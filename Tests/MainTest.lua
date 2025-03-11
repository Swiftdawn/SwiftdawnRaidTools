local SwiftdawnRaidTools = SwiftdawnRaidTools
MainTest = {}

function MainTest:Start()
    -- Set testing mode
    SRT_SetTestMode(true)

    -- Cancel any existing timers & reset caches
    Testing:CancelTimers()
    Testing:ResetCaches()

    -- Start encounter
    SwiftdawnRaidTools.overview:SelectEncounter(42001)
    AssignmentsController:StartEncounter(42001, "The Boss")

    -- Initiate timers
    Testing:SpellCastStart(5, 740, "Aeolyne")
    Testing:SpellCastSuccess(5.2, 740, "Aeolyne")

    Testing:SpellAuraApplied(10, 81572, "The Boss")
    Testing:SpellCastSuccess(12, 62618, "Kondec")

    Testing:RaidBossEmote(15, "I will breathe fire on you!")
    Testing:SpellCastSuccess(16, 31821, "Anticipâte")

    Testing:SpellCastSuccess(20, 88853, "The Boss")
    Testing:SpellCastStart(21, 740, "Clutex")
    Testing:SpellCastSuccess(21.2, 740, "Clutex")
    Testing:SpellCastSuccess(21, 31821, "Elí")

    Testing:SpellCastSuccess(23, 88853, "Bushtree")
    Testing:SpellCastSuccess(26, 88853, "The Boss")

    Testing:SpellCastStart(30, 105256, "The Boss", "Bushpoke")
    Testing:SpellCastSuccess(31, 105256, "The Boss", "Bushpoke")
    Testing:SpellCastStart(33, 105256, "The Boss", "Oldmanbush")
    Testing:SpellCastSuccess(34, 105256, "The Boss", "Oldmanbush")
    Testing:SpellCastSuccess(34, 98008, "Venmir")
    Testing:SpellCastStart(36, 105256, "The Boss", "Bushtree")
    Testing:SpellCastSuccess(37, 105256, "The Boss", "Bushtree")

    Testing:SpellAuraRemoved(41, 63510, "The Boss", "Dableach")
    Testing:SpellCastStart(42, 99052, "The Boss", "Sarune")
    Testing:SpellCastSuccess(43, 99052, "The Boss", "Sarune")
    Testing:SpellAuraRemoved(44, 63510, "The Boss", "Dableach")
    Testing:SpellCastStart(45, 99052, "The Boss", "Sarune")
    Testing:SpellCastSuccess(46, 99052, "The Boss", "Sarune")
    Testing:SpellCastSuccess(47, 740, "Bushtree")
    Testing:SpellAuraRemoved(48, 63510, "The Boss", "Dableach")
    Testing:SpellCastStart(49, 99052, "The Boss", "Sarune")
    Testing:SpellCastSuccess(50, 99052, "The Boss", "Sarune")

    Testing:SpellCastStart(55, 98934, "The Boss")
    Testing:SpellCastStart(58, 98934, "The Boss")
    Testing:SpellCastStart(61, 98934, "The Boss")

    Testing:EndTest(66)
end