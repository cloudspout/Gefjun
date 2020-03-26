variable "aws_region" {
  default = "us-east-1"
}

variable "iot_client" {
  default = "RaspberryPi"
}

variable "alexa_skill_id" {
  type = string
}

variable "grafana_cpu" {
  type        = number
  description = ""
  default     = 256
}

variable "grafana_memory" {
  type        = number
  description = ""
  default     = 512
}

variable "influxdb_cpu" {
  type        = number
  description = ""
  default     = 256
}

variable "influxdb_memory" {
  type        = number
  description = ""
  default     = 512
}
