module "acm_cloudfront" {
  source = "./modules/acm"

  providers = {
    aws = aws.cloudfront
  }

  domain_name               = module.route53.domain_name
  subject_alternative_names = []
  validation_method         = "DNS"
  hosted_zone_id            = module.route53.hosted_zone_id

  tags = {
    Environment = "dev"
  }
}

module "acm_alb" {
  source = "./modules/acm"

  domain_name               = "alb.${module.route53.domain_name}"
  subject_alternative_names = []
  validation_method         = "DNS"
  hosted_zone_id            = module.route53.hosted_zone_id

  tags = {
    Environment = "dev"
  }
}