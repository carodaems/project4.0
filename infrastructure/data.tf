# Data source to retrieve the secret
data "aws_secretsmanager_secret" "gitlab_registry_credentials" {
  name = "GitlabPull" # Use the name you chose for the secret
}

# Data source to retrieve the secret version
data "aws_secretsmanager_secret_version" "gitlab_registry_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.gitlab_registry_credentials.id
}

#IAM LabRole
data "aws_iam_role" "lab_role" {
  name = "LabRole" # Replace with the actual name of your IAM role
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "CredsDB"
}

data "aws_secretsmanager_secret_version" "email_credentials" {
  secret_id = "emailSecret"
}

data "aws_secretsmanager_secret_version" "cloudflare_credentials" {
  secret_id = "cloudflareCreds"
}
data "aws_secretsmanager_secret_version" "grafana_credentials" {
  secret_id = "grafanaCreds"
}

locals {
  db_secret = jsondecode(
    data.aws_secretsmanager_secret_version.db_credentials.secret_string
  )
  cloudflare_secret = jsondecode(
  data.aws_secretsmanager_secret_version.cloudflare_credentials.secret_string
  )
  grafana_secret = jsondecode(
  data.aws_secretsmanager_secret_version.grafana_credentials.secret_string
  )
  email_secret = jsondecode(
  data.aws_secretsmanager_secret_version.email_credentials.secret_string
  )
  log_group_names = [
    aws_cloudwatch_log_group.frontend_log_group.name,
    aws_cloudwatch_log_group.dotnet_api_log_group.name,
    aws_cloudwatch_log_group.ecs_monitoring_logs.name,
    aws_cloudwatch_log_group.python_ai_api_log_group.name,
  ]
}



