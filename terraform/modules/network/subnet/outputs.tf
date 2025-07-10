output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public Subnet ID 리스트"
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Private Subnet ID 리스트"
}

output "private_subnet_ids_app" {
  value       = [for s in aws_subnet.private : s.id if s.tags["type"] == "app"]
  description = "app private subnet"
}

output "private_subnet_ids_data" {
  value       = [for s in aws_subnet.private : s.id if s.tags["type"] == "data"]
  description = "data private subnet"
}