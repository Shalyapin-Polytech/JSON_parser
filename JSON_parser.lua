local M, file = {}, {}
local char = ""

local function next_char(cfg)
    local check_eof, leave_spaces = cfg.check_eof, cfg.leave_spaces
    char = file:read(1)
    if check_eof and char == nil then
        error("unexpected end of file")
    elseif not leave_spaces and string.match(char or "", "^%s$") then
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
    local res = {}

    if char ~= "{" then
        error("table expected, but found" .. char)
    end

    next_char{check_eof = true}
    while char ~= "}" do
        local key = parse_string()
        if char ~= ":" then
            error("invalid format")
        end

        next_char{check_eof = true}
        local val = parse_obj()

        if char ~= "}" and char ~= "," then
            error("unclosed table")
        elseif char == "," then
            next_char{check_eof = true}
        end

        res[key] = val
    end

    next_char{check_eof = false}
    return res
end

function parse_array()
    local res = {}

    if char ~= "[" then
        error("array expected, but found" .. char)
    end

    next_char{check_eof = true}
    while char ~= "]" do
        local val = parse_string()

        if char ~= "]" and char ~= "," then
            error("unclosed array")
        elseif char == "," then
            next_char{check_eof = true}
        end

        res[#res + 1] = val
    end

    next_char{check_eof = false}
    return res
end

function parse_string()
    local res = ""

    if char ~= "\"" then
        error("string expected, but found" .. char)
    end

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
                -- unicode
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
    while string.match(char, "^[%d%+%-%.Ee]$") do
        element = element .. char
        next_char{check_eof = true}
    end

    return tonumber(element)
end

function parse_keyword()
    local element = ""
    while string.match(char, "^[a-z]$") do
        element = element .. char
        next_char{check_eof = true}
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

    next_char{check_eof = true}
    local res = parse_table()
    if char ~= nil then
        error("trash after main table found")
    end

    io.close(file)
    return res
end

return M