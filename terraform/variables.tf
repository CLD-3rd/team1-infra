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