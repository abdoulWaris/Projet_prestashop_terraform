variable "aws_region" {
 description = "the region of aws provider "
    type        = string
    default     = "eu-west-3" // Paris
}

# variable "db_username" {
#   default = "admin"
# }

variable "db_password" {
  description = "The password for the RDS database"
  sensitive   = true
}

variable "instance_type" {
  default = "t3.micro" // or t2.micro( à voir avec Yoann)
}