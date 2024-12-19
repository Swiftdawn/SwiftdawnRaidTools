---@class SpellAuraRemovedTrigger
SpellAuraRemovedTrigger = {}
SpellAuraRemovedTrigger.__index = SpellAuraRemovedTrigger

---@return SpellAuraRemovedTrigger
function SpellAuraRemovedTrigger:New(name, spellID)
    ---@class SpellAuraRemovedTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.conditions = {}
    return obj
end

function SpellAuraRemovedTrigger:GetDisplayName()
    return "Aura Removed: " .. GetSpellInfo(self.spellID)
end