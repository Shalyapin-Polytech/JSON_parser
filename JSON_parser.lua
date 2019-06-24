local M, file = {}, {}
local char = ""

local function next_char()
    char = file:read(1)
    if char == nil then
        error("unexpected end of file")
    elseif char == " " then
        next_char()
    end
end

function parse_obj()
    local res
    next_char()
    if char == "{" then
        res = parse_table()
    elseif char == "[" then
        res = parse_array()
    elseif char == "\"" then
        res = parse_string()
    elseif string.match(char, "^%d$") then
        res = parse_number()
    else
        res = parse_keyword()
    end

    return res
end

function parse_table()
    local res = {}
    next_char()
--    if c ~= "{" then
--        error("invalid format")
--    end

    while char ~= "}" do
        local key = parse_string()
        next_char()
        if char ~= ":" then
            error("invalid format")
        end

        local val = parse_obj()

        next_char()
        if char ~= "}" and char ~= "," then
            error("unclosed table")
        elseif char == "," then
            next_char()
        end

        res[key] = val
    end

    return res
end

function parse_array()
    local res = {}
    next_char()
--    if c ~= "[" then
--        error("invalid format")
--    end

    local i = 1
    while char ~= "]" do
        local val = parse_string()

        next_char()
        if char ~= "]" and char ~= "," then
            error("unclosed array")
        elseif char == "," then
            next_char()
        end

        res[i] = val
        i = i + 1
    end

    return res
end

function parse_string()
    -- экранирование пока не поддерживается
    local res = ""

    if char ~= "\"" then
        error("invalid format")
    end
    next_char()

    while char ~= "\"" do
        res = res .. char
        next_char()
    end

    return res
end

function parse_number() end

function parse_keyword() end

function M.parse(file_name)
    file = io.open(file_name)

    local res = parse_obj()
    char = file:read(1)
    if char ~= nil then
        error("trash after main table found")
    end
    io.close(file)

    return res
end

return M