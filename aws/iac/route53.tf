module "route53" {
  source = "./modules/route53"

  domain_name        = "" # TODO get domain name
  create_hosted_zone = true
  records = [
    {
      name = "cdn"
      type = "A"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
    {
      name = "alb"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.hosted_zone_id
      }
    }
  ]
}