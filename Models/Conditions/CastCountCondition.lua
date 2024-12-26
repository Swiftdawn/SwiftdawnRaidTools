---@class CastCountCondition
CastCountCondition = {}
CastCountCondition.__index = CastCountCondition

---@return CastCountCondition
function CastCountCondition:New(name, spellID, operator, count)
    ---@class CastCountCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.operator = operator
    obj.count = count
    obj.height = 20
    obj.conditions = {}
    return obj
end

function CastCountCondition:GetDisplayName()
    return "\'"..GetSpellInfo(self.spellID) .. "\' is cast "..self.operator.." " .. self.count .. " times"
end

---Serializes the CastCountCondition object into a format suitable for storage or transmission.
---@return table
function CastCountCondition:Serialize()
    local serialized = {
        type = "SPELL_CAST_COUNT",
        spell_id = self.spellID
    }
    if self.operator == "==" then
        serialized.eq = self.count
    elseif self.operator == "<" then
        serialized.lt = self.count
    elseif self.operator == ">" then
        serialized.gt = self.count
    end
    return serialized
end

---@param rawCondition table
---@return CastCountCondition
function CastCountCondition:Deserialize(rawCondition)
    if rawCondition.gt then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, ">", rawCondition.gt)
    elseif rawCondition.lt then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, "<", rawCondition.lt)
    elseif rawCondition.eq then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, "=", rawCondition.eq)
    else
        Log.info("[ERROR] Cannot deserialize! Condition's type is not supported", rawCondition)
        return nil
    end
end