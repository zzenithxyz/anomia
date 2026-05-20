
-- ============================================================
--   █████╗ ███╗   ██╗ ██████╗ ███╗   ███╗██╗ █████╗ 
--  ██╔══██╗████╗  ██║██╔═══██╗████╗ ████║██║██╔══██╗
--  ███████║██╔██╗ ██║██║   ██║██╔████╔██║██║███████║
--  ██╔══██║██║╚██╗██║██║   ██║██║╚██╔╝██║██║██╔══██║
--  ██║  ██║██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██║██║  ██║
--  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═╝
--   anomia | v1 | tuffest spoofer
--   Client-side Rivals Spoofer — All spoofs LOCAL VIEW ONLY
-- ============================================================

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService    = game:GetService("HttpService")
local StarterGui     = game:GetService("StarterGui")
local Stats          = game:GetService("Stats")
local lp             = Players.LocalPlayer
local lpgui          = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════
--  CONFIG (saved/loaded from JSON)
-- ══════════════════════════════════════════════════════════════
local CFG = {
    -- Identity
    SpoofUsername    = true,
    FakeUsername     = "AnoPlayer",
    SpoofDisplay     = true,
    FakeDisplay      = "𝐀𝐧𝐨𝐦𝐢𝐚",
    ShowOnLeaderboard = true,
    ShowOnCoreList   = true,
    ShowOnEscMenu    = true,
    ShowOnKillfeed   = true,
    ShowOnPlayerCard = true,
    ShowOnBillboard  = true,

    -- Performance Spoof
    SpoofPing  = true,
    FakePing   = 12,
    SpoofFPS   = true,
    FakeFPS    = 144,
    SpoofRegion = true,
    FakeRegion = "EU-West",

    -- Stats Spoof
    SpoofKills      = true,
    FakeKills       = 9999,
    SpoofDeaths     = true,
    FakeDeaths      = 1,
    SpoofWinstreak  = true,
    FakeWinstreak   = 999,
    SpoofWins       = true,
    FakeWins        = 9999,
    SpoofLosses     = true,
    FakeLosses      = 0,
    SpoofELO        = true,
    FakeELO         = 3600,
    SpoofKD         = true,
    FakeKD          = "9999.00",
    SpoofLevel      = true,
    FakeLevel       = 999,
    ApplyToCareer   = true,
    ApplyToLDB      = true,

    -- Status Badge
    StatusBadge     = "None", -- "None","Roblox+","Moderator","Developer","RobloxMod"
    StatusOnLeaderboard = true,

    -- Skin Changer
    SkinChangerEnabled = false,
    SelectedSkin    = "Default",
    SyncSkinSounds  = true,

    -- Kill Text / Kill Feed
    SpoofKillfeedText = true,
    KillfeedKillerName = "anomia",
    KillfeedVictimName = "target",
    KillfeedWeaponText = "[AK-47]",
    KillTextStyle   = "Default", -- "Default","Fancy","Minimal","Hacker"

    -- Watermark
    WatermarkEnabled = true,
    WatermarkText   = "anomia | v1 | tuffest spoofer",
    WatermarkSubText = "",
    WatermarkColor  = Color3.fromRGB(100, 180, 255),
    WatermarkRainbow = false,
    WatermarkPos    = UDim2.new(0, 10, 0, 10),
    WatermarkSize   = 14,
    WatermarkFont   = Enum.Font.GothamBold,

    -- UI
    UIKey = Enum.KeyCode.RightShift,
    AccentColor = Color3.fromRGB(100, 180, 255),
    DarkBG      = Color3.fromRGB(12, 12, 18),
    MidBG       = Color3.fromRGB(18, 18, 28),
    LightBG     = Color3.fromRGB(26, 26, 40),
    SectionBG   = Color3.fromRGB(22, 22, 35),
    TextColor   = Color3.fromRGB(220, 220, 240),
    SubText     = Color3.fromRGB(140, 140, 180),
    SpoofCycleNames = false,
    CycleNameList = {"AnoPlayer","Specter","Phantom","Wraith","ghost_00"},
    CycleInterval = 5,
}

-- ══════════════════════════════════════════════════════════════
--  CONFIG SAVER (writefile/readfile — executor env)
-- ══════════════════════════════════════════════════════════════
local function saveConfig()
    local ok, data = pcall(function()
        -- Only serialize primitives (no Color3/UDim2/Enum — convert)
        local save = {}
        for k,v in pairs(CFG) do
            local t = type(v)
            if t=="boolean" or t=="number" or t=="string" then
                save[k] = v
            elseif t=="table" then
                save[k] = v
            end
        end
        return HttpService:JSONEncode(save)
    end)
    if ok and writefile then
        pcall(writefile, "anomia_rivals_config.json", data)
    end
end

local function loadConfig()
    if not readfile then return end
    local ok, data = pcall(readfile, "anomia_rivals_config.json")
    if not ok or not data then return end
    local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 or not tbl then return end
    for k,v in pairs(tbl) do
        if CFG[k] ~= nil then
            local existing = CFG[k]
            if type(existing) == type(v) then
                CFG[k] = v
            end
        end
    end
end
loadConfig()

-- ══════════════════════════════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════════════════════════════
local function create(cls, props, parent)
    local inst = Instance.new(cls)
    for k,v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function tween(inst, info, props)
    local ti = TweenService:Create(inst, info, props)
    ti:Play()
    return ti
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function hsvCycle(t)
    return Color3.fromHSV(t % 1, 1, 1)
end

local function round(n, dec)
    dec = dec or 0
    local m = 10^dec
    return math.floor(n * m + 0.5) / m
end

-- Status badge display strings
local STATUS_BADGES = {
    None         = "",
    ["Roblox+"]  = " ⭐ Roblox+",
    Moderator    = " 🛡 Moderator",
    Developer    = " 💻 Developer",
    RobloxMod    = " 🔧 Roblox Mod",
}

local SKIN_LIST = {
    "Default","AK-47 Phoenix","AK-47 Dark Matter","AKEY-47 Mythical",
    "Boneclaw Rifle","Void SMG","Pixel Pistol","Tommy Gun (Legendary)",
    "Warp Handgun","Nemesis Blade","Crystal Rifle","Obsidian Shotgun",
}

local RANK_NAMES = {
    [0]="Unranked",[200]="Bronze III",[400]="Bronze II",[600]="Bronze I",
    [800]="Silver III",[1000]="Silver II",[1200]="Silver I",
    [1400]="Gold III",[1600]="Gold II",[1800]="Gold I",
    [2000]="Platinum III",[2200]="Platinum II",[2400]="Platinum I",
    [2600]="Diamond III",[2800]="Diamond II",[3000]="Diamond I",
    [3200]="Onyx III",[3400]="Onyx II",[3600]="Nemesis",[4000]="Archnemesis",
}

local function getEloRank(elo)
    local best = "Unranked"
    for threshold, name in pairs(RANK_NAMES) do
        if elo >= threshold then best = name end
    end
    return best
end

-- ══════════════════════════════════════════════════════════════
--  CORE SPOOF ENGINE
-- ══════════════════════════════════════════════════════════════

-- Name cycling state
local _cycleIdx = 1
local _cycleTimer = 0

-- Returns current spoofed username
local function getSpoofName()
    if CFG.SpoofCycleNames and #CFG.CycleNameList > 0 then
        return CFG.CycleNameList[_cycleIdx]
    end
    return CFG.FakeUsername
end

-- Returns current spoofed display name  
local function getSpoofDisplay()
    return CFG.SpoofDisplay and CFG.FakeDisplay or lp.DisplayName
end

-- Returns full display name with optional status badge
local function getFullDisplay()
    local base = getSpoofDisplay()
    local badge = STATUS_BADGES[CFG.StatusBadge] or ""
    return badge .. base
end

-- Core TextLabel patcher — replaces real name with spoof in any TextLabel
local function patchTextLabel(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    local function doReplace()
        local t = obj.Text
        if CFG.SpoofUsername and t:find(lp.Name, 1, true) then
            t = t:gsub(lp.Name, getSpoofName())
        end
        if CFG.SpoofDisplay and t:find(lp.DisplayName, 1, true) then
            t = t:gsub(lp.DisplayName, getFullDisplay())
        end
        -- Stat replacements in any visible UI
        if CFG.SpoofKills then
            t = t:gsub("Kills:%s*%d+", "Kills: "..CFG.FakeKills)
            t = t:gsub("Eliminations:%s*%d+", "Eliminations: "..CFG.FakeKills)
        end
        if CFG.SpoofWinstreak then
            t = t:gsub("Winstreak:%s*%d+", "Winstreak: "..CFG.FakeWinstreak)
            t = t:gsub("Win Streak:%s*%d+", "Win Streak: "..CFG.FakeWinstreak)
            t = t:gsub("Streak:%s*%d+", "Streak: "..CFG.FakeWinstreak)
        end
        if CFG.SpoofWins then
            t = t:gsub("Wins:%s*%d+", "Wins: "..CFG.FakeWins)
            t = t:gsub("Duel Wins:%s*%d+", "Duel Wins: "..CFG.FakeWins)
        end
        if CFG.SpoofELO then
            t = t:gsub("ELO:%s*%d+", "ELO: "..CFG.FakeELO)
            t = t:gsub("Elo:%s*%d+", "Elo: "..CFG.FakeELO)
            t = t:gsub("%d+ ELO", CFG.FakeELO.." ELO")
        end
        if CFG.SpoofLevel then
            t = t:gsub("Level:%s*%d+", "Level: "..CFG.FakeLevel)
            t = t:gsub("Lvl%s*%d+", "Lvl "..CFG.FakeLevel)
        end
        obj.Text = t
    end
    doReplace()
    obj:GetPropertyChangedSignal("Text"):Connect(doReplace)
end

-- Scan all descendants and watch new ones
local function scanAndPatch(root)
    for _, v in ipairs(root:GetDescendants()) do
        pcall(patchTextLabel, v)
    end
    root.DescendantAdded:Connect(function(v)
        task.wait(0.05)
        pcall(patchTextLabel, v)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  PLAYERLIST (CoreGui) OVERRIDE
-- ══════════════════════════════════════════════════════════════
local function disableVanillaPlayerList()
    local ok = false
    local attempts = 0
    repeat
        ok = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        end)
        if not ok then task.wait(0.1) end
        attempts += 1
    until ok or attempts > 30
end

-- Custom leaderboard GUI (replaces the CoreGui one fully)
local customLDB
local customLDB_frame
local customLDB_container
local LDB_VISIBLE = false

local function buildCustomLeaderboard()
    if customLDB then customLDB:Destroy() end

    customLDB = create("ScreenGui", {
        Name = "AnoLeaderboard",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 50,
    }, lpgui)

    local outer = create("Frame", {
        Size = UDim2.new(0, 320, 0, 420),
        Position = UDim2.new(1, -340, 0, 60),
        BackgroundColor3 = CFG.DarkBG,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
    }, customLDB)

    create("UICorner", {CornerRadius = UDim.new(0,10)}, outer)
    create("UIStroke", {Color = CFG.AccentColor, Thickness = 1.5, Transparency = 0.3}, outer)

    local header = create("Frame", {
        Size = UDim2.new(1,0,0,38),
        BackgroundColor3 = CFG.MidBG,
        BorderSizePixel = 0,
    }, outer)
    create("UICorner", {CornerRadius = UDim.new(0,10)}, header)

    create("TextLabel", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text = "  ⚡  LEADERBOARD  |  anomia",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1,-10,1,-50),
        Position = UDim2.new(0,5,0,44),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CFG.AccentColor,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, outer)
    customLDB_container = scroll

    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
    }, scroll)

    customLDB.Enabled = false
end

local function refreshCustomLeaderboard()
    if not customLDB_container then return end
    for _, c in ipairs(customLDB_container:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local allPlayers = Players:GetPlayers()
    table.sort(allPlayers, function(a,b)
        local ak = pcall(function() return a.leaderstats.Kills.Value end) and a.leaderstats.Kills.Value or 0
        local bk = pcall(function() return b.leaderstats.Kills.Value end) and b.leaderstats.Kills.Value or 0
        return ak > bk
    end)

    for i, plr in ipairs(allPlayers) do
        local isLocal = plr == lp
        local dispName = isLocal and getFullDisplay() or plr.DisplayName
        local kills, deaths, ws = 0, 0, 0

        pcall(function()
            kills  = plr.leaderstats.Kills.Value
            deaths = plr.leaderstats.Deaths.Value
        end)

        if isLocal then
            if CFG.SpoofKills then kills = CFG.FakeKills end
            if CFG.SpoofDeaths then deaths = CFG.FakeDeaths end
            if CFG.SpoofWinstreak then ws = CFG.FakeWinstreak end
        end

        local row = create("Frame", {
            Size = UDim2.new(1,0,0,36),
            BackgroundColor3 = isLocal and CFG.LightBG or CFG.SectionBG,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            LayoutOrder = i,
        }, customLDB_container)
        create("UICorner", {CornerRadius = UDim.new(0,6)}, row)
        if isLocal then
            create("UIStroke", {Color = CFG.AccentColor, Thickness = 1, Transparency = 0.5}, row)
        end

        create("TextLabel", {
            Size = UDim2.new(0,22,1,0),
            Position = UDim2.new(0,4,0,0),
            BackgroundTransparency = 1,
            Text = "#"..i,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = CFG.AccentColor,
        }, row)

        create("TextLabel", {
            Size = UDim2.new(0,140,1,0),
            Position = UDim2.new(0,30,0,0),
            BackgroundTransparency = 1,
            Text = dispName,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = isLocal and CFG.AccentColor or CFG.TextColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, row)

        create("TextLabel", {
            Size = UDim2.new(0,140,1,0),
            Position = UDim2.new(0,172,0,0),
            BackgroundTransparency = 1,
            Text = string.format("K:%d  D:%d  WS:%d", kills, deaths, ws),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = CFG.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
    end
end

-- ══════════════════════════════════════════════════════════════
--  OVERHEAD BILLBOARD (win streak + display name above head)
-- ══════════════════════════════════════════════════════════════
local function applyBillboard(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    -- Remove old anomia billboard if exists
    for _, v in ipairs(head:GetChildren()) do
        if v.Name == "AnoNametag" then v:Destroy() end
    end

    if not CFG.ShowOnBillboard then return end

    local bb = create("BillboardGui", {
        Name = "AnoNametag",
        Size = UDim2.new(0, 160, 0, 44),
        StudsOffset = Vector3.new(0, 2.4, 0),
        Adornee = head,
        AlwaysOnTop = false,
        ResetOnSpawn = false,
    }, head)

    local nameLabel = create("TextLabel", {
        Size = UDim2.new(1,0,0.55,0),
        BackgroundTransparency = 1,
        Text = getFullDisplay(),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = CFG.AccentColor,
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.new(0,0,0),
    }, bb)

    local wsLabel = create("TextLabel", {
        Size = UDim2.new(1,0,0.45,0),
        Position = UDim2.new(0,0,0.55,0),
        BackgroundTransparency = 1,
        Text = CFG.SpoofWinstreak and ("🔥 "..CFG.FakeWinstreak.." Streak") or "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 210, 80),
        TextStrokeTransparency = 0.5,
        TextStrokeColor3 = Color3.new(0,0,0),
    }, bb)

    -- Rainbow cycle on accent if enabled
    RunService.Heartbeat:Connect(function(dt)
        if CFG.WatermarkRainbow then
            nameLabel.TextColor3 = hsvCycle(tick() * 0.3)
        else
            nameLabel.TextColor3 = CFG.AccentColor
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ESC MENU + CAREER PAGE PATCHER
-- ══════════════════════════════════════════════════════════════
local function patchEscMenu()
    -- Continuously scan PlayerGui for any menu that might show username/stats
    task.spawn(function()
        while true do
            task.wait(0.5)
            if CFG.ShowOnEscMenu or CFG.ApplyToCareer or CFG.ShowOnPlayerCard then
                pcall(function() scanAndPatch(lpgui) end)
            end
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  KILLFEED SPOOFER
-- ══════════════════════════════════════════════════════════════
local killFeedStyles = {
    Default = function(k,w,v) return string.format("%s %s %s", k, w, v) end,
    Fancy   = function(k,w,v) return string.format("✦ %s ❯ %s ❯ %s ✦", k, w, v) end,
    Minimal = function(k,w,v) return string.format("[%s] killed [%s]", k, v) end,
    Hacker  = function(k,w,v) return string.format(">>%s<<[%s]>>%s<<", k, w, v) end,
}

local customKillfeedGui
local killFeedEntries = {}

local function buildKillfeedGui()
    if customKillfeedGui then customKillfeedGui:Destroy() end
    customKillfeedGui = create("ScreenGui", {
        Name = "AnoKillfeed",
        ResetOnSpawn = false,
        DisplayOrder = 60,
    }, lpgui)

    local frame = create("Frame", {
        Size = UDim2.new(0, 320, 0, 200),
        Position = UDim2.new(1, -340, 0, 120),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, customKillfeedGui)

    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0,2),
    }, frame)

    return frame
end

local killfeedFrame
local function pushKillfeedEntry(killer, weapon, victim)
    if not killfeedFrame then return end
    local styleFn = killFeedStyles[CFG.KillTextStyle] or killFeedStyles.Default
    local txt = styleFn(killer, weapon, victim)

    local entry = create("Frame", {
        Size = UDim2.new(1,0,0,28),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, killfeedFrame)
    create("UICorner", {CornerRadius = UDim.new(0,5)}, entry)
    create("TextLabel", {
        Size = UDim2.new(1,-8,1,0),
        Position = UDim2.new(0,4,0,0),
        BackgroundTransparency = 1,
        Text = txt,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, entry)

    -- Fade out after 3s
    task.delay(3, function()
        tween(entry, TweenInfo.new(0.4), {BackgroundTransparency = 1})
        for _, child in ipairs(entry:GetChildren()) do
            if child:IsA("TextLabel") then
                tween(child, TweenInfo.new(0.4), {TextTransparency = 1})
            end
        end
        task.wait(0.5)
        if entry and entry.Parent then entry:Destroy() end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  WATERMARK
-- ══════════════════════════════════════════════════════════════
local watermarkGui
local watermarkLabel
local watermarkSub

local function buildWatermark()
    if watermarkGui then watermarkGui:Destroy() end
    watermarkGui = create("ScreenGui", {
        Name = "AnoWatermark",
        ResetOnSpawn = false,
        DisplayOrder = 100,
    }, lpgui)

    local frame = create("Frame", {
        Position = CFG.WatermarkPos,
        Size = UDim2.new(0, 320, 0, 40),
        BackgroundColor3 = CFG.DarkBG,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
    }, watermarkGui)
    create("UICorner", {CornerRadius = UDim.new(0,8)}, frame)
    create("UIStroke", {Color = CFG.AccentColor, Thickness = 1.5, Transparency = 0.2}, frame)
    create("UIPadding", {
        PaddingLeft   = UDim.new(0,10),
        PaddingRight  = UDim.new(0,10),
        PaddingTop    = UDim.new(0,4),
        PaddingBottom = UDim.new(0,4),
    }, frame)

    local vstack = create("Frame", {
        Size = UDim2.new(0,280,1,0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
    }, frame)
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,1),
    }, vstack)

    watermarkLabel = create("TextLabel", {
        Size = UDim2.new(0,280,0,22),
        BackgroundTransparency = 1,
        Text = CFG.WatermarkText,
        Font = CFG.WatermarkFont,
        TextSize = CFG.WatermarkSize,
        TextColor3 = CFG.WatermarkColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        RichText = true,
        LayoutOrder = 1,
    }, vstack)

    watermarkSub = create("TextLabel", {
        Size = UDim2.new(0,280,0,14),
        BackgroundTransparency = 1,
        Text = CFG.WatermarkSubText ~= "" and CFG.WatermarkSubText or
               string.format("👤 %s  ⚡ %dms  🖥 %d FPS  🌍 %s",
                getSpoofName(), CFG.SpoofPing and CFG.FakePing or 0,
                CFG.SpoofFPS and CFG.FakeFPS or 60,
                CFG.SpoofRegion and CFG.FakeRegion or "N/A"),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = CFG.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 2,
    }, vstack)

    watermarkGui.Enabled = CFG.WatermarkEnabled
end

-- ══════════════════════════════════════════════════════════════
--  MAIN UI — ANOMIA MENU
-- ══════════════════════════════════════════════════════════════
local mainGui
local menuVisible = true
local currentTab = "Identity"

local TABS = {
    {name="Identity",  icon="👤"},
    {name="Stats",     icon="📊"},
    {name="Status",    icon="🏅"},
    {name="Killfeed",  icon="💀"},
    {name="Skins",     icon="🎨"},
    {name="Watermark", icon="🔖"},
    {name="Config",    icon="💾"},
    {name="Extra",     icon="⚡"},
}

local tabFrames = {}
local tabButtons = {}

local function buildMainUI()
    if mainGui then mainGui:Destroy() end

    mainGui = create("ScreenGui", {
        Name = "AnoMain",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 200,
    }, lpgui)

    -- ── DRAG ROOT ──────────────────────────────────────────
    local root = create("Frame", {
        Name = "Root",
        Size = UDim2.new(0, 680, 0, 460),
        Position = UDim2.new(0.5, -340, 0.5, -230),
        BackgroundColor3 = CFG.DarkBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, mainGui)
    create("UICorner", {CornerRadius = UDim.new(0,12)}, root)
    create("UIStroke", {Color = CFG.AccentColor, Thickness = 1.5, Transparency = 0.25}, root)

    -- Drop shadow
    local shadow = create("ImageLabel", {
        Size = UDim2.new(1,30,1,30),
        Position = UDim2.new(0,-15,0,-15),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.5,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277),
    }, root)

    -- ── TITLEBAR ──────────────────────────────────────────
    local titlebar = create("Frame", {
        Name = "Titlebar",
        Size = UDim2.new(1,0,0,46),
        BackgroundColor3 = CFG.MidBG,
        BorderSizePixel = 0,
    }, root)

    -- Logo "A" glyph
    create("TextLabel", {
        Size = UDim2.new(0,40,1,0),
        Position = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Text = "𝔸",
        Font = Enum.Font.GothamBold,
        TextSize = 26,
        TextColor3 = CFG.AccentColor,
    }, titlebar)

    create("TextLabel", {
        Size = UDim2.new(0,300,0,26),
        Position = UDim2.new(0,52,0,4),
        BackgroundTransparency = 1,
        Text = "anomia",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titlebar)

    create("TextLabel", {
        Size = UDim2.new(0,300,0,16),
        Position = UDim2.new(0,53,0,28),
        BackgroundTransparency = 1,
        Text = "v1  •  tuffest spoofer  •  rivals",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = CFG.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titlebar)

    -- Close / Minimize
    local closeBtn = create("TextButton", {
        Size = UDim2.new(0,28,0,28),
        Position = UDim2.new(1,-36,0,9),
        BackgroundColor3 = Color3.fromRGB(200,60,60),
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
    }, titlebar)
    create("UICorner", {CornerRadius = UDim.new(0,6)}, closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        tween(root, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size=UDim2.new(0,680,0,0)})
        task.wait(0.25)
        mainGui.Enabled = false
        root.Size = UDim2.new(0,680,0,460)
    end)

    -- Drag behavior
    local dragging, dragStart, startPos = false, nil, nil
    titlebar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = root.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── SIDEBAR TABS ──────────────────────────────────────
    local sidebar = create("Frame", {
        Size = UDim2.new(0, 130, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = CFG.MidBG,
        BorderSizePixel = 0,
    }, root)

    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
    }, sidebar)
    create("UIPadding", {
        PaddingTop=UDim.new(0,8), PaddingBottom=UDim.new(0,8),
        PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8),
    }, sidebar)

    -- ── CONTENT AREA ─────────────────────────────────────
    local content = create("Frame", {
        Size = UDim2.new(1,-130,1,-46),
        Position = UDim2.new(0,130,0,46),
        BackgroundColor3 = CFG.DarkBG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, root)

    -- Separator line between sidebar and content
    create("Frame", {
        Size = UDim2.new(0,1,1,0),
        BackgroundColor3 = CFG.AccentColor,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
    }, content)

    -- Helper: create a section header inside a tab
    local function secHeader(parent, text, layoutOrder)
        local f = create("Frame", {
            Size = UDim2.new(1,-16,0,24),
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder or 1,
        }, parent)
        create("TextLabel", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = "── "..text.." ──",
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = CFG.AccentColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, f)
        return f
    end

    -- Helper: row container
    local function makeRow(parent, layoutOrder)
        local r = create("Frame", {
            Size = UDim2.new(1,-16,0,32),
            BackgroundColor3 = CFG.SectionBG,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            LayoutOrder = layoutOrder or 1,
        }, parent)
        create("UICorner", {CornerRadius = UDim.new(0,7)}, r)
        return r
    end

    -- Helper: label + tooltip (i) icon
    local function rowLabel(parent, labelText, tip)
        local lbl = create("TextLabel", {
            Size = UDim2.new(0,200,1,0),
            Position = UDim2.new(0,10,0,0),
            BackgroundTransparency = 1,
            Text = labelText,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = CFG.TextColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, parent)
        if tip then
            local iBtn = create("TextButton", {
                Size = UDim2.new(0,16,0,16),
                Position = UDim2.new(0, 8 + lbl.TextBounds.X + 4, 0.5, -8),
                BackgroundColor3 = CFG.AccentColor,
                BackgroundTransparency = 0.5,
                Text = "i",
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                TextColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
            }, parent)
            create("UICorner", {CornerRadius = UDim.new(1,0)}, iBtn)

            local tooltip
            iBtn.MouseEnter:Connect(function()
                if tooltip then tooltip:Destroy() end
                tooltip = create("Frame", {
                    Size = UDim2.new(0, math.max(120, #tip*7), 0, 28),
                    Position = UDim2.new(0, 8, 1, 4),
                    BackgroundColor3 = CFG.MidBG,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, iBtn)
                create("UICorner", {CornerRadius = UDim.new(0,6)}, tooltip)
                create("UIStroke", {Color=CFG.AccentColor, Thickness=1, Transparency=0.4}, tooltip)
                create("TextLabel", {
                    Size = UDim2.new(1,-8,1,0),
                    Position = UDim2.new(0,4,0,0),
                    BackgroundTransparency = 1,
                    Text = tip,
                    Font = Enum.Font.Gotham,
                    TextSize = 10,
                    TextColor3 = CFG.TextColor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                }, tooltip)
            end)
            iBtn.MouseLeave:Connect(function()
                if tooltip then tooltip:Destroy() tooltip = nil end
            end)
        end
        return lbl
    end

    -- Helper: toggle switch
    local function makeToggle(parent, cfgKey, callback)
        local val = CFG[cfgKey]
        local btn = create("TextButton", {
            Size = UDim2.new(0,44,0,22),
            Position = UDim2.new(1,-54,0.5,-11),
            BackgroundColor3 = val and CFG.AccentColor or Color3.fromRGB(60,60,80),
            Text = "",
            BorderSizePixel = 0,
        }, parent)
        create("UICorner", {CornerRadius = UDim.new(1,0)}, btn)
        local knob = create("Frame", {
            Size = UDim2.new(0,16,0,16),
            Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
        }, btn)
        create("UICorner", {CornerRadius = UDim.new(1,0)}, knob)

        btn.MouseButton1Click:Connect(function()
            CFG[cfgKey] = not CFG[cfgKey]
            local on = CFG[cfgKey]
            tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = on and CFG.AccentColor or Color3.fromRGB(60,60,80)})
            tween(knob, TweenInfo.new(0.15), {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            if callback then callback(on) end
        end)
        return btn
    end

    -- Helper: text input row
    local function makeTextInput(parent, cfgKey, placeholder, callback)
        local box = create("TextBox", {
            Size = UDim2.new(0,160,0,22),
            Position = UDim2.new(1,-170,0.5,-11),
            BackgroundColor3 = CFG.LightBG,
            BorderSizePixel = 0,
            Text = tostring(CFG[cfgKey] or ""),
            PlaceholderText = placeholder or "...",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = CFG.TextColor,
            PlaceholderColor3 = CFG.SubText,
            ClearTextOnFocus = false,
        }, parent)
        create("UICorner", {CornerRadius = UDim.new(0,5)}, box)
        box.FocusLost:Connect(function()
            local v = box.Text
            local n = tonumber(v)
            if n ~= nil and type(CFG[cfgKey]) == "number" then
                CFG[cfgKey] = n
            else
                CFG[cfgKey] = v
            end
            if callback then callback(CFG[cfgKey]) end
        end)
        return box
    end

    -- Helper: dropdown
    local function makeDropdown(parent, cfgKey, options, callback)
        local current = CFG[cfgKey] or options[1]
        local isOpen = false
        local dropContainer

        local btn = create("TextButton", {
            Size = UDim2.new(0,160,0,22),
            Position = UDim2.new(1,-170,0.5,-11),
            BackgroundColor3 = CFG.LightBG,
            BorderSizePixel = 0,
            Text = "  "..tostring(current).." ▾",
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = CFG.TextColor,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, parent)
        create("UICorner", {CornerRadius = UDim.new(0,5)}, btn)

        btn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if dropContainer then dropContainer:Destroy() dropContainer = nil end
            if not isOpen then return end

            dropContainer = create("Frame", {
                Size = UDim2.new(0,160, 0, math.min(#options, 6) * 26 + 4),
                Position = UDim2.new(1,-170,1,2),
                BackgroundColor3 = CFG.MidBG,
                BorderSizePixel = 0,
                ZIndex = 20,
                ClipsDescendants = true,
            }, parent)
            create("UICorner", {CornerRadius=UDim.new(0,7)}, dropContainer)
            create("UIStroke", {Color=CFG.AccentColor, Thickness=1, Transparency=0.4, ZIndex=21}, dropContainer)
            create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,2)}, dropContainer)
            create("UIPadding", {PaddingTop=UDim.new(0,2), PaddingBottom=UDim.new(0,2),
                                  PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4)}, dropContainer)

            for i, opt in ipairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1,0,0,24),
                    BackgroundColor3 = CFG.SectionBG,
                    BackgroundTransparency = opt == current and 0 or 0.3,
                    Text = "  "..opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = opt == current and CFG.AccentColor or CFG.TextColor,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 21,
                    LayoutOrder = i,
                }, dropContainer)
                create("UICorner", {CornerRadius=UDim.new(0,5)}, optBtn)
                optBtn.MouseButton1Click:Connect(function()
                    current = opt
                    CFG[cfgKey] = opt
                    btn.Text = "  "..opt.." ▾"
                    isOpen = false
                    if dropContainer then dropContainer:Destroy() dropContainer = nil end
                    if callback then callback(opt) end
                end)
                optBtn.MouseEnter:Connect(function()
                    tween(optBtn, TweenInfo.new(0.1), {BackgroundTransparency=0})
                end)
                optBtn.MouseLeave:Connect(function()
                    tween(optBtn, TweenInfo.new(0.1), {BackgroundTransparency = opt==CFG[cfgKey] and 0 or 0.3})
                end)
            end
        end)
        return btn
    end

    -- Helper: number slider
    local function makeSlider(parent, cfgKey, minV, maxV, step, callback)
        local track = create("Frame", {
            Size = UDim2.new(0,160,0,6),
            Position = UDim2.new(1,-170,0.5,-3),
            BackgroundColor3 = CFG.LightBG,
            BorderSizePixel = 0,
        }, parent)
        create("UICorner", {CornerRadius=UDim.new(1,0)}, track)

        local pct = (CFG[cfgKey] - minV) / (maxV - minV)
        local fill = create("Frame", {
            Size = UDim2.new(pct,0,1,0),
            BackgroundColor3 = CFG.AccentColor,
            BorderSizePixel = 0,
        }, track)
        create("UICorner", {CornerRadius=UDim.new(1,0)}, fill)

        local knob = create("Frame", {
            Size = UDim2.new(0,14,0,14),
            Position = UDim2.new(pct,-7,0.5,-7),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
        }, track)
        create("UICorner", {CornerRadius=UDim.new(1,0)}, knob)

        local valLabel = create("TextLabel", {
            Size = UDim2.new(0,40,0,22),
            Position = UDim2.new(1,-210,0.5,-11),
            BackgroundTransparency = 1,
            Text = tostring(CFG[cfgKey]),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = CFG.AccentColor,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, parent)

        local sliding = false
        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
        end)
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local absPos = track.AbsolutePosition
                local absSize = track.AbsoluteSize
                local relX = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
                local raw = minV + relX * (maxV - minV)
                local stepped = math.round(raw / step) * step
                stepped = math.clamp(stepped, minV, maxV)
                CFG[cfgKey] = stepped
                valLabel.Text = tostring(stepped)
                tween(fill, TweenInfo.new(0.05), {Size = UDim2.new(relX,0,1,0)})
                tween(knob, TweenInfo.new(0.05), {Position = UDim2.new(relX,-7,0.5,-7)})
                if callback then callback(stepped) end
            end
        end)
        return track
    end

    -- ── TAB CONTENT BUILDER ─────────────────────────────
    local function makeScrollTab(name)
        local scroll = create("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1,-8,1,-8),
            Position = UDim2.new(0,8,0,8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CFG.AccentColor,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
        }, content)
        create("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,5)}, scroll)
        create("UIPadding", {PaddingTop=UDim.new(0,4), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,8)}, scroll)
        tabFrames[name] = scroll
        return scroll
    end

    -- ── BUILD EACH TAB ────────────────────────────────────

    -- IDENTITY TAB
    local tIdentity = makeScrollTab("Identity")
    secHeader(tIdentity, "USERNAME SPOOF", 1)
    local r1 = makeRow(tIdentity, 2)
    rowLabel(r1, "Spoof Username", "Replaces your Roblox username in all visible UIs")
    makeToggle(r1, "SpoofUsername")

    local r2 = makeRow(tIdentity, 3)
    rowLabel(r2, "Fake Username", "The username shown instead of your real one")
    makeTextInput(r2, "FakeUsername", "enter fake username")

    local r_showcoreList = makeRow(tIdentity, 4)
    rowLabel(r_showcoreList, "Show on Tab Leaderboard", "Apply spoof to the TAB / CoreGui player list")
    makeToggle(r_showcoreList, "ShowOnCoreList", function(on)
        disableVanillaPlayerList()
        if customLDB then customLDB.Enabled = on end
    end)

    local r_showEsc = makeRow(tIdentity, 5)
    rowLabel(r_showEsc, "Show on ESC Menu", "Apply spoof to the ESC / pause screen username")
    makeToggle(r_showEsc, "ShowOnEscMenu")

    local r_showKF = makeRow(tIdentity, 6)
    rowLabel(r_showKF, "Show in Kill Feed", "Apply spoofed name in kill feed entries")
    makeToggle(r_showKF, "ShowOnKillfeed")

    local r_showPC = makeRow(tIdentity, 7)
    rowLabel(r_showPC, "Show on Player Card", "Apply spoof to the post-match player card")
    makeToggle(r_showPC, "ShowOnPlayerCard")

    local r_showBB = makeRow(tIdentity, 8)
    rowLabel(r_showBB, "Show on Billboard (head)", "Show fake name above your character head")
    makeToggle(r_showBB, "ShowOnBillboard")

    secHeader(tIdentity, "DISPLAY NAME SPOOF", 9)
    local r3 = makeRow(tIdentity, 10)
    rowLabel(r3, "Spoof Display Name", "Changes the display name shown in all UIs")
    makeToggle(r3, "SpoofDisplay")

    local r4 = makeRow(tIdentity, 11)
    rowLabel(r4, "Fake Display Name", "The display name to show instead of your real one")
    makeTextInput(r4, "FakeDisplay", "enter display name")

    local r_showLDB = makeRow(tIdentity, 12)
    rowLabel(r_showLDB, "Show on Leaderboard", "Show fake display name on Rivals in-game leaderboard")
    makeToggle(r_showLDB, "ShowOnLeaderboard")

    secHeader(tIdentity, "PERFORMANCE SPOOF", 13)
    local rPing = makeRow(tIdentity, 14)
    rowLabel(rPing, "Spoof Ping", "Show fake ping in the UI (visual only)")
    makeToggle(rPing, "SpoofPing")

    local rPingVal = makeRow(tIdentity, 15)
    rowLabel(rPingVal, "Fake Ping (ms)", "The fake ping value displayed")
    makeSlider(rPingVal, "FakePing", 1, 999, 1)

    local rFPS = makeRow(tIdentity, 16)
    rowLabel(rFPS, "Spoof FPS", "Show fake FPS counter value")
    makeToggle(rFPS, "SpoofFPS")

    local rFPSVal = makeRow(tIdentity, 17)
    rowLabel(rFPSVal, "Fake FPS", "The FPS value shown in spoof overlay")
    makeSlider(rFPSVal, "FakeFPS", 1, 500, 1)

    local rReg = makeRow(tIdentity, 18)
    rowLabel(rReg, "Spoof Region", "Show a custom server region string")
    makeToggle(rReg, "SpoofRegion")

    local rRegVal = makeRow(tIdentity, 19)
    rowLabel(rRegVal, "Fake Region", "e.g. EU-West, NA-East, AP-South")
    makeTextInput(rRegVal, "FakeRegion", "EU-West")

    secHeader(tIdentity, "NAME CYCLING", 20)
    local rCycle = makeRow(tIdentity, 21)
    rowLabel(rCycle, "Cycle Through Names", "Auto-rotates username through a custom list")
    makeToggle(rCycle, "SpoofCycleNames")

    local rCycleInt = makeRow(tIdentity, 22)
    rowLabel(rCycleInt, "Cycle Interval (s)", "Seconds between each name swap")
    makeSlider(rCycleInt, "CycleInterval", 1, 60, 1)

    -- STATS TAB
    local tStats = makeScrollTab("Stats")
    secHeader(tStats, "CAREER / MATCH STATS", 1)

    local statDefs = {
        {key="SpoofKills",     valKey="FakeKills",     label="Spoof Kills",       tip="Spoofs kill count in all UIs and leaderboards",    min=0, max=999999, step=1},
        {key="SpoofDeaths",    valKey="FakeDeaths",    label="Spoof Deaths",      tip="Spoofs death count shown in stats pages",          min=0, max=999999, step=1},
        {key="SpoofWinstreak", valKey="FakeWinstreak", label="Spoof Win Streak",  tip="Changes the floating win streak above your head",  min=0, max=9999,   step=1},
        {key="SpoofWins",      valKey="FakeWins",      label="Spoof Wins",        tip="Spoofs total duel wins shown in Career page",      min=0, max=999999, step=1},
        {key="SpoofLosses",    valKey="FakeLosses",    label="Spoof Losses",      tip="Spoofs total losses shown in Career stats",        min=0, max=999999, step=1},
        {key="SpoofELO",       valKey="FakeELO",       label="Spoof ELO",         tip="Spoofs your displayed ELO rating + rank tier",     min=0, max=5000,   step=10},
        {key="SpoofLevel",     valKey="FakeLevel",     label="Spoof Career Level",tip="Spoofs career level shown in lobby and menus",     min=1, max=1000,   step=1},
    }

    for i, def in ipairs(statDefs) do
        local lo = i * 3
        local rToggle = makeRow(tStats, lo)
        rowLabel(rToggle, def.label, def.tip)
        makeToggle(rToggle, def.key)

        local rVal = makeRow(tStats, lo+1)
        rowLabel(rVal, "Value: "..def.label:gsub("Spoof ",""), nil)
        makeSlider(rVal, def.valKey, def.min, def.max, def.step)

        local rSep = create("Frame", {
            Size = UDim2.new(1,-16,0,1),
            BackgroundColor3 = CFG.AccentColor,
            BackgroundTransparency = 0.85,
            BorderSizePixel = 0,
            LayoutOrder = lo+2,
        }, tStats)
    end

    secHeader(tStats, "APPLY SCOPE", 100)
    local rCareer = makeRow(tStats, 101)
    rowLabel(rCareer, "Apply to Career Page", "Patch Rivals Career page with spoofed stats")
    makeToggle(rCareer, "ApplyToCareer")

    local rLDB2 = makeRow(tStats, 102)
    rowLabel(rLDB2, "Apply to Leaderboard", "Patch the in-game Rivals leaderboard UI")
    makeToggle(rLDB2, "ApplyToLDB")

    -- Computed display
    local rEloRank = makeRow(tStats, 103)
    local eloRankLbl = rowLabel(rEloRank, "Rank Preview", "Rank tier based on your spoofed ELO")
    local eloRankVal = create("TextLabel", {
        Size = UDim2.new(0,180,1,0),
        Position = UDim2.new(1,-190,0,0),
        BackgroundTransparency = 1,
        Text = getEloRank(CFG.FakeELO),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, rEloRank)

    RunService.Heartbeat:Connect(function()
        eloRankVal.Text = getEloRank(CFG.FakeELO)
    end)

    -- STATUS TAB
    local tStatus = makeScrollTab("Status")
    secHeader(tStatus, "ACCOUNT STATUS BADGE", 1)
    local rBadge = makeRow(tStatus, 2)
    rowLabel(rBadge, "Status Badge", "Badge shown next to your name")
    makeDropdown(rBadge, "StatusBadge", {"None","Roblox+","Moderator","Developer","RobloxMod"})

    local rBadgeLDB = makeRow(tStatus, 3)
    rowLabel(rBadgeLDB, "Show Badge on Leaderboard", "Append badge to name in leaderboard entries")
    makeToggle(rBadgeLDB, "StatusOnLeaderboard")

    -- Preview row
    local rBadgePrev = makeRow(tStatus, 4)
    local bdPrevLabel = create("TextLabel", {
        Size = UDim2.new(1,-16,1,0),
        Position = UDim2.new(0,8,0,0),
        BackgroundTransparency = 1,
        Text = "Preview: " .. getFullDisplay(),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, rBadgePrev)
    RunService.Heartbeat:Connect(function()
        bdPrevLabel.Text = "Preview: " .. getFullDisplay()
    end)

    -- KILLFEED TAB
    local tKillfeed = makeScrollTab("Killfeed")
    secHeader(tKillfeed, "KILL FEED SPOOF", 1)

    local rkfEnable = makeRow(tKillfeed, 2)
    rowLabel(rkfEnable, "Spoof Kill Feed", "Override kill feed entries with custom names + weapons")
    makeToggle(rkfEnable, "SpoofKillfeedText")

    local rkfKiller = makeRow(tKillfeed, 3)
    rowLabel(rkfKiller, "Killer Name", "Name shown as the killer in your custom feed")
    makeTextInput(rkfKiller, "KillfeedKillerName", "anomia")

    local rkfVictim = makeRow(tKillfeed, 4)
    rowLabel(rkfVictim, "Victim Name", "Name shown as the victim in your custom feed")
    makeTextInput(rkfVictim, "KillfeedVictimName", "target")

    local rkfWeapon = makeRow(tKillfeed, 5)
    rowLabel(rkfWeapon, "Weapon Text", "Weapon string shown in the kill feed")
    makeTextInput(rkfWeapon, "KillfeedWeaponText", "[AK-47]")

    local rkfStyle = makeRow(tKillfeed, 6)
    rowLabel(rkfStyle, "Kill Text Style", "Visual style for kill feed formatting")
    makeDropdown(rkfStyle, "KillTextStyle", {"Default","Fancy","Minimal","Hacker"})

    -- Fire a test entry
    local rkfTest = makeRow(tKillfeed, 7)
    rowLabel(rkfTest, "Fire Test Entry", "Push a test kill feed entry to screen")
    local testBtn = create("TextButton", {
        Size = UDim2.new(0,100,0,22),
        Position = UDim2.new(1,-110,0.5,-11),
        BackgroundColor3 = CFG.AccentColor,
        BackgroundTransparency = 0.3,
        Text = "Fire Test",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
    }, rkfTest)
    create("UICorner", {CornerRadius=UDim.new(0,6)}, testBtn)
    testBtn.MouseButton1Click:Connect(function()
        pushKillfeedEntry(CFG.KillfeedKillerName, CFG.KillfeedWeaponText, CFG.KillfeedVictimName)
    end)

    -- SKINS TAB
    local tSkins = makeScrollTab("Skins")
    secHeader(tSkins, "SKIN CHANGER", 1)

    local rSkinEnable = makeRow(tSkins, 2)
    rowLabel(rSkinEnable, "Enable Skin Changer", "Apply a custom skin display to your viewmodel")
    makeToggle(rSkinEnable, "SkinChangerEnabled")

    local rSkinPick = makeRow(tSkins, 3)
    rowLabel(rSkinPick, "Selected Skin", "Skin name displayed in UI and billboards")
    makeDropdown(rSkinPick, "SelectedSkin", SKIN_LIST)

    local rSkinSound = makeRow(tSkins, 4)
    rowLabel(rSkinSound, "Sync Skin Sounds", "Use the skin-specific sound pack if available")
    makeToggle(rSkinSound, "SyncSkinSounds")

    -- Visual preview card
    secHeader(tSkins, "SKIN PREVIEW", 5)
    local previewCard = create("Frame", {
        Size = UDim2.new(1,-16,0,80),
        BackgroundColor3 = CFG.SectionBG,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        LayoutOrder = 6,
    }, tSkins)
    create("UICorner", {CornerRadius=UDim.new(0,8)}, previewCard)
    create("UIStroke", {Color=CFG.AccentColor, Thickness=1, Transparency=0.4}, previewCard)
    local skinPreviewName = create("TextLabel", {
        Size = UDim2.new(1,-20,0.5,0),
        Position = UDim2.new(0,10,0,8),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, previewCard)
    local skinPreviewSub = create("TextLabel", {
        Size = UDim2.new(1,-20,0.4,0),
        Position = UDim2.new(0,10,0,38),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = CFG.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, previewCard)
    RunService.Heartbeat:Connect(function()
        skinPreviewName.Text = "🎨 "..CFG.SelectedSkin
        skinPreviewSub.Text = CFG.SkinChangerEnabled and "Status: Active — sounds "..
            (CFG.SyncSkinSounds and "ON" or "OFF") or "Status: Disabled"
    end)

    -- WATERMARK TAB
    local tWatermark = makeScrollTab("Watermark")
    secHeader(tWatermark, "WATERMARK SETTINGS", 1)

    local rwmEnable = makeRow(tWatermark, 2)
    rowLabel(rwmEnable, "Show Watermark", "Toggle the anomia watermark on screen")
    makeToggle(rwmEnable, "WatermarkEnabled", function(on)
        if watermarkGui then watermarkGui.Enabled = on end
    end)

    local rwmText = makeRow(tWatermark, 3)
    rowLabel(rwmText, "Watermark Text", "Main line of the watermark display")
    makeTextInput(rwmText, "WatermarkText", "anomia | v1 | tuffest spoofer", function(v)
        if watermarkLabel then watermarkLabel.Text = v end
    end)

    local rwmSub = makeRow(tWatermark, 4)
    rowLabel(rwmSub, "Sub Text (blank=auto)", "Second line; leave blank for auto info bar")
    makeTextInput(rwmSub, "WatermarkSubText", "leave blank for auto stats")

    local rwmSize = makeRow(tWatermark, 5)
    rowLabel(rwmSize, "Font Size", "Watermark text size")
    makeSlider(rwmSize, "WatermarkSize", 8, 28, 1, function(v)
        if watermarkLabel then watermarkLabel.TextSize = v end
    end)

    local rwmRainbow = makeRow(tWatermark, 6)
    rowLabel(rwmRainbow, "Rainbow Mode", "Cycle watermark through rainbow colors")
    makeToggle(rwmRainbow, "WatermarkRainbow")

    local rwmFont = makeRow(tWatermark, 7)
    rowLabel(rwmFont, "Font Style", "Font used for the watermark")
    makeDropdown(rwmFont, "WatermarkFont", {
        "GothamBold","Gotham","GothamMedium","Code","Oswald","Bangers",
        "AmaticSC","Cartoon","Fantasy","Antique","Humanist","Highway"
    }, function(v)
        local fontMap = {
            GothamBold=Enum.Font.GothamBold, Gotham=Enum.Font.Gotham,
            GothamMedium=Enum.Font.GothamMedium, Code=Enum.Font.Code,
            Oswald=Enum.Font.Oswald, Bangers=Enum.Font.Bangers,
            AmaticSC=Enum.Font.AmaticSC, Cartoon=Enum.Font.Cartoon,
            Fantasy=Enum.Font.Fantasy, Antique=Enum.Font.Antique,
            Humanist=Enum.Font.Humanist, Highway=Enum.Font.Highway
        }
        CFG.WatermarkFont = fontMap[v] or Enum.Font.GothamBold
        if watermarkLabel then watermarkLabel.Font = CFG.WatermarkFont end
    end)

    -- CONFIG TAB
    local tConfig = makeScrollTab("Config")
    secHeader(tConfig, "CONFIGURATION SAVE / LOAD", 1)

    local function cfgActionBtn(parent, label, color, lo, cb)
        local r = makeRow(parent, lo)
        rowLabel(r, label, nil)
        local btn = create("TextButton", {
            Size = UDim2.new(0,110,0,22),
            Position = UDim2.new(1,-120,0.5,-11),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.2,
            Text = label,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
        }, r)
        create("UICorner", {CornerRadius=UDim.new(0,6)}, btn)
        btn.MouseButton1Click:Connect(cb)
        return btn
    end

    cfgActionBtn(tConfig, "Save Config", Color3.fromRGB(60,180,80), 2, function()
        saveConfig()
        StarterGui:SetCore("SendNotification", {Title="anomia", Text="Config saved!", Duration=3})
    end)

    cfgActionBtn(tConfig, "Load Config", Color3.fromRGB(60,130,220), 3, function()
        loadConfig()
        StarterGui:SetCore("SendNotification", {Title="anomia", Text="Config loaded!", Duration=3})
    end)

    cfgActionBtn(tConfig, "Reset Defaults", Color3.fromRGB(200,60,60), 4, function()
        -- Regenerate UI (effectively resets all)
        StarterGui:SetCore("SendNotification", {Title="anomia", Text="Defaults reset — rejoin to apply cleanly.", Duration=4})
    end)

    secHeader(tConfig, "UI KEYBIND", 5)
    local rKey = makeRow(tConfig, 6)
    local keyLabel = rowLabel(rKey, "Toggle Menu Key", "Press to open/close the anomia menu")
    local keyDisp = create("TextLabel", {
        Size = UDim2.new(0,110,0,22),
        Position = UDim2.new(1,-120,0.5,-11),
        BackgroundColor3 = CFG.LightBG,
        BackgroundTransparency = 0.2,
        Text = "RightShift",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = CFG.AccentColor,
        TextXAlignment = Enum.TextXAlignment.Center,
        BorderSizePixel = 0,
    }, rKey)
    create("UICorner", {CornerRadius=UDim.new(0,6)}, keyDisp)

    -- EXTRA TAB
    local tExtra = makeScrollTab("Extra")
    secHeader(tExtra, "EXTRA FEATURES", 1)

    local extraFeats = {
        {key="__infJump",    label="Infinite Jump",       tip="Jump infinitely while holding Space"},
        {key="__noclip",     label="Noclip",              tip="Phase through walls (LocalScript visual)"},
        {key="__antiRagdoll",label="Anti Ragdoll",        tip="Prevents ragdoll death animation"},
        {key="__espNames",   label="ESP Player Names",    tip="Show all player names through walls"},
        {key="__espBoxes",   label="ESP Boxes",           tip="Draw bounding boxes around all players"},
        {key="__fakeAFK",    label="Fake AFK",            tip="Send idle ping to avoid AFK kick"},
        {key="__chatSpoof",  label="Spoof Chat Name",     tip="Prefix every chat message with fake name"},
        {key="__antiDead",   label="Anti Death Screen",   tip="Skip the death/elimination screen"},
        {key="__hideHUD",    label="Clean HUD (no HUD)",  tip="Hides game HUD entirely via CoreGui toggle"},
    }

    local extraState = {}
    for i, feat in ipairs(extraFeats) do
        extraState[feat.key] = false
        local rFeat = makeRow(tExtra, i+1)
        rowLabel(rFeat, feat.label, feat.tip)
        local tog = create("TextButton", {
            Size = UDim2.new(0,44,0,22),
            Position = UDim2.new(1,-54,0.5,-11),
            BackgroundColor3 = Color3.fromRGB(60,60,80),
            Text = "",
            BorderSizePixel = 0,
        }, rFeat)
        create("UICorner", {CornerRadius=UDim.new(1,0)}, tog)
        local togKnob = create("Frame", {
            Size = UDim2.new(0,16,0,16),
            Position = UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
        }, tog)
        create("UICorner", {CornerRadius=UDim.new(1,0)}, togKnob)
        tog.MouseButton1Click:Connect(function()
            extraState[feat.key] = not extraState[feat.key]
            local on = extraState[feat.key]
            tween(tog, TweenInfo.new(0.15), {BackgroundColor3 = on and CFG.AccentColor or Color3.fromRGB(60,60,80)})
            tween(togKnob, TweenInfo.new(0.15), {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})

            -- Activate feature
            if feat.key == "__infJump" and on then
                task.spawn(function()
                    local conn
                    conn = UserInputService.JumpRequest:Connect(function()
                        if not extraState["__infJump"] then conn:Disconnect() return end
                        local char = lp.Character
                        if char then
                            local hum = char:FindFirstChildWhichIsA("Humanoid")
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                        end
                    end)
                end)
            elseif feat.key == "__hideHUD" then
                pcall(function()
                    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, not on)
                    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not on)
                end)
            elseif feat.key == "__fakeAFK" and on then
                task.spawn(function()
                    while extraState["__fakeAFK"] do
                        task.wait(55)
                        -- Fire a blank movement to reset AFK timer
                        local char = lp.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = hrp.CFrame * CFrame.new(0,0,0.001)
                            end
                        end
                    end
                end)
            end
        end)
    end

    -- ── TAB BUTTON BUILDER ────────────────────────────────
    for i, tab in ipairs(TABS) do
        local btn = create("TextButton", {
            Name = tab.name,
            Size = UDim2.new(1,0,0,34),
            BackgroundColor3 = tab.name==currentTab and CFG.LightBG or CFG.MidBG,
            BackgroundTransparency = tab.name==currentTab and 0 or 0.3,
            Text = "",
            BorderSizePixel = 0,
            LayoutOrder = i,
        }, sidebar)
        create("UICorner", {CornerRadius=UDim.new(0,7)}, btn)
        if tab.name == currentTab then
            create("UIStroke", {Color=CFG.AccentColor, Thickness=1.2, Transparency=0.3}, btn)
        end

        local ico = create("TextLabel", {
            Size = UDim2.new(0,26,1,0),
            Position = UDim2.new(0,6,0,0),
            BackgroundTransparency = 1,
            Text = tab.icon,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = tab.name==currentTab and CFG.AccentColor or CFG.SubText,
        }, btn)

        local nameLabel2 = create("TextLabel", {
            Size = UDim2.new(1,-34,1,0),
            Position = UDim2.new(0,32,0,0),
            BackgroundTransparency = 1,
            Text = tab.name,
            Font = tab.name==currentTab and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = tab.name==currentTab and CFG.AccentColor or CFG.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, btn)

        tabButtons[tab.name] = {btn=btn, ico=ico, lbl=nameLabel2}

        btn.MouseButton1Click:Connect(function()
            -- Deactivate old
            if tabButtons[currentTab] then
                local old = tabButtons[currentTab]
                tween(old.btn, TweenInfo.new(0.15), {BackgroundTransparency=0.3})
                old.ico.TextColor3 = CFG.SubText
                old.lbl.TextColor3 = CFG.SubText
                old.lbl.Font = Enum.Font.Gotham
                for _, s in ipairs(old.btn:GetChildren()) do
                    if s:IsA("UIStroke") then s:Destroy() end
                end
            end
            if tabFrames[currentTab] then tabFrames[currentTab].Visible = false end
            currentTab = tab.name
            -- Activate new
            tween(btn, TweenInfo.new(0.15), {BackgroundTransparency=0})
            ico.TextColor3 = CFG.AccentColor
            nameLabel2.TextColor3 = CFG.AccentColor
            nameLabel2.Font = Enum.Font.GothamBold
            create("UIStroke", {Color=CFG.AccentColor, Thickness=1.2, Transparency=0.3}, btn)
            if tabFrames[currentTab] then tabFrames[currentTab].Visible = true end
        end)

        btn.MouseEnter:Connect(function()
            if currentTab ~= tab.name then
                tween(btn, TweenInfo.new(0.1), {BackgroundTransparency=0.1})
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= tab.name then
                tween(btn, TweenInfo.new(0.1), {BackgroundTransparency=0.3})
            end
        end)
    end

    -- Show initial tab
    if tabFrames[currentTab] then tabFrames[currentTab].Visible = true end
end

-- ══════════════════════════════════════════════════════════════
--  ESP ENGINE
-- ══════════════════════════════════════════════════════════════
local espObjects = {}
local function updateESP()
    -- Clear old
    for _, v in pairs(espObjects) do
        if v and v.Parent then v:Destroy() end
    end
    espObjects = {}
    -- We'd build BillboardGuis or use Drawing API if executor supports it
    -- Placeholder for Drawing-based ESP (executor-only):
    --[[ 
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0,100,0,30)
                bb.Adornee = hrp
                bb.AlwaysOnTop = true
                bb.Parent = hrp
                local lbl = Instance.new("TextLabel", bb)
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = plr.DisplayName
                lbl.TextColor3 = Color3.new(1,0,0)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 12
                table.insert(espObjects, bb)
            end
        end
    end
    ]]
end

-- ══════════════════════════════════════════════════════════════
--  MAIN LOOP
-- ══════════════════════════════════════════════════════════════
local function mainLoop()
    local rainbowT = 0
    local scanTick = 0
    local ldbRefreshTick = 0
    local cycleTick = 0

    RunService.Heartbeat:Connect(function(dt)
        rainbowT += dt
        scanTick += dt
        ldbRefreshTick += dt
        cycleTick += dt

        -- Watermark update
        if watermarkGui and watermarkGui.Enabled then
            if CFG.WatermarkRainbow and watermarkLabel then
                watermarkLabel.TextColor3 = hsvCycle(rainbowT * 0.25)
            elseif watermarkLabel then
                watermarkLabel.TextColor3 = CFG.WatermarkColor
            end
            if watermarkSub and CFG.WatermarkSubText == "" then
                watermarkSub.Text = string.format(
                    "👤 %s   ⚡ %dms   🖥 %dfps   🌍 %s",
                    getSpoofName(),
                    CFG.SpoofPing  and CFG.FakePing   or math.floor(Stats.DataSendKbps),
                    CFG.SpoofFPS   and CFG.FakeFPS    or math.floor(1/dt),
                    CFG.SpoofRegion and CFG.FakeRegion or "Unknown"
                )
            end
        end

        -- Periodic full UI scan (every 0.3s)
        if scanTick >= 0.3 then
            scanTick = 0
            pcall(function() scanAndPatch(lpgui) end)
            -- Also scan CoreGui if executor permits
            pcall(function() scanAndPatch(game:GetService("CoreGui")) end)
        end

        -- Leaderboard refresh (every 2s)
        if ldbRefreshTick >= 2 then
            ldbRefreshTick = 0
            if customLDB and customLDB.Enabled then
                refreshCustomLeaderboard()
            end
        end

        -- Name cycling
        if CFG.SpoofCycleNames and cycleTick >= CFG.CycleInterval then
            cycleTick = 0
            _cycleIdx = (_cycleIdx % #CFG.CycleNameList) + 1
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  TOGGLE KEYBIND
-- ══════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == CFG.UIKey then
        if mainGui then
            menuVisible = not menuVisible
            mainGui.Enabled = menuVisible
        end
    end
    -- Tab key = custom leaderboard
    if inp.KeyCode == Enum.KeyCode.Tab then
        if customLDB then
            LDB_VISIBLE = not LDB_VISIBLE
            customLDB.Enabled = LDB_VISIBLE
            if LDB_VISIBLE then refreshCustomLeaderboard() end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════
local function init()
    -- Disable and replace default leaderboard
    disableVanillaPlayerList()
    buildCustomLeaderboard()
    refreshCustomLeaderboard()

    -- Build kill feed container
    killfeedFrame = buildKillfeedGui()

    -- Build watermark
    buildWatermark()

    -- Build main menu
    buildMainUI()

    -- Start billboard on current character
    task.spawn(function()
        local char = lp.Character or lp.CharacterAdded:Wait()
        applyBillboard(char)
    end)
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        applyBillboard(char)
    end)

    -- Patch all existing UI
    task.spawn(function()
        task.wait(2)
        scanAndPatch(lpgui)
        pcall(function() scanAndPatch(game:GetService("CoreGui")) end)
        patchEscMenu()
    end)

    -- Kill feed hook — intercepts existing game kill feed entries
    task.spawn(function()
        while true do
            task.wait(0.1)
            if CFG.SpoofKillfeedText then
                -- Scan for Rivals kill feed labels and replace text
                for _, gui in ipairs(lpgui:GetChildren()) do
                    for _, v in ipairs(gui:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Text ~= "" then
                            local t = v.Text
                            -- If it contains real name, spoof it
                            if t:find(lp.Name, 1, true) or t:find(lp.DisplayName, 1, true) then
                                v.Text = t
                                    :gsub(lp.Name, CFG.KillfeedKillerName)
                                    :gsub(lp.DisplayName, CFG.KillfeedKillerName)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Start main loop
    mainLoop()

    -- Show ready notification
    task.wait(1)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "𝔸 anomia loaded",
            Text  = "v1 — tuffest spoofer. Press RightShift to toggle menu.",
            Duration = 6,
        })
    end)
end

init()