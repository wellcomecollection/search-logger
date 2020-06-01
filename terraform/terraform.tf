locals {
  segment_account_id     = "595280932656"
  webplatform_account_id = "130871440101"
  stream_name            = "SearchLogger"
  service_name           = "search-logger"
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
