output "instance_id" {
  value       = aws_instance.app.id
  description = "EC2 instance ID."
}

output "public_ip" {
  value       = aws_instance.app.public_ip
  description = "Public IP of the EC2 instance."
}

output "ec2_security_group_id" {
  value       = aws_security_group.ec2.id
  description = "Security group ID attached to the EC2 instance."
}

output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID used by the EC2 instance."
}

output "subnet_id" {
  value       = local.subnet_id
  description = "Subnet ID used by the EC2 instance."
}

output "vpc_subnet_ids" {
  value       = data.aws_subnets.selected.ids
  description = "All subnet IDs in the VPC."
}

output "ssh_key_name" {
  value       = local.effective_key_name
  description = "EC2 key pair name used for SSH."
}

output "ssh_public_key" {
  value       = var.create_key_pair ? (var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh) : null
  description = "Public key material for SSH access."
}

output "ssh_private_key_pem" {
  value       = try(tls_private_key.ssh[0].private_key_pem, null)
  description = "Private key PEM when Terraform generates it."
  sensitive   = true
}

output "ssh_secret_arn" {
  value       = var.create_key_pair && var.create_ssh_secret ? aws_secretsmanager_secret.ssh_key[0].arn : null
  description = "Secrets Manager ARN for the SSH key secret."
}
