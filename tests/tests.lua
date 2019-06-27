local parse = require("JSON_parser").parse
local asserts = require("tests.core")
local Collection = require("Collection")
local Array = Collection.implement("number")
local Map = Collection.implement("string")

local tests = {
    test_normal1 = function () 
        local expected = Map{
            ["first"] = 1,
            ["second"] = Array{"2 a", "2 b"},
            ["bool"] = nil,
            ["number"] = -1e+055,
            ["empty_table"] = Map{},
            ["empty_array"] = Array{}
        }
        local result = parse("tests/test_normal1.json")

        asserts.assert_tables_equals(expected, result)
    end,
    
    test_normal2 = function () 
        local expected = Map{
            ["t1"] = Array{
                Map{
                    ["k1"] = "v1",
                    ["k2"] = "v2",
                    ["k3"] = "v3"
                },
                Map{
                    ["k1"] = "v1",
                    ["k2"] = "v2"
                },
                Map{
                    ["k1"] = "v1"
                },
                Map{},
                Array{"word"},
            },
            ["t2"] = Array{
                Map{
                    ["t3"] = Map{
                        ["arr1"] = Array{"e1"}, 
                        ["arr2"] = Array{}
                    }
                }
            }
        }
        local result = parse("tests/test_normal2.json")

        asserts.assert_tables_equals(expected, result)
    end,
    
    test_normal3 = function ()
        local expected = Array{true, false, nil}
        local result = parse("tests/test_normal3.json")
        
        asserts.assert_tables_equals(expected, result)
    end,
    
    test_empty_table = function ()
        local result = parse("tests/test_empty_table.json")
        asserts.assert_tables_equals(Map{}, result)
    end,
    
    test_alone_str = function ()
        local result = parse("tests/test_alone_str.json")
        asserts.assert_equals("test", result)
    end,
    
    test_alone_num = function ()
        local result = parse("tests/test_alone_num.json")
        asserts.assert_equals(111, result)
    end,
    
    test_escape_characters = function ()
        local result = parse("tests/test_escape_characters.json")
        asserts.assert_equals("a\bcde\fghijklm\nopq\rs\tvwxyz\\\"/", result)
    end,
    
    test_correct_utf8 = function ()
        local result = parse("tests/test_correct_utf8.json")
        asserts.assert_equals(utf8.char(0x0000, 0x024D, 0x2124, 0x0A00), result)
    end,
    
    test_incorrect_utf8 = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_utf8.json") end
        )
    end,
        
    test_unclosed_table = function ()
        asserts.assert_thrown(
            function () parse("tests/test_unclosed_table.json") end
        )
    end,
    
    test_unclosed_array = function ()
        asserts.assert_thrown(
            function () parse("tests/test_unclosed_array.json") end
        )
    end,
    
    test_incorrect_key = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_key.json") end
        )
    end,
    
    test_unexpected_element = function ()
        asserts.assert_thrown(
            function () parse("tests/test_unexpected_element.json") end
        )
    end,
    
    test_trash_after_table = function ()
        asserts.assert_thrown(
            function () parse("tests/test_trash_after_table.json") end
        )
    end,
    
    test_trailing_comma = function ()
        asserts.assert_thrown(
            function () parse("tests/test_trailing_comma.json") end
        )
    end,
    
    test_opening_comma = function ()
        asserts.assert_thrown(
            function () parse("tests/test_opening_comma.json") end
        )
    end
}

local not_passed_list = {}

for k, f in pairs(tests) do
    if not pcall(f) then
        not_passed_list[#not_passed_list + 1] = tostring(k)
    end
end

if (#not_passed_list > 0) then
    print(#not_passed_list .. " tests not passed:")
    print(table.concat(not_passed_list, "\n"))
else
    print("all tests passed")
end