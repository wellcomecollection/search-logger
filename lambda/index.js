"use-strict";
const { Client } = require("@elastic/elasticsearch");

let esClient;
function setEsClient(credentials) {
  esClient = new Client({
    node: credentials.url,
    auth: {
      username: credentials.username,
      password: credentials.password,
    },
  });
}

const AWS = require("aws-sdk");
const region = "eu-west-1";
const secretName = "prod/SearchLogger/es_details";
const secretsManager = new AWS.SecretsManager({
  region: region,
});

async function processEvent(event, context, callback) {
  const body = event.Records.map(function (record) {
    const payload = new Buffer(record.kinesis.data, "base64").toString("utf-8");
    try {
      const json = JSON.parse(payload);
      if (json.event === "conversion") {
        return parseConversion(json);
      } else {
        return parseSearch(json);
      }
    } catch (e) {
      console.error(e, payload);
      return;
    }
  })
    .filter(Boolean)
    .reduce(function (acc, tuple) {
      return acc.concat(tuple);
    }, []);

  // Get only uniques
  const services = body
    .map((b) => b.index && b.index._index)
    .filter(Boolean)
    .filter((service, i, arr) => arr.indexOf(service) === i)
    .join(", ");

  if (body.length > 0) {
    const { body: bulkResponse } = await esClient.bulk({ body: body });
    if (bulkResponse.errors) {
      console.log(
        "Error sending bulk to Elastic: ",
        JSON.stringify(bulkResponse, null, 2)
      );
    } else {
      console.log(
        `Success on services: ${services} with ${body.length / 2} records`
      );
    }
  }
}

function parseConversion(segmentEvent) {
  const {
    messageId,
    timestamp,
    anonymousId,
    properties: segmentProperties,
  } = segmentEvent;
  const esDoc = {
    "@timestamp": timestamp,
    anonymousId,
    type: segmentProperties.type,
    source: segmentProperties.source,
    page: segmentProperties.page,
    properties: segmentProperties.properties,
  };

  console.info(`Parsed conversion metric ${anonymousId}`);
  console.info(esDoc);
  return [
    {
      index: {
        _index: "conversion",
        _id: messageId,
      },
    },
    esDoc,
  ];
}

function parseSearch(json) {
  const validServices = [
    "search_relevance_implicit",
    "search_relevance_explicit",
  ];
  const network =
    json.context.ip === "195.143.129.132"
      ? "StaffCorporateDevices"
      : json.context.ip === "195.143.129.232"
      ? "Wellcome-WiFi"
      : null;

  // If we don't have a service, skip over it
  const service = json.properties.service;
  const validService = validServices.indexOf(service) !== -1;

  const esDoc = {
    event: json.event,
    anonymousId: json.anonymousId,
    timestamp: json.timestamp,
    network,
    toggles: json.properties.toggles,
    query: json.properties.query,
    data: json.properties.data,
  };

  if (validService) {
    console.info(`Creating record for valid service: ${service}`);
    return [
      {
        index: {
          _index: service,
          _id: json.messageId,
        },
      },
      esDoc,
    ];
  } else {
    console.error(
      `Error: Not creating record for invalid service: ${service}`,
      json
    );
    return [];
  }
}

exports.handler = function (event, context) {
  if (esClient) {
    processEvent(event, context);
  } else {
    secretsManager.getSecretValue(
      { SecretId: secretName },
      function (err, data) {
        if (err) {
          console.info("Secrets Manager error");
          console.error(err);
        } else {
          console.info("Secrets Manager success");
          try {
            const esCredentials = JSON.parse(data.SecretString);
            setEsClient(esCredentials);
            processEvent(event, context);
          } catch (e) {
            console.error(
              "Secrets Manager error: `SecretString` was not a valid JSON string"
            );
          }
        }
      }
    );
  }
};
