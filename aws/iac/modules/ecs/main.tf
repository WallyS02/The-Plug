# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_providers" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.asg.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg.name
  }
}

# ECS capacity provider
resource "aws_ecs_capacity_provider" "asg" {
  name = "${var.name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn

    managed_scaling {
      status = "DISABLED"
    }
  }
}

# ECS task definition
resource "aws_ecs_task_definition" "main" {
  family             = "${var.name}-task"
  network_mode       = "awsvpc"
  cpu                = var.task_cpu
  memory             = var.task_memory
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = "${var.ecr_repository_url}:${var.image_tag}"
    cpu       = var.container_cpu
    memory    = var.container_memory
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.host_port
    }]
    environment = [
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "CACHE_ENDPOINT", value = "redis://${var.cache_auth_token}@${element(split("://", var.cache_endpoint), 1)}" },
      { name = "USE_CACHE", value = 1 },
      { name = "WEB_APP_URL", value = "http://localhost" },
      { name = "ALLOWED_HOSTS", value = "*" },
      { name = "DEBUG", value = 1 },
      { name = "DB_NAME", value = var.db_name },
      { name = "DB_USER", value = var.db_user }
    ]
    secrets = [
      { name = "DB_PASSWORD", valueFrom = var.db_password_secret_arn },
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

# ECS service
resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg.name
  }

  network_configuration {
    subnets          = var.task_subnets
    security_groups  = var.task_security_groups
    assign_public_ip = false
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
  max_capacity       = 3
  min_capacity       = 1
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
    target_value = var.cpu_utilization_threshold

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
    target_value = var.memory_utilization_threshold

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "ecs_no_tasks" {
  alarm_name          = "ECS-No-Running-Tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
  alarm_actions = [var.alarm_topic_arn]

  tags = {
    Environment = "dev"
  }
}