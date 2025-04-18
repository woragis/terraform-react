variable "aws_region" {
  default = "us-east-1"
}

variable "domain_name" {
  description = "Domain for the React app"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for the React build"
  type        = string
}

variable "zone_id" {
  description = "Hosted zone ID for Route 53"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
