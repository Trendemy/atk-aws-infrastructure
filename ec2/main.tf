provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_vpc" "selected" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

locals {
  vpc_id        = var.vpc_id != "" ? data.aws_vpc.selected[0].id : data.aws_vpc.default.id
  service_ports = toset([var.web_client_host_port, var.dashboard_web_host_port, var.dashboard_admin_host_port])
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  subnet_id = var.subnet_id != "" ? var.subnet_id : element(data.aws_subnets.selected.ids, 0)
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "ssh" {
  count     = var.create_key_pair && var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh

  tags = merge({ Name = var.ssh_key_name }, var.tags)
}

locals {
  effective_key_name = var.create_key_pair ? aws_key_pair.ssh[0].key_name : (var.key_name != "" ? var.key_name : null)
}

locals {
  iam_role_name           = var.iam_role_name != "" ? var.iam_role_name : (var.iam_role_arn != "" ? element(reverse(split("/", var.iam_role_arn)), 0) : "")
  create_instance_profile = var.iam_instance_profile == "" && local.iam_role_name != ""
}

resource "aws_iam_instance_profile" "ecr" {
  count = local.create_instance_profile ? 1 : 0
  name  = "atk-ec2-${local.iam_role_name}"
  role  = local.iam_role_name

  tags = merge({ Name = "atk-ec2-${local.iam_role_name}" }, var.tags)
}

locals {
  effective_instance_profile = var.iam_instance_profile != "" ? var.iam_instance_profile : (local.create_instance_profile ? aws_iam_instance_profile.ecr[0].name : null)
}

resource "aws_security_group" "ec2" {
  name        = "atk-ec2-app-sg"
  description = "EC2 security group for web client and dashboard containers."
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = local.service_ports
    content {
      description = "App port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "atk-ec2-app-sg" }, var.tags)
}

resource "aws_instance" "app" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = local.effective_key_name
  iam_instance_profile        = local.effective_instance_profile
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    atk_client_image               = var.atk_client_image
    web_client_host_port           = var.web_client_host_port
    web_client_container_port      = var.web_client_container_port
    atk_dashboard_ui_image         = var.atk_dashboard_ui_image
    dashboard_web_host_port        = var.dashboard_web_host_port
    dashboard_web_container_port   = var.dashboard_web_container_port
    atk_dashboard_server_image     = var.atk_dashboard_server_image
    dashboard_admin_host_port      = var.dashboard_admin_host_port
    dashboard_admin_container_port = var.dashboard_admin_container_port
    docker_network_name            = var.docker_network_name
    docker_registry_login          = var.docker_registry_login
    ecr_registry_url               = var.ecr_registry_url
    ecr_region                     = var.ecr_region != "" ? var.ecr_region : var.aws_region
    user_data_extra                = var.user_data_extra
  })
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
  }

  tags = merge({ Name = "atk-ec2-app" }, var.tags)
}

resource "aws_secretsmanager_secret" "ssh_key" {
  count      = var.create_key_pair && var.create_ssh_secret ? 1 : 0
  name       = var.ssh_secret_name
  kms_key_id = var.ssh_secret_kms_key_id != "" ? var.ssh_secret_kms_key_id : null

  tags = merge({ Name = var.ssh_secret_name }, var.tags)
}

resource "aws_secretsmanager_secret_version" "ssh_key" {
  count     = var.create_key_pair && var.create_ssh_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.ssh_key[0].id
  secret_string = jsonencode({
    key_name        = local.effective_key_name
    public_key      = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
    private_key_pem = try(tls_private_key.ssh[0].private_key_pem, null)
  })
}
