SwiftdawnRaidTools = LibStub("AceAddon-3.0"):NewAddon("SwiftdawnRaidTools", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")

local SRTDebugMode = false
local SRTTestMode = false

function SRT_IsDebugging()
    return SRTDebugMode
end

function SRT_SetDebugMode(mode)
    SRTDebugMode = mode
end

function SRT_IsTesting()
    return SRTTestMode
end

function SRT_SetTestMode(mode)
    SRTTestMode = mode
end

SwiftdawnRaidTools.PREFIX_ANNOUNCE = "SRT-SA"
SwiftdawnRaidTools.PREFIX_SYNC = "SRT-S"
SwiftdawnRaidTools.PREFIX_MAIN = "SRT-M"

SwiftdawnRaidTools.VERSION = C_AddOns.GetAddOnMetadata("SwiftdawnRaidTools", "Version")
SwiftdawnRaidTools.IS_DEV = SwiftdawnRaidTools.VERSION == '\@project-version\@'

-- AceDB defaults
SwiftdawnRaidTools.DEFAULTS = {
    profile = {
        options = {
            import = "",
        },
        data = {
            encountersProgress = nil,
            encountersId = nil,
            encounters = {}
        },
        minimap = {},
        notifications = {
            showOnlyOwnNotifications = false,
            locked = true,
            show = false,
            mute = false,
            appearance = {
                scale = 1.2,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 14,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 12,
                countdownFontType = "Friz Quadrata TT",
                countdownFontSize = 12,
                backgroundOpacity = 0.9,
                iconSize = 16
            }
        },
        overview = {
            selectedEncounterId = nil,
            locked = false,
            show = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        },
        debuglog = {
            locked = false,
            show = false,
            scrollToBottom = true,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                logFontType = "Friz Quadrata TT",
                logFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.4,
                iconSize = 14
            }
        },
        assignmenteditor = {
            anchorX = GetScreenWidth()/2,
            anchorY = -(GetScreenHeight()/2),
            locked = false,
            show = false,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.6,
                iconSize = 14
            }
        },
        rosterbuilder = {
            anchorX = GetScreenWidth()/2,
            anchorY = -(GetScreenHeight()/2),
            locked = false,
            show = false,
            appearance = {
                scale = 1.0,
                titleFontType = "Friz Quadrata TT",
                titleFontSize = 10,
                headerFontType = "Friz Quadrata TT",
                headerFontSize = 10,
                playerFontType = "Friz Quadrata TT",
                playerFontSize = 10,
                titleBarOpacity = 0.8,
                backgroundOpacity = 0.6,
                iconSize = 14
            }
        }
    },
}

function SwiftdawnRaidTools:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SwiftdawnRaidTools", self.DEFAULTS)
    
    SRTData.Initialize()
    
    if DevTool then DevTool:AddData(SpellCache, "SpellCache") end

    self:OptionsInit()
    self:MinimapInit()

    self.overview = SRTOverview:New(300, 180)
    self.overview:Initialize()

    self.notification = SRTNotification:New()
    self.notification:Initialize()

    self.debugLog = SRTDebugLog:New(100, 400)
    self.debugLog:Initialize()

    self.rosterBuilder = RosterBuilder:New()
    self.rosterBuilder:Initialize()

    self:RegisterComm(self.PREFIX_ANNOUNCE)
    self:RegisterComm(self.PREFIX_SYNC)
    self:RegisterComm(self.PREFIX_MAIN)

    print("|cffE00E00SwiftdawnRaidTools "..self.VERSION.." by Anti & Bush loaded. /srt config to open options|r")
end

function SwiftdawnRaidTools:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

    self:RegisterMessage("SRT_WA_EVENT")

    self:RegisterChatCommand("srt", "ChatHandleCommand")
end

function SwiftdawnRaidTools:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ZONE_CHANGED")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")
    self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
    self:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")

    self:UnregisterMessage("SRT_WA_EVENT")

    self:UnregisterChatCommand("srt")
end

function SwiftdawnRaidTools:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
    if isInitialLogin or isReloadingUi then
        BossInfo.Initialize()
        SyncController:SendStatus()
        if Utils:IsPlayerRaidLeader() then SyncController:ScheduleAssignmentsSync() end
    end
    self.overview:Update()
    self.debugLog:Update()
    self.rosterBuilder:Update()
end

function SwiftdawnRaidTools:SendRaidMessage(event, data, prefix, prio, callbackFn)
    -- Set defaults
    prefix = prefix or self.PREFIX_MAIN
    prio = prio or "NORMAL"
    -- Assemble payload
    local payload = {
        v = self.VERSION,
        e = event,
        d = data,
    }
    -- "Send" message directly to self if it is not SYNC
    if payload.e ~= "SYNC" then
        self:HandleMessagePayload(payload)
    end
    -- Send to raid
    if IsInRaid() then
        local message = self:Serialize(payload)
        self:SendCommMessage(prefix, message, "RAID", nil, prio, callbackFn)
    end
end

function SwiftdawnRaidTools:OnCommReceived(prefix, message, _, sender)
    if sender == UnitName("player") then
        return
    end

    if prefix == self.PREFIX_MAIN or prefix == self.PREFIX_SYNC or prefix == self.PREFIX_ANNOUNCE then
        local ok, payload = self:Deserialize(message)

        if ok then
            SyncController:SetClientVersion(sender, payload.v)
            self:HandleMessagePayload(payload, sender)
        end
    end
end

local function AcceptIncomingSyncOrNot(incomingData)
    -- If the sync coming in has a different Roster ID, accept the new roster
    if incomingData.encountersId ~= SRTData.GetActiveRosterID() then
        return true
    end
    -- If the lastUpdated is not in the payload, its coming from an old version; accept it for backward compatibility
    if not incomingData.lastUpdated then
        return true
    end
    -- If the Roster ID is the same, but the lastUpdated is higher, accept the new version
    return incomingData.lastUpdated > Roster.GetLastUpdated(SRTData.GetActiveRoster())
end

local function TriggerSyncOrNot(incomingData)
    -- If the sync coming in has a different Roster ID, trigger the sync
    if incomingData.encountersId ~= SRTData.GetActiveRosterID() then
        return true
    end
    -- If the lastUpdated is not in the payload, its coming from an old version; trigger the sync
    if not incomingData.lastUpdated then 
        return true
    end
    -- If the Roster ID is the same, but the lastUpdated is lower, trigger the sync
    return incomingData.lastUpdated < Roster.GetLastUpdated(SRTData.GetActiveRoster())
end

function SwiftdawnRaidTools:HandleMessagePayload(payload, sender)
    if payload.e == "SYNC_REQ_VERSIONS" then
        Log.debug("Received version request from "..tostring(sender), payload)
        SyncController:SendVersion()
    elseif payload.e == "SYNC_STATUS" then
        if IsEncounterInProgress() or not Utils:IsPlayerRaidLeader() then
            return
        end
        if TriggerSyncOrNot(payload.d) then
            SyncController:ScheduleAssignmentsSync()
        end
    elseif payload.e == "SYNC_ANNOUNCE" then
        if AcceptIncomingSyncOrNot(payload.d) then
            Log.debug("Assignment synchronization incoming")
            SRTData.SetActiveRosterID(nil)
            self.overview:Update()
        end
    elseif payload.e == "SYNC" then
        if AcceptIncomingSyncOrNot(payload.d) then
            Log.debug("Received assignment synchronization from "..tostring(sender), payload)
            SRTData.SetActiveRosterID(payload.d.encountersId)
            local parsedRoster = Roster.Parse(payload.d.encounters, "Received Roster", payload.d.lastUpdated, Utils:GetFullSenderName(sender))
            SRTData.AddRoster(payload.d.encountersId, parsedRoster)
            self.overview:Update()
        elseif payload.d.encountersId == SRTData.GetActiveRosterID() and payload.d.lastUpdated == Roster.GetLastUpdated(SRTData.GetActiveRoster()) then
            Log.debug("Ignoring SYNC from "..tostring(sender)..", already have this version", payload)
        else
            Log.debug("Ignoring SYNC from "..tostring(sender)..", outdated version!", payload)
        end
    elseif payload.e == "ACT_GRPS" then
        Log.debug("Received activate groups message from "..tostring(sender), payload)
        Groups.SetAllActive(payload.d)
        self.overview:UpdateActiveGroups()
    elseif payload.e == "TRIGGER" then
        Log.debug("Received assignment trigger from "..tostring(sender), payload)
        self.debugLog:AddItem(payload.d)
        Groups.SetActive(payload.d.uuid, payload.d.activeGroups)
        self.notification:ShowRaidAssignment(payload.d.uuid, payload.d.context, payload.d.delay, payload.d.countdown)
        self.notification:UpdateSpells()
    end
end

function SwiftdawnRaidTools:SRT_WA_EVENT(_, event, ...)
    if event == "WA_NUMEN_TIMER" then
        local key, countdown = ...
        AssignmentsController:HandleFojjiNumenTimer(key, countdown)
    end
end

function SwiftdawnRaidTools:ENCOUNTER_START(_, encounterID, encounterName, ...)
    self:TestModeEnd()
    self.overview:SelectEncounter(encounterID)
    self.debugLog:ClearWindow()
    AssignmentsController:StartEncounter(encounterID, encounterName)
end

function SwiftdawnRaidTools:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
    AssignmentsController:EndEncounter(encounterID, encounterName, success)
    SpellCache.Reset()
    UnitCache:ResetDeadCache()
    self.overview:UpdateSpells()
    self.notification:UpdateSpells()
end

function SwiftdawnRaidTools:ZONE_CHANGED()
    self:TestModeEnd()
    AssignmentsController:EndEncounter()
    self.overview:UpdateSpells()
    self.notification:UpdateSpells()
end

function SwiftdawnRaidTools:UNIT_HEALTH(_, unitId, ...)
    local guid = UnitGUID(unitId)

    if UnitCache:IsDead(guid) and UnitHealth(unitId) > 0 and not UnitIsGhost(unitId) then
        Log.debug(UnitName(unitId) .. " coming back to life", { guid = guid, unitId = unitId, extra = ... })
        UnitCache:SetAlive(guid)
        AssignmentsController:UpdateGroups()
        self.overview:UpdateSpells()
        self.notification:UpdateSpells()
    end

    AssignmentsController:HandleUnitHealth(unitId)
end

function SwiftdawnRaidTools:GROUP_ROSTER_UPDATE()
    self.overview:UpdateSpells()
    self.notification:UpdateSpells()

    if IsInRaid() and not self.sentRaidSync then
        self.sentRaidSync = true
        SyncController:SendStatus()
    else
        self.sentRaidSync = false
    end
end

function SwiftdawnRaidTools:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId = CombatLogGetCurrentEventInfo()
    self:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
end

function SwiftdawnRaidTools:CHAT_MSG_RAID_BOSS_EMOTE(_, text)
    AssignmentsController:HandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:CHAT_MSG_MONSTER_EMOTE(_, text, ...)
    AssignmentsController:HandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:CHAT_MSG_MONSTER_YELL(_, text, ...)
    AssignmentsController:HandleRaidBossEmote(text)
end

function SwiftdawnRaidTools:HandleCombatLog(subEvent, sourceName, destGUID, destName, spellId)
    if not IsEncounterInProgress() and not SRT_IsTesting() then
        return
    end
    if subEvent == "SPELL_CAST_START" then
        SpellCache.RegisterCastStart(sourceName, destName, spellId)
        AssignmentsController:HandleSpellCast(subEvent, spellId, sourceName, destName)
        AssignmentsController:UpdateGroups()
    elseif subEvent == "SPELL_CAST_SUCCESS" then
        SpellCache.RegisterCastSuccess(sourceName, destName, spellId, function()
            AssignmentsController:UpdateGroups()
            self.overview:UpdateSpells()
            self.notification:UpdateSpells()
        end)
        AssignmentsController:HandleSpellCast(subEvent, spellId, sourceName, destName)
    elseif subEvent == "SPELL_AURA_APPLIED" then
        SpellCache.RegisterCastSuccess(sourceName, destName, spellId, function()
            AssignmentsController:UpdateGroups()
            self.overview:UpdateSpells()
            self.notification:UpdateSpells()
        end)
        AssignmentsController:HandleSpellAura(subEvent, spellId, sourceName, destName)
    elseif subEvent == "SPELL_AURA_REMOVED" then
        SpellCache.RegisterAuraRemoved(destName, spellId)
        AssignmentsController:HandleSpellAuraRemoved(subEvent, spellId, sourceName, destName)
    elseif subEvent == "UNIT_DIED" then
        if Utils:IsFriendlyRaidMemberOrPlayer(destGUID) then
            UnitCache:SetDead(destGUID)
            AssignmentsController:UpdateGroups()
            self.overview:UpdateSpells()
            self.notification:UpdateSpells()
        end
    end
end
