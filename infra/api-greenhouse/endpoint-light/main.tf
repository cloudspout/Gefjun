resource "aws_api_gateway_method" "greenhouse_lights" {
  rest_api_id   = var.aws_api_gateway_rest_api.id
  resource_id   = var.aws_api_gateway_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.aws_api_gateway_rest_api.id
  resource_id             = aws_api_gateway_method.greenhouse_lights.resource_id
  http_method             = aws_api_gateway_method.greenhouse_lights.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.aws_lambda_function.invoke_arn
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = "{\"desiredState\": ${var.desired_state}}"
  }
}

resource "aws_api_gateway_integration_response" "greenhouse_lights" {
  rest_api_id   = var.aws_api_gateway_rest_api.id
  resource_id   = aws_api_gateway_method.greenhouse_lights.resource_id
  http_method   = aws_api_gateway_method.greenhouse_lights.http_method
  
  status_code = 200
  selection_pattern = ".*"

  response_templates = {
    "application/json" = "{\"statusCode\":\"200\"}"
  }  
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id   = var.aws_api_gateway_rest_api.id
  resource_id   = aws_api_gateway_method.greenhouse_lights.resource_id
  http_method   = aws_api_gateway_method.greenhouse_lights.http_method
  
  status_code = 200
}
