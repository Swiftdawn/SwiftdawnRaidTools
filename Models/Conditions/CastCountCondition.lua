---@class CastCountCondition
CastCountCondition = {}
CastCountCondition.__index = CastCountCondition

---@return CastCountCondition
function CastCountCondition:New(name, spellID, source, target, operator, count)
    ---@class CastCountCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_CAST_COUNT"
    obj.spellID = spellID or 0
    obj.source = source or ""
    obj.target = target or ""
    obj.operator = operator or ">"
    obj.count = count or 0
    obj.height = 20
    return obj
end

function CastCountCondition:GetDisplayName()
    local spellName = C_Spell.GetSpellName(self.spellID)
    if self.source ~= "" then
        if self.target ~= "" then
            return self.source .. " casts " .. (spellName or "Spell not found") .. " " .. self.operator .. " " .. self.count .. " times on " .. self.target
        else
            return self.source .. " casts " .. (spellName or "Spell not found") .. " " .. self.operator .. " " .. self.count .. " times"
        end
    else
        if self.target ~= "" then
            return (spellName or "Spell not found") .. " is cast " .. self.operator .. " " .. self.count .. " times on " .. self.target
        else
            return (spellName or "Spell not found") .. " is cast " .. self.operator .. " " .. self.count .. " times"
        end
    end
end

---Serializes the CastCountCondition object into a format suitable for storage or transmission.
---@return table
function CastCountCondition:Serialize()
    local serialized = {
        type = "SPELL_CAST_COUNT",
        spell_id = self.spellID,
        source = self.source,
        target = self.target
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
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, ">", rawCondition.gt)
    elseif rawCondition.lt then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, "<", rawCondition.lt)
    elseif rawCondition.eq then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, "==", rawCondition.eq)
    else
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, ">", 0)
    end
end