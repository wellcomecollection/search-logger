const fs = require("fs");
const AWS = require("aws-sdk");
const sts = new AWS.STS();

sts.assumeRole(
  {
    RoleArn: "arn:aws:iam::130871440101:role/experience-admin",
    RoleSessionName: "SearchLoggerCopytoS3",
  },
  (err, data) => {
    if (err) {
      console.error("Cannot assumeRole");
      console.log(err);
    } else {
      AWS.config.update({
        accessKeyId: data.Credentials.AccessKeyId,
        secretAccessKey: data.Credentials.SecretAccessKey,
        sessionToken: data.Credentials.SessionToken,
      });
      const s3 = new AWS.S3();

      fs.readFile(
        "./search_logger_kinesis_to_es_lambda.zip",
        (err, fileData) => {
          if (err) {
            console.error("Cannot read file");
            console.info(err);
          } else {
            s3.putObject(
              {
                Bucket: "search-logger",
                Key: "lambdas/search_logger_kinesis_to_es_lambda.zip",
                Body: fileData,
              },
              (err, data) => {
                if (err) {
                  console.error("Cannot putObject");
                } else {
                  console.info("done");
                }
              }
            );
          }
        }
      );
    }
  }
);
