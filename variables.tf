variable "lambda_run_paraquet_key" {
  type    = string
  default = "scripts/lambda_run_paraquet_crawler.py"
}

variable "lambda_run_history_key" {
  type    = string
  default = "scripts/lambda_run_history_crawler.py"
}

variable "lambda_run_bike_key" {
  type    = string
  default = "scripts/lambda_run_bike_crawler.zip"
}

variable "bikes_crawler_name" {
  type    = string
  default = "biel-poc2-bikes-crawler"
}

variable "history_crawler_name" {
  type    = string
  default = "biel-poc2-history-crawler"
}

variable "paraquet_crawler_name" {
  type    = string
  default = "biel-poc2-paraquet"
}

variable "duration_wait_time" {
  type    = number
  default = 5
}

variable "timeout_sec" {
  type    = number
  default =  600
}

variable "sns_email_address" {
  type    = string
  default = "pawel.biel@capgemini.com"
}
