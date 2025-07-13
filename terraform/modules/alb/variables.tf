variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "target_port" {
  type    = number
  default = 80
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to associate with the ALB listener."
  type        = string
  default     = null
}

variable "create_https_listener" {
  description = "Whether to create an HTTPS listener for the ALB."
  type        = bool
  default     = false
}
