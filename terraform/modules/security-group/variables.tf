variable "name_prefix" {
  type        = string
  description = "리소스 이름 접두사"
}

variable "sg_name" {
  type        = string
  description = "보안 그룹 이름"
}

variable "description" {
  type        = string
  description = "보안 그룹 설명"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "environment" {
  type        = string
  description = "환경명 (dev, prod 등)"
}

variable "ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
    description     = optional(string)
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
    description     = optional(string)
  }))
  default = []
}