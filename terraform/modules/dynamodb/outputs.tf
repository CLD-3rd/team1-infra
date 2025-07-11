# DynamoDB 테이블 이름 출력
output "dynamodb_table_name" {
  description = "생성된 DynamoDB 테이블 이름"
  value       = aws_dynamodb_table.this.name
}
