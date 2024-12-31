---@class EncounterStartTrigger
EncounterStartTrigger = {}
EncounterStartTrigger.__index = EncounterStartTrigger

---@return EncounterStartTrigger
function EncounterStartTrigger:New(name, delay, countdown, throttle)
    ---@class EncounterStartTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "ENCOUNTER_START"
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 20
    obj.conditions = {}
    return obj
end

function EncounterStartTrigger:GetDisplayName()
    return tostring(self.delay) .. " seconds has elapsed"
end

function EncounterStartTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "ENCOUNTER_START",
        delay = self.delay
    }
    if not isUntrigger then
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

function EncounterStartTrigger:Deserialize(rawTrigger)
    return EncounterStartTrigger:New(rawTrigger.type, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end