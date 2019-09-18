local M, file = {}, {}
local Collection = require("Collection")
local Array = Collection.implement("number")
local Map = Collection.implement("string")
local char = ""

local function next_char(cfg)
    local check_eof, leave_spaces = cfg.check_eof, cfg.leave_spaces
    char = file:read(1)
    assert(not check_eof or char, "unexpected end of file")
    
    if not leave_spaces and char and char:match("^%s$") then
        next_char{check_eof = check_eof}
    end
end

function parse_obj()
    if char == "{" then
        return parse_table()
    elseif char == "[" then
        return parse_array()
    elseif char == "\"" then
        return parse_string()
    elseif char:match("^[%d%-]$") then
        return parse_number()
    else
        return parse_keyword()
    end
end

function parse_table()
    local res = Map{}
    assert(char == "{", "table expected, but found " .. tostring(char))

    next_char{check_eof = true}
    while char ~= "}" do
        local key = parse_string()
        assert(not res[key], "key must be unique")
        assert(char == ":", "expected :, but got " .. tostring(char))

        next_char{check_eof = true}
        local val = parse_obj()

        assert(char == "}" or char == ",", "unclosed table")
        if char == "," then
            next_char{check_eof = true}
            assert(char ~= "}", "trailing comma is not supported")
        end

        res[key] = val
    end

    next_char{check_eof = false}
    return res
end

function parse_array()
    local res = Array{}
    assert(char == "[", "array expected, but found " .. tostring(char))

    next_char{check_eof = true}
    while char ~= "]" do
        local val = parse_obj()

        assert(char == "]" or char == ",", "unclosed array")
        if char == "," then
            next_char{check_eof = true}
            assert(char ~= "]", "trailing comma is not supported")
        end

        res[#res + 1] = val
    end

    next_char{check_eof = false}
    return res
end

function parse_string()
    local res = ""
    assert(char == "\"", "string expected, but found " .. tostring(char))

    next_char{check_eof = true}
    while char ~= "\"" do
        if char == "\\" then
            next_char{check_eof = true, leave_spaces = true}
            assert(char:match("^[\"\\/bfnrtu]$"), "illegal escape sequence")
            
            if char == "b" then
                res = res .. "\b"
            elseif char == "f" then
                res = res .. "\f"
            elseif char == "n" then
                res = res .. "\n"
            elseif char == "r" then
                res = res .. "\r"
            elseif char == "t" then
                res = res .. "\t"
            elseif char == "u" then
                local utf8_char = ""
                for i = 1, 4 do
                    next_char{check_eof = true, leave_spaces = true}
                    utf8_char = utf8_char .. char
                end
                
                assert(
                    utf8_char:match("^" .. ("[0-9A-Fa-f]"):rep(4) .. "$"), 
                    "incorrect UTF-8 character code: " .. utf8_char
                )
                res = res .. utf8.char(tonumber("0x" .. utf8_char))
            else
                res = res .. char
            end
        else
            res = res .. char
        end
        next_char{check_eof = true, leave_spaces = true}
    end

    next_char{check_eof = false}
    return res
end

function parse_number()
    local res = ""
    while char and char:match("^[%d%+%-%.Ee]$") do
        res = res .. char
        next_char{check_eof = false}
    end
    
    res = tonumber(res)
    assert(res, "incorrect format of number")
    
    return res
end

function parse_keyword()
    local element = ""
    while char and char:match("^[a-z]$") do
        element = element .. char
        next_char{check_eof = false}
    end

    if element == "true" then
        return true
    elseif element == "false" then
        return false
    elseif element == "null" then
        return nil
    else
        error("unexpected element: " .. element)
    end
end

function M.parse(file_name)
    file = io.open(file_name)

    next_char{check_eof = true}
    local res = parse_obj()
    assert(char == nil, "trash after main table found")

    file:close()
    return res
end

return M
