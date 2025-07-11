output "redis_primary_ep" {
  description = "Redis primary 엔드포인트"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_ep" {
  description = "Redis reader 엔드포인트"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_security_group_id" {
  description = "Redis sg id"
  value       = aws_security_group.redis.id
}

output "redis_subnet_group_name" {
  description = "Redis subnet group name"
  value       = aws_elasticache_subnet_group.redis.name
}

output "redis_port" {
  value = aws_elasticache_replication_group.redis.port
}
