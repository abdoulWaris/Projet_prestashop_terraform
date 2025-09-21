# configure aws provider to establish a secure connection between terraform and aws
provider "aws" {
  region  = "eu-west-3" // Paris
  profile = "terraform-user"

  default_tags {
    tags = {
      "Automation"  = "terraform"
      "Project"     = var.project_name
      "Environment" = var.environment
    }
  }
}