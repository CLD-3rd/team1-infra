# EKS Node Group Resource
resource "aws_eks_node_group" "this" {
  # 리소스 이름은 팀 prefix로 시작
  cluster_name    = var.cluster_name
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # 태그는 공통 형식으로 지정
  tags = {
    Name        = "${var.name_prefix}-node-group"
    Environment = var.environment
  }

  # EKS 노드 그룹 생성 시 필요한 추가 설정 (예: AMI 타입, 원격 액세스 등)은 여기에 추가

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = var.remote_access_source_security_group_ids
  }
}
