---@class Trigger
Trigger = {}
Trigger.__index = Trigger

---@return Trigger
function Trigger:New(type)
    ---@class Trigger
    local obj = setmetatable({}, self)
    self.__index = self
    obj.type = type
    obj.triggered = false
    return obj
end

---Set triggered state for trigger
---@param triggered boolean Defaults to true
function Trigger:SetTriggered(triggered)
    if triggered == nil then
        self.triggered = true
    else
        self.triggered = triggered
    end
end