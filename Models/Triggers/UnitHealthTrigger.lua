---@class UnitHealthTrigger
UnitHealthTrigger = {}
UnitHealthTrigger.__index = UnitHealthTrigger

---@return UnitHealthTrigger
function UnitHealthTrigger:New(name, unitID, operator, value)
    ---@class UnitHealthTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.unitID = unitID
    obj.operator = operator
    obj.value = value
    obj.conditions = {}
    return obj
end

function UnitHealthTrigger:GetDisplayName()
    return "Unit Health: \"" .. tostring(self.unitID) .. "\" "..self.operator.." "..tostring(self.value)
end