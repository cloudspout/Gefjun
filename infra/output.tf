output "certificate_pem" {
  value = aws_iot_certificate.cert.certificate_pem
}

output "private_key" {
  value = aws_iot_certificate.cert.private_key
}

output "sensor_arn" {
  value = aws_iot_thing.sensor.arn
}

output "endpoint" {
  value = data.aws_iot_endpoint.gefjun.endpoint_address
}

output "lambda_arn" {
  value = aws_lambda_function.light.arn
}

output "grafana_admin-password" {
  value = random_password.grafana_admin-password.result
}

output "influxdb_admin-password" {
  value = random_password.influxdb_admin-password.result
}


output "influxdb_grafana-password" {
  value = random_password.influxdb_grafana-password.result
}

