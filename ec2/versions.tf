terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "atk-terraform-state-bucket"
    key            = "atk-aws-infrastructure/ec2/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "atk-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
