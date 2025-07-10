provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

module "vpc" {
  source      = "./modules/network/vpc"
  name_prefix = "${var.team_name}-vpc"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "subnet" {
  source               = "./modules/network/subnet"
  name_prefix          = "${var.team_name}-subnet"
  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  azs                  = ["ap-northeast-2a", "ap-northeast-2c"]
}

module "internet_gateway" {
  source      = "./modules/network/internet-gateway"
  name_prefix = "${var.team_name}-ig"
  environment = "dev"
  vpc_id      = module.vpc.vpc_id
}

module "route_table" {
  source            = "./modules/network/route-table"
  name_prefix       = "${var.team_name}-rt"
  environment       = "dev"
  vpc_id            = module.vpc.vpc_id
  igw_id            = module.internet_gateway.igw_id
  public_subnet_ids = module.subnet.public_subnet_ids
}

module "nat_gateway" {
  source             = "./modules/network/nat-gateway"
  name_prefix        = "${var.team_name}-ng"
  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.internet_gateway.igw_id
  public_subnet_id   = module.subnet.public_subnet_ids[0]
  private_subnet_ids = module.subnet.private_subnet_ids
}
