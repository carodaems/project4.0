# CREATING ECS CLUSTER
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "cluster"
}

#ECS TASK DEFINITION FRONT-END
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([{
    name  = "barometerapp"
    image = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_app/frontend"

    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.frontend_log_group.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "frontend"
      }
    }
    environment = [
      {
        "name" : "API_URL",
        "value" : "https://api.teameclypse.be"
      },
    ]

    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

# ECS Service

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.ecs_cluster.name
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  depends_on = [aws_ecs_cluster.ecs_cluster]

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "barometerapp"
    container_port   = 80 # Port on which your app is running inside the container
  }
}

