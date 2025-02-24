Condition = {
    AuraRemovedCount = {
        name = "Aura Removed Count",
        creator = function ()
            return AuraRemovedCountCondition:New()
        end
    },
    CastCount = {
        name = "Spell Cast Count",
        creator = function ()
            return CastCountCondition:New()
        end
    },
    UnitHealth = {
        name = "Unit Health",
        creator = function ()
            return UnitHealthCondition:New()
        end
    }
}