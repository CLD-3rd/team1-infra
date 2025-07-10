provider "aws" {
  region = var.aws_region
}

module "eks" {
  source                      = "./modules/eks"
  name_prefix                 = var.name_prefix
  environment                 = var.environment
  cluster_name                = var.cluster_name
  cluster_version             = var.kubernetes_version
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.subnet.private_subnet_ids
  public_subnets              = module.subnet.public_subnet_ids
  node_group_min_capacity     = var.node_group_min_size
  node_group_desired_capacity = var.node_group_desired_size
  node_group_max_capacity     = var.node_group_max_size
  node_instance_types         = [var.node_instance_type]
  region                      = var.aws_region
}
