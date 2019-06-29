local parse = require("JSON_parser").parse
local asserts = require("tests.core").asserts
local do_tests =  require("tests.core").tests.do_tests
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
    
    test_collection_type = function ()
        local result = parse("tests/test_normal1.json")
        
        asserts.assert_equals("string", result.get_type())
        asserts.assert_equals("number", result["second"].get_type())
    end,
    
    test_collection_size = function ()
        local result = parse("tests/test_normal2.json")
        
        asserts.assert_equals(2, #result)
        asserts.assert_equals(5, #result["t1"])
    end,
    
    test_type_filter = function ()
        local result = parse("tests/test_normal2.json")
        
        asserts.assert_thrown(
            function() result[1] = "bar" end
        )
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
        asserts.assert_equals("\b\f\n\r\t\\\"/", result)
    end,
    
    test_illegal_escape_characters = function ()
        asserts.assert_thrown(
            function () parse("tests/test_illegal_escape_characters.json") end
        )
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
    
    test_repeating_key = function ()
        asserts.assert_thrown(
            function () parse("tests/test_repeating_key.json") end
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
    end,
    
    test_hex_number = function ()
        asserts.assert_thrown(
            function () parse("tests/test_hex_number.json") end
        )
    end,
    
    test_exp = function ()
        asserts.assert_tables_equals(
            parse("tests/test_exp.json"),
            Array{0E0, 0e+1, 0e-0, 0e+0, 123e-589}
        )
    end,
    
    test_incorrect_exp1 = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_exp1.json") end
        )
    end,
    
    test_incorrect_exp2 = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_exp2.json") end
        )
    end,
    
    test_incorrect_exp3 = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_exp3.json") end
        )
    end,
    
    test_incorrect_exp4 = function ()
        asserts.assert_thrown(
            function () parse("tests/test_incorrect_exp4.json") end
        )
    end, 
    
    test_null = function ()
        asserts.assert_equals(2, #parse("tests/test_null.json"))
    end
}

do_tests(tests)