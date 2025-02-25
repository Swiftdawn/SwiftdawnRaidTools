local SwiftdawnRaidTools = SwiftdawnRaidTools

SpellCache = {
    -- casts[spellID] = {[source] = {target = target, time = time, count = count}}
    casts = {},
    -- aura_removed[spellID] = {[target] = {time = time, count = count}}
    aura_removed = {}
}

function SpellCache.Reset()
    SpellCache.casts = {}
    SpellCache.aura_removed = {}
end

function SpellCache.RegisterCastStart(source, target, spellId)
    if not SpellCache.casts[spellId] then
        SpellCache.casts[spellId] = {}
    end
    if not SpellCache.casts[spellId][source] then
        SpellCache.casts[spellId][source] = {target = target, time = GetTime(), count = 1}
    else
        SpellCache.casts[spellId][source].count = SpellCache.casts[spellId][source].count + 1
        SpellCache.casts[spellId][source].time = GetTime()
    end
    -- Log.debug("Registered cast start #".. SpellCache.casts[spellId][source].count .." of "..GetSpellInfo(spellId) .. " by " .. source, { source=source, target=target, spell=spellId, time=GetTime(), count=SpellCache.casts[spellId][source].count })
end

function SpellCache.RegisterCastSuccess(source, target, spellId, updateFunc)
    -- Only register casts of instant spells, spells with cast time should have been counted on start
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo.castTime or spellInfo.castTime == 0 then
        if not SpellCache.casts[spellId] then
            SpellCache.casts[spellId] = {}
        end
        if not SpellCache.casts[spellId][source] then
            SpellCache.casts[spellId][source] = {target = target, time = GetTime(), count = 1}
        else
            local now = GetTime()
            local isChanneled = now - (SpellCache.GetCastTime(source, spellId) or now) < 0.5
            if not isChanneled then
                SpellCache.casts[spellId][source].count = SpellCache.casts[spellId][source].count + 1
                SpellCache.casts[spellId][source].time = GetTime()
            end
        end
    end
    -- Log.debug("Registered cast success #".. SpellCache.casts[spellId][source].count .." of "..GetSpellInfo(spellId) .. " by " .. source, { source=source, target=target, spell=spellId, time=GetTime(), count=SpellCache.casts[spellId][source].count })

    if (UnitIsPlayer(source) and UnitInRaid(source)) or SRT_IsTesting() then
        local spell = SRTData.GetSpellByID(spellId)
        if spell then
            updateFunc()
            if spell.duration > 5 then
                C_Timer.After(spell.duration - 5, updateFunc)
            end
            C_Timer.After(spell.duration, updateFunc)
            C_Timer.After(spell.cooldown, updateFunc)
        end
    end
end

function SpellCache.RegisterAuraRemoved(target, spellId)
    if not SpellCache.aura_removed[spellId] then
        SpellCache.aura_removed[spellId] = {}
    end
    if not SpellCache.aura_removed[spellId][target] then
        SpellCache.aura_removed[spellId][target] = {time = GetTime(), count = 1}
    else
        SpellCache.aura_removed[spellId][target].count = SpellCache.aura_removed[spellId][target].count + 1
        SpellCache.aura_removed[spellId][target].time = GetTime()
    end
    -- Log.debug("Registered aura removed #".. SpellCache.aura_removed[spellId][target].count .." of "..GetSpellInfo(spellId) .. " from " .. target, { target=target, spell=spellId, time=GetTime(), count=SpellCache.aura_removed[spellId][target].count })
end

function SpellCache.GetCastTime(source, spellId)
    if not SpellCache.casts[spellId] then
        return nil
    end
    if not SpellCache.casts[spellId][source] then
        return nil
    end
    return SpellCache.casts[spellId][source].time
end

function SpellCache.GetCastCount(source, spellId)
    if not SpellCache.casts[spellId] then
        return 0
    end
    if source then
        if not SpellCache.casts[spellId][source] then
            return 0
        end
        return SpellCache.casts[spellId][source].count
    else
        local totalCount = 0
        for _, data in pairs(SpellCache.casts[spellId]) do
            totalCount = totalCount + data.count
        end
        return totalCount
    end
end

function SpellCache.GetAuraRemovedCount(target, spellId)
    if not SpellCache.aura_removed[spellId] then
        return 0
    end
    if target then
        if not SpellCache.aura_removed[spellId][target] then
            return 0
        end
        return SpellCache.aura_removed[spellId][target].count
    else
        local totalCount = 0
        for _, data in pairs(SpellCache.aura_removed[spellId]) do
            totalCount = totalCount + data.count
        end
        return totalCount
    end
end

function SpellCache.IsSpellReady(source, spellId, timestamp)
    if not SRT_IsTesting() then
        if UnitIsDeadOrGhost(source) then
            return false
        end

        if not UnitIsPlayer(source) and not UnitInRaid(source) then
            -- print("Unit is not player or in raid", source)
            return false
        end
    end

    timestamp = timestamp or GetTime()

    -- Find the most recent cast by source
    local mostRecentCast = SpellCache.GetCastTime(source, spellId)

    -- If the spell has never been cast, it is ready
    if not mostRecentCast then
        return true
    end

    -- If the most recent cast was more than the cooldown ago, the spell is ready
    if timestamp < mostRecentCast + SRTData.GetSpellByID(spellId).cooldown then
        return false
    end
    return true
end

function SpellCache.IsSpellActive(source, spellId, timestamp)
    if not SRT_IsTesting() then
        if UnitIsDeadOrGhost(source) then
            return false
        end

        if not UnitIsPlayer(source) and not UnitInRaid(source) then
            -- print("Unit is not player or in raid", source)
            return false
        end
    end

    local timestamp = timestamp or GetTime()

    -- Find the most recent cast by source
    local mostRecentCast = SpellCache.GetCastTime(source, spellId)

    -- If the spell has never been cast, it is ready
    if not mostRecentCast then
        return false
    end

    -- If the most recent cast was less than the duration ago, the spell is active
    if timestamp < mostRecentCast + SRTData.GetSpellByID(spellId).duration then
        return true
    end
    return false
end