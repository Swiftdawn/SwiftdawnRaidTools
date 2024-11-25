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
    rosterFrame.text:SetTextColor(0.8, 0.8, 0.8, 1)
    rosterFrame:SetScript("OnEnter", function () rosterFrame:SetBackdropColor(1, 1, 1, 0.4) end)
    rosterFrame:SetScript("OnLeave", function () rosterFrame:SetBackdropColor(0, 0, 0, 0) end)
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
    groupFrame.IsMouseOverFrame = function ()
        return FrameBuilder.IsMouseOverFrame(groupFrame)
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
    assignmentFrame:SetClipsChildren(true)
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
    assignmentFrame.text:SetTextColor(0.8, 0.8, 0.8, 1)
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
    selector.text:SetTextColor(0.8, 0.8, 0.8, 1)
    selector.text:SetJustifyH("LEFT")
    selector.button = CreateFrame("Button", "SRT_DropdownButton", selector)
    selector.button:SetSize(selector.fontSize*1.4, selector.fontSize*1.4)
    selector.button:SetPoint("RIGHT", selector, "RIGHT", -3, 0)
    selector.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    selector.button:SetAlpha(0.8)
    selector.button:SetScript("OnEnter", function(b) b:SetAlpha(1) end)
    selector.button:SetScript("OnLeave", function(b) b:SetAlpha(0.8) end)
    selector.button:SetScript("OnClick", function(b)
        if selector.dropdown:IsShown() then
            selector.dropdown:Hide()
            -- selector:SetBackdropColor(0, 0, 0, 0)
        else
            selector.dropdown:Show()
            -- selector:SetBackdropColor(0, 0, 0, 0.5)
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
    selector.Update()
    return selector
end

function FrameBuilder.UpdateSelector(selector)
    selector.text:SetText(selector.selectedName)
    selector.dropdown:SetHeight(#selector.items * (14+4))
    selector.dropdown:SetBackdrop({
        bgFile = "Interface\\Addons\\SwiftdawnRaidTools\\Media\\gradient32x32.tga",
        tile = true,
        tileSize = selector.dropdown:GetHeight(),
    })
    selector.dropdown:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    selector.dropdown.rows = selector.dropdown.rows or {}
    local lastRow
    for rowIndex, item in ipairs(selector.items) do
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
            r:SetBackdropColor(1, 0.8235, 0, 1)
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
                r.text:SetTextColor(0.8, 0.8, 0.8, 1)
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
            row.text:SetTextColor(0.8, 0.8, 0.8, 1)
        end
        row.text:SetJustifyH("LEFT")
        selector.dropdown.rows[rowIndex] = row
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
        popup.items.close.text:SetTextColor(1, 1, 1, 0.8)
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
    item.text:SetTextColor(1, 1, 1, 0.8)
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
        item.arrow:SetTextColor(1, 1, 1, 0.8)
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
            firstItem:SetPoint("TOPLEFT", item, "BOTTOMLEFT", 0, -3)
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
                nextItem:SetPoint("TOPLEFT", previousItem, "BOTTOMLEFT", 0, -3)
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
    return frame:IsMouseOver()
    -- local x, y = GetCursorPosition()
    -- local scale = UIParent:GetScale()
    -- local left = frame:GetLeft() * scale
    -- local right = frame:GetRight() * scale
    -- local top = frame:GetTop() * scale
    -- local bottom = frame:GetBottom() * scale
    -- if left < x and right > x and top > y and bottom < y then
    --     return true
    -- else
    --     return false
    -- end
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
    frame.title:SetTextColor(0.8, 0.8, 0.8, 1)
    frame.title:SetPoint("TOPLEFT", 5, -3)
    frame.groups = {}
    frame.IsMouseOverFrame = function ()
        return FrameBuilder.IsMouseOverFrame(frame)
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
        item.text:SetTextColor(0.8, 0.8, 0.8, 1)
    else
        item.text:SetTextColor(1, 0.8235, 0, 1)
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