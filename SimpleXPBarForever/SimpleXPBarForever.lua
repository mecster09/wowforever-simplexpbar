local addonName, ns = ...
local defaults = {
    visible = true, locked = true, trackedOnly = false, width = 680, height = 24, fontSize = 12,
    point = "CENTER", x = 0, y = -200,
    colors = {
        restedCurrent = { 0.22, 0.43, 0.69 }, unrestedCurrent = { 0.58, 0, 0.55 },
        rested = { 0.30, 0.57, 0.79 }, quest = { 0.29, 0.64, 0.30 }, overlap = { 0.31, 0.60, 0.55 },
    },
}
local settings, bar, panel, statusText
local controls = {}

local function copyDefaults(saved, source)
    if type(saved) ~= "table" then saved = {} end
    for key, value in pairs(source) do
        if type(value) == "table" then saved[key] = copyDefaults(saved[key], value)
        elseif type(saved[key]) ~= type(value) then saved[key] = value end
    end
    return saved
end

local function combat() return InCombatLockdown() end
local function questXP()
    local total, incomplete = 0, false
    local count, questCount = C_QuestLog.GetNumQuestLogEntries()
    local seen = 0
    for index = 1, count do
        local info = C_QuestLog.GetInfo(index)
        if info and not info.isHeader and info.questID then
            seen = seen + 1
            local id = info.questID
            if C_QuestLog.IsComplete(id) and (not settings.trackedOnly or C_QuestLog.GetQuestWatchType(id) ~= nil) then
                local reward = GetQuestLogRewardXP and GetQuestLogRewardXP(id)
                if type(reward) == "number" and not (issecretvalue and issecretvalue(reward)) then total = total + reward
                else incomplete = true end
            end
        elseif info and info.isHeader and info.isCollapsed then
            incomplete = true
        end
    end
    if questCount and seen < questCount then incomplete = true end
    return total, incomplete
end

local function defaultBar(show)
    if combat() then return end
    local container = MainStatusTrackingBarContainer
    if not container or (container.IsForbidden and container:IsForbidden()) or (container.IsProtected and container:IsProtected()) then return end
    if show then
        if ns.defaultAlpha then container:SetAlpha(ns.defaultAlpha); ns.defaultAlpha = nil end
    elseif ns.defaultAlpha == nil then
        ns.defaultAlpha = container:GetAlpha()
        container:SetAlpha(0)
    end
end

local function setSegment(texture, from, to, color)
    local width = settings.width * math.max(0, to - from)
    if width <= 0 then texture:Hide(); return end
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", bar, "TOPLEFT", settings.width * from, 0)
    texture:SetSize(width, settings.height)
    texture:SetColorTexture(color[1], color[2], color[3], 1)
    texture:Show()
end

local function refresh()
    if not settings then return end
    local current, maximum = UnitXP("player"), UnitXPMax("player")
    local rested = GetXPExhaustion() or 0
    if issecretvalue and (issecretvalue(current) or issecretvalue(maximum) or issecretvalue(rested)) then return end
    local visible = settings.visible and maximum and maximum > 0
    if not visible then bar:Hide(); defaultBar(true); return end
    bar:Show()
    defaultBar(false)
    local quests, incomplete = questXP()
    local p = ns.project(current, maximum, rested, quests)
    local colors = settings.colors
    setSegment(bar.current, 0, p.current, rested > 0 and colors.restedCurrent or colors.unrestedCurrent)
    setSegment(bar.rested, p.current, p.restedEnd, colors.rested)
    setSegment(bar.quest, p.current, p.questEnd, colors.quest)
    setSegment(bar.overlap, p.current, p.overlapEnd, colors.overlap)
    bar.text:SetFormattedText("XP %s / %s (%.1f%%)   |cff82c6ffRested %s|r   |cff83e581Quests %s%s|r", BreakUpLargeNumbers(current), BreakUpLargeNumbers(maximum), 100 * current / maximum, BreakUpLargeNumbers(rested), BreakUpLargeNumbers(quests), incomplete and " (incomplete)" or "")
end

local function applySettings()
    bar:SetSize(settings.width, settings.height)
    bar:ClearAllPoints()
    bar:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y)
    local font = GameFontNormal:GetFont()
    bar.text:SetFont(font, settings.fontSize, "OUTLINE")
    bar:EnableMouse(not settings.locked and not combat())
    refresh()
end

local function createBar()
    bar = CreateFrame("Frame", addonName .. "Frame", UIParent, "BackdropTemplate")
    bar:SetMovable(true); bar:SetClampedToScreen(true); bar:RegisterForDrag("LeftButton")
    bar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
    bar:SetBackdropColor(0.04, 0.04, 0.05, 0.95)
    for _, name in ipairs({ "current", "rested", "quest", "overlap" }) do bar[name] = bar:CreateTexture(nil, "ARTWORK", nil, 1) end
    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.text:SetPoint("CENTER")
    bar:SetScript("OnDragStart", function(self) if not combat() and not settings.locked then self:StartMoving() end end)
    bar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if not combat() then
            local point, _, _, x, y = self:GetPoint()
            settings.point, settings.x, settings.y = point, x, y
        end
    end)
end

local function setControlsEnabled()
    for _, control in ipairs(controls) do control:SetEnabled(not combat()) end
    if statusText then statusText:SetText(combat() and "Configuration is unavailable in combat." or "") end
    bar:EnableMouse(not combat() and not settings.locked)
end

local function createOptions()
    panel = CreateFrame("Frame", addonName .. "Options", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(460, 590); panel:SetPoint("CENTER"); panel:SetFrameStrata("DIALOG"); panel:Hide()
    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    panel.title:SetPoint("TOP", 0, -8); panel.title:SetText("Simple XP Bar Forever")
    statusText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("BOTTOM", 0, 15)
    local y = -40
    local function checkbox(label, key)
        local box = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        box:SetPoint("TOPLEFT", 24, y); y = y - 31
        box.text:SetText(label); box:SetChecked(settings[key])
        box:SetScript("OnClick", function(self)
            if combat() then self:SetChecked(settings[key]); return end
            settings[key] = self:GetChecked() and true or false; applySettings()
        end)
        box.refresh = function() box:SetChecked(settings[key]) end
        controls[#controls + 1] = box
    end
    checkbox("Show bar", "visible"); checkbox("Lock position", "locked"); checkbox("Count tracked completed quests only", "trackedOnly")
    local function slider(label, key, low, high)
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 30, y); title:SetText(label)
        local slider = CreateFrame("Slider", addonName .. key .. "Slider", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", 200, y + 2); slider:SetWidth(200); slider:SetMinMaxValues(low, high); slider:SetValueStep(1); slider:SetObeyStepOnDrag(true)
        slider:SetValue(settings[key]); y = y - 38
        slider:SetScript("OnValueChanged", function(self, value)
            if combat() then return end
            settings[key] = math.floor(value + 0.5); title:SetText(label .. ": " .. settings[key]); applySettings()
        end)
        slider.refresh = function() slider:SetValue(settings[key]); title:SetText(label .. ": " .. settings[key]) end
        controls[#controls + 1] = slider
    end
    slider("Width", "width", 300, 1200); slider("Height", "height", 12, 48); slider("Text size", "fontSize", 9, 24)
    local function colorButton(label, key)
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(190, 24); button:SetPoint("TOPLEFT", 30, y); y = y - 28; button:SetText(label)
        button:SetScript("OnClick", function()
            if combat() then return end
            local c = settings.colors[key]
            local old = { c[1], c[2], c[3] }
            ColorPickerFrame:SetupColorPickerAndShow({ r = c[1], g = c[2], b = c[3], hasOpacity = false,
                swatchFunc = function() if not combat() then c[1], c[2], c[3] = ColorPickerFrame:GetColorRGB(); refresh() end end,
                cancelFunc = function() if not combat() then c[1], c[2], c[3] = old[1], old[2], old[3]; refresh() end end })
        end)
        controls[#controls + 1] = button
    end
    colorButton("Current XP when rested", "restedCurrent"); colorButton("Current XP when unrested", "unrestedCurrent")
    colorButton("Rested projection", "rested"); colorButton("Quest projection", "quest"); colorButton("Overlap", "overlap")
    local function button(label, x, handler)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(160, 24); b:SetPoint("TOPLEFT", x, y - 8); b:SetText(label)
        b:SetScript("OnClick", function() if not combat() then handler(); applySettings(); for _, c in ipairs(controls) do if c.refresh then c.refresh() end end end end)
        controls[#controls + 1] = b
    end
    button("Reset position", 30, function() settings.point, settings.x, settings.y = defaults.point, defaults.x, defaults.y end)
    button("Reset all", 220, function() settings = copyDefaults({}, defaults); SimpleXPBarForeverDB = settings end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, arg)
    if event == "ADDON_LOADED" then
        if arg ~= addonName then return end
        settings = copyDefaults(SimpleXPBarForeverDB, defaults); SimpleXPBarForeverDB = settings
        createBar(); createOptions(); applySettings()
        for _, e in ipairs({ "PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION", "PLAYER_LEVEL_UP", "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED" }) do self:RegisterEvent(e) end
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        setControlsEnabled(); refresh()
    else refresh() end
end)
SLASH_SIMPLEXPBARFOREVER1 = "/sxp"
SLASH_SIMPLEXPBARFOREVER2 = "/simplexp"
SlashCmdList.SIMPLEXPBARFOREVER = function() if panel then panel:Show(); setControlsEnabled() end end
