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
