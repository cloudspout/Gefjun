
resource "aws_service_discovery_private_dns_namespace" "gefjun" {
  name = "gefjun.local"
  vpc  = aws_vpc._.id
}

resource "aws_service_discovery_service" "influxdb" {
  name = "influxdb"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.gefjun.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}