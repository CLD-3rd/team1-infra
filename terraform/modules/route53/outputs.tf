output "zone_id" {
  description = "The ID of the Route 53 Hosted Zone."
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers for the Route 53 Hosted Zone."
  value       = aws_route53_zone.main.name_servers
}
