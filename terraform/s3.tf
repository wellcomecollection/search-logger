resource "aws_s3_bucket" "search-logger" {
  bucket = "search-logger"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Service = "${local.service_name}"
  }
}
