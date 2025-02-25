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

    insert(timers, C_Timer.NewTimer(5.2, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Aeolyne", nil, nil, 740)
    end))

    -- Phase 1

    insert(timers, C_Timer.NewTimer(10, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_APPLIED", "The Boss", nil, nil, 81572)
    end))

    insert(timers, C_Timer.NewTimer(12, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Kondec", nil, nil, 62618)
    end))

    -- Phase 2

    insert(timers, C_Timer.NewTimer(15, function()
        SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(nil, "I will breathe fire on you!")
    end))

    insert(timers, C_Timer.NewTimer(16, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Anticipâte", nil, nil, 31821)
    end))

    -- Phase 3

    insert(timers, C_Timer.NewTimer(20, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    insert(timers, C_Timer.NewTimer(23, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Bushtree", nil, nil, 88853)
    end))

    insert(timers, C_Timer.NewTimer(26, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, nil, 88853)
    end))

    -- Phase 4

    insert(timers, C_Timer.NewTimer(30, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Bushpoke", 105256)
    end))

    insert(timers, C_Timer.NewTimer(31, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Bushpoke", 105256)
    end))

    insert(timers, C_Timer.NewTimer(33, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Oldmanbush", 105256)
    end))

    insert(timers, C_Timer.NewTimer(34, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Oldmanbush", 105256)
    end))

    insert(timers, C_Timer.NewTimer(34, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "Venmir", nil, nil, 98008)
    end))

    insert(timers, C_Timer.NewTimer(36, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Bushtree", 105256)
    end))

    insert(timers, C_Timer.NewTimer(37, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Bushtree", 105256)
    end))

    -- Phase 5

    insert(timers, C_Timer.NewTimer(41, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_REMOVED", "The Boss", nil, "Dableach", 63510)
    end))

    insert(timers, C_Timer.NewTimer(42, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Sarune", 99052)
    end))

    insert(timers, C_Timer.NewTimer(43, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Sarune", 99052)
    end))

    insert(timers, C_Timer.NewTimer(44, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_REMOVED", "The Boss", nil, "Dableach", 63510)
    end))

    insert(timers, C_Timer.NewTimer(45, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Sarune", 99052)
    end))

    insert(timers, C_Timer.NewTimer(46, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Sarune", 99052)
    end))

    insert(timers, C_Timer.NewTimer(47, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "Bushtree", nil, nil, 740)
    end))

    insert(timers, C_Timer.NewTimer(48, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_AURA_REMOVED", "The Boss", nil, "Dableach", 63510)
    end))

    insert(timers, C_Timer.NewTimer(49, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, "Sarune", 99052)
    end))

    insert(timers, C_Timer.NewTimer(50, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_SUCCESS", "The Boss", nil, "Sarune", 99052)
    end))

    -- Phase 6

    insert(timers, C_Timer.NewTimer(55, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, nil, 98934)
    end))

    insert(timers, C_Timer.NewTimer(58, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, nil, 98934)
    end))

    insert(timers, C_Timer.NewTimer(61, function()
        SwiftdawnRaidTools:HandleCombatLog("SPELL_CAST_START", "The Boss", nil, nil, 98934)
    end))

    -- End of Test

    insert(timers, C_Timer.NewTimer(66, function()
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
