terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {}
}

provider "aws" {}


# Create bucket

resource "aws_s3_bucket" "testbucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "testbucket_acl" {
  bucket = aws_s3_bucket.testbucket.id
  acl    = "private"
}