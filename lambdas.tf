# Lambda crawlers

data "archive_file" "lambda_run_bike_crawler" {
  type        = "zip"
  source_file = "./lambda_functions/lambda_run_bike_crawler.py"
  output_path = "./lambda_functions/zipped/lambda_run_bike_crawler.zip"
}

resource "aws_lambda_function" "biel_lambda_run_bike_crawler" {
  filename  = "./lambda_functions/zipped/lambda_run_bike_crawler.zip"
  role      = "${aws_iam_role.biel-poc2-role.arn}"
  function_name    = "biel-lambda-run-bike-crawler"
  handler          = "lambda_run_bike_crawler.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300

  environment {
    variables = {
      duration_wait_time = "${var.duration_wait_time}",
      timeout_sec = "${var.timeout_sec}",
      bike_crawler = "${var.bikes_crawler_name}"
    }
  }
}

data "archive_file" "lambda_run_history_crawler" {
  type        = "zip"
  source_file = "./lambda_functions/lambda_run_history_crawler.py"
  output_path = "./lambda_functions/zipped/lambda_run_history_crawler.zip"
}

resource "aws_lambda_function" "lambda_run_history_crawler" {
  filename  = "./lambda_functions/zipped/lambda_run_history_crawler.zip"
  role      = "${aws_iam_role.biel-poc2-role.arn}"
  function_name    = "biel-lambda-run-history-crawler"
  handler          = "lambda_run_history_crawler.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300

  environment {
    variables = {
      duration_wait_time = "${var.duration_wait_time}",
      timeout_sec = "${var.timeout_sec}",
      history_crawler = "${var.history_crawler_name}"
    }
  }
}

data "archive_file" "lambda_run_paraquet_crawler" {
  type        = "zip"
  source_file = "./lambda_functions/lambda_run_paraquet_crawler.py"
  output_path = "./lambda_functions/zipped/lambda_run_paraquet_crawler.zip"
}

resource "aws_lambda_function" "lambda_run_paraquet_crawler" {
  filename  = "./lambda_functions/zipped/lambda_run_paraquet_crawler.zip"
  role      = "${aws_iam_role.biel-poc2-role.arn}"
  function_name    = "biel-lambda-run-paraquet-crawler"
  handler          = "lambda_run_paraquet_crawler.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300

  environment {
    variables = {
      duration_wait_time = "${var.duration_wait_time}",
      timeout_sec = "${var.timeout_sec}",
      paraquet_crawler = "${var.paraquet_crawler_name}"
    }
  }
}

# S3 bucket notification when new file is created

data "archive_file" "biel_send_event_new_file_is_created_terraform" {
  type        = "zip"
  source_file = "./lambda_functions/lambda_send_event_new_file_is_created.py"
  output_path = "./lambda_functions/zipped/lambda_send_event_new_file_is_created.zip"
}

resource "aws_lambda_function" "biel_send_event_new_file_is_created_terraform" {
  filename  = "./lambda_functions/zipped/lambda_send_event_new_file_is_created.zip"
  role      = "${aws_iam_role.biel-poc2-role.arn}"
  function_name    = "biel-lambda-send-event-new-file-is-created"
  handler          = "lambda_send_event_new_file_is_created.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300
}

resource "aws_s3_bucket_notification" "trigger_lambda_from_s3" {
  bucket = "${aws_s3_bucket.biel-poc2.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.biel_send_event_new_file_is_created_terraform.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "csv/"
    filter_suffix       = ".csv"
  }
}

resource "aws_lambda_permission" "permission" {
statement_id  = "AllowS3Invoke"
action        = "lambda:InvokeFunction"
function_name = "${aws_lambda_function.biel_send_event_new_file_is_created_terraform.function_name}"
principal = "s3.amazonaws.com"
source_arn = "arn:aws:s3:::${aws_s3_bucket.biel-poc2.id}"
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.biel_send_event_new_file_is_created_terraform.function_name

  destination_config {
    on_success {
      destination = aws_sns_topic.biel_poc_2_sns_trigger_lambda_terraform.arn
    }
  }
}

# start step function
data "archive_file" "lambda_start_step_function" {
  type        = "zip"
  source_file = "./lambda_functions/lambda_start_step_function.py"
  output_path = "./lambda_functions/zipped/lambda_start_step_function.zip"
}

resource "aws_lambda_function" "lambda_start_step_function" {
  filename  = "./lambda_functions/zipped/lambda_start_step_function.zip"
  role      = "${aws_iam_role.biel-poc2-role.arn}"
  function_name    = "biel-lambda-start-step-function"
  handler          = "lambda_start_step_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 300

  environment {
    variables = {
      step_function_arn = "${aws_sfn_state_machine.biel-poc-2-step-machine.arn}",
    }
  }
}



resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_start_step_function.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.biel_poc_2_sns_trigger_lambda_terraform.arn}"
}