local SwiftdawnRaidTools = SwiftdawnRaidTools

local function stringSafe(thing, indent)
    if type(thing) ~= "table" then
        return thing or ""
    end

    local result = {}
    local indent = indent or 0
    local padding = string.rep("  ", indent)
    
    table.insert(result, "{\n")
    
    for k, v in pairs(thing) do
        local key
        if type(k) == "string" then
            key = string.format("%s[%q] = ", padding, k)
        else
            key = string.format("%s[%s] = ", padding, tostring(k))
        end
        
        local value
        if type(v) == "table" then
            value = stringSafe(v, indent + 1)
        elseif type(v) == "string" then
            value = string.format("%q", v)
        else
            value = tostring(v)
        end
        
        table.insert(result, key .. value .. ",\n")
    end
    
    table.insert(result, padding .. "}")
    
    return table.concat(result)
end

local function validateRequiredFields(import)
    if not import.type then
        return false, "Import is missing a type field"
    end
    if not import.encounter then
        return false, "Import is missing an encounter field"
    end

    return true
end

local function validateTypeAndVersion(import)
    if not import.type then
        return false, "Import is missing a type field."
    end

    if import.type ~= "RAID_ASSIGNMENTS" then
        return false, "Import has an unknown type: " .. stringSafe(import.type) .. "."
    end

    if not import.version then
        return false, "Import is missing a version field."
    end
    if import.version ~= 1 then
        return false, "Import has an unknown version: " .. stringSafe(import.version) .. "."
    end

    return true
end

local function validateEncounter(import)
    if type(import.encounter) ~= "number" or import.encounter ~= math.floor(import.encounter) then
        return false, "Import has an invalid encounter value: " .. stringSafe(import.encounter) .. ".."
    end

    if not BossInfo.GetEncounterInfoByID(import.encounter) then
        return false, "Import has an unknown encounter value: " .. stringSafe(import.encounter) .. "."
    end

    return true
end

local function validateRaidAssignments(import)
    if import.type == "RAID_ASSIGNMENTS" then
        if not import.assignments then
            return false, "Import with type RAID_ASSIGNMENTS is missing a assignments field."
        end

        if type(import.assignments) ~= "table" then
            return false, "Import has an invalid assignments value: " .. stringSafe(import.assignments) .. "."
        end

        for _, group in ipairs(import.assignments) do
            if type(group) ~= "table" then
                return false, "Import has an invalid assignments value: " .. stringSafe(group) .. "."
            end
        end

        if not import.triggers then
            return false, "Import with type RAID_ASSIGNMENTS is missing a triggers field."
        end

        if type(import.triggers) ~= "table" or not Utils:IsArray(import.triggers) then
            return false, "Import has an invalid triggers value: " .. stringSafe(import.triggers) .. "."
        end

        if import.untriggers and (type(import.untriggers) ~= "table" or not Utils:IsArray(import.untriggers)) then
            return false, "Import has an invalid untriggers value: " .. stringSafe(import.untriggers) .. "."
        end

        if not import.metadata then
            return false, "Import with type RAID_ASSIGNMENTS is missing a metadata field."
        end

        if not import.metadata.name then
            return false, "Import metadata requires a name field."
        end

        if import.metadata.spell_id and (type(import.metadata.spell_id) ~= "number" or import.metadata.spell_id ~= math.floor(import.metadata.spell_id)) then
            return false, "Import has an invalid spell_id value: " .. stringSafe(import.spell_id) .. "."
        end

        if not import.assignments then
            return false, "Import with type RAID_ASSIGNMENTS is missing an assignments field."
        end

        if type(import.assignments) ~= "table" or not Utils:IsArray(import.assignments) then
            return false, "Import has an invalid assignments value: " .. stringSafe(import.assignments) .. "."
        end

        if #import.assignments == 0 then
            return false, "Import assignments is empty."
        end
        
        for _, group in pairs(import.assignments) do
            if type(group) ~= "table" or not Utils:IsArray(group) then
                return false, "Import has an invalid assignments value: " .. stringSafe(group) .. "."
            end

            if #group > 2 then
                return false, "Import has invalid assignments: " .. stringSafe(group) .. ". The group size is more than 2."
            end

            for _, assignment in pairs(group) do
                if type(assignment) ~= "table" then
                    return false, "Import has an invalid assignments value: " .. stringSafe(assignment) .. "."
                end

                if not assignment.type then
                    return false, "Import has a invalid assignments field. Missing type: " .. stringSafe(assignment)
                end

                if not assignment.player then
                    return false, "Import has a invalid assignments field. Missing player: " .. stringSafe(assignment)
                end
                if not assignment.spell_id then
                    return false, "Import has a invalid assignments field. Missing spell_id: " .. stringSafe(assignment)
                end
                if type(assignment.spell_id) ~= "number" or assignment.spell_id ~= math.floor(assignment.spell_id) then
                    return false, "Import has an unknown spell_id value: " .. stringSafe(assignment.spell_id) .. "."
                end
                if not SRTData.GetSpellByID(assignment.spell_id) then
                    return false, "Import has a spell_id that's not supported: " .. stringSafe(assignment.spell_id) .. "."
                end
            end
        end
    end

    return true
end

local function validateTriggers(import)
    if import.triggers then
        for _, trigger in ipairs(import.triggers) do
            if not trigger.type then
                return false, "Import trigger is missing a type field."
            end

            if not (trigger.type == "UNIT_HEALTH" or trigger.type == "SPELL_CAST" or trigger.type == "SPELL_AURA" or trigger.type == "SPELL_AURA_REMOVED" or trigger.type == "RAID_BOSS_EMOTE" or trigger.type == "ENCOUNTER_START" or trigger.type == "FOJJI_NUMEN_TIMER") then
                return false, "Import has an invalid trigger type."
            end

            if trigger.type == "UNIT_HEALTH" then
                if not trigger.unit then
                    return false, "Import with trigger type UNIT_HEALTH is missing a unit field."
                end

                local conditions = 0

                if trigger.lt then
                    conditions = conditions + 1
                end

                if trigger.pct_lt then
                    conditions = conditions + 1
                end

                if conditions ~= 1 then
                    return false, "Import with trigger type UNIT_HEALTH requries exactly one of lt or pct_lt fields."
                end
            end

            if trigger.type == "SPELL_CAST" then
                if not trigger.spell_id then
                    return false, "Import with trigger type SPELL_CAST is missing a spell_id field."
                end

                if type(trigger.spell_id) ~= "number" or trigger.spell_id ~= math.floor(trigger.spell_id) then
                    return false, "Import has an invalid spell_id value: " .. stringSafe(trigger.spell_id) .. "."
                end
            end

            if trigger.type == "SPELL_AURA" then
                if not trigger.spell_id then
                    return false, "Import with trigger type SPELL_AURA is missing a spell_id field."
                end
    
                if type(trigger.spell_id) ~= "number" or trigger.spell_id ~= math.floor(trigger.spell_id) then
                    return false, "Import has an invalid spell_id value: " .. stringSafe(trigger.spell_id) .. "."
                end
            end

            if trigger.type == "SPELL_AURA_REMOVED" then
                if not trigger.spell_id then
                    return false, "Import with trigger type SPELL_AURA_REMOVED is missing a spell_id field."
                end
    
                if type(trigger.spell_id) ~= "number" or trigger.spell_id ~= math.floor(trigger.spell_id) then
                    return false, "Import has an invalid spell_id value: " .. stringSafe(trigger.spell_id) .. "."
                end
            end

            if trigger.type == "RAID_BOSS_EMOTE" then
                if not trigger.text then
                    return false, "Import with trigger type RAID_BOSS_EMOTE is missing a text field."
                end
            end

            if trigger.type == "FOJJI_NUMEN_TIMER" then
                if not trigger.key then
                    return false, "Import with trigger type FOJJI_NUMEN_TIMER is missing a key field."
                end

                if trigger.countdown then
                    return false, "Import with trigger type FOJJI_NUMEN_TIMER has a countdown field."
                end

                if trigger.delay then
                    return false, "Import with trigger type FOJJI_NUMEN_TIMER has a delay field."
                end
            end

            if trigger.countdown and (type(trigger.countdown) ~= "number" or trigger.countdown ~= math.floor(trigger.countdown)) then
                return false, "Import has an invalid countdown value: " .. stringSafe(trigger.countdown) .. "."
            end

            if trigger.delay and (type(trigger.delay) ~= "number" or trigger.delay ~= math.floor(trigger.delay)) then
                return false, "Import has an invalid delay value: " .. stringSafe(trigger.delay) .. "."
            end

            if trigger.throttle and (type(trigger.throttle) ~= "number" or trigger.throttle ~= math.floor(trigger.throttle)) then
                return false, "Import has an invalid throttle value: " .. stringSafe(trigger.delay) .. "."
            end

            if trigger.conditions and type(trigger.conditions) ~= "table"  then
                return false, "Import has an invalid conditions value: " .. stringSafe(trigger.conditions) .. "."
            end

            if trigger.conditions then
                for _, condition in ipairs(trigger.conditions) do
                    if not condition.type then
                        return false, "Import condition is missing a type field."
                    end

                    if not (condition.type == "UNIT_HEALTH") and not (condition.type == "SPELL_CAST_COUNT") then
                        return false, "Import has an invalid condition type."
                    end

                    if condition.type == "UNIT_HEALTH" then
                        if not condition.unit then
                            return false, "Import condition of type UNIT_HEALTH is missing a unit field."
                        end

                        local conditions = 0

                        if condition.lt then
                            conditions = conditions + 1
                        end

                        if condition.gt then
                            conditions = conditions + 1
                        end

                        if condition.pct_lt then
                            conditions = conditions + 1
                        end

                        if condition.pct_gt then
                            conditions = conditions + 1
                        end

                        if conditions ~= 1 then
                            return false, "Import condition of type UNIT_HEALTH requires exactly one of lt, gt, pct_gt or pct_lt fields."
                        end
                    elseif condition.type == "SPELL_CAST_COUNT" then
                        if not condition.spell_id then
                            return false, "Import condition of type SPELL_CAST_COUNT is missing a spell_id field."
                        end

                        if condition.eq then
                            if condition.lt or condition.gt then
                                return false, "Import condition of type SPELL_CAST_COUNT has `eq` combined `gt` or `lt` fields."
                            end
                        else
                            local conditions = 0

                            if condition.lt then
                                conditions = conditions + 1
                            end
    
                            if condition.gt then
                                conditions = conditions + 1
                            end
    
                            if conditions == 0 then
                                return false, "Import condition of type SPELL_CAST_COUNT requires at least one of lt, gt fields."
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end

local function validateUntriggers(import)
    if import.untriggers then
        for _, untrigger in ipairs(import.untriggers) do
            if not untrigger.type then
                return false, "Import untrigger is missing a type field."
            end

            if not (untrigger.type == "UNIT_HEALTH" or untrigger.type == "SPELL_CAST" or untrigger.type == "SPELL_AURA" or untrigger.type == "RAID_BOSS_EMOTE") then
                return false, "Import has an invalid untrigger type."
            end

            if untrigger.type == "UNIT_HEALTH" then
                if not untrigger.unit then
                    return false, "Import with untrigger type UNIT_HEALTH is missing a unit field."
                end

                if not untrigger.percentage then
                    return false, "Import with untrigger type UNIT_HEALTH is missing a percentage field."
                end
            end

            if untrigger.type == "SPELL_CAST" then
                if not untrigger.spell_id then
                    return false, "Import with untrigger type SPELL_CAST is missing a spell_id field."
                end
    
                if type(untrigger.spell_id) ~= "number" or untrigger.spell_id ~= math.floor(untrigger.spell_id) then
                    return false, "Import has an invalid spell_id value: " .. stringSafe(untrigger.spell_id) .. "."
                end
            end

            if untrigger.type == "SPELL_AURA" then
                if not untrigger.spell_id then
                    return false, "Import with trigger type SPELL_AURA is missing a spell_id field."
                end

                if type(untrigger.spell_id) ~= "number" or untrigger.spell_id ~= math.floor(untrigger.spell_id) then
                    return false, "Import has an invalid spell_id value: " .. stringSafe(untrigger.spell_id) .. "."
                end
            end

            if untrigger.type == "RAID_BOSS_EMOTE" then
                if not untrigger.text then
                    return false, "Import with trigger type RAID_BOSS_EMOTE is missing a text field."
                end
            end
        end
    end

    return true
end

Validation = {}

function Validation:ValidateImport(import)
    local ok, err = validateRequiredFields(import)
    if not ok then return false, err end

    ok, err = validateTypeAndVersion(import)
    if not ok then return false, err end

    ok, err = validateEncounter(import)
    if not ok then return false, err end

    ok, err = validateTriggers(import)
    if not ok then return false, err end

    ok, err = validateUntriggers(import)
    if not ok then return false, err end

    ok, err = validateRaidAssignments(import)
    if not ok then return false, err end
    
    return true
end
