# EKS Cluster Resource
resource "aws_eks_cluster" "this" {
  name     = "${var.name_prefix}-eks-cluster"
  version  = var.kubernetes_version
  role_arn = var.cluster_iam_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.cluster_security_group_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  tags = {
    Name        = "${var.name_prefix}-eks-cluster"
    Environment = var.environment
  }

  # EKS 클러스터 생성 시 필요한 추가 설정 (예: 로깅, 암호화 등)은 여기에 추가
}
