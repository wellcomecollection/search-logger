#!/usr/bin/env bash

AWS_CLI_PROFILE="search-logger-terraform"
EXPERIENCE_DEVELOPER_ARN="arn:aws:iam::130871440101:role/experience-developer"

aws configure set region eu-west-1 --profile $AWS_CLI_PROFILE
aws configure set role_arn "$EXPERIENCE_DEVELOPER_ARN" --profile $AWS_CLI_PROFILE
aws configure set source_profile default --profile $AWS_CLI_PROFILE

SEGMENT_SOURCE_ID=$(aws secretsmanager get-secret-value \
  --secret-id search_logger/segment_source_id \
  --profile "$AWS_CLI_PROFILE" \
  --output text \
  --query 'SecretString')

terraform "$@" -var "segment_source_id=$SEGMENT_SOURCE_ID"
