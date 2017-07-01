provider "aws" {
  region = "eu-central-1"
}

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
  filename         = "ec2_state_change.zip"
  source_code_hash = "${base64sha256(file("ec2_state_change.zip"))}"
  handler          = "ec2_state_change.lambda_handler"
  runtime          = "python2.7"
  role             = "${aws_iam_role.iam_role.arn}"
  timeout          = 300
  memory_size      = 512
  tags {
    Description = "Update Hosts in Zabbix"
  }
}

resource "aws_kinesis_stream" "kinesis_stream" {
  name        = "ZabbixDemoKinesisStream"
  shard_count = 1
  tags {
    Description = "Receive Ec2 state changes from CloudWatch"
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn  = "${aws_kinesis_stream.kinesis_stream.arn}"
  function_name     = "${aws_lambda_function.lambda_function.arn}"
  batch_size        = 60 # lambda.timeout / req.duration
  enabled           = true
  starting_position = "TRIM_HORIZON"
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "ZabbixDemoEvents"
  description = "Capture every EC2 Instance state change to trigger Zabbix Lambda Function"
  event_pattern = <<PATTERN
{
  "source": [ "aws.ec2" ],
  "detail-type": [ "EC2 Instance State-change Notification" ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = "${aws_cloudwatch_event_rule.event_rule.name}"
  arn       = "${aws_lambda_function.lambda_function.arn}"
}
