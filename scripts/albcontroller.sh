#!/bin/bash

# === 설정값 ===
CLUSTER_NAME="team1-eks-cluster"
REGION="ap-northeast-2"
VPC_ID="vpc-0bf6101828762ca8c"  # Terraform 출력값 사용 권장
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
NAMESPACE="kube-system"
ROLE_ARN="arn:aws:iam::715411139253:role/team1-eks-cluster-alb-controller-role"  # Terraform 출력값 사용 권장
ARCH=amd64
BASTION_ROLE_ARN="arn:aws:iam::715411139253:role/team1-bastion-role"
PUB_SUBNET1="subnet-0c41b2fa45c193119"
PUB_SUBNET2="subnet-07ac69a6a746b67ea"

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg unzip
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

eksctl create iamidentitymapping \
  --cluster team1-eks-cluster \
  --arn $BASTION_ROLE_ARN \
  --group system:masters \
  --username bastion \
  --region ap-northeast-2

# === 클러스터 연결 ===
echo "[INFO] update-kubeconfig for EKS cluster..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

# === Helm 리포지토리 등록 ===
echo "[INFO] Add Helm repo for AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# === ServiceAccount 생성 (IRSA 연결용) ===
echo "[INFO] Create ServiceAccount with IAM Role (IRSA)..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SERVICE_ACCOUNT_NAME
  namespace: $NAMESPACE
  annotations:
    eks.amazonaws.com/role-arn: "$ROLE_ARN"
EOF

# === Helm 설치 ===
echo "[INFO] Installing AWS Load Balancer Controller with Helm..."
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n $NAMESPACE \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SERVICE_ACCOUNT_NAME \
  --set region=$REGION \
  --set vpcId=$VPC_ID \
  --set ingressClass=alb

echo "AWS Load Balancer Controller 설치 완료"

# === Prometheus & Grafana 설치 ===
echo "[INFO] Add Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "[INFO] Installing kube-prometheus-stack (Prometheus + Grafana)"
helm upgrade -i kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer \
  --set grafana.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing" \
  --set prometheus.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-scheme"="internet-facing"

echo "[INFO] Tagging public subnets for ELB..."
aws ec2 create-tags --resources $PUB_SUBNET1 $PUB_SUBNET2 \
  --tags Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=owned \
         Key=kubernetes.io/role/elb,Value=1

# === Prometheus & Grafana 서비스에 public 서브넷 명시 ===
PUB_SUBNETS="$PUB_SUBNET1,$PUB_SUBNET2"
echo "[INFO] Annotating Grafana service for internet-facing ELB..."
kubectl -n monitoring annotate svc kube-prometheus-stack-grafana \
  service.beta.kubernetes.io/aws-load-balancer-scheme="internet-facing" \
  service.beta.kubernetes.io/aws-load-balancer-subnets="$PUB_SUBNETS" \
  --overwrite

echo "[INFO] Annotating Prometheus service for internet-facing ELB..."
kubectl -n monitoring annotate svc kube-prometheus-stack-prometheus \
  service.beta.kubernetes.io/aws-load-balancer-scheme="internet-facing" \
  service.beta.kubernetes.io/aws-load-balancer-subnets="$PUB_SUBNETS" \
  --overwrite

echo "[INFO] Waiting for Grafana to be ready"
kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring --timeout=10m

echo "[INFO] Prometheus & Grafana installation completed"


mkdir -p manifest/argocd
cd manifest/argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# --- Ensure Argo CD namespace exists ---
if ! kubectl get namespace argocd >/dev/null 2>&1; then
  echo "[INFO] Creating argocd namespace..."
  kubectl create namespace argocd
fi

# 기본 values 가져오기
helm show values argo/argo-cd > base-values.yaml
cp base-values.yaml my-values.yaml

# my-values.yaml 수정
cat <<EOF >> my-values.yaml
server:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-subnets: "$PUB_SUBNETS"
  ingress:
    enabled: false
EOF

# kustomization.yaml 생성
cat <<EOF > kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: argocd
resources:
  - install.yaml
EOF

helm template argo-cd argo/argo-cd \
  --namespace argocd \
  -f my-values.yaml \
  > install.yaml

cd ~/manifest/argocd
kubectl apply -k .


kubectl -n argocd annotate svc argo-cd-argocd-server \
  service.beta.kubernetes.io/aws-load-balancer-scheme="internet-facing" \
  service.beta.kubernetes.io/aws-load-balancer-subnets="$PUB_SUBNETS" \
  --overwrite


echo "[INFO] Grafana admin password:"
kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode; echo
echo "[INFO] ArgoCD admin password:"
ADMIN_SECRET=$(kubectl -n argocd get secret -o name | grep 'initial-admin' | head -n1 | cut -d'/' -f2)
if [ -z "$ADMIN_SECRET" ]; then
  echo "Admin secret not found yet. Wait a few moments and retry:"
  echo "  kubectl -n argocd get secret | grep initial-admin"
else
  kubectl -n argocd get secret "$ADMIN_SECRET" -o jsonpath="{.data.password}" | base64 --decode; echo
fi
