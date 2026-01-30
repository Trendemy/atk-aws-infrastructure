variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into."
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to use. Leave empty to use the default VPC."
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the instance. Leave empty to use the first subnet in the VPC."
  default     = ""
}

variable "ami_id" {
  type        = string
  description = "AMI ID override. Leave empty to use the latest Ubuntu 22.04 LTS AMI."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "m7i-flex.large"
}

variable "root_volume_size_gb" {
  type        = number
  description = "Root EBS volume size in GiB."
  default     = 30
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name for SSH access when create_key_pair is false."
  default     = ""

  validation {
    condition     = var.create_key_pair || var.key_name != ""
    error_message = "key_name must be set when create_key_pair is false."
  }
}

variable "create_key_pair" {
  type        = bool
  description = "Create and manage an EC2 key pair."
  default     = true
}

variable "ssh_key_name" {
  type        = string
  description = "Name for the managed EC2 key pair."
  default     = "atk-ec2-key"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key material to register when create_key_pair is true. Leave empty to generate one."
  default     = ""
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name or ARN for the EC2 instance."
  default     = ""
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN to create/attach via a new instance profile when iam_instance_profile is empty."
  default     = ""
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name to create/attach via a new instance profile when iam_instance_profile is empty."
  default     = ""
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access app ports."
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to SSH (port 22). Leave empty to disable SSH ingress."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}

variable "atk_client_image" {
  type        = string
  description = "Docker image for the ATK client web."
}

variable "atk_dashboard_ui_image" {
  type        = string
  description = "Docker image for the ATK dashboard UI."
}

variable "atk_dashboard_server_image" {
  type        = string
  description = "Docker image for the ATK dashboard server (API)."
}

variable "web_client_host_port" {
  type        = number
  description = "Host port for the web client container."
  default     = 8080
}

variable "web_client_container_port" {
  type        = number
  description = "Container port for the web client image."
  default     = 8080
}

variable "dashboard_web_host_port" {
  type        = number
  description = "Host port for the dashboard web container."
  default     = 4173
}

variable "dashboard_web_container_port" {
  type        = number
  description = "Container port for the dashboard web image."
  default     = 4173
}

variable "dashboard_admin_host_port" {
  type        = number
  description = "Host port for the dashboard admin container."
  default     = 3000
}

variable "dashboard_admin_container_port" {
  type        = number
  description = "Container port for the dashboard admin image."
  default     = 3000
}

variable "docker_network_name" {
  type        = string
  description = "Docker network name to attach containers to."
  default     = "atk-apps"
}

variable "docker_registry_login" {
  type        = string
  description = "Optional command to authenticate to a Docker registry."
  default     = ""
}

variable "ecr_registry_url" {
  type        = string
  description = "ECR registry URL (e.g. 123456789012.dkr.ecr.ap-southeast-1.amazonaws.com)."
  default     = ""
}

variable "ecr_region" {
  type        = string
  description = "ECR region. Leave empty to use aws_region."
  default     = ""
}

variable "create_ssh_secret" {
  type        = bool
  description = "Store SSH key material in AWS Secrets Manager when available."
  default     = true
}

variable "ssh_secret_name" {
  type        = string
  description = "Secrets Manager name for the SSH key secret."
  default     = "atk-ec2-ssh-key"
}

variable "ssh_secret_kms_key_id" {
  type        = string
  description = "Optional KMS key ID/ARN for encrypting the SSH key secret."
  default     = ""
}

variable "user_data_extra" {
  type        = string
  description = "Optional extra commands appended to user_data."
  default     = ""
}
