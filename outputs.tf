output "full_domain" {
  description = "The full domain used for the site (e.g., app.example.com)"
  value       = local.full_domain
}

output "project_name" {
  description = "The project name used for naming resources and tags (or null if not provided)"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "The deployment environment (e.g., dev, prod, staging)"
  value       = local.environment
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket hosting the React app static files"
  value       = aws_s3_bucket.static_site.bucket
}

output "logging_bucket_name" {
  description = "The name of the S3 bucket for CloudFront and S3 logs"
  value       = aws_s3_bucket.logging_bucket.bucket
}

output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain name (e.g., d123...cloudfront.net)"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "The CloudFront distribution ID for cache invalidation"
  value       = aws_cloudfront_distribution.cdn.id
}

output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert.arn
}