---@class SpellAuraTrigger
SpellAuraTrigger = {}
SpellAuraTrigger.__index = SpellAuraTrigger

---@return SpellAuraTrigger
function SpellAuraTrigger:New(name, spellID)
    ---@class SpellAuraTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.conditions = {}
    return obj
end

function SpellAuraTrigger:GetDisplayName()
    return "Aura: " .. GetSpellInfo(self.spellID)
end