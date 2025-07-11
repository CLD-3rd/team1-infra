variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
