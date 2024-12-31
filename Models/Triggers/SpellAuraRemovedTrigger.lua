---@class SpellAuraRemovedTrigger
SpellAuraRemovedTrigger = {}
SpellAuraRemovedTrigger.__index = SpellAuraRemovedTrigger

---@return SpellAuraRemovedTrigger
function SpellAuraRemovedTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellAuraRemovedTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_AURA_REMOVED"
    obj.spellID = spellID or 0
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 30
    obj.conditions = {}
    return obj
end

function SpellAuraRemovedTrigger:GetDisplayName()
    return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "' is removed".. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
end

---Serializes the SpellAuraRemovedTrigger object into a format suitable for storage or transmission.
---@return table
function SpellAuraRemovedTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "SPELL_AURA_REMOVED",
        spell_id = self.spellID,
        delay = self.delay,
        countdown = self.countdown,
        throttle = self.throttle
    }
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

---@param rawTrigger table
---@return SpellAuraRemovedTrigger
function SpellAuraRemovedTrigger:Deserialize(rawTrigger)
    return SpellAuraRemovedTrigger:New(rawTrigger.type, rawTrigger.spell_id, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end