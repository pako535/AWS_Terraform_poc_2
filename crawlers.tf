resource "aws_glue_classifier" "biel-poc2-classifier" {
  name = "biel-poc2-classifier"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "UNKNOWN"
    delimiter              = ","
    disable_value_trimming = false
    quote_symbol           = "\""
  }
}

resource "aws_glue_crawler" "biel-poc2-history-crawler" {
  database_name = aws_glue_catalog_database.biel-poc2-db.name
  name          = "biel-poc2-history-crawler"
  role          = aws_iam_role.glue_role.arn
  classifiers = [aws_glue_classifier.biel-poc2-classifier.name]

  s3_target {
    path = "s3://${aws_s3_bucket.biel-poc2.bucket}/csv/history"
  }
}

resource "aws_glue_crawler" "biel-poc2-bikes-crawler" {
  database_name = aws_glue_catalog_database.biel-poc2-db.name
  name          = "biel-poc2-bikes-crawler"
  role          = aws_iam_role.glue_role.arn
  classifiers = [aws_glue_classifier.biel-poc2-classifier.name]

  s3_target {
    path = "s3://${aws_s3_bucket.biel-poc2.bucket}/csv/bikes"
  }
}

resource "aws_glue_crawler" "biel-poc2-paraquet-crawler" {
  database_name = aws_glue_catalog_database.biel-poc2-db.name
  name          = "biel-poc2-paraquet-crawler"
  role          = aws_iam_role.glue_role.arn
  classifiers = [aws_glue_classifier.biel-poc2-classifier.name]

  s3_target {
    path = "s3://${aws_s3_bucket.biel-poc2.bucket}/csv/paraquet"
  }
}