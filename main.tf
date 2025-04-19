provider "aws" {
  region = local.aws_region
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

# 1. S3 Bucket for Static Site
resource "aws_s3_bucket" "react_site" {
  bucket = local.bucket_name

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.react_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "Site" {
  bucket = aws_s3_bucket.react_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.react_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "s3:GetObject",
      Resource = "${aws_s3_bucket.react_site.arn}/*"
    }]
  })
}

# Zone creation
data "aws_route53_zone" "existing" {
  count = local.create_zone ? 0 : 1
  name  = "${local.domain_name}."
}

resource "aws_route53_zone" "new" {
  count = local.create_zone ? 1 : 0
  name  = local.domain_name
}

# 2. ACM Certificate (in us-east-1)
resource "aws_acm_certificate" "cert" {
  provider          = aws.acm
  domain_name       = var.create_zone ? local.domain_name : local.complete_route

  validation_method = "DNS"

  tags = local.tags
}

# 3. Route53 Cert Validation Record
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 300
}

# 4. Certificate Validation
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 5. CloudFront Distribution
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for React App"
}

resource "aws_cloudfront_distribution" "react_cdn" {
  depends_on = [aws_acm_certificate_validation.cert_validation]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "React App CloudFront"
  default_root_object = "index.html"

  aliases = [local.domain_name]

  origin {
    domain_name = aws_s3_bucket.react_site.bucket_regional_domain_name
    origin_id   = "s3-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.tags
}

# 6. Route53 Alias Record
resource "aws_route53_record" "cdn_alias" {
  zone_id = local.zone_id
  name    = local.complete_route
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.react_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.react_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
