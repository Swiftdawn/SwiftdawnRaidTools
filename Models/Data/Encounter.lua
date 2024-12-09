---@class Encounter
Encounter = {}
Encounter.__index = Encounter

---@return Encounter
function Encounter:New(encounterID)
    ---@class Encounter
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = encounterID
    obj.info = nil
    obj.abilities = {}
    return obj
end

function Encounter:GetInfo()
    if self.info then
        return self.info
    end
    self.info = SwiftdawnRaidTools:BossEncounterByID(self.id)
end
