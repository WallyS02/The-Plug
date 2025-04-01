output "hosted_zone_id" {
  description = "Hosted zone id"
  value       = local.hosted_zone_id
}

output "name_servers" {
  description = "Hosted zone name servers"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}