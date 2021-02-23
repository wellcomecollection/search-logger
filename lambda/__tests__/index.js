const { conversion } = require("../__mocks__/conversion");
const { parseConversion } = require("../index");

it("replaces `.` in query field names with `_`", () => {
  const c = parseConversion(conversion);
  expect(c[1].page.query).toEqual({
    workType: ["a", "b"],
    page: 23,
    production_dates_from: "1980",
  });
});
