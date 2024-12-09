---@class SpellCastTrigger:Trigger
SpellCastTrigger = setmetatable({}, Trigger)
SpellCastTrigger.__index = SpellCastTrigger

---@return SpellCastTrigger
function SpellCastTrigger:New(unit, comparison, value)
    ---@class SpellCastTrigger
    local obj = Trigger.New(self, "UNIT_HEALTH")
    self.__index = self
    self.unit = unit
    self.comparison = comparison
    self.value = value
    return obj
end

function SpellCastTrigger:CheckTrigger(castSpellID)
    
    return false
end
