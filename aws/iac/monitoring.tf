# Monitoring Agent
module "monitoring_agent" {
  source = "./modules/monitoring"

  create_iam_role = true
  tags = {
    Environment = "dev"
  }
}

# Log groups
locals {
  log_retention = 1
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${module.ecs.name}"
  retention_in_days = local.log_retention

  tags = {
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/${module.rds.identifier}/${module.rds.db_name}"
  retention_in_days = local.log_retention

  tags = {
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "cloudfront" {
  name              = "/aws/cloudfront/${module.cloudfront.distribution_id}"
  retention_in_days = local.log_retention

  tags = {
    Environment = "dev"
  }
}

# Log policies
resource "aws_cloudwatch_log_resource_policy" "global" {
  policy_name = "Global-Log-Policy"
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = [
          "ecs.amazonaws.com",
          "rds.amazonaws.com"
        ]
      },
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:log-group:*"
    }]
  })
}

# CloudFront log storage size exceeded alarm
resource "aws_cloudwatch_metric_alarm" "cloudfront_log_size" {
  alarm_name          = "${aws_cloudwatch_log_group.cloudfront.name}-Size-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"
  metric_name         = "StoredBytes"
  namespace           = "AWS/Logs"
  period              = 86400 # 24h
  statistic           = "Maximum"
  threshold           = 3e9 # 3 GB
  alarm_description   = "Log group approaching 5GB limit"
  alarm_actions       = [module.alarm_topic.arn]
  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudfront.name
  }

  tags = {
    Environment = "dev"
  }
}

# Dashboards
resource "aws_cloudwatch_dashboard" "global" {
  dashboard_name = "Global-Health"
  dashboard_body = jsonencode({
    widgets = [
      # 1. EC2/ASG
      {
        type = "metric",
        x    = 0, y = 0, width = 6, height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", module.asg.asg_name],
            ["CWAgent", "mem_used_percent", { label : "Memory" }]
          ],
          view   = "timeSeries",
          title  = "EC2 Resources",
          period = 300 # 5-min aggregation
        }
      },

      # 2. ALB
      {
        type = "metric",
        x    = 6, y = 0, width = 6, height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", module.alb.arn],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", module.alb.arn],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.alb.arn]
          ],
          view  = "timeSeries",
          title = "ALB Traffic"
        }
      },

      # 3. RDS
      {
        type = "metric",
        x    = 12, y = 0, width = 6, height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.rds.identifier],
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", module.rds.identifier]
          ],
          view  = "timeSeries",
          title = "Database Health"
        }
      },

      # 4. CloudFront
      {
        type = "metric",
        x    = 0, y = 6, width = 6, height = 6,
        properties = {
          metrics = [
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId", module.cloudfront.distribution_id],
            ["AWS/CloudFront", "CacheHitRate", "DistributionId", module.cloudfront.distribution_id]
          ],
          view  = "timeSeries",
          title = "CDN Performance"
        }
      },

      # 5. S3
      {
        type = "metric",
        x    = 6, y = 6, width = 6, height = 6,
        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", module.s3_frontend_bucket.name, "StorageType", "StandardStorage"]
          ],
          view  = "singleValue",
          title = "S3 Usage"
        }
      },

      # 6. Alarms
      {
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            module.cloudfront.cloudfront_errors_alarm_arn,
            module.rds.high_connections_alarm_arn,
            module.rds.low_storage_alarm_arn
          ]
        }
      },

      # 7. Query Analysis
      {
        type = "log",
        properties = {
          query  = "SOURCE '/aws/cloudfront/${module.cloudfront.distribution_id}' | fields @timestamp, @message\n| filter @message like /ERROR/"
          region = var.region,
          title  = "CloudFront Error Logs",
          view   = "table"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_dashboard" "app_performance" {
  dashboard_name = "App-Performance"
  dashboard_body = jsonencode({
    widgets = [
      # 1. ECS Tasks
      {
        type = "metric",
        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ClusterName", module.ecs.cluster_name],
            ["AWS/ECS", "MemoryReservation", "ClusterName", module.ecs.cluster_name]
          ],
          view  = "timeSeries",
          title = "ECS Tasks"
        }
      },

      # 2. Container Metrics
      {
        type = "metric",
        properties = {
          metrics = [
            ["ECS/ContainerInsights", "CpuUtilized", "ClusterName", module.ecs.cluster_name],
            ["ECS/ContainerInsights", "MemoryUtilized", "ClusterName", module.ecs.cluster_name]
          ],
          view  = "gauge",
          title = "Container Resources"
        }
      },

      # 3. ALB Latency
      {
        type = "metric",
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", module.alb.arn]
          ],
          view = "timeSeries",
          annotations = {
            horizontal = [{
              label = "SLA Threshold",
              value = 2.0
            }]
          }
        }
      },

      # 4. CloudFront Cache
      {
        type = "metric",
        properties = {
          metrics = [
            ["AWS/CloudFront", "CacheHitRate", "DistributionId", module.cloudfront.distribution_id]
          ],
          view  = "pie",
          title = "Cache Efficiency"
        }
      },

      # 5. Alarms
      {
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            module.cloudfront.cloudfront_errors_alarm_arn,
            module.ecs.ecs_no_tasks_alarm_arn
          ]
        }
      },

      # 6. Query Analysis
      {
        type = "log",
        properties = {
          query  = "SOURCE '/ecs/${module.ecs.name}' | fields @timestamp, @message\n| filter @message like /ERROR/"
          region = var.region,
          title  = "Database Error Logs",
          view   = "table"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_dashboard" "data_layer" {
  dashboard_name = "Data-Layer"
  dashboard_body = jsonencode({
    widgets = [
      # 1. RDS Performance
      {
        type = "metric",
        properties = {
          metrics = [
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", module.rds.identifier],
            ["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", module.rds.identifier],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", module.rds.identifier]
          ],
          view  = "timeSeries",
          title = "RDS Performance"
        }
      },

      # 2. ElastiCache
      {
        type = "metric",
        properties = {
          metrics = [
            ["AWS/ElastiCache", "CacheHits", "CacheClusterId", module.elasticache.id],
            ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", module.elasticache.id],
            ["AWS/ElastiCache", "Evictions", "CacheClusterId", module.elasticache.id]
          ],
          view  = "timeSeries",
          title = "Redis Metrics"
        }
      },

      # 3. Alarms
      {
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            module.rds.high_connections_alarm_arn,
            module.rds.low_storage_alarm_arn,
            module.elasticache.high_evictions_alarm_arn
          ]
        }
      },

      # 4. Query Analysis
      {
        type = "log",
        properties = {
          query  = "SOURCE '/aws/rds/${module.rds.identifier}/${module.rds.db_name}' | fields @timestamp, @message\n| filter @message like /ERROR/"
          region = var.region,
          title  = "Database Error Logs",
          view   = "table"
        }
      },
    ]
  })
}