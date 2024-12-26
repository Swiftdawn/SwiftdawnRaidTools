---@class SpellCastTrigger
SpellCastTrigger = {}
SpellCastTrigger.__index = SpellCastTrigger

---@return SpellCastTrigger
function SpellCastTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellCastTrigger
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

function SpellCastTrigger:GetDisplayName()
    return "\'"..GetSpellInfo(self.spellID) .. "' is cast".. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
end

---Serializes the SpellCastTrigger object into a format suitable for storage or transmission.
---@return table
function SpellCastTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "SPELL_CAST",
        spell_id = self.spellID
    }
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

---@param rawTrigger table
---@return SpellCastTrigger
function SpellCastTrigger:Deserialize(rawTrigger)
    return SpellCastTrigger:New(rawTrigger.type, rawTrigger.spell_id, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end