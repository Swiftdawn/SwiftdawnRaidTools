local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")

local WINDOW_WIDTH = 600

local State = {
    LOAD_OR_CREATE_ROSTER = 1,
    ADD_OR_REMOVE_PLAYERS = 2,
    CREATE_ASSIGNMENTS = 3,
    PICK_SPELL = 4,
    IMPORT_ROSTER = 5
}

--- Roster Builder window class object
---@class RosterBuilder:SRTWindow
RosterBuilder = setmetatable({
    state = State.LOAD_OR_CREATE_ROSTER,
    lastState = State.LOAD_OR_CREATE_ROSTER,
    availableRosters = {},

    ---@class Roster?
    selectedRoster = nil,

    -- { incounterID, abilityIndex, groupIndex, assignmentIndex }
    pickedAssignment = nil,
    pickedPlayer = nil,

    roster = {},
    availablePlayers = {
        guild = {
            players = {}
        }
    }
}, SRTWindow)
RosterBuilder.__index = RosterBuilder

local availablePlayerFilterDefaults = {
    ["Class"] = {
        ["Death Knight"] = true,
        ["Druid"] = true,
        ["Hunter"] = true,
        ["Mage"] = true,
        ["Paladin"] = true,
        ["Priest"] = true,
        ["Rogue"] = true,
        ["Shaman"] = true,
        ["Warlock"] = true,
        ["Warrior"] = true
    },
    ["Guild Rank"] = {
        _function = function (key)
            local name = Utils:GetGuildRankNameByIndex(key + 1)
            return name ~= nil and name or "Rank "..key
        end,
    },
    ["Online only"] = false,
}
for i = 0, GuildControlGetNumRanks() - 1, 1 do
    availablePlayerFilterDefaults["Guild Rank"][i] = true
end

---@return RosterBuilder
function RosterBuilder:New(height)
    local obj = SRTWindow.New(self, "RosterBuilder", height, WINDOW_WIDTH, nil, nil, WINDOW_WIDTH, WINDOW_WIDTH)
    ---@cast obj RosterBuilder
    self.__index = self
    return obj
end

function RosterBuilder:SetToLeftSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    child:SetPoint("TOPRIGHT", parent, "TOP", -5, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOM", -5, 0)
end

function RosterBuilder:SetToRightSide(child, parent)
    child:SetPoint("TOPLEFT", parent, "TOP", 5, 0)
    child:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    child:SetPoint("BOTTOMLEFT", parent, "BOTTOM", 5, 0)
    child:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
end

function RosterBuilder:Initialize()
    SRTWindow.Initialize(self)
    -- Unset clipping to show filter menu out the side
    self.container:SetClipsChildren(false)

    -- Set header text
    self.headerText:SetText("Roster Builder")
    
    -- Set menu button script
    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and InCombatLockdown() then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)

    -- Create content pane
    self.content = CreateFrame("Frame", "SRTRoster_Content", self.main)
    self.content:SetClipsChildren(false)
    self.content:SetPoint("TOPLEFT", self.main, "TOPLEFT", 10, -5)
    self.content:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", -10, -5)
    self.content:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 10, 5)
    self.content:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", -10, 5)

    -- Create possible left/right panes
    self:InitializeLoadOrCreateRoster()
    self:InitializeAddOrRemovePlayers()
    self:InitializeCreateAssignments()
    self:InitializeImportRoster()

    -- Update appearance
    self:UpdateAppearance()
end

function RosterBuilder:InitializeLoadOrCreateRoster()
    self.loadCreate = {}
    self.loadCreate.load = {}
    self.loadCreate.load.pane = CreateFrame("Frame", "SRTRoster_Load", self.content)
    self.loadCreate.load.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.loadCreate.load.pane, self.content)
    self.loadCreate.load.title = self.loadCreate.load.pane:CreateFontString(self.loadCreate.load.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.loadCreate.load.title:SetPoint("TOPLEFT", self.loadCreate.load.pane, "TOPLEFT", 5 , -5)
    self.loadCreate.load.title:SetText("Roster")
    self.loadCreate.load.title:SetFont(self:GetHeaderFont(), 16)
    self.loadCreate.load.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.loadCreate.load.scroll = FrameBuilder.CreateScrollArea(self.loadCreate.load.pane, "SavedItems")
    self.loadCreate.load.scroll:SetPoint("TOPLEFT", self.loadCreate.load.pane, "TOPLEFT", 0, -28)
    self.loadCreate.load.scroll:SetPoint("TOPRIGHT", self.loadCreate.load.pane, "TOPRIGHT", 0, -28)
    self.loadCreate.load.scroll:SetPoint("BOTTOMLEFT", self.loadCreate.load.pane, "BOTTOMLEFT", 0, 35)
    self.loadCreate.load.scroll:SetPoint("BOTTOMRIGHT", self.loadCreate.load.pane, "BOTTOMRIGHT", 0, 35)
    self.loadCreate.load.scroll:SetScript("OnMouseDown", function ()
        self.selectedRoster = nil
        self:UpdateAppearance()
    end)

    -- Create buttons
    self.loadCreate.deleteButton = FrameBuilder.CreateButton(self.loadCreate.load.pane, 70, 25, "Delete", SRTColor.Gray, SRTColor.Gray)
    self.loadCreate.deleteButton:SetPoint("BOTTOMLEFT", self.loadCreate.load.pane, "BOTTOMLEFT", 0, 5)

    self.loadCreate.activateButton = FrameBuilder.CreateButton(self.loadCreate.load.pane, 70, 25, "Activate", SRTColor.Gray, SRTColor.Gray)
    self.loadCreate.activateButton:SetPoint("BOTTOMRIGHT", self.loadCreate.load.pane, "BOTTOMRIGHT", 0, 5)
    self.loadCreate.activateButton:SetScript("OnMouseDown", nil)

    self.loadCreate.info = {}
    self.loadCreate.info.pane = CreateFrame("Frame", "SRTRoster_SelectedInfo", self.content)
    self.loadCreate.info.pane:SetClipsChildren(false)
    self:SetToRightSide(self.loadCreate.info.pane, self.content)
    self.loadCreate.info.title = self.loadCreate.info.pane:CreateFontString(self.loadCreate.info.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.loadCreate.info.title:SetPoint("TOPLEFT", self.loadCreate.info.pane, "TOPLEFT", 5 , -5)
    self.loadCreate.info.title:SetText("Selected Player Info")
    self.loadCreate.info.title:SetFont(self:GetHeaderFont(), 16)
    self.loadCreate.info.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.loadCreate.info.scroll = FrameBuilder.CreateScrollArea(self.loadCreate.info.pane, "RosterInfo")
    self.loadCreate.info.scroll:SetPoint("TOPLEFT", self.loadCreate.info.pane, "TOPLEFT", 0, -28)
    self.loadCreate.info.scroll:SetPoint("TOPRIGHT", self.loadCreate.info.pane, "TOPRIGHT", 0, -28)
    self.loadCreate.info.scroll:SetPoint("BOTTOMLEFT", self.loadCreate.info.pane, "BOTTOMLEFT", 0, 35)
    self.loadCreate.info.scroll:SetPoint("BOTTOMRIGHT", self.loadCreate.info.pane, "BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.loadCreate.importButton = FrameBuilder.CreateButton(self.loadCreate.info.pane, 70, 25, "Import", SRTColor.Green, SRTColor.GreenHighlight)
    self.loadCreate.importButton:SetPoint("BOTTOMLEFT", self.loadCreate.info.pane, "BOTTOMLEFT", 0, 5)
    self.loadCreate.importButton:SetScript("OnMouseDown", function ()
        self.state = State.IMPORT_ROSTER
        self:UpdateAppearance()
    end)
    self.loadCreate.createButton = FrameBuilder.CreateButton(self.loadCreate.info.pane, 70, 25, "Create", SRTColor.Green, SRTColor.GreenHighlight)
    self.loadCreate.createButton:SetPoint("BOTTOMRIGHT", self.loadCreate.info.pane, "BOTTOMRIGHT", 0, 5)
    self.loadCreate.createButton:SetScript("OnMouseDown", function ()
        self.selectedRoster = SRTData.CreateNewRoster()
        self.state = State.ADD_OR_REMOVE_PLAYERS
        self:UpdateAppearance()
    end)
    self.loadCreate.editButton = FrameBuilder.CreateButton(self.loadCreate.info.pane, 70, 25, "Edit", SRTColor.Gray, SRTColor.Gray)
    self.loadCreate.editButton:SetPoint("RIGHT", self.loadCreate.createButton, "LEFT", -10, 0)
    self.loadCreate.editButton:Hide()
end

function RosterBuilder:InitializeImportRoster()
    self.import = {}
    self.import.input = {}
    self.import.input.pane = CreateFrame("Frame", "SRTRoster_ImportRoster", self.content)
    self.import.input.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.import.input.pane, self.content)
    self.import.input.title = self.import.input.pane:CreateFontString(self.import.input.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.import.input.title:SetPoint("TOPLEFT", self.import.input.pane, "TOPLEFT", 5 , -5)
    self.import.input.title:SetText("Import Roster")
    self.import.input.title:SetFont(self:GetHeaderFont(), 16)
    self.import.input.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)

    self.import.input.scrollPane = CreateFrame("Frame", "SRTRoster_ImportScrollPane", self.import.input.pane, "BackdropTemplate")
    self.import.input.scrollPane:SetPoint("TOPLEFT", self.import.input.pane, "TOPLEFT", 0, -28)
    self.import.input.scrollPane:SetPoint("TOPRIGHT", self.import.input.pane, "TOPRIGHT", 0, -28)
    self.import.input.scrollPane:SetPoint("BOTTOMLEFT", self.import.input.pane, "BOTTOMLEFT", 0, 5)
    self.import.input.scrollPane:SetPoint("BOTTOMRIGHT", self.import.input.pane, "BOTTOMRIGHT", 0, 5)
    self.import.input.scrollPane:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = self.import.input.scrollPane:GetHeight(),
    })
    self.import.input.scrollPane:SetBackdropColor(0, 0, 0, 0.3)
    self.import.input.scroll = FrameBuilder.CreateScrollArea(self.import.input.scrollPane, "RosterInfo")
    self.import.input.scroll:SetAllPoints()
    self.import.input.scroll.content:SetWidth(280)
    self.import.input.scroll.content:SetHeight(self.import.input.scrollPane:GetHeight())

    self.import.input.editBox = CreateFrame("EditBox", "ImportEditBox", self.import.input.scroll.content)
    self.import.input.editBox:SetPoint("TOPLEFT", self.import.input.scroll.content, "TOPLEFT", 5, -5)
    self.import.input.editBox:SetPoint("TOPRIGHT", self.import.input.scroll.content, "TOPRIGHT", -5, -5)
    self.import.input.editBox:SetPoint("BOTTOMLEFT", self.import.input.scroll.content, "BOTTOMLEFT", 5, 5)
    self.import.input.editBox:SetPoint("BOTTOMRIGHT", self.import.input.scroll.content, "BOTTOMRIGHT", -5, 5)
    self.import.input.editBox:SetMultiLine(true) -- Enable multi-line input
    self.import.input.editBox:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize, "") -- Set font
    self.import.input.editBox:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.import.input.editBox:SetAutoFocus(false) -- Disable auto-focus
    -- self.import.input.editBox:SetText("<Import String>") -- Initialize with empty text
    -- Create a hidden FontString for measurement
    self.import.input.editBox.fontString = self.import.input.editBox:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    self.import.input.editBox.fontString:SetWidth(270) -- Match the EditBox width for accurate line wrapping
    self.import.input.editBox.fontString:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize, "") -- Set font
    self.import.input.editBox.fontString:SetText(self.import.input.editBox:GetText()) -- Set the same text as the EditBox
    self.import.input.editBox.fontString:Hide() -- Keep it hidden
    self.import.input.editBox:SetScript("OnTextChanged", function()
        local text = self.import.input.editBox:GetText()
        self.import.input.editBox.fontString:SetText(text) -- Update the text in the FontString
        local textHeight = self.import.input.editBox.fontString:GetStringHeight()
        local newHeight = math.max(textHeight + 10, self.import.input.scrollPane:GetHeight())
        self.import.input.scroll.content:SetHeight(newHeight)
        
        local ok, parseResult = SRTImport:ParseYAML(text)
        if not ok then
            self.import.info.error:SetText(parseResult)
            self.import.importButton.color = SRTColor.Gray
            self.import.importButton.colorHighlight = SRTColor.Gray
            FrameBuilder.UpdateButton(self.import.importButton)
            self.import.importButton:SetScript("OnMouseUp", nil)
        else
            self.import.info.error:SetText("No errors")
            self.import.importButton.color = SRTColor.Green
            self.import.importButton.colorHighlight = SRTColor.GreenHighlight
            FrameBuilder.UpdateButton(self.import.importButton)
            self.import.importButton:SetScript("OnMouseUp", function ()
                local encounters = SRTImport:AddIDs(parseResult)
                local parsedRoster = Roster.Parse(encounters, "Imported Roster", time(), Utils:GetFullPlayerName())
                SRTData.AddRoster(parsedRoster.id, parsedRoster)
                self.state = State.LOAD_OR_CREATE_ROSTER
                self:UpdateAppearance()
            end)
        end
    end)
    self.import.input.editBox:SetScript("OnEscapePressed", function()
        self.import.input.editBox:ClearFocus() -- Clear focus when Escape is pressed
    end)

    self.import.info = {}
    self.import.info.pane = CreateFrame("Frame", "SRTRoster_ImportInfo", self.content)
    self.import.info.pane:SetClipsChildren(false)
    self:SetToRightSide(self.import.info.pane, self.content)
    self.import.info.title = self.import.info.pane:CreateFontString(self.import.info.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.import.info.title:SetPoint("TOPLEFT", self.import.info.pane, "TOPLEFT", 5 , -5)
    self.import.info.title:SetText("Roster Info")
    self.import.info.title:SetFont(self:GetHeaderFont(), 16)
    self.import.info.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.import.info.error = self.import.info.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.import.info.error:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
    self.import.info.error:SetText("No errors")
    self.import.info.error:SetJustifyH("LEFT")
    self.import.info.error:SetTextColor(SRTColor.Red.r, SRTColor.Red.g, SRTColor.Red.b, SRTColor.Red.a)
    self.import.info.error:SetPoint("TOPLEFT", self.import.info.title, "BOTTOMLEFT", 0, -10)

    -- Create buttons
    self.import.importButton = FrameBuilder.CreateButton(self.import.info.pane, 70, 25, "Import", SRTColor.Gray, SRTColor.Gray)
    self.import.importButton:SetPoint("BOTTOMRIGHT", self.import.info.pane, "BOTTOMRIGHT", 0, 5)
    self.import.importButton:SetScript("OnMouseDown", nil)
    self.import.cancelButton = FrameBuilder.CreateButton(self.import.info.pane, 70, 25, "Cancel", SRTColor.Red, SRTColor.RedHighlight)
    self.import.cancelButton:SetPoint("BOTTOMLEFT", self.import.info.pane, "BOTTOMLEFT", 0, 5)
    self.import.cancelButton:SetScript("OnMouseDown", function ()
        self.state = State.LOAD_OR_CREATE_ROSTER
        self:UpdateAppearance()
    end)
end

function RosterBuilder:InitializeAddOrRemovePlayers()
    self.addRemove = {}
    self.addRemove.roster = {}
    self.addRemove.roster.pane = CreateFrame("Frame", "SRTRoster_RosterPane", self.content)
    self.addRemove.roster.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.addRemove.roster.pane, self.content)
    self.addRemove.roster.title = self.addRemove.roster.pane:CreateFontString(self.addRemove.roster.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.addRemove.roster.title:SetPoint("TOPLEFT", self.addRemove.roster.pane, "TOPLEFT", 5 , -5)
    self.addRemove.roster.title:SetText("Roster")
    self.addRemove.roster.title:SetFont(self:GetHeaderFont(), 16)
    self.addRemove.roster.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.addRemove.roster.titleEditBox = CreateFrame("EditBox", self.addRemove.roster.pane:GetName().."TitleEditBox", self.addRemove.roster.pane)
    self.addRemove.roster.titleEditBox:SetSize(260, 16)
    self.addRemove.roster.titleEditBox:SetPoint("TOPLEFT", self.addRemove.roster.pane, "TOPLEFT", 5 , -5)
    self.addRemove.roster.titleEditBox:SetMultiLine(false)
    self.addRemove.roster.titleEditBox:SetFont(self:GetHeaderFont(), 16, "")
    self.addRemove.roster.titleEditBox:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.addRemove.roster.titleEditBox:SetAutoFocus(true)
    self.addRemove.roster.titleEditBox:SetScript("OnEnterPressed", function()
        self.selectedRoster.name = self.addRemove.roster.titleEditBox:GetText()
        self.addRemove.roster.titleEditBox:ClearFocus()
        self.addRemove.roster.titleEditBox:Hide()
        self.addRemove.roster.title:Show()
        self:UpdateAddOrRemovePlayers()
    end)
    self.addRemove.roster.titleEditBox:SetScript("OnEscapePressed", function()
        self.addRemove.roster.titleEditBox:ClearFocus()
        self.addRemove.roster.titleEditBox:Hide()
        self.addRemove.roster.title:Show()
    end)
    self.addRemove.roster.titleEditBox:Hide()
    self.addRemove.roster.editTitleButton = CreateFrame("Button", self.addRemove.roster.pane:GetName().."_EditTitle", self.addRemove.roster.pane, "BackdropTemplate")
    self.addRemove.roster.editTitleButton:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    self.addRemove.roster.editTitleButton:SetBackdropColor(0, 0, 0, 0)
    self.addRemove.roster.editTitleButton.texture = self.addRemove.roster.editTitleButton:CreateTexture(nil, "BACKGROUND")
    self.addRemove.roster.editTitleButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\marker-drawing-on-paper.png")
    self.addRemove.roster.editTitleButton.texture:SetAllPoints()
    self.addRemove.roster.editTitleButton.texture:SetAlpha(0.8)
    self.addRemove.roster.editTitleButton:SetSize(16, 16)
    self.addRemove.roster.editTitleButton:SetPoint("TOPRIGHT", self.addRemove.roster.pane, "TOPRIGHT", -5, -5)
    self.addRemove.roster.editTitleButton:SetScript("OnMouseUp", function ()
        self.addRemove.roster.titleEditBox:SetText(self.selectedRoster.name)
        self.addRemove.roster.titleEditBox:Show()
        self.addRemove.roster.title:Hide()
    end)
    self.addRemove.roster.editTitleButton:SetScript("OnEnter", function ()
        self.addRemove.roster.editTitleButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\marker-drawing-on-paper_hover.png")
    end)
    self.addRemove.roster.editTitleButton:SetScript("OnLeave", function ()
        self.addRemove.roster.editTitleButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\marker-drawing-on-paper.png")
    end)
    self.addRemove.roster.scroll = FrameBuilder.CreateScrollArea(self.addRemove.roster.pane, "Roster")
    self.addRemove.roster.scroll:SetPoint("TOPLEFT", self.addRemove.roster.pane, "TOPLEFT", 0, -28)
    self.addRemove.roster.scroll:SetPoint("TOPRIGHT", self.addRemove.roster.pane, "TOPRIGHT", 0, -28)
    self.addRemove.roster.scroll:SetPoint("BOTTOMLEFT", self.addRemove.roster.pane, "BOTTOMLEFT", 0, 35)
    self.addRemove.roster.scroll:SetPoint("BOTTOMRIGHT", self.addRemove.roster.pane, "BOTTOMRIGHT", 0, 35)
    self.addRemove.available = {}
    self.addRemove.available.pane = CreateFrame("Frame", "SRTRoster_AvailablePlayers", self.content)
    self.addRemove.available.pane:SetClipsChildren(false)
    self:SetToRightSide(self.addRemove.available.pane, self.content)
    self.addRemove.available.title = self.addRemove.available.pane:CreateFontString(self.addRemove.available.pane:GetName().."_Title", "OVERLAY", "GameFontNormal")
    self.addRemove.available.title:SetPoint("TOPLEFT", self.addRemove.available.pane, "TOPLEFT", 5 , -5)
    self.addRemove.available.title:SetText("Available Players")
    self.addRemove.available.title:SetFont(self:GetHeaderFont(), 16)
    self.addRemove.available.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.addRemove.available.filterButton = CreateFrame("Button", self.addRemove.available.pane:GetName().."_Filter", self.addRemove.available.pane, "BackdropTemplate")
    self.addRemove.available.filterButton.texture = self.addRemove.available.filterButton:CreateTexture(nil, "BACKGROUND")
    self.addRemove.available.filterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter.png")
    self.addRemove.available.filterButton.texture:SetAllPoints()
    self.addRemove.available.filterButton.texture:SetAlpha(0.8)
    self.addRemove.available.filterButton:SetSize(16, 16)
    self.addRemove.available.filterButton:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", -5, -5)
    self.addRemove.available.filterButton:SetScript("OnEnter", function ()
        self.addRemove.available.filterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter_hover.png")
    end)
    self.addRemove.available.filterButton:SetScript("OnLeave", function ()
        self.addRemove.available.filterButton.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\filter.png")
    end)
    self.addRemove.available.filterPopup = FrameBuilder.CreateFilterMenu(self.addRemove.available.filterButton, availablePlayerFilterDefaults, self:GetPlayerFont(), function() self:UpdateAddOrRemovePlayers() end)
    self.addRemove.available.filterPopup:SetPoint("TOPLEFT", self.addRemove.available.filterButton, "BOTTOMLEFT", 0, -3)
    self.addRemove.available.filterPopup:Hide()
    self.addRemove.available.filterButton:SetScript("OnClick", function ()
        if self.addRemove.available.filterPopup:IsShown() then self.addRemove.available.filterPopup:Hide() else self.addRemove.available.filterPopup:Show() end
    end)
    self.addRemove.available.scroll = FrameBuilder.CreateScrollArea(self.addRemove.available.pane, "Available")
    self.addRemove.available.scroll:SetPoint("TOPLEFT", self.addRemove.available.pane, "TOPLEFT", 0, -28)
    self.addRemove.available.scroll:SetPoint("TOPRIGHT", self.addRemove.available.pane, "TOPRIGHT", 0, -28)
    self.addRemove.available.scroll:SetPoint("BOTTOMLEFT", self.addRemove.available.pane, "BOTTOMLEFT", 0, 35)
    self.addRemove.available.scroll:SetPoint("BOTTOMRIGHT", self.addRemove.available.pane, "BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.addRemove.backButton = FrameBuilder.CreateButton(self.addRemove.roster.pane, 70, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.addRemove.backButton:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 0, 5)
    self.addRemove.backButton:SetScript("OnMouseDown", function (button)
        self.state = State.LOAD_OR_CREATE_ROSTER
        self.selectedRoster = nil
        self:UpdateAppearance()
    end)
    self.addRemove.assignmentsButton = FrameBuilder.CreateButton(self.addRemove.available.pane, 95, 25, "Assignments", SRTColor.Green, SRTColor.GreenHighlight)
    self.addRemove.assignmentsButton:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 5)
    self.addRemove.assignmentsButton:SetScript("OnMouseDown", function (button)
        self.state = State.CREATE_ASSIGNMENTS
        self:UpdateAppearance()
    end)
end

function RosterBuilder:InitializeCreateAssignments()
    self.assignments = {}
    self.assignments.players = {}
    self.assignments.players.pane = CreateFrame("Frame", "SRTRoster_AssignablePlayersPane", self.content)
    self.assignments.players.pane:SetClipsChildren(false)
    self:SetToLeftSide(self.assignments.players.pane, self.content)
    self.assignments.bossSelector = FrameBuilder.CreateSelector(self.assignments.players.pane, {}, 280, self:GetHeaderFontType(), 16, "Select encounter...")
    self.assignments.bossSelector:SetPoint("TOPLEFT", 0, -4)
    self.assignments.players.title = self.assignments.players.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.assignments.players.title:SetFont(self:GetHeaderFontType(), 14)
    self.assignments.players.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.assignments.players.title:SetText("Roster")
    self.assignments.players.title:SetPoint("TOPLEFT", self.assignments.bossSelector, "BOTTOMLEFT", 10, -8)
    self.assignments.players.scroll = FrameBuilder.CreateScrollArea(self.assignments.players.pane, "Players")
    self.assignments.players.scroll:SetPoint("TOPLEFT", 0, -51)
    self.assignments.players.scroll:SetPoint("TOPRIGHT", 0, -51)
    self.assignments.players.scroll:SetPoint("BOTTOMLEFT", 0, 38)
    self.assignments.players.scroll:SetPoint("BOTTOMRIGHT", 0, 38)
    self.assignments.encounter = {}
    self.assignments.encounter.pane = CreateFrame("Frame", "SRTRoster_BossAssignmentsPane", self.content)
    self.assignments.encounter.pane:SetClipsChildren(false)
    self:SetToRightSide(self.assignments.encounter.pane, self.content)
    self.assignments.encounter.title = self.assignments.encounter.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.assignments.encounter.title:SetFont(self:GetHeaderFontType(), 14)
    self.assignments.encounter.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.assignments.encounter.title:SetText("")
    self.assignments.encounter.title:SetPoint("TOPLEFT", self.assignments.encounter.pane, "TOPLEFT", 10, -8)
    self.assignments.encounter.scroll = FrameBuilder.CreateScrollArea(self.assignments.encounter.pane, "Encounter")
    self.assignments.encounter.scroll:SetPoint("TOPLEFT", 0, -2)
    self.assignments.encounter.scroll:SetPoint("TOPRIGHT", 0, -2)
    self.assignments.encounter.scroll:SetPoint("BOTTOMLEFT", 0, 35)
    self.assignments.encounter.scroll:SetPoint("BOTTOMRIGHT", 0, 35)

    self.assignments.pickspell = {}
    self.assignments.pickspell.pane = CreateFrame("Frame", "SRTRoster_PickSpellPane", self.content)
    self.assignments.pickspell.pane:SetClipsChildren(false)
    self.assignments.pickspell.pane:SetScript("OnMouseDown", function ()
        self.state = State.CREATE_ASSIGNMENTS
        self:UpdateCreateAssignments()
    end)
    self:SetToRightSide(self.assignments.pickspell.pane, self.content)
    self.assignments.pickspell.title = self.assignments.pickspell.pane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.assignments.pickspell.title:SetFont(self:GetHeaderFontType(), 14)
    self.assignments.pickspell.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.assignments.pickspell.title:SetText("Pick Spell to Assign...")
    self.assignments.pickspell.title:SetPoint("TOPLEFT", self.assignments.pickspell.pane, "TOPLEFT", 10, -8)
    self.assignments.pickspell.scroll = FrameBuilder.CreateScrollArea(self.assignments.pickspell.pane, "Spells")
    self.assignments.pickspell.scroll:SetPoint("TOPLEFT", 0, -28)
    self.assignments.pickspell.scroll:SetPoint("TOPRIGHT", 0, -28)
    self.assignments.pickspell.scroll:SetPoint("BOTTOMLEFT", 0, 35)
    self.assignments.pickspell.scroll:SetPoint("BOTTOMRIGHT", 0, 35)

    -- Create buttons
    self.assignments.backButton = FrameBuilder.CreateButton(self.assignments.players.pane, 70, 25, "Back", SRTColor.Red, SRTColor.RedHighlight)
    self.assignments.backButton:SetPoint("BOTTOMLEFT", self.content, "BOTTOMLEFT", 0, 5)
    self.assignments.backButton:SetScript("OnMouseDown", function (button)
        self.state = State.ADD_OR_REMOVE_PLAYERS
        self:UpdateAppearance()
    end)
    self.assignments.finishButton = FrameBuilder.CreateButton(self.assignments.encounter.pane, 70, 25, "Finish", SRTColor.Green, SRTColor.GreenHighlight)
    self.assignments.finishButton:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", 0, 5)
    self.assignments.finishButton:SetScript("OnMouseDown", function (button)
        if SRTData.GetSyncedRosterID() == self.selectedRoster.id and SRTData.GetSyncedRosterLastUpdated() ~= self.selectedRoster.lastUpdated then
            SyncController:ScheduleAssignmentsSync()
        end
        self.state = State.LOAD_OR_CREATE_ROSTER
        self:UpdateAppearance()
    end)
end

function RosterBuilder:UpdateAppearance()
    SRTWindow.UpdateAppearance(self)

    self:UpdateLoadOrCreateRoster()
    self:UpdateAddOrRemovePlayers()
    self:UpdateCreateAssignments()
    self:UpdateImportRoster()
end

local rosterInfo = {}

function RosterBuilder:EncounterIDsWithFilledAssignments()
    local ids = {}
    for encounterID, encounter in pairs(self.selectedRoster.encounters) do
        for _, abilityFrame in pairs(encounter) do
            if #abilityFrame.assignments > 0 then
                table.insert(ids, encounterID)
                break
            end
        end
    end
    return ids
end

--- Update left side of Load or Create state
function RosterBuilder:UpdateLoadOrCreateRoster()
    if self.state == State.LOAD_OR_CREATE_ROSTER then
        self.loadCreate.load.pane:Show()
        self.loadCreate.info.pane:Show()
    else
        self.loadCreate.load.pane:Hide()
        self.loadCreate.info.pane:Hide()
        for id, rosterFrame in pairs(self.availableRosters) do
            rosterFrame:Hide()
        end
        return
    end

    self.loadCreate.load.title:SetText("Saved Rosters")

    local previousFrame = nil
    local visibleRosters = 0
    for _, rosterFrame in pairs(self.availableRosters) do
        rosterFrame:Hide()
    end
    for id, roster in pairs(SRTData.GetRosters()) do
        -- roster.id = id  --Fix legacy issue
        local rosterFrame = self.availableRosters[id] or FrameBuilder.CreateRosterFrame(self.loadCreate.load.scroll.content, id, roster.name.." - "..Roster.GetLastUpdatedTimestamp(roster), 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        rosterFrame.name = roster.name.." - "..Roster.GetLastUpdatedTimestamp(roster)
        rosterFrame.Update()

        -- Make sure rosters are colored properly
        if self.selectedRoster and roster.id == self.selectedRoster.id then
            -- Yellow for selected
            rosterFrame.text:SetTextColor(SRTColor.GameYellow.r, SRTColor.GameYellow.g, SRTColor.GameYellow.b, SRTColor.GameYellow.a)
        elseif roster.id == SRTData.GetSyncedRosterID() and Roster.GetLastUpdated(roster) == SRTData.GetSyncedRosterLastUpdated() then
            -- Blue for synced and up-to-date roster
            rosterFrame.text:SetTextColor(SRTColor.BlueHighlight.r, SRTColor.BlueHighlight.g, SRTColor.BlueHighlight.b, SRTColor.BlueHighlight.a)
        elseif roster.id == SRTData.GetSyncedRosterID() and Roster.GetLastUpdated(roster) > SRTData.GetSyncedRosterLastUpdated() then
            -- Green for synced and altered roster (does this ever happen?)
            rosterFrame.text:SetTextColor(SRTColor.Purple.r, SRTColor.Purple.g, SRTColor.Purple.b, SRTColor.Purple.a)
        else
            -- Light gray for the rest
            rosterFrame.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        end

        if previousFrame then
            rosterFrame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -3)
        else
            rosterFrame:SetPoint("TOPLEFT", self.loadCreate.load.scroll.content, "TOPLEFT", 10, 0)
        end

        rosterFrame:SetScript("OnMouseDown", function ()
            self.selectedRoster = roster
            self:UpdateAppearance()
        end)

        rosterFrame:Show()
        self.availableRosters[id] = rosterFrame
        previousFrame = rosterFrame
        visibleRosters = visibleRosters + 1
    end

    self.loadCreate.load.scroll.content:SetHeight(23*visibleRosters)

    if self.selectedRoster then
        self.loadCreate.deleteButton.color = SRTColor.Red
        self.loadCreate.deleteButton.colorHighlight = SRTColor.RedHighlight
        FrameBuilder.UpdateButton(self.loadCreate.deleteButton)
        self.loadCreate.deleteButton:SetScript("OnMouseDown", function (button)
            if SRTData.GetActiveRosterID() == self.selectedRoster.id then
                if not Utils:IsPlayerRaidLeader() then
                    return
                end
                SRTData.SetActiveRosterID(nil)
            end
            SRTData.RemoveRoster(self.selectedRoster.id)
            self.availableRosters[self.selectedRoster.id]:Hide()
            self.availableRosters[self.selectedRoster.id] = nil
            self.selectedRoster = nil
            self:UpdateAppearance()
        end)
        self.loadCreate.editButton.color = SRTColor.Green
        self.loadCreate.editButton.colorHighlight = SRTColor.GreenHighlight
        if self.selectedRoster.owner == Utils:GetFullPlayerName() then
            self.loadCreate.editButton.displayText = "Edit"
            self.loadCreate.editButton:SetScript("OnMouseDown", function (button)
                self.state = State.ADD_OR_REMOVE_PLAYERS
                self:UpdateAppearance()
            end)
        else
            self.loadCreate.editButton.displayText = "Copy"
            self.loadCreate.editButton:SetScript("OnMouseDown", function (button)
                local copy = Roster.Copy(self.selectedRoster)
                SRTData.AddRoster(copy.id, copy)
                self.selectedRoster = copy
                self:UpdateAppearance()
            end)
        end
        FrameBuilder.UpdateButton(self.loadCreate.editButton)
        self.loadCreate.editButton:Show()
        if Utils:IsPlayerRaidLeader() and not IsEncounterInProgress() then
            self.loadCreate.activateButton.color = SRTColor.Blue
            self.loadCreate.activateButton.colorHighlight = SRTColor.BlueHighlight
            self.loadCreate.activateButton:SetScript("OnMouseDown", function (button)
                SRTData.SetActiveRosterID(self.selectedRoster.id)
                SyncController:SyncAssignmentsNow()
                SwiftdawnRaidTools.overview:Update()
                SwiftdawnRaidTools.assignmentEditor:Update()
                self:UpdateAppearance()
            end)
            FrameBuilder.UpdateButton(self.loadCreate.activateButton)
        end
        self.loadCreate.info.title:SetText(self.selectedRoster.name)

        rosterInfo.timestamp = rosterInfo.timestamp or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.timestamp:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        rosterInfo.timestamp:SetText("Last updated: "..Roster.GetLastUpdatedTimestamp(self.selectedRoster))
        rosterInfo.timestamp:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        rosterInfo.timestamp:SetPoint("TOPLEFT", 10, -5)
        rosterInfo.timestamp:Show()

        rosterInfo.owner = rosterInfo.owner or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.owner:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        rosterInfo.owner:SetText("Owned by: "..string.gsub(tostring(self.selectedRoster.owner), "-", ", ", 1))
        rosterInfo.owner:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        rosterInfo.owner:SetPoint("TOPLEFT", rosterInfo.timestamp, "BOTTOMLEFT", 0, -18)
        rosterInfo.owner:Show()

        rosterInfo.players = rosterInfo.players or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.players:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        local playerNames = nil
        for _, player in pairs(self.selectedRoster.players) do
            if playerNames then
                playerNames = string.format("%s, %s", playerNames, strsplit("-", player.name))
            else
                playerNames = string.format("\nPlayers: \n\n%s", strsplit("-", player.name))
            end
        end
        rosterInfo.players:SetText(playerNames)
        rosterInfo.players:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        rosterInfo.players:SetWidth(260)
        rosterInfo.players:SetJustifyH("LEFT")
        rosterInfo.players:SetWordWrap(true)
        rosterInfo.players:SetPoint("TOPLEFT", rosterInfo.owner, "BOTTOMLEFT", 0, -8)
        rosterInfo.players:Show()

        rosterInfo.encounters = rosterInfo.encounters or self.loadCreate.info.scroll.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rosterInfo.encounters:SetFont(self:GetPlayerFont(), self:GetAppearance().playerFontSize)
        local encounters = nil
        for _, encounterID in pairs(self:EncounterIDsWithFilledAssignments()) do
            if encounters then
                encounters = string.format("%s, %s", encounters, BossInfo.GetNameByID(encounterID))
            else
                encounters = string.format("\nEncounters: \n\n%s", BossInfo.GetNameByID(encounterID))
            end
        end
        rosterInfo.encounters:SetText(encounters)
        rosterInfo.encounters:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        rosterInfo.encounters:SetWidth(260)
        rosterInfo.encounters:SetJustifyH("LEFT")
        rosterInfo.encounters:SetWordWrap(true)
        rosterInfo.encounters:SetPoint("TOPLEFT", rosterInfo.players, "BOTTOMLEFT", 0, -8)
        rosterInfo.encounters:Show()
    else
        self.loadCreate.deleteButton.color = SRTColor.Gray
        self.loadCreate.deleteButton.colorHighlight = SRTColor.Gray
        FrameBuilder.UpdateButton(self.loadCreate.deleteButton)
        self.loadCreate.deleteButton:SetScript("OnMouseDown", nil)
        self.loadCreate.editButton:Hide()
        self.loadCreate.editButton:SetScript("OnMouseDown", nil)
        self.loadCreate.activateButton.color = SRTColor.Gray
        self.loadCreate.activateButton.colorHighlight = SRTColor.Gray
        FrameBuilder.UpdateButton(self.loadCreate.activateButton)
        self.loadCreate.activateButton:SetScript("OnMouseDown", nil)
        if rosterInfo.timestamp then rosterInfo.timestamp:Hide() end
        if rosterInfo.owner then rosterInfo.owner:Hide() end
        if rosterInfo.players then rosterInfo.players:Hide() end
        if rosterInfo.encounters then rosterInfo.encounters:Hide() end
        self.loadCreate.info.title:SetText("No roster selected")
    end
end

--- Update roster; used in Create Roster and Select Role states
function RosterBuilder:UpdateAddOrRemovePlayers()
    if self.state == State.ADD_OR_REMOVE_PLAYERS then
        self.addRemove.roster.pane:Show()
        self.addRemove.available.pane:Show()
    else
        self.addRemove.roster.pane:Hide()
        self.addRemove.available.pane:Hide()
        for _, playerFrame in pairs(self.addRemove.roster.scroll.items) do
            playerFrame:Hide()
        end
        for _, playerFrame in pairs(self.addRemove.available.scroll.items) do
            playerFrame:Hide()
        end
        return
    end

    local lastPlayerFrame
    local visiblePlayers = 0
    for _, rosteredPlayer in pairs(self.selectedRoster.players) do
        local playerFrame = self.addRemove.roster.scroll.items[rosteredPlayer.name] or FrameBuilder.CreatePlayerFrame(self.addRemove.roster.scroll.content, rosteredPlayer.name, rosteredPlayer.class.fileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14)
        playerFrame.info = rosteredPlayer.info
        if lastPlayerFrame then
            playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, 0)
        else
            playerFrame:SetPoint("TOPLEFT", self.addRemove.roster.scroll.content, "TOPLEFT", 10, 0)
        end
        playerFrame:Show()
        playerFrame:SetMovable(true)
        playerFrame:EnableMouse(true)
        playerFrame:RegisterForDrag("LeftButton")
        playerFrame:SetScript("OnDragStart", function(_)
            self.addRemove.roster.scroll.DisconnectItem(rosteredPlayer.name, playerFrame, self.content)
            playerFrame:StartMoving()
        end)
        playerFrame:SetScript("OnDragStop", function(_)
            -- Change parent back to scrollpane
            playerFrame:SetParent(self.addRemove.roster.scroll.content)
            -- Stop moving
            playerFrame:StopMovingOrSizing()
            -- Check if over other pane
            if self.addRemove.available.scroll.IsMouseOverArea() then
                -- Remove from roster
                self.selectedRoster.players[rosteredPlayer.name] = nil
                self.addRemove.roster.scroll.items[rosteredPlayer.name] = nil
                playerFrame:Hide()
            else
                self.addRemove.roster.scroll.ConnectItem(rosteredPlayer.name, playerFrame)
            end
            self:UpdateAddOrRemovePlayers()
        end)

        self.addRemove.roster.scroll.items[rosteredPlayer.name] = playerFrame
        visiblePlayers = visiblePlayers + 1
        lastPlayerFrame = playerFrame
    end

    self.addRemove.roster.title:SetText(string.format("%s (%d)", self.selectedRoster.name, visiblePlayers))
    self.addRemove.roster.scroll.content:SetHeight(23 * visiblePlayers)

    local shouldShowPlayer = function(guildMember)
        if self.addRemove.roster.scroll.items[guildMember.name] then
            return false
        end
        if not self.addRemove.available.filterPopup.items.Class.popup.items[guildMember.class].value then
            return false
        end
        if self.addRemove.available.filterPopup.items["Guild Rank"].popup.items[guildMember.rankIndex] and not self.addRemove.available.filterPopup.items["Guild Rank"].popup.items[guildMember.rankIndex].value then
            return false
        end
        if self.addRemove.available.filterPopup.items["Online only"].value then
            return guildMember.online
        end
        return true
    end

    visiblePlayers = 0
    lastPlayerFrame = nil
    for _, frame in pairs(self.addRemove.available.scroll.items) do
        frame:Hide()
    end
    for player in Utils:CombinedIteratorWithUniqueNames(Utils:GetRaidMembers(false), Utils:GetGuildMembers(false)) do
        if shouldShowPlayer(player) then
            local playerFrame = self.addRemove.available.scroll.items[player.name] or FrameBuilder.CreatePlayerFrame(self.addRemove.available.scroll.content, player.name, player.fileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14)
            playerFrame.info = player
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.addRemove.available.scroll.content, "TOPLEFT", 10, 0)
            end
            playerFrame:SetMovable(true)
            playerFrame:EnableMouse(true)
            playerFrame:RegisterForDrag("LeftButton")
            playerFrame:SetScript("OnDragStart", function(_)
                self.addRemove.available.scroll.DisconnectItem(player.name, playerFrame, self.content)
                playerFrame:StartMoving()
            end)
            playerFrame:SetScript("OnDragStop", function(_)
                -- Change parent back to scrollpane
                playerFrame:SetParent(self.addRemove.available.scroll.content)
                playerFrame:StopMovingOrSizing()
                if self.addRemove.roster.scroll.IsMouseOverArea() then
                    self.selectedRoster.players[player.name] = self.selectedRoster.players[player.name] or Player:New(player.name, SRTData.GetClass(player.fileName))
                    self.selectedRoster.players[player.name].info = player
                    playerFrame:Hide()
                else
                    self.addRemove.available.scroll.ConnectItem(player.name, playerFrame)
                end
                self:UpdateAddOrRemovePlayers()
            end)
            playerFrame:Show()
            visiblePlayers = visiblePlayers + 1
            self.addRemove.available.scroll.items[player.name] = playerFrame
            lastPlayerFrame = playerFrame
        end
    end
    self.addRemove.available.title:SetText(string.format("Available Players (%d)", visiblePlayers))
    self.addRemove.available.scroll.content:SetHeight(23 * visiblePlayers)
end

function RosterBuilder:UpdateCreateAssignments()
    if self.state == State.CREATE_ASSIGNMENTS then
        self.assignments.players.pane:Show()
        self.assignments.players.pane:SetAlpha(1)
        self.assignments.encounter.pane:Show()
        self.assignments.pickspell.pane:Hide()
    elseif self.state == State.PICK_SPELL then
        self.assignments.players.pane:Show()
        self.assignments.players.pane:SetAlpha(0.3)
        self.assignments.encounter.pane:Hide()
        self.assignments.pickspell.pane:Show()
    else
        self.assignments.players.pane:Hide()
        self.assignments.encounter.pane:Hide()
        self.assignments.pickspell.pane:Hide()
        return
    end

    local shouldShowPlayer = function(rosterPlayer)
        return true
    end

    local filledIDs = self:EncounterIDsWithFilledAssignments()
    for _, item in pairs(self.assignments.bossSelector.items) do
        item.highlight = false
    end
    for _, id in pairs(filledIDs) do
        for _, item in pairs(self.assignments.bossSelector.items) do
            if item.encounterID == id then
                item.highlight = true
            end
        end
    end
    self.assignments.bossSelector.Update()

    for _, playerFrame in pairs(self.assignments.players.scroll.items) do
        playerFrame:Hide()
    end
    local visiblePlayers = 0
    local lastPlayerFrame = nil
    for name, player in pairs(self.selectedRoster.players) do
        if shouldShowPlayer(player) then
            local playerFrame = self.assignments.players.scroll.items[name] or FrameBuilder.CreatePlayerFrame(self.assignments.players.scroll.content, name, player.class.fileName, 260, 20, self:GetPlayerFont(), self:GetAppearance().playerFontSize, 14, true)
            playerFrame:Show()
            playerFrame.info = player.info
            if lastPlayerFrame then
                playerFrame:SetPoint("TOPLEFT", lastPlayerFrame, "BOTTOMLEFT", 0, -3)
            else
                playerFrame:SetPoint("TOPLEFT", self.assignments.players.scroll.content, "TOPLEFT", 10, 0)
            end
            playerFrame:SetMovable(true)
            playerFrame:EnableMouse(true)
            playerFrame:RegisterForDrag("LeftButton")
            playerFrame:SetScript("OnDragStart", function(_)
                self.assignments.players.scroll.DisconnectItem(name, playerFrame, self.content)
                playerFrame:SetScript("OnUpdate", function ()
                    local mouseOverFound = false
                    for _, assignmentFrame in pairs(self.assignments.encounter.scroll.items) do
                        assignmentFrame:SetBackdropColor(0, 0, 0, 0)
                        if assignmentFrame:IsShown() and assignmentFrame.IsMouseOverFrame() then
                            for _, groupFrame in pairs(assignmentFrame.groups) do
                                groupFrame:SetBackdropColor(0, 0, 0, 0)
                                if groupFrame:IsShown() and groupFrame.IsMouseOverFrame() then
                                    groupFrame:SetBackdropColor(1, 1, 1, 0.4)
                                    mouseOverFound = true
                                end
                            end
                            if mouseOverFound == false then
                                assignmentFrame:SetBackdropColor(1, 1, 1, 0.4)
                            end
                        end
                    end
                end)
                playerFrame:StartMoving()
            end)
            playerFrame:SetScript("OnDragStop", function(_)
                playerFrame:StopMovingOrSizing()
                self.assignments.players.scroll.ConnectItem(name, playerFrame)
                playerFrame:SetScript("OnUpdate", nil)
                for _, assignmentFrame in pairs(self.assignments.encounter.scroll.items) do
                    if assignmentFrame:IsShown() and assignmentFrame.IsMouseOverFrame() then
                        assignmentFrame:SetBackdropColor(0, 0, 0, 0)
                        self.selectedRoster.encounters = self.selectedRoster.encounters or {}
                        self.selectedRoster.encounters[self.selectedEncounterID] = self.selectedRoster.encounters[self.selectedEncounterID] or SRTData.GetAssignmentDefaults()[self.selectedEncounterID]
                        self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex] or {}
                        self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments = self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments or {}
                        for _, groupFrame in pairs(assignmentFrame.groups) do
                            if groupFrame:IsShown() and groupFrame.IsMouseOverFrame() then
                                groupFrame:SetBackdropColor(0, 0, 0, 0)
                                self.pickedPlayer = { name = player.name, fileName = player.class.fileName }
                                self.pickedAssignment = {
                                    encounterID = self.selectedEncounterID,
                                    abilityIndex = assignmentFrame.abilityIndex,
                                    groupIndex = groupFrame.index
                                }
                                self.state = State.PICK_SPELL
                                self:UpdateCreateAssignments()
                                return
                            end
                        end

                        self.pickedPlayer = { name = player.name, fileName = player.class.fileName }
                        self.pickedAssignment = {
                            encounterID = self.selectedEncounterID,
                            abilityIndex = assignmentFrame.abilityIndex,
                            groupIndex = #self.selectedRoster.encounters[self.selectedEncounterID][assignmentFrame.abilityIndex].assignments + 1,
                        }
                        self.state = State.PICK_SPELL
                        self:UpdateCreateAssignments()
                        return
                    end
                end
                self:UpdateCreateAssignments()
            end)
            lastPlayerFrame = playerFrame
            self.assignments.players.scroll.items[name] = playerFrame
            visiblePlayers = visiblePlayers + 1
        end
    end
    self.assignments.players.scroll.content:SetHeight(23 * visiblePlayers)

    if self.state == State.CREATE_ASSIGNMENTS then
        if self.selectedEncounterID == nil then
            return
        elseif SRTData.GetAssignmentDefaults()[self.selectedEncounterID] == nil and self.selectedRoster and self.selectedRoster.encounters and not self.selectedRoster.encounters[self.selectedEncounterID] then
            self.assignments.encounter.title:SetText("No defaults available yet...")
            self.assignments.encounter.scroll:Hide()
            return
        else
            self.assignments.encounter.title:SetText("")
            self.assignments.encounter.scroll:Show()
        end
        for _, abilityFrame in pairs(self.assignments.encounter.scroll.items) do
            abilityFrame:SetBackdropColor(0, 0, 0, 0)
            for _, groupFrame in pairs(abilityFrame.groups) do
                groupFrame:SetBackdropColor(0, 0, 0, 0)
            end
        end
        self.selectedRoster.encounters = self.selectedRoster.encounters or {}
        local encounterAssignments = self.selectedRoster.encounters[self.selectedEncounterID] or SRTData.GetAssignmentDefaults()[self.selectedEncounterID]
        for _, abilityFrame in pairs(self.assignments.encounter.scroll.items) do
            abilityFrame:Hide()
        end
        local lastAbilityFrame = nil
        for bossAbilityIndex, bossAbility in ipairs(encounterAssignments) do
            -- Create frame for boss ability assignment groups
            local abilityFrameID = string.format("%d-%d", self.selectedEncounterID, bossAbilityIndex)
            local abilityFrame = self.assignments.encounter.scroll.items[abilityFrameID] or FrameBuilder.CreateBossAbilityAssignmentsFrame(self.assignments.encounter.scroll.content, bossAbility.metadata.name, bossAbilityIndex, 260, self:GetPlayerFont(), 16)
            if lastAbilityFrame then
                abilityFrame:SetPoint("TOPLEFT", lastAbilityFrame, "BOTTOMLEFT", 0, -3)
            else
                abilityFrame:SetPoint("TOPLEFT", self.assignments.encounter.scroll.content, "TOPLEFT", 5, 0)
            end

            -- Create known frames for current assignment groups and inner assignments
            for _, group in pairs(abilityFrame.groups) do group:Hide() end
            abilityFrame.groups = {}
            local previousGroup = nil
            for groupIndex, group in ipairs(encounterAssignments[bossAbilityIndex].assignments) do
                local groupFrame = abilityFrame.groups[groupIndex] or FrameBuilder.CreateAssignmentGroupFrame(abilityFrame, self:GetAssignmentGroupHeight() + 3)
                FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, "uuid-empty", groupIndex, self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
                
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
                local previousAssignmentFrame = nil
                for assignmentIndex, assignment in ipairs(group) do
                    local assignmentFrame = groupFrame.assignments[assignmentIndex] or FrameBuilder.CreateAssignmentFrame(groupFrame, assignmentIndex, self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize)
                    FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment)
                    
                    assignmentFrame:ClearAllPoints()
                    if previousAssignmentFrame then
                        assignmentFrame:SetPoint("TOPLEFT", groupFrame, "TOP", 0, 0)
                        assignmentFrame:SetPoint("BOTTOMRIGHT", groupFrame, "BOTTOMRIGHT", 0, 0)
                    else
                        assignmentFrame:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 0)
                        assignmentFrame:SetPoint("BOTTOMRIGHT", groupFrame, "BOTTOM", 0, 0)
                    end

                    assignmentFrame:SetScript("OnMouseDown", function (af, button)
                        if button == "LeftButton" then
                            self.pickedPlayer = { name = assignmentFrame.player, fileName = SRTData.GetClassBySpellID(assignmentFrame.spellId).fileName }
                            self.pickedAssignment = {
                                encounterID = self.selectedEncounterID,
                                abilityIndex = bossAbilityIndex,
                                groupIndex = groupIndex,
                                assignmentIndex = assignmentIndex
                            }
                            self.state = State.PICK_SPELL
                            self:UpdateCreateAssignments()
                        elseif button == "RightButton" then
                            af:Hide()
                            local changes = { removed = encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index] }
                            if af.index == 1 and #encounterAssignments[bossAbilityIndex].assignments[groupIndex] > 1 then
                                encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index] = encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index + 1]
                                encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index + 1] = nil
                                encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index].index = 1
                            else
                                encounterAssignments[bossAbilityIndex].assignments[groupIndex][af.index] = nil
                            end
                            if #encounterAssignments[bossAbilityIndex].assignments[groupIndex] == 0 then
                                groupFrame:Hide()
                                for i = groupIndex, #encounterAssignments[bossAbilityIndex].assignments, 1 do
                                    if i == #abilityFrame.groups then
                                        abilityFrame.groups[i] = nil
                                        encounterAssignments[bossAbilityIndex].assignments[i] = nil
                                    else
                                        abilityFrame.groups[i] = abilityFrame.groups[i+1]
                                        abilityFrame.groups[i].index = abilityFrame.groups[i].index - 1
                                        encounterAssignments[bossAbilityIndex].assignments[i] = encounterAssignments[bossAbilityIndex].assignments[i+1]
                                    end
                                end
                            end
                            Roster.MarkUpdated(self.selectedRoster, changes)
                            self:UpdateCreateAssignments()
                        end
                    end)

                    assignmentFrame.groupIndex = groupIndex
                    groupFrame.assignments[assignmentIndex] = assignmentFrame
                    previousAssignmentFrame = assignmentFrame
                end

                abilityFrame.groups[groupIndex] = groupFrame
                previousGroup = groupFrame
            end
            abilityFrame.Update()
            abilityFrame:Show()

            self.assignments.encounter.scroll.items[abilityFrameID] = abilityFrame
            lastAbilityFrame = abilityFrame
        end
    end

    if self.state == State.PICK_SPELL then
        if self.pickedPlayer == nil then
            print("Unable to open spell picker, no player selected")
            self.state = State.CREATE_ASSIGNMENTS
            return
        end
        local class = SRTData.GetClass(self.pickedPlayer.fileName)

        for _, spellFrame in pairs(self.assignments.pickspell.scroll.items) do
            spellFrame:Hide()
        end

        local scrollHeight = 0
        local previousSpellFrame = nil
        for _, spell in pairs(class.spells) do
            local spellFrame = self.assignments.pickspell.scroll.items[spell.id] or FrameBuilder.CreateLargeSpellFrame(self.assignments.pickspell.scroll.content)
            FrameBuilder.UpdateLargeSpellFrame(spellFrame, spell.id, self:GetPlayerFont(), self:GetAppearance().playerFontSize, self:GetAppearance().iconSize * 3)
            spellFrame.spellID = spell.id
            spellFrame:SetWidth(280)
            spellFrame:SetScript("OnEnter", function () spellFrame:SetBackdropColor(1, 1, 1, 0.4) end)
            spellFrame:SetScript("OnLeave", function () spellFrame:SetBackdropColor(0, 0, 0, 0) end)
            spellFrame:SetScript("OnMouseDown", function (sf, button)
                if button == "LeftButton" then
                    local encounterID = self.pickedAssignment.encounterID
                    local abilityIndex = self.pickedAssignment.abilityIndex
                    local groupIndex = self.pickedAssignment.groupIndex

                    self.selectedRoster.encounters = self.selectedRoster.encounters or {}
                    self.selectedRoster.encounters[encounterID] = self.selectedRoster.encounters[encounterID] or SRTData.GetAssignmentDefaults()[encounterID]
                    self.selectedRoster.encounters[encounterID][abilityIndex] = self.selectedRoster.encounters[encounterID][abilityIndex] or {}
                    self.selectedRoster.encounters[encounterID][abilityIndex].assignments = self.selectedRoster.encounters[encounterID][abilityIndex].assignments or {}

                    local numberOfGroups = #self.selectedRoster.encounters[encounterID][abilityIndex].assignments

                    if self.pickedAssignment.assignmentIndex then
                        local assignmentIndex = self.pickedAssignment.assignmentIndex
                        self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex][assignmentIndex] = {
                            ["spell_id"] = sf.spellID,
                            ["type"] = "SPELL",
                            ["player"] = self.pickedPlayer.name,
                        }
                        Roster.MarkUpdated(self.selectedRoster, { added = self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex][assignmentIndex] })
                    elseif groupIndex == 0 then
                        self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1] = {}
                        table.insert(self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1], {
                            ["spell_id"] = sf.spellID,
                            ["type"] = "SPELL",
                            ["player"] = self.pickedPlayer.name,
                        })
                        Roster.MarkUpdated(self.selectedRoster, { added = self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1][1] })
                    elseif not self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex] or #self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex] < 2 then
                        self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex] = self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex] or {}
                        table.insert(self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex], {
                            ["spell_id"] = sf.spellID,
                            ["type"] = "SPELL",
                            ["player"] = self.pickedPlayer.name,
                        })
                        Roster.MarkUpdated(self.selectedRoster, { added = self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex][#self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex]] })
                    elseif #self.selectedRoster.encounters[encounterID][abilityIndex].assignments[groupIndex] >= 2 then
                        self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1] = {}
                        table.insert(self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1], {
                            ["spell_id"] = sf.spellID,
                            ["type"] = "SPELL",
                            ["player"] = self.pickedPlayer.name,
                        })
                        Roster.MarkUpdated(self.selectedRoster, { added = self.selectedRoster.encounters[encounterID][abilityIndex].assignments[numberOfGroups + 1][1] })
                    end
                    self.state = State.CREATE_ASSIGNMENTS
                    self:UpdateCreateAssignments()
                end
            end)
            if previousSpellFrame then
                spellFrame:SetPoint("TOPLEFT", previousSpellFrame, "BOTTOMLEFT", 0, -7)
            else
                spellFrame:SetPoint("TOPLEFT", self.assignments.pickspell.scroll.content, "TOPLEFT", 10, 0)
            end
            spellFrame:Show()
            self.assignments.pickspell.scroll.items[spell.id] = spellFrame
            previousSpellFrame = spellFrame
            scrollHeight = scrollHeight + spellFrame:GetHeight() + 7
        end
        self.assignments.pickspell.scroll.content:SetHeight(scrollHeight)
    end
end

function RosterBuilder:UpdateImportRoster()
    if self.state == State.IMPORT_ROSTER then
        self.import.input.pane:Show()
        self.import.info.pane:Show()
    else
        self.import.input.pane:Hide()
        self.import.info.pane:Hide()
        return
    end
end

function RosterBuilder:GetAssignmentGroupHeight()
    local playerFontSize = self:GetAppearance().playerFontSize
    local iconSize = self:GetAppearance().iconSize
    return (playerFontSize > iconSize and playerFontSize or iconSize) + 7
end

function RosterBuilder:Update()
    SRTWindow.Update(self)
    self.assignments.bossSelector.items = {}
    for _, instanceInfo in Utils:OrderedPairs(BossInfo.instances) do
        for encounterID, encounterInfo in Utils:OrderedPairs(instanceInfo.encounters) do
            local item = {
                name = encounterInfo.name,
                encounterID = encounterID,
                onClick = function (row)
                    self.selectedEncounterID = row.item.encounterID
                    self:UpdateAppearance()
                end
            }
            table.insert(self.assignments.bossSelector.items, item)
        end
    end
    self.assignments.bossSelector.selectedName = self.selectedEncounterID and BossInfo.GetEncounterInfoByID(self.selectedEncounterID) or "Select encounter..."
    self.assignments.bossSelector.Update()
end

---@return FontFile
function RosterBuilder:GetHeaderFontType()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

---@return FontFile
function RosterBuilder:GetPlayerFont()
    ---@class FontFile
    return SharedMedia:Fetch("font", self:GetAppearance().playerFontType)
end

function RosterBuilder:UpdatePopupMenu()
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