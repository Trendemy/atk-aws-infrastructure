aws_region = "ap-southeast-1"

# Network (leave empty to read from EC2 state)
vpc_id     = ""
subnet_ids = []

# Remote state for EC2 (change if backend key/bucket differs)
ec2_state_bucket = "atk-terraform-state-bucket"
ec2_state_key    = "atk-aws-infrastructure/ec2/terraform.tfstate"
ec2_state_region = "ap-southeast-1"

cluster_identifier = "atk-postgres"
engine_version     = "16.10"
db_name            = "atk"
master_username    = "postgres"
master_password    = ""

instance_class    = "db.t4g.micro"
allocated_storage = 20
storage_type      = "gp3"
multi_az          = false

publicly_accessible     = false
allowed_cidrs           = []
backup_retention_period = 1
storage_encrypted       = true
skip_final_snapshot     = true
deletion_protection     = false
apply_immediately       = true

create_rds_secret     = true
rds_secret_name       = "atk-postgres-credentials"
rds_secret_kms_key_id = ""

tags = {
  Project = "atk"
  Env     = "prod"
}
