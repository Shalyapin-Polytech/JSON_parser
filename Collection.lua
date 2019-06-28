typeof = type

Collection = {}

function Collection.implement(type)
    local class = {
        type = type,

        __newindex = function (self, k, v)
            local expected_type, actual_type = type, typeof(k)
            assert(
                actual_type == expected_type,
                "incorrect type of key: expected " ..
                    tostring(expected_type) ..
                    ", but got " ..
                    tostring(actual_type)
            )
            
            rawset(self, k, v)
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
        __call = function (self, tbl)
            return setmetatable(tbl, class)
        end
    }

    return setmetatable(class, constructor)
end

return Collection