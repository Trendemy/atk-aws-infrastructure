variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "iam_user_name" {
  description = "Name of the IAM user"
  type        = string
  default     = "atk-admin-content-user"
}

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
  default     = "atk-admin-content-credentials"
}

variable "secret_recovery_days" {
  description = "Number of days to retain secret after deletion"
  type        = number
  default     = 7
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
