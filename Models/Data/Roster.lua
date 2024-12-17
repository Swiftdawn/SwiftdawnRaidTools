---@class Roster
Roster = {}
Roster.__index = Roster

---@return Roster
function Roster:New(name, lastUpdated, owner)
    ---@class Roster
    local obj = setmetatable({}, self)
    self.__index = self
    obj.id = Utils:GenerateUUID()
    obj.name = name
    obj.lastUpdated = lastUpdated
    obj.owner = owner
    obj.players = {}
    obj.encounters = {}
    return obj
end

function Roster.MarkUpdated(roster, changes)
    roster.lastUpdated = time()
    Log.debug("Roster updated at "..Roster.GetLastUpdatedTimestamp(roster), { rosterID = roster.id, changes = changes })
end

function Roster.GetLastUpdated(roster)
    return roster.lastUpdated or 0
end

function Roster.GetLastUpdatedTimestamp(roster)
    return date("%d-%m-%Y %H:%M:%S", Roster.GetLastUpdated(roster))
end

---@param player Player
function Roster.AddPlayer(roster, player)
    roster.players[player.name] = player
end

function Roster.Parse(raw, name, lastUpdated, owner)
    local roster = Roster:New(name, lastUpdated or time(), owner)
    roster.encounters = raw
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

function Roster.Copy(roster)
    local copiedRoster = Utils:DeepClone(roster)
    copiedRoster.id = Utils:GenerateUUID()
    copiedRoster.name = "Copied Roster"
    copiedRoster.lastUpdated = time()
    copiedRoster.owner = Utils:GetFullPlayerName()
    return copiedRoster
end