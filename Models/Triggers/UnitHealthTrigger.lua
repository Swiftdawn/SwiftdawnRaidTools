---@class UnitHealthTrigger
UnitHealthTrigger = {}
UnitHealthTrigger.__index = UnitHealthTrigger

---@return UnitHealthTrigger
function UnitHealthTrigger:New(name, unitID, operator, value, type)
    ---@class UnitHealthTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.unitID = unitID
    obj.operator = operator
    obj.value = value
    obj.type = type
    obj.conditions = {}
    return obj
end

function UnitHealthTrigger:GetDisplayName()
    return tostring(self.unitID) .. "'s health "..self.type.." "..self.operator.." "..tostring(self.value)
end