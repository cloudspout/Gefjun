resource "aws_lambda_function" "sunrise" {
  function_name = "Gefjun-${terraform.workspace}-Sunrise"
  role          = aws_iam_role.sunrise.arn
  handler       = "sunrise.handler"

  s3_bucket         = aws_s3_bucket_object.light.bucket
  s3_key            = aws_s3_bucket_object.light.key
  s3_object_version = aws_s3_bucket_object.light.version_id
  source_code_hash  = filebase64sha256(aws_s3_bucket_object.light.source)

  runtime     = "nodejs12.x"
  memory_size = 128
  timeout     = 3
  publish     = true

  environment {
    variables = {
      LOCATION_LAT = "40.7603878"
      LOCATION_LNG = "-74.0006542"
      DURATION = 6
      RULE_ON = aws_cloudwatch_event_rule.light_trigger_on.name
      RULE_OFF = aws_cloudwatch_event_rule.light_trigger_off.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logging-sunrise, aws_cloudwatch_log_group.light]
}

resource "aws_lambda_alias" "sunrise" {
  name             = "Gefjun-${terraform.workspace}-Sunrise-LATEST"
  description      = "Gefjun-${terraform.workspace}-Sunrise LATEST"
  function_name    = aws_lambda_function.sunrise.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_cloudwatch_sunrise" {
  statement_id  = "AllowExecutionFromCloudWatch-Gefjun-${terraform.workspace}-Sunrise"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sunrise.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sunrise.arn
  qualifier     = aws_lambda_alias.sunrise.name
}

resource "aws_cloudwatch_event_target" "sunrise" {
  target_id = "Gefjun-${terraform.workspace}-Sunrise"
  rule      = aws_cloudwatch_event_rule.sunrise.name
  arn       = aws_lambda_alias.sunrise.arn
}
