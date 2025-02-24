---@class SpellAuraTrigger
SpellAuraTrigger = {}
SpellAuraTrigger.__index = SpellAuraTrigger

---@return SpellAuraTrigger
function SpellAuraTrigger:New(name, spellID, source, target, delay, countdown, throttle)
    ---@class SpellAuraTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_AURA"
    obj.spellID = spellID or 0
    obj.source = source or ""
    obj.target = target or ""
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 30
    obj.conditions = {}
    return obj
end

function SpellAuraTrigger:GetDisplayName()
    if self.source ~= "" then
        if self.target ~= "" then
            return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "\' is activated by " .. self.source .. " on " .. self.target .. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
        else
            return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "\' is activated by " .. self.source .. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
        end
    elseif self.target ~= "" then
        return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "\' is activated on " .. self.target .. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
    else
        return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "' is activated" .. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
    end
end

---Serializes the SpellAuraTrigger object into a format suitable for storage or transmission.
---@return table
function SpellAuraTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "SPELL_AURA",
        spell_id = self.spellID,
        source = self.source,
        target = self.target
    }
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

---@param rawTrigger table
---@return SpellAuraTrigger
function SpellAuraTrigger:Deserialize(rawTrigger)
    return SpellAuraTrigger:New(rawTrigger.type, rawTrigger.spell_id, rawTrigger.source or nil, rawTrigger.target or nil, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end