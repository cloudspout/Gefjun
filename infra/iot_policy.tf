resource "aws_iot_policy" "sensor" {
  name = "sensor-Policy"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [{
         "Effect": "Allow",
         "Action": "iot:Connect",
         "Resource": "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/${var.iot_client}"
      },
      {
         "Effect": "Allow",
         "Action": "iot:Publish",
         "Resource": [
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/update",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/delete",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/get"
         ]
      },
      {
         "Effect": "Allow",
         "Action": "iot:Receive",
         "Resource": [
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/delta",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/delete/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/get/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/rejected",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/$aws/things/${aws_iot_thing.sensor.name}/shadow/delete/rejected"
         ]
      },
      {
         "Effect": "Allow",
         "Action": "iot:Subscribe",
         "Resource": [
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/delta",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/delete/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/get/accepted",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/update/rejected",
            "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topicfilter/$aws/things/${aws_iot_thing.sensor.name}/shadow/delete/rejected"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "iot:GetThingShadow",
            "iot:UpdateThingShadow",
            "iot:DeleteThingShadow"
         ],
         "Resource": "${aws_iot_thing.sensor.arn}"

      }
   ]
}
EOF
}

resource "aws_iot_certificate" "cert" {
  active = true
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.sensor.name
  target = aws_iot_certificate.cert.arn
}
