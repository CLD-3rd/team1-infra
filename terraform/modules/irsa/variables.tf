variable "role_name" {
  type        = string
  description = "생성할 IAM Role 이름"
}

variable "namespace" {
  type        = string
  description = "ServiceAccount가 존재할 K8s 네임스페이스"
}

variable "service_account_name" {
  type        = string
  description = "ServiceAccount 이름"
}

variable "oidc_provider_url" {
  type        = string
  description = "EKS의 OIDC 공급자 URL (https:// 포함)"
}

variable "oidc_provider_arn" {
  type        = string
  description = "EKS의 OIDC 공급자 ARN"
}

variable "policy_arns" {
  type        = list(string)
  default     = []
  description = "연결할 IAM 정책 ARN 목록"
}
