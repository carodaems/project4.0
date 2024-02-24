# AWS Application FRONT-END Load Balancer (ALB)
resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets # Deploy ALB in public subnets

  enable_deletion_protection = false

  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = false
}

# ALB Target FRONT-END Group
resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}

# ALB Listener for HTTPS
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
  depends_on = [aws_acm_certificate_validation.cert]
}

# AWS Application BACK-END Load Balancer (ALB)
resource "aws_lb" "ecs_alb_backend" {
  name                             = "ecs-alb-backend"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb.id]
  subnets                          = module.vpc.public_subnets
  enable_deletion_protection       = false
  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = false
}

# ALB Target BACK-END Group
resource "aws_lb_target_group" "ecs_target_group_backend" {
  name        = "ecs-target-group-backend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    path                = "/api/predictions"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    matcher             = "401"
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "ecs_http_listener" {
  load_balancer_arn = aws_lb.ecs_alb_backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group_backend.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https_listener_backend" {
  load_balancer_arn = aws_lb.ecs_alb_backend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group_backend.arn
    type             = "forward"
  }
  depends_on = [aws_acm_certificate_validation.cert]
}

# AWS Application GRAFANA Load Balancer (ALB)
resource "aws_lb" "ecs_alb_monitoring" {
  name                             = "ecs-alb-monitoring"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb.id]
  subnets                          = module.vpc.public_subnets
  enable_deletion_protection       = false
  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = false
}

# ALB Target GRAFANA Group
resource "aws_lb_target_group" "ecs_target_group_monitoring" {
  name        = "ecs-target-group-monitoring"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "ecs_http_listener_monitoring" {
  load_balancer_arn = aws_lb.ecs_alb_monitoring.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group_monitoring.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https_listener_monitoring" {
  load_balancer_arn = aws_lb.ecs_alb_monitoring.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.monitoring_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group_monitoring.arn
    type             = "forward"
  }
  depends_on = [aws_acm_certificate_validation.cert]
}

