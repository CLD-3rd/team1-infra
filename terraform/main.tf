terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.team_name}-key-pair"
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name        = "${var.team_name}-key-pair"
    Environment = var.environment
  }
}

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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

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

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

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

  allowed_sg_ids     = [module.eks.cluster_security_group_id]
  engine_version     = "7.1"
  node_type          = "cache.r5.large"
  preferred_azs      = ["ap-northeast-2a", "ap-northeast-2c"]
  number_of_replicas = 2
}

module "eks" {
  source      = "./modules/eks"
  name_prefix = var.team_name
  environment = "dev"
  cluster_iam_role_arn = aws_iam_role.eks_cluster_role.arn    # EKS 클러스터 IAM 역할 ARN 연결
  subnet_ids           = module.subnet.private_subnet_ids_app # EKS 클러스터는 Private Subnet에 배포
  # cluster_security_group_ids = [aws_security_group.eks_cluster_sg.id] # 필요시 EKS 클러스터 보안 그룹 지정
}

resource "aws_security_group_rule" "eks_api_from_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id        = module.eks.cluster_security_group_id
  description              = "Allow bastion sg to access eks"
}

module "eks_node_group" {
  source       = "./modules/eks-node-group"
  name_prefix  = var.team_name
  environment  = "dev"
  cluster_name = module.eks.cluster_name
  # EKS 노드 그룹이 사용할 IAM 역할 ARN을 지정해야 합니다.
  node_role_arn                           = aws_iam_role.eks_node_role.arn   # EKS 노드 그룹 IAM 역할 ARN 연결
  subnet_ids                              = module.subnet.private_subnet_ids # 노드 그룹은 Private Subnet에 배포
  ssh_key_name                            = aws_key_pair.this.key_name
  remote_access_source_security_group_ids = [aws_security_group.ec2_sg.id]
}

# EC2 인스턴스에 적용할 보안 그룹
resource "aws_security_group" "ec2_sg" {
  name        = "${var.team_name}-ec2-sg"
  description = "Allow HTTP and SSH traffic to EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.team_name}-ec2-sg"
    Environment = var.environment
  }
}
# ── Bastion EC2가 IMDS로 자격 증명을 받게 하는 역할 ──
resource "aws_iam_role" "bastion_role" {
  name = "${var.team_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.team_name}-bastion-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "bastion_eks_readonly" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.team_name}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

# EC2 인스턴스 모듈
module "ec2" {
  source             = "./modules/ec2"
  name_prefix        = var.team_name
  environment        = var.environment
  ami_id             = var.ec2_ami_id
  instance_type      = var.ec2_instance_type
  subnet_id          = module.subnet.public_subnet_ids[0] # 퍼블릭 서브넷에 배포
  security_group_ids = [aws_security_group.ec2_sg.id]
  key_name           = aws_key_pair.this.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  tags               = {}
}

#RDS
module "rds" {
  source             = "./modules/rds"
  name_prefix        = var.team_name
  environment        = "dev"
  private_subnet_ids = module.subnet.private_subnet_ids
  security_group_id  = module.rds_sg.security_group_id

  db_name  = "team1db"
  username = "admin"
  password = var.rds_password
}

#RDS 보안그룹
module "rds_sg" {
  source      = "./modules/security-group"
  name_prefix = var.team_name
  sg_name     = "rds"
  description = "Allow MySQL from EKS Node or Bastion"
  vpc_id      = module.vpc.vpc_id
  environment = "dev"

  ingress_rules = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [module.eks_node_sg.security_group_id, module.eks.cluster_security_group_id] # EKS 노드 + 클러스터 SG 허용
      description     = "Allow MySQL from EKS nodes"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

}
#eks node 보안그룹
module "eks_node_sg" {
  source      = "./modules/security-group"
  name_prefix = var.team_name
  sg_name     = "eks-node"
  description = "EKS Node SG"
  vpc_id      = module.vpc.vpc_id
  environment = "dev"

  ingress_rules = [
    {
      from_port   = 1025
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "Allow high ports for internal traffic"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]
}

module "dynamodb" {
  source        = "./modules/dynamodb"
  name_prefix   = var.team_name
  environment   = "dev"
  hash_key      = "album_id"
  hash_key_type = "S"
}


module "s3" {
  source            = "./modules/s3"
  name_prefix       = var.team_name
  environment       = "dev"
  enable_versioning = true
  allow_public_read = true
}

# module "route53" {
#   source      = "./modules/route53"
#   domain_name = var.domain_name
#   tags = {
#     Name = "${var.team_name}-r53-zone"
#   }

#   records = [
#     {
#       name = "www"
#       type = "A"

#       alias = {
#         name                   = module.alb_vinyl.alb_dns_name
#         zone_id                = module.alb_vinyl.alb_zone_id
#         evaluate_target_health = true
#       }
#     },
#     {
#       name = "vinyl"
#       type = "CNAME"
#       alias = {
#         name                   = module.alb_vinyl.alb_dns_name
#         zone_id                = module.alb_vinyl.alb_zone_id
#         evaluate_target_health = true
#       }
#     },
#     {
#       name = "argocd"
#       type = "CNAME"
#       alias = {
#         name                   = module.alb_argocd.alb_dns_name
#         zone_id                = module.alb_argocd.alb_zone_id
#         evaluate_target_health = true
#       }
#     }
#   ]

#   create_acm_certificate = true
#   acm_domain_name        = "*.${var.domain_name}"
# }

// alb 모듈
# module "alb_vinyl" {
#   source                = "./modules/alb"
#   name_prefix           = "${var.team_name}-vinyl"
#   environment           = "dev"
#   vpc_id                = module.vpc.vpc_id
#   public_subnet_ids     = module.subnet.public_subnet_ids
#   security_group_id     = module.alb_sg.security_group_id
#   target_port           = 80 
#   acm_certificate_arn   = module.route53.acm_certificate_arn
#   create_https_listener = true
# }

# module "alb_argocd" {
#   source                = "./modules/alb"
#   name_prefix           = "${var.team_name}-argocd"
#   environment           = "dev"
#   vpc_id                = module.vpc.vpc_id
#   public_subnet_ids     = module.subnet.public_subnet_ids
#   security_group_id     = module.alb_sg.security_group_id # You might want a specific SG for ArgoCD
#   target_port           = 80                             
#   acm_certificate_arn   = module.route53.acm_certificate_arn
#   create_https_listener = true
# }

# //alb sg
# module "alb_sg" {
#   source      = "./modules/security-group"
#   name_prefix = var.team_name
#   sg_name     = "alb"
#   description = "Security group for ALB"
#   vpc_id      = module.vpc.vpc_id
#   environment = "dev"

#   ingress_rules = [
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow HTTP from anywhere"
#     },
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow HTTPS from anywhere"
#     }
#   ]

#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow all outbound"
#     }
#   ]
# }

// alb iam 컨트롤러 정책
module "iam_alb_controller" {
  source       = "./modules/iam_alb_controller"
  cluster_name = module.eks.cluster_name # 기존 EKS 클러스터 이름 사용
  region       = "ap-northeast-2"        # 클러스터 리전 명시

  depends_on   = [module.eks]             # EKS 생성 이후 적용
}


// EC2 키 페어 개인 키를 로컬에 파일로 저장
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.module}/${var.team_name}-key-pair.pem"
  file_permission = "0400"
}

# // IRSA: Vinyl 애플리케이션용 서비스 어카운트 생성
# module "vinyl_irsa" {
#   source               = "./modules/irsa"
#   role_name            = "eks-vinyl-app-role"
#   namespace            = "vinyl"
#   service_account_name = "vinyl-app-sa"
#   oidc_provider_url    = module.eks.oidc_provider
#   oidc_provider_arn    = module.eks.oidc_provider_arn
#   policy_arns          = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
# }

# // IRSA: ArgoCD Repo 서버용 서비스 어카운트 생성
# module "argocd_repo_irsa" {
#   source               = "./modules/irsa"
#   role_name            = "eks-argocd-repo-role"
#   namespace            = "argocd"
#   service_account_name = "argocd-repo-server"
#   oidc_provider_url    = module.eks.oidc_provider
#   oidc_provider_arn    = module.eks.oidc_provider_arn
#   policy_arns          = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
# }