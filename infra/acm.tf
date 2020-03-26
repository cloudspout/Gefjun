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

