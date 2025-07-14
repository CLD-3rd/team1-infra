output "redis_primary_ep" {
  value = module.elasticache.redis_primary_ep
}

output "redis_port" {
  value = module.elasticache.redis_port
}

output "rds_endpoint" {
  value     = module.rds.rds_endpoint
  sensitive = true
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
  value       = local_file.ssh_private_key.content
  sensitive   = true

}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnet.public_subnet_ids
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "alb_controller_role_arn" {
  value = module.iam_alb_controller.alb_controller_role_arn
}

output "alb_vinyl_dns_name" {
  value = module.alb_vinyl.alb_dns_name
}

output "alb_vinyl_zone_id" {
  value = module.alb_vinyl.alb_zone_id
}

output "alb_argocd_dns_name" {
  value = module.alb_argocd.alb_dns_name
}

output "alb_argocd_zone_id" {
  value = module.alb_argocd.alb_zone_id
}

output "s3_bucket" {
  value = module.s3.bucket_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate created by the route53 module"
  value       = module.route53.acm_certificate_arn
}

output "bastion_role_arn" {
  description = "IAM Role ARN for the Bastion EC2 instance"
  value       = aws_iam_role.bastion_role.arn
}