Trigger = {
    UnitHealth = {
        name = "Unit health",
        creator = function ()
            return UnitHealthTrigger:New()
        end
    },
    SpellCast = {
        name = "Spell cast",
        creator = function ()
            return SpellCastTrigger:New()
        end
    },
    BossEmote = {
        name = "Boss emote",
        creator = function ()
            return BossEmoteTrigger:New()
        end
    },
    StartEncounter = {
        name = "After X time",
        creator = function ()
            return EncounterStartTrigger:New()
        end
    },
    Aura = {
        name = "Aura activated",
        creator = function ()
            return SpellAuraTrigger:New()
        end
    },
    AuraRemoved = {
        name = "Aura removed",
        creator = function ()
            return SpellAuraRemovedTrigger:New()
        end
    },
    NumenTimer = {
        name = "Numen timer",
        creator = function ()
            return NumenTimerTrigger:New()
        end
    }
}