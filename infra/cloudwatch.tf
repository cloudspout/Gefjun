resource "aws_cloudwatch_log_group" "light" {
  name              = "/aws/lambda/Gefjun/${terraform.workspace}/light"
  retention_in_days = 7
}

resource "aws_cloudwatch_event_rule" "light_trigger_on" {
  name        = "Gefjun-${terraform.workspace}-Light-On"
  description = "Turns the light on at a certain time"

  schedule_expression = "cron(0 13 * * ? *)"

  lifecycle {
    ignore_changes = [schedule_expression]
  }
}

resource "aws_cloudwatch_event_rule" "light_trigger_off" {
  name        = "Gefjun-${terraform.workspace}-Light-Off"
  description = "Turns the light off at a certain time"

  schedule_expression = "cron(0 21 * * ? *)"

  lifecycle {
    ignore_changes = [schedule_expression]
  }
}

resource "aws_cloudwatch_event_rule" "sunrise" {
  name        = "Gefjun-${terraform.workspace}-Sunrise"
  description = "Sets the timer for ON and OFF trigger based on the sun "

  schedule_expression = "cron(1 0 * * ? *)"
}
