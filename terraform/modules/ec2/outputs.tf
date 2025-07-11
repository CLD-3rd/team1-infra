output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
  value       = aws_instance.this.public_ip
}

output "instance_id" {
  description = "EC2 인스턴스의 ID"
  value       = aws_instance.this.id
}