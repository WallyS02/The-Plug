# Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name          = var.domain_name
  comment       = "Hosted zone for ${var.domain_name}"
  force_destroy = false

  dynamic "vpc" {
    for_each = var.private_zone ? var.vpc_ids : []
    content {
      vpc_id = vpc.value
    }
  }
}

# DNS records (CloudFront and ALB)
resource "aws_route53_record" "records" {
  for_each = { for record in var.records : record.name => record }

  name    = each.value.name != "" ? "${each.value.name}.${var.domain_name}}" : var.domain_name
  type    = each.value.type
  zone_id = local.hosted_zone_id
  ttl     = lookup(each.value, "ttl", null)

  dynamic "alias" {
    for_each = lookup(each.value, "alias", [])
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }

  records = lookup(each.value, "records", null)
}

# DNSSEC
resource "aws_route53_key_signing_key" "main" {
  count = var.enable_dnssec && var.create_hosted_zone ? 1 : 0

  hosted_zone_id             = local.hosted_zone_id
  key_management_service_arn = var.key_management_service_arn
  name                       = "dnssec-key-${var.domain_name}"
}

resource "aws_route53_hosted_zone_dnssec" "main" {
  count = var.enable_dnssec && var.create_hosted_zone ? 1 : 0

  hosted_zone_id = local.hosted_zone_id
  depends_on     = [aws_route53_key_signing_key.main]
}