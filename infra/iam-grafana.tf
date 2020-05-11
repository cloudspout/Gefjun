resource "aws_iam_role" "grafana_execution" {
  name               = "Gefjun-${terraform.workspace}-grafana_execution"
  assume_role_policy = data.aws_iam_policy_document.ECS_trust.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "grafana_execution-attach-AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.grafana_execution.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

data "aws_iam_policy_document" "grafana_secrets_access" {
  version = "2012-10-17"

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_secretsmanager_secret.grafana_admin-password.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "grafana_secrets_access" {
  name        = "Gefjun-${terraform.workspace}-grafana_secrets_access"
  description = ""

  policy = data.aws_iam_policy_document.grafana_secrets_access.json
}

resource "aws_iam_role_policy_attachment" "grafana_execution-attach-grafana_secrets_access" {
  role       = aws_iam_role.grafana_execution.name
  policy_arn = aws_iam_policy.grafana_secrets_access.arn
}

resource "aws_iam_role" "grafana" {
  name               = "Gefjun-${terraform.workspace}-grafana"
  assume_role_policy = data.aws_iam_policy_document.ECS_trust.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "grafana_cloudwatch_access" {
  version = "2012-10-17"

  statement {
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "tag:GetResources"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "grafana_cloudwatch_access" {
  name        = "Gefjun-${terraform.workspace}-grafana_cloudwatch_access"
  description = "Grafana needs permissions granted via IAM to be able to read CloudWatch metrics and EC2 tags/instances/regions"

  policy = data.aws_iam_policy_document.grafana_cloudwatch_access.json
}

resource "aws_iam_role_policy_attachment" "grafana-attach-grafana_cloudwatch_access" {
  role       = aws_iam_role.grafana.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_access.arn
}
