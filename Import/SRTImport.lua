local SwiftdawnRaidTools = SwiftdawnRaidTools

SRTImport = {}

function SRTImport:ParseYAML(str)
    if str == nil or string.len(str) == 0 then
        return false
    end

    local ok, result = SwiftdawnRaidTools.YAML.evalm(str)

    if not ok then
        return false, "Error in assignment " .. result .. ":\nFailed to parse YAML."
    end

    for i, part in ipairs(result) do
        if type(part) ~= "table" then
            return false, "Error in assignment " .. i .. ":\nInvalid import."
        end
    end

    for i, part in ipairs(result) do
        local ok, result = Validation:ValidateImport(part)

        if not ok then
            return false, "Error in assignment " .. i .. ":\n" .. result
        end
    end

    for _, part in ipairs(result) do
        part.uuid = Utils:GenerateUUID()
    end

    return true, result
end

function SRTImport:AddIDs(import)
    local result = {}

    for _, part in ipairs(import) do
        if not result[part.encounter] then
            result[part.encounter] = {}
        end

        table.insert(result[part.encounter], part)
    end

    local uuid = Utils:GenerateUUID()

    return result, uuid
end
