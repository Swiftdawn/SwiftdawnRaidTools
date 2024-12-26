---@class NumenTimerTrigger
NumenTimerTrigger = {}
NumenTimerTrigger.__index = NumenTimerTrigger

---@return NumenTimerTrigger
function NumenTimerTrigger:New(name, key, delay, countdown, throttle)
    ---@class NumenTimerTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.key = key
    obj.delay = delay
    obj.countdown = countdown
    obj.throttle = throttle
    obj.height = 20
    obj.conditions = {}
    return obj
end

function NumenTimerTrigger:GetDisplayName()
    return "Numen timer \'" .. self.key .. "\' is at 5 seconds".. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
end

function NumenTimerTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "FOJJI_NUMEN_TIMER",
        key = self.key
    }
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

function NumenTimerTrigger:Deserialize(rawTrigger)
    return NumenTimerTrigger:New(rawTrigger.type, rawTrigger.key, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end