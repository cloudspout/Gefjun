module "fargate-influxdb-efs" {
  source  = "cloudspout/fargate-influxdb-efs/aws"
  version = "0.0.2"

  name   = "gefjun"
  tags   = local.common_tags

  aws_service_discovery_private_dns_namespace = aws_service_discovery_private_dns_namespace.gefjun


  aws_ecs_cluster = aws_ecs_cluster.gefjun
  cpu    = var.influxdb_cpu
  memory = var.influxdb_memory

  execution_role = aws_iam_role.influxdb_execution
  task_role      = aws_iam_role.influxdb

  admin_user                                 = "influxdb"
  aws_secretsmanager_secret-admin_password   = aws_secretsmanager_secret.influxdb_admin-password
  rw_user                                    = "grafana"
  aws_secretsmanager_secret-rw_user_password = aws_secretsmanager_secret.influxdb_grafana-password
  ro_user                                    = "lambda"
  aws_secretsmanager_secret-ro_user_password = aws_secretsmanager_secret.influxdb_lambda-password

  aws_vpc            = aws_vpc._
  aws_subnets        = aws_subnet.public.*
  aws_security_group = aws_security_group.influxdb_access
}
