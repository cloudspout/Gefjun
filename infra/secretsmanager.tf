resource "aws_secretsmanager_secret" "grafana_api_key" {
  name = "Gefjun/${terraform.workspace}/GRAFANA_API_KEY"
}

resource "aws_secretsmanager_secret_version" "grafana_api_key" {
  secret_id     = aws_secretsmanager_secret.grafana_api_key.id
  secret_string = var.grafana_api_key
}
