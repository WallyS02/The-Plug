# ALB configuration
resource "aws_lb" "main" {
  name               = "${var.environment}-${var.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.logging_bucket
    prefix  = var.logging_prefix
    enabled = var.enable_access_logs
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.name}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "${var.environment}-${var.name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.name}-tg"
  })
}

# HTTP/HTTPS Listener
resource "aws_lb_listener" "http" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_https && var.acm_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}