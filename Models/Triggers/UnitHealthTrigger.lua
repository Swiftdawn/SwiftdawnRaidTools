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
    if self.type == "percentage" then
        return self:GetUnitName() .. "'s health is "..self.operator.." "..tostring(self.value).." percent"..(self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
    elseif self.type == "absolute" then
        return self:GetUnitName() .. "'s health is "..self.operator.." "..tostring(self.value)..(self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
    end
end

function UnitHealthTrigger:GetUnitName()
    if self.unitID == "player" then
        return "Player"
    elseif self.unitID == "boss1" then
        return "Boss"
    end
    return tostring(self.unitID)
end

function UnitHealthTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "UNIT_HEALTH",
        unit = self.unitID
    }
    if self.type == "percentage" then
        if self.operator == ">" then
            serialized.pct_gt = self.value
        elseif self.operator == "<" then
            serialized.pct_lt = self.value
        end
    elseif self.type == "absolute" then
        if self.operator == ">" then
            serialized.gt = self.value
        elseif self.operator == "<" then
            serialized.lt = self.value
        end
    end
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

function UnitHealthTrigger:Deserialize(rawTrigger)
    if rawTrigger.pct_gt then
        return UnitHealthTrigger:New(rawTrigger.type, rawTrigger.unit, ">", rawTrigger.pct_gt, "percentage", rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
    elseif rawTrigger.pct_lt then
        return UnitHealthTrigger:New(rawTrigger.type, rawTrigger.unit, "<", rawTrigger.pct_lt, "percentage", rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
    elseif rawTrigger.gt then
        return UnitHealthTrigger:New(rawTrigger.type, rawTrigger.unit, ">", rawTrigger.gt, "absolute", rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
    elseif rawTrigger.lt then
        return UnitHealthTrigger:New(rawTrigger.type, rawTrigger.unit, "<", rawTrigger.lt, "absolute", rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
    end
end