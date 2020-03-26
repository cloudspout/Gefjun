data "template_file" "grafana" {
  template = file("task-definitions/grafana.tpl")

  vars = {
    cpu    = var.grafana_cpu
    memory = var.grafana_memory

    admin_username = "gefjun"
    admin_password-arn = aws_secretsmanager_secret.grafana_admin-password.arn

    region = var.aws_region
    log_group = aws_cloudwatch_log_group.grafana.name
  }
}

resource "aws_ecs_task_definition" "grafana" {
  family                = "Gefjun-${terraform.workspace}-grafana"
  container_definitions = data.template_file.grafana.rendered

  task_role_arn      = aws_iam_role.grafana.arn
  execution_role_arn = aws_iam_role.grafana_execution.arn

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory

  volume {
    name = "grafana-storage"
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.gefjun.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.grafana_access.id]

    subnets = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  tags = local.common_tags
  propagate_tags = "TASK_DEFINITION"

  depends_on = [aws_alb_target_group.grafana, aws_ecs_service.influxdb]
}

