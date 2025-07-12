resource "aws_s3_bucket" "this" {
  bucket        = "${var.name_prefix}-s3-${var.environment}"
  force_destroy = true

  tags = {
    Name        = "${var.name_prefix}-s3-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !var.allow_public_read
  block_public_policy     = false
  ignore_public_acls      = !var.allow_public_read
  restrict_public_buckets = !var.allow_public_read
}

resource "aws_s3_bucket_policy" "public_read" {
  count  = var.allow_public_read ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}
