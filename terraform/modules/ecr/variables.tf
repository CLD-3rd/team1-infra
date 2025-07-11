variable "repository_name" {
  description = "리포지토리의 이름"
  type        = string
}

variable "image_tag_mutability" {
  description = "리포지토리의 태그 변경 가능성 설정"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "이미지가 리포지토리에 푸시될 때 취약점에 대해 스캔되는지 여부."
  type        = bool
  default     = true
}

variable "environment" {
  description = "환경 태그 (예: dev, staging, prod"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "리소스에 할당할 태그 맵"
  type        = map(string)
  default     = {}
}