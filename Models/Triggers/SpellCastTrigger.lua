---@class SpellCastTrigger
SpellCastTrigger = {}
SpellCastTrigger.__index = SpellCastTrigger

---@return SpellCastTrigger
function SpellCastTrigger:New(name, spellID, delay, countdown, throttle)
    ---@class SpellCastTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "SPELL_CAST"
    obj.spellID = spellID or 0
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 30
    obj.conditions = {}
    return obj
end

function SpellCastTrigger:GetDisplayName()
    return "\'"..(GetSpellInfo(self.spellID) or "Spell not found") .. "' is cast".. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
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