output "redis_primary_ep" {
  value = module.elasticache.redis_primary_ep
}

output "redis_port" {
  value = module.elasticache.redis_port
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_port" {
  value = module.rds.rds_port
}

output "private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "local_ssh_key_path" {
  description = "Path to the locally saved SSH private key file."
  value       = local_file.ssh_private_key.filename
}