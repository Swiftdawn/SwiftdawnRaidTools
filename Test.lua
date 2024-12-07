local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools

local timers = {}

local function cancelTimers()
    for i, timer in ipairs(timers) do
        timer:Cancel()
        timers[i] = nil
    end
end

function SwiftdawnRaidTools:InternalTestStart()
    SRT_SetTestMode(true)

    self.overview:UpdateSpells()

    self:ENCOUNTER_START(nil, 1082)

    C_Timer.NewTimer(10, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Sinestra", nil, nil, 90125)
    end)

    -- C_Timer.NewTimer(40, function()
    --     SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Sinestra", nil, nil, 90125)
    -- end)
end

function SwiftdawnRaidTools:InternalTestEnd()
    SRT_SetTestMode(false)

    self:ENCOUNTER_END(nil, 1082)
end

function SwiftdawnRaidTools:TestModeToggle()
    if SRT_IsTesting() then
        self:TestModeEnd()
    else
        self:TestModeStart()
    end
end

function SwiftdawnRaidTools:TestModeStart()
    SRT_SetTestMode(true)

    cancelTimers()

    Groups.Reset()
    SpellCache.Reset()
    UnitCache:ResetDeadCache()

    self.overview:SelectEncounter(42001)
    Log.debug("SRT Test: Starting encounter")
    AssignmentsController:StartEncounter(42001, "The Boss")

    insert(timers, C_Timer.NewTimer(5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Aeolyne", nil, nil, 740)
    end))

    insert(timers, C_Timer.NewTimer(5.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Aeolyne", nil, nil, 740)
    end))

    -- Phase 1

    insert(timers, C_Timer.NewTimer(14, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_APPLIED", "The Boss", nil, nil, 81572)
    end))

    insert(timers, C_Timer.NewTimer(15.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Kondec", nil, nil, 62618)
    end))

    insert(timers, C_Timer.NewTimer(16.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kondec", nil, nil, 62618)
    end))

    -- Phase 2

    insert(timers, C_Timer.NewTimer(21, function()
        SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "I will breathe fire on you!")
    end))

    insert(timers, C_Timer.NewTimer(22.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Anticipâte", nil, nil, 31821)
    end))

    insert(timers, C_Timer.NewTimer(23.5, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    end))

    -- Phase 3

    insert(timers, C_Timer.NewTimer(28, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    insert(timers, C_Timer.NewTimer(33, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    -- End of Test

    insert(timers, C_Timer.NewTimer(44, function()
        SwiftdawnRaidTools:TestModeEnd()
    end))
end

function SwiftdawnRaidTools:TestModeEnd()
    if SRT_IsTesting() then
        SRT_SetTestMode(false)

        cancelTimers()

        AssignmentsController:EndEncounter(42001, "The Boss", true)
        SpellCache.Reset()
        UnitCache:ResetDeadCache()
        self.overview:Update()
    end
end
