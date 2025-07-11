variable "name_prefix" {
  description = "리소스 이름에 사용될 접두사"
  type        = string
}

variable "environment" {
  description = "환경 태그"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS 클러스터의 Kubernetes 버전"
  type        = string
  default     = "1.31"
}

variable "cluster_iam_role_arn" {
  description = "EKS 클러스터가 사용할 IAM 역할의 ARN"
  type        = string
}

variable "subnet_ids" {
  description = "EKS 클러스터가 배포될 서브넷 ID 목록"
  type        = list(string)
}

variable "cluster_security_group_ids" {
  description = "EKS 클러스터에 연결될 보안 그룹 ID 목록"
  type        = list(string)
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "EKS 클러스터 엔드포인트에 대한 프라이빗 액세스 활성화 여부"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "EKS 클러스터 엔드포인트에 대한 퍼블릭 액세스 활성화 여부"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "EKS 클러스터 퍼블릭 엔드포인트에 액세스할 수 있는 CIDR 블록 목록"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
