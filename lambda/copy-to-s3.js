const zipLocation = './search_logger_kinesis_to_es_lambda.zip'
const s3Bucket = 'search-logger'
const s3Key =  'lambdas/search_logger_kinesis_to_es_lambda.zip'
const roleArn = 'arn:aws:iam::130871440101:role/experience-admin'

const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3")
const { fromTemporaryCredentials } = require("@aws-sdk/credential-providers")
const fs = require("fs")

const s3Client = new S3Client({ 
  credentials: fromTemporaryCredentials({
    params: { RoleArn: roleArn }
  })
});

try {
  const data = fs.readFileSync(zipLocation)

  const command = new PutObjectCommand({
    Bucket: s3Bucket,
    Key: s3Key,
    Body: data,
    ACL: 'private',
    ContentType: 'application/zip'
  })

  s3Client.send(command, function(err, data) {
    if (err) console.log(err, err.stack)
    else console.log(`Finished uploading ${zipLocation} to s3://${s3Bucket}/${s3Key}`)
  })

} catch (e) {
  console.log('Error:', e.stack);
}