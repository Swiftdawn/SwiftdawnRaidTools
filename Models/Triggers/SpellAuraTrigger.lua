---@class SpellAuraTrigger
SpellAuraTrigger = {}
SpellAuraTrigger.__index = SpellAuraTrigger

---@return SpellAuraTrigger
function SpellAuraTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellAuraTrigger
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

function SpellAuraTrigger:GetDisplayName()
    return "\'"..GetSpellInfo(self.spellID) .. "' is activated".. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
end

---Serializes the SpellAuraTrigger object into a format suitable for storage or transmission.
---@return table
function SpellAuraTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "SPELL_AURA",
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
---@return SpellAuraTrigger
function SpellAuraTrigger:Deserialize(rawTrigger)
    return SpellAuraTrigger:New(rawTrigger.type, rawTrigger.spell_id, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end