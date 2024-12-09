---@class BossAbility
BossAbility = {}
BossAbility.__index = BossAbility

---@return BossAbility
function BossAbility:New(name)
    ---@class BossAbility
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.notification = nil
    obj.triggers = {}
    obj.untriggers = {}
    return obj
end