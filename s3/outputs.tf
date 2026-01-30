output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.admin_content.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.admin_content.arn
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.admin_content.region
}

output "iam_user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.s3_admin.name
}

output "iam_user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.s3_admin.arn
}

output "secret_id" {
  description = "ID of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.s3_admin_credentials.id
}

output "secret_arn" {
  description = "ARN of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.s3_admin_credentials.arn
}

output "access_key_id" {
  description = "Access Key ID (sensitive - use secret manager instead)"
  value       = aws_iam_access_key.s3_admin.id
  sensitive   = true
}
