provider "aws" {
  region = "ap-northeast-2"
}

# EKS 클러스터 IAM 역할
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.team_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.team_name}-eks-cluster-role"
    Environment = var.environment
  }
}

# EKS 클러스터 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS 서비스 정책 연결
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS 노드 그룹 IAM 역할
resource "aws_iam_role" "eks_node_role" {
  name = "${var.team_name}-eks-node-role" # 팀 prefix를 사용한 역할 이름

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.team_name}-eks-node-role"
    Environment = var.environment
  }
}

# EKS 워커 노드 정책 연결
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

# EKS CNI 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# EC2 컨테이너 레지스트리 읽기 전용 정책 연결
resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

module "vpc" {
  source      = "./modules/network/vpc"
  name_prefix = var.team_name
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "subnet" {
  source               = "./modules/network/subnet"
  name_prefix          = var.team_name
  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  azs                  = ["ap-northeast-2a", "ap-northeast-2c"]
}

module "internet_gateway" {
  source      = "./modules/network/internet-gateway"
  name_prefix = var.team_name
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
}

module "route_table" {
  source            = "./modules/network/route-table"
  name_prefix       = var.team_name
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  igw_id            = module.internet_gateway.igw_id
  public_subnet_ids = module.subnet.public_subnet_ids
}

module "nat_gateway" {
  source             = "./modules/network/nat-gateway"
  name_prefix        = var.team_name
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.internet_gateway.igw_id
  public_subnet_id   = module.subnet.public_subnet_ids[0]
  private_subnet_ids = module.subnet.private_subnet_ids
}

module "elasticache" {
  source      = "./modules/elasticache"
  name_prefix = "${var.team_name}-ng"
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.subnet.private_subnet_ids_data
  # allowed_sg_ids = [ module.eks.workernode_sg_id ] eks 워커노드 sg
  allowed_sg_ids     = [""]
  engine_version     = "7.1"
  node_type          = "cache.r5.large"
  preferred_azs      = ["ap-northeast-2a", "ap-northeast-2c"]
  number_of_replicas = 2
}

# EKS 클러스터 모듈
module "eks" {
  source      = "./modules/eks"
  name_prefix = var.team_name
  environment = "dev"
  # EKS 클러스터가 사용할 IAM 역할 ARN을 지정해야 합니다.
  # 예: aws_iam_role.eks_cluster_role.arn
  cluster_iam_role_arn = aws_iam_role.eks_cluster_role.arn    # EKS 클러스터 IAM 역할 ARN 연결
  subnet_ids           = module.subnet.private_subnet_ids_app # EKS 클러스터는 Private Subnet에 배포
  # cluster_security_group_ids = [aws_security_group.eks_cluster_sg.id] # 필요시 EKS 클러스터 보안 그룹 지정
}

# EKS 노드 그룹 모듈
module "eks_node_group" {
  source       = "./modules/eks-node-group"
  name_prefix  = var.team_name
  environment  = "dev"
  cluster_name = module.eks.cluster_name
  # EKS 노드 그룹이 사용할 IAM 역할 ARN을 지정해야 합니다.
  # 예: aws_iam_role.eks_node_role.arn
  node_role_arn = aws_iam_role.eks_node_role.arn       # EKS 노드 그룹 IAM 역할 ARN 연결
  subnet_ids    = module.subnet.private_subnet_ids_app # 노드 그룹은 Private Subnet에 배포
}

module "dynamodb" {
  source        = "./modules/dynamodb"
  name_prefix   = var.team_name
  environment   = "dev"

  hash_key      = "album_id"
  hash_key_type = "S"
}
