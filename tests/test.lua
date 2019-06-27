local JSON_parser = require("JSON_parser")
local asserts = require("tests.core")
local Collection = require("Collection")
local Array = Collection.implement("number")
local Map = Collection.implement("string")

local expected = Map{
    ["first"] = 1,
    ["second"] = Array{"2 a", "2 " .. utf8.char(0x024D) .."b"},
    ["bool"] = nil,
    ["number"] = -12.64E-8,
    ["empty_table"] = Map{},
    ["empty_array"] = Array{}
}
local result = JSON_parser.parse("tests/test.json")

asserts.assert_tables_equals(expected, result)

print("all tests passed")