local SwiftdawnRaidTools = SwiftdawnRaidTools

SpellCache = {
    --- key = "unitId:spellId", Value = cast timestamp
    casts = {}
}

function SpellCache.Reset()
    SpellCache.casts = {}
end

function SpellCache.IsSpellReady(unit, spellId, timestamp)
    if not SRT_IsTesting() then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            print("Unit is not player or in raid", unit)
            return false
        end
    end

    timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = SpellCache.casts[key]

    if not cachedCastTimestamp then
        return true
    end

    if timestamp < cachedCastTimestamp + SRTData.GetSpellByID(spellId).cooldown then
        return false
    end

    return true
end

function SpellCache.IsSpellActive(unit, spellId, timestamp)
    if not SRT_IsTesting() then
        if UnitIsDeadOrGhost(unit) then
            return false
        end

        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            -- print("Unit is not player or in raid", unit)
            return false
        end
    end

    local timestamp = timestamp or GetTime()

    local key = unit .. ":" .. spellId

    local cachedCastTimestamp = SpellCache.casts[key]

    if not cachedCastTimestamp then
        return false
    end

    if timestamp < cachedCastTimestamp + SRTData.GetSpellByID(spellId).duration then
        return true
    end

    return false
end

function SpellCache.GetCastTime(unit, spellId)
    local key = unit .. ":" .. spellId

    return SpellCache.casts[key]
end

function SpellCache.RegisterCast(unit, spellId, updateFunc)
    if not SRT_IsTesting() then
        if not UnitIsPlayer(unit) and not UnitInRaid(unit) then
            return
        end
    end

    local spell = SRTData.GetSpellByID(spellId)
    if spell then
        local key = unit .. ":" .. spellId

        SpellCache.casts[key] = GetTime()

        updateFunc()

        if spell.duration > 5 then
            C_Timer.After(spell.duration - 5, updateFunc)
        end

        C_Timer.After(spell.duration, updateFunc)
        C_Timer.After(spell.cooldown, updateFunc)
    end
end