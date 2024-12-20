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