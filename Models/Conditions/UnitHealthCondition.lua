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
    return self:GetUnitName() .. "'s health "..self.type.." "..self.operator.." "..tostring(self.value)
end

function UnitHealthCondition:GetUnitName()
    if self.unitID == "player" then
        return "Player"
    elseif self.unitID == "boss1" then
        return "Boss"
    end
    return tostring(self.unitID)
end