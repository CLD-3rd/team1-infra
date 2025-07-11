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
