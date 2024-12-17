---@class UnitHealthCondition:Condition
UnitHealthCondition = setmetatable({}, Condition)
UnitHealthCondition.__index = UnitHealthCondition

---@return UnitHealthCondition
function UnitHealthCondition:New(unit, comparison, value)
    ---@class UnitHealthCondition
    local obj = Condition.New(self, "UNIT_HEALTH")
    self.__index = self
    self.unit = unit
    self.comparison = comparison
    self.value = value
    return obj
end

function UnitHealthCondition:Verify()
    local health = UnitHealth(self.unit)
    if self.comparison == Comparison.LOWER_THAN then
        if health < self.value then
            return true
        end
    elseif self.comparison == Comparison.GREATER_THAN then
        if health > self.value then
            return true
        end
    elseif self.comparison == Comparison.PERCENT_LOWER_THAN then
        local maxHealth = UnitHealthMax(self.unit)
        local percent = health / maxHealth * 100
        if percent < self.value then
            return true
        end
    elseif self.comparison == Comparison.PERCENT_GREATER_THAN then
        local maxHealth = UnitHealthMax(self.unit)
        local percent = health / maxHealth * 100
        if percent > self.value then
            return true
        end
    end
    return false
end
