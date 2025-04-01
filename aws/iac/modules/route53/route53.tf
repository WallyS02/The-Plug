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
  ttl     = lookup(each.value, "ttl", 300)

  records = each.value.records
  dynamic "alias" {
    for_each = lookup(each.value, "alias", [])
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }
}

# ACM validation records
resource "aws_route53_record" "acm_validation" {
  for_each = var.acm_validation_records

  name    = each.value.name
  type    = each.value.type
  zone_id = local.hosted_zone_id
  ttl     = 60
  records = each.value.records
}

# DNSSEC
resource "aws_route53_key_signing_key" "main" {
  hosted_zone_id             = local.hosted_zone_id
  key_management_service_arn = aws_kms_key.dnssec.arn
  name                       = "dnssec-key"
}

resource "aws_route53_hosted_zone_dnssec" "main" {
  hosted_zone_id = local.hosted_zone_id
}