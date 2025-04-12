module "route53" {
  source = "./modules/route53"

  domain_name        = "theplug.software"
  create_hosted_zone = true
  records = [
    {
      name = "",
      type = "A",
      alias = {
        name                   = module.cloudfront.domain_name
        zone_id                = module.cloudfront.hosted_zone_id
        evaluate_target_health = false
      }
    },
    {
      name = "alb",
      type = "A",
      alias = {
        name                   = module.alb.dns_name
        zone_id                = module.alb.hosted_zone_id
        evaluate_target_health = false
      }
    }
  ]

  tags = {
    Environment = "dev"
  }
}