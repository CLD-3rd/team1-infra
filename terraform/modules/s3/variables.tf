variable "name_prefix" {
  description = "팀 이름 접두사 (예: team1)"
  type        = string
}

variable "environment" {
  description = "환경명 (dev, prod 등)"
  type        = string
}

variable "enable_versioning" {
  description = "버전 관리 여부"
  type        = bool
  default     = true
}

variable "allow_public_read" {
  description = "퍼블릭 읽기 허용 여부"
  type        = bool
  default     = true
}
