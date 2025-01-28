Condition = {
    CastCount = {
        name = "Cast Count",
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