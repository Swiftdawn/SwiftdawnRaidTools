---@class UnitHealthCondition
UnitHealthCondition = {}
UnitHealthCondition.__index = UnitHealthCondition

---@return UnitHealthCondition
function UnitHealthCondition:New(name, unitID, operator, value, type)
    ---@class UnitHealthCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.unitID = unitID
    obj.operator = operator
    obj.value = value
    obj.type = type
    obj.height = 20
    obj.conditions = {}
    return obj
end

function UnitHealthCondition:GetDisplayName()
    return tostring(self.unitID) .. "'s health "..self.type.." "..self.operator.." "..tostring(self.value)
end