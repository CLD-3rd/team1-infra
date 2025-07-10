variable "team_name" {
  description = "Name of team name"
  type        = string
  default     = "team1"
<<<<<<< HEAD
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "kubernetes_version" {
  description = "EKS kubernetes version"
  type        = string
  default     = "1.27"
}

variable "node_instance_type" {
  description = "EKS node instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_group_min_size" {
  description = "EKS node group min size"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "EKS node group max size"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "EKS node group desired size"
  type        = number
  default     = 2
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "team1-eks"
}

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet cidr blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet cidr blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    "Terraform" = "true"
  }
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "team1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
=======

>>>>>>> 32c994119b640135a73c54950350dfe706de402c
}