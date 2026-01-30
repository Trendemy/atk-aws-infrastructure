output "instance_id" {
  value       = aws_db_instance.postgres.id
  description = "RDS instance ID."
}

output "instance_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "Endpoint for the RDS instance."
}

output "instance_address" {
  value       = aws_db_instance.postgres.address
  description = "Address for the RDS instance."
}

output "instance_port" {
  value       = aws_db_instance.postgres.port
  description = "Port for the RDS instance."
}

output "security_group_id" {
  value       = aws_security_group.rds.id
  description = "Security group ID for the RDS instance."
}

output "rds_secret_arn" {
  value       = var.create_rds_secret ? aws_secretsmanager_secret.rds[0].arn : null
  description = "Secrets Manager ARN for the RDS credentials."
}
