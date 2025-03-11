local SwiftdawnRaidTools = SwiftdawnRaidTools
SequentialTest = {}

function SequentialTest:Start()
    -- Set testing mode
    SRT_SetTestMode(true)

    -- Cancel any existing timers & reset caches
    Testing:CancelTimers()
    Testing:ResetCaches()

    -- Start encounter
    SwiftdawnRaidTools.overview:SelectEncounter(42002)
    AssignmentsController:StartEncounter(42002, "The Boss")

    -- Initiate timers
    Testing:SpellCastStart(5, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(10, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(15, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(20, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(25, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(30, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(35, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(40, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(45, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(50, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(55, 99052, "The Boss", "Sarune")
    Testing:SpellCastStart(60, 99052, "The Boss", "Sarune")

    Testing:EndTest(65)
end