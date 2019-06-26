local JSON_parser = require("JSON_parser")
local asserts = require("tests.core")

local expected = {
    ["first"] = 1,
    ["second"] = {"2 a", "2 b"},
    ["bool"] = nil,
    ["number"] = -12.64E-8,
    ["empty_table"] = {},
    ["empty_array"] = {}
}
local result = JSON_parser.parse("tests/test.json")

asserts.assert_tables_equals(expected, result)
