local insert = table.insert

local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")
local SONAR_SOUND_FILE = "Interface\\AddOns\\SwiftdawnRaidTools\\Media\\PowerAuras_Sounds_Sonar.mp3"

local function BossAbilityFontType()
    return SharedMedia:Fetch("font", SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType)
end

local function BossAbilityFontSize()
    return SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize
end

local function CountdownFontType()
    return SharedMedia:Fetch("font", SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType)
end

local function CountdownFontSize()
    return SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize
end

local function PlayerFontType()
    return SharedMedia:Fetch("font", SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType)
end

local function PlayerFontSize()
    return SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize
end

local function PlayerIconSize()
    return SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize
end

local function GetHeaderHeight()
    local bossAbilityFontSize = PlayerFontSize()
    local countdownFontSize = CountdownFontSize()
    local padding = 7
    return (bossAbilityFontSize > countdownFontSize and bossAbilityFontSize or countdownFontSize) + padding
end

local function GetAssignmentHeight()
    local playerFontSize = PlayerFontSize()
    local iconSize = PlayerIconSize()
    return playerFontSize > iconSize and playerFontSize or iconSize
end

local function GetContentHeight()
    local assignmentHeight = GetAssignmentHeight()
    local padding = 17
    return assignmentHeight + padding
end

---@class SRTNotification
SRTNotification = {}
SRTNotification.__index = SRTNotification

---#return SRTNotification
function SRTNotification:New()
    ---@class SRTNotification
    local obj = setmetatable({}, self)
    obj.container = CreateFrame("Frame", "SwiftdawnRaidToolsNotification", UIParent, "BackdropTemplate")
    obj.content = CreateFrame("Frame", "SwiftdawnRaidToolsNotificationContent", obj.container, "BackdropTemplate")
    obj.extraInfo = CreateFrame("Frame", nil, obj.container, "BackdropTemplate")
    obj.notificationShowId = ""
    obj.notificationRaidAssignmentGroups = {}
    obj.notificationsCountdown = 0
    obj.notificationsCountdownFade = 2
    return obj
end

---Get top left coordinates
---@param frame table|BackdropTemplate|Frame
---@return number
---@return number
local function GetScaledTopLeftCoords(frame)
    local x = frame:GetLeft()
    local y = frame:GetTop()
    return x, y
end

---Function to re-anchor the frame
---@param frame table|BackdropTemplate|Frame
local function ReAnchorFrame(frame)
    local x, y = GetScaledTopLeftCoords(frame)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

function SRTNotification:Initialize()
    SwiftdawnRaidTools.db.profile.notifications.locked = true

    -- The base frame that dictates the size of the notification
    if SwiftdawnRaidTools.db.profile.notifications.anchorX and SwiftdawnRaidTools.db.profile.notifications.anchorY then
        self.container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", SwiftdawnRaidTools.db.profile.notifications.anchorX, SwiftdawnRaidTools.db.profile.notifications.anchorY)
    else
        self.container:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    end
    self.container:SetFrameStrata("HIGH")
    self.container:SetMovable(true)
    self.container:SetUserPlaced(true)
    self.container:SetClampedToScreen(true)
    self.container:RegisterForDrag("LeftButton")
    self.container:SetScript("OnDragStart", function(container) container:StartMoving() end)
    self.container:SetScript("OnDragStop", function(container)
        container:StopMovingOrSizing()
        ReAnchorFrame(self.container)
    end)
    self.container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    self.container:SetBackdropColor(0, 0, 0, 0)

    -- The unlocked frame anchor; only visible if anchors are unlocked
    self.container.frameLockText = self.container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.container.frameLockText:SetTextColor(1, 1, 1, 0.4)
    self.container.frameLockText:SetPoint("TOP", self.container, "TOP", 0, -15)
    self.container.frameLockText:SetText("SRT Notifications Anchor")
    self.container.frameLockText:Hide()
    self.container.frameLockPositionText = self.container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.container.frameLockPositionText:SetTextColor(1, 1, 1, 0.4)
    self.container.frameLockPositionText:SetPoint("BOTTOM", self.container, "BOTTOM", 0, 15)
    self.container.frameLockPositionText:SetText("X, Y")
    self.container.frameLockPositionText:Hide()

    -- The notification itself
    self.content:SetAllPoints()
    self.content:SetBackdrop({
        bgFile = "Interface\\Cooldown\\LoC-ShadowBG"
    })
    self.content.bossAbilityText = self.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.content.bossAbilityText:SetTextColor(1, 1, 1, 1)
    self.content.bossAbilityText:SetPoint("LEFT", 30, -1)
    self.content.bossAbilityText:SetPoint("TOP", 0, -8)
    self.content.countdown = self.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.content.countdown:SetTextColor(1, 1, 1, 1)
    self.content.countdown:SetPoint("RIGHT", -30, -1)
    self.content.countdown:SetPoint("TOP", 0, -8)

    self.content:Hide()

    self.extraInfo:SetHeight(30)
    self.extraInfo:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    self.extraInfo:SetBackdropColor(0, 0, 0, 0.6)
    self.extraInfo.text = self.extraInfo:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.extraInfo.text:SetFont("Fonts\\ARIALN.TTF", 12)
    self.extraInfo.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    self.extraInfo.text:SetPoint("BOTTOMLEFT", 32, 8)
    self.extraInfo.text:SetWidth(200)
    self.extraInfo.text:SetJustifyH("LEFT")
    self.extraInfo.text:SetJustifyV("TOP")
    self.extraInfo.text:SetWordWrap(true)

    self.extraInfo:Hide()

    self.notificationFrameFadeOut = Utils:CreateFadeOut(self.content, function()
        self.content:Hide()
    end)

    self:UpdateAppearance()
end

function SRTNotification:UpdateAppearance()
    local headerFontSize = BossAbilityFontSize()
    local countdownFontSize = CountdownFontSize()
    local playerFontSize = PlayerFontSize()
    local iconSize = PlayerIconSize()

    self.container:SetSize(250, GetHeaderHeight() + GetContentHeight())
    self.container:SetScale(SwiftdawnRaidTools.db.profile.notifications.appearance.scale)

    self.content:SetBackdropColor(0, 0, 0, SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity)
    self.content.bossAbilityText:SetFont(BossAbilityFontType(), headerFontSize)
    self.content.countdown:SetFont(CountdownFontType(), countdownFontSize)

    for _, groupFrame in pairs(self.notificationRaidAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            assignmentFrame.text:SetFont(PlayerFontType(), playerFontSize)
            assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
        end
    end
end

function SRTNotification:ToggleFrameLock(lock)
    if lock or self.container:IsMouseEnabled() then
        self.container:EnableMouse(false)
        self.container:SetBackdropColor(0, 0, 0, 0)
        self.container.frameLockText:Hide()
        self.container.frameLockPositionText:Hide()
        self.container:SetScript("OnUpdate", nil)
    else
        self.container:ClearAllPoints()
        self.container:EnableMouse(true)
        self.container:SetBackdropColor(0, 0, 0, 0.6)
        self.container.frameLockText:Show()
        self.container.frameLockPositionText:Show()
        self.content:Hide()
        self.container:SetScript("OnUpdate", function (frame)
            local x, y = GetScaledTopLeftCoords(frame)
            SwiftdawnRaidTools.db.profile.notifications.anchorX = x
            SwiftdawnRaidTools.db.profile.notifications.anchorY = y
            if x and y then
                self.container.frameLockPositionText:SetText(string.format("%.1f, %.1f", x, y))
            else
                self.container.frameLockPositionText:SetText("X, Y")
            end
        end)
    end
end

function SRTNotification:UpdateHeader(text)
    self.content.bossAbilityText:SetText(Utils:StringEllipsis(text, 32))
end

local function createNotificationGroup(contentFrame, assignmentCount)
    local groupFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    groupFrame:SetSize(120*assignmentCount+10, GetAssignmentHeight())
    groupFrame.assignments = {}
    return groupFrame
end

local function createNotificationGroupAssignment(groupFrame)
    local assignmentFrame = CreateFrame("Frame", nil, groupFrame, "BackdropTemplate")
    local iconSize = PlayerIconSize()
    local assignmentHeight = GetAssignmentHeight()

    assignmentFrame:SetSize(120, assignmentHeight)

    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)

    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()
    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame
    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(PlayerFontType(), PlayerFontSize())
    assignmentFrame.text:SetTextColor(1, 1, 1, 1)

    return assignmentFrame
end

function SRTNotification:UpdateNotificationGroupAssignment(assignmentFrame, assignment, index, total)
    assignmentFrame:Show()

    local iconSize = PlayerIconSize()

    assignmentFrame.player = assignment.player
    assignmentFrame.spellId = assignment.spell_id

    local spellIcon, _ = C_Spell.GetSpellTexture(assignment.spell_id)

    assignmentFrame.icon:SetTexture(spellIcon)
    assignmentFrame.text:SetText(assignment.player)

    local color = SRTData.GetClassColorBySpellID(assignment.spell_id)

    assignmentFrame.text:SetTextColor(color.r, color.g, color.b)

    assignmentFrame.cooldownFrame:Clear()

    assignmentFrame.text:ClearAllPoints()
    assignmentFrame.iconFrame:ClearAllPoints()

    local offset = (index - 1) * 120 + 4
    assignmentFrame:SetPoint("TOPLEFT", assignmentFrame:GetParent(), "TOPLEFT", offset, 0)

    if index == 1 then
        assignmentFrame.iconFrame:SetPoint("LEFT", assignmentFrame, "LEFT", 26, 0)
        assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "RIGHT", iconSize / 3, 0)

    else
        assignmentFrame.text:SetPoint("RIGHT", assignmentFrame, "RIGHT", -26, 0)
        assignmentFrame.iconFrame:SetPoint("RIGHT", assignmentFrame.text, "LEFT", iconSize / -3, 0)
    end
end

function SRTNotification:UpdateNotificationGroup(groupFrame, group, uuid, index)
    groupFrame:Show()

    groupFrame.uuid = uuid
    groupFrame.index = index

    local heightOffset = 11
    groupFrame:SetPoint("TOPLEFT", 0, -(GetHeaderHeight()+ heightOffset))
    groupFrame:SetPoint("TOPRIGHT", 0, -(GetHeaderHeight()+ heightOffset))

    for _, cd in pairs(groupFrame.assignments) do
        cd:Hide()
    end
    
    for i, assignment in ipairs(group) do
        if not groupFrame.assignments[i] then
            groupFrame.assignments[i] = createNotificationGroupAssignment(groupFrame)
        end

        SRTNotification:UpdateNotificationGroupAssignment(groupFrame.assignments[i], assignment, i, #group)
    end
end

local function updateExtraInfo(frame, prevFrame, assignments, activeGroups)
    -- Use BETCH_MATCH recursivly to create list of follow ups. This list might not be
    -- the correct order in which assignments will be selected but its the best
    -- estimation we can do.
    local groups = {}

    local assignmentsClone = Utils:ShallowClone(assignments)

    local bestMatchIndex = AssignmentsController:SelectBestMatchIndex(assignmentsClone)
    if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end

    while bestMatchIndex do
        insert(groups, bestMatchIndex)

        bestMatchIndex = AssignmentsController:SelectBestMatchIndex(assignmentsClone)
        if bestMatchIndex then assignmentsClone[bestMatchIndex] = nil end
    end

    for _, index in ipairs(activeGroups) do
        for i, group in ipairs(groups) do
            if group == index then
                groups[i] = nil
            end
        end
    end

    local playersKeySet = {}

    for _, index in pairs(groups) do
        local group = assignments[index]

        if group then
            for _, assignment in ipairs(group) do
                if assignment.type == "SPELL" and SpellCache.IsSpellReady(assignment.player, assignment.spell_id) then
                    insert(playersKeySet, assignment.player)
                end
            end
        end
    end

    local players={}

    for _, player in pairs(playersKeySet) do
        insert(players, player)
    end

    if #players > 0 then
        frame:Show()
        frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, 0)
        frame:SetPoint("TOPRIGHT", prevFrame, "BOTTOMRIGHT", 0, 0)
        frame.text:SetText("→ " .. Utils:StringJoin(players) .. " follow up.")
        frame:SetHeight(frame.text:GetStringHeight() + 10)
    end
end

function SRTNotification:ShowRaidAssignment(uuid, context, delay, countdown)
    local selectedEncounterId = SwiftdawnRaidTools.db.profile.overview.selectedEncounterId
    local encounter = SRTData.GetActiveEncounters()[selectedEncounterId]

    if not SRT_IsTesting() then
        if SwiftdawnRaidTools.db.profile.notifications.showOnlyOwnNotifications then
            local part = Utils:GetRaidAssignmentPart(uuid)

            if part and not Utils:IsPlayerInActiveGroup(part) then
                return
            end
        end
    end

    self.extraInfo:Hide()

    for _, group in pairs(self.notificationRaidAssignmentGroups) do
        group:Hide()
    end

    if encounter then            
        local groupIndex = 1
        for _, part in pairs(encounter) do
            if part.type == "RAID_ASSIGNMENTS" and part.uuid == uuid then
                local activeGroups = Groups.GetActive(uuid)

                if not activeGroups or #activeGroups == 0 then
                    return
                end
                
                self:ToggleFrameLock(true)
    
                self.notificationFrameFadeOut:Stop()
                self.content:Show()
            
                if not SwiftdawnRaidTools.db.profile.notifications.mute then
                    PlaySoundFile(SONAR_SOUND_FILE, "Master")
                end

                -- Update header
                local headerText = part.metadata.name

                if part.metadata.notification then
                    local ok, result = Utils:StringInterpolate(part.metadata.notification, context)
                    if ok then
                        headerText = result
                    end
                end

                self:UpdateHeader(headerText)

                if countdown > 0 then
                    self.notificationsCountdown = countdown
                    self.content.countdown:Show()
                    self.content:SetScript("OnUpdate", function (_, elapsed)
                        self.notificationsCountdown = self.notificationsCountdown - elapsed
                    
                        if self.notificationsCountdown > 0 then
                            self.content.countdown:SetText(string.format("%.1fs", self.notificationsCountdown))
                        else
                            self.content.countdown:SetText("NOW")
                            -- Make the NOW pop by adding 2 points of font size temporarily
                            local countdownFontSize = CountdownFontSize()
                            self.content.countdown:SetFont(CountdownFontType(), countdownFontSize + 2)
                            self.content.countdown:SetTextColor(1, 0, 0, 1)
                            self.notificationsCountdownFade = 2
                            self.content:SetScript("OnUpdate", function (_, elapsed)
                                self.notificationsCountdownFade = self.notificationsCountdownFade - elapsed
                                if self.notificationsCountdownFade > 0 then
                                    local opacity = self.notificationsCountdownFade / 2
                                    self.content.countdown:SetTextColor(1, 0, 0, opacity)
                                else
                                    self.content.countdown:Hide()
                                    self.content.countdown:SetTextColor(1, 1, 1, 1)
                                    -- Reset countdown font size
                                    self.content.countdown:SetFont(CountdownFontType(), countdownFontSize)
                                    self.content:SetScript("OnUpdate", nil)
                                end
                            end)
                        end
                    end)
                end

                local showId = Utils:GenerateUUID()
                self.notificationShowId = showId

                C_Timer.After(8 + countdown, function()
                    if showId == self.notificationShowId then
                        self.notificationFrameFadeOut:Play()
                    end
                end)

                -- Update groups
                for _, index in ipairs(activeGroups) do
                    if not self.notificationRaidAssignmentGroups[groupIndex] then
                        self.notificationRaidAssignmentGroups[groupIndex] = createNotificationGroup(self.content, #part.assignments[index])
                    end
                    local groupFrame = self.notificationRaidAssignmentGroups[groupIndex]
                    SRTNotification:UpdateNotificationGroup(groupFrame, part.assignments[index], part.uuid, index)
                    groupIndex = groupIndex + 1
                end

                break
            end
        end
    end
end

function SRTNotification:UpdateSpells()
    for _, groupFrame in pairs(self.notificationRaidAssignmentGroups) do
        for _, assignmentFrame in pairs(groupFrame.assignments) do
            if SpellCache.IsSpellActive(assignmentFrame.player, assignmentFrame.spellId) then
                local castTimestamp = SpellCache.GetCastTime(assignmentFrame.player, assignmentFrame.spellId)
                local spell = SRTData.GetSpellByID(assignmentFrame.spellId)
                if castTimestamp and spell then
                    assignmentFrame.cooldownFrame:SetCooldown(castTimestamp, spell.duration)
                end
                assignmentFrame:SetAlpha(1)
            else
                if SpellCache.IsSpellReady(assignmentFrame.player, assignmentFrame.spellId) then
                    assignmentFrame:SetAlpha(1)
                else
                    assignmentFrame:SetAlpha(0.4)
                end
            end
        end
    end
end
