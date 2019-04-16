data "aws_secretsmanager_secret" "es_details" {
  name = "prod/SearchLogger/es_details"
}
