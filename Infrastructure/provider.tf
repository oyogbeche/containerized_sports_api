terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.82.2"
    }
  }
  backend "s3" {
    bucket         = "oyogbeche-resume-terraform-state"
    key            = "containerized_sportsApi/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}

provider "aws" {
  profile = "oyogbeche"
  region  = "eu-west-1"
}