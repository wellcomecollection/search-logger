locals {
  lambda_file_name   = "lambdas/search_logger_kinesis_to_es_lambda.zip"
  lambda_bucket_name = "search-logger"
}

variable "es_url" {}
variable "es_username" {}
variable "es_password" {}

data "aws_iam_policy_document" "search_logger_kinesis_to_es_lambda_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "search_logger_kinesis_to_es_lambda_role" {
  name               = "SearchLoggerKinesisToEsLambdaRole"
  assume_role_policy = "${data.aws_iam_policy_document.search_logger_kinesis_to_es_lambda_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role_attachement" {
  role       = "${aws_iam_role.search_logger_kinesis_to_es_lambda_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_execution_role_attachement" {
  role       = "${aws_iam_role.search_logger_kinesis_to_es_lambda_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

data "aws_s3_bucket_object" "search_logger_kinesis_to_es_lambda_s3_object" {
  bucket = "${local.lambda_bucket_name}"
  key    = "${local.lambda_file_name}"
}

resource "aws_lambda_function" "search_logger_kinesis_to_es_lambda" {
  function_name     = "search_logger_kinesis_to_es_lambda"
  role              = "${aws_iam_role.search_logger_kinesis_to_es_lambda_role.arn}"
  runtime           = "nodejs8.10"
  handler           = "index.handler"
  s3_bucket         = "${data.aws_s3_bucket_object.search_logger_kinesis_to_es_lambda_s3_object.bucket}"
  s3_key            = "${data.aws_s3_bucket_object.search_logger_kinesis_to_es_lambda_s3_object.key}"
  s3_object_version = "${data.aws_s3_bucket_object.search_logger_kinesis_to_es_lambda_s3_object.version_id}"
  publish           = true

  environment = {
    variables = {
      ES_URL      = "${var.es_url}"
      ES_USERNAME = "${var.es_username}"
      ES_PASSWORD = "${var.es_password}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "search_logger_kinesis_to_es_lambda_source_mapping" {
  event_source_arn  = "${aws_kinesis_stream.search_logger_stream.arn}"
  function_name     = "${aws_lambda_function.search_logger_kinesis_to_es_lambda.arn}"
  starting_position = "LATEST"
}
