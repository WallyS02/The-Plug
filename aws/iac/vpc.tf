module "vpc" {
  source = "./modules/vpc"

  environment = "dev"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_cidrs = ["10.0.1.0/24"]
  private_subnets_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  azs = ["eu-north-1a", "eu-north-1b"]
  enable_nat_gateway = false
  enable_s3_endpoint = true
  region = "eu-north-1"
}