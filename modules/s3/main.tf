# S3 버킷
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# S3 버전 관리
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
