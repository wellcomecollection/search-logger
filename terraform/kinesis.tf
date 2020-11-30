resource "aws_kinesis_stream" "search_logger_stream" {
  name             = local.stream_name
  shard_count      = 1
  retention_period = 168

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = merge(local.default_tags, {
    Service = local.service_name
  })
}
