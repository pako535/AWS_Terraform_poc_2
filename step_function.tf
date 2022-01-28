resource "aws_sfn_state_machine" "biel-poc-2-step-machine" {
  name     = "biel-poc-2-step-machine-terraform"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "Comment": "Biel Poc 2 Step function",
  "StartAt": "ErrorHandler",
  "States": {
    "ErrorHandler": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Choice",
          "States": {
            "Choice": {
              "Type": "Choice",
              "Choices": [
                {
                  "Variable": "$.prefix",
                  "StringMatches": "biel-poc2/csv/bikes/",
                  "Next": "Bikes crawling solo"
                },
                {
                  "Variable": "$.prefix",
                  "StringMatches": "biel-poc2/csv/history/",
                  "Next": "History crawling solo"
                }
              ]
            },
            "Bikes crawling solo": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.biel_lambda_run_bike_crawler.arn}",
              "TimeoutSeconds": 600,
              "Next": "Join"
            },
            "History crawling solo": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.lambda_run_history_crawler.arn}",
              "TimeoutSeconds": 600,
              "Next": "Join"
            },
            "Join": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun",
              "Parameters": {
                "JobName": "${aws_glue_job.join_data_glue_job.name}"
              },
              "Next": "Paraquet crawling"
            },
            "Paraquet crawling": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.lambda_run_paraquet_crawler.arn}",
              "TimeoutSeconds": 600,
              "End": true
            }
          }
        }
      ],
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "ResultPath": "$.error",
          "Next": "Send Failed Email"
        }
      ],
      "Next": "Send Succeed Email"
    },
    "Succeed": {
      "Type": "Succeed"
    },
    "Send Succeed Email": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.biel_poc_2_sns_email_notification.arn}",
        "Message": "Job Succeed"
      },
      "Next": "Succeed"
    },
    "Send Failed Email": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${aws_sns_topic.biel_poc_2_sns_email_notification.arn}",
        "Message": "Something went wrong! - FAILD"
      },
      "Next": "Fail Workflow"
    },
    "Fail Workflow": {
      "Type": "Fail"
    }
  }
}
EOF
}





# "Parallel": {
#       "Type": "Parallel",
#       "Branches": [
#         {
#           "StartAt": "Bikes crawling",
#           "States": {
#             "Bikes crawling": {
#               "Type": "Task",
#               "Resource": "${aws_lambda_function.biel_lambda_run_bike_crawler.arn}",
#               "TimeoutSeconds": 600,
#               "End": true
#             }
#           }
#         },
#         {
#           "StartAt": "History crawling",
#           "States": {
#             "History crawling": {
#               "Type": "Task",
#               "Resource": "${aws_lambda_function.lambda_run_history_crawler.arn}",
#               "TimeoutSeconds": 600,
#               "End": true
#             }
#           }
#         }
#       ],
#       "Next": "Join"
#     },