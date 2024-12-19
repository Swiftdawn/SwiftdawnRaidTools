---@class SpellCastTrigger
SpellCastTrigger = {}
SpellCastTrigger.__index = SpellCastTrigger

---@return SpellCastTrigger
function SpellCastTrigger:New(name, spellID)
    ---@class SpellCastTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.conditions = {}
    return obj
end

function SpellCastTrigger:GetDisplayName()
    return "Spell Cast: " .. GetSpellInfo(self.spellID)
end