resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = merge(
    {
      Name        = "${var.name_prefix}-ec2-instance"
      Environment = var.environment
    },
    var.tags
  )
}
