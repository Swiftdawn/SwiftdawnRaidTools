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