local SharedMedia = LibStub("LibSharedMedia-3.0")

---@class LogItem
LogItem = {
    showExtra = false
}
LogItem.__index = LogItem

---@return LogItem
function LogItem:New(data, ...)
    ---@class LogItem
    local obj = {}
    setmetatable(obj, LogItem)
    obj.time = Utils:Timestamp(true) .. ": "
    if type(data) == "string" then
        obj.triggerType = "STRING"
        obj.line = data
        obj.extra = ...
    else
        obj.triggerType = data.triggerType
        obj.assignmentId = data.uuid
        obj.activeGroups = data.activeGroups
        obj.countdown = data.countdown
        obj.delay = data.delay
        obj.context = data.context
        obj.line = nil
        obj.extra = nil
    end
    return obj
end

function LogItem:NewData(data, ...)
    if type(data) == "string" then
        self.triggerType = "STRING"
        self.line = data
        self.extra = ...
    else
        self.triggerType = data.triggerType
        self.assignmentId = data.uuid
        self.activeGroups = data.activeGroups
        self.countdown = data.countdown
        self.delay = data.delay
        self.context = data.context
        self.line = nil
        self.extra = nil
    end
end

function LogItem:GetString()
    local line
    if self.triggerType == "STRING" then
        return string.format("%s %s", self.line, Utils:StringJoin(self.extra))
    elseif self.triggerType == "ENCOUNTER_START" then
        line = "Encounter with " .. self.context.encounterName .. " has started"
        return line
    elseif self.triggerType == "SPELL_CAST" then
        line = self.context.source_name .. " is casting " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.triggerType == "SPELL_AURA" then
        line = self.context.source_name .. " has applied aura " .. self.context.spell_name
        if self.context.dest_name ~= nil then
            line = line  .. " on " .. self.context.dest_name
        end
        return line
    elseif self.triggerType == "RAID_BOSS_EMOTE" then
        return "Boss emotes '" .. self.context.text .. "'"
    else
        return self.triggerType
    end
end

function LogItem:GetExtraString()
    if self.triggerType == "STRING" and not self.extra then
        return ""
    elseif self.triggerType == "STRING" and self.extra then
        return Utils:TableToString(self.extra)
    end
    return string.format(
            "type: %s\nassignment: %s\nactiveGroups: %s\ncountdown: %d\ndelay: %d\ncontext: %s",
            tostring(self.triggerType), tostring(self.assignmentId), Utils:TableToString(self.activeGroups), tostring(self.countdown), tostring(self.delay), Utils:TableToString(self.context))
end

function LogItem:getLogFontType()
    return SharedMedia:Fetch("font", SRT_Profile().debuglog.appearance.logFontType)
end

function LogItem:CreateString(parentFrame, previousItem)
    self.text = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.text:SetShadowOffset(1, -1)
    self.text:SetShadowColor(0, 0, 0, 1)
    self.text:SetJustifyH("LEFT")
    self.text:SetWordWrap(false)
    self.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b)
    self.text:SetFont(self:getLogFontType(), SRT_Profile().debuglog.appearance.logFontSize)
    self.text:SetWidth(parentFrame:GetWidth() - 10)
    if previousItem then
        self.text:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -3)
    else
        self.text:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -3)
    end
    self:UpdateAppearance()
end

function LogItem:CreateFrame(parentFrame)
    -- self.frame = CreateFrame("Frame", "LogLine", parentFrame)
    -- self.frame:SetClipsChildren(true)
    -- self.timestamp = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- self.timestamp:SetShadowOffset(1, -1)
    -- self.timestamp:SetShadowColor(0, 0, 0, 1)
    -- self.timestamp:SetJustifyH("LEFT")
    -- self.timestamp:SetWordWrap(false)
    -- self.timestamp:SetTextColor(1, 1, 1)
    -- self.timestamp:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, 0)
    -- self.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- self.text:SetShadowOffset(1, -1)
    -- self.text:SetShadowColor(0, 0, 0, 1)
    -- self.text:SetJustifyH("LEFT")
    -- self.text:SetWordWrap(false)
    -- self.text:SetPoint("LEFT", self.timestamp, "RIGHT", 0, 0)
    -- self.extraText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- self.extraText:SetShadowOffset(1, -1)
    -- self.extraText:SetShadowColor(0, 0, 0, 1)
    -- self.extraText:SetJustifyH("LEFT")
    -- self.extraText:SetWordWrap(true)
    -- self.extraText:SetTextColor(1, 0.80, 1)
    -- self.extraText:SetPoint("TOPLEFT", self.timestamp, "BOTTOMLEFT", 5, -3)
    -- self.extraText:Hide()
    -- self.frame:SetScript("OnMouseDown", function(_, button)
    --     if button == "LeftButton" and (not self.line or self.extra) then
    --         self.showExtra = not self.showExtra
    --         self:UpdateAppearance()
    --     end
    -- end)
    -- self:UpdateAppearance()
end

function LogItem:UpdateAppearance()
    self.text:SetText(self.time .. self:GetString())
    -- local logFontSize = SRT_Profile().debuglog.appearance.logFontSize
    -- self.frame:SetWidth(self.frame:GetParent():GetWidth() - 10)
    -- self.timestamp:SetFont(self:getLogFontType(), logFontSize)
    -- self.timestamp:SetWidth(self.timestamp:GetStringWidth())
    -- self.timestamp:SetText(Utils:Timestamp(true) .. ": ")
    if self.triggerType == "STRING" and not self.extra then
        self.text:SetTextColor(0.80, 0.80, 0.80)
    elseif self.triggerType == "STRING" and self.extra then
        self.text:SetTextColor(1, 1, 1)
    else
        self.text:SetTextColor(SRTColor.GameYellow.r, SRTColor.GameYellow.g, SRTColor.GameYellow.b)
    end
    -- self.text:SetFont(self:getLogFontType(), logFontSize)
    -- self.text:SetWidth(self.frame:GetWidth() - self.timestamp:GetStringWidth() - 2)
    -- self.text:SetText(self:GetString())
    -- self.extraText:SetFont(self:getLogFontType(), logFontSize)
    -- self.extraText:SetWidth(self.frame:GetWidth() - 5)
    -- self.extraText:SetHeight(self.extraText:GetStringHeight())
    -- self.extraText:SetText(self:GetExtraString())
    -- if self.showExtra then
    --     self.extraText:Show()
    --     self.frame:SetHeight(logFontSize + 3 + self.extraText:GetHeight())
    -- else
    --     self.extraText:Hide()
    --     self.frame:SetHeight(logFontSize + 3)
    -- end
end

function LogItem:DeleteFrame()
    -- self.frame:Hide()
    -- self.frame:ClearAllPoints()
    -- self.frame:SetScript("OnMouseDown", nil)
    -- self.frame = nil
    -- self.timestamp:Hide()
    -- self.timestamp:ClearAllPoints()
    -- self.timestamp = nil
    self.text:Hide()
    self.text:ClearAllPoints()
    self.text = nil
    -- self.extraText:Hide()
    -- self.extraText:ClearAllPoints()
    -- self.extraText = nil
end

return LogItem