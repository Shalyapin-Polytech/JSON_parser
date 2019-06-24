local M, file = {}, {}
local char = ""

local function next_char(check_eof, leave_spaces)
    char = file:read(1)
    if check_eof and char == nil then
        error("unexpected end of file")
    elseif not leave_spaces and char == " " then
        next_char(check_eof)
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
    local res = {}

    if char ~= "{" then
        error("table expected, but found" .. char)
    end

    next_char(true)
    while char ~= "}" do
        local key = parse_string()
        if char ~= ":" then
            error("invalid format")
        end

        next_char(true)
        local val = parse_obj()

        if char ~= "}" and char ~= "," then
            error("unclosed table")
        elseif char == "," then
            next_char(true)
        end

        res[key] = val
    end

    next_char(false)
    return res
end

function parse_array()
    local res = {}
    if char ~= "[" then
        error("array expected, but found" .. char)
    end

    next_char(true)
    local i = 1
    while char ~= "]" do
        local val = parse_string()

        if char ~= "]" and char ~= "," then
            error("unclosed array")
        elseif char == "," then
            next_char(true)
        end

        res[i] = val
        i = i + 1
    end

    next_char(false)
    return res
end

function parse_string()
    -- экранирование пока не поддерживается
    local res = ""

    if char ~= "\"" then
        error("invalid format")
    end

    next_char(true)
    while char ~= "\"" do
        res = res .. char
        next_char(true, true)
    end

    next_char(false)
    return res
end

function parse_number()
    local element = ""
    while string.match(char, "^[%d%+%-%.Ee]$") do
        element = element .. char
        next_char(true)
    end

    return tonumber(element)
end

function parse_keyword()
    local element = ""
    while string.match(char, "^[a-z]$") do
        element = element .. char
        next_char(true)
    end

    if element == "true" then
        return true
    elseif element == "false" then
        return false
    elseif element == "null" then
        return nil
    else
        error("unexpected element")
    end
end

function M.parse(file_name)
    file = io.open(file_name)

    next_char(true)
    local res = parse_table()
    if char ~= nil then
        error("trash after main table found")
    end
    io.close(file)

    return res
end

return M