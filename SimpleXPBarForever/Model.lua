local _, ns = ...

function ns.project(current, maximum, rested, quests)
    if maximum <= 0 then
        return { current = 0, restedEnd = 0, questEnd = 0, overlapEnd = 0 }
    end
    local start = math.min(1, math.max(0, current / maximum))
    local restedEnd = math.min(1, math.max(start, (current + rested) / maximum))
    local questEnd = math.min(1, math.max(start, (current + quests) / maximum))
    return { current = start, restedEnd = restedEnd, questEnd = questEnd, overlapEnd = math.min(restedEnd, questEnd) }
end
