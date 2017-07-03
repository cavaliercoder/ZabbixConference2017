resource "aws_iam_role" "iam_role" {
  name = "ZabbixDemoRole"
  description = "Role for Zabbix Demo Lambda Function"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name = "ZabbixDemoPolicy"
  role = "${aws_iam_role.iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListStreams"
      ],
      "Resource": [ "${aws_kinesis_stream.kinesis_stream.arn}"]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "ZabbixDemoLambdaFunction"
  description      = "Update hosts in Zabbix when their state changes in EC2"
  filename         = "../lambda/ec2_state_change.zip"
  source_code_hash = "${base64sha256(file("../lambda/ec2_state_change.zip"))}"
  handler          = "ec2_state_change.kinesis_stream_handler"
  runtime          = "python2.7"
  role             = "${aws_iam_role.iam_role.arn}"
  timeout          = 300
  memory_size      = 512
  
  tags {
    Description = "Update Hosts in Zabbix"
  }

  environment {
    variables = {
      ZABBIX_URL      = "http://${aws_instance.zabbix_server.public_ip}/zabbix"
      ZABBIX_USER     = "Admin"
      ZABBIX_PASSWORD = "zabbix"
      DEBUG           = "true"
    }
  }
}
