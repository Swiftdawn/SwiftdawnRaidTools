local SwiftdawnRaidTools = SwiftdawnRaidTools

---@class SRTDebugLog:SRTWindow
SRTDebugLog = setmetatable({
    logItems = {},
    maxFrames = 500,
    log = {}
}, SRTWindow)
SRTDebugLog.__index = SRTDebugLog

---@return SRTDebugLog
function SRTDebugLog:New(height, width)
    local obj = SRTWindow.New(self, "DebugLog", height, width)
    ---@cast obj SRTDebugLog
    self.__index = self
    return obj
end

function SRTDebugLog:Initialize()
    SRTWindow.Initialize(self)
    self.headerText:SetText("Debug Log")

    -- Create the scroll frame
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollFrame = CreateFrame("ScrollFrame", "SRT_"..self.name.."_ScrollFrame", self.main, "UIPanelScrollFrameTemplate")
    self.scrollFrame:SetPoint("TOPLEFT", self.main, "TOPLEFT", 0, 0)
    self.scrollFrame:SetPoint("TOPRIGHT", self.main, "TOPRIGHT", 0, 0)
    self.scrollFrame:SetPoint("BOTTOMLEFT", self.main, "BOTTOMLEFT", 0, 5)
    self.scrollFrame:SetPoint("BOTTOMRIGHT", self.main, "BOTTOMRIGHT", 0, 5)

    self.scrollBar = _G[self.scrollFrame:GetName() .. "ScrollBar"]
    self.scrollBar.scrollStep = logFontSize  -- Change this value to adjust the scroll amount per tick
    -- Create a content frame to hold the text
    self.scrollContentFrame = CreateFrame("Frame", "SRT_"..self.name.."_ContentFrame", self.scrollFrame)
    self.scrollContentFrame:SetSize(500, MIN_HEIGHT)  -- Set the size of the content frame (height is larger for scrolling)
    self.scrollContentFrame:SetPoint("TOPLEFT")
    self.scrollContentFrame:SetPoint("TOPRIGHT")

    -- Set the content frame as the scroll frame's scroll child
    self.scrollFrame:SetScrollChild(self.scrollContentFrame)

    self.menuButton:SetScript("OnClick", function()
        if not SRT_IsTesting() and InCombatLockdown() then
            return
        end
        self:UpdatePopupMenu()
        self.popupMenu:Show()
    end)

    self:UpdateAppearance()
end

function SRTDebugLog:ScrollToBottom()
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollBar:SetValue(15 + #self.logItems * (logFontSize + 3))
end

--- Add a log statement to the debug log
---@param data table
function SRTDebugLog:AddItem(data, ...)
    if not AssignmentsController:IsInEncounter() then
        if SRT_IsDebugging() then SwiftdawnRaidTools:Print("[DEBUG] Not adding log data. No encounter going on!", ...) end
        return
    else
        local encounterID = AssignmentsController.activeEncounterID
        local encounterStart = AssignmentsController.encounterStart
        if not encounterStart then
            if SRT_IsDebugging() then SwiftdawnRaidTools:Print("[DEBUG] Not adding log data. No start time known for current encounter!", ...) end
            return
        else
            self.log[encounterID] = self.log[encounterID] or {}
            self.log[encounterID][encounterStart] = self.log[encounterID][encounterStart] or {}
            table.insert(self.log[encounterID][encounterStart], data)
        end
    end

    if #self.logItems < self.maxFrames then
        -- Create a new frame and attach at the bottom
        local newItem = LogItem:New(data, ...)
        newItem:CreateFrame(self.scrollContentFrame)
        if #self.logItems == 0 then
            newItem.frame:SetPoint("TOPLEFT", self.scrollContentFrame, "TOPLEFT", 5, -3)
        else
            newItem.frame:SetPoint("TOPLEFT", self.logItems[#self.logItems].frame, "BOTTOMLEFT", 0, -3)
        end
        table.insert(self.logItems, newItem)
    else
        -- Grab first frame, update and attach at the bottom
        local cachedItem = table.remove(self.logItems, 1)
        cachedItem.frame:ClearAllPoints()
        local firstItem = self.logItems[1]
        firstItem.frame:ClearAllPoints()
        firstItem.frame:SetPoint("TOPLEFT", self.scrollContentFrame, "TOPLEFT", 5, -3)
        local lastItem = self.logItems[#self.logItems]
        cachedItem.frame:SetPoint("TOPLEFT", lastItem.frame, "BOTTOMLEFT", 0, -3)
        cachedItem:NewData(data, ...)
        cachedItem:UpdateAppearance()
        table.insert(self.logItems, cachedItem)
    end
    if self:GetProfile().scrollToBottom then
        self:ScrollToBottom()
    end
end

function SRTDebugLog:UpdateAppearance()
    local logFontSize = self:GetAppearance().logFontSize
    self.scrollContentFrame:SetHeight(15 + #self.logItems * (logFontSize + 3) + 5)
    for _, item in ipairs(self.logItems) do
        item:UpdateAppearance()
    end
    self.scrollBar.scrollStep = logFontSize * 2
    SRTWindow.UpdateAppearance(self)
end

function SRTDebugLog:UpdateAutoScroll()
    if self:GetProfile().scrollToBottom then
        self:ScrollToBottom()
    end
end

function SRTDebugLog:ToggleAutoScroll()
    self:GetProfile().scrollToBottom = not self:GetProfile().scrollToBottom
    self:UpdateAutoScroll()
end

function SRTDebugLog:ClearWindow()
    for i, _ in ipairs(self.logItems) do
        self.logItems[i]:DeleteFrame()
    end
    self.logItems = {}
    self:UpdateAppearance()
end

function SRTDebugLog:UpdatePopupMenu()
    if InCombatLockdown() then
        return
    end

    self.popupMenu.Update({
        { name = "Clear Log", onClick = function() self:ClearWindow() end },
        { name = self:GetProfile().scrollToBottom and "Don't autoscroll" or "Autoscroll", onClick = function() self:ToggleAutoScroll() end },
        {},
        { name = "Configuration", onClick = function() Settings.OpenToCategory("Swiftdawn Raid Tools") end, isSetting = true },
        {},
        { name = self:GetProfile().locked and "Unlock Window" or "Lock Window", onClick = function() self:ToggleLock() end, isSetting = true },
        { name = "Close Window", onClick = function() self:CloseWindow() end, isSetting = true },
        {},
        { name = "Close", onClick = nil, isSetting = true },
    })
end