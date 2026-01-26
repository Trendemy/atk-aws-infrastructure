variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use. Leave empty to use the EC2 state or default VPC."
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the DB subnet group. Leave empty to use EC2 state or all VPC subnets."
  default     = []
}

variable "ec2_security_group_id" {
  type        = string
  description = "EC2 security group ID allowed to access Postgres. Leave empty to read from EC2 state."
  default     = ""
}

variable "ec2_state_bucket" {
  type        = string
  description = "S3 bucket name for the EC2 terraform state."
  default     = "atk-terraform-state-bucket"
}

variable "ec2_state_key" {
  type        = string
  description = "S3 key for the EC2 terraform state."
  default     = "atk-aws-infrastructure/ec2/terraform.tfstate"
}

variable "ec2_state_region" {
  type        = string
  description = "AWS region for the EC2 terraform state bucket. Leave empty to use aws_region."
  default     = ""
}

variable "cluster_identifier" {
  type        = string
  description = "Identifier for the RDS instance."
  default     = "atk-postgres"
}

variable "engine" {
  type        = string
  description = "RDS engine for the instance."
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Postgres engine version."
  default     = "16.10"
}

variable "db_name" {
  type        = string
  description = "Initial database name."
  default     = "atk"
}

variable "master_username" {
  type        = string
  description = "Master username."
  default     = "postgres"
}

variable "master_password" {
  type        = string
  description = "Master password."
  sensitive   = true
  default     = ""
}

variable "instance_class" {
  type        = string
  description = "Instance class for the DB instance."
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB."
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "Storage type for the DB instance."
  default     = "gp3"
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment."
  default     = false
}

variable "storage_encrypted" {
  type        = bool
  description = "Enable storage encryption."
  default     = true
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days to retain backups."
  default     = 7
}

variable "publicly_accessible" {
  type        = bool
  description = "Whether the DB instance is publicly accessible."
  default     = false
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "Additional CIDR blocks allowed to access Postgres."
  default     = []
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy."
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection."
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Apply modifications immediately."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}

variable "create_rds_secret" {
  type        = bool
  description = "Store RDS credentials in AWS Secrets Manager."
  default     = true
}

variable "rds_secret_name" {
  type        = string
  description = "Secrets Manager name for the RDS credentials."
  default     = "atk-postgres-credentials"
}

variable "rds_secret_kms_key_id" {
  type        = string
  description = "Optional KMS key ID/ARN for encrypting the RDS secret."
  default     = ""
}
