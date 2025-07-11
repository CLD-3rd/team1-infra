resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"        = "${var.name_prefix}-redis.sg"
    "Environment" = var.environment
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.name_prefix}-redis-subnet-group"
  description = "Redis subnet group"
  subnet_ids  = var.subnet_ids
}

resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled = true
  replication_group_id       = "${var.name_prefix}-redis-rg"
  description                = "Redis replication group"
  node_type                  = var.node_type
  num_cache_clusters         = var.number_of_replicas
  parameter_group_name       = "default.redis7"
  port                       = var.port

  engine             = "redis"
  engine_version     = var.engine_version
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  multi_az_enabled            = true
  preferred_cache_cluster_azs = var.preferred_azs

  apply_immediately = true

  tags = {
    "Name"        = "${var.name_prefix}-redis"
    "Environment" = var.environment
  }
}

