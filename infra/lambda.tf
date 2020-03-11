data "archive_file" "light" {
  type        = "zip"
  source_file = "../src/javascript/index.js"
  output_path = "${path.root}/.terraform/tmp/light.zip"
}

resource "aws_s3_bucket_object" "light" {
  bucket = aws_s3_bucket._.bucket
  key    = "${terraform.workspace}/light/index.zip"

  source = data.archive_file.light.output_path
  etag   = filemd5(data.archive_file.light.output_path)

  content_type = "application/zip"
}

resource "aws_lambda_function" "light" {
  function_name = "Gefjun-${terraform.workspace}-Light"
  role          = aws_iam_role.light.arn
  handler       = "index.handler"

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
      MQTT_BROKER_ENDPOINT = data.aws_iot_endpoint.gefjun.endpoint_address
      THING_NAME           = aws_iot_thing.sensor.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_logging, aws_cloudwatch_log_group.light]
}

resource "aws_lambda_alias" "light" {
  name             = "Gefjun-${terraform.workspace}-LATEST"
  description      = "Gefjun-${terraform.workspace} LATEST"
  function_name    = aws_lambda_function.light.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_cloudwatch_on" {
  statement_id  = "AllowExecutionFromCloudWatch-Gefjun-${terraform.workspace}-Light-On"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.light.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.light_trigger_on.arn
  qualifier     = aws_lambda_alias.light.name
}

resource "aws_cloudwatch_event_target" "light_on" {
  target_id = "Gefjun-${terraform.workspace}-Light"
  rule      = aws_cloudwatch_event_rule.light_trigger_on.name
  arn       = aws_lambda_alias.light.arn

  input = "{\"desiredState\": true}"
}

resource "aws_cloudwatch_event_target" "light_off" {
  target_id = "Gefjun-${terraform.workspace}-Light-Off"
  rule      = aws_cloudwatch_event_rule.light_trigger_off.name
  arn       = aws_lambda_alias.light.arn

  input = "{\"desiredState\": false}"
}
