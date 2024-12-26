---@class SpellAuraRemovedTrigger
SpellAuraRemovedTrigger = {}
SpellAuraRemovedTrigger.__index = SpellAuraRemovedTrigger

---@return SpellAuraRemovedTrigger
function SpellAuraRemovedTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellAuraRemovedTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.delay = delay
    obj.countdown = countdown
    obj.throttle = throttle
    obj.height = 30
    obj.conditions = {}
    return obj
end

function SpellAuraRemovedTrigger:GetDisplayName()
    return "\'"..GetSpellInfo(self.spellID) .. "' is removed".. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
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