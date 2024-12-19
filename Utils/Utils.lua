local SwiftdawnRaidTools = SwiftdawnRaidTools

-- Make sure guild roster data is loaded
C_GuildInfo.GuildRoster()

function SRT_Global()
    return SwiftdawnRaidTools.db.global
end

function SRT_Profile()
    return SwiftdawnRaidTools.db.profile
end

Utils = {}

-- Function to get the name of a guild rank by index
function Utils:GetGuildRankNameByIndex(rankIndex)
    if rankIndex < 0 or rankIndex >= GuildControlGetNumRanks() then
        return nil
    end
    return GuildControlGetRankName(rankIndex)
end

function Utils:IsFriendlyRaidMemberOrPlayer(guid)
    if UnitGUID("player") == guid then
        return true
    end
    for i = 1, GetNumGroupMembers() do
        local raidUnit = "raid" .. i

        if UnitGUID(raidUnit) == guid then
            return true
        end
    end
    return false
end

function Utils:IsPlayerRaidLeader()
    return IsInRaid() and UnitIsGroupLeader("player")
end

function Utils:GetRaidAssignmentPart(uuid)
    local encounters = SRTData.GetActiveEncounters()
    if encounters then
        for _, encounter in pairs(encounters) do
            for _, part in pairs(encounter) do
                if part.uuid == uuid then
                    return part
                end
            end
        end
    end
end

function Utils:IsPlayerInAssignments(assignments)
    for _, group in ipairs(assignments) do
        for _, assignment in ipairs(group) do
            if assignment.player == UnitName("player") then
                return true
            end
        end
    end
    return false
end

function Utils:IsPlayerInActiveGroup(part)
    local activeGroups = Groups.GetActive(part.uuid)
    if activeGroups then
        for _, groupIndex in ipairs(activeGroups) do
            local group = part.assignments[groupIndex]
            if group then
                for _, assignment in ipairs(group) do
                    if assignment.player == UnitName("player") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Utils:Timestamp(withoutYears)
    local currentTimestamp = time()
    if withoutYears then
        ---@class string
        return string.format("%s", date("%H:%M:%S"))
    else
        ---@class string
        return date("%d-%m-%Y %H:%M:%S", currentTimestamp)
    end
end

function Utils:GetWeirdScale()
    -- WEIRD FUNKYNESS!
    local uiScale = UIParent:GetEffectiveScale()
    local weirdScale = ((1 - uiScale) / 2) + uiScale
    local renderScale = tonumber(GetCVar("renderScale"))
    return weirdScale * renderScale
end

function Utils:OrderedPairs(tbl)
    local __genOrderedIndex = function( t )
        local orderedIndex = {}
        for key in pairs(t) do
            if string.sub(key, 1, 1) ~= "_"  then
                table.insert(orderedIndex, key)
            end
        end
        table.sort( orderedIndex )
        return orderedIndex
    end

    local orderedNext = function(t, state)
        -- Equivalent of the next function, but returns the keys in the alphabetic
        -- order. We use a temporary ordered key table that is stored in the
        -- table being iterated.
        local key = nil
        --Log.info("orderedNext: state = "..tostring(state) )
        if state == nil then
            -- the first time, generate the index
            t.__orderedIndex = __genOrderedIndex( t )
            key = t.__orderedIndex[1]
        else
            -- fetch the next value
            for i = 1, #t.__orderedIndex do
                if t.__orderedIndex[i] == state then
                    key = t.__orderedIndex[i+1]
                end
            end
        end
        if key then
            return key, t[key]
        end
        -- no more value to return, cleanup
        t.__orderedIndex = nil
        return
    end

    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, tbl, nil
end

function Utils:TableToString(tbl, indent, seen)
    if type(tbl) == "string" then
        return tbl
    elseif tbl == nil then
        return "nil"
    end
    indent = indent or 0
    seen = seen or {}
    local result = "{\n"
    local indentStr = string.rep("  ", indent)
    -- Detect cyclic references
    if seen[tbl] then
        return indentStr .. "[Cyclic Reference]"
    end
    seen[tbl] = true
    for k, v in pairs(tbl) do
        result = result .. indentStr .. "  [" .. tostring(k) .. "] = "

        if type(v) == "table" then
            result = result .. Utils:TableToString(v, indent + 1, seen) .. ",\n"
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '",\n'
        elseif type(v) == "function" or type(v) == "userdata" then
            result = result .. "[Unsupported Type: " .. type(v) .. "],\n"
        else
            result = result .. tostring(v) .. ",\n"
        end
    end
    result = result .. indentStr .. "}"
    return result
end

function Utils:ShallowClone(table)
    if not table then return table end
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

function Utils:DeepClone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Utils:DeepClone(orig_key)] = Utils:DeepClone(orig_value)
        end
        setmetatable(copy, Utils:DeepClone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Utils:StringEllipsis(str, len)
    if string.len(str) > len + 3 then
        return str:sub(1, len) .. "..."
    end
    return str
end

function Utils:StringJoin(strings, delimiter)
    if not strings then
        return ""
    elseif type(strings) == "string" then
        return strings
    elseif type(strings) ~= "table" then
        return tostring(strings)
    end
    delimiter = delimiter or ", "
    local result = ""
    for i, str in ipairs(strings) do
        result = result .. str

        if i < #strings then
            result = result .. delimiter
        end
    end
    return result
end

-- Returns a boolean indicating if the string was fully intepolated and the interpolated string
-- Example use:
-- StringInterpolate("%(key)s is %(val).2f%" , { key = "concentration", val = 56.2795 }) -> "Concentration is 56.27%"
function Utils:StringInterpolate(str, ctx)
    local stringFullyInterpolated = true
    local result = str:gsub('%%%(([%a%w_]*)%)([-0-9%.]*[cdeEfgGiouxXsq])', function(k, fmt)
        if not ctx[k] then
            stringFullyInterpolated = false
        end

        return ctx[k] and ("%" .. fmt):format(ctx[k]) or '%(' .. k .. ')' .. fmt
    end)
    return stringFullyInterpolated, result
end

function Utils:CreateFadeOut(frame, onFinished)
    local fadeOutGroup = frame:CreateAnimationGroup()
    local fadeOut = fadeOutGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetSmoothing("OUT")
    fadeOutGroup:SetScript("OnFinished", function(self)
        if onFinished then onFinished() end
        self:GetParent():Hide()
    end)
    return fadeOutGroup
end

function Utils:GenerateUUID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 15) or (math.random(8, 11))
        return string.format('%x', v)
    end)
end

function Utils:ValidateUUID(input)
    -- UUID pattern (version 4)
    local uuidPattern = "^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$"
    
    -- Check if input matches the UUID pattern
    if input:match(uuidPattern) then
        return true  -- Valid UUID
    else
        return false, "Invalid UUID. Please enter a valid UUID version 4."
    end
end

function Utils:IsArray(table)
    local i = 0
    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end
    return true
end

local lastUpdatedRaidMembers = 0
local raidMembers = {}
function Utils:GetRaidMembers(onlineOnly)
    if GetTime() - lastUpdatedRaidMembers < 5 then
        return raidMembers
    end
    raidMembers = {}
    if IsInRaid() then
        local numMembers = GetNumGroupMembers()
        for i = 1, numMembers do
            local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
            if name then
                if (onlineOnly and online) or not onlineOnly then
                    table.insert(raidMembers, { name = name, class = class, fileName = fileName })
                end
            end
        end
    end
    return raidMembers
end

local lastUpdatedOnlineGuildMembers = 0
local guildMembers = {}
function Utils:GetGuildMembers(onlineOnly)
    if GetTime() - lastUpdatedOnlineGuildMembers < 5 then
        return guildMembers
    end
    guildMembers = {}
    local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
    for index = 1, numTotalGuildMembers, 1 do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, fileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(index)
        if level == 85 then
            if (onlineOnly and online) or not onlineOnly then
                table.insert(guildMembers, { name = name, class = class, fileName = fileName, online = online, standing = standingID, rankIndex = rankIndex })
            end
        end
    end
    table.sort(guildMembers, function (a, b)
        if a.online ~= b.online then
            return a.online
        elseif a.standing ~= b.standing then
            return a.standing > b.standing
        elseif a.rankIndex ~= b.rankIndex then
            return a.rankIndex < b.rankIndex
        else
            return a.name < b.name
        end
    end)
    return guildMembers
end

function Utils:CombinedIteratorWithUniqueNames(t1, t2)
    local i, j = 1, 1
    local len1, len2 = #t1, #t2
    local seen_names = {}
    return function()
        while i <= len1 do
            local item = t1[i]
            i = i + 1
            if item.name and not seen_names[strsplit("-", item.name)] then
                seen_names[strsplit("-", item.name)] = true
                return item
            end
        end
        while j <= len2 do
            local item = t2[j]
            j = j + 1
            if item.name and not seen_names[strsplit("-", item.name)] then
                seen_names[strsplit("-", item.name)] = true
                return item
            end
        end
    end
end

function Utils:GetFullSenderName(sender)
    local name, realm = strsplit("-", sender)
    return name .. "-" .. (realm or GetRealmName())
end

function Utils:GetFullPlayerName()
    local playerName, playerRealm = UnitName("player")
    return playerName .. "-" .. (playerRealm or GetRealmName())
end

---@return SpellCastTrigger|BossEmoteTrigger|UnitHealthTrigger|EncounterStartTrigger|nil
function Utils:ParseTrigger(rawTrigger)
    if not rawTrigger.type then
        Log.info("[ERROR] Trigger's type is missing", rawTrigger)
        return nil
    end
    if rawTrigger.type == "SPELL_CAST" then
        return SpellCastTrigger:New(rawTrigger.type, rawTrigger.spell_id)
    elseif rawTrigger.type == "BOSS_EMOTE" then
        return BossEmoteTrigger:New(rawTrigger.type, rawTrigger.emoteText)
    elseif rawTrigger.type == "UNIT_HEALTH" then
        return UnitHealthTrigger:New(rawTrigger.type, rawTrigger.unit, ">", rawTrigger.pct_gt)
    elseif rawTrigger.type == "ENCOUNTER_START" then
        return EncounterStartTrigger:New(rawTrigger.type, rawTrigger.delay)
    else
        Log.info("[ERROR] Trigger's type is not supported", rawTrigger)
        return nil
    end
end

---@return CastCountCondition|UnitHealthCondition|nil
function Utils:ParseCondition(rawCondition)
    if not rawCondition.type then
        Log.info("[ERROR] Condition's type is missing", rawCondition)
        return nil
    end
    if rawCondition.type == "SPELL_CAST_COUNT" then
        return CastCountCondition:New(rawCondition.type, rawCondition.spell_id, rawCondition.gt)
    elseif rawCondition.type == "UNIT_HEALTH" then
        return UnitHealthCondition:New(rawCondition.type, rawCondition.unit, ">", rawCondition.pct_gt)
    else
        Log.info("[ERROR] Condition's type is not supported", rawCondition)
        return nil
    end
end