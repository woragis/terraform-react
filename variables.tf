variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
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
