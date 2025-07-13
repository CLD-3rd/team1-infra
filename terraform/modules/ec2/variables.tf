variable "name_prefix" {
  description = "리소스를 식별하는 데 사용되는 접두사"
  type        = string
}

variable "environment" {
  description = "배포 환경 (예: dev, stg, prd)"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
}

variable "subnet_id" {
  description = "EC2 인스턴스를 배포할 서브넷 ID"
  type        = string
}

variable "security_group_ids" {
  description = "EC2 인스턴스에 적용할 보안 그룹 ID 목록"
  type        = list(string)
}

variable "key_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
}

variable "tags" {
  description = "EC2 인스턴스에 추가할 태그 맵"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile" {
  description = "EC2에 연결할 IAM Instance Profile 이름(없으면 빈 문자열)"
  type        = string
  default     = ""
}