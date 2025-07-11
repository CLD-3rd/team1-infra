output "repository_arn" {
  description = "리포지토리의 Amazon 리소스 이름(ARN)"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "리포지토리의 이름"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "리포지토리의 URL"
  value       = aws_ecr_repository.this.repository_url
}