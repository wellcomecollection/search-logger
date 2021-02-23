const conversion = {
  messageId: "123-456-789",
  timestamp: "2020-01-01",
  anonymousId: "5a86b515-3dd7-4807-891d-4111f284db71",
  properties: {
    session: {
      id: "b06f1c88-29f2-42f8-8c70-5ce4cc86fdc1",
      timeout: 1800000,
    },
    type: "pageview",
    source: "unknown",
    page: {
      name: "works",
      path: "/works",
      pathname: "/works",
      query: {
        workType: ["a", "b"],
        page: 23,
        "production.dates.from": "1980",
      },
    },
    properties: {
      totalResults: 1028,
    },
  },
};

module.exports = { conversion };
