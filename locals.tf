locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  s3_bucket_name       = "${var.project_name}-${var.environment}-s3"
}
