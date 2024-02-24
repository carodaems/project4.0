# CloudWatch Log Groups for ECS Services

# Log Group for Front-End Service
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = "/ecs/frontend-service"  
  retention_in_days = 30
}

# Log Group for .NET API Service
resource "aws_cloudwatch_log_group" "dotnet_api_log_group" {
  name = "/ecs/dotnet-api-service"  
  retention_in_days = 30
}
# Log Group for Monitoring Service
resource "aws_cloudwatch_log_group" "ecs_monitoring_logs" {
  name = "/ecs/monitoring-task"
  retention_in_days = 30
}

# Log Group for Python AI API Service
resource "aws_cloudwatch_log_group" "python_ai_api_log_group" {
  name = "/ecs/python-ai-api-service"  
  retention_in_days = 30
}

# CloudWatch Metric Alarm for High CPU Usage (Front-End Service)
resource "aws_cloudwatch_metric_alarm" "frontend_high_cpu_usage" {
  alarm_name          = "frontend-high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm for high CPU usage in Front-End ECS Service"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.frontend.name
  }

  actions_enabled = true
  alarm_actions = [aws_sns_topic.ecs_alarm_topic.arn]
}
