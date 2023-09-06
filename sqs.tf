resource "aws_sqs_queue" "s3_put_sqs_event_notification" {
  name                      = "stg-s3-put-sqs-event-notification"
  visibility_timeout_seconds= 65
  message_retention_seconds = 345600
  delay_seconds             = 0
  max_message_size          = 262144
  receive_wait_time_seconds = 0
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "stg-s3-put-sqs-event-notification-policy",
  "Statement": [
    {
      "Sid": "Allow S3 to send messages",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:us-east-1:704331390715:stg-s3-put-sqs-event-notification",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "704331390715"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:*:*:cenco-pe-poc-ventas"
        }
      }
    }
  ]
}
EOF

  #tags = local.tags
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = "${aws_sqs_queue.s3_put_sqs_event_notification.arn}"
  enabled          = true
  function_name    = "arn:aws:lambda:us-east-1:704331390715:function:cenco-pe-poc-ventas-create-csv-lambda"
  batch_size       = 300
  maximum_batching_window_in_seconds = 5
}