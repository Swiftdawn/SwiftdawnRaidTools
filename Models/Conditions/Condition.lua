---@class Condition
Condition = {}
Condition.__index = Condition

---@return Condition
function Condition:New(type)
    ---@class Condition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.type = type
    return obj
end