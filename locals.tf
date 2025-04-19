locals {
  project_name = var.project_name
  project_type = var.project_type
  aws_region   = var.aws_region
  domain_name  = var.domain_name
  subdomain    = var.subdomain
  create_zone  = var.create_zone
  bucket_name  = var.bucket_name
  tags         = var.tags

  zone_id        = var.create_zone ? aws_route53_zone.new[0].zone_id : data.aws_route53_zone.existing[0].zone_id
  complete_route = "${var.subdomain}.${var.domain_name}"
}
