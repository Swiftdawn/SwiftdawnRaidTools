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