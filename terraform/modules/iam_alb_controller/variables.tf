variable "cluster_name" {
  type        = string
  description = "EKS 클러스터 이름"
}

variable "region" {
  type        = string
  description = "EKS 클러스터가 존재하는 리전"
  default     = "ap-northeast-2"
}
