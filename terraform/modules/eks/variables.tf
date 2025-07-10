variable "name_prefix" {
  description = "리소스 이름 접두어 (예: team1)"
  type        = string
}

variable "environment" {
  description = "배포 환경 (예: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS 리전"
  type        = string
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes 버전"
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "EKS를 배치할 VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "퍼블릭 서브넷 ID 리스트"
  type        = list(string)
}

variable "private_subnets" {
  description = "프라이빗 서브넷 ID 리스트"
  type        = list(string)
}

variable "node_group_min_capacity" {
  description = "노드그룹 최소 인스턴스 수"
  type        = number
  default     = 1
}

variable "node_group_desired_capacity" {
  description = "노드그룹 기본 인스턴스 수"
  type        = number
  default     = 2
}

variable "node_group_max_capacity" {
  description = "노드그룹 최대 인스턴스 수"
  type        = number
  default     = 3
}

variable "node_instance_types" {
  description = "노드 인스턴스 타입 리스트"
  type        = list(string)
  default     = ["t3.medium"]
}
