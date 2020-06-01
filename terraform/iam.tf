data "aws_iam_policy_document" "search_logger_write_policy" {
  statement {
    effect    = "Allow"
    actions   = ["kinesis:PutRecord"]
    resources = ["arn:aws:kinesis:eu-west-1:${local.webplatform_account_id}:stream/${local.stream_name}"]
  }
}

resource "aws_iam_policy" "search_logger_kinesis_write_policy" {
  name        = "${local.stream_name}WriteAccess"
  description = "Allows write access to the kinesis stream holding segment logs."
  policy      = data.aws_iam_policy_document.search_logger_write_policy.json
}

data "aws_iam_policy_document" "search_logger_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.segment_source_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.segment_account_id}:root"]
    }
  }
}

resource "aws_iam_role" "search_logger_write_role" {
  name               = "${local.stream_name}Role"
  assume_role_policy = data.aws_iam_policy_document.search_logger_assume_role_policy.json

  tags = merge(local.default_tags, {
    Service = local.service_name
  })
}

resource "aws_iam_role_policy_attachment" "search_logger_role_attachment" {
  role       = aws_iam_role.search_logger_write_role.name
  policy_arn = aws_iam_policy.search_logger_kinesis_write_policy.arn
}

output "aws_iam_role_search_logger_write_role_arn" {
  value = aws_iam_role.search_logger_write_role.arn
}
