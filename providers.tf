terraform {
  required_version = "~> 1.5.0" #Lazy way
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.36.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

###export TF_VAR_aws_access_key="YOUR_AWS_ACCESS_KEY"
###export TF_VAR_aws_secret_key="YOUR_AWS_SECRET_KEY"
