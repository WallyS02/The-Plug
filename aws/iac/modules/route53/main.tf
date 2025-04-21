# Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0

  name          = var.domain_name
  comment       = "Hosted zone for ${var.domain_name}"
  force_destroy = false
  tags          = var.tags
}

# DNS records (CloudFront and ALB)
resource "aws_route53_record" "records" {
  for_each = { for record in var.records : record.name != "" ? "${record.name}-${record.type}" : record.type => record }

  name    = each.value.name != "" ? "${each.value.name}.${var.domain_name}" : var.domain_name
  type    = each.value.type
  zone_id = local.hosted_zone_id
  ttl     = lookup(each.value, "ttl", null)

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  records = lookup(each.value, "records", null)
}