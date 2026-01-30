aws_region = "ap-southeast-1"

# Network / compute
vpc_id    = ""
subnet_id = ""

instance_type       = "m7i-flex.large"
root_volume_size_gb = 30

# SSH access
ssh_allowed_cidrs = ["42.114.57.245/32"]
create_key_pair   = true
ssh_key_name      = "atk-ec2-key"
ssh_public_key    = ""
key_name          = ""

# IAM for ECR pull permissions (create instance profile from role)
iam_instance_profile = ""
iam_role_arn         = "arn:aws:iam::065571034444:role/sbs-ecr-role"
iam_role_name        = ""

# Container images (ECR)
ecr_registry_url = "065571034444.dkr.ecr.ap-southeast-1.amazonaws.com"
ecr_region       = "ap-southeast-1"

atk_client_image           = "065571034444.dkr.ecr.ap-southeast-1.amazonaws.com/prod-atk-client"
atk_dashboard_server_image = "065571034444.dkr.ecr.ap-southeast-1.amazonaws.com/prod-atk-dashboard-server"
atk_dashboard_ui_image     = "065571034444.dkr.ecr.ap-southeast-1.amazonaws.com/prod-atk-dashboard-ui"

# App ports (host -> container)
web_client_host_port           = 8080
web_client_container_port      = 8080
dashboard_web_host_port        = 4173
dashboard_web_container_port   = 4173
dashboard_admin_host_port      = 3000
dashboard_admin_container_port = 3000

allowed_cidrs = ["0.0.0.0/0"]

create_ssh_secret     = true
ssh_secret_name       = "atk-ec2-ssh-key"
ssh_secret_kms_key_id = ""

tags = {
  Project = "atk"
  Env     = "prod"
}
