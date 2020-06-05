resource "aws_security_group" "grafana_access" {
  name        = "Gefjun-${terraform.workspace}-grafana_access"
  description = "Allow access to Grafana from the ALB only"
  vpc_id      = aws_vpc._.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_access.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-grafana_access"
  })
}

resource "aws_security_group" "iot2influxdb" {
  name        = "Gefjun-${terraform.workspace}-iot2influxdb"
  description = "iot2influxdb Lambda security group"
  vpc_id      = aws_vpc._.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-iot2influxdb"
  })
}

resource "aws_security_group" "influxdb_access" {
  name        = "Gefjun-${terraform.workspace}-influxdb_access"
  description = "Allow access to the Influxdb"
  vpc_id      = aws_vpc._.id

  ingress {
    from_port = 8086
    to_port   = 8086
    protocol  = "tcp"
    security_groups = [
      aws_security_group.grafana_access.id,
      aws_security_group.iot2influxdb.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-influxdb_access"
  })
}

resource "aws_security_group" "alb_access" {
  name        = "Gefjun-${terraform.workspace}-ALB-access"
  description = "Allow access to the ALB"
  vpc_id      = aws_vpc._.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-ALB-access"
  })
}

resource "aws_security_group" "efs_grafana_access" {
  name        = "Gefjun-${terraform.workspace}-EFS-grafana-access"
  description = "Allow access to the Grafana EFS"
  vpc_id      = aws_vpc._.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = [
      aws_security_group.grafana_access.id,
    ]
  }

  tags = merge(local.common_tags, {
    Name = "Gefjun-${terraform.workspace}-EFS-grafana-access"
  })
}
