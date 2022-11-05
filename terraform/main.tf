terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

# Make a bucket
resource "aws_s3_bucket" "acme-storage" {
  bucket = "acme-storage-robertoasir"

  tags = {
    Name        = "My CICD bucket"
    Environment = "Test"
  }
}


# Expected output: 
# arn = "arn:aws:s3:::acme-storage-robertoasir"
output "arn" {
  value = aws_s3_bucket.acme-storage.arn
}

