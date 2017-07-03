
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

resource "aws_iam_role" "cloud_watch_role" {
  name = "ZabbixDemoCloudWatchRole"
  description = "Allow CloudWatch to write to Kinesis Stream"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloud_watch_role_policy" {
  name = "ZabbixDemoCloudWatchPolicy"
  role = "${aws_iam_role.cloud_watch_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.kinesis_stream.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = "${aws_cloudwatch_event_rule.event_rule.name}"
  arn       = "${aws_kinesis_stream.kinesis_stream.arn}"
  role_arn  = "${aws_iam_role.cloud_watch_role.arn}"
}
