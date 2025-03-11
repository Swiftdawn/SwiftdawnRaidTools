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

    -- Encounter Start trigger
    Testing:SpellCastStart(5, 740, "Aeolyne")
    Testing:SpellCastSuccess(5.2, 740, "Aeolyne")

    -- Aura Applied trigger
    Testing:SpellAuraApplied(10, 81572, "The Boss")
    Testing:SpellCastSuccess(12, 62618, "Kondec")

    -- Emote trigger
    Testing:RaidBossEmote(15, "I will breathe fire on you!")
    Testing:SpellCastSuccess(16, 31821, "Anticipâte")

    -- Spell Cast By trigger
    Testing:SpellCastSuccess(20, 88853, "The Boss")
    Testing:SpellCastSuccess(21, 88853, "Bushtree")
    Testing:SpellCastSuccess(22, 88853, "The Boss")
    Testing:SpellCastStart(23, 740, "Clutex")
    Testing:SpellCastSuccess(23.2, 740, "Clutex")
    Testing:SpellCastSuccess(23.4, 31821, "Elí")

    -- Spell Cast On trigger
    Testing:SpellCastStart(30, 105256, "The Boss", "Bushpoke")
    Testing:SpellCastSuccess(31, 105256, "The Boss", "Bushpoke")
    Testing:SpellCastStart(33, 105256, "The Boss", "Oldmanbush")
    Testing:SpellCastSuccess(34, 105256, "The Boss", "Oldmanbush")
    Testing:SpellCastSuccess(34, 98008, "Venmir")
    Testing:SpellCastStart(34, 64843, "Kondec")
    Testing:SpellCastSuccess(34.2, 64843, "Kondec")
    Testing:SpellCastStart(36, 105256, "The Boss", "Bushtree")
    Testing:SpellCastSuccess(37, 105256, "The Boss", "Bushtree")

    -- Aura Removed Count trigger
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

    -- Spell Cast Count trigger
    Testing:SpellCastStart(55, 98934, "The Boss")
    Testing:SpellCastStart(58, 98934, "The Boss")
    Testing:SpellCastStart(58.3, 64843, "Managobrr")
    Testing:SpellCastSuccess(58.5, 64843, "Managobrr")
    Testing:SpellCastStart(61, 98934, "The Boss")

    Testing:EndTest(66)
end