resource "aws_api_gateway_resource" "greenhouse_lights" {
  rest_api_id = var.aws_api_gateway_rest_api.id
  parent_id   = var.aws_api_gateway_resource.id
  path_part   = "lights"
}

resource "aws_api_gateway_resource" "greenhouse_lights_on" {
  rest_api_id = var.aws_api_gateway_rest_api.id
  parent_id   = aws_api_gateway_resource.greenhouse_lights.id
  path_part   = "on"
}

resource "aws_api_gateway_resource" "greenhouse_lights_off" {
  rest_api_id = var.aws_api_gateway_rest_api.id
  parent_id   = aws_api_gateway_resource.greenhouse_lights.id
  path_part   = "off"
}

module "endponit_light-off" {
  source = "./endpoint-light"

  aws_api_gateway_rest_api = var.aws_api_gateway_rest_api
  aws_api_gateway_resource = aws_api_gateway_resource.greenhouse_lights_off
  aws_lambda_function      = var.aws_lambda_function
  desired_state            = false
}

module "endponit_light-on" {
  source = "./endpoint-light"

  aws_api_gateway_rest_api = var.aws_api_gateway_rest_api
  aws_api_gateway_resource = aws_api_gateway_resource.greenhouse_lights_on
  aws_lambda_function      = var.aws_lambda_function
  desired_state            = true
}



