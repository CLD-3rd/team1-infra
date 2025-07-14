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
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0ecd4e9b5"] # AWS 기본 thumbprint
}
