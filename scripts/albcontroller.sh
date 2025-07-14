#!/bin/bash

# === 설정값 ===
CLUSTER_NAME="team1-eks-cluster"
REGION="ap-northeast-2"
VPC_ID="vpc-0dafb01ec03de6efe"  # Terraform 출력값 사용 권장
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
NAMESPACE="kube-system"
ROLE_ARN="arn:aws:iam::061039804626:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/A12FE5318CC62DC0A76EF2E04F11BFAE"  # Terraform 출력값 사용 권장
ARCH=amd64
BASTION_ROLE_ARN=""

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
  --username bastion

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
  --set prometheus.service.type=LoadBalancer

echo "[INFO] Waiting for Grafana to be ready"
kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring --timeout=10m

echo "[INFO] Prometheus & Grafana installation completed"
echo "[INFO] Grafana admin password:"
kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode; echo
