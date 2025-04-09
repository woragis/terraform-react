output "full_domain" {
  description = "The full domain used for the site"
  value       = "${var.subdomain}.${var.root_domain}"
}

output "project_name" {
  description = "The normalized project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}
