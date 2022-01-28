data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "AWSSFNTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
  }
}


data "aws_iam_policy_document" "AWSGlueTrustPolicy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "s3_objects_policy" {
  name   = "biel-poc2-s3-bucket-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${aws_s3_bucket.biel-poc2.arn}/*"
            ]
        }
    ]
}
EOF
}

# Roles
resource "aws_iam_role" "glue_role" {
  name               = "biel-poc2-glue-role"
  assume_role_policy = data.aws_iam_policy_document.AWSGlueTrustPolicy.json
}

resource "aws_iam_role" "step_function_role" {
  name               = "biel-poc2-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.AWSSFNTrustPolicy.json
}

resource "aws_iam_role" "biel-poc2-role" {
  name               = "biel-poc2-role"
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json

}

# Attachments

resource "aws_iam_role_policy_attachment" "glue_policy_glue_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_role.name
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  policy_arn = aws_iam_policy.s3_objects_policy.arn
  role       = aws_iam_role.glue_role.name
}

resource "aws_iam_role_policy_attachment" "sfn_policy_glue" {
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  role       = aws_iam_role.glue_role.name
}

# sfn role

resource "aws_iam_role_policy_attachment" "lambda_execute_sfn" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

resource "aws_iam_role_policy_attachment" "sfn_policy_step_fn" {
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  role       = aws_iam_role.step_function_role.name
}

resource "aws_iam_role_policy_attachment" "glue_policy_step_fn" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.step_function_role.name
}

resource "aws_iam_role_policy_attachment" "sns_topic_step_fn" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  role       = aws_iam_role.step_function_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_policy_sfn" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# poc2 role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.biel-poc2-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sns_lambda_policy" {
  policy_arn = aws_iam_policy.sns_publish_policy.arn
  role       = aws_iam_role.biel-poc2-role.name
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.biel-poc2-role.name
}

resource "aws_iam_role_policy_attachment" "policy_step_fn" {
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  role       = aws_iam_role.biel-poc2-role.name
}

resource "aws_iam_policy" "sns_publish_policy" {
  name = "biel-sns-publish-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.biel_poc_2_sns_trigger_lambda_terraform.arn
      }
    ]
  })
}