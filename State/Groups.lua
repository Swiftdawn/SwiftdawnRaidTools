Groups = {
    -- Key: UUID, value = assignment group index
    active = {}
}

function Groups.SetActive(uuid, groups)
    if uuid then
        Groups.active[uuid] = groups
    end
end

function Groups.GetActive(uuid)
    return Groups.active[uuid]
end

function Groups.GetAllActive()
    return Groups.active
end

function Groups.SetAllActive(groups)
    Groups.active = groups
end

function Groups.Reset()
    Groups.active = {}
end
