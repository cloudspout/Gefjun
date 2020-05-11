resource "aws_secretsmanager_secret" "grafana_admin-password" {
  name = "Gefjun/${terraform.workspace}/grafana/admin-password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "grafana_admin-password" {
  secret_id     = aws_secretsmanager_secret.grafana_admin-password.id
  secret_string = random_password.grafana_admin-password.result
}

resource "random_password" "grafana_admin-password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "influxdb_admin-password" {
  name = "Gefjun/${terraform.workspace}/influxdb/admin-password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "influxdb_admin-password" {
  secret_id     = aws_secretsmanager_secret.influxdb_admin-password.id
  secret_string = random_password.influxdb_admin-password.result
}

resource "random_password" "influxdb_admin-password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "influxdb_grafana-password" {
  name = "Gefjun/${terraform.workspace}/influxdb/grafana-password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "influxdb_grafana-password" {
  secret_id     = aws_secretsmanager_secret.influxdb_grafana-password.id
  secret_string = random_password.influxdb_grafana-password.result
}

resource "random_password" "influxdb_grafana-password" {
  length           = 12
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "influxdb_lambda-password" {
  name = "Gefjun/${terraform.workspace}/influxdb/lambda-password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "influxdb_lambda-password" {
  secret_id     = aws_secretsmanager_secret.influxdb_lambda-password.id
  secret_string = random_password.influxdb_lambda-password.result
}

resource "random_password" "influxdb_lambda-password" {
  length           = 12
  special          = true
  override_special = "_%@"
}
