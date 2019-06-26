typeof = type

Collection = {}

function Collection.implement(type)
    local class = {
        type = type,

        __newindex = function (self, k, v)
            local expected_type, actual_type = type, typeof(k)
            if actual_type == expected_type then
                rawset(self, k, v)
            else
                error("incorrect type of key: expected " .. expected_type .. ", but got " .. actual_type)
            end
        end,

        __len = function (self)
            local res = 0
            for k, _ in pairs(self) do
                if typeof(k) == type then
                    res = res + 1
                end
            end

            return res
        end
    }

    local constructor = {
        __call = function ()
            return setmetatable({}, class)
        end
    }

    return setmetatable(class, constructor)
end

return Collection