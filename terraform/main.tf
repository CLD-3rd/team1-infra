provider "aws" {
  region = var.aws_region
}

<<<<<<< HEAD
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

=======
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
>>>>>>> 32c994119b640135a73c54950350dfe706de402c
}

module "elasticache" {
  source      = "./modules/elasticache"
  name_prefix = "${var.team_name}-ng"
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.subnet.private_subnet_ids
  # allowed_sg_ids = [ module.eks.workernode_sg_id ] eks 워커노드 sg
  allowed_sg_ids     = [""]
  engine_version     = "7.1"
  node_type          = "cache.r5.large"
  preferred_azs      = ["ap-northeast-2a", "ap-northeast-2c"]
  number_of_replicas = 2
}

