---@class CastCountCondition
CastCountCondition = {}
CastCountCondition.__index = CastCountCondition

---@return CastCountCondition
function CastCountCondition:New(name, spellID, count)
    ---@class CastCountCondition
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.spellID = spellID
    obj.count = count
    obj.conditions = {}
    return obj
end

function CastCountCondition:GetDisplayName()
    return GetSpellInfo(self.spellID) .. " was cast more than " .. self.count .. " times"
end