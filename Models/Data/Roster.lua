---@class Roster
Roster = {}
Roster.__index = Roster

local function timestamp()
    local currentTimestamp = time()
    ---@class string
    return date("%d-%m-%Y %H:%M:%S", currentTimestamp)
end

---@return Roster
function Roster:New()
    ---@class Roster
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = Utils:GenerateUUID()
    obj.name = nil
    obj.timestamp = timestamp()
    obj.players = {}
    obj.encounters = {}
    return obj
end

function Roster.GetName(roster)
    if not roster.name then
        roster.name = "Roster"
    end
    return roster.name
end

function Roster.GetTimestamp(roster)
    if not roster.timestamp then
        roster.timestamp = Utils:Timestamp()
    end
    return roster.timestamp
end

---@param player Player
function Roster.AddPlayer(roster, player)
    roster.players[player.name] = player
end

function Roster.Parse(raw, name)
    local roster = Roster:New()
    if name then
        roster.name = name
    end
    roster.encounters = raw
    roster.timestamp = timestamp()
    for _, encounter in pairs(roster.encounters) do
        for _, ability in pairs(encounter) do
            for _, group in pairs(ability.assignments) do
                for _, assignment in pairs(group) do
                    Roster.AddPlayer(roster, Player:New(assignment.player, SRTData.GetClassBySpellID(assignment.spell_id)))
                end
            end
        end
    end
    return roster
end