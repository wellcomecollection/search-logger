locals {
  lambda_file_name   = "lambdas/search_logger_kinesis_to_es_lambda.zip"
  lambda_bucket_name = "search-logger"
}

data "aws_iam_policy_document" "kms_decrypt_env_vars" {
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.lambda_env_vars.arn]
  }
}

data "aws_iam_policy_document" "secrets_manager_es_details_read" {
  statement {
    actions   = ["secretsmanager:Get*"]
    resources = [data.aws_secretsmanager_secret.es_details.arn]
  }
}

resource "aws_iam_policy" "search_logger_kinesis_to_es_kms_decrypt_policy" {
  name        = "SearchLoggerKinesisToEsLambdaDecryptKMS"
  description = "Allow the decrypting of keys via KMS"
  policy      = data.aws_iam_policy_document.kms_decrypt_env_vars.json
}

resource "aws_iam_policy" "search_logger_kinesis_to_es_secrets_manager_read_es_details" {
  name        = "SearchLoggerKinesisToEsLambdaSecretsManagerReadEsDetails"
  description = "Read the ES details from Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets_manager_es_details_read.json
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_kms_decrypt" {
  role       = module.search_logger.lambda_role.id
  policy_arn = aws_iam_policy.search_logger_kinesis_to_es_kms_decrypt_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_secrets_manager_read_es_details" {
  role       = module.search_logger.lambda_role.id
  policy_arn = aws_iam_policy.search_logger_kinesis_to_es_secrets_manager_read_es_details.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role_attachement" {
  role       = module.search_logger.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_execution_role_attachement" {
  role       = module.search_logger.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
}

data "aws_s3_object" "search_logger_kinesis_to_es_lambda_s3_object" {
  bucket = local.lambda_bucket_name
  key    = local.lambda_file_name
}

module "search_logger" {
  source = "git@github.com:wellcomecollection/terraform-aws-lambda.git?ref=v1.2.0"

  name = "search_logger_kinesis_to_es_lambda"

  runtime           = "nodejs12.x"
  handler           = "index.handler"
  s3_bucket         = data.aws_s3_object.search_logger_kinesis_to_es_lambda_s3_object.bucket
  s3_key            = data.aws_s3_object.search_logger_kinesis_to_es_lambda_s3_object.key
  s3_object_version = data.aws_s3_object.search_logger_kinesis_to_es_lambda_s3_object.version_id
  publish           = true

  # Note: this timeout was originally 3 seconds, but we increased it when
  # we saw the Lambda timing out.  It processes events from Kinesis in batches
  # of 100, so this should be plenty.
  timeout = 60

  error_alarm_topic_arn = local.lambda_error_alert_arn
}

resource "aws_lambda_event_source_mapping" "search_logger_kinesis_to_es_lambda_source_mapping" {
  event_source_arn  = aws_kinesis_stream.search_logger_stream.arn
  function_name     = module.search_logger.lambda.arn
  starting_position = "LATEST"
}

output "lambda_s3_version" {
  value = data.aws_s3_object.search_logger_kinesis_to_es_lambda_s3_object.version_id
}
