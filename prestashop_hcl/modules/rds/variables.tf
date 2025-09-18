variable "environment" {}
variable "instance_type" {}
variable "username" {}
variable "password" {
  sensitive = true
}