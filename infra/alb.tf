resource "aws_alb" "grafana" {
  name               = "Gefjun-${terraform.workspace}-Grafana"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_access.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false

  tags = local.common_tags
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.grafana.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = aws_acm_certificate_validation.grafana.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.grafana.arn
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.grafana]
}

resource "aws_alb_target_group" "grafana" {
  name        = "Gefjun-${terraform.workspace}-Grafana"
  port        = 3000
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = aws_vpc._.id

  health_check {
    matcher = "200-399"
  }

  depends_on = [aws_alb.grafana]
}
