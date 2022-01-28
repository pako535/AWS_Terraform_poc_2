# Create bucket
resource "aws_s3_bucket" "biel-poc2" {
  bucket = "biel-poc2"
  acl    = "private"
}

# Create folders
resource "aws_s3_bucket_object" "bikes" {
    bucket = "${aws_s3_bucket.biel-poc2.id}"
    acl    = "private"
    key    = "csv/bikes/"
}

resource "aws_s3_bucket_object" "history" {
    bucket = "${aws_s3_bucket.biel-poc2.id}"
    acl    = "private"
    key    = "csv/history/"
}

resource "aws_s3_bucket_object" "paraquet" {
    bucket = "${aws_s3_bucket.biel-poc2.id}"
    acl    = "private"
    key    = "paraquet/"
}

# Upload scripts on s3
resource "aws_s3_bucket_object" "glue_job_upload" {
    bucket = "${aws_s3_bucket.biel-poc2.id}"
    acl    = "private"
    key    = "scripts/join_data_glue_job.py"
    source = "./join_data_glue_job.py"
    etag   = "${filemd5("./join_data_glue_job.py")}"
}