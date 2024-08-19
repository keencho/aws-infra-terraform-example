terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = var.app_project_name
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}