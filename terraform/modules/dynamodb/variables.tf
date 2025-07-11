# DynamoDB 모듈 변수 정의

variable "name_prefix" {
  description = "리소스 이름에 사용할 접두사 (예: team1)"
  type        = string
}

variable "environment" {
  description = "리소스에 태그로 붙을 환경 이름 (예: dev, staging, prod)"
  type        = string
}

variable "hash_key" {
  description = "DynamoDB 테이블의 파티션 키 이름"
  type        = string
}

variable "hash_key_type" {
  description = "파티션 키의 타입 (S: 문자열, N: 숫자, B: 바이너리)"
  type        = string
  default     = "S"
}
