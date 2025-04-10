module "asg" {
  source = "./modules/asg"

  name_prefix         = "the-plug"
  ami_id              = "ami-0274f4b62b6ae3bd5" # Amazon Linux 2023 AMI
  instance_type       = "t3.micro"
  security_group_ids  = [module.asg_security_group.id]
  vpc_zone_identifier = module.vpc.private_subnet_ids

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  target_group_arns = [module.alb.target_group_arn]
  health_check_type = "ELB"
  health_check_grace_period = 300

  enable_monitoring = false

  block_device_mappings = [{
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }]

  enable_scaling_policies = true
  scaling_adjustment      = 1

  wait_for_capacity_timeout = "5m"

  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${module.ecs.cluster_name} >> /etc/ecs/ecs.config
    EOF
  )

  tags = {
    Environment = "dev"
  }
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

  tags = {
    Environment = "dev"
  }
}