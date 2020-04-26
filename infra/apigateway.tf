locals {
  apigateway_description = "apigateway.tf${filemd5("apigateway.tf")} greenhouse:${module.api_greenhouse.md5sum}"
  apigateway_md5 = md5(local.apigateway_description)
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "Gefjun-${terraform.workspace}"
  description = "Made in NYC with ❤️"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = aws_acm_certificate.api.domain_name
  regional_certificate_arn = aws_acm_certificate.api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_api_key" "grafana" {
  name = "grafana-${terraform.workspace}"
  description = "Made in NYC with ❤"

  tags = local.common_tags
}

resource "aws_api_gateway_usage_plan" "grafana" {
  name = "grafana-${terraform.workspace}"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.greenhouse.stage_name
  }

  depends_on = [aws_api_gateway_deployment.greenhouse]
}

resource "aws_api_gateway_usage_plan_key" "grafana" {
  key_id        = aws_api_gateway_api_key.grafana.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.grafana.id
}

resource "aws_api_gateway_deployment" "greenhouse" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  stage_description = local.apigateway_md5
  description = local.apigateway_description

  stage_name = ""

  lifecycle {
    create_before_destroy = "true"
  }

  depends_on = [ module.api_greenhouse ]
}

resource "aws_api_gateway_method_settings" "greenhouse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = aws_api_gateway_stage.greenhouse.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
  #  logging_level = "INFO"
    data_trace_enabled = false
  }
}

resource "aws_api_gateway_stage" "greenhouse" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  stage_name = terraform.workspace
  deployment_id = aws_api_gateway_deployment.greenhouse.id
  #documentation_version

  xray_tracing_enabled = "true"

  tags = merge(local.common_tags, {
    md5: local.apigateway_md5
  })

  depends_on = [
    aws_cloudwatch_log_group.api_gateway
  ]
}

resource "aws_api_gateway_method_settings" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.greenhouse.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }

  depends_on = [
    aws_api_gateway_account.api
  ]
}

resource "aws_api_gateway_resource" "greenhouse" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "greenhouse"
}

module "api_greenhouse" {
  source = "./api-greenhouse"

  aws_api_gateway_rest_api = aws_api_gateway_rest_api.api
  aws_api_gateway_resource = aws_api_gateway_resource.greenhouse
  aws_lambda_function = aws_lambda_function.light

  region = var.aws_region
  account = data.aws_caller_identity.current
}

resource "aws_api_gateway_base_path_mapping" "greenhouse" {
  api_id = aws_api_gateway_rest_api.api.id
  stage_name = aws_api_gateway_stage.greenhouse.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}
resource "aws_api_gateway_account" "api" {
  cloudwatch_role_arn = aws_iam_role.api_gateway.arn
}
