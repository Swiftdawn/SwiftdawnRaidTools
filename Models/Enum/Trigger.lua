Trigger = {
    UnitHealth = {
        name = "Unit health",
        creator = UnitHealthTrigger.New
    },
    SpellCast = {
        name = "Spell cast",
        creator = SpellCastTrigger.New
    },
    BossEmote = {
        name = "Boss emote",
        creator = BossEmoteTrigger.New
    },
    StartEncounter = {
        name = "After X time",
        creator = EncounterStartTrigger.New
    },
    Aura = {
        name = "Aura activated",
        creator = SpellAuraTrigger.New
    },
    AuraRemoved = {
        name = "Aura removed",
        creator = SpellAuraRemovedTrigger.New
    },
    NumenTimer = {
        name = "Numen timer",
        creator = NumenTimerTrigger.New
    }
}