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
---@class AssignmentEditor:SRTWindow
AssignmentEditor = setmetatable({
    state = State.ONLY_ENCOUNTER,
    lastState = State.ONLY_ENCOUNTER,
    selectedEncounterID = nil,
    selectedPlayer= {},
    viewRosterPlayer = false,
    selectedRosterPlayer= {},
    encounter = {},
    player = {},
    roster = {},
}, SRTWindow)
AssignmentEditor.__index = AssignmentEditor

---@return AssignmentEditor
function AssignmentEditor:New(height)
    local obj = SRTWindow.New(self, "AssignmentEditor", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj AssignmentEditor
    self.__index = self
    return obj
end

function AssignmentEditor:Initialize()
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

    self.player.name = self.player.name or self.selectedPlayerPane:CreateFontString("SRT_AssignmentEditor_PlayerPane_Name", "OVERLAY", "GameFontNormalLarge")
    self.player.name:SetPoint("TOPLEFT", self.selectedPlayerPane, "TOPLEFT", 0, -5)
    self.player.name:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.player.cooldowns = self.player.cooldowns or {}

    self.applyBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Apply", SRTColor.Green, SRTColor.GreenHighlight)
    self.applyBuffChangesButton:SetPoint("BOTTOMRIGHT", self.selectedPlayerPane, "BOTTOMRIGHT", 0, 5)
    self.applyBuffChangesButton:Hide()
    self.replaceButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Replace", SRTColor.Red, SRTColor.RedHighlight)
    self.replaceButton:SetPoint("BOTTOMRIGHT", self.selectedPlayerPane, "BOTTOMRIGHT", 0, 5)
    self.replaceButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.SHOW_ROSTER
            self.viewRosterPlayer = false
            self.selectedRosterPlayer.selectedID = nil
            self.applyBuffChangesButton:Hide()
            self.applyBuffChangesButton:SetScript("OnMouseUp", nil)
            self:UpdateAppearance()
        end
    end)
    self.cancelBuffChangesButton = FrameBuilder.CreateButton(self.selectedPlayerPane, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.cancelBuffChangesButton:SetPoint("BOTTOMLEFT", self.selectedPlayerPane, "BOTTOMLEFT", 0, 5)
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
    self.rosterPane:Hide()
    self.cancelReplaceButton = FrameBuilder.CreateButton(self.rosterPane, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.cancelReplaceButton:SetPoint("BOTTOMLEFT", self.rosterPane, "BOTTOMLEFT", 0, 5)
    self.cancelReplaceButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.ONLY_ENCOUNTER
            self:UpdateAppearance()
        end
    end)
    -- Setup apply buff change pane
    self.applyChangePane = CreateFrame("Frame", "SRT_AssignmentEditor_ApplyChange", self.main)
    self.applyChangePane:SetClipsChildren(true)
    self.applyChangePane:SetPoint("TOPLEFT", self.main, "TOP", 5, -5)
    self.applyChangePane:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.applyChangePane:SetPoint("BOTTOMLEFT", self.main, "BOTTOM", 5, 5)
    self.applyChangePane:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)
    self.applyChangeAcceptButton = FrameBuilder.CreateButton(self.applyChangePane, 75, 25, "Accept", SRTColor.Green, SRTColor.GreenHighlight)
    self.applyChangeAcceptButton:SetPoint("BOTTOMRIGHT", self.applyChangePane, "BOTTOMRIGHT", 0, 5)
    self.applyChangeCancelButton = FrameBuilder.CreateButton(self.applyChangePane, 75, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.applyChangeCancelButton:SetPoint("BOTTOMLEFT", self.selectedPlayerPane, "BOTTOMLEFT", 0, 5)
    self.applyChangeCancelButton:SetScript("OnMouseUp", function (_, button)
        if button == "LeftButton" then
            self.lastState = State.SHOW_PLAYER
            self.state = State.ONLY_ENCOUNTER
            self:UpdateAppearance()
        end
    end)
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
function AssignmentEditor:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function AssignmentEditor:GetPlayerFont()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function AssignmentEditor:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function AssignmentEditor:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateEncounterPane()
    self:UpdateSelectedPlayerPane()
    self:UpdateRosterPane()
    self:UpdateApplyChangePane()
end

function AssignmentEditor:Update()
    SRTWindow.Update(self)
    self.encounter.selector.items = {}
    for encounterID, _ in pairs(SRTData.GetActiveEncounters()) do
        local item = {
            name = BossInfo.GetNameByID(encounterID),
            encounterID = encounterID,
            onClick = function (row)
                self.selectedEncounterID = row.item.encounterID
                self:UpdateAppearance()
            end
        }
        table.insert(self.encounter.selector.items, item)
    end
    if self.selectedEncounterID then
        self.encounter.selector.selectedName = BossInfo.GetNameByID(self.selectedEncounterID)
    elseif #self.encounter.selector.items > 0 then
        self.encounter.selector.selectedName = self.encounter.selector.items[1].name
        self.selectedEncounterID = self.encounter.selector.items[1].encounterID
        self:UpdateAppearance()
    else
        self.encounter.selector.selectedName = "No encounters in assignments!"
    end
    self.encounter.selector.Update()
end

function AssignmentEditor:UpdateEncounterPane()
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
            abilityFrame:SetPoint("TOPRIGHT", self.encounter.selector, "BOTTOMLEFT", 280, -7)
        end
        local bossAbilityFrameHeight = 7

        abilityFrame.name = abilityFrame.name or abilityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        abilityFrame.name:SetPoint("TOPLEFT", abilityFrame, "TOPLEFT", 0, 0)
        abilityFrame.name:SetText(ability.metadata.name)
        abilityFrame.name:SetFont(self:GetHeaderFontType(), 12)
        abilityFrame.name:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
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
                    assignmentFrame:SetPoint("TOPLEFT", groupFrame, "TOP", 0, 0)
                    assignmentFrame:SetPoint("BOTTOMRIGHT", 0, 0)
                else
                    assignmentFrame:SetPoint("TOPLEFT", 0, 0)
                    assignmentFrame:SetPoint("BOTTOMRIGHT", groupFrame, "BOTTOM", 0, 0)
                end

                assignmentFrame.groupIndex = groupIndex
                groupFrame.assignments[assignmentIndex] = assignmentFrame
            end

            -- Set OnClick for each assignment
            for assignmentIndex, assignmentFrame in pairs(groupFrame.assignments) do
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
                            groupIndex = frame.groupIndex,
                            assignmentIndex = assignmentIndex
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

function AssignmentEditor:UpdateSelectedPlayerPane()
    if self.state == State.SHOW_PLAYER then
        self.selectedPlayerPane:Show()
    else
        self.selectedPlayerPane:Hide()
        return
    end

    if self.viewRosterPlayer then
        self.replaceButton:Hide()
        self.player.name:SetText(self.selectedRosterPlayer.name)
    else
        self.replaceButton:Show()
        self.applyBuffChangesButton:Hide()
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
        if spell.id == selectedID or self.viewRosterPlayer then
            local spellFrame = self.player.cooldowns[spell.id] or FrameBuilder.CreateLargeSpellFrame(self.selectedPlayerPane.scroll.content)
            FrameBuilder.UpdateLargeSpellFrame(spellFrame, spell.id, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
            spellFrame:SetScript("OnEnter", function () spellFrame:SetBackdropColor(1, 1, 1, 0.4) end)
            spellFrame:SetScript("OnLeave", function (frame) if frame.spellID ~= selectedID or not self.viewRosterPlayer then spellFrame:SetBackdropColor(0, 0, 0, 0) end end)
            spellFrame:SetScript("OnMouseDown", function (sf, button)
                if button == "LeftButton" then
                    if self.viewRosterPlayer then
                        self.selectedRosterPlayer.selectedID = sf.spellID
                        self.applyBuffChangesButton:Show()
                        self.applyBuffChangesButton:SetScript("OnMouseUp", function (_, b)
                            if b == "LeftButton" then
                                self.lastState = State.SHOW_ROSTER
                                self.state = State.APPLY_BUFF_CHANGE
                                self:UpdateAppearance()
                            end
                        end)
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
            if spell.id == selectedID and self.viewRosterPlayer then
                spellFrame:SetBackdropColor(1, 1, 1, 0.4)
            end
            self.player.cooldowns[spell.id] = spellFrame
            scrollHeight = scrollHeight + spellFrame:GetHeight() + 7
            lastSpellFrame = spellFrame
        end
    end
    self.selectedPlayerPane.scroll.content:SetHeight(scrollHeight)
end

function AssignmentEditor:UpdateRosterPane()
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
    self.rosterPane.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.rosterPane.guildTitle = self.rosterPane.guildTitle or self.rosterPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.rosterPane.guildTitle:SetText("Swiftdawn")
    self.rosterPane.guildTitle:SetPoint("TOPLEFT", self.rosterPane.title, "BOTTOMLEFT", 10, -7)
    self.rosterPane.guildTitle:SetFont(self:GetHeaderFontType(), 13)
    self.rosterPane.guildTitle:SetHeight(self.rosterPane.guildTitle:GetStringHeight())
    self.rosterPane.guildTitle:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)

    self.rosterPane.roster = self.rosterPane.roster or {}
    
    local lastPlayerFrame = nil
    for player in Utils:CombinedIteratorWithUniqueNames(Utils:GetRaidMembers(true), Utils:GetGuildMembers(true)) do
        local playerFrame = self.rosterPane.roster[player.name] or FrameBuilder.CreatePlayerFrame(self.rosterPane, player.name, player.fileName,
            self.rosterPane:GetWidth(), self:GetAssignmentGroupHeight(), self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize + 2)

        if not lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", self.rosterPane.guildTitle, "BOTTOMLEFT", 0, -5)
        else
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, 0)
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
                    class = player.fileName,
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
    Log.debug("Assignment updated", {
        original = original,
        replacement = replacement
    })
    local assignmentFrame = SRTData.GetActiveEncounters()[original.encounterID][original.bossAbility]["assignments"][original.groupIndex][original.assignmentIndex]
    if assignmentFrame.player == original.name and assignmentFrame.spell_id == original.selectedID then
        assignmentFrame.player = replacement.name
        assignmentFrame.spell_id = replacement.selectedID
    end
    Roster.MarkUpdated(SRTData.GetActiveRoster())
    SwiftdawnRaidTools.overview:Update()
    SwiftdawnRaidTools.rosterBuilder:Update()
end

function AssignmentEditor:UpdateApplyChangePane()
    if self.state == State.APPLY_BUFF_CHANGE then
        self.applyChangePane:Show()
    else
        self.applyChangePane:Hide()
        return
    end

    local originalSpellInfo = C_Spell.GetSpellInfo(self.selectedPlayer.selectedID)

    self.applyChangePane.questionPartOne = self.applyChangePane.questionPartOne or self.applyChangePane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.applyChangePane.questionPartOne:SetText(string.format("Change %s's %s", self.selectedPlayer.name, originalSpellInfo.name))
    self.applyChangePane.questionPartOne:SetPoint("TOPLEFT", self.applyChangePane, "TOPLEFT", 0, -5)
    self.applyChangePane.questionPartOne:SetFont(self:GetHeaderFontType(), 14)
    self.applyChangePane.questionPartOne:SetHeight(self.applyChangePane.questionPartOne:GetStringHeight())
    self.applyChangePane.questionPartOne:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    
    local iconSize = self:GetAppearance().iconSize * 3
    self.applyChangePane.originalSpellFrame = self.applyChangePane.originalSpellFrame or FrameBuilder.CreateLargeSpellFrame(self.applyChangePane)
    FrameBuilder.UpdateLargeSpellFrame(self.applyChangePane.originalSpellFrame, originalSpellInfo.spellID, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
    self.applyChangePane.originalSpellFrame:SetPoint("TOPLEFT", self.applyChangePane.questionPartOne, "BOTTOMLEFT", 5, -7)
    self.applyChangePane.originalSpellFrame:SetPoint("TOPRIGHT", self.applyChangePane.questionPartOne, "BOTTOMLEFT", 285, -7)

    local replacementSpellInfo = C_Spell.GetSpellInfo(self.selectedRosterPlayer.selectedID)

    self.applyChangePane.questionPartTwo = self.applyChangePane.questionPartTwo or self.applyChangePane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.applyChangePane.questionPartTwo:SetText(string.format("To %s's %s?", self.selectedRosterPlayer.name, replacementSpellInfo.name))
    self.applyChangePane.questionPartTwo:SetPoint("TOPLEFT", self.applyChangePane.originalSpellFrame, "BOTTOMLEFT", -5, -7)
    self.applyChangePane.questionPartTwo:SetFont(self:GetHeaderFontType(), 14)
    self.applyChangePane.questionPartTwo:SetHeight(self.applyChangePane.questionPartTwo:GetStringHeight())
    self.applyChangePane.questionPartTwo:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    
    self.applyChangePane.replacementSpellFrame = self.applyChangePane.replacementSpellFrame or FrameBuilder.CreateLargeSpellFrame(self.applyChangePane)
    FrameBuilder.UpdateLargeSpellFrame(self.applyChangePane.replacementSpellFrame, replacementSpellInfo.spellID, self:GetPlayerFont(), self:GetAppearance().playerFontSize, iconSize)
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

function AssignmentEditor:CreateTriggerFrame(bossAbilityFrame)
    local triggerFrame = CreateFrame("Frame", nil, bossAbilityFrame, "BackdropTemplate")
    triggerFrame:SetHeight(self:GetAssignmentGroupHeight())
    triggerFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = triggerFrame:GetHeight(),
    })
    triggerFrame:SetBackdropColor(0, 0, 0, 0)
    triggerFrame.text = triggerFrame.text or triggerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    triggerFrame.text:SetAllPoints()
    triggerFrame.text:SetFont(self:GetTitleFontType(), self:GetAppearance().titleFontSize)
    self:SetDefaultFontStyle(triggerFrame.text)
    return triggerFrame
end

function AssignmentEditor:SetDefaultFontStyle(fontString)
    fontString:SetShadowOffset(1, -1)
    fontString:SetShadowColor(0, 0, 0, 1)
    fontString:SetJustifyH("LEFT")
    fontString:SetHeight(fontString:GetStringHeight())
end

function AssignmentEditor:UpdatePopupMenu()
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