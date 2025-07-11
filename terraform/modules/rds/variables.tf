variable "name_prefix" {
  type        = string
  description = "리소스 이름 접두사"
}

variable "environment" {
  type        = string
  description = "dev / prod 등 환경 구분"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "RDS가 배치될 프라이빗 서브넷 ID 리스트"
}

variable "security_group_id" {
  type        = string
  description = "RDS 인스턴스에 적용할 보안 그룹 ID"
}

variable "db_name" {
  type        = string
  description = "DB 이름"
}

variable "username" {
  type        = string
  description = "DB 관리자 계정"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "DB 비밀번호"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "parameter_group_name" {
  type    = string
  default = "default.mysql8.0"
}
