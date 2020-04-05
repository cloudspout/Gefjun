resource "aws_api_gateway_rest_api" "api" {
  name        = "Gefjun-${terraform.workspace}"
  description = "Made in NYC with ❤️"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.gefjun.cloudspout.io"
  regional_certificate_arn = aws_acm_certificate_validation.api.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


