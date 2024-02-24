# ECS Task Definition for Python AI API
resource "aws_ecs_task_definition" "python_ai_api" {
  family                   = "python_ai_api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name  = "pythonaiapi"
    image = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_app/aiapi:latest"
    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.python_ai_api_log_group.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "python-ai-api"
      }
    }
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      }
    ]
  }])
}

# ECS Service for Python AI API
resource "aws_ecs_service" "python_ai_api_service" {
  name            = "python-ai-api-service"
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.python_ai_api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.api_ai.id]
    assign_public_ip = true
  }
}