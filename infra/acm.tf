resource "aws_acm_certificate" "grafana" {
  domain_name       = aws_route53_record.grafana_gefjun_cloudspout_io.name
  validation_method = "DNS"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "grafana" {
  certificate_arn         = aws_acm_certificate.grafana.arn
  validation_record_fqdns = aws_route53_record.grafana_validation.*.fqdn
}

resource "aws_acm_certificate" "api" {
  domain_name       = aws_route53_record.api_gefjun_cloudspout_io.name
  validation_method = "DNS"

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = aws_route53_record.api_validation.*.fqdn
}
