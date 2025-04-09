variable "project_name" {
  type        = string
  description = "Project name used for tags and naming"
}

variable "subdomain" {
    type = string
  description = "The project name (subdomain)"
}

variable "root_domain" {
    type = string
    description = "Main domain (ex.: lizardti.com)"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type = string
  default = "us-east-1"
}