# EKS Node Group Module Variables

variable "name_prefix" {
  description = "리소스 이름에 사용될 접두사 (예: team1)"
  type        = string
}

variable "environment" {
  description = "환경 태그 (예: dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "노드 그룹이 연결될 EKS 클러스터의 이름"
  type        = string
}

variable "node_role_arn" {
  description = "EKS 노드 그룹이 사용할 IAM 역할의 ARN"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 노드 그룹이 배포될 서브넷 ID 목록"
  type        = list(string)
}

variable "instance_types" {
  description = "노드 그룹에 사용될 인스턴스 타입 목록"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "노드 그룹의 원하는 인스턴스 수"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "노드 그룹의 최대 인스턴스 수"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "노드 그룹의 최소 인스턴스 수"
  type        = number
  default     = 1
}

variable "ssh_key_name" {
  description = "ssh key pair name to connect node remote"
  type        = string
}

variable "remote_access_source_security_group_ids" {
  description = "sg id list to allow remote connection (bastion SG)"
  type        = list(string)
}
