# Configure the required providers
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "ap-southeast-2"
}