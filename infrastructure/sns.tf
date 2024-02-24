resource "aws_sns_topic" "ecs_alarm_topic" {
  name = "ecs-alarm-topic" 
}

resource "aws_sns_topic_subscription" "ecs_alarm_subscription" {
  topic_arn = aws_sns_topic.ecs_alarm_topic.arn
  protocol  = "email"  
  endpoint  = local.email_secret.email 
}


