module "asg" {
  source = "./modules/asg"

  name_prefix         = "the-plug"
  ami_id              = "ami-0274f4b62b6ae3bd5"
  instance_type       = "t3.micro"
  security_group_ids  = [module.asg_security_group.id]
  vpc_zone_identifier = module.vpc.private_subnet_ids

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  target_group_arns = [module.alb.target_group_arn]
  health_check_type = "ELB"

  enable_monitoring = false

  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = module.kms_asg.key_arn
  }]

  mixed_instances_policy = null

  enable_scaling_policies = true
  scaling_adjustment      = 1

  wait_for_capacity_timeout = "10m"
}

module "asg_security_group" {
  source = "./modules/security-groups"

  name        = "asg-security-group"
  description = "Security group for ASG in private subnet"
  vpc_id      = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      description     = "Allowing communication with ALB on port 80"
      protocol        = "tcp"
      security_groups = [module.alb.security_group_id]
    },
    {
      from_port       = 443
      to_port         = 443
      description     = "Allowing communication with ALB on port 443"
      protocol        = "tcp"
      security_groups = [module.alb.security_group_id]
    }
  ]
}

module "kms_asg" {
  source = "./modules/kms"

  description         = "Key for ASG storage encryption"
  alias_name          = "asg"
  enable_key_rotation = false

  additional_policies = data.aws_iam_policy_document.asg_kms_policy.json
}

data "aws_iam_policy_document" "asg_kms_policy" {
  statement {
    sid = "AllowEC2Use"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [module.asg.ec2_role_arn]
    }
  }
}