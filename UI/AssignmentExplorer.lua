local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    ONLY_ENCOUNTER = 1,
    SHOW_PLAYER = 2,
    SHOW_ROSTER = 3,
    APPLY_BUFF_CHANGE = 4
}

--- Assignment Explorer window class object
---@class AssignmentExplorer:SRTWindow
AssignmentExplorer = setmetatable({
    state = State.ONLY_ENCOUNTER,
    lastState = State.ONLY_ENCOUNTER,
    selectedEncounterID = 1025,
    selectedPlayer= {},
    viewRosterPlayer = false,
    selectedRosterPlayer= {},
    encounter = {},
    player = {},
    roster = {},
}, SRTWindow)
AssignmentExplorer.__index = AssignmentExplorer

---@return AssignmentExplorer
function AssignmentExplorer:New(height)
    local obj = SRTWindow.New(self, "AssignmentExplorer", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj AssignmentExplorer
    self.__index = self
    return obj
end

function AssignmentExplorer:Initialize()
    SRTWindow.Initialize(self)
    -- Setup header
    self.headerText:SetText("Assignments Explorer")
    -- Setup encounter pane
    self.encounterPane = CreateFrame("Frame", "SRT_Assignments_EncounterPane", self.main)
    self.encounterPane:SetClipsChildren(true)
    self.encounterPane:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.encounterPane:SetPoint("TOPRIGHT", self.main, "TOP", -5, -5)
    self.encounterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.encounterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOM", -5, 5)

    self.encounter.selector = self.encounter.selector or FrameBuilder.CreateSelector(self.encounterPane, {}, 285, self:GetHeaderFontType(), 14, "Select encounter...")
    self.encounter.selector:SetPoint("TOPLEFT", self.encounterPane, "TOPLEFT", 0, -5)
    self.encounter.selector.selectedName = "Maloriak"
    self.encounter.bossAbilities = self.encounter.bossAbilities or {}
    -- Setup player pane
    self.selectedPlayerPane = CreateFrame("Frame", "SRT_Assignments_SelectedPlayerPane", self.main)
    self.selectedPlayerPane:SetClipsChildren(true)
    self.selectedPlayerPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.selectedPlayerPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.selectedPlayerPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.selectedPlayerPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.selectedPlayerPane.scroll = FrameBuilder.CreateScrollArea(self.selectedPlayerPane, "AvailableSpells")
    self.selectedPlayerPane.scroll:SetPoint("TOPLEFT", self.selectedPlayerPane, "TOPLEFT", 0, -28)
    self.selectedPlayerPane.scroll:SetPoint("TOPRIGHT", self.selectedPlayerPane, "TOPRIGHT", 0, -28)
    self.selectedPlayerPane.scroll:SetPoint("BOTTOMLEFT", self.selectedPlayerPane, "BOTTOMLEFT", 10, 35)
    self.selectedPlayerPane.scroll:SetPoint("BOTTOMRIGHT", self.selectedPlayerPane, "BOTTOMRIGHT", 10, 35)

    self.player.name = self.player.name or self.selectedPlayerPane:CreateFontString("SRT_AssignmentExplorer_PlayerPane_Name", "OVERLAY", "GameFontNormalLarge")
    self.player.name:SetPoint("TOPLEFT", self.selectedPlayerPane, "TOPLEFT", 0, -5)
    self.player.name:SetTextColor(1, 1, 1, 0.8)
    self.player.cooldowns = self.player.cooldowns or {}

    self.replaceButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Replace", SRTColor.Red, SRTColor.RedHighlight)
    self.replaceButton:SetPoint("BOTTOMLEFT", self.selectedPlayerPane, "BOTTOMLEFT", 0, 5)
    self.replaceButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.SHOW_ROSTER
            self.viewRosterPlayer = false
            self.selectedRosterPlayer.selectedID = nil
            self.applyBuffChangesButton.color = SRTColor.Gray
            self.applyBuffChangesButton.colorHighlight = SRTColor.Gray
            self.applyBuffChangesButton:SetScript("OnMouseUp", nil)
            FrameBuilder.UpdateButton(self.applyBuffChangesButton)
            self:UpdateAppearance()
        end
    end)
    self.applyBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Apply", SRTColor.Gray, SRTColor.Gray)
    self.applyBuffChangesButton:SetPoint("BOTTOMRIGHT", self.selectedPlayerPane, "BOTTOMRIGHT", 0, 5)
    self.cancelBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.cancelBuffChangesButton:SetPoint("RIGHT", self.applyBuffChangesButton, "LEFT", -5, 0)
    self.cancelBuffChangesButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.ONLY_ENCOUNTER
            self:UpdateAppearance()
        end
    end)
    self.selectedPlayerPane:Hide()
    -- Setup roster pane
    self.rosterPane = CreateFrame("Frame", "SRT_Assignments_Roster", self.main)
    self.rosterPane:SetClipsChildren(true)
    self.rosterPane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.rosterPane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.rosterPane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.rosterPane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.rosterPane.roster = {}
    self.rosterBackButton = FrameBuilder.CreateButton(self.rosterPane, 75, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.rosterBackButton:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 5)
    self.rosterBackButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.SHOW_PLAYER
            self:UpdateAppearance()
        end
    end)
    self.rosterPane:Hide()
    -- Setup apply buff change pane
    self.applyChangePane = CreateFrame("Frame", "SRT_AssignmentExplorer_ApplyChange", self.main)
    self.applyChangePane:SetClipsChildren(true)
    self.applyChangePane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.applyChangePane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.applyChangePane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.applyChangePane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.applyChangeBackButton = FrameBuilder.CreateButton(self.applyChangePane, 75, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.applyChangeBackButton:SetPoint("BOTTOMLEFT", self.applyChangePane, "BOTTOMLEFT", 0, 5)
    self.applyChangeBackButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_ROSTER
            self.state = State.SHOW_PLAYER
            self:UpdateAppearance()
        end
    end)
    self.applyChangeAcceptButton = FrameBuilder.CreateButton(self.applyChangePane, 75, 25, "Accept", SRTColor.Green, SRTColor.GreenHighlight)
    self.applyChangeAcceptButton:SetPoint("BOTTOMRIGHT", self.applyChangePane, "BOTTOMRIGHT", 0, 5)
    self.applyChangePane:Hide()
    
    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and InCombatLockdown() then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)
    -- Update appearance
    self:UpdateAppearance()
end

---@return FontFile
function AssignmentExplorer:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function AssignmentExplorer:GetPlayerFont()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function AssignmentExplorer:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function AssignmentExplorer:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateEncounterPane()
    self:UpdateSelectedPlayerPane()
    self:UpdateRosterPane()
    self:UpdateApplyChangePane()
end

function AssignmentExplorer:Update()
    SRTWindow.Update(self)
    self.encounter.selector.items = {}
    BossEncounters:Initialize()
    for encounterID, _ in pairs(SRTData.GetActiveEncounters()) do
        local item = {
            name = BossEncounters:GetNameByID(encounterID),
            encounterID = encounterID,
            onClick = function (row)
                self.selectedEncounterID = row.item.encounterID
                self:UpdateAppearance()
            end
        }
        table.insert(self.encounter.selector.items, item)
    end
    self.encounter.selector.selectedName = BossEncounters:GetNameByID(self.selectedEncounterID)
    self.encounter.selector.Update()
end

function AssignmentExplorer:UpdateEncounterPane()
    local encounterAssignments = SRTData.GetActiveEncounters()[self.selectedEncounterID]
    if not encounterAssignments then
        return
    end

    for _, abilityFrame in pairs(self.encounter.bossAbilities) do
        abilityFrame:Hide()
    end
    local previousAbilityFrame
    for abilityIndex, ability in ipairs(encounterAssignments) do
        local abilityFrame = self.encounter.bossAbilities[abilityIndex] or CreateFrame("Frame", nil, self.encounterPane)
        abilityFrame:Show()
        if previousAbilityFrame then
            abilityFrame:SetPoint("TOPLEFT", previousAbilityFrame, "BOTTOMLEFT", 0, 0)
            abilityFrame:SetPoint("TOPRIGHT", previousAbilityFrame, "BOTTOMRIGHT", 0, 0)
        else
            abilityFrame:SetPoint("TOPLEFT", self.encounter.selector, "BOTTOMLEFT", 10, -7)
            abilityFrame:SetPoint("TOPRIGHT", self.encounter.selector, "BOTTOMLEFT", 190, -7)
        end
        local bossAbilityFrameHeight = 7

        abilityFrame.name = abilityFrame.name or abilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        abilityFrame.name:SetPoint("TOPLEFT", abilityFrame, "TOPLEFT", 0, 0)
        abilityFrame.name:SetText(ability.metadata.name)
        abilityFrame.name:SetFont(self:GetHeaderFontType(), 12)
        abilityFrame.name:SetTextColor(1, 1, 1, 0.8)
        self:SetDefaultFontStyle(abilityFrame.name)
        bossAbilityFrameHeight = bossAbilityFrameHeight + 12

        abilityFrame.bossSelectionFrame = abilityFrame.bossSelectionFrame or {}

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
                    assignmentFrame:SetPoint("TOPRIGHT", -10, 0)
                else
                    assignmentFrame:SetPoint("BOTTOMLEFT", 10, 0)
                    assignmentFrame:SetPoint("TOPRIGHT", groupFrame, "TOP", 0, 0)
                end

                assignmentFrame.groupIndex = groupIndex
                groupFrame.assignments[assignmentIndex] = assignmentFrame
            end

            -- Set OnClick for each assignment
            for _, assignmentFrame in pairs(groupFrame.assignments) do
                assignmentFrame:SetScript("OnMouseUp", function (frame, button)
                    if button == "LeftButton" then
                        self.lastState = State.ONLY_ENCOUNTER
                        self.state = State.SHOW_PLAYER
                        self.viewRosterPlayer = false
                        self.selectedPlayer = {
                            name = frame.player,
                            class = SRTData.GetClassBySpellID(frame.spellId),
                            selectedID = frame.spellId,
                            encounterID = self.selectedEncounterID,
                            bossAbility = abilityIndex,
                            assignmentGroup = frame.groupIndex
                        }
                        self:UpdateAppearance()
                    end
                end)
            end

            bossAbilityFrameHeight = bossAbilityFrameHeight + groupFrame:GetHeight()
            abilityFrame.groups[groupIndex] = groupFrame

            previousGroup = groupFrame
        end

        bossAbilityFrameHeight = bossAbilityFrameHeight + 7
        abilityFrame:SetHeight(bossAbilityFrameHeight)

        self.encounter.bossAbilities[abilityIndex] = abilityFrame
        previousAbilityFrame = abilityFrame
    end
end

function AssignmentExplorer:UpdateSelectedPlayerPane()
    if self.lastState == State.SHOW_ROSTER then
        self.replaceButton.text:SetText("Back")
    else
        self.replaceButton.text:SetText("Replace")
    end

    if self.state == State.SHOW_PLAYER then
        self.selectedPlayerPane:Show()
    else
        self.selectedPlayerPane:Hide()
        return
    end

    if self.viewRosterPlayer then
        self.player.name:SetText(self.selectedRosterPlayer.name)
    else
        self.player.name:SetText(self.selectedPlayer.name)
    end
    self.player.name:SetFont(self:GetHeaderFontType(), 14)
    
    local iconSize = self:GetAppearance().iconSize * 3

    for _, spellFrame in pairs(self.player.cooldowns) do
        spellFrame:Hide()
    end
    local lastSpellFrame

    local classSpells
    local selectedID
    if self.viewRosterPlayer then
        classSpells = SRTData.GetClass(self.selectedRosterPlayer.class).spells
        selectedID = self.selectedRosterPlayer.selectedID
    else
        classSpells = self.selectedPlayer.class.spells
        selectedID = self.selectedPlayer.selectedID
    end
    local scrollHeight = 0
    for _, spell in pairs(classSpells) do
        local spellFrame = self.player.cooldowns[spell.id] or FrameBuilder.CreateLargeSpellFrame(self.selectedPlayerPane.scroll.content)
        FrameBuilder.UpdateLargeSpellFrame(spellFrame, spell.id, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
        spellFrame:SetScript("OnEnter", function () spellFrame:SetBackdropColor(1, 1, 1, 0.4) end)
        spellFrame:SetScript("OnLeave", function (frame) if frame.spellID ~= selectedID then spellFrame:SetBackdropColor(0, 0, 0, 0) end end)
        spellFrame:SetScript("OnMouseDown", function (sf, button)
            if button == "LeftButton" then
                if self.viewRosterPlayer then
                    self.selectedRosterPlayer.selectedID = sf.spellID
                    self.applyBuffChangesButton.color = SRTColor.Green
                    self.applyBuffChangesButton.colorHighlight = SRTColor.GreenHighlight
                    self.applyBuffChangesButton:SetScript("OnMouseUp", function (_, b)
                        if b == "LeftButton" then
                            self.lastState = State.SHOW_ROSTER
                            self.state = State.APPLY_BUFF_CHANGE
                            self:UpdateAppearance()
                        end
                    end)
                    FrameBuilder.UpdateButton(self.applyBuffChangesButton)
                    self:UpdateAppearance()
                end
            end
        end)
        if lastSpellFrame then
            spellFrame:SetPoint("TOPLEFT", lastSpellFrame, "BOTTOMLEFT", 0, -7)
            spellFrame:SetPoint("TOPRIGHT", lastSpellFrame, "BOTTOMRIGHT", 0, -7)
        else
            spellFrame:SetPoint("TOPLEFT", self.selectedPlayerPane.scroll.content, "TOPLEFT", 0, -7)
            spellFrame:SetPoint("TOPRIGHT", self.selectedPlayerPane.scroll.content, "TOPRIGHT", 0, -7)
        end
        if spell.id == selectedID then
            spellFrame:SetBackdropColor(1, 1, 1, 0.4)
        end
        self.player.cooldowns[spell.id] = spellFrame
        scrollHeight = scrollHeight + spellFrame:GetHeight() + 7
        lastSpellFrame = spellFrame
    end
    self.selectedPlayerPane.scroll.content:SetHeight(scrollHeight)
end

function AssignmentExplorer:UpdateRosterPane()
    if self.state == State.SHOW_ROSTER then
        self.rosterPane:Show()
    else
        self.rosterPane:Hide()
        return
    end

    self.rosterPane.title = self.rosterPane.title or self.rosterPane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.rosterPane.title:SetText("Available Players")
    self.rosterPane.title:SetPoint("TOPLEFT", self.rosterPane, "TOPLEFT", 0, -5)
    self.rosterPane.title:SetFont(self:GetHeaderFontType(), 14)
    self.rosterPane.title:SetHeight(self.rosterPane.title:GetStringHeight())
    self.rosterPane.title:SetTextColor(0.8, 0.8, 0.8, 1)
    self.rosterPane.guildTitle = self.rosterPane.guildTitle or self.rosterPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.rosterPane.guildTitle:SetText("Swiftdawn")
    self.rosterPane.guildTitle:SetPoint("TOPLEFT", self.rosterPane.title, "BOTTOMLEFT", 10, -7)
    self.rosterPane.guildTitle:SetFont(self:GetHeaderFontType(), 13)
    self.rosterPane.guildTitle:SetHeight(self.rosterPane.guildTitle:GetStringHeight())
    self.rosterPane.guildTitle:SetTextColor(0.8, 0.8, 0.8, 1)

    self.rosterPane.roster = self.rosterPane.roster or {}
    
    local lastPlayerFrame = nil
    for _, player in ipairs(self:GetOnlineGuildMembers()) do
        local playerFrame = self.rosterPane.roster[player.name] or FrameBuilder.CreatePlayerFrame(self.rosterPane, player.name, player.classFileName,
            self.rosterPane:GetWidth(), self:GetAssignmentGroupHeight(), self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize + 2)

        if not lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", self.rosterPane.guildTitle, "BOTTOMLEFT", 0, -7)
        else
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -5)
        end

        playerFrame:SetScript("OnEnter", function () playerFrame:SetBackdropColor(1, 1, 1, 0.4) end)
        playerFrame:SetScript("OnLeave", function () playerFrame:SetBackdropColor(0, 0, 0, 0) end)

        playerFrame:SetScript("OnMouseUp", function (_, button)
            if button == "LeftButton" then
                self.lastState = State.SHOW_ROSTER
                self.state = State.SHOW_PLAYER
                self.viewRosterPlayer = true
                self.selectedRosterPlayer = {
                    name = strsplit("-", player.name),
                    class = player.classFileName,
                    selectedID = nil
                }
                self:UpdateAppearance()
            end
        end)

        self.rosterPane.roster[player.name] = playerFrame
        lastPlayerFrame = playerFrame
    end
end

local function ApplyBuffChange(original, replacement)
    if SwiftdawnRaidTools.DEBUG then print(string.format("Changing %s's Spell:%d for %s's Spell:%d on encounter %d and ability %d", original.name, original.selectedID, replacement.name, replacement.selectedID, original.encounterID, original.bossAbility)) end
    for _, assignment in ipairs(SRT_Profile().data.encounters[original.encounterID][original.bossAbility]["assignments"][original.assignmentGroup]) do
        if assignment.player == original.name and assignment.spell_id == original.selectedID then
            assignment.player = replacement.name
            assignment.spell_id = replacement.selectedID
        end
    end
end

function AssignmentExplorer:UpdateApplyChangePane()
    if self.state == State.APPLY_BUFF_CHANGE then
        self.applyChangePane:Show()
    else
        self.applyChangePane:Hide()
        return
    end

    local originalSpellName, _, _, _, _, _, originalSpellID, _ = C_Spell.GetSpellInfo(self.selectedPlayer.selectedID)

    self.applyChangePane.questionPartOne = self.applyChangePane.questionPartOne or self.applyChangePane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.applyChangePane.questionPartOne:SetText(string.format("Change %s's %s", self.selectedPlayer.name, originalSpellName))
    self.applyChangePane.questionPartOne:SetPoint("TOPLEFT", self.applyChangePane, "TOPLEFT", 0, -5)
    self.applyChangePane.questionPartOne:SetFont(self:GetHeaderFontType(), 14)
    self.applyChangePane.questionPartOne:SetHeight(self.applyChangePane.questionPartOne:GetStringHeight())
    self.applyChangePane.questionPartOne:SetTextColor(1, 1, 1, 0.8)
    
    local iconSize = self:GetAppearance().iconSize * 3
    self.applyChangePane.originalSpellFrame = self.applyChangePane.originalSpellFrame or FrameBuilder.CreateLargeSpellFrame(self.applyChangePane)
    FrameBuilder.UpdateLargeSpellFrame(self.applyChangePane.originalSpellFrame, originalSpellID, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
    self.applyChangePane.originalSpellFrame:SetPoint("TOPLEFT", self.applyChangePane.questionPartOne, "BOTTOMLEFT", 5, -7)
    self.applyChangePane.originalSpellFrame:SetPoint("TOPRIGHT", self.applyChangePane.questionPartOne, "BOTTOMLEFT", 285, -7)

    local replacementSpellName, _, _, _, _, _, replacementSpellID, _ = C_Spell.GetSpellInfo(self.selectedRosterPlayer.selectedID)

    self.applyChangePane.questionPartTwo = self.applyChangePane.questionPartTwo or self.applyChangePane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.applyChangePane.questionPartTwo:SetText(string.format("To %s's %s?", self.selectedRosterPlayer.name, replacementSpellName))
    self.applyChangePane.questionPartTwo:SetPoint("TOPLEFT", self.applyChangePane.originalSpellFrame, "BOTTOMLEFT", -5, -7)
    self.applyChangePane.questionPartTwo:SetFont(self:GetHeaderFontType(), 14)
    self.applyChangePane.questionPartTwo:SetHeight(self.applyChangePane.questionPartTwo:GetStringHeight())
    self.applyChangePane.questionPartTwo:SetTextColor(1, 1, 1, 0.8)
    
    self.applyChangePane.replacementSpellFrame = self.applyChangePane.replacementSpellFrame or FrameBuilder.CreateLargeSpellFrame(self.applyChangePane)
    FrameBuilder.UpdateLargeSpellFrame(self.applyChangePane.replacementSpellFrame, replacementSpellID, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
    self.applyChangePane.replacementSpellFrame:SetPoint("TOPLEFT", self.applyChangePane.questionPartTwo, "BOTTOMLEFT", 5, -7)
    self.applyChangePane.replacementSpellFrame:SetPoint("TOPRIGHT", self.applyChangePane.questionPartTwo, "BOTTOMLEFT", 285, -7)

    self.applyChangeAcceptButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.APPLY_BUFF_CHANGE
            self.state = State.ONLY_ENCOUNTER
            ApplyBuffChange(self.selectedPlayer, self.selectedRosterPlayer)
            self:UpdateAppearance()
        end
    end)
end

local lastUpdatedOnlineGuildMembers = 0
local guildMembers = {}
function AssignmentExplorer:GetOnlineGuildMembers()
    if GetTime() - lastUpdatedOnlineGuildMembers < 5 then
        return guildMembers
    end
    guildMembers = {}
    local numTotalGuildMembers, numOnlineGuildMembers, numOnlineAndMobileMembers = GetNumGuildMembers()
    for index = 1, numTotalGuildMembers, 1 do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID = GetGuildRosterInfo(index)
        if online and level == 85 then
            table.insert(guildMembers, { name = name, class = class, classFileName = classFileName })
        end
    end
    return guildMembers
end

function AssignmentExplorer:CreateTriggerFrame(bossAbilityFrame)
    local triggerFrame = CreateFrame("Frame", nil, bossAbilityFrame, "BackdropTemplate")
    triggerFrame:SetHeight(self:GetAssignmentGroupHeight())
    triggerFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    triggerFrame:SetBackdropColor(0, 0, 0, 0)
    triggerFrame.text = triggerFrame.text or triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    triggerFrame.text:SetAllPoints()
    triggerFrame.text:SetFont(self:GetTitleFontType(), self:GetAppearance().titleFontSize)
    self:SetDefaultFontStyle(triggerFrame.text)
    return triggerFrame
end

function AssignmentExplorer:SetDefaultFontStyle(fontString)
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
    fontString:SetJustifyH("LEFT")
    fontString:SetHeight(fontString:GetStringHeight())
end

function AssignmentExplorer:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end

    self.popupMenu.Update({
        { name = "Configuration", onClick = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end, isSetting = true },
        {},
        { name = self:GetProfile().locked and "Unlock Window" or "Lock Window", onClick = function() self:ToggleLock() end, isSetting = true },
        { name = "Close Window", onClick = function() self:CloseWindow() end, isSetting = true },
        {},
        { name = "Close", onClick = nil, isSetting = true },
    })
end