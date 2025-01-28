---@class UnitHealthCondition
UnitHealthCondition = {}
UnitHealthCondition.__index = UnitHealthCondition

---@return UnitHealthCondition
function UnitHealthCondition:New(name, unitID, operator, value, type)
    ---@class UnitHealthCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "UNIT_HEALTH"
    obj.unitID = unitID or "player"
    obj.operator = operator or ">"
    obj.value = value or 0
    obj.type = type or "percentage"
    obj.height = 20
    return obj
end

function UnitHealthCondition:GetDisplayName()
    if self.type == "percentage" then
        return self:GetUnitName() .. "\'s health is "..self.operator.." "..tostring(self.value) .. " percent"
    else
        return self:GetUnitName() .. "\'s health is "..self.operator.." "..tostring(self.value)
    end
end

function UnitHealthCondition:GetUnitName()
    if self.unitID == "player" then
        return "Player"
    elseif self.unitID == "boss1" then
        return "Boss"
    end
    return tostring(self.unitID)
end

---Serializes the UnitHealthCondition object into a format suitable for storage or transmission.
---@return table
function UnitHealthCondition:Serialize()
    local serialized = {
        type = "UNIT_HEALTH",
        unit = self.unitID
    }
    if self.type == "percentage" then
        if self.operator == "<" then
            serialized.pct_lt = self.value
        elseif self.operator == ">" then
            serialized.pct_gt = self.value
        end
    elseif self.type == "absolute" then
        if self.operator == "<" then
            serialized.lt = self.value
        elseif self.operator == ">" then
            serialized.gt = self.value
        end
    end
    return serialized
end

---@param rawCondition table
---@return UnitHealthCondition|nil
function UnitHealthCondition:Deserialize(rawCondition)
    if rawCondition.pct_gt then
        return UnitHealthCondition:New(rawCondition.type, rawCondition.unit, ">", rawCondition.pct_gt, "percentage")
    elseif rawCondition.pct_lt then
        return UnitHealthCondition:New(rawCondition.type, rawCondition.unit, "<", rawCondition.pct_lt, "percentage")
    elseif rawCondition.gt then
        return UnitHealthCondition:New(rawCondition.type, rawCondition.unit, ">", rawCondition.gt, "absolute")
    elseif rawCondition.lt then
        return UnitHealthCondition:New(rawCondition.type, rawCondition.unit, "<", rawCondition.lt, "absolute")
    else
        Log.info("[ERROR] Cannot deserialize! Condition's type is not supported", rawCondition)
        return nil
    end
end