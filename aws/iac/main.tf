module "vpc" {
  source = "./modules/vpc"
}

module "security-groups" {
  source = "./modules/security-groups"
}

module "secrets-manager" {
  source = "./modules/secrets-manager"
}

module "s3" {
  source = "./modules/s3"
}

module "route53" {
  source = "./modules/route53"
}

module "rds" {
  source = "./modules/rds"
}

module "cloudwatch" {
  source = "./modules/monitoring"
}

module "kms" {
  source = "./modules/kms"
}

module "iam" {
  source = "./modules/iam"
}

module "elasticache" {
  source = "./modules/elasticache"
}

module "ecr" {
  source = "./modules/ecr"
}

module "cloudfront" {
  source = "./modules/cloudfront"
}

module "asg" {
  source = "./modules/asg"
}

module "alb" {
  source = "./modules/alb"
}

module "acm" {
  source = "./modules/acm"
}