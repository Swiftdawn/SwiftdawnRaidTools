---@class UnitHealthTrigger
UnitHealthTrigger = {}
UnitHealthTrigger.__index = UnitHealthTrigger

---@return UnitHealthTrigger
function UnitHealthTrigger:New(name, unitID, operator, value, type, delay, countdown, throttle)
    ---@class UnitHealthTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.unitID = unitID
    obj.operator = operator
    obj.value = value
    obj.type = type
    obj.delay = delay
    obj.countdown = countdown
    obj.throttle = throttle
    obj.height = 20
    obj.conditions = {}
    return obj
end

function UnitHealthTrigger:GetDisplayName()
    return self:GetUnitName() .. "'s health "..self.type.." "..self.operator.." "..tostring(self.value).. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
end

function UnitHealthTrigger:GetUnitName()
    if self.unitID == "player" then
        return "Player"
    elseif self.unitID == "boss1" then
        return "Boss"
    end
    return tostring(self.unitID)
end