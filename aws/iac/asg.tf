module "asg" {
  source = "./modules/asg"

  name_prefix         = "the-plug"
  ami_id              = "ami-0274f4b62b6ae3bd5" # Amazon Linux 2023 AMI eu-north-1
  instance_type       = "t3.micro"
  security_group_ids  = [module.asg_security_group.id]
  vpc_zone_identifier = module.vpc.private_subnet_ids

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  # target_group_arns         = [module.alb.target_group_arn]
  health_check_type         = "ELB"
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

  wait_for_capacity_timeout   = "5m"
  cw_agent_ssm_parameter_name = var.cw_agent_ssm_parameter_name

  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    # ECS configuration
    echo ECS_CLUSTER=${module.ecs.cluster_name} >> /etc/ecs/ecs.config
    # echo "ECS_ENABLE_CONTAINER_METRICS=true" >> /etc/ecs/ecs.config
    # SSM Agent
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent && systemctl start amazon-ssm-agent
    # CW Agent
    set -e
    exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1
    yum update -y
    yum upgrade -y
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U ./amazon-cloudwatch-agent.rpm
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c ssm:${var.cw_agent_ssm_parameter_name} -s
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
      from_port       = 8080
      to_port         = 8080
      description     = "ALB access on port 8080"
      protocol        = "tcp"
      security_groups = [module.alb.security_group_id]
    }
  ]

  egress_rules = []

  tags = {
    Environment = "dev"
  }
}

resource "aws_security_group_rule" "asg_database_access" {
  type                     = "egress"
  description              = "Database access"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.rds.security_group_id
  security_group_id        = module.asg_security_group.id
}

resource "aws_security_group_rule" "asg_cache_access" {
  type                     = "egress"
  description              = "Cache access"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.elasticache.security_group_id
  security_group_id        = module.asg_security_group.id
}

resource "aws_security_group_rule" "asg_outbound_HTTPS" {
  type              = "egress"
  description       = "Outbound HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.asg_security_group.id
}