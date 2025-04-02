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

      dynamic "s3_origin_configuration" {
        for_each = origin.value.type == "s3" ? [1] : []
        content {
          origin_access_identity = var.create_origin_access_identity ? aws_cloudfront_origin_access_identity.s3_oai[0].cloudfront_access_identity_path : ""
        }
      }

      dynamic "custom_origin_configuration" {
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

  # Default cache behaviour
  default_cache_behavior {
    target_origin_id       = var.default_cache_behaviour.target_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods          = var.default_cache_behaviour.allowed_methods
    cached_methods           = var.default_cache_behaviour.cached_methods
    compress                 = true
    cache_policy_id          = var.default_cache_behaviour.cache_policy_id
    origin_request_policy_id = var.default_cache_behaviour.origin_request_policy_id

    dynamic "lambda_function_association" {
      for_each = var.lambda_function_associations
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lookup(lambda_function_association.value, "include_body", false)
      }
    }
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
  dynamic "logging_configuration" {
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
resource "aws_s3_bucket_policy" "cloudfront_access" {
  count  = var.create_origin_access_identity ? 1 : 0
  bucket = var.s3_bucket_id
  policy = var.s3_bucket_policy
}