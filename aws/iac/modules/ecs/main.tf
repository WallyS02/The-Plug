# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

# ECS capacity provider
resource "aws_ecs_capacity_provider" "asg" {
  name = "${var.name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.asg_arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_providers" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.asg.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg.name
    weight            = 100
    base              = 1
  }
}

# ECS task definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name              = var.container_name
    image             = "${var.ecr_repository_url}:${var.image_tag}"
    memoryReservation = var.container_memory
    essential         = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    environment = [
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "CACHE_ENDPOINT", value = var.cache_endpoint },
      { name = "USE_CACHE", value = "1" },
      { name = "ALLOWED_HOSTS", value = "*" },
      { name = "DEBUG", value = "1" },
      { name = "DB_NAME", value = var.db_name },
      { name = "DB_USER", value = var.db_user }
    ]
    secrets = [
      { name = "DB_PASSWORD", valueFrom = var.db_password_secret_arn },
      { name = "CACHE_PASSWORD", valueFrom = var.cache_password_secret_arn },
      { name = "EMAIL_HOST_USER", valueFrom = var.email_host_user_secret_arn },
      { name = "EMAIL_HOST_PASSWORD", valueFrom = var.email_host_password_secret_arn },
      { name = "SECRET_KEY", valueFrom = var.secret_key_secret_arn },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group
        "awslogs-region"        = var.log_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-access"
  role = aws_iam_role.ecs_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = [
        var.db_password_secret_arn,
        var.cache_password_secret_arn,
        var.email_host_password_secret_arn,
        var.email_host_user_secret_arn,
        var.secret_key_secret_arn
      ]
    }]
  })
}

# ECS service
resource "aws_ecs_service" "main" {
  name                    = "${var.name}-service"
  cluster                 = aws_ecs_cluster.main.arn
  task_definition         = aws_ecs_task_definition.main.arn
  desired_count           = var.desired_count
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  wait_for_steady_state   = true

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg.name
    weight            = 100
    base              = 1
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ECS task scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.maximum_capacity
  min_capacity       = var.minimum_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_utilization_threshold
    scale_in_cooldown  = var.scaling_cooldown
    scale_out_cooldown = var.scaling_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.memory_utilization_threshold
    scale_in_cooldown  = var.scaling_cooldown
    scale_out_cooldown = var.scaling_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}