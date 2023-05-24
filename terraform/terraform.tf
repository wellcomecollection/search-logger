locals {
  segment_account_id     = "595280932656"
  webplatform_account_id = "130871440101"
  stream_name            = "SearchLogger"
  service_name           = "search-logger"

  lambda_error_alert_arn = data.terraform_remote_state.monitoring.outputs["experience_lambda_error_alerts_topic_arn"]
}

variable "segment_source_id" {}

terraform {
  required_version = ">= 0.12.26"

  backend "s3" {
    role_arn       = "arn:aws:iam::130871440101:role/experience-developer"
    key            = "build-state/search-logger.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
    bucket         = "wellcomecollection-infra"
  }
}

data "terraform_remote_state" "monitoring" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/monitoring.tfstate"
    region = "eu-west-1"
  }
}
