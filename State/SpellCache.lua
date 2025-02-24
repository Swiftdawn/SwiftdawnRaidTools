local SwiftdawnRaidTools = SwiftdawnRaidTools

SpellCache = {
    -- casts[spellID] = [{source = source, target = target, time = time}]
    casts = {}
}

function SpellCache.Reset()
    SpellCache.casts = {}
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

    -- If the spell has never been cast, it is ready
    if not SpellCache.casts[spellId] then
        return true
    end

    -- Find the most recent cast by source
    local cachedCasts = SpellCache.casts[spellId]
    local mostRecentCast = 0
    for _, cachedCast in pairs(cachedCasts) do
        if cachedCast.source == source and cachedCast.time > mostRecentCast then
            mostRecentCast = cachedCast.time
        end
    end

    -- If the spell was never cast by the source, the spell is ready
    if mostRecentCast == 0 then
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

    -- If the spell has never been cast, it is not active
    if not SpellCache.casts[spellId] then
        return false
    end

    -- Find the most recent cast by source
    local cachedCasts = SpellCache.casts[spellId]
    local mostRecentCast = 0
    for _, cachedCast in pairs(cachedCasts) do
        if cachedCast.source == source and cachedCast.time > mostRecentCast then
            mostRecentCast = cachedCast.time
        end
    end

    -- If the spell was never cast by the source, the spell is not active
    if mostRecentCast == 0 then
        return false
    end

    -- If the most recent cast was less than the duration ago, the spell is active
    if timestamp < mostRecentCast + SRTData.GetSpellByID(spellId).duration then
        return true
    end
    return false
end

function SpellCache.GetCastTime(source, spellId)
    if not SpellCache.casts[spellId] then
        return nil
    end

    -- Find the most recent cast by source
    local cachedCasts = SpellCache.casts[spellId]
    local mostRecentCast = 0
    for _, cachedCast in pairs(cachedCasts) do
        if cachedCast.source == source and cachedCast.time > mostRecentCast then
            mostRecentCast = cachedCast.time
        end
    end

    return mostRecentCast == 0 and nil or mostRecentCast
end

function SpellCache.RegisterCast(source, target, spellId, updateFunc)
    if not SRT_IsTesting() then
        if not UnitIsPlayer(source) and not UnitInRaid(source) then
            return
        end
    end

    local spell = SRTData.GetSpellByID(spellId)
    if spell then
        if not SpellCache.casts[spellId] then
            SpellCache.casts[spellId] = {}
        end
        table.insert(SpellCache.casts[spellId], {source = source, target = target, time = GetTime()})
        Log.info("Registered cast of "..spell.name .. " by " .. source, { source=source, target=target, spell=spellId, time=GetTime() })

        updateFunc()

        if spell.duration > 5 then
            C_Timer.After(spell.duration - 5, updateFunc)
        end

        C_Timer.After(spell.duration, updateFunc)
        C_Timer.After(spell.cooldown, updateFunc)
    end
end