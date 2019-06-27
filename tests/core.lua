local M = {}

function mismatch_error(expected, actual)
    error("expected " .. tostring(expected) .. ", but got " .. tostring(actual))
end

function M.assert_equals(expected, actual)
    if expected ~= actual then
        mismatch_error(expected, actual)
    end
end

function M.assert_tables_equals(expected, actual)
    local expected_type, actual_type = getmetatable(expected).type, getmetatable(actual).type
    local expected_size, actual_size = #expected, #actual
    if expected_type ~= actual_type then
        mismatch_error(expected_type,  actual_type)
    elseif expected_size ~= actual_size then
        mismatch_error(expected_size, actual_size)
    end
    for k, v in pairs(expected) do
        if type(v) == "table" then
            M.assert_tables_equals(v, actual[k])
        else
            M.assert_equals(v, actual[k])
        end
    end
end

return M

