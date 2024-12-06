local SwiftdawnRaidTools = SwiftdawnRaidTools
local SharedMedia = LibStub("LibSharedMedia-3.0")
MIN_WIDTH = 100
MIN_HEIGHT = 100

--- Base window class object for SRT 
---@class SRTWindow
SRTWindow = {}
SRTWindow.__index = SRTWindow

---@return SRTWindow 
function SRTWindow:New(name, height, width, minHeight, maxHeight, minWidth, maxWidth)
    ---@class SRTWindow
    local obj = setmetatable({}, self)
    self.__index = self
    obj.name = name
    obj.height = height
    obj.width = width
    obj.minHeight = minHeight
    obj.maxHeight = maxHeight
    obj.minWidth = minWidth
    obj.maxWidth = maxWidth
    obj.container = CreateFrame("Frame", "SRT_"..name, UIParent, "BackdropTemplate")
    obj.header = CreateFrame("Frame", "SRT_"..name.."_Header", obj.container, "BackdropTemplate")
    obj.headerText = obj.header:CreateFontString("SRT_"..name.."_HeaderTitle", "OVERLAY", "GameFontNormalLarge")
    obj.menuButton = CreateFrame("Button", "SRT_"..name.."_MenuButton", obj.header)
    obj.popupMenu = FrameBuilder.CreatePopupMenu(obj.menuButton)
    obj.main = CreateFrame("Frame", "SRT_"..name.."_Main", obj.container)
    obj.resizeButton = CreateFrame("Button", "SRT_"..name.."_ResizeButton", obj.container)
    obj.popupListItems = {}
    return obj
end

function SRTWindow:GetProfile()
    return SRT_Profile()[string.lower(self.name)]
end

function SRTWindow:GetAppearance()
    return self:GetProfile().appearance
end

function SRTWindow:GetTitleFont()
    return SharedMedia:Fetch("font", self:GetAppearance().titleFontType)
end

function SRTWindow:GetHeaderFont()
    return SharedMedia:Fetch("font", self:GetAppearance().headerFontType)
end

function SRTWindow:Initialize()
    self:SetupContainerFrame()
    self:SetupPopupMenu()
    self:SetupHeader()
    self:SetupResizeButton()
    self:SetupMain()
end

function SRTWindow:SetupContainerFrame()
    self.container:SetSize(self.width, self.height)
    self.container:SetFrameStrata("MEDIUM")
    self.container:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 32,
    })
    self.container:SetBackdropColor(0, 0, 0, self:GetAppearance().backgroundOpacity)
    self.container:SetMovable(true)
    self.container:EnableMouse(true)
    self.container:SetUserPlaced(true)
    self.container:SetClampedToScreen(true)
    self.container:RegisterForDrag("LeftButton")
    self.container:SetScript("OnDragStart", function(_)
        self.container:StartMoving()
        -- self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
        --     self:GetProfile().anchorX = tonumber(string.format("%.2f", self.container:GetLeft()))
        --     self:GetProfile().anchorY = tonumber(string.format("%.2f", self.container:GetTop() - GetScreenHeight()))
        --     LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
        -- end)
    end)
    self.container:SetScript("OnDragStop", function(_)
        self.container:StopMovingOrSizing()
        -- self.container:SetScript("OnUpdate", nil)
    end)
    self.container:SetScale(self:GetAppearance().scale)
    self.container:SetClipsChildren(true)
    self.container:SetResizable(true)
    self.container:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self:GetProfile().anchorX, self:GetProfile().anchorY)
    self.container:SetScript("OnMouseDown", function (_, button)
        if button == "LeftButton" or button == "RightButton" then
            self.popupMenu:Hide()
        end
    end)
end

function SRTWindow:SetupPopupMenu()
    self.popupMenu:SetPoint("TOPLEFT", self.menuButton, "TOPLEFT", 0, 0)
    self.popupMenu:Hide() -- Start hidden
end

function SRTWindow:GetTitleFontType()
    return SharedMedia:Fetch("font", self:GetAppearance().titleFontType)
end

function SRTWindow:SetupHeader()
    local titleFontSize = self:GetAppearance().titleFontSize
    self.header:SetPoint("TOPLEFT", 0, 0)
    self.header:SetPoint("TOPRIGHT", 0, 0)
    self.header:RegisterForDrag("LeftButton")
    self.header:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 16,
    })
    self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
    self.header:SetScript("OnDragStart", function(_)
        self.container:StartMoving()
        -- self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
        --     self:GetProfile().anchorX = tonumber(string.format("%.2f", self.container:GetLeft()))
        --     self:GetProfile().anchorY = tonumber(string.format("%.2f", self.container:GetTop() - GetScreenHeight()))
        --     LibStub("AceConfigRegistry-3.0"):NotifyChange("SwiftdawnRaidTools Appearance")
        -- end)
    end)
    self.header:SetScript("OnDragStop", function(_)
        self.container:StopMovingOrSizing()
        -- self.container:SetScript("OnUpdate", nil)
    end)

    self.header:SetScript("OnEnter", function()
        self.header:SetBackdropColor(0, 0, 0, 1)
        self.menuButton:SetAlpha(1)
    end)
    self.header:SetScript("OnLeave", function()
        self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
        self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    end)
    self.headerText:SetFont(self:GetTitleFontType(), titleFontSize)
    self.headerText:SetPoint("LEFT", self.header, "LEFT", 10, 0)
    self.headerText:SetShadowOffset(1, -1)
    self.headerText:SetShadowColor(0, 0, 0, 1)
    self.headerText:SetJustifyH("LEFT")
    self.headerText:SetWordWrap(false)
    self.menuButton:SetSize(titleFontSize, titleFontSize)
    self.menuButton:SetPoint("RIGHT", self.header, "RIGHT", -3, 0)
    self.menuButton:SetNormalTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetHighlightTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetPushedTexture("Gamepad_Ltr_Menu_32")
    self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    self.menuButton:SetScript("OnEnter", function()
        self.header:SetBackdropColor(0, 0, 0, 1)
        self.menuButton:SetAlpha(1)
    end)
    self.menuButton:SetScript("OnLeave", function()
        self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
        self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    end)
    self.menuButton:RegisterForClicks("AnyDown", "AnyUp")
end

function SRTWindow:SetupResizeButton()
    self.resizeButton:SetSize(12, 12)
    self.resizeButton:SetPoint("BOTTOMRIGHT")
    local resizeTexture = self.resizeButton:CreateTexture(nil, "BACKGROUND")
    resizeTexture:SetAllPoints(self.resizeButton)
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") -- Use a default WoW texture for resize
    self.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self.resizeButton:SetAlpha(0)
    self.resizeButton:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self.container:StartSizing("BOTTOMRIGHT")  -- Start resizing from bottom-right corner
            self.container:SetScript("OnUpdate", function()  -- Continuously update the frame size
                self:UpdateAppearance()
            end)
        end
    end)
    self.resizeButton:SetScript("OnEnter", function()
        self.resizeButton:SetAlpha(1)
    end)
    self.resizeButton:SetScript("OnLeave", function()
        self.resizeButton:SetAlpha(0)
    end)
    self.resizeButton:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            self.container:StopMovingOrSizing()  -- Stop the resizing action
            self.container:SetScript("OnUpdate", nil)  -- Stop updating frame size
        end
    end)
    self.container:SetScript("OnSizeChanged", function(_, width, height)
        if width < MIN_WIDTH then width = MIN_WIDTH end
        if height < MIN_HEIGHT then height = MIN_HEIGHT end
        if self.minWidth and width < self.minWidth then width = self.minWidth end
        if self.minHeight and height < self.minHeight then height = self.minHeight end
        if self.maxWidth and width > self.maxWidth then width = self.maxWidth end
        if self.maxHeight and height > self.maxHeight then height = self.maxHeight end
        self.container:SetSize(width, height)
    end)
end

function SRTWindow:SetupMain()
    self.main:SetPoint("BOTTOMLEFT", 0, 0)
    self.main:SetPoint("BOTTOMRIGHT", 0, 0)
end

function SRTWindow:UpdateAppearance()
    local titleFontSize = self:GetAppearance().titleFontSize
    self.container:SetScale(self:GetAppearance().scale)
    self.headerText:SetFont(self:GetTitleFont(), titleFontSize)
    local headerHeight = titleFontSize + 8
    self.header:SetHeight(headerHeight)
    local headerWidth = self.header:GetWidth()
    self.headerText:SetWidth(headerWidth - 10 - titleFontSize)
    self.main:SetPoint("TOPLEFT", 0, -headerHeight)
    self.main:SetPoint("TOPRIGHT", 0, -headerHeight)
    self.menuButton:SetSize(titleFontSize, titleFontSize)
    self.menuButton:SetAlpha(self:GetAppearance().titleBarOpacity)
    self.header:SetBackdropColor(0, 0, 0, self:GetAppearance().titleBarOpacity)
    local r, g, b = self.container:GetBackdropColor()
    self.container:SetBackdropColor(r, g, b, self:GetAppearance().backgroundOpacity)
end

function SRTWindow:CloseWindow()
    self:GetProfile().show = false
    self:Update()
end

function SRTWindow:ToggleLock()
    self:GetProfile().locked = not self:GetProfile().locked
    self:UpdateLocked()
end

function SRTWindow:UpdateLocked()
    if self:GetProfile().locked then
        self.container:EnableMouse(false)
        self.header:EnableMouse(false)
        self.resizeButton:EnableMouse(false)
        self.resizeButton:Hide()
    else
        self.container:EnableMouse(true)
        self.header:EnableMouse(true)
        self.resizeButton:EnableMouse(true)
        self.resizeButton:Show()
    end
end

function SRTWindow:Update()
    if not self:GetProfile().show then
        self.container:Hide()
        return
    end
    self:UpdateLocked()
    self.container:Show()
end

return SRTWindow