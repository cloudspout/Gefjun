resource "aws_lambda_function" "iot2influxdb" {
  function_name = "Gefjun-${terraform.workspace}-iot2influxdb"
  role          = aws_iam_role.iot2influxdb.arn
  handler       = "iot2influxdb.handler"

  s3_bucket         = aws_s3_bucket_object.light.bucket
  s3_key            = aws_s3_bucket_object.light.key
  s3_object_version = aws_s3_bucket_object.light.version_id
  source_code_hash  = filebase64sha256(aws_s3_bucket_object.light.source)

  runtime     = "nodejs12.x"
  memory_size = 128
  timeout     = 3
  publish     = true

  vpc_config {
    subnet_ids         = aws_subnet.private.*.id
    security_group_ids = [ aws_security_group.iot2influxdb.id ]
  }

  environment {
    variables = {
        INFLUXDB        = "gefjun"
        INFLUXDBUSRNAME = "lambda"
        INFLUXDBPWD     = aws_secretsmanager_secret_version.influxdb_lambda-password.secret_string
        INFLUXDBPORT    = "8086"
        INFLUXDBHOST    = "influxdb.gefjun.local"
    }
  }

  tags = local.common_tags

  depends_on = [aws_iam_role_policy_attachment.lambda_logging-iot2influxdb, aws_cloudwatch_log_group.light]
}

resource "aws_lambda_alias" "iot2influxdb" {
  name             = "Gefjun-${terraform.workspace}-iot2influxdb-LATEST"
  description      = "Gefjun-${terraform.workspace}-iot2influxdb LATEST"
  function_name    = aws_lambda_function.iot2influxdb.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow_iot_rule" {
  statement_id  = "AllowExecutionFromIoT-Gefjun-${terraform.workspace}-iot2influxdb"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iot2influxdb.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.iot2influxdb.arn
  qualifier     = aws_lambda_alias.iot2influxdb.name
}

resource "aws_iot_topic_rule" "iot2influxdb" {
  name        = "Gefjun_${terraform.workspace}_iot2influxdb"
  description = "Pushes the events to the influxdb"
  enabled     = true
  sql         = "SELECT state.reported FROM '$aws/things/sensor/shadow/update'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.iot2influxdb.arn
  }
}
