local SwiftdawnRaidTools = SwiftdawnRaidTools

SpellCache = {
    -- casts[spellID] = {[source] = {target = target, time = time, count = count}}
    casts = {}
}

function SpellCache.Reset()
    SpellCache.casts = {}
end

function SpellCache.RegisterCast(source, target, spellId, updateFunc)
    if not SpellCache.casts[spellId] then
        SpellCache.casts[spellId] = {}
    end
    if not SpellCache.casts[spellId][source] then
        SpellCache.casts[spellId][source] = {target = target, time = GetTime(), count = 1}
    else
        SpellCache.casts[spellId][source].count = SpellCache.casts[spellId][source].count + 1
        SpellCache.casts[spellId][source].time = GetTime()
    end
    Log.info("Registered cast #".. SpellCache.casts[spellId][source].count .." of "..GetSpellInfo(spellId) .. " by " .. source, { source=source, target=target, spell=spellId, time=GetTime(), count=SpellCache.casts[spellId][source].count })

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
        return nil
    end
    if not SpellCache.casts[spellId][source] then
        return nil
    end
    return SpellCache.casts[spellId][source].count
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