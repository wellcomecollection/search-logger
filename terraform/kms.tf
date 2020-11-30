resource "aws_kms_key" "lambda_env_vars" {
  description = "Encrypt / decrypt env vars"

  tags = {
    Service = local.service_name
  }
}

resource "aws_kms_alias" "lambda_env_vars" {
  name          = "alias/lambda/env-vars"
  target_key_id = aws_kms_key.lambda_env_vars.key_id
}
