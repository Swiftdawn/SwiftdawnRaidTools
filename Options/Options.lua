local SwiftdawnRaidTools = SwiftdawnRaidTools
local insert = table.insert

local SharedMedia = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")

do
    local Type = "ImportMultiLineEditBox"
    local Version = 1

    local function Constructor()
        local widget = AceGUI:Create("MultiLineEditBox")
        widget.button:Disable()

        -- Error label
        -- TODO: Improve this.
        -- This error label is floating beneth the windows.
        -- Only works if there's nothing below the input.
        local errorLabel = widget.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        errorLabel:SetPoint("TOPLEFT", widget.frame, "BOTTOMLEFT", 0, -2)
        errorLabel:SetPoint("TOPRIGHT", widget.frame, "BOTTOMRIGHT", 0, -2)
        errorLabel:SetHeight(20)
        errorLabel:SetJustifyH("LEFT")
        errorLabel:SetJustifyV("TOP")
        errorLabel:SetTextColor(1, 0, 0) -- Red
        errorLabel:SetText("")
        widget.errorLabel = errorLabel

        function widget:Validate()
            local text = self:GetText()

            if text then
                text = text:trim()
            end
            
            if not text or text == "" then
                return true
            end

            local ok, result = SRTImport:ParseYAML(text)
            if not ok then
                self.errorLabel:SetText(result)
                return false
            end

            self.errorLabel:SetText("")
            return true
        end

        -- Validate on text changed
        widget.editBox:HookScript("OnTextChanged", function(_, userInput)
            if userInput then
                if widget:Validate() then
                    widget.button:Enable()
                else
                    widget.button:Disable()
                end
            end
        end)

        return widget
    end

    AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local mainOptions = {
    name = "Swiftdawn Raid Tools " .. SwiftdawnRaidTools.VERSION,
    type = "group",
    args =  {
        buttonGroup = {
            type = "group",
            inline = true,
            name = "",
            order = 1,
            args = {
                toggleAnchors = {
                    type = "execute",
                    name = "Toggle Anchors",
                    desc = "Toggle Anchors Visibility.",
                    func = function()
                        SwiftdawnRaidTools.notification:ToggleFrameLock()
                    end,
                    order = 1,
                },
                toggleTestMode = {
                    type = "execute",
                    name = "Toggle Test Mode",
                    desc = "Toggle Test Mode on and off.",
                    func = function()
                        if not InCombatLockdown() then
                            SwiftdawnRaidTools:TestModeToggle()
                        end
                    end,
                    order = 2,
                },
                separator01 = {
                    type = "description",
                    name = " ",
                    width = "full",
                    order = 3,
                },
                resetAppearance = {
                    type = "execute",
                    name = "Reset Appearance",
                    desc = "Reset to default settings.",
                    func = function()
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize = 14
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize = 12
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize = 12
                        SwiftdawnRaidTools.db.profile.notifications.appearance.scale = 1.2
                        SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity = 0.9
                        SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize = 16
                        SwiftdawnRaidTools.db.profile.overview.appearance.scale = 1.0
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize = 10
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity = 0.8
                        SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity = 0.4
                        SwiftdawnRaidTools.db.profile.overview.appearance.iconSize = 14
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.scale = 1.0
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.headerFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.headerFontSize = 10
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontType = "Friz Quadrata TT"
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontSize = 10
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.titleBarOpacity = 0.8
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.backgroundOpacity = 0.4
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.iconSize = 14

                        SwiftdawnRaidTools.notification.container:ClearAllPoints()
                        SwiftdawnRaidTools.notification.container:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                        SwiftdawnRaidTools.notification:UpdateAppearance()
                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                    order = 4,
                },
                forceSync = {
                    type = "execute",
                    name = "Force Sync",
                    desc = "Synchronize raid assignments with Raid.",
                    func = function()
                        SyncController:SyncAssignmentsNow()
                    end,
                    order = 5,
                },
            },
        },
        separator00 = {
            type = "description",
            name = " ",
            width = "full",
            order = 2,
        },
        openAssignmentExplorer = {
            type = "execute",
            name = "Assignment Explorer",
            desc = "Open Assignment Explorer window.",
            func = function()
                SwiftdawnRaidTools.db.profile.assignmentexplorer.show = true
                SwiftdawnRaidTools.assignmentExplorer:Update()
            end,
            order = 3,
        },
        openRosterBuilder = {
            type = "execute",
            name = "Roster Builder",
            desc = "Open Roster Builder window.",
            func = function()
                SwiftdawnRaidTools.db.profile.rosterbuilder.show = true
                SwiftdawnRaidTools.rosterBuilder:Update()
            end,
            order = 4,
        },
        separator01 = {
            type = "description",
            name = " ",
            width = "full",
            order = 12,
        },
        showEnableWindowsDescription = {
            type = "description",
            name = "Enable or Disable Windows",
            width = "full",
            fontSize = "large",
            order = 13,
        },
        separator02 = {
            type = "description",
            name = " ",
            width = "full",
            order = 14,
        },
        showOverviewDescription = {
            type = "description",
            name = "Show Overview",
            width = "normal",
            order = 20,
        },
        showOverview = {
            name = " ",
            desc = "Enables / Disables Overview window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.overview.show = value
                SwiftdawnRaidTools.overview:Update()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.overview.show end,
            order = 21,
        },
        lockOverviewDescription = {
            type = "description",
            name = "Lock Overview",
            width = "normal",
            order = 22,
        },
        lockOverview = {
            name = " ",
            desc = "Lock / Unlocks Overview window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.overview.locked = value
                SwiftdawnRaidTools.overview:Update()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.overview.locked end,
            order = 23,
        },
        showDebugLogDescription = {
            type = "description",
            name = "Show Debug Log",
            width = "normal",
            order = 30,
        },
        showDebugLog = {
            name = " ",
            desc = "Enables / Disables Debug Log window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.debuglog.show = value
                SwiftdawnRaidTools.debugLog:Update()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.debuglog.show end,
            order = 31,
        },
        lockDebugLogDescription = {
            type = "description",
            name = "Lock Debug Log",
            width = "normal",
            order = 32,
        },
        lockDebugLog = {
            name = " ",
            desc = "Lock / Unlocks Debug Log window",
            type = "toggle",
            width = "half",
            set = function(info, value)
                SwiftdawnRaidTools.db.profile.debuglog.locked = value
                SwiftdawnRaidTools.debugLog:Update()
            end,
            get = function(info) return SwiftdawnRaidTools.db.profile.debuglog.locked end,
            order = 33,
        }
    },
}

local appearanceOptions = {
    name = "Appearance",
    type = "group",
    childGroups = "tab",
    args =  {
        overview = {
            type = "group",
            name = "Overview",
            order = 1, 
            args = {
                overviewScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 18,
                },
                overviewScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview UI Scale.",
                    width = "double",
                    order = 19,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.scale = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewTitleFontDescription = {
                    type = "description",
                    name = "Encounter Name",
                    width = "normal",
                    order = 21,
                },
                overviewTitleFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview title",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 22,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontType = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewTitleFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the overview title",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 23,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleFontSize = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewHeaderFontDescription = {
                    type = "description",
                    name = "Boss Ability",
                    width = "normal",
                    order = 31,
                },
                overviewHeaderFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview header",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 32,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontType = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewHeaderFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font sze used in the overview header",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 33,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.headerFontSize = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewPlayerFontDescription = {
                    type = "description",
                    name = "Player Names",
                    width = "normal",
                    order = 41,
                },
                overviewPlayerFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the overview player name",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 42,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontType = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewPlayerFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the overview player name",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 43,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.playerFontSize = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewIconSizeDescription = {
                    type = "description",
                    name = "Icon Size",
                    width = "normal",
                    order = 51,
                },
                overviewIconSize = {
                    type = "range",
                    min = 12,
                    max = 32,
                    step = 1,
                    name = "",
                    desc = "Set the ability icon size.",
                    width = "double",
                    order = 52,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.iconSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.iconSize = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewTitleBarOpacityDescription = {
                    type = "description",
                    name = "Title Bar Opacity",
                    width = "normal",
                    order = 53,
                },
                overviewTitleBarOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview Background Opacity.",
                    width = "double",
                    order = 54,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.titleBarOpacity = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                },
                overviewBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 55,
                },
                overviewBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Overview Background Opacity.",
                    width = "double",
                    order = 56,
                    get = function() return SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.overview.appearance.backgroundOpacity = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                    end,
                }
            }
        },
        notifications = {
            type = "group",
            name = "Notifications",
            order = 2,
            args = {
                notificationsPositionDescription = {
                    type = "description",
                    name = "Position",
                    width = "normal",
                    order = 10,
                },
                notificationsPositionInputX = {
                    type = "input",
                    name = "X",
                    desc = "Type in some text here",
                    get = function(info)
                        return string.format("%.1f", SwiftdawnRaidTools.db.profile.notifications.anchorX)
                    end,
                    set = function(info, value)
                        SwiftdawnRaidTools.db.profile.notifications.anchorX = tonumber(value)
                        SwiftdawnRaidTools.notification.container:SetPoint("CENTER", UIParent, "CENTER", SwiftdawnRaidTools.db.profile.notifications.anchorX / Utils:GetWeirdScale(), SwiftdawnRaidTools.db.profile.notifications.anchorY / Utils:GetWeirdScale())
                    end,
                    validate = function(info, value)
                        -- Check if the value is a valid floating-point number
                        return tonumber(value) ~= nil or "Please enter a valid number."
                    end,
                    order = 11,
                },
                notificationsPositionInputY = {
                    type = "input",
                    name = "Y",
                    desc = "Type in some text here",
                    get = function(info)
                        return string.format("%.1f", SwiftdawnRaidTools.db.profile.notifications.anchorY)
                    end,
                    set = function(info, value)
                        SwiftdawnRaidTools.db.profile.notifications.anchorY = tonumber(value)
                        SwiftdawnRaidTools.notificationFrame:SetPoint("CENTER", UIParent, "CENTER", SwiftdawnRaidTools.db.profile.notifications.anchorX / Utils:GetWeirdScale(), SwiftdawnRaidTools.db.profile.notifications.anchorY / Utils:GetWeirdScale())
                    end,
                    validate = function(info, value)
                        -- Check if the value is a valid floating-point number
                        return tonumber(value) ~= nil or "Please enter a valid number."
                    end,
                    order = 11,
                },
                notificationsScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 68,
                },
                notificationsScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Notifications UI Scale.",
                    width = "double",
                    order = 69,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.scale = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsHeaderFontDescription = {
                    type = "description",
                    name = "Boss Ability",
                    width = "normal",
                    order = 71,
                },
                notificationsHeaderFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification header",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 72,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontType = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsHeaderFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification header",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 73,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize end,
                    set = function(self, key)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.headerFontSize = key

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsPlayerFontDescription = {
                    type = "description",
                    name = "Player Names",
                    width = "normal",
                    order = 81,
                },
                notificationsPlayerFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification player names",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 82,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType end,
                    set = function(_, key)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontType = key

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsPlayerFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification player names",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 83,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.playerFontSize = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsCountdownFontDescription = {
                    type = "description",
                    name = "Countdown",
                    width = "normal",
                    order = 84,
                },
                notificationsCountdownFontType = {
                    type = "select",
                    name = "",
                    desc = "Sets the font used in notification countdown",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 85,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontType = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsCountdownFontSize = {
                    type = "range",
                    name = "",
                    desc = "Sets the font size used in notification countdown",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 86,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.countdownFontSize = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsIconSizeDescription = {
                    type = "description",
                    name = "Icon Size",
                    width = "normal",
                    order = 91,
                },
                notificationsIconSize = {
                    type = "range",
                    min = 12,
                    max = 32,
                    step = 1,
                    name = "",
                    desc = "Set the notification icon size",
                    width = "double",
                    order = 92,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.iconSize = value

                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
                notificationsBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 93,
                },
                notificationsBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Notifications Background Opacity.",
                    width = "double",
                    order = 94,
                    get = function() return SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.notifications.appearance.backgroundOpacity = value
                        SwiftdawnRaidTools.notification:UpdateAppearance()
                    end,
                },
            },
        },
        debugLog = {
            type = "group",
            name = "Debug Log",
            order = 3,
            args = {
                debugLogScaleDescription = {
                    type = "description",
                    name = "Scale",
                    width = "normal",
                    order = 10,
                },
                debugLogScale = {
                    type = "range",
                    min = 0.6,
                    max = 1.4,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log UI Scale.",
                    width = "double",
                    order = 11,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.scale end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.scale = value

                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogTitleFontDescription = {
                    type = "description",
                    name = "Title Bar",
                    width = "normal",
                    order = 20,
                },
                debugLogTitleFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the Debug Log title",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 21,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.titleFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.titleFontType = value

                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogTitleFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the Debug Log title",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 22,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.titleFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.titleFontSize = value

                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogLineFontDescription = {
                    type = "description",
                    name = "Log Lines",
                    width = "normal",
                    order = 30,
                },
                debugLogLineFontType = {
                    type = "select",
                    name = "",
                    desc = "Set the font used in the Debug Log lines",
                    values = SharedMedia:HashTable("font"),
                    dialogControl = "LSM30_Font",
                    width = "normal",
                    order = 142,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontType end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontType = value

                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogLineFontSize = {
                    type = "range",
                    name = "",
                    desc = "Set the font size used in the Debug Log lines",
                    min = 8,
                    max = 32,
                    step = 1,
                    width = "normal",
                    order = 143,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontSize end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.logFontSize = value

                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogTitleBarOpacityDescription = {
                    type = "description",
                    name = "Title Bar Opacity",
                    width = "normal",
                    order = 153,
                },
                debugLogTitleBarOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log title bar background opacity.",
                    width = "double",
                    order = 154,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.titleBarOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.titleBarOpacity = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
                debugLogBackgroundOpacityDescription = {
                    type = "description",
                    name = "Background Opacity",
                    width = "normal",
                    order = 155,
                },
                debugLogBackgroundOpacity = {
                    type = "range",
                    min = 0,
                    max = 1,
                    isPercent = true,
                    name = "",
                    desc = "Set the Debug Log background opacity.",
                    width = "double",
                    order = 156,
                    get = function() return SwiftdawnRaidTools.db.profile.debuglog.appearance.backgroundOpacity end,
                    set = function(_, value)
                        SwiftdawnRaidTools.db.profile.debuglog.appearance.backgroundOpacity = value

                        SwiftdawnRaidTools.overview:UpdateAppearance()
                        SwiftdawnRaidTools.debugLog:UpdateAppearance()
                    end,
                },
            },
        },
    },
}

local notificationOptions = {
    name = "Notifications",
    type = "group",
    args =  {
        showOnlyOwnNotificationsCheckbox = {
            type = "toggle",
            name = "Limit Notifications",
            desc = "Only show Raid Notifications that apply to You.",
            width = "full",
            order = 1,
            get = function() return SwiftdawnRaidTools.db.profile.notifications.showOnlyOwnNotifications end,
            set = function(_, value) SwiftdawnRaidTools.db.profile.notifications.showOnlyOwnNotifications = value end,
        },
        showOnlyOwnNotificationsDescription = {
            type = "description",
            name = "Only show Raid Notifications that apply to you.",
            order = 2,
        },
        separator = {
            type = "description",
            name = " ",
            order = 3,
        },
        muteCheckbox = {
            type = "toggle",
            name = "Mute Sounds",
            desc = "Mute all Raid Notification Sounds.",
            width = "full",
            order = 4,
            get = function() return SwiftdawnRaidTools.db.profile.notifications.mute end,
            set = function(_, value)SwiftdawnRaidTools.db.profile.notifications.mute = value end,
        },
        muteDescription = {
            type = "description",
            name = "Mute all Raid Notification Sounds.",
            order = 5,
        },
    },
}

local fojjiIntegrationOptions = {
    name = "Fojji Integration (Experimental)",
    type = "group",
    args = {
        weakAuraText = {
            type = "description",
            name = "Fojji Integration require the use of a Helper WeakAura. This WeakAura is only required if you are the Raid Leader and configure assignments that are activated by Fojji timers.",
            order = 1,
        },
        separator = {
            type = "description",
            name = " ",
            order = 2,
        },
        weakAurasNotInstalledError = {
            type = "description",
            fontSize = "medium",
            name = "|cffff0000WeakAuras is not installed.|r",
            order = 3,
            hidden = function() return SwiftdawnRaidTools:WeakAurasIsInstalled() end
        },
        helperWeakAuraInstalledMessage = {
            type = "description",
            fontSize = "medium",
            name = "|cff00ff00Swiftdawn Raid Tools Helper WeakAura Installed.|r",
            order = 4,
            hidden = function() return not SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
        installWeakAuraButton = {
            type = "execute",
            name = "Install WeakAura",
            desc = "Install the Swiftdawn Raid Tools Helper WeakAura.",
            func = function() SwiftdawnRaidTools:WeakAurasInstallHelper(function()
                LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Fojji Integration")
            end) end,
            order = 5,
            hidden = function() return not SwiftdawnRaidTools:WeakAurasIsInstalled() or SwiftdawnRaidTools:WeakaurasIsHelperInstalled() end
        },
    },
}

local importDescription = [[
Paste your raid assignments and other import data below. The import should be valid YAML.

For the full Import API spec, visit https://github.com/gonstr/SwiftdawnRaidTools.
]]

local importOptions = {
    name = "Import",
    type = "group",
    args = {
        description = {
            type = "description",
            name = importDescription,
            fontSize = "medium",
            order = 1,
        },
        import = {
            type = "input",
            name = "Import",
            desc = "Paste your import data here.",
            multiline = 25,
            width = "full",
            dialogControl = "ImportMultiLineEditBox",
            order = 2,
            get = function() return SwiftdawnRaidTools.db.profile.options.import end,
            set = function(_, val)
                if val then
                    val = val:trim()
                end

                SwiftdawnRaidTools:TestModeEnd()

                SwiftdawnRaidTools.db.profile.options.import = val

                SRTData.SetActiveRosterID("none")

                if val ~= nil and val ~= "" then
                    local _, result = SRTImport:ParseYAML(val)
                    local encounters, encountersId = SRTImport:AddIDs(result)
                    SRTData.SetActiveRosterID(encountersId or "none")
                    SRTData.AddRoster(encountersId, Roster.Parse(encounters, "Imported Roster"))
                end

                SyncController:ScheduleAssignmentsSync()
                SwiftdawnRaidTools.overview:Update()
            end,
        },
    },
}

local troubleshootOptions = {
    name = "Troubleshooting Options",
    type = "group",
    args = {
        activeRosterIDInputDescription = {
            type = "description",
            name = "Active Roster ID",
            width = "normal",
            order = 1
        },
        activeRosterIDInput = {
            type = "input",
            name = "Active Roster ID Input",
            width = "double",
            get = function(_)
                return SRTData.GetActiveRosterID()
            end,
            set = function(_, value)
                SRTData.SetActiveRosterID(value)
                SwiftdawnRaidTools.overview:Update()
            end,
            order = 2
        },
        activeRosterIDSelectDescription = {
            type = "description",
            name = "Active Roster ID",
            width = "normal",
            order = 11
        },
        activeRosterIDSelect = {
            type = "select",
            name = "Active Roster ID Select",
            width = "double",
            values = function ()
                local v = {}
                for id, _ in pairs(SRTData.GetRosters()) do
                    v[id] = id
                end
                return v
            end,
            get = function() return tostring(SRTData.GetActiveRosterID()) end,
            set = function(_, key)
                SRTData.SetActiveRosterID(key)
                SwiftdawnRaidTools.overview:Update()
            end,
            order = 12
        },
    }
}

function SwiftdawnRaidTools:OptionsInit()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools", mainOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Appearance", appearanceOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Appearance", "Appearance", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Notifications", notificationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Notifications", "Notifications", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Fojji Integration", fojjiIntegrationOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Fojji Integration", "Fojji Integration", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Import", importOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Import", "Import", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Troubleshooting", troubleshootOptions)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Troubleshooting", "Troubleshooting", "Swiftdawn Raid Tools")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SwiftdawnRaidTools Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SwiftdawnRaidTools Profiles", "Profiles", "Swiftdawn Raid Tools")
end

function SwiftdawnRaidTools:ToggleFrameLock(lock) end

function SwiftdawnRaidTools:OnConfigChanged()
    SwiftdawnRaidTools:UpdatePartyFramesVisibility(self.db.profile.hideBlizPartyFrame)
    SwiftdawnRaidTools:UpdateArenaFramesVisibility(self.db.profile.hideBlizArenaFrame)
    SwiftdawnRaidTools:UpdateAuraDurationsVisibility()
end

SwiftdawnRaidTools:RegisterChatCommand("art", function()
    LibStub("AceConfigDialog-3.0"):Open("SwiftdawnRaidTools")
end)
