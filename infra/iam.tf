data "aws_iam_policy_document" "light" {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "light" {
  name = "Gefjun-${terraform.workspace}-Light"

  assume_role_policy = data.aws_iam_policy_document.light.json
}

data "aws_iam_policy_document" "lambda_logging" {
  version = "2012-10-17"

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "Gefjun-${terraform.workspace}-lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging-light" {
  role       = aws_iam_role.light.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "aws_iam_policy_document" "lamda_iot-light" {
  version = "2012-10-17"

  statement {
    actions = [
      "iot:Connect"
    ]

    resources = ["*"]

    effect = "Allow"
  }

  statement {
    actions = [
      "iot:GetThingShadow",
      "iot:UpdateThingShadow",
      "iot:DeleteThingShadow"
    ]

    resources = [aws_iot_thing.sensor.arn]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "lamda_iot-light" {
  name        = "Gefjun-${terraform.workspace}-lambda_iot-light"
  path        = "/"
  description = "IAM policy for IOT from a lambda"

  policy = data.aws_iam_policy_document.lamda_iot-light.json
}

resource "aws_iam_role_policy_attachment" "lamda_iot-light" {
  role       = aws_iam_role.light.name
  policy_arn = aws_iam_policy.lamda_iot-light.arn
}

resource "aws_iam_role" "sunrise" {
  name = "Gefjun-${terraform.workspace}-Sunrise"

  assume_role_policy = data.aws_iam_policy_document.light.json
}


data "aws_iam_policy_document" "update-cloudwatch-cron" {
  version = "2012-10-17"

  statement {
    actions = [
      "events:DescribeRule",
      "events:PutRule"
    ]

    resources = [
      aws_cloudwatch_event_rule.light_trigger_on.arn,
      aws_cloudwatch_event_rule.light_trigger_off.arn
    ]

    effect = "Allow"
  }

}

resource "aws_iam_policy" "update-cloudwatch-cron" {
  name        = "Gefjun-${terraform.workspace}-update-cloudwatch-cron"
  path        = "/"
  description = "IAM policy to update CloudWatch light on/off trigger"

  policy = data.aws_iam_policy_document.update-cloudwatch-cron.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging-sunrise" {
  role       = aws_iam_role.sunrise.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "update-cloudwatch-cron" {
  role       = aws_iam_role.sunrise.name
  policy_arn = aws_iam_policy.update-cloudwatch-cron.arn
}
