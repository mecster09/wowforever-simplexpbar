-- Temporary diagnostic: compares quest IDs exposed by the active quest log.
-- It does not expand headers, select quests, or save character data.
local previous

local function snapshot()
    local entries, total = C_QuestLog.GetNumQuestLogEntries()
    local ids, visible, trackedComplete, untrackedComplete = {}, 0, 0, 0
    for i = 1, entries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and info.questID then
            ids[info.questID] = true
            visible = visible + 1
            if C_QuestLog.IsComplete(info.questID) then
                if C_QuestLog.GetQuestWatchType(info.questID) ~= nil then
                    trackedComplete = trackedComplete + 1
                else
                    untrackedComplete = untrackedComplete + 1
                end
            end
        end
    end
    return { ids = ids, visible = visible, total = total, entries = entries,
        trackedComplete = trackedComplete, untrackedComplete = untrackedComplete }
end

local function say(message)
    print("|cff73c9ffSXP Quest Probe:|r " .. message)
end

SLASH_SXPQUESTPROBE1 = "/sxpcheck"
SlashCmdList.SXPQUESTPROBE = function(message)
    if message and message:lower():match("^%s*reset%s*$") then
        previous = nil
        say("Snapshot cleared. Type /sxpcheck to take another.")
        return
    end
    local current = snapshot()
    say(("Quest entries: %d; quest IDs returned: %d; reported quest count: %s."):format(current.entries, current.visible, tostring(current.total)))
    say(("Completed quests: %d tracked, %d untracked; both modes: all=%d, tracked-only=%d."):format(
        current.trackedComplete, current.untrackedComplete,
        current.trackedComplete + current.untrackedComplete, current.trackedComplete))
    if previous then
        local missing, added = 0, 0
        for id in pairs(previous.ids) do if not current.ids[id] then missing = missing + 1 end end
        for id in pairs(current.ids) do if not previous.ids[id] then added = added + 1 end end
        say(("Since previous snapshot: %d quest IDs disappeared; %d appeared."):format(missing, added))
        if missing > 0 then say("The visible scan lost quest IDs. Collapsed sections may hide quests from this scan.")
        elseif added > 0 then say("The visible scan gained quest IDs. Compare again without accepting or turning in quests.")
        else say("The same quest IDs were returned in both snapshots.") end
    else
        say("Snapshot saved. Track or untrack a completed quest, then type /sxpcheck again.")
    end
    previous = current
end

