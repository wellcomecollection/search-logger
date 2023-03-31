resource "aws_s3_bucket" "search-logger" {
  bucket = "search-logger"

  tags = {
    Service = local.service_name
  }
}

resource "aws_s3_bucket_acl" "search-logger" {
  bucket = aws_s3_bucket.search-logger.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "search-logger" {
  bucket = aws_s3_bucket.search-logger.id

  versioning_configuration {
    status = "Enabled"
  }
}
