
resource "aws_service_discovery_private_dns_namespace" "gefjun" {
  name = "gefjun.local"
  vpc  = aws_vpc._.id
}
