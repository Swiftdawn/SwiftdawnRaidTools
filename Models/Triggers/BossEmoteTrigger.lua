---@class BossEmoteTrigger
BossEmoteTrigger = {}
BossEmoteTrigger.__index = BossEmoteTrigger

---@return BossEmoteTrigger
function BossEmoteTrigger:New(name, emoteText, delay, countdown, throttle)
    ---@class BossEmoteTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name or "RAID_BOSS_EMOTE"
    obj.emoteText = emoteText or "change me"
    obj.delay = delay or 0
    obj.countdown = countdown or 0
    obj.throttle = throttle or 0
    obj.conditions = {}
    obj.height = 30
    return obj
end

function BossEmoteTrigger:GetDisplayName()
    return "Boss emotes \n\'" .. Utils:RemoveChatCodes(self.emoteText) .. "\'".. (self.delay > 0 and "\nTrigger after " .. tostring(self.delay) .. " seconds" or "")
end

function BossEmoteTrigger:Serialize(isUntrigger)
    local serialized = {
        type = "RAID_BOSS_EMOTE",
        text = self.emoteText,
    }
    if not isUntrigger then
        serialized.delay = self.delay
        serialized.countdown = self.countdown
        serialized.throttle = self.throttle
    end
    return serialized
end

function BossEmoteTrigger:Deserialize(rawTrigger)
    return BossEmoteTrigger:New(rawTrigger.type, rawTrigger.text, rawTrigger.delay, rawTrigger.countdown, rawTrigger.throttle)
end