---@class CastCountCondition
CastCountCondition = {}
CastCountCondition.__index = CastCountCondition

---@return CastCountCondition
function CastCountCondition:New(name, spellID, operator, count)
    ---@class CastCountCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_CAST_COUNT"
    obj.spellID = spellID or 0
    obj.operator = operator or ">"
    obj.count = count or 0
    obj.height = 20
    return obj
end

function CastCountCondition:GetDisplayName()
    return "\'".. (GetSpellInfo(self.spellID) or "Spell not found") .. "\' is cast "..self.operator.." " .. self.count .. " times"
end

---Serializes the CastCountCondition object into a format suitable for storage or transmission.
---@return table
function CastCountCondition:Serialize()
    local serialized = {
        type = "SPELL_CAST_COUNT",
        spell_id = self.spellID
    }
    if self.operator == "==" or self.operator == "=" then
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
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, "==", rawCondition.eq)
    else
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, ">", 0)
    end
end