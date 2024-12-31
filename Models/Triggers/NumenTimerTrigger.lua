---@class NumenTimerTrigger
NumenTimerTrigger = {}
NumenTimerTrigger.__index = NumenTimerTrigger

---@return NumenTimerTrigger
function NumenTimerTrigger:New(name, key, delay, countdown, throttle)
    ---@class NumenTimerTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "FOJJI_NUMEN_TIMER"
    obj.key = key or "change.me"
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.height = 20
    obj.conditions = {}
    return obj
end

function NumenTimerTrigger:GetDisplayName()
    return "Numen timer \'" .. self.key .. "\' is at 5 seconds".. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
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