# S3 Bucket
resource "aws_s3_bucket" "admin_content" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "admin_content" {
  bucket = aws_s3_bucket.admin_content.id

  versioning_configuration {
    status = "Disabled"
  }
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "admin_content" {
  bucket = aws_s3_bucket.admin_content.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "admin_content" {
  bucket = aws_s3_bucket.admin_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM User
resource "aws_iam_user" "s3_admin" {
  name = var.iam_user_name

  tags = {
    Name        = var.iam_user_name
    Environment = var.environment
  }
}

# IAM Policy for S3 Access
resource "aws_iam_user_policy" "s3_admin_policy" {
  name = "${var.iam_user_name}-s3-policy"
  user = aws_iam_user.s3_admin.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.admin_content.arn,
          "${aws_s3_bucket.admin_content.arn}/*"
        ]
      }
    ]
  })
}

# IAM Access Key
resource "aws_iam_access_key" "s3_admin" {
  user = aws_iam_user.s3_admin.name
}

# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "s3_admin_credentials" {
  name                    = var.secret_name
  description             = "Access credentials for ${var.iam_user_name}"
  recovery_window_in_days = var.secret_recovery_days

  tags = {
    Name        = var.secret_name
    Environment = var.environment
  }
}

# Store Access Key in Secrets Manager
resource "aws_secretsmanager_secret_version" "s3_admin_credentials" {
  secret_id = aws_secretsmanager_secret.s3_admin_credentials.id

  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.s3_admin.id
    secret_access_key = aws_iam_access_key.s3_admin.secret
    user_name         = aws_iam_user.s3_admin.name
    bucket_name       = aws_s3_bucket.admin_content.id
  })
}
