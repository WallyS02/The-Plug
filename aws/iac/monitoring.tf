# Log groups
locals {
  log_retention = 1

  tags = {
    Environment = "dev"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${module.ecs.name}"
  retention_in_days = local.log_retention

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "cloudfront" {
  name              = "/aws/cloudfront/${module.cloudfront.distribution_id}"
  retention_in_days = local.log_retention

  tags = local.tags
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
          "rds.amazonaws.com",
          "cloudfront.amazonaws.com"
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
            ["CWAgent", "mem_used_percent", "AutoScalingGroupName", module.asg.asg_name]
          ],
          view   = "timeSeries",
          region = var.region,
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
          view   = "timeSeries",
          region = var.region,
          title  = "ALB Traffic"
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
          view   = "timeSeries",
          region = var.region,
          title  = "Database Health"
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
          view   = "timeSeries",
          region = "us-east-1",
          title  = "CDN Performance"
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
          view   = "singleValue",
          region = var.region,
          title  = "S3 Usage"
        }
      },

      # 6. Alarms
      /*{
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            module.cloudfront.cloudfront_errors_alarm_arn,
            module.rds.low_storage_alarm_arn
          ]
        }
      },*/

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
          view   = "timeSeries",
          region = var.region,
          title  = "ECS Tasks"
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
          view   = "gauge",
          region = var.region,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100
            },
            "right" : {
              "min" : 50
            }
          }
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
          region = var.region,
          view   = "timeSeries",
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
          view   = "pie",
          region = "us-east-1",
          title  = "Cache Efficiency"
        }
      },

      # 5. Alarms
      /*{
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            #module.cloudfront.cloudfront_errors_alarm_arn
          ]
        }
      },*/

      # 6. Query Analysis
      {
        type = "log",
        properties = {
          query  = "SOURCE '/ecs/${module.ecs.name}' | fields @timestamp, @message\n| filter @message like /ERROR/"
          region = var.region,
          title  = "Backend Error Logs",
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
          view   = "timeSeries",
          region = var.region,
          title  = "RDS Performance"
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
          view   = "timeSeries",
          region = var.region,
          title  = "Redis Metrics"
        }
      },

      # 3. Alarms
      /*{
        type = "alarm",
        properties = {
          title = "Active Alarms",
          alarms = [
            module.rds.low_storage_alarm_arn
          ]
        }
      },*/

      # 4. Query Analysis
      {
        type = "log",
        properties = {
          query  = "SOURCE '/aws/rds/instance/${module.rds.identifier}/postgresql' | fields @timestamp, @message\n| filter @message like /ERROR/"
          region = var.region,
          title  = "Database Error Logs",
          view   = "table"
        }
      },
    ]
  })
}