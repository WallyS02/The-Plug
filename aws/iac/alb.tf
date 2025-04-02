module "alb" {
  source = "./modules/alb"

  name = "core"
  environment = "dev"
  vpc_id = module.vpc.vpc_id
  security_groups = [module.alb_security_group.id]
  subnet_ids = [module.vpc.public_subnet_ids[0]]
  internal = false
  target_port = 8080
  enable_http = true
  enable_https = true
  acm_certificate_arn = module.acm_alb.certificate_arn
  enable_deletion_protection = true
  enable_access_logs = false

  depends_on = [module.vpc, module.acm_alb, module.route53, module.alb_security_group]
}

module "alb_security_group" {
  source = "./modules/security-groups"

  name   = "alb-security-group"
  description = "Security group for core ALB in public subnet"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  depends_on = [module.vpc]
}