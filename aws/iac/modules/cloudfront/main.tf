# Origin Access Identity for S3
resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  count   = var.create_origin_access_identity ? 1 : 0
  comment = "OAI for ${var.distribution_name}"
}

# CloudFront distribution configuration
resource "aws_cloudfront_distribution" "main" {
  enabled             = var.enabled
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases

  # Origin configuration
  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.key
      origin_path = lookup(origin.value, "origin_path", "")

      dynamic "s3_origin_config" {
        for_each = origin.value.type == "s3" ? [1] : []
        content {
          origin_access_identity = var.create_origin_access_identity ? aws_cloudfront_origin_access_identity.s3_oai[0].cloudfront_access_identity_path : ""
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.type == "custom" ? [1] : []
        content {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      }
    }
  }

  # Default cache behaviour (S3 bucket)
  default_cache_behavior {
    target_origin_id       = var.default_cache_behaviour.target_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods          = var.default_cache_behaviour.allowed_methods
    cached_methods           = var.default_cache_behaviour.cached_methods
    compress                 = true
    cache_policy_id          = var.default_cache_behaviour.cache_policy_id
    origin_request_policy_id = var.default_cache_behaviour.origin_request_policy_id
  }

  # Ordered cache behaviour (ALB)
  ordered_cache_behavior {
    path_pattern           = var.ordered_cache_behaviour.path_pattern
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = var.ordered_cache_behaviour.target_origin_id

    allowed_methods = var.ordered_cache_behaviour.allowed_methods
    cached_methods  = var.ordered_cache_behaviour.cached_methods
    compress        = true

    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # Managed-AllViewer
  }

  # Geographical restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geographical_restrictions.restriction_type
      locations        = var.geographical_restrictions.locations
    }
  }

  # SSL configuration
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # S3 logging
  dynamic "logging_config" {
    for_each = var.logging_enabled ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
      prefix          = var.logging_prefix
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [tags["LastModified"]]
  }
}

# S3 bucket policies for OAI
data "aws_iam_policy_document" "s3_policy" {
  count = var.create_origin_access_identity ? 1 : 0

  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["${var.s3_bucket_arn}/*", var.s3_bucket_arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_oai[0].iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  count  = var.create_origin_access_identity ? 1 : 0
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy[count.index].json
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "cloudfront_errors" {
  alarm_name          = "CloudFront-High-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = 300
  statistic           = "Average"
  threshold           = var.high_5xx_errors_threshold
  dimensions = {
    DistributionId = aws_cloudfront_distribution.main.id
    Region         = "Global"
  }
  alarm_actions = [var.alarm_topic_arn]

  tags = var.tags
}