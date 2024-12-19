---@class EncounterStartTrigger
EncounterStartTrigger = {}
EncounterStartTrigger.__index = EncounterStartTrigger

---@return EncounterStartTrigger
function EncounterStartTrigger:New(name, value)
    ---@class EncounterStartTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.value = value
    obj.conditions = {}
    return obj
end

function EncounterStartTrigger:GetDisplayName()
    return "Time: " .. tostring(self.value) .. " seconds"
end