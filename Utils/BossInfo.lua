BossInfo = {
    initialized = false,
    instances = {}
}

function BossInfo.Initialize()
    if BossInfo.initialized then
        return
    end

    local currTier = EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers()
    for tierIndex = 1, numTiers do
        EJ_SelectTier(tierIndex)
        local instance_index = 1
        while true do
            local instanceID, instanceName, instanceDescription, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, instanceLink, shouldDisplayDifficulty, mapID = EJ_GetInstanceByIndex(instance_index, true)
            if instanceID then
                EJ_SelectInstance(instanceID)
                local instanceInfo = {
                    name = instanceName,
                    description = instanceDescription,
                    encounters = {},
                    dungeonAreaMapID = dungeonAreaMapID,
                    link = instanceLink,
                    shouldDisplayDifficulty = shouldDisplayDifficulty,
                    mapID = mapID
                }
                local encounter_index = 1
                while true do
                    local encounterName, encounterDescription, journalEncounterID, rootSectionID, encounterLink, journalInstanceID, dungeonEncounterID, _ = EJ_GetEncounterInfoByIndex(encounter_index, instanceID)
                    if encounterName then
                        instanceInfo.encounters[dungeonEncounterID] = {
                            name = encounterName,
                            description = encounterDescription,
                            journalEncounterID = journalEncounterID,
                            rootSectionID = rootSectionID,
                            link = encounterLink,
                            journalInstanceID = journalInstanceID,
                            dungeonEncounterID = dungeonEncounterID
                        }
                    else
                        break
                    end
                    if instanceInfo.encounters[dungeonEncounterID].rootSectionID then
                        instanceInfo.encounters[dungeonEncounterID].journal = BossInfo.BuildSectionJournal(instanceInfo.encounters[dungeonEncounterID].rootSectionID)
                    end
                    encounter_index = encounter_index + 1
                end
                BossInfo.instances[instanceID] = instanceInfo
            else
                break
            end
            instance_index = instance_index + 1
        end
    end

    -- Switch Shannox and Alysrazor
    if BossInfo.instances[78] then
        local actuallyShannox = BossInfo.instances[78].encounters[1205] or nil
        local actuallyAlysrazor = BossInfo.instances[78].encounters[1206] or nil
        BossInfo.instances[78].encounters[1205] = actuallyAlysrazor
        BossInfo.instances[78].encounters[1206] = actuallyShannox
    end

    -- Add bosses not in the encounter journal until discovered
    BossInfo.instances[72].encounters[1082] = { name = "Sinestra" }
    BossInfo.instances[72].encounters[1083] = { name = "Sinestra" }
    BossInfo.instances[72].encounters[42001] = { name = "Main Test Boss" }
    BossInfo.instances[72].encounters[42002] = { name = "Sequential Test Boss" }

    EJ_SelectTier(currTier)
    if DevTool then DevTool:AddData(BossInfo, "BossInfo") end
    BossInfo.initialized = true
end

function BossInfo.Get()
    if not BossInfo.initialized then
        BossInfo.Initialize()
    end
    return BossInfo
end

function BossInfo.GetEncounterInfoByID(encounterID)
    for _, instanceInfo in Utils:OrderedPairs(BossInfo.Get().instances) do
        for storedEncounterID, encounterInfo in Utils:OrderedPairs(instanceInfo.encounters) do
            if storedEncounterID == encounterID then
                return encounterInfo
            end
        end
    end
    return nil
end

function BossInfo.GetNameByID(encounterID)
    if encounterID == 42001 then
        return "The Test Boss"
    end
    return BossInfo.Get().GetEncounterInfoByID(encounterID).name
end

function BossInfo.BuildSectionJournal(rootSectionID)
    local sectionJournal = {}
    ---@class EncounterJournalSectionInfo
    local sectionInfo = C_EncounterJournal.GetSectionInfo(rootSectionID)
    if not sectionInfo then
        return nil
    end
    while sectionInfo do
        if sectionInfo.firstChildSectionID then
            sectionInfo.children = BossInfo.BuildSectionJournal(sectionInfo.firstChildSectionID)
        end
        table.insert(sectionJournal, sectionInfo)
        if sectionInfo.siblingSectionID then
            sectionInfo = C_EncounterJournal.GetSectionInfo(sectionInfo.siblingSectionID)
        else
            break
        end
    end
    return sectionJournal
end