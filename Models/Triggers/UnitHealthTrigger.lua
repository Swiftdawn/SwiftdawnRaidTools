---@class UnitHealthTrigger:Trigger
UnitHealthTrigger = setmetatable({}, Trigger)
UnitHealthTrigger.__index = UnitHealthTrigger

---@return UnitHealthTrigger
function UnitHealthTrigger:New(unit, comparison, value)
    ---@class UnitHealthTrigger
    local obj = Trigger.New(self, "UNIT_HEALTH")
    self.__index = self
    self.unit = unit
    self.comparison = comparison
    self.value = value
    return obj
end

function UnitHealthTrigger:CheckTrigger(unitName, unitHealth, unitHealthMax)
    if self.unit ~= unitName then
        return false
    end
    if self.comparison == Comparison.LOWER_THAN and unitHealth < self.value then
        return true
    elseif self.comparison == Comparison.GREATER_THAN and unitHealth > self.value then
        return true
    end
    local percent = unitHealth / UnitHealthMax(self.unit) * 100
    if self.comparison == Comparison.PERCENT_LOWER_THAN and percent < self.value then
        return true
    elseif self.comparison == Comparison.PERCENT_GREATER_THAN and percent > self.value then
        return true
    end
    return false
end
