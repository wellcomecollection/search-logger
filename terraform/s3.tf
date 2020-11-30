resource "aws_s3_bucket" "search-logger" {
  bucket = "search-logger"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge(local.default_tags, {
    Service = local.service_name
  })
}
