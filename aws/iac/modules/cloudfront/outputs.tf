output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "domain_name" {
  description = "CloudFront domain"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "oai_iam_arn" {
  description = "ARN OAI"
  value       = try(aws_cloudfront_origin_access_identity.s3_oai[0].iam_arn, "")
}

output "cloudfront_errors_alarm_arn" {
  description = "CloudFront Errors Alarm ARN"
  value       = aws_cloudwatch_metric_alarm.cloudfront_errors.arn
}