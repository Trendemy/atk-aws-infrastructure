terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "atk-terraform-state-bucket"
    key            = "atk-aws-infrastructure/rds/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "atk-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
