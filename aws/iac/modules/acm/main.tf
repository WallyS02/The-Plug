# Certificate creation
resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 DNS validation
resource "aws_route53_record" "validation" {
  for_each = var.validation_method == "DNS" ? {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  name    = var.validation_method == "DNS" ? each.value.name : null
  type    = var.validation_method == "DNS" ? each.value.type : null
  zone_id = var.validation_method == "DNS" ? var.hosted_zone_id : null
  ttl     = var.validation_method == "DNS" ? 60 : null
  records = var.validation_method == "DNS" ? [each.value.record] : []
}

# Certificate approval
resource "aws_acm_certificate_validation" "cert_validation" {
  count = var.validation_method == "DNS" ? 1 : 0

  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}