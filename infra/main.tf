provider "aws" {
  # No secrets here - Use env. variables or the ~/.aws/credentials
  # https://www.terraform.io/docs/providers/aws/index.html
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "cloudspout-terraform-infra-state"
    key            = "gefjun/app/tfstate/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project = "Gefjun"
    Env     = terraform.workspace
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}