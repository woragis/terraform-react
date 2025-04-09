provider "aws" {
  region = var.aws_region
}

# Get the hosted zone for your domain
data "aws_route53_zone" "primary" {
  name         = var.root_domain
  private_zone = false
}

# S3 bucket for static site
resource "aws_s3_bucket" "static_site" {
  bucket = local.s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = local.s3_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket Lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    id     = "auto-archive"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# ACM certificate for subdomain
resource "aws_acm_certificate" "cert" {
  domain_name       = local.full_domain
  validation_method = "DNS"

  tags = {
    Name = local.certificate_name
  }
}

# DNS record for certificate validation
resource "aws_route53_record" "cert_validation" {
  name    = local.cert_validation.resource_record_name
  type    = local.cert_validation.resource_record_type
  zone_id = data.aws_route53_zone.primary.zone_id
  records = [local.cert_validation.resource_record_value]
  ttl     = 60

  allow_overwrite = true
}

# Validates the certificate
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}


# Create the OAI
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${local.s3_bucket_name}"
}

# Grant OAI permission in bucket policy
resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
      }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_site.arn}/*"
    }]
  })
}

resource "time_sleep" "wait_for_certificate" {
  create_duration = "300s"  # Wait 5 minutes for certificate validation
}

# CloudFront distribution for S3
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_id   = "S3-${local.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${local.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern           = "*.(jpg|jpeg|png|gif|ico|css|js)"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${local.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 31536000
    max_ttl                = 31536000

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket          = "your-logging-bucket.s3.amazonaws.com"
    include_cookies = false
    prefix          = "cloudfront/"
  }

  tags = {
    Name = local.cloudfront_name
  }

  depends_on = [aws_acm_certificate_validation.cert, time_sleep.wait_for_certificate]
}