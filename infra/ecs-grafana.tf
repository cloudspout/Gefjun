data "template_file" "grafana" {
  template = file("task-definitions/grafana.tpl")

  vars = {
    cpu    = var.grafana_cpu
    memory = var.grafana_memory

    admin_username     = "gefjun"
    admin_password-arn = aws_secretsmanager_secret.grafana_admin-password.arn

    region    = var.aws_region
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

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.grafana.id
    }
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "grafana" {
  name             = "grafana"
  cluster          = aws_ecs_cluster.gefjun.id
  task_definition  = aws_ecs_task_definition.grafana.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0" #This should be latest but that defaults to 1.3 right now

  network_configuration {
    security_groups = [aws_security_group.grafana_access.id]

    #subnets = aws_subnet.private.*.id
    assign_public_ip = true
    subnets          = aws_subnet.public.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  tags           = local.common_tags
  propagate_tags = "TASK_DEFINITION"

  depends_on = [aws_alb_target_group.grafana, module.fargate-influxdb-efs ]
}

resource "aws_efs_file_system" "grafana" {
  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-grafana"
  })
}

resource "aws_efs_mount_target" "grafana" {
  count = length(aws_subnet.public)

  file_system_id  = aws_efs_file_system.grafana.id
  subnet_id       = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.efs_grafana_access.id]
}