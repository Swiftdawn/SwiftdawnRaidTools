---@class BossEmoteTrigger
BossEmoteTrigger = {}
BossEmoteTrigger.__index = BossEmoteTrigger

---@return BossEmoteTrigger
function BossEmoteTrigger:New(name, emoteText)
    ---@class BossEmoteTrigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.emoteText = emoteText
    obj.conditions = {}
    return obj
end

function BossEmoteTrigger:GetDisplayName()
    return "Boss Emote: \"" .. self.emoteText .. "\""
end