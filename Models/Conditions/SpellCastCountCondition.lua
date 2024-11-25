---@class SpellCastCountCondition:Condition
SpellCastCountCondition = setmetatable({}, Condition)
SpellCastCountCondition.__index = SpellCastCountCondition

---@return SpellCastCountCondition
function SpellCastCountCondition:New(unit, comparison, value)
    ---@class SpellCastCountCondition
    local obj = Condition.New(self, "SPELL_CAST_COUNT")
    self.__index = self
    self.unit = unit
    self.comparison = comparison
    self.value = value
    return obj
end

function SpellCastCountCondition:Verify(casts)
    if self.comparison == Comparison.EQUAL then
        if not casts or casts ~= self.value then
            return false
        end
    end

    if self.comparison == Comparison.LOWER_THAN then
        if casts and casts >= self.value then
             return false
        end
    end

    if self.comparison == Comparison.GREATER_THAN then
        if not casts or casts <= self.value then
            return false
        end
    end
    return false
end
