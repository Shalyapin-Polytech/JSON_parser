local JSON_parser = require("JSON_parser")
local result = JSON_parser.parse("tests/test.json")

print(result["first"])
print(result["second"][2])
print(#result["empty_array"])
