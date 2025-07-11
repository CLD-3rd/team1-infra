output "rds_endpoint" {
  description = "RDS 접속 엔드포인트"
  value       = aws_db_instance.this.endpoint
}

output "rds_identifier" {
  value = aws_db_instance.this.id
}

output "rds_password" {
  value     = var.password
  sensitive = true
}
