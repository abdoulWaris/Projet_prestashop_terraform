# Environment Variables
variable "region" {
    description = "region to create resources"
    type        = string
    default = "eu-west-3"
}

variable "project_name" {
    description = "project name"
    type        = string
    default = "TaylorShift-Project"
}

variable "environment" {
    description = "environment"
    type        = string
}
