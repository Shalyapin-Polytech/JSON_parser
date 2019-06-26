local M = {}

function mismatch_error(expected, actual)
    error("expected \"" .. expected or "nil" .. "\", but got \"" .. actual or "nil" .."\"")
end

function M.assert_equals(expected, actual)
    if expected ~= actual then
        mismatch_error(expected, actual)
    end
end

function M.assert_tables_equals(expected, actual)
    if #expected ~= #actual then
        mismatch_error(#expected, #actual)
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

