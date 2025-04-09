variable "project_name" {
  type        = string
  description = "Project name used for naming resources and tags (e.g., 'react-app')"
}

variable "root_domain" {
  type        = string
  description = "Main domain for the application (e.g., 'example.com')"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.[a-zA-Z]{2,}$", var.root_domain))
    error_message = "The root_domain must be a valid domain name (e.g., example.com)."
  }
}

variable "subdomain" {
  type        = string
  description = "Subdomain for the React app (e.g., 'app' will result in 'app.example.com')"
  default     = "app"
}

variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store the React app static files"
  type        = string
  default     = null  # Will be derived from project_name and environment if not provided
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., 'dev', 'prod', 'staging')"
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod", "staging"], lower(var.environment))
    error_message = "The environment must be one of: 'dev', 'prod', or 'staging'."
  }
}

variable "acm_certificate_tags" {
  type        = map(string)
  description = "Tags for the ACM certificate"
  default     = {
    Environment = "dev"
    Project     = "react-app"
  }
}

variable "cloudfront_distribution_name" {
  type        = string
  description = "Name for the CloudFront distribution"
  default     = null  # Will be derived from project_name and environment
}

variable "logging_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for CloudFront and S3 logs"
  default     = null  # Will be derived from project_name and environment
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID (optional, will be fetched if not provided)"
  default     = null
}

variable "ssl_minimum_protocol_version" {
  type        = string
  description = "Minimum protocol version for SSL in CloudFront"
  default     = "TLSv1.2_2021"
}