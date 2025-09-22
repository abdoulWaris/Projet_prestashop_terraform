terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_uuid" "random_uuid" {

}
# Create an S3 bucket for remote state storage
resource "aws_s3_bucket" "remote_state_bucket" {
  bucket = "remote-state-bucket-${random_uuid.random_uuid.id}"
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name        = "prestashop Remote State Bucket"
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.remote_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table for state locking
resource "aws_dynamodb_table" "state_lock_table" {
  name         = "taylorshift-state-lock-table-st"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "taylorshift State Lock Table"
  }
}
