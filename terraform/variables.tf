
variable "team_name" {
  description = "Name of team name"
  type        = string
  default     = "team1"
}

variable "environment" {
  description = "환경 태그 (예: dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ec2_ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
  default     = "ami-08943a151bd468f4e" 
}

variable "ec2_instance_type" {
  description = "EC2 인스턴스 유형"
  type        = string
  default     = "t2.micro"
}

variable "ec2_key_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
  default     = "test"
}
