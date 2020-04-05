data "aws_route53_zone" "cloudspout_io" {
  name         = "cloudspout.io."
} 

resource "aws_route53_record" "grafana_validation" {
  count = length(aws_acm_certificate.grafana.domain_validation_options)

  zone_id = data.aws_route53_zone.cloudspout_io.id

  name    = aws_acm_certificate.grafana.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.grafana.domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.grafana.domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "api_validation" {
  count = length(aws_acm_certificate.api.domain_validation_options)

  zone_id = data.aws_route53_zone.cloudspout_io.id

  name    = aws_acm_certificate.api.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.api.domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.api.domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "grafana_gefjun_cloudspout_io" {
  zone_id = data.aws_route53_zone.cloudspout_io.id

  name    = "grafana.gefjun.cloudspout.io"
  type    = "A"

  alias {
    name                   = aws_alb.grafana.dns_name
    zone_id                = aws_alb.grafana.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_gefjun_cloudspout_io" {
  zone_id = data.aws_route53_zone.cloudspout_io.id

  name    = aws_acm_certificate.api.domain_name
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
  }
}
