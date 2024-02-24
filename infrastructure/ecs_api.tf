data "external" "private_ip_ai" {
  program    = ["sh", "./get_private_ip.sh", aws_ecs_cluster.ecs_cluster.name, aws_ecs_service.python_ai_api_service.name]
  depends_on = [aws_ecs_service.python_ai_api_service]
}

# ECS Task Definition for .NET API
resource "aws_ecs_task_definition" "dotnet_api" {
  family                   = "dotnet-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name  = "dotnetapi"
    image = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_app/api"
    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.dotnet_api_log_group.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "dotnet-api"
      }
    }
    # Define environment variables
    environment = [
      {
        "name" : "ASPNETCORE_ENVIRONMENT",
        "value" : "Production"
      },
      {
        name  = "ASPNETCORE_HTTP_PORT",
        value = "https://+:443"
      },
      {
        name  = "ASPNETCORE_URLS",
        value = "http://+:80"
      },
      {
        name  = "YOUR_CONNECTION_STRING_VARIABLE",
        value = "Server=${aws_db_instance.app_db.address};Database=BarometerDB;User Id=${local.db_secret.username};Password=${local.db_secret.password};Encrypt=True;TrustServerCertificate=True;"
      },
      {
        name  = "AI_URL_VARIABLE"
        value = data.external.private_ip_ai.result["private_ip"]
      }
    ]
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      }
    ]
  }])
}

# ECS Service for .NET API
resource "aws_ecs_service" "dotnet_api" {
  name            = "dotnet-api-service"
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.dotnet_api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group_backend.arn
    container_name   = "dotnetapi"
    container_port   = 80 # Port on which your app is running inside the container
  }
}


