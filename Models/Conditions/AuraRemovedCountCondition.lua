---@class AuraRemovedCountCondition
AuraRemovedCountCondition = {}
AuraRemovedCountCondition.__index = AuraRemovedCountCondition

---@return AuraRemovedCountCondition
function AuraRemovedCountCondition:New(name, spellID, source, target, operator, count)
    ---@class AuraRemovedCountCondition
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

function AuraRemovedCountCondition:GetDisplayName()
    if self.source ~= "" then
        if self.target ~= "" then
            return self.source .. " removed " .. (GetSpellInfo(self.spellID) or "Spell not found") .. " " .. self.operator .. " " .. self.count .. " times on " .. self.target
        else
            return self.source .. " removed " .. (GetSpellInfo(self.spellID) or "Spell not found") .. " " .. self.operator .. " " .. self.count .. " times"
        end
    else
        if self.target ~= "" then
            return (GetSpellInfo(self.spellID) or "Spell not found") .. " is removed " .. self.operator .. " " .. self.count .. " times on " .. self.target
        else
            return (GetSpellInfo(self.spellID) or "Spell not found") .. " is removed " .. self.operator .. " " .. self.count .. " times"
        end
    end
end

---Serializes the AuraRemovedCountCondition object into a format suitable for storage or transmission.
---@return table
function AuraRemovedCountCondition:Serialize()
    local serialized = {
        type = "AURA_REMOVED_COUNT",
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
---@return AuraRemovedCountCondition
function AuraRemovedCountCondition:Deserialize(rawCondition)
    if rawCondition.gt then
        return AuraRemovedCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, ">", rawCondition.gt)
    elseif rawCondition.lt then
        return AuraRemovedCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, "<", rawCondition.lt)
    elseif rawCondition.eq then
        return AuraRemovedCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, "==", rawCondition.eq)
    else
        return AuraRemovedCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.source or nil, rawCondition.target or nil, ">", 0)
    end
end