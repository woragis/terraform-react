locals {
  full_domain      = "${var.subdomain}.${var.root_domain}"

  normalized_project  = lower(var.project_name)

  s3_bucket_name   = "${local.normalized_project}-s3"
  cloudfront_name  = "${var.project_name}-cdn"
  certificate_name = "${var.project_name}-cert"
  cert_validation  = tolist(aws_acm_certificate.cert.domain_validation_options)[0]
}
