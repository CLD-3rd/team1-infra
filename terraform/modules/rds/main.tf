resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.environment}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.name_prefix}-${var.environment}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier           = "${var.name_prefix}-${var.environment}-rds"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "${var.name_prefix}-${var.environment}-rds"
  }
}
