local SwiftdawnRaidTools = SwiftdawnRaidTools

AssignmentsController = {
    -- key: unitId, value = triggers
    unitHealthTriggersCache = {},
    -- key: unitId, value = triggers
    unitHealthUntriggersCache = {},
    -- key: spellId, value = triggers
    spellCastTriggersCache = {},
    -- key: spellId, value = triggers
    spellCastUntriggersCache = {},
    -- key: spellId, value = triggers
    spellAuraTriggersCache = {},
    -- key: spellId, value = triggers
    spellAuraUntriggersCache = {},
    -- key: spellId, value = triggers
    spellAuraRemovedTriggersCache = {},
    -- key: spellId, value = triggers
    spellAuraRemovedUntriggersCache = {},
    -- key: text, value = triggers
    raidBossEmoteTriggersCache = {},
    -- key: text, value = triggers
    raidBossEmoteUntriggersCache = {},
    -- key: fojji key, value = triggers
    fojjiNumenTimersTriggersCache = {},
    -- key: fojji key, value = C_Timer.NewTimer
    fojjiNumenTimers = {},
    -- key: part uuid, value = [C_Timer.NewTimer]
    delayTimers = {},
    -- key: spellid, value = number of casts
    spellCastCache = {},
    activeEncounterID = nil,
    encounterStart = nil
}

function AssignmentsController:ResetState()
    AssignmentsController.activeEncounterID = nil
    AssignmentsController.encounterStart = nil
    AssignmentsController.unitHealthTriggersCache = {}
    AssignmentsController.unitHealthUntriggersCache = {}
    AssignmentsController.spellCastTriggersCache = {}
    AssignmentsController.spellCastUntriggersCache = {}
    AssignmentsController.spellAuraTriggersCache = {}
    AssignmentsController.spellAuraRemovedTriggersCache = {}
    AssignmentsController.spellAuraUntriggersCache = {}
    AssignmentsController.raidBossEmoteTriggersCache = {}
    AssignmentsController.raidBossEmoteUntriggersCache = {}
    AssignmentsController.fojjiNumenTimersTriggersCache = {}
    AssignmentsController.spellCastCache = {}

    for key, timer in pairs(AssignmentsController.fojjiNumenTimers) do
        timer:Cancel()
        AssignmentsController.fojjiNumenTimers[key] = nil
    end

    for uuid, timers in pairs(AssignmentsController.delayTimers) do
        for _, timer in ipairs(timers) do
            timer:Cancel()
        end

        AssignmentsController.delayTimers[uuid] = nil
    end
end

function AssignmentsController:GetActiveEncounter()
    if not AssignmentsController.activeEncounterID then
        return {}
    end
    return SRTData.GetActiveEncounters()[AssignmentsController.activeEncounterID]
end

function AssignmentsController:StartEncounter(encounterID, encounterName)
    AssignmentsController:ResetState()

    if not SRT_IsTesting() and not Utils:IsPlayerRaidLeader() then
        return
    end

    if not SRTData.GetActiveEncounters()[encounterID] then
        Log.debug("No active encounter found!")
        return
    end

    AssignmentsController.activeEncounterID = encounterID
    AssignmentsController.encounterStart = Utils:Timestamp()

    AssignmentsController:UpdateGroups()

    -- Populate caches
    for _, part in ipairs(AssignmentsController:GetActiveEncounter()) do
        if part.type == "RAID_ASSIGNMENTS" then
            local triggerClones = Utils:DeepClone(part.triggers)

            for _, trigger in ipairs(triggerClones) do
                trigger.triggered = false
                trigger.uuid = part.uuid

                if trigger.type == "ENCOUNTER_START" then
                    AssignmentsController:Trigger(trigger, { encounterName = encounterName })
                elseif trigger.type == "UNIT_HEALTH" then
                    if not AssignmentsController.unitHealthTriggersCache[trigger.unit] then
                        AssignmentsController.unitHealthTriggersCache[trigger.unit] = {}
                    end
                    table.insert(AssignmentsController.unitHealthTriggersCache[trigger.unit], trigger)
                elseif trigger.type == "SPELL_CAST" then
                    if not AssignmentsController.spellCastTriggersCache[trigger.spell_id] then
                        AssignmentsController.spellCastTriggersCache[trigger.spell_id] = {}
                    end
                    table.insert(AssignmentsController.spellCastTriggersCache[trigger.spell_id], trigger)
                elseif trigger.type == "SPELL_AURA" then
                    if not AssignmentsController.spellAuraTriggersCache[trigger.spell_id] then
                        AssignmentsController.spellAuraTriggersCache[trigger.spell_id] = {}
                    end
                    table.insert(AssignmentsController.spellAuraTriggersCache[trigger.spell_id], trigger)
                elseif trigger.type == "SPELL_AURA_REMOVED" then
                    if not AssignmentsController.spellAuraRemovedTriggersCache[trigger.spell_id] then
                        AssignmentsController.spellAuraRemovedTriggersCache[trigger.spell_id] = {}
                    end
                    table.insert(AssignmentsController.spellAuraRemovedTriggersCache[trigger.spell_id], trigger)
                elseif trigger.type == "RAID_BOSS_EMOTE" then
                    if not AssignmentsController.raidBossEmoteTriggersCache[trigger.text] then
                        AssignmentsController.raidBossEmoteTriggersCache[trigger.text] = {}
                    end
                    table.insert(AssignmentsController.raidBossEmoteTriggersCache[trigger.text], trigger)
                elseif trigger.type == "FOJJI_NUMEN_TIMER" then
                    if not AssignmentsController.fojjiNumenTimersTriggersCache[trigger.key] then
                        AssignmentsController.fojjiNumenTimersTriggersCache[trigger.key] = {}
                    end
                    table.insert(AssignmentsController.fojjiNumenTimersTriggersCache[trigger.key], trigger)
                end
            end

            if part.untriggers then
                local untriggerClones = Utils:DeepClone(part.untriggers)

                for _, untrigger in ipairs(untriggerClones) do
                    untrigger.triggered = false
                    untrigger.uuid = part.uuid

                    if untrigger.type == "UNIT_HEALTH" then
                        if not AssignmentsController.unitHealthUntriggersCache[untrigger.unit] then
                            AssignmentsController.unitHealthUntriggersCache[untrigger.unit] = {}
                        end
                        table.insert(AssignmentsController.unitHealthUntriggersCache[untrigger.unit], untrigger)
                    elseif untrigger.type == "SPELL_CAST" then
                        if not AssignmentsController.spellCastUntriggersCache[untrigger.spell_id] then
                            AssignmentsController.spellCastUntriggersCache[untrigger.spell_id] = {}
                        end
                        table.insert(AssignmentsController.spellCastUntriggersCache[untrigger.spell_id], untrigger)
                    elseif untrigger.type == "SPELL_AURA" then
                        if not AssignmentsController.spellAuraUntriggersCache[untrigger.spell_id] then
                            AssignmentsController.spellAuraUntriggersCache[untrigger.spell_id] = {}
                        end
                        table.insert(AssignmentsController.spellAuraUntriggersCache[untrigger.spell_id], untrigger)
                    elseif untrigger.type == "SPELL_AURA_REMOVED" then
                        if not AssignmentsController.spellAuraRemovedUntriggersCache[untrigger.spell_id] then
                            AssignmentsController.spellAuraRemovedUntriggersCache[untrigger.spell_id] = {}
                        end
                        table.insert(AssignmentsController.spellAuraRemovedUntriggersCache[untrigger.spell_id], untrigger)
                    elseif untrigger.type == "RAID_BOSS_EMOTE" then
                        if not AssignmentsController.raidBossEmoteUntriggersCache[untrigger.text] then
                            AssignmentsController.raidBossEmoteUntriggersCache[untrigger.text] = {}
                        end
                        table.insert(AssignmentsController.raidBossEmoteUntriggersCache[untrigger.text], untrigger)
                    end
                end
            end
        end
    end

    Log.info(string.format("Encounter '%s' (id:%s) starting at %s", tostring(encounterName), tostring(encounterID), tostring(AssignmentsController.encounterStart)))
end

function AssignmentsController:EndEncounter(encounterID, encounterName, success)
    if not AssignmentsController.activeEncounterID then
        return
    end
    if not encounterID then
        Log.info("Encounter ended, zone changed!")
    else
        Log.info(string.format("Encounter '%s' (id:%s) ended with %s at %s", tostring(encounterName), tostring(encounterID), success and "SUCCESS" or "FAILURE", Utils:Timestamp()))
    end

    AssignmentsController:ResetState()
    Groups.Reset()
    SwiftdawnRaidTools.overview:UpdateActiveGroups()
end

function AssignmentsController:IsInEncounter()
    return AssignmentsController.activeEncounterID ~= nil
end

function AssignmentsController:IsGroupsEqual(grp1, grp2)
    if grp1 == nil and grp2 == nil then
        return true
    end

    if grp1 == nil or grp2 == nil then
        return false
    end

    if #grp1 ~= #grp2 then
        return false
    end

    local grp1Copy = Utils:ShallowClone(grp1)
    local grp2Copy = Utils:ShallowClone(grp2)

    table.sort(grp1Copy)
    table.sort(grp2Copy)

    for i = 1, #grp1Copy do
        if grp1Copy[i] ~= grp2Copy[i] then
            return false
        end
    end

    return true
end

function AssignmentsController:UpdateGroups()
    if not AssignmentsController.activeEncounterID then
        return
    end

    local groupsUpdated = false

    for _, part in ipairs(AssignmentsController:GetActiveEncounter()) do
        if part.type == "RAID_ASSIGNMENTS" then
            -- Prevent active group from being updated if all spells in the current active group is still ready
            local allActiveGroupsReady = true

            local activeGroups = Groups.GetActive(part.uuid)

            if not activeGroups or #activeGroups == 0 then
                allActiveGroupsReady = false
            else
                for _, groupIndex in ipairs(activeGroups) do
                    local group = part.assignments[groupIndex]

                    for _, assignment in ipairs(group) do
                        if not SpellCache.IsSpellReady(assignment.player, assignment.spell_id) then
                            allActiveGroupsReady = false
                        end
                    end
                end
            end

            if not allActiveGroupsReady then
                local selectedGroups = AssignmentsController:SelectGroup(part.assignments)

                if not AssignmentsController:IsGroupsEqual(activeGroups, selectedGroups) then
                    Log.debug("Updated groups for", part.uuid, Utils:StringJoin(selectedGroups))

                    groupsUpdated = true
                    Groups.SetActive(part.uuid, selectedGroups)
                end
            end
        end
    end

    if groupsUpdated then
        Log.debug("Sending message ACT_GRPS", Groups.GetAllActive())
        SwiftdawnRaidTools:SendRaidMessage("ACT_GRPS", Groups.GetAllActive())
    end
end

function AssignmentsController:SelectBestMatchIndex(assignments)
    local bestMatchIndex = nil
    local maxReadySpells = 0

    -- First pass: check for a group where all assignments are ready
    for i, group in ipairs(assignments) do
        local ready = true
        for _, assignment in ipairs(group) do
            if not SpellCache.IsSpellActive(assignment.player, assignment.spell_id, GetTime() + 5) and not SpellCache.IsSpellReady(assignment.player, assignment.spell_id) then
                ready = false
                break
            end
        end
        if ready then
            return i
        end
    end

    -- Second pass: Find the group with the most ready assignments
    for i, group in pairs(assignments) do
        local readySpells = 0
        for _, assignment in ipairs(group) do
            if SpellCache.IsSpellActive(assignment.player, assignment.spell_id, GetTime() + 5) or SpellCache.IsSpellReady(assignment.player, assignment.spell_id) then
                readySpells = readySpells + 1
            end
        end
        if readySpells > maxReadySpells then
            bestMatchIndex = i
            maxReadySpells = readySpells
        end
    end

    return bestMatchIndex
end

function AssignmentsController:SelectGroup(assignments)
    local groups = {}

    local bestMatchIndex = AssignmentsController:SelectBestMatchIndex(assignments)

    if bestMatchIndex then
        table.insert(groups, bestMatchIndex)
    end

    return groups
end

function AssignmentsController:CheckTriggerConditions(conditions)
    if conditions then
        for _, condition in ipairs(conditions) do
            if condition.type == "UNIT_HEALTH" then
                local health = UnitHealth(condition.unit)

                if condition.lt and health >= condition.lt then
                    return false
                end

                if condition.gt and health <= condition.gt then
                    return false
                end

                if condition.pct_lt then
                    local maxHealth = UnitHealthMax(condition.unit)

                    local pct = health / maxHealth * 100

                    if pct >= condition.pct_lt then
                        return false
                    end
                end

                if condition.pct_gt then
                    local maxHealth = UnitHealthMax(condition.unit)

                    local pct = health / maxHealth * 100

                    if pct <= condition.pct_gt then
                        return false
                    end
                end
            elseif condition.type == "SPELL_CAST_COUNT" then
                local casts = AssignmentsController.spellCastCache[condition.spell_id]

                if condition.eq then
                    if not casts or casts ~= condition.eq then
                        return false
                    end
                end

                if condition.lt then
                    if casts and casts >= condition.lt then
                         return false
                    end
                end

                if condition.gt then
                    if not casts or casts <= condition.gt then
                        return false
                    end
                end
            end
        end
    end

    return true
end

function AssignmentsController:Trigger(trigger, context, countdown, ignoreTriggerDelay)
    Log.debug("TRIGGER "..tostring(trigger.type), { trigger = trigger, context = context, countdown = countdown, ignoreTriggerDelay = ignoreTriggerDelay })

    if trigger.throttle then
        if trigger.lastTriggerTime and GetTime() < trigger.lastTriggerTime + trigger.throttle then
            Log.debug("TRIGGER "..tostring(trigger.type)..": Throttled", { trigger = trigger, context = context, countdown = countdown, ignoreTriggerDelay = ignoreTriggerDelay })
            return
        end
    end

    if not AssignmentsController:CheckTriggerConditions(trigger.conditions) then
        Log.debug("TRIGGER "..tostring(trigger.type)..": Conditions did not pass", { trigger = trigger, context = context, countdown = countdown, ignoreTriggerDelay = ignoreTriggerDelay })
        return
    end

    local activeGroups = Groups.GetActive(trigger.uuid)

    countdown = countdown or trigger.countdown or 0

    context = context or {}

    local delay = trigger.delay or 0

    if activeGroups and #activeGroups > 0 then
        local data = {
            triggerType = trigger.type,
            uuid = trigger.uuid,
            activeGroups = activeGroups,
            countdown = countdown,
            delay = delay,
            context = context
        }

        Log.debug("TRIGGER "..tostring(trigger.type)..": Found groups", data)

        if not ignoreTriggerDelay and (trigger.delay and trigger.delay > 0) then
            if not AssignmentsController.delayTimers[trigger.uuid] then
                AssignmentsController.delayTimers[trigger.uuid] = {}
            end

            table.insert(AssignmentsController.delayTimers[trigger.uuid], C_Timer.NewTimer(trigger.delay, function()
                -- We trigger it at a delay with the ignoreTriggerDelay on so it wont be delayed again
                AssignmentsController:Trigger(trigger, context, countdown, true)
            end))
        else
            trigger.lastTriggerTime = GetTime()
            Log.debug("Sending message TRIGGER "..tostring(trigger.type), data)
            SwiftdawnRaidTools:SendRaidMessage("TRIGGER", data)
        end
    end
end

function AssignmentsController:CancelDelayTimers(uuid)
    Log.debug("Cancelling timers for", uuid)
    if AssignmentsController.delayTimers[uuid] then
        for _, timer in ipairs(AssignmentsController.delayTimers[uuid]) do
            timer:Cancel()
        end
        AssignmentsController.delayTimers[uuid] = nil
    end
end

function AssignmentsController:HandleUnitHealth(unit)
    if not AssignmentsController.activeEncounterID then
        return
    end

    local triggers = AssignmentsController.unitHealthTriggersCache[unit]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if not trigger.triggered then
                local health = UnitHealth(unit)
                local maxHealth = UnitHealthMax(unit)
                local pct = health / maxHealth * 100

                local shouldTrigger = false

                if trigger.lt and health < trigger.lt then
                    shouldTrigger = true
                end

                if trigger.gt and health > trigger.gt then
                    shouldTrigger = true
                end

                if trigger.pct_lt and pct < trigger.pct_lt then
                    shouldTrigger = true
                end

                if trigger.pct_gt and pct > trigger.pct_gt then
                    shouldTrigger = true
                end

                if shouldTrigger then
                    trigger.triggered = true
                    local context = {
                        unit_name = UnitName(unit),
                        health = health,
                        health_pct = pct
                    }
                    AssignmentsController:Trigger(trigger, context)
                end
            end
        end
    end

    -- TODO: Should probably log something about this as well

    local untriggers = AssignmentsController.unitHealthUntriggersCache[unit]

    if untriggers then
        for _, untrigger in ipairs(untriggers) do
            if not untrigger.triggered then
                local health = UnitHealth(unit)

                local shouldTrigger = false

                if untrigger.lt and health < untrigger.lt then
                    shouldTrigger = true
                end

                if untrigger.pct_lt then
                    local maxHealth = UnitHealthMax(unit)

                    local pct = health / maxHealth * 100

                    if pct < untrigger.pct_lt then
                        shouldTrigger = true
                    end
                end

                if shouldTrigger then
                    untrigger.triggered = true

                    AssignmentsController:CancelDelayTimers(untrigger.uuid)
                end
            end
        end
    end
end

function AssignmentsController:HandleSpellCast(event, spellId, sourceName, destName)
    if not AssignmentsController.activeEncounterID then
        return
    end

    local triggers = AssignmentsController.spellCastTriggersCache[spellId]

    if event == "SPELL_CAST_SUCCESS" then
        if not AssignmentsController.spellCastCache[spellId] then
            AssignmentsController.spellCastCache[spellId] = 0
        end
        AssignmentsController.spellCastCache[spellId] = AssignmentsController.spellCastCache[spellId] + 1
    end

    if triggers then
        local spellInfo = C_Spell.GetSpellInfo(spellId)

        local ctx = {
            spell_name = spellInfo.name,
            source_name = sourceName,
            dest_name = destName
        }

        -- We don't want to handle a spellcast twice so we only look for start events or success events for instant cast spells
        if event == "SPELL_CAST_START" or (event == "SPELL_CAST_SUCCESS" and (not spellInfo.castTime or spellInfo.castTime == 0)) then
            for _, trigger in ipairs(triggers) do
                local countdown = spellInfo.castTime / 1000
                AssignmentsController:Trigger(trigger, ctx, countdown)
            end
        end
    end

    local untriggers = AssignmentsController.spellCastUntriggersCache[spellId]

    if untriggers then
        local spellInfo = C_Spell.GetSpellInfo(spellId)

        if event == "SPELL_CAST_START" or (event == "SPELL_CAST_SUCCESS" and (not spellInfo.castTime or spellInfo.castTime == 0)) then
            for _, untrigger in ipairs(untriggers) do
                AssignmentsController:CancelDelayTimers(untrigger.uuid)
            end
        end
    end
end

function AssignmentsController:HandleSpellAura(subEvent, spellId, sourceName, destName)
    if not AssignmentsController.activeEncounterID then
        return
    end

    local spellName = C_Spell.GetSpellName(spellId)

    local ctx = {
        spell_name = spellName,
        source_name = sourceName,
        dest_name = destName
    }

    if subEvent == "SPELL_AURA_APPLIED" then
        local triggers = AssignmentsController.spellAuraTriggersCache[spellId]

        if triggers then
            for _, trigger in ipairs(triggers) do
                AssignmentsController:Trigger(trigger, ctx)
            end
        end
    
        local untriggers = AssignmentsController.spellAuraUntriggersCache[spellId]
    
        if untriggers then
            for _, untrigger in ipairs(untriggers) do
                AssignmentsController:CancelDelayTimers(untrigger.uuid)
            end
        end
    elseif subEvent == "SPELL_AURA_REMOVED" then
        local triggers = AssignmentsController.spellAuraRemovedTriggersCache[spellId]

        if triggers then
            for _, trigger in ipairs(triggers) do
                AssignmentsController:Trigger(trigger, ctx)
            end
        end
    
        local untriggers = AssignmentsController.spellAuraRemovedUntriggersCache[spellId]
    
        if untriggers then
            for _, untrigger in ipairs(untriggers) do
                AssignmentsController:CancelDelayTimers(untrigger.uuid)
            end
        end
    end
end

function AssignmentsController:HandleRaidBossEmote(text)
    if not AssignmentsController.activeEncounterID then
        return
    end

    Log.debug("Handling raid boss emote: ", text)

    for _, triggers in pairs(AssignmentsController.raidBossEmoteTriggersCache) do
        for _, trigger in ipairs(triggers) do
            if text:match(trigger.text) ~= nil then
                Log.debug("Found raid boss emote TRIGGER match", trigger)
                AssignmentsController:Trigger(trigger, { text = text })
            end
        end
    end

    for _, untriggers in pairs(AssignmentsController.raidBossEmoteUntriggersCache) do
        for _, untrigger in ipairs(untriggers) do
            if text:match(untrigger.text) ~= nil then
                Log.debug("Found raid boss emote UNTRIGGER match", trigger)
                AssignmentsController:CancelDelayTimers(untrigger.uuid)
            end
        end
    end
end

function AssignmentsController:CancelFojjiNumenTimer(key)
    local timer = AssignmentsController.fojjiNumenTimers[key]

    if timer then
        timer:Cancel()
        AssignmentsController.fojjiNumenTimers[key] = nil
    end
end

function AssignmentsController:HandleFojjiNumenTimer(key, countdown)
    if not AssignmentsController.activeEncounterID or not countdown then
        return
    end

    local triggers = AssignmentsController.fojjiNumenTimersTriggersCache[key]

    if triggers then
        for _, trigger in ipairs(triggers) do
            if countdown <= 5 then
                AssignmentsController:Trigger(trigger, nil, countdown)
            else
                AssignmentsController:CancelFojjiNumenTimer(key)

                AssignmentsController.fojjiNumenTimers[key] = C_Timer.NewTimer(countdown - 5, function()
                    AssignmentsController:Trigger(trigger, nil, 5)
                end)
            end
        end
    end
end
