module "cloudfront" {
  source = "./modules/cloudfront"

  distribution_name = "the-plug-cdn"
  enabled = true
  aliases = [] # TODO get domain name

  origins = {
    s3_origin = {
      domain_name = module.s3_frontend_bucket.regional_domain_name
      type = "s3"
    }
    alb_origin = {
      domain_name = module.alb.dns_name
      type = "custom"
    }
  }

  default_cache_behaviour = {
    target_origin_id         = "s3_origin"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-UserAgentRefererHeaders
  }

  ordered_cache_behaviour = {
    path_pattern     = "/api*"
    target_origin_id = "alb_origin"
    allowed_methods  = ["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
  }

  acm_certificate_arn = module.acm_cloudfront.certificate_arn
  create_origin_access_identity = true
  s3_bucket_arn = module.s3_frontend_bucket.arn
  s3_bucket_id = module.s3_frontend_bucket.id
  logging_enabled = false

  geographical_restrictions = {
    restriction_type = "whitelist"
    locations        = ["PL"]
  }

  price_class = "PriceClass_100"
  comment = "CloudFront distribution for The Plug application"
  default_root_object = "index.html"

  depends_on = [module.acm_cloudfront]
}

resource "null_resource" "invalidation" {
  triggers = { # Run with every terraform apply
    version = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      aws cloudfront create-invalidation \
        --distribution-id ${module.cloudfront.distribution_id} \
        --paths "/*"
    EOT
  }
}