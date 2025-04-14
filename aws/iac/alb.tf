module "alb" {
  source = "./modules/alb"

  name                       = "core"
  vpc_id                     = module.vpc.vpc_id
  security_groups            = [module.alb_security_group.id]
  subnet_ids                 = module.vpc.public_subnet_ids
  internal                   = false
  target_port                = 8080
  enable_http                = true
  enable_https               = true
  acm_certificate_arn        = module.acm_alb.certificate_arn
  enable_deletion_protection = true
  enable_access_logs         = false
  health_check_path          = "/api/herb/list/"

  tags = {
    Environment = "dev"
  }

  depends_on = [module.acm_alb]
}

module "alb_security_group" {
  source = "./modules/security-groups"

  name        = "alb-security-group"
  description = "Security group for core ALB in public subnet"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port        = 80
      to_port          = 80
      description      = "HTTP from Internet"
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    {
      from_port        = 443
      to_port          = 443
      description      = "HTTPS from Internet"
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  egress_rules = []

  tags = {
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "alb_asg_access" {
  type                     = "egress"
  description              = "Outbound to ECS ASG infrastructure"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.asg.security_group_id
  security_group_id        = module.alb_security_group.id
}

resource "aws_security_group_rule" "alb_ecs_access" {
  type                     = "egress"
  description              = "Outbound to ECS"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.ecs_security_group.id
  security_group_id        = module.alb_security_group.id
}