variable "name_prefix" {
  description = "리소스 이름 접두어 (ex: team1)"
  type        = string
}

variable "environment" {
  description = "환경 (dev, prod 등)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "port" {
  description = "Redis 사용 port"
  type        = number
  default     = 6379
}

variable "allowed_sg_ids" {
  description = "Redis 접속 허용 id 리스트"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Redis subnet group에 속할 private subnet id 리스트"
  type        = list(string)
}

variable "engine_version" {
  description = "redis engine version"
  type        = string
}

variable "node_type" {
  description = "redis node instance type"
  type        = string
}

variable "number_of_replicas" {
  description = "redis node 수"
  type        = number
}

variable "preferred_azs" {
  description = "Redis 사용 az"
  type        = list(string)
}

