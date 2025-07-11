output "bucket_name" {
  description = "버킷 이름"
  value       = aws_s3_bucket.this.bucket
}
