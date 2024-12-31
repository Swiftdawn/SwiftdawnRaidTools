---@class SpellAuraTrigger
SpellAuraTrigger = {}
SpellAuraTrigger.__index = SpellAuraTrigger

---@return SpellAuraTrigger
function SpellAuraTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellAuraTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_AURA"
    obj.spellID = spellID or 0
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 30
    obj.conditions = {}
    return obj
end

function SpellAuraTrigger:GetDisplayName()
    return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "' is activated".. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
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