local asserts, tests = {}, {}

function asserts.assert_equals(expected, actual)
    assert(expected == actual, "expected " .. tostring(expected) .. ", but got " .. tostring(actual))
end

function asserts.assert_tables_equals(expected, actual)
    asserts.assert_equals(getmetatable(expected).type, getmetatable(actual).type)
    asserts.assert_equals(#expected, #actual)
    for k, v in pairs(expected) do
        if type(v) == "table" then
            asserts.assert_tables_equals(v, actual[k])
        else
            asserts.assert_equals(v, actual[k])
        end
    end
end

function asserts.assert_thrown(f)
    assert(not pcall(f), "expected error")
end

function tests.do_tests(tests)
    local not_passed_list = {}

    for k, f in pairs(tests) do
        local passed, message = pcall(f)
        if not passed then
            not_passed_list[#not_passed_list + 1] = "\"" .. tostring(k) .. "\" with message " .. message
        end
    end

    if (#not_passed_list > 0) then
        print(#not_passed_list .. " tests not passed:")
        print(table.concat(not_passed_list, "\n"))
    else
        print("all tests passed")
    end
end

return {asserts = asserts, tests = tests}

