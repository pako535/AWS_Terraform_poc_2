resource "aws_glue_job" "join_data_glue_job" {
  name     = "biel-join-data-glue-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.biel-poc2.id}/scripts/join_data_glue_job.py"
  }
}