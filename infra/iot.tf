data "aws_iot_endpoint" "gefjun" {
  endpoint_type="iot:Data-ATS"
}
data "aws_caller_identity" "current" {}

resource "aws_iot_thing" "sensor" {
  name = "sensor"

  attributes = {
    Manufacturer = "Sebastian"
  }
}
