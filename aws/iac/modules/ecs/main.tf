# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
  tags = var.tags
}

# ECS task definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 768 # 0.75 vCPU
  memory                   = 768 # 768 MB

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = "${var.ecr_repository_url}:${var.image_tag}"
    cpu       = 256 # 0.25 vCPU
    memory    = 256 # 256 MB
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.host_port
    }]
    environment = [
      { name = "DB_HOST", value = var.db_endpoint },
      { name = "CACHE_ENDPOINT", value = var.cache_endpoint }, # TODO make backend use cache
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
  }])
}

# ECS service
resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
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
}