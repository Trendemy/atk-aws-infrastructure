provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = var.ec2_state_bucket
    key    = var.ec2_state_key
    region = var.ec2_state_region != "" ? var.ec2_state_region : var.aws_region
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_vpc" "selected" {
  count = var.vpc_id != "" ? 1 : 0
  id    = var.vpc_id
}

locals {
  vpc_id_from_state     = try(data.terraform_remote_state.ec2.outputs.vpc_id, null)
  subnet_ids_from_state = try(data.terraform_remote_state.ec2.outputs.vpc_subnet_ids, [])
  ec2_sg_from_state     = try(data.terraform_remote_state.ec2.outputs.ec2_security_group_id, "")
}

locals {
  vpc_id    = var.vpc_id != "" ? var.vpc_id : (local.vpc_id_from_state != null ? local.vpc_id_from_state : data.aws_vpc.default.id)
  ec2_sg_id = var.ec2_security_group_id != "" ? var.ec2_security_group_id : local.ec2_sg_from_state
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : (length(local.subnet_ids_from_state) > 0 ? local.subnet_ids_from_state : data.aws_subnets.selected.ids)
}

resource "random_password" "master" {
  count            = var.master_password == "" ? 1 : 0
  length           = 32
  special          = true
  min_special      = 1
  override_special = "_%@+"
}

locals {
  master_password = var.master_password != "" ? var.master_password : random_password.master[0].result
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.cluster_identifier}-subnets"
  subnet_ids = local.subnet_ids

  tags = merge({ Name = "${var.cluster_identifier}-subnets" }, var.tags)
}

resource "aws_security_group" "rds" {
  name        = "${var.cluster_identifier}-sg"
  description = "RDS Postgres access."
  vpc_id      = local.vpc_id

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "${var.cluster_identifier}-sg" }, var.tags)
}

resource "aws_security_group_rule" "postgres_from_ec2" {
  count                    = local.ec2_sg_id != "" ? 1 : 0
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Postgres access from EC2."
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = local.ec2_sg_id
}

resource "aws_security_group_rule" "postgres_from_cidrs" {
  for_each          = toset(var.allowed_cidrs)
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  description       = "Postgres access from CIDR."
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [each.value]
}

resource "aws_db_instance" "postgres" {
  identifier              = var.cluster_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_name                 = var.db_name
  username                = var.master_username
  password                = local.master_password
  publicly_accessible     = var.publicly_accessible
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  apply_immediately       = var.apply_immediately

  tags = merge({ Name = var.cluster_identifier }, var.tags)
}

resource "aws_secretsmanager_secret" "rds" {
  count      = var.create_rds_secret ? 1 : 0
  name       = var.rds_secret_name
  kms_key_id = var.rds_secret_kms_key_id != "" ? var.rds_secret_kms_key_id : null

  tags = merge({ Name = var.rds_secret_name }, var.tags)
}

resource "aws_secretsmanager_secret_version" "rds" {
  count     = var.create_rds_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = local.master_password
    engine   = var.engine
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = var.db_name
    instance = var.cluster_identifier
  })
}
