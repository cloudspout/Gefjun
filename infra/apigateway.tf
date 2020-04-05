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


