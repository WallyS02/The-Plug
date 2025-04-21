# Launch Template
resource "aws_launch_template" "main" {
  name_prefix            = "${var.name_prefix}-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  user_data              = var.user_data_base64
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        kms_key_id            = null
      }
    }
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { "Name" = "${var.name_prefix}-instance" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role and Profile for instances
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_parameter_access" {
  name = "ssm-parameters-access"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_role_for_ssm" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ec2_container_service_for_ec2_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = var.cw_agent_ssm_parameter_name
  type        = "String"
  value       = file("${path.module}/cw_agent_config.json")
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                  = "${var.name_prefix}-instance"
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  vpc_zone_identifier   = var.vpc_zone_identifier
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  wait_for_capacity_timeout = var.wait_for_capacity_timeout

  dynamic "tag" {
    for_each = merge(var.tags, { "Name" = "${var.name_prefix}-asg" }, { "AmazonECSManaged" = "true" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Scaling Policies
resource "aws_autoscaling_policy" "cpu" {
  count                  = var.enable_scaling_policies ? 1 : 0
  name                   = "cpu-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.main.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_utilization_threshold
  }
}

resource "aws_autoscaling_policy" "memory" {
  count                  = var.enable_scaling_policies ? 1 : 0
  name                   = "memory-scaling"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.main.name

  target_tracking_configuration {
    customized_metric_specification {
      metric_name = "MemoryUtilization"
      namespace   = "AWS/EC2"
      statistic   = "Average"
      metric_dimension {
        name  = "AutoScalingGroupName"
        value = aws_autoscaling_group.main.name
      }
    }
    target_value = var.memory_utilization_threshold
  }
}