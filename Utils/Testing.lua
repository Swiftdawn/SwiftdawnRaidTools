local SwiftdawnRaidTools = SwiftdawnRaidTools
Testing = {
    timers = {},
}

function Testing:CancelTimers()
    for i, timer in ipairs(self.timers) do
        timer:Cancel()
        self.timers[i] = nil
    end
end

function Testing:SpellCastStart(time, spellId, source, target)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", source, nil, target, spellId)
    end))
end

function Testing:SpellCastSuccess(time, spellId, source, target)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", source, nil, target, spellId)
    end))
end

function Testing:SpellAuraApplied(time, spellId, source, target)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_APPLIED", source, nil, target, spellId)
    end))
end

function Testing:SpellAuraRemoved(time, spellId, source, target)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_REMOVED", source, nil, target, spellId)
    end))
end

function Testing:RaidBossEmote(time, emote)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, emote)
    end))
end

function Testing:EndTest(time)
    table.insert(self.timers, C_Timer.NewTimer(time, function()
        self:EndTestNow()
    end))
end

function Testing:EndTestNow()
    if SRT_IsTesting() then
        SRT_SetTestMode(false)

        self:CancelTimers()

        AssignmentsController:EndEncounter(42001, "The Boss", true)
        SpellCache.Reset()
        UnitCache:ResetDeadCache()
        SwiftdawnRaidTools.overview:Update()
    end
end

function Testing:ResetCaches()
    Groups.Reset()
    SpellCache.Reset()
    UnitCache:ResetDeadCache()
end

function Testing:ToggleMainTest()
    if not SRT_IsTesting() then
        MainTest:Start()
    else
        Testing:EndTestNow()
    end
end

function Testing:ToggleSequentialTest()
    if not SRT_IsTesting() then
        SequentialTest:Start()
    else
        Testing:EndTestNow()
    end
end