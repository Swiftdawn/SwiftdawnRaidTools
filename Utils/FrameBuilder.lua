local SharedMedia = LibStub("LibSharedMedia-3.0")

FrameBuilder = {}
FrameBuilder.__index = FrameBuilder

---@return table|BackdropTemplate|Frame
---@param parentFrame Frame
---@param playerName string
---@param classFileName string
---@param width integer
---@param height integer
---@param font FontFile
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.CreatePlayerFrame(parentFrame, playerName, classFileName, width, height, font, fontSize, iconSize, showSpells)
    local playerFrame = CreateFrame("Frame", parentFrame:GetName() .. "_" .. playerName, parentFrame, "BackdropTemplate")
    playerFrame:EnableMouse(true)
    playerFrame:SetSize(width, height)
    playerFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    playerFrame:SetBackdropColor(0, 0, 0, 0)

    playerFrame.name = playerFrame.name or playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerFrame.name:EnableMouse(false)
    playerFrame.name:SetPoint("LEFT", playerFrame, "LEFT", 5, 0)
    playerFrame.name:SetFont(font, fontSize)
    playerFrame.name:SetText(strsplit("-", playerName))

    playerFrame.spells = playerFrame.spells or {}
    local color
    local previousIconFrame = nil
    if showSpells then
        for _, spell in pairs(SRTData.GetClass(classFileName).spells) do
            local spellIcon, _ = C_Spell.GetSpellTexture(spell.id)
            local iconFrame = playerFrame.spells[spell.id] or CreateFrame("Frame", nil, playerFrame)
            iconFrame:EnableMouse(false)
            iconFrame:SetSize(iconSize, iconSize)
            if previousIconFrame then
                iconFrame:SetPoint("LEFT", previousIconFrame, "RIGHT", 7, 0)
            else
                iconFrame:SetPoint("LEFT", playerFrame.name, "RIGHT", 7, 0)
            end
            iconFrame.icon = iconFrame.icon or iconFrame:CreateTexture(nil, "ARTWORK")
            iconFrame.icon:SetAllPoints()
            iconFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            iconFrame.icon:SetTexture(spellIcon)
            previousIconFrame = iconFrame
            playerFrame.spells[spell.id] = iconFrame
        end
    end
    color = RAID_CLASS_COLORS[classFileName] or { r = 1, g = 1, b = 1 }
    playerFrame.name:SetTextColor(color.r, color.g, color.b)

    playerFrame:SetScript("OnEnter", function () playerFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    playerFrame:SetScript("OnLeave", function () playerFrame:SetBackdropColor(0, 0, 0, 0) end)
    return playerFrame
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateTextFrame(parentFrame, text, width, height, font, fontSize)
    local frame = CreateFrame("Frame", parentFrame:GetName() .. "_" .. text:gsub(" ", "_"), parentFrame, "BackdropTemplate")
    frame:EnableMouse(true)
    frame:SetSize(width, height)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = height,
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame.text = frame.text or frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.text:EnableMouse(false)
    frame.text:SetPoint("LEFT", frame, "LEFT", 5, 0)
    frame.text:SetFont(font, fontSize)
    frame.text:SetText(text)
    frame.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    frame.text:SetJustifyH("LEFT")
    frame.text:SetWordWrap(true)
    frame.text:SetSpacing(3)
    frame.text:SetIndentedWordWrap(true)
    frame.text:SetWidth(width - 6)
    frame:SetScript("OnEnter", function () frame:SetBackdropColor(1, 1, 1, 0.4) end)
    frame:SetScript("OnLeave", function () frame:SetBackdropColor(0, 0, 0, 0) end)
    frame.Update = function ()
        FrameBuilder.UpdateTextFrame(frame)
    end
    frame.Update()
    return frame
end

function FrameBuilder.UpdateTextFrame(frame)
    frame:SetHeight(frame.text:GetHeight() + 8)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = frame:GetHeight(),
    })
    frame:SetBackdropColor(0, 0, 0, 0)
end

function FrameBuilder.CreateTriggerFrame(parentFrame, triggerID, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = CreateFrame("Frame", "TriggerFrame", parentFrame, "BackdropTemplate")
    if trigger.name == "SPELL_CAST" then
        frame.triggerFrame = FrameBuilder.CreateSpellCastTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "SPELL_AURA" then
        frame.triggerFrame = FrameBuilder.CreateSpellCastTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "SPELL_AURA_REMOVED" then
        frame.triggerFrame = FrameBuilder.CreateSpellCastTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "RAID_BOSS_EMOTE" then
        frame.triggerFrame = FrameBuilder.CreateEmoteTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "UNIT_HEALTH" then
        frame.triggerFrame = FrameBuilder.CreateUnitHealthTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "ENCOUNTER_START" then
        frame.triggerFrame = FrameBuilder.CreateTimeTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    elseif trigger.name == "FOJJI_NUMEN_TIMER" then
        frame.triggerFrame = FrameBuilder.CreateNumenTimerTriggerFrame(frame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    end
    frame.id = triggerID
    frame.triggerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.type = type
    frame.items = {}
    frame.AddCondition = function (cid, condition, onConditionChanges, onConditionRemove)
        trigger.conditions[cid] = condition
        local conditionFrame
        if condition.name == "SPELL_CAST_COUNT" then
            conditionFrame = frame.items[cid] or FrameBuilder.CreateCastCountConditionFrame(frame, condition, width - 10, height, font, fontSize, onConditionChanges, onConditionRemove)
        elseif condition.name == "UNIT_HEALTH" then
            conditionFrame = frame.items[cid] or FrameBuilder.CreateUnitHealthConditionFrame(frame, condition, width - 10, height, font, fontSize, onConditionChanges, onConditionRemove)
        elseif condition.name == "AURA_REMOVED_COUNT" then
            conditionFrame = frame.items[cid] or FrameBuilder.CreateAuraRemovedCountConditionsFrame(frame, condition, width - 10, height, font, fontSize, onConditionChanges, onConditionRemove)
        end
        if #frame.items == 0 then
            conditionFrame:SetPoint("TOPLEFT", frame.triggerFrame, "BOTTOMLEFT", 10, 0)
        else
            conditionFrame:SetPoint("TOPLEFT", frame.items[#frame.items], "BOTTOMLEFT", 0, 0)
        end
        table.insert(frame.items, conditionFrame)
        frame:Update()
    end
    frame.RemoveCondition = function (cid)
        if frame.items[cid] then
            frame.items[cid]:Hide()
            table.remove(frame.items, cid)
        end
        frame:Update()
    end
    frame.RemoveAllConditions = function ()
        for cid, item in pairs(frame.items) do
            item:Hide()
            table.remove(frame.items, cid)
            item = nil
        end
        frame.items = {}
        frame:Update()
    end
    frame.GetCurrentHeight = function ()
        local h = frame.triggerFrame:GetHeight()
        for _, item in pairs(frame.items) do
            h = h + item:GetHeight()
        end
        return h
    end
    frame.Update = function ()
        frame:SetHeight(frame.GetCurrentHeight())
        frame:SetBackdrop({
            bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
            tile = true,
            tileSize = (frame.hiddenFrames and not frame.hiddenFrames:IsShown()) and frame.GetCurrentHeight() or frame:GetHeight(),
        })
        frame:SetBackdropColor(0, 0, 0, 0)
    end
    frame.GetNextConditionID = function ()
        return #frame.items + 1
    end
    frame:SetWidth(width)
    frame.Update()
    return frame
end

local function AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
    frame.hiddenFrames.countdownTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.countdownTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.countdownTitle:SetText("Countdown:")
    frame.hiddenFrames.countdownTitle:SetWidth(frame.hiddenFrames.countdownTitle:GetStringWidth())
    frame.hiddenFrames.countdownEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.countdownEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.countdownEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.countdownEditBox:SetNumericFullRange(true)
    frame.hiddenFrames.countdownEditBox:SetPoint("LEFT", frame.hiddenFrames.countdownTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.countdownEditBox:SetAutoFocus(false)
end

local function AddHiddenDelayEditbox(frame, font, fontSize, width, height)
    frame.hiddenFrames.delayTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.delayTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.delayTitle:SetText("Delay:")
    frame.hiddenFrames.delayTitle:SetWidth(frame.hiddenFrames.delayTitle:GetStringWidth())
    frame.hiddenFrames.delayEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.delayEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.delayEditBox:SetNumericFullRange(true)
    frame.hiddenFrames.delayEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.delayEditBox:SetPoint("LEFT", frame.hiddenFrames.delayTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.delayEditBox:SetAutoFocus(false)
end

local function AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
    frame.hiddenFrames.throttleTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.throttleTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.throttleTitle:SetText("Throttle:")
    frame.hiddenFrames.throttleTitle:SetWidth(frame.hiddenFrames.throttleTitle:GetStringWidth())
    frame.hiddenFrames.throttleEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.throttleEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.throttleEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.throttleEditBox:SetNumeric(true)
    frame.hiddenFrames.throttleEditBox:SetPoint("LEFT", frame.hiddenFrames.throttleTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.throttleEditBox:SetAutoFocus(false)
end

function FrameBuilder.CreateEmoteTriggerFrame(parentFrame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.trigger = trigger
    frame.type = type
    frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    frame.hiddenFrames.emoteTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.emoteTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.emoteTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.emoteTitle:SetText("Emote:")
    frame.hiddenFrames.emoteTitle:SetWidth(frame.hiddenFrames.emoteTitle:GetStringWidth())
    frame.hiddenFrames.emoteEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.emoteEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.emoteEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.emoteEditBox:SetPoint("TOPLEFT", frame.hiddenFrames.emoteTitle, "BOTTOMLEFT", 5, 0)
    frame.hiddenFrames.emoteEditBox:SetAutoFocus(false)
    if type == "trigger" then
        AddHiddenDelayEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.delayTitle:SetPoint("TOPLEFT", frame.hiddenFrames.emoteEditBox, "BOTTOMLEFT", -5, -2)
        AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.throttleTitle:SetPoint("TOPLEFT", frame.hiddenFrames.delayTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.countdownTitle:SetPoint("TOPLEFT", frame.hiddenFrames.throttleTitle, "BOTTOMLEFT", 0, -5)
    end
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.trigger.emoteText = frame.hiddenFrames.emoteEditBox:GetText() or ""
        if type == "trigger" then
            frame.trigger.countdown = tonumber(frame.hiddenFrames.countdownEditBox:GetText()) or 0
            frame.trigger.delay = tonumber(frame.hiddenFrames.delayEditBox:GetText()) or 0
            frame.trigger.throttle = tonumber(frame.hiddenFrames.throttleEditBox:GetText()) or 0
        end
        frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
        onChanges(frame.trigger)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.emoteEditBox:SetText(frame.trigger.emoteText or "")
            if type == "trigger" then
                frame.hiddenFrames.delayEditBox:SetText(tostring(frame.trigger.delay) or "0")
                frame.hiddenFrames.throttleEditBox:SetText(tostring(frame.trigger.throttle) or "0")
                frame.hiddenFrames.countdownEditBox:SetText(tostring(frame.trigger.countdown) or "0")
            end
            frame.hiddenFrames:Show()
            frame:SetSize(width, type == "trigger" and 80 or 35) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, type == "trigger" and 80 or 35)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.emoteEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.emoteEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.emoteEditBox:SetScript("OnEnterPressed", acceptChanges)
    if type == "trigger" then
        frame.hiddenFrames.throttleEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEnterPressed", acceptChanges)
    end
    frame:Update()
    return frame
end

function FrameBuilder.CreateNumenTimerTriggerFrame(parentFrame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.trigger = trigger
    frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    frame.hiddenFrames.numenKeyTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.numenKeyTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.numenKeyTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.numenKeyTitle:SetText("Numen Key:")
    frame.hiddenFrames.numenKeyTitle:SetWidth(frame.hiddenFrames.numenKeyTitle:GetStringWidth())
    frame.hiddenFrames.numenKeyEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.numenKeyEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.numenKeyEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.numenKeyEditBox:SetPoint("TOPLEFT", frame.hiddenFrames.numenKeyTitle, "BOTTOMLEFT", 5, 0)
    frame.hiddenFrames.numenKeyEditBox:SetAutoFocus(false)
    if type == "trigger" then
        AddHiddenDelayEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.delayTitle:SetPoint("TOPLEFT", frame.hiddenFrames.numenKeyEditBox, "BOTTOMLEFT", -5, -2)
        AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.throttleTitle:SetPoint("TOPLEFT", frame.hiddenFrames.delayTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.countdownTitle:SetPoint("TOPLEFT", frame.hiddenFrames.throttleTitle, "BOTTOMLEFT", 0, -5)
    end
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.trigger.key = frame.hiddenFrames.numenKeyEditBox:GetText() or ""
        if type == "trigger" then
            frame.trigger.countdown = tonumber(frame.hiddenFrames.countdownEditBox:GetText()) or 0
            frame.trigger.delay = tonumber(frame.hiddenFrames.delayEditBox:GetText()) or 0
            frame.trigger.throttle = tonumber(frame.hiddenFrames.throttleEditBox:GetText()) or 0
        end
        frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
        onChanges(frame.trigger)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.numenKeyEditBox:SetText(frame.trigger.key or "")
            if type == "trigger" then
                frame.hiddenFrames.delayEditBox:SetText(tostring(frame.trigger.delay) or "0")
                frame.hiddenFrames.throttleEditBox:SetText(tostring(frame.trigger.throttle) or "0")
                frame.hiddenFrames.countdownEditBox:SetText(tostring(frame.trigger.countdown) or "0")
            end
            frame.hiddenFrames:Show()
            frame:SetSize(width, type == "trigger" and 80 or 35) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, type == "trigger" and 80 or 35)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.numenKeyEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.numenKeyEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.numenKeyEditBox:SetScript("OnEnterPressed", acceptChanges)
    if type == "trigger" then
        frame.hiddenFrames.throttleEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEnterPressed", acceptChanges)
    end
    frame:Update()
    return frame
end

function FrameBuilder.CreateTimeTriggerFrame(parentFrame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.trigger = trigger
    frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    AddHiddenDelayEditbox(frame, font, fontSize, width, height)
    frame.hiddenFrames.delayTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    if type == "trigger" then
        AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.throttleTitle:SetPoint("TOPLEFT", frame.hiddenFrames.delayTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.countdownTitle:SetPoint("TOPLEFT", frame.hiddenFrames.throttleTitle, "BOTTOMLEFT", 0, -5)
    end
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.trigger.delay = tonumber(frame.hiddenFrames.delayEditBox:GetText()) or 0
        if type == "trigger" then
            frame.trigger.countdown = tonumber(frame.hiddenFrames.countdownEditBox:GetText()) or 0
            frame.trigger.throttle = tonumber(frame.hiddenFrames.throttleEditBox:GetText()) or 0
        end
        frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
        onChanges(frame.trigger)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.delayEditBox:SetText(tostring(frame.trigger.delay) or "0")
            if type == "trigger" then
                frame.hiddenFrames.throttleEditBox:SetText(tostring(frame.trigger.throttle) or "0")
                frame.hiddenFrames.countdownEditBox:SetText(tostring(frame.trigger.countdown) or "0")
            end
            frame.hiddenFrames:Show()
            frame:SetSize(width, type == "trigger" and 50 or 20) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, type == "trigger" and 50 or 20)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.delayEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.delayEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.delayEditBox:SetScript("OnEnterPressed", acceptChanges)
    if type == "trigger" then
        frame.hiddenFrames.throttleEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEnterPressed", acceptChanges)
    end
    frame:Update()
    return frame
end

function FrameBuilder.CreateUnitHealthTriggerFrame(parentFrame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.trigger = trigger
    frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    frame.hiddenFrames.unitTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.unitTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.unitTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.unitTitle:SetText("UnitID:")
    frame.hiddenFrames.unitTitle:SetWidth(frame.hiddenFrames.unitTitle:GetStringWidth())
    frame.hiddenFrames.unitEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.unitEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.unitEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.unitEditBox:SetPoint("LEFT", frame.hiddenFrames.unitTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.unitEditBox:SetAutoFocus(false)
    frame.hiddenFrames.typeTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.typeTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.typeTitle:SetPoint("TOPLEFT", frame.hiddenFrames.unitTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.typeTitle:SetText("Comparison Type:")
    frame.hiddenFrames.typeTitle:SetWidth(frame.hiddenFrames.typeTitle:GetStringWidth())
    local typeItems = {
        { name = "percentage", onClick = function ()
            frame.hiddenFrames.typeSelector.selectedName = "percentage"
            frame.hiddenFrames.typeSelector:Update()
        end },
        { name = "absolute", onClick = function ()
            frame.hiddenFrames.typeSelector.selectedName = "absolute"
            frame.hiddenFrames.typeSelector:Update()
        end }
    }
    frame.hiddenFrames.typeSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, typeItems, width - 10 - frame.hiddenFrames.typeTitle:GetWidth(), font, fontSize, frame.trigger.type or "percentage")
    frame.hiddenFrames.typeSelector:SetPoint("LEFT", frame.hiddenFrames.typeTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.operatorTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.operatorTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.operatorTitle:SetPoint("TOPLEFT", frame.hiddenFrames.typeTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.operatorTitle:SetText("Operator:")
    frame.hiddenFrames.operatorTitle:SetWidth(frame.hiddenFrames.operatorTitle:GetStringWidth())
    local operatorItems = {
        { name = "<", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "<"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = ">", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = ">"
            frame.hiddenFrames.operatorSelector:Update()
        end }
    }
    frame.hiddenFrames.operatorSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, operatorItems, width - 10 - frame.hiddenFrames.operatorTitle:GetWidth(), font, fontSize, frame.trigger.operator or "<")
    frame.hiddenFrames.operatorSelector:SetPoint("LEFT", frame.hiddenFrames.operatorTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.valueTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.valueTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.valueTitle:SetPoint("TOPLEFT", frame.hiddenFrames.operatorTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.valueTitle:SetText("Value:")
    frame.hiddenFrames.valueTitle:SetWidth(frame.hiddenFrames.valueTitle:GetStringWidth())
    frame.hiddenFrames.valueEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.valueEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.valueEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.valueEditBox:SetNumericFullRange(true)
    frame.hiddenFrames.valueEditBox:SetPoint("LEFT", frame.hiddenFrames.valueTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.valueEditBox:SetAutoFocus(false)
    if type == "trigger" then
        AddHiddenDelayEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.delayTitle:SetPoint("TOPLEFT", frame.hiddenFrames.valueTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.throttleTitle:SetPoint("TOPLEFT", frame.hiddenFrames.delayTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.countdownTitle:SetPoint("TOPLEFT", frame.hiddenFrames.throttleTitle, "BOTTOMLEFT", 0, -5)
    end
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.trigger.unitID = frame.hiddenFrames.unitEditBox:GetText() or ""
        frame.trigger.operator = frame.hiddenFrames.operatorSelector:GetSelectedValue() or "<"
        frame.trigger.type = frame.hiddenFrames.typeSelector:GetSelectedValue() or "percentage"
        frame.trigger.value = tonumber(frame.hiddenFrames.valueEditBox:GetText()) or 0
        if type == "trigger" then
            frame.trigger.countdown = tonumber(frame.hiddenFrames.countdownEditBox:GetText()) or 0
            frame.trigger.delay = tonumber(frame.hiddenFrames.delayEditBox:GetText()) or 0
            frame.trigger.throttle = tonumber(frame.hiddenFrames.throttleEditBox:GetText()) or 0
        end
        frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
        onChanges(frame.trigger)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.unitEditBox:SetText(frame.trigger.unitID or "")
            frame.hiddenFrames.operatorSelector:SetSelectedValue(frame.trigger.operator or "<")
            frame.hiddenFrames.typeSelector:SetSelectedValue(frame.trigger.type or "percentage")
            frame.hiddenFrames.valueEditBox:SetText(tostring(frame.trigger.value) or "0")
            if type == "trigger" then
                frame.hiddenFrames.delayEditBox:SetText(tostring(frame.trigger.delay) or "0")
                frame.hiddenFrames.throttleEditBox:SetText(tostring(frame.trigger.throttle) or "0")
                frame.hiddenFrames.countdownEditBox:SetText(tostring(frame.trigger.countdown) or "0")
            end
            frame.hiddenFrames:Show()
            frame:SetSize(width, type == "trigger" and 108 or 63) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, type == "trigger" and 108 or 63)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.unitEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.unitEditBox:SetScript("OnEscapePressed", cancelEditing)
    -- frame.hiddenFrames.operatorEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.valueEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.unitEditBox:SetScript("OnEnterPressed", acceptChanges)
    -- frame.hiddenFrames.operatorEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.valueEditBox:SetScript("OnEnterPressed", acceptChanges)
    if type == "trigger" then
        frame.hiddenFrames.throttleEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEnterPressed", acceptChanges)
    end
    frame:Update()
    return frame
end

function FrameBuilder.CreateSpellCastTriggerFrame(parentFrame, trigger, type, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.trigger = trigger
    frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    frame.hiddenFrames.spellTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.spellTitle:SetText("Spell ID:")
    frame.hiddenFrames.spellTitle:SetWidth(frame.hiddenFrames.spellTitle:GetStringWidth())
    frame.hiddenFrames.spellEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.spellEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.spellEditBox:SetNumeric(true)
    frame.hiddenFrames.spellEditBox:SetPoint("LEFT", frame.hiddenFrames.spellTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.spellEditBox:SetAutoFocus(false)
    frame.hiddenFrames.spellName = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellName:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellName:SetPoint("TOPLEFT", frame.hiddenFrames.spellTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.spellName:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    frame.hiddenFrames.spellName:SetText("Spell Name: "..(C_Spell.GetSpellName(frame.trigger.spellID) or "Spell not found!"))
    frame.hiddenFrames.sourceTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.sourceTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceTitle:SetPoint("TOPLEFT", frame.hiddenFrames.spellName, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.sourceTitle:SetText("Source:")
    frame.hiddenFrames.sourceTitle:SetWidth(frame.hiddenFrames.sourceTitle:GetStringWidth())
    frame.hiddenFrames.sourceEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.sourceEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.sourceEditBox:SetPoint("LEFT", frame.hiddenFrames.sourceTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.sourceEditBox:SetAutoFocus(false)
    frame.hiddenFrames.targetTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.targetTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetTitle:SetPoint("TOPLEFT", frame.hiddenFrames.sourceTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.targetTitle:SetText("Target:")
    frame.hiddenFrames.targetTitle:SetWidth(frame.hiddenFrames.targetTitle:GetStringWidth())
    frame.hiddenFrames.targetEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.targetEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.targetEditBox:SetPoint("LEFT", frame.hiddenFrames.targetTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.targetEditBox:SetAutoFocus(false)
    if type == "trigger" then
        AddHiddenDelayEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.delayTitle:SetPoint("TOPLEFT", frame.hiddenFrames.targetTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenThrottleEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.throttleTitle:SetPoint("TOPLEFT", frame.hiddenFrames.delayTitle, "BOTTOMLEFT", 0, -5)
        AddHiddenCountdownEditbox(frame, font, fontSize, width, height)
        frame.hiddenFrames.countdownTitle:SetPoint("TOPLEFT", frame.hiddenFrames.throttleTitle, "BOTTOMLEFT", 0, -5)
    end
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.trigger.spellID = tonumber(frame.hiddenFrames.spellEditBox:GetText()) or 0
        frame.trigger.source = frame.hiddenFrames.sourceEditBox:GetText() or ""
        frame.trigger.target = frame.hiddenFrames.targetEditBox:GetText() or ""
        if type == "trigger" then
            frame.trigger.countdown = tonumber(frame.hiddenFrames.countdownEditBox:GetText()) or 0
            frame.trigger.delay = tonumber(frame.hiddenFrames.delayEditBox:GetText()) or 0
            frame.trigger.throttle = tonumber(frame.hiddenFrames.throttleEditBox:GetText()) or 0
        end
        frame.text:SetText((type == "trigger" and "|cFFFFD200WHEN:|r " or "|cFFFFD200UNLESS:|r ")..frame.trigger:GetDisplayName())
        onChanges(frame.trigger)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.spellEditBox:SetText(tostring(frame.trigger.spellID) or "0")
            frame.hiddenFrames.sourceEditBox:SetText(frame.trigger.source or "")
            frame.hiddenFrames.targetEditBox:SetText(frame.trigger.target or "")
            if type == "trigger" then
                frame.hiddenFrames.delayEditBox:SetText(tostring(frame.trigger.delay) or "0")
                frame.hiddenFrames.throttleEditBox:SetText(tostring(frame.trigger.throttle) or "0")
                frame.hiddenFrames.countdownEditBox:SetText(tostring(frame.trigger.countdown) or "0")
            end
            frame.hiddenFrames:Show()
            frame:SetSize(width, type == "trigger" and 110 or 35) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, type == "trigger" and 110 or 35)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.spellEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnUpdate", function (editBox)
        frame.hiddenFrames.spellName:SetText("|cFFFFD200Spell Name:|r "..(C_Spell.GetSpellName(editBox:GetText()) or "Spell not found!"))
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.spellEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.targetEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.targetEditBox:SetScript("OnEnterPressed", acceptChanges)
    if type == "trigger" then
        frame.hiddenFrames.delayEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEscapePressed", cancelEditing)
        frame.hiddenFrames.delayEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.throttleEditBox:SetScript("OnEnterPressed", acceptChanges)
        frame.hiddenFrames.countdownEditBox:SetScript("OnEnterPressed", acceptChanges)
    end
    frame.Update()
    return frame
end

function FrameBuilder.CreateConditionFrame(parentFrame, condition, width, height, font, fontSize)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, "", width, height, font, fontSize)
    frame.condition = condition
    frame.text:SetText("|cFFFFD200IF:|r "..frame.condition:GetDisplayName())
    frame.hiddenFrames = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.hiddenFrames:SetAllPoints()
    frame.hiddenFrames:Hide()
    return frame
end

function FrameBuilder.CreateCastCountConditionFrame(parentFrame, condition, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateConditionFrame(parentFrame, condition, width, height, font, fontSize)
    frame.hiddenFrames.spellTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.spellTitle:SetText("Spell ID:")
    frame.hiddenFrames.spellTitle:SetWidth(frame.hiddenFrames.spellTitle:GetStringWidth())
    frame.hiddenFrames.spellEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.spellEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.spellEditBox:SetNumeric(true)
    frame.hiddenFrames.spellEditBox:SetPoint("LEFT", frame.hiddenFrames.spellTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.spellEditBox:SetAutoFocus(false)
    frame.hiddenFrames.spellName = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellName:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellName:SetPoint("TOPLEFT", frame.hiddenFrames.spellTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.spellName:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    frame.hiddenFrames.spellName:SetText("Spell Name: "..(C_Spell.GetSpellName(frame.condition.spellID) or "Spell not found!"))
    frame.hiddenFrames.sourceTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.sourceTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceTitle:SetPoint("TOPLEFT", frame.hiddenFrames.spellName, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.sourceTitle:SetText("Source:")
    frame.hiddenFrames.sourceTitle:SetWidth(frame.hiddenFrames.sourceTitle:GetStringWidth())
    frame.hiddenFrames.sourceEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.sourceEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.sourceEditBox:SetPoint("LEFT", frame.hiddenFrames.sourceTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.sourceEditBox:SetAutoFocus(false)
    frame.hiddenFrames.targetTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.targetTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetTitle:SetPoint("TOPLEFT", frame.hiddenFrames.sourceTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.targetTitle:SetText("Target:")
    frame.hiddenFrames.targetTitle:SetWidth(frame.hiddenFrames.targetTitle:GetStringWidth())
    frame.hiddenFrames.targetEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.targetEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.targetEditBox:SetPoint("LEFT", frame.hiddenFrames.targetTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.targetEditBox:SetAutoFocus(false)
    frame.hiddenFrames.operatorTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.operatorTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.operatorTitle:SetPoint("TOPLEFT", frame.hiddenFrames.targetTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.operatorTitle:SetText("Operator:")
    frame.hiddenFrames.operatorTitle:SetWidth(frame.hiddenFrames.operatorTitle:GetStringWidth())
    local operatorItems = {
        { name = "<", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "<"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = ">", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = ">"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = "==", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "=="
            frame.hiddenFrames.operatorSelector:Update()
        end }
    }
    frame.hiddenFrames.operatorSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, operatorItems, width - 10 - frame.hiddenFrames.operatorTitle:GetWidth(), font, fontSize, frame.condition.operator or "==")
    frame.hiddenFrames.operatorSelector:SetPoint("LEFT", frame.hiddenFrames.operatorTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.countTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.countTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.countTitle:SetPoint("TOPLEFT", frame.hiddenFrames.operatorTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.countTitle:SetText("Count:")
    frame.hiddenFrames.countTitle:SetWidth(frame.hiddenFrames.countTitle:GetStringWidth())
    frame.hiddenFrames.countEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.countEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.countEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.countEditBox:SetNumeric(true)
    frame.hiddenFrames.countEditBox:SetPoint("LEFT", frame.hiddenFrames.countTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.countEditBox:SetAutoFocus(false)
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.condition.spellID = tonumber(frame.hiddenFrames.spellEditBox:GetText()) or 0
        frame.condition.source = frame.hiddenFrames.sourceEditBox:GetText() or ""
        frame.condition.target = frame.hiddenFrames.targetEditBox:GetText() or ""
        frame.condition.operator = frame.hiddenFrames.operatorSelector:GetSelectedValue() or "=="
        frame.condition.count = tonumber(frame.hiddenFrames.countEditBox:GetText()) or 0
        frame.text:SetText("|cFFFFD200IF:|r "..frame.condition:GetDisplayName())
        onChanges(frame.condition)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.spellEditBox:SetText(tostring(frame.condition.spellID) or "0")
            frame.hiddenFrames.sourceEditBox:SetText(frame.condition.source or "")
            frame.hiddenFrames.targetEditBox:SetText(frame.condition.target or "")
            frame.hiddenFrames.operatorSelector:SetSelectedValue(frame.condition.operator or "==")
            frame.hiddenFrames.countEditBox:SetText(tostring(frame.condition.count) or "0")
            frame.hiddenFrames:Show()
            frame:SetSize(width, 95) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, 95)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.spellEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnUpdate", function (editBox)
        frame.hiddenFrames.spellName:SetText("|cFFFFD200Spell Name:|r "..(C_Spell.GetSpellName(editBox:GetText()) or "Spell not found!"))
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.spellEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.targetEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.targetEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.countEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.countEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.Update()
    return frame
end

function FrameBuilder.CreateAuraRemovedCountConditionsFrame(parentFrame, condition, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateConditionFrame(parentFrame, condition, width, height, font, fontSize)
    frame.hiddenFrames.spellTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.spellTitle:SetText("Aura ID:")
    frame.hiddenFrames.spellTitle:SetWidth(frame.hiddenFrames.spellTitle:GetStringWidth())
    frame.hiddenFrames.spellEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.spellEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.spellEditBox:SetNumeric(true)
    frame.hiddenFrames.spellEditBox:SetPoint("LEFT", frame.hiddenFrames.spellTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.spellEditBox:SetAutoFocus(false)
    frame.hiddenFrames.spellName = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.spellName:SetFont(font, fontSize, "")
    frame.hiddenFrames.spellName:SetPoint("TOPLEFT", frame.hiddenFrames.spellTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.spellName:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    frame.hiddenFrames.spellName:SetText("Aura Name: "..(C_Spell.GetSpellName(frame.condition.spellID) or "Aura not found!"))
    frame.hiddenFrames.sourceTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.sourceTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceTitle:SetPoint("TOPLEFT", frame.hiddenFrames.spellName, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.sourceTitle:SetText("Source:")
    frame.hiddenFrames.sourceTitle:SetWidth(frame.hiddenFrames.sourceTitle:GetStringWidth())
    frame.hiddenFrames.sourceEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.sourceEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.sourceEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.sourceEditBox:SetPoint("LEFT", frame.hiddenFrames.sourceTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.sourceEditBox:SetAutoFocus(false)
    frame.hiddenFrames.targetTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.targetTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetTitle:SetPoint("TOPLEFT", frame.hiddenFrames.sourceTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.targetTitle:SetText("Target:")
    frame.hiddenFrames.targetTitle:SetWidth(frame.hiddenFrames.targetTitle:GetStringWidth())
    frame.hiddenFrames.targetEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.targetEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.targetEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.targetEditBox:SetPoint("LEFT", frame.hiddenFrames.targetTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.targetEditBox:SetAutoFocus(false)
    frame.hiddenFrames.operatorTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.operatorTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.operatorTitle:SetPoint("TOPLEFT", frame.hiddenFrames.targetTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.operatorTitle:SetText("Operator:")
    frame.hiddenFrames.operatorTitle:SetWidth(frame.hiddenFrames.operatorTitle:GetStringWidth())
    local operatorItems = {
        { name = "<", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "<"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = ">", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = ">"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = "==", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "=="
            frame.hiddenFrames.operatorSelector:Update()
        end }
    }
    frame.hiddenFrames.operatorSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, operatorItems, width - 10 - frame.hiddenFrames.operatorTitle:GetWidth(), font, fontSize, frame.condition.operator or "==")
    frame.hiddenFrames.operatorSelector:SetPoint("LEFT", frame.hiddenFrames.operatorTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.countTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.countTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.countTitle:SetPoint("TOPLEFT", frame.hiddenFrames.operatorTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.countTitle:SetText("Count:")
    frame.hiddenFrames.countTitle:SetWidth(frame.hiddenFrames.countTitle:GetStringWidth())
    frame.hiddenFrames.countEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.countEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.countEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.countEditBox:SetNumeric(true)
    frame.hiddenFrames.countEditBox:SetPoint("LEFT", frame.hiddenFrames.countTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.countEditBox:SetAutoFocus(false)
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.condition.spellID = tonumber(frame.hiddenFrames.spellEditBox:GetText()) or 0
        frame.condition.source = frame.hiddenFrames.sourceEditBox:GetText() or ""
        frame.condition.target = frame.hiddenFrames.targetEditBox:GetText() or ""
        frame.condition.operator = frame.hiddenFrames.operatorSelector:GetSelectedValue() or "=="
        frame.condition.count = tonumber(frame.hiddenFrames.countEditBox:GetText()) or 0
        frame.text:SetText("|cFFFFD200IF:|r "..frame.condition:GetDisplayName())
        onChanges(frame.condition)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.spellEditBox:SetText(tostring(frame.condition.spellID) or "0")
            frame.hiddenFrames.sourceEditBox:SetText(frame.condition.source or "")
            frame.hiddenFrames.targetEditBox:SetText(frame.condition.target or "")
            frame.hiddenFrames.operatorSelector:SetSelectedValue(frame.condition.operator or "==")
            frame.hiddenFrames.countEditBox:SetText(tostring(frame.condition.count) or "0")
            frame.hiddenFrames:Show()
            frame:SetSize(width, 95) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, 95)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.spellEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnUpdate", function (editBox)
        frame.hiddenFrames.spellName:SetText("|cFFFFD200Aura Name:|r "..(C_Spell.GetSpellName(editBox:GetText()) or "Aura not found!"))
    end)
    frame.hiddenFrames.spellEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.spellEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.sourceEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.targetEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.targetEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.countEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.countEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.Update()
    return frame
end

function FrameBuilder.CreateUnitHealthConditionFrame(parentFrame, condition, width, height, font, fontSize, onChanges, onRemove)
    local frame = FrameBuilder.CreateConditionFrame(parentFrame, condition, width, height, font, fontSize)
    frame.hiddenFrames.unitIDTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.unitIDTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.unitIDTitle:SetPoint("TOPLEFT", frame.hiddenFrames, "TOPLEFT", 5, -5)
    frame.hiddenFrames.unitIDTitle:SetText("Unit ID:")
    frame.hiddenFrames.unitIDTitle:SetWidth(frame.hiddenFrames.unitIDTitle:GetStringWidth())
    frame.hiddenFrames.unitIDEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.unitIDEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.unitIDEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.unitIDEditBox:SetPoint("LEFT", frame.hiddenFrames.unitIDTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.unitIDEditBox:SetAutoFocus(false)
    frame.hiddenFrames.typeTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.typeTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.typeTitle:SetPoint("TOPLEFT", frame.hiddenFrames.unitIDTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.typeTitle:SetText("Comparison Type:")
    frame.hiddenFrames.typeTitle:SetWidth(frame.hiddenFrames.typeTitle:GetStringWidth())
    local typeItems = {
        { name = "percentage", onClick = function ()
            frame.hiddenFrames.typeSelector.selectedName = "percentage"
            frame.hiddenFrames.typeSelector:Update()
        end },
        { name = "absolute", onClick = function ()
            frame.hiddenFrames.typeSelector.selectedName = "absolute"
            frame.hiddenFrames.typeSelector:Update()
        end }
    }
    frame.hiddenFrames.typeSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, typeItems, width - 10 - frame.hiddenFrames.typeTitle:GetWidth(), font, fontSize, frame.condition.type or "percentage")
    frame.hiddenFrames.typeSelector:SetPoint("LEFT", frame.hiddenFrames.typeTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.operatorTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.operatorTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.operatorTitle:SetPoint("TOPLEFT", frame.hiddenFrames.typeTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.operatorTitle:SetText("Operator:")
    frame.hiddenFrames.operatorTitle:SetWidth(frame.hiddenFrames.operatorTitle:GetStringWidth())
    local operatorItems = {
        { name = "<", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = "<"
            frame.hiddenFrames.operatorSelector:Update()
        end },
        { name = ">", onClick = function ()
            frame.hiddenFrames.operatorSelector.selectedName = ">"
            frame.hiddenFrames.operatorSelector:Update()
        end }
    }
    frame.hiddenFrames.operatorSelector = FrameBuilder.CreateSelector(frame.hiddenFrames, operatorItems, width - 10 - frame.hiddenFrames.operatorTitle:GetWidth(), font, fontSize, frame.condition.operator or "<")
    frame.hiddenFrames.operatorSelector:SetPoint("LEFT", frame.hiddenFrames.operatorTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.valueTitle = frame.hiddenFrames:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.hiddenFrames.valueTitle:SetFont(font, fontSize, "")
    frame.hiddenFrames.valueTitle:SetPoint("TOPLEFT", frame.hiddenFrames.operatorTitle, "BOTTOMLEFT", 0, -5)
    frame.hiddenFrames.valueTitle:SetText("Value:")
    frame.hiddenFrames.valueTitle:SetWidth(frame.hiddenFrames.valueTitle:GetStringWidth())
    frame.hiddenFrames.valueEditBox = CreateFrame("EditBox", nil, frame.hiddenFrames)
    frame.hiddenFrames.valueEditBox:SetFont(font, fontSize, "")
    frame.hiddenFrames.valueEditBox:SetSize(width - 10, height)
    frame.hiddenFrames.valueEditBox:SetNumericFullRange(true)
    frame.hiddenFrames.valueEditBox:SetPoint("LEFT", frame.hiddenFrames.valueTitle, "RIGHT", 5, 0)
    frame.hiddenFrames.valueEditBox:SetAutoFocus(false)
    local function cancelEditing()
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    local function acceptChanges()
        frame.condition.unitID = frame.hiddenFrames.unitIDEditBox:GetText() or ""
        frame.condition.type = frame.hiddenFrames.typeSelector:GetSelectedValue() or "percentage"
        frame.condition.operator = frame.hiddenFrames.operatorSelector:GetSelectedValue() or "<"
        frame.condition.value = tonumber(frame.hiddenFrames.valueEditBox:GetText()) or 0
        frame.text:SetText("|cFFFFD200IF:|r "..frame.condition:GetDisplayName())
        onChanges(frame.condition)
        frame.hiddenFrames:Hide()
        frame:Update()
        frame.text:Show()
        parentFrame.Update()
    end
    frame:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame.text:Hide()
            frame.hiddenFrames.unitIDEditBox:SetText(tostring(frame.condition.unitID) or "")
            frame.hiddenFrames.typeSelector:SetSelectedValue(frame.condition.type or "percentage")
            frame.hiddenFrames.operatorSelector:SetSelectedValue(frame.condition.operator or "<")
            frame.hiddenFrames.valueEditBox:SetText(tostring(frame.condition.value) or "0")
            frame.hiddenFrames:Show()
            frame:SetSize(width, 65) -- Adjust the frame size to fit the hidden frames
            frame.hiddenFrames:SetSize(width, 65)
            frame:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdrop({
                bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
                tile = true,
                tileSize = frame:GetHeight(),
            })
            frame.hiddenFrames:SetBackdropColor(1, 1, 1, 0.2)
            frame.hiddenFrames.unitIDEditBox:SetFocus()
            parentFrame.Update()
        elseif button == "RightButton" then
            onRemove(parentFrame)
        end
    end)
    frame.hiddenFrames.unitIDEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.unitIDEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.hiddenFrames.valueEditBox:SetScript("OnEscapePressed", cancelEditing)
    frame.hiddenFrames.valueEditBox:SetScript("OnEnterPressed", acceptChanges)
    frame.Update()
    return frame
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateEditableTextFrame(parentFrame, text, width, height, font, fontSize, onChanged)
    local frame = FrameBuilder.CreateTextFrame(parentFrame, text, width, height, font, fontSize)
    frame.editBox = CreateFrame("EditBox", frame:GetName().."Edit", frame)
    frame.editBox:SetSize(width - 10, height)
    frame.editBox:SetPoint("LEFT", frame, "LEFT", 5, 0)
    frame.editBox:SetFont(font, fontSize, "")
    frame.editBox:Hide()
    frame:SetScript("OnMouseDown", function()
        frame.text:Hide()
        frame.editBox:SetText(frame.text:GetText() or "")
        frame.editBox:Show()
        frame.editBox:SetFocus()
    end)
    frame.editBox:SetScript("OnEscapePressed", function()
        frame.editBox:Hide()
        frame.text:Show()
    end)
    frame.editBox:SetScript("OnEnterPressed", function()
        frame.text:SetText(frame.editBox:GetText() or "")
        onChanged(frame.editBox:GetText())
        frame.editBox:Hide()
        frame.text:Show()
    end)
    frame:SetScript("OnEnter", function ()
        frame:SetBackdropColor(1, 1, 1, 0.4)
        frame.hoverIcon:Show()
    end)
    frame:SetScript("OnLeave", function ()
        frame:SetBackdropColor(0, 0, 0, 0)
        frame.hoverIcon:Hide()
    end)

    frame.hoverIcon = frame:CreateTexture(nil, "OVERLAY")
    frame.hoverIcon:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\edit.png")
    frame.hoverIcon:SetSize(fontSize, fontSize)
    frame.hoverIcon:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
    frame.hoverIcon:Hide()
    return frame
end

---@return table|BackdropTemplate|Frame
---@param parentFrame Frame
function FrameBuilder.CreateRosterFrame(parentFrame, id, name, width, height, font, fontSize)
    local rosterFrame = CreateFrame("Frame", parentFrame:GetName() .. "_Roster" .. id, parentFrame, "BackdropTemplate")
    rosterFrame.id = id
    rosterFrame.width = width
    rosterFrame.height = height
    rosterFrame:EnableMouse(true)
    rosterFrame.name = name
    rosterFrame.text = rosterFrame.text or rosterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rosterFrame.text:EnableMouse(false)
    rosterFrame.text:SetPoint("LEFT", rosterFrame, "LEFT", 5, 0)
    rosterFrame.text:SetFont(font, fontSize)
    rosterFrame.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    rosterFrame:SetScript("OnEnter", function () rosterFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    rosterFrame:SetScript("OnLeave", function () rosterFrame:SetBackdropColor(0, 0, 0, 0) end)
    rosterFrame.active = false
    rosterFrame.synced = false
    rosterFrame.icon = CreateFrame("Frame", nil, rosterFrame, "BackdropTemplate")
    rosterFrame.icon:SetSize(16, 16)
    rosterFrame.icon:SetPoint("RIGHT", rosterFrame, "RIGHT", -5, 0)
    rosterFrame.icon.texture = rosterFrame.icon:CreateTexture(nil, "ARTWORK")
    rosterFrame.icon.texture:SetAllPoints()
    rosterFrame.icon.texture:SetAlpha(0.8)
    rosterFrame.icon:Hide()
    rosterFrame.Update = function ()
        FrameBuilder.UpdateRosterFrame(rosterFrame)
    end
    rosterFrame.Update()
    return rosterFrame
end

function FrameBuilder.UpdateRosterFrame(rosterFrame)
    rosterFrame:SetSize(rosterFrame.width, rosterFrame.height)
    rosterFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = rosterFrame.height,
    })
    rosterFrame:SetBackdropColor(0, 0, 0, 0)
    rosterFrame.text:SetText(rosterFrame.name)
    if rosterFrame.active and rosterFrame.synced then
        rosterFrame.icon:Show()
        rosterFrame.icon.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\check-mark.png")
    elseif rosterFrame.active then
        rosterFrame.icon:Show()
        rosterFrame.icon.texture:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\alert.png")
    else
        rosterFrame.icon:Hide()
    end
end

---@return table|BackdropTemplate|Frame
---@param parentFrame table|BackdropTemplate|Frame
---@param height integer
function FrameBuilder.CreateAssignmentGroupFrame(parentFrame, height)
    local groupFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    groupFrame:SetHeight(height)
    groupFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = height,
    })
    groupFrame:SetBackdropColor(0, 0, 0, 0)
    groupFrame.assignments = {}
    groupFrame.highlightTop = groupFrame:CreateTexture(nil, "OVERLAY")
    groupFrame.highlightTop:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\highlight-white.png")
    groupFrame.highlightTop:SetBlendMode("ADD")
    groupFrame.highlightTop:SetPoint("TOPLEFT", groupFrame, "TOPLEFT", 0, 5)
    groupFrame.highlightTop:SetPoint("TOPRIGHT", groupFrame, "TOPRIGHT", 0, 5)
    groupFrame.highlightTop:SetHeight(10)
    groupFrame.highlightTop:Hide()
    groupFrame.highlightBottom = groupFrame:CreateTexture(nil, "OVERLAY")
    groupFrame.highlightBottom:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\highlight-white.png")
    groupFrame.highlightBottom:SetBlendMode("ADD")
    groupFrame.highlightBottom:SetPoint("BOTTOMLEFT", groupFrame, "BOTTOMLEFT", 0, -5)
    groupFrame.highlightBottom:SetPoint("BOTTOMRIGHT", groupFrame, "BOTTOMRIGHT", 0, -5)
    groupFrame.highlightBottom:SetHeight(10)
    groupFrame.highlightBottom:Hide()
    groupFrame.IsMouseOverFrame = function ()
        return FrameBuilder.IsMouseOverFrame(groupFrame)
    end
    groupFrame.IsMouseOverTop = function ()
        return FrameBuilder.IsMouseOverTop(groupFrame)
    end
    groupFrame.IsMouseOverMid = function ()
        return FrameBuilder.IsMouseOverMid(groupFrame)
    end
    groupFrame.IsMouseOverBottom = function ()
        return FrameBuilder.IsMouseOverBottom(groupFrame)
    end
    return groupFrame
end

---@param groupFrame table|BackdropTemplate|Frame
---@param uuid string
---@param index integer
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.UpdateAssignmentGroupFrame(groupFrame, uuid, index, fontSize, iconSize)
    groupFrame:Show()
    groupFrame.uuid = uuid
    groupFrame.index = index
    local height = (fontSize > iconSize and fontSize or iconSize) + 10
    groupFrame:SetHeight(height)
    groupFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = height,
    })
    groupFrame:SetBackdropColor(0, 0, 0, 0)
end

---@return table|BackdropTemplate|Frame
---@param parentFrame table|BackdropTemplate|Frame
---@param font any
---@param fontSize integer
---@param iconSize integer
function FrameBuilder.CreateAssignmentFrame(parentFrame, index, font, fontSize, iconSize)
    local assignmentFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    assignmentFrame:SetClipsChildren(false)
    assignmentFrame.index = index
    assignmentFrame.iconFrame = CreateFrame("Frame", nil, assignmentFrame, "BackdropTemplate")
    assignmentFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    assignmentFrame:SetBackdropColor(0, 0, 0, 0)
    assignmentFrame:SetScript("OnEnter", function() assignmentFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    assignmentFrame:SetScript("OnLeave", function() assignmentFrame:SetBackdropColor(0, 0, 0, 0) end)
    assignmentFrame:SetMouseClickEnabled(true)
    assignmentFrame.highlight = assignmentFrame:CreateTexture(nil, "OVERLAY")
    assignmentFrame.highlight:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\highlight-white.png")
    assignmentFrame.highlight:SetBlendMode("ADD")
    assignmentFrame.highlight:SetPoint("TOPLEFT", assignmentFrame, "TOPLEFT", 0, 5)
    assignmentFrame.highlight:SetPoint("TOPRIGHT", assignmentFrame, "TOPRIGHT", 0, 5)
    assignmentFrame.highlight:SetHeight(10)
    assignmentFrame.highlight:Hide()
    assignmentFrame.iconFrame:SetSize(iconSize, iconSize)
    assignmentFrame.iconFrame:SetPoint("LEFT", 5, 0)
    assignmentFrame.cooldownFrame = CreateFrame("Cooldown", nil, assignmentFrame.iconFrame, "CooldownFrameTemplate")
    assignmentFrame.cooldownFrame:SetAllPoints()
    assignmentFrame.iconFrame.cooldown = assignmentFrame.cooldownFrame
    assignmentFrame.icon = assignmentFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    assignmentFrame.icon:SetAllPoints()
    assignmentFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    assignmentFrame.text = assignmentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    assignmentFrame.text:SetFont(font, fontSize)
    assignmentFrame.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    assignmentFrame.text:SetPoint("LEFT", assignmentFrame.iconFrame, "CENTER", iconSize/2+4, -1)
    return assignmentFrame
end

---@param assignmentFrame table|BackdropTemplate|Frame
function FrameBuilder.UpdateAssignmentFrame(assignmentFrame, assignment)
    assignmentFrame.player = assignment.player
    assignmentFrame.spellId = assignment.spell_id
    assignmentFrame:Show()
    if assignmentFrame.spellId then
        local spellIcon, _ = C_Spell.GetSpellTexture(assignmentFrame.spellId)
        assignmentFrame.icon:SetTexture(spellIcon)
        local color = SRTData.GetClassColorBySpellID(assignmentFrame.spellId)
        assignmentFrame.text:SetTextColor(color.r, color.g, color.b)
    end
    assignmentFrame.text:SetText(strsplit("-", assignmentFrame.player))
    assignmentFrame.cooldownFrame:Clear()
    assignmentFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = assignmentFrame:GetHeight(),
    })
    assignmentFrame:SetBackdropColor(0, 0, 0, 0)
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateLargeSpellFrame(parentFrame)
    local spellFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    spellFrame.iconFrame = CreateFrame("Frame", nil, spellFrame)
    spellFrame.iconFrame:SetPoint("TOPLEFT", 10, -5)
    spellFrame.icon = spellFrame.iconFrame:CreateTexture(nil, "ARTWORK")
    spellFrame.icon:SetAllPoints()
    spellFrame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    spellFrame.name = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellFrame.name:SetTextColor(1, 1, 1, 1)
    spellFrame.name:SetPoint("TOPLEFT", spellFrame.iconFrame, "TOPRIGHT", 7, -1)

    spellFrame.castTimeText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.castTimeText:SetTextColor(1, 1, 1, 1)
    spellFrame.castTimeText:SetPoint("TOPLEFT", spellFrame.name, "BOTTOMLEFT", 0, -3)

    spellFrame.durationText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.durationText:SetTextColor(1, 1, 1, 1)
    spellFrame.durationText:SetPoint("TOPLEFT", spellFrame.castTimeText, "BOTTOMLEFT", 0, -3)

    spellFrame.cooldownText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.cooldownText:SetTextColor(1, 1, 1, 1)
    spellFrame.cooldownText:SetPoint("TOPLEFT", spellFrame.durationText, "BOTTOMLEFT", 0, -3)

    spellFrame.rangeText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.rangeText:SetTextColor(1, 1, 1, 1)
    spellFrame.rangeText:SetPoint("TOPLEFT", spellFrame.cooldownText, "BOTTOMLEFT", 0, -3)

    spellFrame.descriptionText = spellFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellFrame.descriptionText:SetTextColor(1, 1, 1, 1)
    spellFrame.descriptionText:SetPoint("TOPLEFT", spellFrame.rangeText, "BOTTOMLEFT", 0, -3)
    return spellFrame
end

function FrameBuilder.UpdateLargeSpellFrame(spellFrame, spellID, font, fontSize, iconSize)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    local srtSpellInfo = SRTData.GetSpellByID(spellID)
    spellFrame:Show()
    spellFrame.spellID = spellID
    spellFrame.iconFrame:SetSize(iconSize, iconSize)
    spellFrame.icon:SetTexture(spellInfo.iconID)
    spellFrame.name:SetFont(font, fontSize+2)
    spellFrame.name:SetText(spellInfo.name)
    spellFrame.castTimeText:SetFont(font, fontSize)
    spellFrame.castTimeText:SetText(string.format("Cast time: %ds", spellInfo.castTime/1000))
    if srtSpellInfo ~= nil then
        spellFrame.durationText:Show()
        spellFrame.durationText:SetFont(font, fontSize)
        spellFrame.durationText:SetText(string.format("Duration: %ds", srtSpellInfo.duration))
        spellFrame.cooldownText:Show()
        spellFrame.cooldownText:SetFont(font, fontSize)
        spellFrame.cooldownText:SetText(string.format("Cooldown: %ds", srtSpellInfo.cooldown))
    else
        spellFrame.durationText:Hide()
        spellFrame.cooldownText:Hide()
    end
    spellFrame.rangeText:SetFont(font, fontSize)
    spellFrame.rangeText:SetText(string.format("Range: %d to %d yards", spellInfo.minRange, spellInfo.maxRange))
    local description = C_Spell.GetSpellDescription(spellID)
    spellFrame.descriptionText:SetFont(font, fontSize)
    spellFrame.descriptionText:SetText(string.format("%s", description))
    spellFrame.descriptionText:SetWidth(280 - iconSize - 27)
    spellFrame.descriptionText:SetJustifyH("LEFT")
    spellFrame.descriptionText:SetHeight(spellFrame.descriptionText:GetStringHeight())
    local textHeight = 5 + 1 + spellFrame.name:GetStringHeight() + 3 + spellFrame.castTimeText:GetStringHeight() + 3 + spellFrame.rangeText:GetStringHeight() + 3 + spellFrame.descriptionText:GetStringHeight() + 10
    if srtSpellInfo ~= nil then
        textHeight = textHeight + 3 + spellFrame.durationText:GetStringHeight() + 3 + spellFrame.cooldownText:GetStringHeight()
    end
    local height = iconSize > textHeight and iconSize+10 or textHeight
    spellFrame:SetHeight(height)
    spellFrame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = spellFrame:GetHeight(),
    })
    spellFrame:SetBackdropColor(0, 0, 0, 0)
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateButton(parentFrame, width, height, text, color, colorHighlight)
    local button = CreateFrame("Frame", parentFrame:GetName().."_Button_"..string.gsub(text, " ", ""), parentFrame, "BackdropTemplate")
    button.width = width
    button.height = height
    button.displayText = text
    button.color = color
    button.colorHighlight = colorHighlight
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetAllPoints()
    button.text:SetTextColor(1, 1, 1, 1)
    FrameBuilder.UpdateButton(button)
    return button
end

function FrameBuilder.UpdateButton(button)
    button:SetScript("OnEnter", function(b) b:SetBackdropColor(button.colorHighlight.r, button.colorHighlight.g, button.colorHighlight.b, button.colorHighlight.a) end)
    button:SetScript("OnLeave", function(b) b:SetBackdropColor(button.color.r, button.color.g, button.color.b, button.color.a) end)
    button:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = button.height,
    })
    button:SetBackdropColor(button.color.r, button.color.g, button.color.b, button.color.a)
    button:SetWidth(button.width)
    button:SetHeight(button.height)
    button.text:SetText(button.displayText)
end

---@return table|BackdropTemplate|Frame
function FrameBuilder.CreateSelector(parentFrame, items, width, font, fontSize, selectedName)
    local selector = CreateFrame("Frame", "SRT_DropdownClosed", parentFrame, "BackdropTemplate")
    selector:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 16,
    })
    selector:SetBackdropColor(0, 0, 0, 0)
    selector:SetSize(width, fontSize+2)
    selector.selectedName = selectedName
    selector.items = items
    selector.font = font
    selector.fontSize = fontSize
    selector.text = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selector.text:SetPoint("LEFT", selector, "LEFT", 5, 0)
    selector.text:SetFont(selector.font, selector.fontSize)
    selector.text:SetText(selectedName)
    selector.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    selector.text:SetJustifyH("LEFT")
    selector.button = CreateFrame("Button", "SRT_DropdownButton", selector)
    selector.button:SetSize(selector.fontSize*1.4, selector.fontSize*1.4)
    selector.button:SetPoint("RIGHT", selector, "RIGHT", -3, 0)
    selector.button:SetNormalTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\dropdown_alt.png")
    selector.button:SetHighlightTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\dropdown_alt_hover.png")
    selector.button:SetPushedTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\dropdown_alt_hover.png")
    selector.button:SetAlpha(0.8)
    selector.button:SetScript("OnEnter", function(b) b:SetAlpha(1) end)
    selector.button:SetScript("OnLeave", function(b) b:SetAlpha(0.8) end)
    selector.button:SetScript("OnClick", function(b)
        if selector.dropdown:IsShown() then
            selector.dropdown:Hide()
        else
            selector.dropdown:Show()
        end
    end)
    selector.dropdown = CreateFrame("Frame", "SRT_DropdownOpen", parentFrame, "BackdropTemplate")
    selector.dropdown:SetPoint("TOPLEFT", selector, "BOTTOMLEFT", 5, -5)
    selector.dropdown:SetPoint("TOPRIGHT", selector, "BOTTOMRIGHT", -10, -5)
    selector.dropdown:SetFrameStrata("DIALOG")
    selector.dropdown:Hide()
    selector.Update = function ()
        FrameBuilder.UpdateSelector(selector)
    end
    selector.GetSelectedValue = function ()
        for _, item in ipairs(selector.items) do
            if item.name == selector.selectedName then
                return item.name
            end
        end
        return nil
    end
    selector.SetSelectedValue = function (value)
        for _, item in ipairs(selector.items) do
            if item.value == value then
                selector.selectedName = item.name
                selector.text:SetText(item.name)
                return
            end
        end
    end
    selector.RemoveItem = function (index)
        table.remove(selector.items, index)
        selector.Update()
    end
    selector.Update()
    return selector
end

function FrameBuilder.UpdateSelector(selector)
    selector.text:SetText(selector.selectedName or "Select...")
    selector.dropdown:SetHeight(#selector.items * (14+4))
    selector.dropdown:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = selector.dropdown:GetHeight(),
    })
    selector.dropdown:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    selector.dropdown.rows = selector.dropdown.rows or {}
    for _, row in ipairs(selector.dropdown.rows) do
        row:Hide()
    end
    local lastRow
    for rowIndex, item in ipairs(selector.items) do
        item.index = rowIndex
        local row = selector.dropdown.rows[rowIndex] or CreateFrame("Frame", nil, selector.dropdown, "BackdropTemplate")
        row:SetSize(selector:GetWidth(), 18)
        if lastRow then
            row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", lastRow, "BOTTOMRIGHT", 0, 0)
        else
            row:SetPoint("TOPLEFT", selector.dropdown, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", selector.dropdown, "TOPRIGHT", 0, 0)
        end
        row:SetBackdrop({
            bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
            tile = true,
            tileSize = 16,
        })
        row:SetBackdropColor(0, 0, 0, 0)
        row:SetScript("OnEnter", function(r)
            r:SetBackdropColor(SRTColor.GameYellow.r, SRTColor.GameYellow.g, SRTColor.GameYellow.b, SRTColor.GameYellow.a)
            if item.highlight then
                r.text:SetTextColor(0.2, 0.5, 0.2, 1)
            else
                r.text:SetTextColor(0.2, 0.2, 0.2, 1)
            end
        end)
        row:SetScript("OnLeave", function(r)
            r:SetBackdropColor(0, 0, 0, 0)
            if item.highlight then
                r.text:SetTextColor(0.3, 0.8, 0.3, 1)
            else
                r.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
            end
        end)
        row:SetScript("OnMouseDown", function (r)
            selector.dropdown:Hide()
            selector.selectedName = item.name
            selector.text:SetText(item.name)
            item.onClick(r)
        end)
        row.item = item
        row.text = row.text or row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.text:SetPoint("LEFT", row, "LEFT", 10, 0)
        row.text:SetFont(selector.font, selector.fontSize - 2)
        if item.name then
            row.text:SetText(item.name)
        else
            row.text:SetText("[empty]")
        end
        if item.highlight then
            row.text:SetTextColor(0.3, 0.8, 0.3, 1)
        else
            row.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        end
        row.text:SetJustifyH("LEFT")
        selector.dropdown.rows[rowIndex] = row
        row:Show()
        lastRow = row
    end
end

---@return table|Frame|BackdropTemplate
function FrameBuilder.CreateFilterMenu(parentFrame, structure, font, updateFunction, depth)
    if not depth then depth = 1 end
    local popup = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    popup:SetFrameStrata("DIALOG")
    popup:SetWidth(120)
    popup:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 240,
    })
    popup:SetBackdropColor(0, 0, 0, 0.8)

    local lastItem
    local count = 0
    popup.items = {}
    for name, subStructure in Utils:OrderedPairs(structure) do
        if name ~= "_function" then 
            popup.items[name] = FrameBuilder.CreateFilterMenuItem(popup, lastItem, name, structure._function, subStructure, font, updateFunction, depth)
            lastItem = popup.items[name]
            count = count + 1
        end
    end

    if depth == 1 then
        popup.items.close = CreateFrame("Frame", nil, popup, "BackdropTemplate")
        popup.items.close:SetHeight(18)
        popup.items.close:SetPoint("TOPLEFT", lastItem, "BOTTOMLEFT")
        popup.items.close:SetPoint("TOPRIGHT", lastItem, "BOTTOMRIGHT")
        popup.items.close.text = popup.items.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        popup.items.close.text:SetText("Close")
        popup.items.close.text:SetFont(font, 12)
        popup.items.close.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        popup.items.close.text:SetPoint("TOPLEFT", 3, -3)
        popup.items.close:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popup.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
        end)
        popup.items.close:SetScript("OnMouseDown", function (_, button)
            if button == "LeftButton" then popup:Hide() end
        end)
        count = count + 1
    end

    popup:SetHeight(18 * count)

    popup.Update = function ()
        FrameBuilder.UpdateFilterMenu(popup)
    end
    return popup
end

---@return table|Frame|BackdropTemplate
function FrameBuilder.CreateFilterMenuItem(popupFrame, previousItem, name, nameFunction, structure, font, updateFunction, depth)
    local item = CreateFrame("Frame", nil, popupFrame, "BackdropTemplate")
    item:SetHeight(18)
    if previousItem then
        item:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT")
        item:SetPoint("TOPRIGHT", previousItem, "BOTTOMRIGHT")
    else
        item:SetPoint("TOPLEFT")
        item:SetPoint("TOPRIGHT")
    end
    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    if nameFunction then
        item.text:SetText(nameFunction(name))
    else
        item.text:SetText(name)
    end
    item.text:SetFont(font, 12)
    item.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    item.text:SetPoint("TOPLEFT", 3, -3)
    if type(structure) == "boolean" then
        item.value = structure
        item.icon = CreateFrame("Button", nil, item, "BackdropTemplate")
        item.icon:SetPoint("TOPRIGHT", item, "TOPRIGHT", -3, -3)
        item.icon:SetSize(12, 12)
        item.icon.texture = item.icon:CreateTexture(nil, "OVERLAY")
        if item.value then
            item.icon.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        else
            item.icon.texture:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
        end
        item.icon.texture:SetAllPoints()
        item:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popupFrame.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
        end)
        item:SetScript("OnMouseDown", function (_, button)
            if button == "LeftButton" then
                item.value = not item.value
                popupFrame.Update()
                updateFunction()
            end
        end)
    elseif type(structure) == "table" then
        item.arrow = item:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        item.arrow:SetText(">")
        item.arrow:SetFont(font, 12)
        item.arrow:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
        item.arrow:SetPoint("TOPRIGHT", -3, -3)

        item.popup = FrameBuilder.CreateFilterMenu(item, structure, font, updateFunction, depth+1)
        item.popup:SetPoint("TOPLEFT", item, "TOPRIGHT", 0, 0)
        item.popup:Hide()
        item:SetScript("OnEnter", function ()
            for _, otherItem in pairs(popupFrame.items) do
                if otherItem.popup then
                    otherItem.popup:Hide()
                end
            end
            item.popup:Show()
        end)
    end
    return item
end

function FrameBuilder.UpdateFilterMenu(popup)
    for _, item in pairs(popup.items) do
        if item.icon then
            -- option
            if item.value then
                item.icon.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
            else
                item.icon.texture:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
            end
        elseif item.popup then
            -- menu
            item.popup.Update()
        end
    end
end

---@return table|Frame|ScrollFrame
function FrameBuilder.CreateScrollArea(parentFrame, areaName)
    local scrollFrame
    scrollFrame = CreateFrame("ScrollFrame", string.format("%s_%sScroll", parentFrame:GetName(), areaName), parentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetClipsChildren(true)
    scrollFrame.ScrollBar:SetValueStep(20)  -- Set scrolling speed per scroll step
    scrollFrame.ScrollBar:SetMinMaxValues(0, 400)  -- Set based on content height - frame height
    scrollFrame.content = CreateFrame("Frame", string.format("%s_%sScrollContent", parentFrame:GetName(), areaName), scrollFrame)
    scrollFrame.content:SetClipsChildren(false)
    scrollFrame.content:SetSize(500, 8000)  -- Set the size of the content frame (height is larger for scrolling)
    scrollFrame.content:SetPoint("TOPLEFT")
    scrollFrame.content:SetPoint("TOPRIGHT")
    scrollFrame:SetScrollChild(scrollFrame.content)
    scrollFrame.bar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollFrame.bar.scrollStep = 23*3  -- Change this value to adjust the scroll amount per tick
    scrollFrame.bar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -12, 0)
    scrollFrame.bar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -12, 0)
    scrollFrame.bar.ScrollUpButton:SetAlpha(0)
    scrollFrame.bar.ScrollDownButton:SetAlpha(0)
    local thumbTexture = scrollFrame.bar:GetThumbTexture()
    thumbTexture:SetColorTexture(0, 0, 0, 0.8)  -- RGBA (0, 0, 0, 1) sets it to solid black
    thumbTexture:SetWidth(5)  -- Customize the size as needed
    scrollFrame.bar:Show()
    scrollFrame.items = {}
    scrollFrame.FindFirstItem = function ()
        for _, item in pairs(scrollFrame.items) do
            local _, previousItem = item:GetPoint(1)
            if previousItem and previousItem:GetName() == scrollFrame.content:GetName() then
                return item
            end
        end
    end
    scrollFrame.FindNextItem = function (name, item)
        for otherName, otherItem in pairs(scrollFrame.items) do
            if otherName ~= name then
                local _, otherPreviousItem = otherItem:GetPoint(1)
                if otherPreviousItem and otherPreviousItem:GetName() == item:GetName() then
                    return otherItem
                end
            end
        end
        return nil
    end
    scrollFrame.ConnectItem = function(name, item)
        -- Administration
        scrollFrame.items[name] = item
        -- Change parent to scroll content
        item:SetParent(scrollFrame.content)
        -- Attach first item to our bottom
        local firstItem = scrollFrame.FindFirstItem()
        if firstItem and firstItem:GetName() ~= item:GetName() then
            firstItem:SetPoint("TOPLEFT", item, "BOTTOMLEFT", 0, 0)
        end
        -- Attach item to top
        item:SetPoint("TOPLEFT", scrollFrame.content, "TOPLEFT", 10, 0)
    end
    scrollFrame.DisconnectItem = function (name, item, newParent)
        -- Administration
        scrollFrame.items[name] = nil
        -- Change parent to content to avoid cutoff
        item:SetParent(newParent)
        -- Cleverly connect next item to previous item
        local _, previousItem = item:GetPoint(1)
        local nextItem = scrollFrame.FindNextItem(name, item)
        if nextItem then
            if previousItem:GetName() == scrollFrame.content:GetName() then
                nextItem:SetPoint("TOPLEFT", previousItem, "TOPLEFT", 10, 0)
            else
                nextItem:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, 0)
            end
        end
        -- Disconnect
        item:ClearAllPoints()
    end
    scrollFrame.IsMouseOverArea = function ()
        return FrameBuilder.IsMouseOverFrame(scrollFrame)
    end
    return scrollFrame
end

---@param frame table|BackdropTemplate|Frame
---@return boolean
function FrameBuilder.IsMouseOverFrame(frame)
    -- return frame:IsMouseOver()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetScale()
    local left = frame:GetLeft() * scale
    local right = frame:GetRight() * scale
    local top = frame:GetTop() * scale
    local bottom = frame:GetBottom() * scale
    if left < x and right > x and top > y and bottom < y then
        return true
    else
        return false
    end
end

---@param frame table|BackdropTemplate|Frame
---@return boolean
function FrameBuilder.IsMouseOverTop(frame)
    -- return frame:IsMouseOver()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetScale()
    local left = frame:GetLeft() * scale
    local right = frame:GetRight() * scale
    local top = frame:GetTop() * scale
    local bottom = frame:GetBottom() * scale
    local height = top - bottom
    if left < x and right > x and top > y and (top - height * 0.25) < y then
        return true
    else
        return false
    end
end

---@param frame table|BackdropTemplate|Frame
---@return boolean
function FrameBuilder.IsMouseOverMid(frame)
    -- return frame:IsMouseOver()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetScale()
    local left = frame:GetLeft() * scale
    local right = frame:GetRight() * scale
    local top = frame:GetTop() * scale
    local bottom = frame:GetBottom() * scale
    local height = top - bottom
    if left < x and right > x and (top - height * 0.25) > y and (bottom + height * 0.25) < y then
        return true
    else
        return false
    end
end

---@param frame table|BackdropTemplate|Frame
---@return boolean
function FrameBuilder.IsMouseOverBottom(frame)
    -- return frame:IsMouseOver()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetScale()
    local left = frame:GetLeft() * scale
    local right = frame:GetRight() * scale
    local top = frame:GetTop() * scale
    local bottom = frame:GetBottom() * scale
    local height = top - bottom
    if left < x and right > x and bottom < y and (bottom + height * 0.25) > y then
        return true
    else
        return false
    end
end

---@return table|Frame|BackdropTemplate
function FrameBuilder.CreateBossAbilityAssignmentsFrame(parentFrame, name, abilityIndex, width, font, fontSize)
    local frameName = parentFrame:GetName().."_BossAbilityAssignments_"..name
    local frame = CreateFrame("Frame", frameName, parentFrame, "BackdropTemplate")
    frame.name = name
    frame.abilityIndex = abilityIndex
    frame.width = width
    frame.displayText = name
    frame.font = font
    frame.fontSize = fontSize
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = 25,
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    frame.title:SetPoint("TOPLEFT", 5, -3)
    frame.highlight = frame:CreateTexture(nil, "OVERLAY")
    frame.highlight:SetTexture("Interface\\Addons\\SwiftdawnRaidTools\\Media\\highlight-white.png")
    frame.highlight:SetBlendMode("ADD")
    frame.highlight:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 10)
    frame.highlight:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 10)
    frame.highlight:SetHeight(10)
    frame.highlight:Hide()
    frame.groups = {}
    frame.IsMouseOverFrame = function ()
        return FrameBuilder.IsMouseOverFrame(frame)
    end
    frame.IsMouseOverTop = function ()
        return FrameBuilder.IsMouseOverTop(frame)
    end
    frame.IsMouseOverMid = function ()
        return FrameBuilder.IsMouseOverMid(frame)
    end
    frame.IsMouseOverBottom = function ()
        return FrameBuilder.IsMouseOverBottom(frame)
    end
    frame.Update = function ()
        FrameBuilder.UpdateBossAbilityAssignmentsFrame(frame)
    end
    frame.Update()
    return frame
end

function FrameBuilder.UpdateBossAbilityAssignmentsFrame(frame)
    frame:SetSize(frame.width, frame.fontSize + 10 + ((10 + 14) * (#frame.groups + 0)) + 5)
    frame:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = frame:GetHeight(),
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame.title:SetText(frame.name)
    frame.title:SetFont(frame.font, frame.fontSize)
    if #frame.groups >= 1 then
        frame.groups[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -(frame.fontSize + 10))
        frame.groups[1]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -(frame.fontSize + 10))
    end
end

function FrameBuilder.CreatePopupMenu(parentFrame, items)
    local popupMenu = CreateFrame("Frame", "SRT_"..parentFrame:GetName().."_PopupMenu", UIParent, "BackdropTemplate")
    popupMenu.Update = function (i)
        FrameBuilder.UpdatePopupMenu(popupMenu, i)
    end
    popupMenu:SetClampedToScreen(true)
    popupMenu:SetSize(200, 50)
    popupMenu:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    })
    popupMenu:SetBackdropColor(0, 0, 0, 1)
    popupMenu:SetFrameStrata("DIALOG")
    popupMenu:Hide() -- Start hidden
    popupMenu.items = {}
    popupMenu.Update(items)
    return popupMenu
end

local function AppearancePopupFontType()
    return SharedMedia:Fetch("font", "Friz Quadrata TT")
end

function FrameBuilder.CreatePopupMenuItem(popupMenu, text, onClick, isSetting)
    local item = CreateFrame("Frame", nil, popupMenu, "BackdropTemplate")
    item:SetHeight(20)
    item:EnableMouse(true)
    item:SetScript("OnEnter", function() item.highlight:Show() end)
    item:SetScript("OnLeave", function() item.highlight:Hide() end)
    item:EnableMouse(true)
    item:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            if item.onClick then item.onClick() end
            popupMenu:Hide()
        end
    end)
    item.highlight = item:CreateTexture(nil, "HIGHLIGHT")
    item.highlight:SetPoint("TOPLEFT", 10, 0)
    item.highlight:SetPoint("BOTTOMRIGHT", -10, 0)
    item.highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    item.highlight:SetBlendMode("ADD")
    item.highlight:SetAlpha(0.5)
    item.highlight:Hide()
    item.text = item:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    item.text:SetFont(AppearancePopupFontType(), 10)
    if isSetting then
        item.text:SetTextColor(SRTColor.LightGray.r, SRTColor.LightGray.g, SRTColor.LightGray.b, SRTColor.LightGray.a)
    else
        item.text:SetTextColor(SRTColor.GameYellow.r, SRTColor.GameYellow.g, SRTColor.GameYellow.b, SRTColor.GameYellow.a)
    end
    item.text:SetPoint("BOTTOMLEFT", 15, 5)
    item.Update = function (t, oc)
        FrameBuilder.UpdatePopupMenuItem(item, t, oc)
    end
    item.Update(text, onClick)
    return item
end

function FrameBuilder.UpdatePopupMenuItem(item, text, onClick)
    item.text:SetText(text)
    item.onClick = onClick
end

function FrameBuilder.UpdatePopupMenu(popupMenu, items)
    if not items then
        popupMenu:Hide()
        return
    end
    for _, item in pairs(popupMenu.items) do
        item:Hide()
    end
    local previousItem = nil
    local leaveSpace = false
    local height = 20
    for index, item in pairs(items) do
        if item.name then
            local itemFrame = popupMenu.items[index] or FrameBuilder.CreatePopupMenuItem(popupMenu, item.name, item.onClick, item.isSetting)
            itemFrame.Update(item.name, item.onClick)
            height = height + 20
            if previousItem then
                if leaveSpace then
                    itemFrame:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -10)
                    itemFrame:SetPoint("TOPRIGHT", previousItem, "BOTTOMRIGHT", 0, -10)
                    height = height + 10
                    leaveSpace = false
                else
                    itemFrame:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, 0)
                    itemFrame:SetPoint("TOPRIGHT", previousItem, "BOTTOMRIGHT", 0, 0)
                end
            else
                itemFrame:SetPoint("TOPLEFT", popupMenu, "TOPLEFT", 0, -10)
                itemFrame:SetPoint("TOPRIGHT", popupMenu, "TOPRIGHT", 0, -10)
            end
            popupMenu.items[index] = itemFrame
            itemFrame:Show()
            previousItem = itemFrame
        else
            leaveSpace = true
        end
    end
    if height > 0 then
        popupMenu:SetHeight(height)
    end
end