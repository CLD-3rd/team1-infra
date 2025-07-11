resource "aws_dynamodb_table" "this" {
  name         = "${var.name_prefix}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = {
    Name        = "${var.name_prefix}-dynamodb"
    Environment = var.environment
  }
}
