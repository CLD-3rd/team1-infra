variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "create_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Existing hosted zone ID (if not creating new)"
  type        = string
  default     = ""
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }), null)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}

variable "create_acm_certificate" {
  description = "Whether to create an ACM certificate"
  type        = bool
  default     = false
}

variable "acm_domain_name" {
  description = "Domain name for the ACM certificate (e.g., *.example.com)"
  type        = string
  default     = ""
}

variable "acm_validation_method" {
  description = "Validation method for the ACM certificate (e.g., DNS, EMAIL)"
  type        = string
  default     = "DNS"
}