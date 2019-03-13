const elasticsearch = require('elasticsearch');
const client = new elasticsearch.Client({
  host: process.env.ES_URL,
  httpAuth: `${process.env.ES_USERNAME}:${process.env.ES_PASSWORD}`
});

exports.handler = function(event, context) {
  console.log('Record count: ' + event.Records.length);

  const body = event.Records.map(function(record) {
    const payload = new Buffer(record.kinesis.data, 'base64').toString('ascii');
    try {
      // We stringify the payload to remove unicode etc
      const json = JSON.parse(JSON.stringify(payload));
      return [
        {
          index: {
            _index: 'search_logs',
            _type: 'search_log',
            _id: payload.messageId
          }
        },
        json
      ];
    } catch (e) {
      console.error(e, payload);
      return;
    }
  })
    .filter(Boolean)
    .reduce(function(acc, tuple) {
      return acc.concat(tuple);
    }, []);

  client.bulk({ body: body }, function(err, resp) {
    if (err) console.error(err);
    else console.log('Success!');
  });
};
