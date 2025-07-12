#!/bin/bash

# === 설정값 ===
CLUSTER_NAME="team1-dev-eks"
REGION="ap-northeast-2"
VPC_ID="<YOUR_VPC_ID>"  # Terraform 출력값 사용 권장
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
NAMESPACE="kube-system"
ROLE_ARN="<YOUR_IAM_ROLE_ARN>"  # Terraform 출력값 사용 권장

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