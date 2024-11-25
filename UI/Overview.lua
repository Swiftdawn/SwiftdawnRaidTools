local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

---@class SRTOverview:SRTWindow
SRTOverview = setmetatable({
    bossAbilities = {}
}, SRTWindow)
SRTOverview.__index = SRTOverview

---@return SRTOverview
function SRTOverview:New(height, width)
    local obj = SRTWindow.New(self, "Overview", height, width)
    ---@cast obj SRTOverview
    self.__index = self
    return obj
end

function SRTOverview:Initialize()
    SRTWindow.Initialize(self)
    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and (InCombatLockdown() or AssignmentsController:IsInEncounter()) then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)
    self:UpdateAppearance()
end

function SRTOverview:GetBossAbilityHeight()
    local headerFontSize = self:GetAppearance().headerFontSize
    return headerFontSize + 7
end

function SRTOverview:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function SRTOverview:GetPlayerFont()
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function SRTOverview:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)
    local headerFontSize = self:GetAppearance().headerFontSize
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize

    for _, frame in pairs(self.popupListItems) do
        frame.text:SetFont(self:GetHeaderFont(), 10)
    end

    for _, bossAbilityFrame in pairs(self.bossAbilities) do
        bossAbilityFrame.name:SetFont(self:GetHeaderFont(), headerFontSize)
        for _, assignmentGroupFrame in pairs(bossAbilityFrame.groups) do
            assignmentGroupFrame:SetHeight(self:GetAssignmentGroupHeight())
            for _, assignmentFrame in pairs(assignmentGroupFrame.assignments) do
                assignmentFrame.text:SetFont(self:GetPlayerFont(), playerFontSize)
                assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
                assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
            end
        end
    end

    self:UpdateMain()
end

function SRTOverview:Resize()
    local totalHeight = 16
    for _, bossAbilityFrame in pairs(self.bossAbilities) do
        if bossAbilityFrame:IsShown() then
            totalHeight = totalHeight + bossAbilityFrame:GetHeight() + 7
        end
    end
    self.container:SetHeight(math.max(MIN_HEIGHT, totalHeight))
end

function SRTOverview:Update()
    SRTWindow.Update(self)

    local encounters = SRTData.GetActiveEncounters()
    if encounters[self:GetProfile().selectedEncounterId] == nil then
        local encounterIndexes = {}
        for encounterId in pairs(encounters) do
            table.insert(encounterIndexes, encounterId)
        end
        table.sort(encounterIndexes)
        self:GetProfile().selectedEncounterId = encounterIndexes[1]
    end

    self:UpdateHeaderText()
    self:UpdatePopupMenu()
    self:UpdateMain()
    self:UpdateSpells()
end

function SRTOverview:UpdateHeaderText()
    local encounters = SRTData.GetActiveEncounters()

    local encountersExists = false

    for _ in pairs(encounters) do
        encountersExists = true
        break
    end

    self.headerText:SetAlpha(1)

    if encountersExists then
        self.headerText:SetText(BossEncounters:GetNameByID(self:GetProfile().selectedEncounterId))
    else
        if SwiftdawnRaidTools.encountersProgress then
            self.headerText:SetText((SRTData.GetActiveRosterID() == "none" and "Loading" or "Syncing").." Assignments... |cFFFFFFFF" .. string.format("%.1f", SwiftdawnRaidTools.encountersProgress) .. "%|r")
        else
            self.headerText:SetText("SRT |cFFFFFFFF" .. tostring(SwiftdawnRaidTools.VERSION) .. "|r")
            self.headerText:SetAlpha(0.8)
        end
    end
end

function SRTOverview:SelectEncounter(encounterId)
    self:GetProfile().selectedEncounterId = encounterId
    self:Update()
end

function SRTOverview:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end
    local menuItems = {}
    local encounterIndexes = {}
    for encounterId in pairs(SRTData.GetActiveEncounters()) do
        table.insert(encounterIndexes, encounterId)
    end
    table.sort(encounterIndexes)
    for index, encounterId in ipairs(encounterIndexes) do
        menuItems[index] = { name = BossEncounters:GetNameByID(encounterId), onClick = function() self:SelectEncounter(encounterId) end }
    end
    if #encounterIndexes > 0 then
        table.insert(menuItems, {})
    end
    table.insert(menuItems, {
        name = SRT_Profile().notifications.locked and "Show Anchors" or "Hide Anchors",
        onClick = function()
            SRT_Profile().notifications.locked = not SRT_Profile().notifications.locked
            SwiftdawnRaidTools.notification:ToggleFrameLock(SRT_Profile().notifications.locked)
        end,
        isSetting = true
    })
    table.insert(menuItems, {
        name = self:GetProfile().locked and "Unlock Overview" or "Lock Overview",
        onClick = function()
            self:ToggleLock()
            LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools")
        end,
        isSetting = true
    })
    table.insert(menuItems, {
        name = "Debug Log",
        onClick = function()
            SRT_Profile().debuglog.show = true
            SwiftdawnRaidTools.debugLog:Update()
        end,
        isSetting = true
    })
    table.insert(menuItems, {
        name = "Configuration",
        onClick = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end,
        isSetting = true
    })
    table.insert(menuItems, {})
    table.insert(menuItems, {
        name = "Close",
        onClick = nil,
        isSetting = true
    })
    self.popupMenu.Update(menuItems)
end

function SRTOverview:UpdateMain()
    for _, ability in pairs(self.bossAbilities) do
        ability:Hide()
    end

    local selectedEncounterId = self:GetProfile().selectedEncounterId
    local encounter = SRTData.GetActiveEncounters()[selectedEncounterId]

    if encounter then

        local previousAbilityFrame
        for abilityIndex, ability in ipairs(encounter) do
            local abilityFrame = self.bossAbilities[abilityIndex] or CreateFrame("Frame", nil, self.main)
            if previousAbilityFrame then
                abilityFrame:SetPoint("TOPLEFT", previousAbilityFrame, "BOTTOMLEFT", 0, 0)
                abilityFrame:SetPoint("TOPRIGHT", previousAbilityFrame, "BOTTOMRIGHT", 0, 0)
            else
                abilityFrame:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, -7)
                abilityFrame:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", 0, -7)
            end
            local abilityFrameHeight = 7
    
            abilityFrame.name = abilityFrame.name or abilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            abilityFrame.name:SetPoint("TOPLEFT", abilityFrame, "TOPLEFT", 10, 0)
            abilityFrame.name:SetText(ability.metadata.name)
            abilityFrame.name:SetFont(self:GetHeaderFont(), self:GetAppearance().headerFontSize)
            abilityFrame.name:SetTextColor(1, 1, 1, 0.8)
            abilityFrameHeight = abilityFrameHeight + self:GetAppearance().headerFontSize

            abilityFrame.groups = abilityFrame.groups or {}
            for _, groupFrame in ipairs(abilityFrame.groups) do
                groupFrame:Hide()
            end
            local previousGroup = nil
            for groupIndex, group in ipairs(ability.assignments) do
                local groupFrame = abilityFrame.groups[groupIndex] or FrameBuilder.CreateAssignmentGroupFrame(abilityFrame, self:GetAssignmentGroupHeight() + 3)
                FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, ability.uuid, groupIndex, self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
                
                groupFrame:ClearAllPoints()
                if previousGroup then
                    groupFrame:SetPoint("TOPLEFT", previousGroup, "BOTTOMLEFT", 0, 0)
                    groupFrame:SetPoint("TOPRIGHT", previousGroup, "BOTTOMRIGHT", 0, 0)
                else
                    groupFrame:SetPoint("TOPLEFT", abilityFrame, "TOPLEFT", 0, -16)
                    groupFrame:SetPoint("TOPRIGHT", abilityFrame, "TOPRIGHT", 0, -16)
                end

                for _, cd in pairs(groupFrame.assignments) do
                    cd:Hide()
                end
                for assignmentIndex, assignment in ipairs(group) do
                    local assignmentFrame = groupFrame.assignments[assignmentIndex] or FrameBuilder.CreateAssignmentFrame(groupFrame, assignmentIndex, self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
                    FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment)
                    
                    assignmentFrame:ClearAllPoints()
                    if assignmentIndex > 1 then
                        assignmentFrame:SetPoint("BOTTOMLEFT", groupFrame, "BOTTOM")
                        assignmentFrame:SetPoint("TOPRIGHT", -5, 0)
                    else
                        assignmentFrame:SetPoint("BOTTOMLEFT", 5, 0)
                        assignmentFrame:SetPoint("TOPRIGHT", groupFrame, "TOP", 0, 0)
                    end

                    assignmentFrame.groupIndex = groupIndex
                    groupFrame.assignments[assignmentIndex] = assignmentFrame
                end
    
                abilityFrameHeight = abilityFrameHeight + groupFrame:GetHeight()
                abilityFrame.groups[groupIndex] = groupFrame
    
                previousGroup = groupFrame
            end
    
            abilityFrameHeight = abilityFrameHeight + 7
            abilityFrame:SetHeight(abilityFrameHeight)

            abilityFrame:Show()
    
            self.bossAbilities[abilityIndex] = abilityFrame
            previousAbilityFrame = abilityFrame
        end
    end

    self:Resize()
end

function SRTOverview:UpdateActiveGroups()
    for _, ability in pairs(self.bossAbilities) do
        for _, group in pairs(ability.groups) do
            local selectedEncounterId = self:GetProfile().selectedEncounterId
            local encounter = SRTData.GetActiveEncounters()[selectedEncounterId]

            if encounter then
                for _, part in ipairs(encounter) do
                    if part.uuid == group.uuid then
                        local activeGroups = Groups.GetActive(group.uuid)

                        if activeGroups and #activeGroups > 0 then
                            for _, index in ipairs(activeGroups) do
                                if index == group.index then
                                    group:SetBackdropColor(1, 1, 1, 0.6)
                                else
                                    group:SetBackdropColor(0, 0, 0, 0)
                                end
                            end
                        else
                            group:SetBackdropColor(0, 0, 0, 0)
                        end

                        break
                    end
                end
            end
        end
    end
end

function SRTOverview:UpdateSpells()
    for _, ability in pairs(self.bossAbilities) do
        for _, group in pairs(ability.groups) do
            for _, assignment in pairs(group.assignments) do
                if SpellCache.IsSpellActive(assignment.player, assignment.spellId) then
                    local castTimestamp = SpellCache.GetCastTime(assignment.player, assignment.spellId)
                    local spell = SRTData.GetSpellByID(assignment.spellId)

                    if castTimestamp and spell then
                        assignment.cooldownFrame:SetCooldown(castTimestamp, spell.duration)
                    end

                    assignment:SetAlpha(1)
                else
                    if SpellCache.IsSpellReady(assignment.player, assignment.spellId) then
                        assignment:SetAlpha(1)
                    else
                        assignment:SetAlpha(0.4)
                    end
                end
            end
        end
    end
end
