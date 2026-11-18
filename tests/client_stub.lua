-- Minimal simulated client for public event, command and display behavior.
frames = {}
local methods = {}
local mt = { __index = function(t, key)
    if methods[key] then return methods[key] end
    return function() end
end }
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:UnregisterEvent(event) self.events[event] = nil end
function methods:SetPoint(point, relative, relativePoint, x, y) self.point, self.x, self.y = point, x, y end
function methods:GetPoint() return self.point or 'CENTER', nil, nil, self.x or 0, self.y or 0 end
function methods:SetSize(w, h) self.width, self.height = w, h end
function methods:SetWidth(w) self.width = w end
function methods:SetValue(v) self.value = v end
function methods:SetChecked(v) self.checked = v end
function methods:GetChecked() return self.checked end
function methods:SetText(t) self.value = t end
function methods:SetFormattedText(fmt, ...) self.value = string.format(fmt, ...) end
function methods:GetFont() return 'font', 12 end
function methods:Show() self.shown = true end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetAlpha(v) self.alpha = v end
function methods:GetAlpha() return self.alpha or 1 end
function methods:IsProtected() return false end
function methods:IsForbidden() return false end
local function frame(name)
    local f = setmetatable({name=name, scripts={}, events={}, shown=true}, mt)
    f.text = setmetatable({scripts={}, events={}}, mt)
    frames[#frames + 1] = f
    if name then _G[name] = f end
    return f
end
function methods:CreateTexture() return frame() end
function methods:CreateFontString() return frame() end
function CreateFrame(_, name) return frame(name) end
UIParent = frame()
GameFontNormal = frame()
SlashCmdList = {}
MainStatusTrackingBarContainer = frame()
combatState = false
function InCombatLockdown() return combatState end
xp, maxXP, restedXP, playerLevel = 4200, 10000, 2000, 10
function UnitXP() return xp end
function UnitXPMax() return maxXP end
function GetXPExhaustion() return restedXP end
function UnitLevel() return playerLevel end
function GetMaxPlayerLevel() return 60 end
function BreakUpLargeNumbers(n) return tostring(n) end
quests = {}
C_QuestLog = {}
function C_QuestLog.GetNumQuestLogEntries() return #quests, #quests end
function C_QuestLog.GetInfo(i) return quests[i] end
function C_QuestLog.IsComplete(id) for _,q in ipairs(quests) do if q.questID == id then return q.complete end end end
function C_QuestLog.GetQuestWatchType(id) for _,q in ipairs(quests) do if q.questID == id then return q.watched and 0 or nil end end end
function C_QuestLog.GetNumQuestWatches() local n=0; for _,q in ipairs(quests) do if q.watched then n=n+1 end end; return n end
function C_QuestLog.GetQuestIDForQuestWatchIndex(index) local n=0; for _,q in ipairs(quests) do if q.watched then n=n+1; if n==index then return q.questID end end end end
function GetQuestLogRewardXP(id) for _,q in ipairs(quests) do if q.questID == id then return q.reward end end end
function send(event, arg)
    for _, f in ipairs(frames) do if f.events[event] and f.scripts.OnEvent then f.scripts.OnEvent(f, event, arg) end end
end
