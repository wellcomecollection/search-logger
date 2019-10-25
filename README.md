# search-logger

Accepts data from [Segment](https://segment.com/) via [Kinesis](https://segment.com/docs/destinations/amazon-kinesis/). 

The kinesis stream triggers a lambda which writes into the ElasticCloud hosted [Reporting ES cluster](https://reporting.wellcomecollection.org).

This is provisioned in the Experience AWS account.
