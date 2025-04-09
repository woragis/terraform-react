locals {
  # Domain and Naming
  full_domain           = "${var.subdomain}.${var.root_domain}"
  normalized_project    = var.project_name != null ? lower(var.project_name) : "app"  # Fallback to "app" if null
  environment           = lower(var.environment)

  # S3 Bucket Names
  s3_bucket_name        = var.s3_bucket_name != null ? var.s3_bucket_name : "${local.normalized_project}-${local.environment}-static"
  logging_bucket_name   = var.logging_bucket_name != null ? var.logging_bucket_name : "${local.normalized_project}-${local.environment}-logs"

  # CloudFront and Certificate Names
  cloudfront_name       = var.cloudfront_distribution_name != null ? var.cloudfront_distribution_name : "${local.normalized_project}-${local.environment}-cdn"
  certificate_name      = "${local.normalized_project}-${local.environment}-cert"
  cert_validation       = tolist(aws_acm_certificate.cert.domain_validation_options)[0]

  # Tags
  common_tags           = {
    Project     = var.project_name != null ? var.project_name : "App"  # Fallback to "App" if null
    Environment = local.environment
    ManagedBy   = "Terraform"
    Purpose     = "ReactFrontend"
  }

  # CloudFront Settings
  ssl_minimum_protocol_version = var.ssl_minimum_protocol_version
  cloudfront_origin_id         = "${local.normalized_project}-s3-origin"
}