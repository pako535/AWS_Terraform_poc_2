resource "aws_sns_topic" "biel_poc_2_sns_email_notification" {
  name = "biel_poc_2_sns_email_notification"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.biel_poc_2_sns_email_notification.arn}"
  protocol  = "email"
  endpoint  = "${var.sns_email_address}"
}

# Triger step function when new object is created

resource "aws_sns_topic" "biel_poc_2_sns_trigger_lambda_terraform" {
  name = "biel_poc_2_sns_trigger_lambda_terraform"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
}

resource "aws_sns_topic_subscription" "triger_step_function_sub" {
  topic_arn = "${aws_sns_topic.biel_poc_2_sns_trigger_lambda_terraform.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda_start_step_function.arn}"
}