local M, file = {}, {}
local Collection = require("Collection")
local Array = Collection.implement("number")
local Map = Collection.implement("string")
local char = ""

local function next_char(cfg)
    local check_eof, leave_spaces = cfg.check_eof, cfg.leave_spaces
    char = file:read(1)
    assert(not check_eof or char ~= nil, "unexpected end of file")
    if not leave_spaces and string.match(char or "", "^%s$") then
        next_char{check_eof = check_eof}
    end
end

function parse_obj()
    local res
    if char == "{" then
        res = parse_table()
    elseif char == "[" then
        res = parse_array()
    elseif char == "\"" then
        res = parse_string()
    elseif string.match(char, "^[%d%-]$") then
        res = parse_number()
    else
        res = parse_keyword()
    end

    return res
end

function parse_table()
    local res = Map{}

    assert(char == "{", "table expected, but found " .. tostring(char))

    next_char{check_eof = true}
    while char ~= "}" do
        local key = parse_string()
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
                    string.match(utf8_char, "^" .. ("[0-9A-Fa-f]"):rep(4) .. "$"), 
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
    local element = ""
    while string.match(char or "", "^[%d%+%-%.Ee]$") do
        element = element .. char
        next_char{check_eof = false}
    end

    return tonumber(element)
end

function parse_keyword()
    local element = ""
    while string.match(char or "", "^[a-z]$") do
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

    io.close(file)
    return res
end

return M