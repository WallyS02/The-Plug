output "certificate_arn" {
  description = "SSL certificate ARN"
  value       = aws_acm_certificate_validation.cert_validation[0].certificate_arn
}

output "domain_validation_options" {
  description = "Domain validation options"
  value       = aws_acm_certificate.certificate.domain_validation_options
}