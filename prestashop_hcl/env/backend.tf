# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "prestashop-terraform-remote-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-3"
    profile        = "terraform-user"
    dynamodb_table = "terraform-state-lock"
  }
}
