resource "aws_ecs_task_definition" "monitoring_task" {
  family                   = "monitoring-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }
      name        = "prometheus-agent"
      image       = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_app/prometheus"  
      cpu         = 512
      memory      = 1024
      essential   = true
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_monitoring_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "prometheus"
        }
      }
    },
    {
      name        = "cloudflare-exporter"
      image       = "ghcr.io/lablabs/cloudflare_exporter"
      cpu         = 256
      memory      = 512
      essential   = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "CF_API_TOKEN", value = local.grafana_secret.api_key }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_monitoring_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "cloudflare-exporter"
        }
      }
    },
    {
    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }
      name  = "grafana-agent"
      image = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_app/grafana"  
      cpu         = 256
      memory      = 512
      essential   = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "ACCESS_KEY", value = local.grafana_secret.username },
        { name = "SECRET_KEY", value = local.grafana_secret.password },
        { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "true" },
        { name = "GF_AUTH_ANONYMOUS_ORG_ROLE", value = "Viewer" },
        { name = "GF_SECURITY_ALLOW_EMBEDDING", value = "true" },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = local.grafana_secret.admin_password },
        { name = "DEFAULT_REGION", value = "us-east-1" }
      ]
      depends_on = [
        {
          containerName = "prometheus"
          condition     = "HEALTHY"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_monitoring_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "grafana-agent"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "monitoring_service" {
  name            = "monitoring-service"
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.monitoring_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_monitoring_sg.id]
    assign_public_ip = false
  }
   load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group_monitoring.arn
    container_name   = "grafana-agent"
    container_port   = 3000 
  }
  depends_on = [
    aws_cloudwatch_log_group.ecs_monitoring_logs
  ]
 
}
