resource "aws_ecs_cluster" "gefjun" {
  name = "Gefjun-${terraform.workspace}"

  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}




