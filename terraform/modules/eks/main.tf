provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 1.3.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  eks_managed_node_groups = {
    default = {
      name           = "${var.name_prefix}-nodes"
      desired_size   = var.node_group_desired_capacity
      min_size       = var.node_group_min_capacity
      max_size       = var.node_group_max_capacity
      instance_types = var.node_instance_types
      tags = {
        Name        = "${var.name_prefix}-node"
        Environment = var.environment
      }
    }
  }

  tags = {
    Name        = "${var.name_prefix}-eks-${var.environment}"
    Environment = var.environment
  }
}
