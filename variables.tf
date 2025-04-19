variable "aws_region" {
  default = "us-east-1"
}

variable "domain_name" {
  description = "Domain for the React app"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the React app"
  type        = string
  default     = "www"
}

variable "bucket_name" {
  description = "S3 bucket name for the React build"
  type        = string
}

variable "create_zone" {
  description = "Flag to create Route 53 hosted zone"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}