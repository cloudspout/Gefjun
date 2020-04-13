data "template_file" "influxdb" {
  template = file("task-definitions/influxdb.tpl")

  vars = {
    cpu    = var.influxdb_cpu
    memory = var.influxdb_memory

    db_name        = "gefjun"
    admin_username = "influxdb"
    admin_password-arn = aws_secretsmanager_secret.influxdb_admin-password.arn

    grafana_username = "grafana"
    grafana_password-arn = aws_secretsmanager_secret.influxdb_grafana-password.arn

    lambda_username = "lambda"
    lambda_password-arn = aws_secretsmanager_secret.influxdb_lambda-password.arn

    region = var.aws_region
    log_group = aws_cloudwatch_log_group.influxdb.name
  }
}

resource "aws_ecs_task_definition" "influxdb" {
  family                = "Gefjun-${terraform.workspace}-influxdb"
  container_definitions = data.template_file.influxdb.rendered

  task_role_arn      = aws_iam_role.influxdb.arn
  execution_role_arn = aws_iam_role.influxdb_execution.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.influxdb_cpu
  memory                   = var.influxdb_memory

  volume {
    name = "influxdb-storage"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.influxdb.id
    }
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "influxdb" {
  name            = "influxdb"
  cluster         = aws_ecs_cluster.gefjun.id
  task_definition = aws_ecs_task_definition.influxdb.arn
  desired_count   = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0" #This should be latest but that defaults to 1.3 right now

  network_configuration {
    security_groups = [aws_security_group.influxdb_access.id]

    #subnets = aws_subnet.private.*.id
    assign_public_ip = true
    subnets = aws_subnet.public.*.id
  }

  service_registries {
    registry_arn = aws_service_discovery_service.influxdb.arn
  }

  tags = local.common_tags
  propagate_tags = "TASK_DEFINITION"
}

resource "aws_efs_file_system" "influxdb" {
  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-influxdb"
  })
}

resource "aws_efs_mount_target" "influxdb" {
  count = length(aws_subnet.public)

  file_system_id = aws_efs_file_system.influxdb.id
  subnet_id      = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs_influxdb_access.id]
}
