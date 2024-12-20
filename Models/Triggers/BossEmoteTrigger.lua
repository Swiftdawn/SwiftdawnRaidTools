---@class BossEmoteTrigger
BossEmoteTrigger = {}
BossEmoteTrigger.__index = BossEmoteTrigger

---@return BossEmoteTrigger
function BossEmoteTrigger:New(name, emoteText, delay, countdown, throttle)
    ---@class BossEmoteTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.emoteText = emoteText
    obj.delay = delay
    obj.countdown = countdown
    obj.throttle = throttle
    obj.conditions = {}
    obj.height = 30
    return obj
end

function BossEmoteTrigger:GetDisplayName()
    return "Boss emotes \n\'" .. Utils:RemoveChatCodes(self.emoteText) .. "\'".. (self.delay and "\n|cFFFFD200Trigger after|r " .. tostring(self.delay) .. " seconds" or "")
end