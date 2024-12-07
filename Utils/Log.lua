local SwiftdawnRaidTools = SwiftdawnRaidTools
Log = {}

function Log.info(message, ...)
    SwiftdawnRaidTools:Print(message, ...)
    if SwiftdawnRaidTools.debugLog then
        SwiftdawnRaidTools.debugLog:AddItem(message, ...)
    end
end

function Log.debug(message, ...)
    if SRT_IsDebugging() then
        if ... then
            SwiftdawnRaidTools:Print("[DEBUG] "..message, type(...) == "table" and "" or ...)
        else
            SwiftdawnRaidTools:Print("[DEBUG] "..message)
        end
    end
    if SwiftdawnRaidTools.debugLog then
        SwiftdawnRaidTools.debugLog:AddItem(message, ...)
    end
end