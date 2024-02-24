# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming traffic from any IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ECS Frontend Security Group
resource "aws_security_group" "frontend" {
  vpc_id      = module.vpc.vpc_id
  name        = "frontend-security-group"
  description = "Security group for frontend container"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ECS Backend Security Group
resource "aws_security_group" "backend" {
  vpc_id      = module.vpc.vpc_id
  name        = "backend security group"
  description = "Security group for API container"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ECS Monitoring Security Group
resource "aws_security_group" "ecs_monitoring_sg" {
  vpc_id      = module.vpc.vpc_id
  name        = "ECS-Monitoring-Security-Group"
  description = "Security Group for ECS Monitoring services"

  # Ingress rule for Cloudflare exporter
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic on 8080 for Cloudflare exporter"
  }

  # Ingress rule for Grafana agent
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic on 12345 for Grafana agent"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic on 9090 for Prometheus agent"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# API AI Security Group
resource "aws_security_group" "api_ai" {
  vpc_id      = module.vpc.vpc_id
  name        = "API AI Security group"
  description = "Security Group for API AI"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_ai" {
  vpc_id      = module.vpc.vpc_id
  name        = "APP AI Security group"
  description = "Security Group for APP AI"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  vpc_id      = module.vpc.vpc_id
  name        = "RDS Security group"
  description = "Security Group for database"

  # Define your security group rules here
  ingress {
    from_port       = 1433 # Assuming SQL Server default port
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id] # Allow traffic from ECS security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
