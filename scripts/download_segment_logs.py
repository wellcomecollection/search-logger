import boto3
from tempfile import TemporaryFile
from io import BytesIO
import gzip
import shutil
from pathlib import Path


def download_gzipped(bucket, key, fp, compressed_fp=None):
    """Download and uncompress contents from S3 to fp.
    If compressed_fp is None, the compression is performed in memory.
    """
    if not compressed_fp:
        compressed_fp = BytesIO()
    bucket.download_fileobj(key, compressed_fp)
    compressed_fp.seek(0)
    with gzip.GzipFile(fileobj=compressed_fp, mode='rb') as gz:
        shutil.copyfileobj(gz, fp)

def s3_list_keys(bucket_name, prefix):
    client = boto3.client('s3')
    keys = []
    kwargs = {'Bucket': bucket_name, 'Prefix': prefix}
    while True:
        resp = client.list_objects_v2(**kwargs)
        for obj in resp['Contents']:
            keys.append(obj['Key'])
        try:
            kwargs['ContinuationToken'] = resp['NextContinuationToken']
        except KeyError:
            break
    return keys

bucket_name = 'weco-search-logs'
prefix = 'segment-logs/0eSboRrIxe'
keys = s3_list_keys(bucket_name, prefix)

resource = boto3.resource('s3')
bucket = resource.Bucket(bucket_name)
for key in keys:
    file = '../.data/{}'.format(key.split('/')[-1])
    with open(file, 'wb') as fp:
        download_gzipped(bucket, key, fp)
