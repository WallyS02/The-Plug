module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.1.0/24"]
  private_subnets_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  azs                   = ["${var.region}a", "${var.region}b"]
  enable_vpc_flow_logs  = false

  tags = {
    Environment = "dev"
  }
}