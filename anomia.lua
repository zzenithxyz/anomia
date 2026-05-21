-- ╔══════════════════════════════════════════════════════╗
-- ║  ANOMIA  |  v2  |  RIVALS SPOOFER                   ║
-- ║  Full client-side spoofer — executor-injected        ║
-- ╚══════════════════════════════════════════════════════╝

-- ┌─────────────────────────────────────────────────────┐
--   SERVICES
-- └─────────────────────────────────────────────────────┘
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UIS              = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local CoreGui          = game:GetService("CoreGui")

local lp    = Players.LocalPlayer
local lpgui = lp:WaitForChild("PlayerGui")

-- ┌─────────────────────────────────────────────────────┐
--   THEMES
-- └─────────────────────────────────────────────────────┘
local THEMES = {
    Dark = {
        Root        = Color3.fromRGB(9,  11, 18),
        Sidebar     = Color3.fromRGB(6,   8, 14),
        Content     = Color3.fromRGB(11, 13, 21),
        Card        = Color3.fromRGB(16, 18, 29),
        CardHover   = Color3.fromRGB(21, 23, 36),
        Accent      = Color3.fromRGB(92, 165, 255),
        AccentDim   = Color3.fromRGB(50,  95, 175),
        TextPri     = Color3.fromRGB(228, 231, 242),
        TextSec     = Color3.fromRGB(100, 107, 138),
        Border      = Color3.fromRGB(22,  25, 40),
        Logo        = Color3.fromRGB(255, 255, 255),
        Toggle_OFF  = Color3.fromRGB(38,  40, 58),
        Toggle_ON   = Color3.fromRGB(92, 165, 255),
        Watermark   = Color3.fromRGB(9,  11, 18),
    },
    Light = {
        Root        = Color3.fromRGB(246, 247, 252),
        Sidebar     = Color3.fromRGB(234, 236, 246),
        Content     = Color3.fromRGB(251, 252, 255),
        Card        = Color3.fromRGB(255, 255, 255),
        CardHover   = Color3.fromRGB(240, 242, 252),
        Accent      = Color3.fromRGB(55,  125, 225),
        AccentDim   = Color3.fromRGB(30,   80, 175),
        TextPri     = Color3.fromRGB(16,  18,  30),
        TextSec     = Color3.fromRGB(100, 108, 135),
        Border      = Color3.fromRGB(210, 214, 230),
        Logo        = Color3.fromRGB(10,  12,  22),
        Toggle_OFF  = Color3.fromRGB(200, 204, 220),
        Toggle_ON   = Color3.fromRGB(55,  125, 225),
        Watermark   = Color3.fromRGB(246, 247, 252),
    },
}

-- ┌─────────────────────────────────────────────────────┐
--   CONFIG
-- └─────────────────────────────────────────────────────┘
local CFG = {
    -- Identity
    SpoofUsername     = true,
    FakeUsername      = "AnoPlayer",
    SpoofDisplay      = true,
    FakeDisplay       = "anomia",
    ShowOnBillboard   = true,
    ShowOnKillfeed    = true,
    CycleNames        = false,
    CycleList         = {"AnoPlayer","specter","wraith","phantom","null_0"},
    CycleInterval     = 8,

    -- Perf display
    SpoofPing         = true,  FakePing   = 9,
    SpoofFPS          = true,  FakeFPS    = 240,
    SpoofRegion       = true,  FakeRegion = "EU-West",

    -- Stats
    SpoofKills        = true,  FakeKills       = 9999,
    SpoofDeaths       = true,  FakeDeaths      = 1,
    SpoofStreak       = true,  FakeStreak      = 999,
    SpoofWins         = true,  FakeWins        = 9999,
    SpoofLosses       = true,  FakeLosses      = 0,
    SpoofELO          = true,  FakeELO         = 3800,
    SpoofLevel        = true,  FakeLevel       = 999,
    ApplyToCareer     = true,
    ApplyToLDB        = true,

    -- Rank season spoofer
    RankSpoofEnabled  = false,
    RankSeason        = "Season 2",
    RankTier          = "Nemesis",

    -- Status badge
    StatusBadge       = "None",

    -- Skin / cosmetic unlock
    SkinUnlockAll     = false,
    WrapUnlockAll     = false,
    CharmUnlockAll    = false,
    SelectedSkin      = "Default",

    -- Kill feed
    SpoofKillfeed     = true,
    KFKiller          = "anomia",
    KFVictim          = "target",
    KFWeapon          = "AK-47",
    KFStyle           = "Clean",

    -- Watermark
    WMEnabled         = true,
    WMText            = "anomia  |  v2",
    WMSubAuto         = true,
    WMSubText         = "",
    WMRainbow         = false,
    WMSize            = 13,

    -- UI
    Theme             = "Dark",
    MenuKey           = "RightShift",
    MenuKey2          = "",          -- optional second key
    ConfigCycleKey    = "F8",
    ConfigCycleKey2   = "",
    ConfigSlot        = 1,

    -- Extra
    InfJump           = false,
    Noclip            = false,
    FakeAFK           = false,
    AntiDead          = false,
    CleanHUD          = false,
    ESPNames          = false,
}

-- Active theme reference (updated when theme changes)
local T = THEMES[CFG.Theme]
local function refreshTheme() T = THEMES[CFG.Theme] end

-- ┌─────────────────────────────────────────────────────┐
--   CONFIG SAVE / LOAD  (writefile/readfile — executor)
-- └─────────────────────────────────────────────────────┘
local CONFIG_FILE = "anomia_rivals_v2_slot"

local function saveSlot(slot)
    if not writefile then return end
    local out = {}
    for k,v in pairs(CFG) do
        local t = type(v)
        if t=="boolean" or t=="number" or t=="string" or t=="table" then
            out[k] = v
        end
    end
    pcall(writefile, CONFIG_FILE..slot..".json", HttpService:JSONEncode(out))
end

local function loadSlot(slot)
    if not readfile then return end
    local ok, raw = pcall(readfile, CONFIG_FILE..slot..".json")
    if not ok or not raw then return end
    local ok2, tbl = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or not tbl then return end
    for k,v in pairs(tbl) do
        if CFG[k] ~= nil and type(CFG[k]) == type(v) then CFG[k] = v end
    end
    refreshTheme()
end

loadSlot(CFG.ConfigSlot)

-- ┌─────────────────────────────────────────────────────┐
--   UTILITY
-- └─────────────────────────────────────────────────────┘
local TI_FAST   = TweenInfo.new(0.18, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_MED    = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_SLOW   = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tw(inst, ti, props) TweenService:Create(inst,ti,props):Play() end

local function new(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do i[k]=v end
    if parent then i.Parent=parent end
    return i
end

local function corner(r, parent)
    return new("UICorner",{CornerRadius=UDim.new(0,r)},parent)
end

local function stroke(col, thickness, trans, parent)
    return new("UIStroke",{Color=col,Thickness=thickness,Transparency=trans or 0},parent)
end

local function pad(t,b,l,r, parent)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),
        PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)
    }, parent)
end

local function hsvCycle(t) return Color3.fromHSV(t%1,0.85,1) end

local RANK_TABLE = {
    [0]="Unranked",   [200]="Bronze III", [400]="Bronze II",  [600]="Bronze I",
    [800]="Silver III",[1000]="Silver II",[1200]="Silver I",
    [1400]="Gold III", [1600]="Gold II",  [1800]="Gold I",
    [2000]="Plat III", [2200]="Plat II",  [2400]="Plat I",
    [2600]="Diamond III",[2800]="Diamond II",[3000]="Diamond I",
    [3200]="Onyx III", [3400]="Onyx II",  [3600]="Nemesis",
    [4000]="Archnemesis",
}
local function eloToRank(e)
    local best,bv = "Unranked", 0
    for threshold,name in pairs(RANK_TABLE) do
        if e>=threshold and threshold>=bv then best=name;bv=threshold end
    end
    return best
end

local BADGE_STR = {
    None="", ["Roblox+"]="[R+] ", Moderator="[MOD] ",
    Developer="[DEV] ", RobloxMod="[RBLX] ",
}

local function spoofName()
    if CFG.CycleNames and #CFG.CycleList>0 then
        return CFG.CycleList[1]
    end
    return CFG.FakeUsername
end

local function spoofDisplay()
    local badge = BADGE_STR[CFG.StatusBadge] or ""
    return badge .. (CFG.SpoofDisplay and CFG.FakeDisplay or lp.DisplayName)
end

-- ┌─────────────────────────────────────────────────────┐
--   PERFORMANCE-SAFE SPOOF ENGINE
--   No polling loops — purely event-driven.
--   Central patcher called only on DescendantAdded.
-- └─────────────────────────────────────────────────────┘
local patchedLabels = {}   -- weak set to avoid re-patching
setmetatable(patchedLabels, {__mode="k"})

local STAT_PATTERNS = {
    -- {find pattern, replace function}
    {"Kills:%s*(%d+)",        function() return "Kills: "..CFG.FakeKills         end, "SpoofKills"},
    {"Eliminations:%s*(%d+)", function() return "Eliminations: "..CFG.FakeKills  end, "SpoofKills"},
    {"Deaths:%s*(%d+)",       function() return "Deaths: "..CFG.FakeDeaths       end, "SpoofDeaths"},
    {"Winstreak:%s*(%d+)",    function() return "Winstreak: "..CFG.FakeStreak    end, "SpoofStreak"},
    {"Win Streak:%s*(%d+)",   function() return "Win Streak: "..CFG.FakeStreak   end, "SpoofStreak"},
    {"Streak:%s*(%d+)",       function() return "Streak: "..CFG.FakeStreak       end, "SpoofStreak"},
    {"Wins:%s*(%d+)",         function() return "Wins: "..CFG.FakeWins           end, "SpoofWins"},
    {"Duel Wins:%s*(%d+)",    function() return "Duel Wins: "..CFG.FakeWins      end, "SpoofWins"},
    {"Losses:%s*(%d+)",       function() return "Losses: "..CFG.FakeLosses       end, "SpoofLosses"},
    {"ELO:%s*(%d+)",          function() return "ELO: "..CFG.FakeELO             end, "SpoofELO"},
    {"Elo:%s*(%d+)",          function() return "Elo: "..CFG.FakeELO             end, "SpoofELO"},
    {"%d+ ELO",               function() return CFG.FakeELO.." ELO"             end, "SpoofELO"},
    {"Level:%s*(%d+)",        function() return "Level: "..CFG.FakeLevel         end, "SpoofLevel"},
    {"Lvl%s*(%d+)",           function() return "Lvl "..CFG.FakeLevel            end, "SpoofLevel"},
    -- Rank tier names
    {"Bronze%s*[III|II|I]*",  function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Silver%s*[III|II|I]*",  function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Gold%s*[III|II|I]*",    function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Platinum%s*[III|II|I]*",function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Diamond%s*[III|II|I]*", function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Onyx%s*[III|II|I]*",    function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Nemesis",               function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Archnemesis",           function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
    {"Unranked",              function() return CFG.RankSpoofEnabled and CFG.RankTier or nil end, "RankSpoofEnabled"},
}

local function applySpoof(label)
    local original = label.Text
    local t = original

    -- Name spoofs
    if CFG.SpoofUsername and lp.Name ~= "" then
        t = t:gsub(lp.Name, spoofName())
    end
    if CFG.SpoofDisplay and lp.DisplayName ~= "" then
        t = t:gsub(lp.DisplayName, spoofDisplay())
    end

    -- Stat spoofs
    for _, def in ipairs(STAT_PATTERNS) do
        local pat, repFn, cfgKey = def[1], def[2], def[3]
        if CFG[cfgKey] then
            local rep = repFn()
            if rep then
                t = t:gsub(pat, rep)
            end
        end
    end

    if t ~= original then
        label.Text = t
    end
end

local function hookLabel(obj)
    if patchedLabels[obj] then return end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    patchedLabels[obj] = true
    applySpoof(obj)
    obj:GetPropertyChangedSignal("Text"):Connect(function()
        -- Only re-apply if the text changed to something we haven't already spoofed
        applySpoof(obj)
    end)
end

local function scanTree(root)
    -- Non-blocking scan via task.spawn batching
    task.spawn(function()
        local descendants = root:GetDescendants()
        for i = 1, #descendants do
            pcall(hookLabel, descendants[i])
            -- Yield every 50 items to avoid frame drops
            if i % 50 == 0 then task.wait() end
        end
    end)
    root.DescendantAdded:Connect(function(v)
        task.wait()   -- 1 frame delay so text is set
        pcall(hookLabel, v)
    end)
end

-- Hook PlayerGui + CoreGui (executor-level)
task.spawn(function()
    task.wait(2)  -- wait for game to load
    scanTree(lpgui)
    pcall(scanTree, CoreGui)
end)

lp.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(scanTree, CoreGui)
end)

-- ┌─────────────────────────────────────────────────────┐
--   RIVALS-SPECIFIC HOOKS
--   Target the known GUI names Rivals uses.
-- └─────────────────────────────────────────────────────┘
local rivalsTargetGuis = {
    -- Rivals ScreenGui name patterns (lowercase match)
    "hud","killfeed","leaderboard","career","endgame",
    "scoreboard","playerlist","matchend","stats","playercard",
    "duelsummary","ranking","ranked","profile",
}

local function isRivalsGui(name)
    local low = name:lower()
    for _, pattern in ipairs(rivalsTargetGuis) do
        if low:find(pattern, 1, true) then return true end
    end
    return false
end

-- Watch for Rivals GUIs appearing (they load dynamically)
lpgui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") or child:IsA("Frame") then
        task.wait(0.1)
        pcall(scanTree, child)
    end
end)

-- Extra: watch game.Players for other player name spoofing in kill feed
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        -- Disable their overhead nametag if we want clean look
    end)
end)

-- ┌─────────────────────────────────────────────────────┐
--   CUSTOM LEADERBOARD
-- └─────────────────────────────────────────────────────┘
local LDB_GUI, LDB_LIST

local function disableVanillaLDB()
    for _ = 1, 10 do
        local ok = pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        end)
        if ok then break end
        task.wait(0.15)
    end
end

local function buildLDB()
    if LDB_GUI then LDB_GUI:Destroy() end
    local th = T

    LDB_GUI = new("ScreenGui",{
        Name="AnoLDB", ResetOnSpawn=false, DisplayOrder=55, Enabled=false
    }, lpgui)

    local panel = new("Frame",{
        Size=UDim2.new(0,310,0,400),
        Position=UDim2.new(1,-326,0,56),
        BackgroundColor3=th.Root,
        BackgroundTransparency=0.04,
        BorderSizePixel=0,
    }, LDB_GUI)
    corner(12, panel)
    stroke(th.Accent, 1, 0.55, panel)
    new("UIDropShadowEffect",{ShadowColor=Color3.new(0,0,0),ShadowTransparency=0.65,BlurRadius=20}, panel)

    local header = new("Frame",{
        Size=UDim2.new(1,0,0,40),
        BackgroundColor3=th.Sidebar,
        BorderSizePixel=0,
    }, panel)
    corner(12, header)
    -- bottom corners flat
    new("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),
        BackgroundColor3=th.Sidebar,BorderSizePixel=0}, header)

    new("TextLabel",{
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1, Text="Leaderboard",
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=th.TextPri,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, header)

    local accentLine = new("Frame",{
        Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,0,0.5,-10),
        BackgroundColor3=th.Accent, BorderSizePixel=0,
    }, header)
    corner(2, accentLine)

    LDB_LIST = new("ScrollingFrame",{
        Size=UDim2.new(1,-16,1,-52),
        Position=UDim2.new(0,8,0,44),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=2,
        ScrollBarImageColor3=th.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, panel)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)}, LDB_LIST)
end

local function refreshLDB()
    if not LDB_LIST then return end
    for _,c in ipairs(LDB_LIST:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local plrs = Players:GetPlayers()
    table.sort(plrs, function(a,b)
        local ak,bk = 0,0
        pcall(function() ak = a.leaderstats.Kills.Value end)
        pcall(function() bk = b.leaderstats.Kills.Value end)
        return ak>bk
    end)
    local th = T
    for i,plr in ipairs(plrs) do
        local isMe = plr==lp
        local kills,deaths,streak = 0,0,0
        pcall(function() kills=plr.leaderstats.Kills.Value end)
        pcall(function() deaths=plr.leaderstats.Deaths.Value end)
        if isMe then
            if CFG.SpoofKills  then kills  = CFG.FakeKills  end
            if CFG.SpoofDeaths then deaths = CFG.FakeDeaths end
            if CFG.SpoofStreak then streak = CFG.FakeStreak end
        end
        local dname = isMe and spoofDisplay() or plr.DisplayName

        local row = new("Frame",{
            Size=UDim2.new(1,0,0,38),
            BackgroundColor3=isMe and th.Card or th.Content,
            BackgroundTransparency=isMe and 0 or 0.3,
            BorderSizePixel=0, LayoutOrder=i,
        }, LDB_LIST)
        corner(8, row)
        if isMe then stroke(th.Accent, 1, 0.4, row) end
        pad(0,0,8,8, row)

        -- Rank #
        new("TextLabel",{
            Size=UDim2.new(0,24,1,0),
            BackgroundTransparency=1,
            Text="#"..i,
            Font=Enum.Font.GothamBold, TextSize=11,
            TextColor3=th.Accent,
        }, row)
        -- Name
        new("TextLabel",{
            Size=UDim2.new(0,130,1,0), Position=UDim2.new(0,28,0,0),
            BackgroundTransparency=1,
            Text=dname,
            Font=isMe and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize=12, TextColor3=isMe and th.Accent or th.TextPri,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,
        }, row)
        -- Stats
        new("TextLabel",{
            Size=UDim2.new(0,112,1,0), Position=UDim2.new(0,162,0,0),
            BackgroundTransparency=1,
            Text=kills.."K  "..deaths.."D  "..streak.."WS",
            Font=Enum.Font.Gotham, TextSize=11,
            TextColor3=th.TextSec,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, row)
    end
end

-- ┌─────────────────────────────────────────────────────┐
--   BILLBOARD  (win streak + spoof name above head)
-- └─────────────────────────────────────────────────────┘
local activeBillboard

local function applyBillboard(char)
    if activeBillboard then activeBillboard:Destroy() activeBillboard=nil end
    if not CFG.ShowOnBillboard then return end
    local head = char:WaitForChild("Head", 4)
    if not head then return end

    local bb = new("BillboardGui",{
        Name="AnoBB", Adornee=head,
        Size=UDim2.new(0,160,0,42),
        StudsOffset=Vector3.new(0,2.6,0),
        AlwaysOnTop=false, ResetOnSpawn=false,
    }, head)
    activeBillboard = bb

    local nameLbl = new("TextLabel",{
        Size=UDim2.new(1,0,0.56,0),
        BackgroundTransparency=1,
        Text=spoofDisplay(),
        Font=Enum.Font.GothamBold, TextSize=14,
        TextColor3=T.Accent,
        TextStrokeTransparency=0.4, TextStrokeColor3=Color3.new(0,0,0),
    }, bb)

    local wsLbl = new("TextLabel",{
        Size=UDim2.new(1,0,0.44,0), Position=UDim2.new(0,0,0.56,0),
        BackgroundTransparency=1,
        Text=CFG.SpoofStreak and (CFG.FakeStreak.." Streak") or "",
        Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=Color3.fromRGB(255,210,70),
        TextStrokeTransparency=0.5, TextStrokeColor3=Color3.new(0,0,0),
    }, bb)

    -- Lightweight rainbow update (only if enabled, low rate)
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not bb or not bb.Parent then conn:Disconnect() return end
        if CFG.WMRainbow then
            nameLbl.TextColor3 = hsvCycle(tick()*0.25)
        else
            nameLbl.TextColor3 = T.Accent
        end
        nameLbl.Text = spoofDisplay()
        wsLbl.Text = CFG.SpoofStreak and (CFG.FakeStreak.." Streak") or ""
    end)
end

lp.CharacterAdded:Connect(function(c) task.wait(0.3) applyBillboard(c) end)
if lp.Character then task.spawn(function() applyBillboard(lp.Character) end) end

-- ┌─────────────────────────────────────────────────────┐
--   KILL FEED STYLES
-- └─────────────────────────────────────────────────────┘
local KF_STYLES = {
    Clean   = function(k,w,v) return k.." killed "..v.." ["..w.."]" end,
    Arrow   = function(k,w,v) return k.." -> "..v.." ("..w..")" end,
    Bracket = function(k,w,v) return "["..k.."] ["..w.."] ["..v.."]" end,
    Hacker  = function(k,w,v) return ">>"..k.."<<"..w..">>"..v.."<<" end,
    Minimal = function(k,w,v) return k.." + "..v end,
}

local KF_GUI, KF_FRAME

local function buildKFGui()
    if KF_GUI then KF_GUI:Destroy() end
    KF_GUI = new("ScreenGui",{
        Name="AnoKF", ResetOnSpawn=false, DisplayOrder=58
    }, lpgui)
    KF_FRAME = new("Frame",{
        Size=UDim2.new(0,340,0,190),
        Position=UDim2.new(1,-358,0,106),
        BackgroundTransparency=1, BorderSizePixel=0,
    }, KF_GUI)
    local ll = new("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        Padding=UDim.new(0,3),
    }, KF_FRAME)
end

local kfOrder = 0
local function pushKF(killer, weapon, victim)
    if not KF_FRAME then return end
    kfOrder += 1
    local fn = KF_STYLES[CFG.KFStyle] or KF_STYLES.Clean
    local txt = fn(killer, weapon, victim)

    local entry = new("Frame",{
        Size=UDim2.new(1,0,0,28),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.45,
        BorderSizePixel=0, LayoutOrder=kfOrder,
    }, KF_FRAME)
    corner(6, entry)

    new("TextLabel",{
        Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1, Text=txt,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=T.Accent,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, entry)

    task.delay(3.5, function()
        if not entry.Parent then return end
        tw(entry, TI_MED, {BackgroundTransparency=1})
        for _,c in ipairs(entry:GetChildren()) do
            if c:IsA("TextLabel") then tw(c, TI_MED, {TextTransparency=1}) end
        end
        task.wait(0.5)
        if entry.Parent then entry:Destroy() end
    end)
end

-- ┌─────────────────────────────────────────────────────┐
--   WATERMARK  (updates every 1s — not per-frame)
-- └─────────────────────────────────────────────────────┘
local WM_GUI, WM_MAIN, WM_SUB

local function buildWatermark()
    if WM_GUI then WM_GUI:Destroy() end
    local th = T

    WM_GUI = new("ScreenGui",{
        Name="AnoWM", ResetOnSpawn=false, DisplayOrder=100,
        Enabled=CFG.WMEnabled,
    }, lpgui)

    local frame = new("Frame",{
        Position=UDim2.new(0,12,0,12),
        Size=UDim2.new(0,14,0,44),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=th.Watermark,
        BackgroundTransparency=0.06,
        BorderSizePixel=0,
    }, WM_GUI)
    corner(10, frame)
    stroke(th.Accent, 1, 0.5, frame)
    pad(8,8,12,14, frame)

    local stack = new("Frame",{
        Size=UDim2.new(0,1,1,0),
        AutomaticSize=Enum.AutomaticSize.XY,
        BackgroundTransparency=1,
    }, frame)
    new("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,2),
    }, stack)

    WM_MAIN = new("TextLabel",{
        Size=UDim2.new(0,1,0,18),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,
        Text=CFG.WMText,
        Font=Enum.Font.GothamBold, TextSize=CFG.WMSize,
        TextColor3=th.Accent,
        TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=1,
    }, stack)

    WM_SUB = new("TextLabel",{
        Size=UDim2.new(0,1,0,14),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,
        Text="",
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=th.TextSec,
        TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=2,
    }, stack)
end

-- 1s loop — very light
task.spawn(function()
    while true do
        task.wait(1)
        if WM_GUI and WM_GUI.Enabled then
            if WM_MAIN then
                WM_MAIN.Text = CFG.WMText
                if CFG.WMRainbow then
                    WM_MAIN.TextColor3 = hsvCycle(tick()*0.2)
                else
                    WM_MAIN.TextColor3 = T.Accent
                end
            end
            if WM_SUB then
                if CFG.WMSubAuto then
                    local fps = math.floor(1/math.max(RunService.Heartbeat:Wait(),0.001))
                    WM_SUB.Text = string.format(
                        "%s   %dms   %dfps   %s",
                        spoofName(),
                        CFG.SpoofPing and CFG.FakePing or 0,
                        CFG.SpoofFPS  and CFG.FakeFPS  or fps,
                        CFG.SpoofRegion and CFG.FakeRegion or "?"
                    )
                else
                    WM_SUB.Text = CFG.WMSubText
                end
            end
        end
    end
end)

-- ┌─────────────────────────────────────────────────────┐
--   EXTRA FEATURES
-- └─────────────────────────────────────────────────────┘
local extraConnections = {}

local function stopExtra(key)
    if extraConnections[key] then
        pcall(function() extraConnections[key]:Disconnect() end)
        extraConnections[key] = nil
    end
end

local function startInfJump()
    stopExtra("infJump")
    extraConnections["infJump"] = UIS.JumpRequest:Connect(function()
        if not CFG.InfJump then stopExtra("infJump") return end
        local c = lp.Character
        if c then
            local h = c:FindFirstChildWhichIsA("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

local noclipConn
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not CFG.Noclip then noclipConn:Disconnect() return end
        local c = lp.Character
        if c then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

local afkThread
local function startFakeAFK()
    if afkThread then task.cancel(afkThread) end
    afkThread = task.spawn(function()
        while CFG.FakeAFK do
            task.wait(55)
            local c = lp.Character
            if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0.001,0,0) end
            end
        end
    end)
end

-- Name cycling thread
local cycleThread
local cycleIdx = 1
local function startNameCycle()
    if cycleThread then task.cancel(cycleThread) end
    cycleThread = task.spawn(function()
        while CFG.CycleNames do
            task.wait(CFG.CycleInterval)
            cycleIdx = (cycleIdx % #CFG.CycleList) + 1
            -- Rotate so spoofName() picks first
            local rotated = {}
            for i = cycleIdx, #CFG.CycleList do rotated[#rotated+1]=CFG.CycleList[i] end
            for i = 1, cycleIdx-1 do rotated[#rotated+1]=CFG.CycleList[i] end
            CFG.CycleList = rotated
        end
    end)
end

-- ┌─────────────────────────────────────────────────────┐
--   MAIN UI
--   Sidebar: 52px collapsed, 186px expanded on hover
--   No X button. Professional dark/light theme.
-- └─────────────────────────────────────────────────────┘
local MAIN_GUI
local menuOpen = true

-- Sidebar dimensions
local SB_W_COL = 54
local SB_W_EXP = 188
local CONTENT_X_COL = SB_W_COL + 1
local CONTENT_X_EXP = SB_W_EXP + 1

-- Tab registry
local TAB_DATA = {
    {id="identity", icon="rbxassetid://14671146577",  label="Identity"},
    {id="stats",    icon="rbxassetid://14484108059",  label="Stats"},
    {id="status",   icon="rbxassetid://14508492012",  label="Status"},
    {id="killfeed", icon="rbxassetid://14510951736",  label="Kill Feed"},
    {id="skins",    icon="rbxassetid://14484110001",  label="Skins"},
    {id="watermark",icon="rbxassetid://14484106924",  label="Watermark"},
    {id="extra",    icon="rbxassetid://14484105428",  label="Extra"},
    {id="config",   icon="rbxassetid://14484104516",  label="Config"},
}
local tabFrames   = {}
local tabBtns     = {}
local activeTab   = "identity"

-- Re-theming references
local themeRefs = {}  -- list of {inst, prop, themeKey}
local function regTheme(inst, prop, themeKey)
    themeRefs[#themeRefs+1] = {inst=inst, prop=prop, key=themeKey}
end
local function applyTheme()
    refreshTheme()
    for _,r in ipairs(themeRefs) do
        if r.inst and r.inst.Parent then
            r.inst[r.prop] = T[r.key]
        end
    end
end

local function buildUI()
    if MAIN_GUI then MAIN_GUI:Destroy() end
    themeRefs = {}

    local th = T

    MAIN_GUI = new("ScreenGui",{
        Name="AnoMain", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200, Enabled=menuOpen,
    }, lpgui)

    -- ── ROOT ─────────────────────────────────────────────
    local root = new("Frame",{
        Name="Root",
        Size=UDim2.new(0,710,0,480),
        Position=UDim2.new(0.5,-355,0.5,-240),
        BackgroundColor3=th.Root,
        BorderSizePixel=0, ClipsDescendants=false,
    }, MAIN_GUI)
    corner(14, root)
    local rootStroke = stroke(th.Border, 1.2, 0, root)
    regTheme(root,"BackgroundColor3","Root")
    regTheme(rootStroke,"Color","Border")

    -- Subtle inner clip frame (prevents overflow)
    local clipInner = new("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        ClipsDescendants=true,
    }, root)
    corner(14, clipInner)

    -- Drop shadow (image-based, no lag)
    new("ImageLabel",{
        Size=UDim2.new(1,40,1,40),
        Position=UDim2.new(0,-20,0,-20),
        BackgroundTransparency=1,
        Image="rbxassetid://5554236805",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.55,
        ZIndex=-1, ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(23,23,277,277),
    }, root)

    -- ── DRAG ─────────────────────────────────────────────
    do
        local dragging, dStart, rStart = false, nil, nil
        root.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging=true; dStart=inp.Position; rStart=root.Position
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
                local d = inp.Position - dStart
                root.Position = UDim2.new(
                    rStart.X.Scale, rStart.X.Offset+d.X,
                    rStart.Y.Scale, rStart.Y.Offset+d.Y
                )
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
    end

    -- ── SIDEBAR ───────────────────────────────────────────
    local sidebar = new("Frame",{
        Name="Sidebar",
        Size=UDim2.new(0,SB_W_COL,1,0),
        BackgroundColor3=th.Sidebar,
        BorderSizePixel=0,
    }, clipInner)
    corner(14, sidebar)
    -- Flatten right side
    new("Frame",{
        Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-14,0,0),
        BackgroundColor3=th.Sidebar, BorderSizePixel=0,
    }, sidebar)
    regTheme(sidebar,"BackgroundColor3","Sidebar")

    -- Thin separator
    local sep = new("Frame",{
        Size=UDim2.new(0,1,1,0),
        Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=th.Border,
        BorderSizePixel=0,
    }, sidebar)
    regTheme(sep,"BackgroundColor3","Border")

    -- ── LOGO ─────────────────────────────────────────────
    local logoBtn = new("TextButton",{
        Name="LogoArea",
        Size=UDim2.new(1,0,0,54),
        BackgroundTransparency=1,
        Text="",
        BorderSizePixel=0,
    }, sidebar)

    -- "A" glyph (fantasy font — renders properly)
    local logoA = new("TextLabel",{
        Size=UDim2.new(0,SB_W_COL,1,0),
        BackgroundTransparency=1,
        Text="A",
        Font=Enum.Font.Fantasy,
        TextSize=28,
        TextColor3=th.Logo,
        TextXAlignment=Enum.TextXAlignment.Center,
    }, logoBtn)
    regTheme(logoA,"TextColor3","Logo")

    -- "anomia" label that fades in when expanded
    local logoText = new("TextLabel",{
        Size=UDim2.new(1,-(SB_W_COL+4),1,0),
        Position=UDim2.new(0,SB_W_COL,0,0),
        BackgroundTransparency=1,
        Text="anomia",
        Font=Enum.Font.GothamBold,
        TextSize=16, TextColor3=th.TextPri,
        TextTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, logoBtn)
    regTheme(logoText,"TextColor3","TextPri")

    -- Logo accent dot
    new("Frame",{
        Size=UDim2.new(0,4,0,4),
        Position=UDim2.new(0,SB_W_COL/2-2,1,-8),
        BackgroundColor3=th.Accent,
        BorderSizePixel=0,
    }, logoBtn)

    -- Divider below logo
    local logoDivider = new("Frame",{
        Size=UDim2.new(0.75,0,0,1),
        Position=UDim2.new(0.125,0,1,-1),
        BackgroundColor3=th.Border,
        BorderSizePixel=0,
    }, logoBtn)
    regTheme(logoDivider,"BackgroundColor3","Border")

    -- ── TAB BUTTONS ──────────────────────────────────────
    local tabList = new("Frame",{
        Name="TabList",
        Size=UDim2.new(1,0,1,-60),
        Position=UDim2.new(0,0,0,60),
        BackgroundTransparency=1,
        BorderSizePixel=0,
    }, sidebar)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)}, tabList)
    pad(4,4,4,4, tabList)

    for i, tabDef in ipairs(TAB_DATA) do
        local isActive = tabDef.id == activeTab
        local btn = new("TextButton",{
            Name=tabDef.id,
            Size=UDim2.new(1,0,0,38),
            BackgroundColor3=isActive and th.Card or th.Sidebar,
            BackgroundTransparency=isActive and 0 or 1,
            Text="", BorderSizePixel=0,
            LayoutOrder=i,
        }, tabList)
        corner(8, btn)

        local activeBar = new("Frame",{
            Size=UDim2.new(0,3,0,20),
            Position=UDim2.new(0,0,0.5,-10),
            BackgroundColor3=th.Accent,
            BackgroundTransparency=isActive and 0 or 1,
            BorderSizePixel=0,
        }, btn)
        corner(2, activeBar)

        -- Icon
        local icon = new("ImageLabel",{
            Size=UDim2.new(0,18,0,18),
            Position=UDim2.new(0,SB_W_COL/2-9,0.5,-9),
            BackgroundTransparency=1,
            Image=tabDef.icon,
            ImageColor3=isActive and th.Accent or th.TextSec,
        }, btn)

        -- Label (invisible by default)
        local lbl = new("TextLabel",{
            Size=UDim2.new(1,-(SB_W_COL+6),1,0),
            Position=UDim2.new(0,SB_W_COL,0,0),
            BackgroundTransparency=1,
            Text=tabDef.label,
            Font=isActive and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize=12, TextColor3=isActive and th.Accent or th.TextPri,
            TextTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, btn)
        regTheme(lbl,"TextColor3",isActive and "Accent" or "TextPri")

        tabBtns[tabDef.id] = {
            btn=btn, icon=icon, lbl=lbl, bar=activeBar
        }

        btn.MouseEnter:Connect(function()
            if tabDef.id ~= activeTab then
                tw(btn, TI_FAST, {BackgroundTransparency=0.7, BackgroundColor3=th.Card})
                tw(icon, TI_FAST, {ImageColor3=th.TextPri})
            end
        end)
        btn.MouseLeave:Connect(function()
            if tabDef.id ~= activeTab then
                tw(btn, TI_FAST, {BackgroundTransparency=1})
                tw(icon, TI_FAST, {ImageColor3=th.TextSec})
            end
        end)

        btn.MouseButton1Click:Connect(function()
            local prev = activeTab
            if prev == tabDef.id then return end

            -- Deactivate old
            local oldRefs = tabBtns[prev]
            if oldRefs then
                tw(oldRefs.btn,  TI_FAST, {BackgroundTransparency=1})
                tw(oldRefs.bar,  TI_FAST, {BackgroundTransparency=1})
                tw(oldRefs.icon, TI_FAST, {ImageColor3=th.TextSec})
                tw(oldRefs.lbl,  TI_FAST, {TextColor3=th.TextPri, TextTransparency=1})
                oldRefs.lbl.Font = Enum.Font.Gotham
            end
            if tabFrames[prev] then
                tw(tabFrames[prev], TI_FAST, {BackgroundTransparency=1})
                task.delay(0.2, function()
                    if tabFrames[prev] then tabFrames[prev].Visible = false end
                end)
            end

            activeTab = tabDef.id
            -- Activate new
            tw(btn,  TI_FAST, {BackgroundTransparency=0, BackgroundColor3=th.Card})
            tw(activeBar, TI_FAST, {BackgroundTransparency=0})
            tw(icon, TI_FAST, {ImageColor3=th.Accent})
            lbl.Font = Enum.Font.GothamBold
            -- Only show label if sidebar expanded (handled by sidebar hover)

            if tabFrames[activeTab] then
                tabFrames[activeTab].Visible = true
                tabFrames[activeTab].BackgroundTransparency = 1
                tw(tabFrames[activeTab], TI_MED, {BackgroundTransparency=0})
            end
        end)
    end

    -- ── SIDEBAR HOVER EXPAND ─────────────────────────────
    local sbExpanded = false
    local sbHoverTask

    local function expandSidebar()
        if sbExpanded then return end
        sbExpanded = true
        tw(sidebar, TI_MED, {Size=UDim2.new(0,SB_W_EXP,1,0)})
        -- Show labels
        tw(logoText, TI_MED, {TextTransparency=0})
        for _, td in ipairs(TAB_DATA) do
            local refs = tabBtns[td.id]
            if refs then
                tw(refs.lbl, TI_MED, {TextTransparency=0})
            end
        end
    end

    local function collapseSidebar()
        if not sbExpanded then return end
        sbExpanded = false
        tw(sidebar, TI_MED, {Size=UDim2.new(0,SB_W_COL,1,0)})
        tw(logoText, TI_FAST, {TextTransparency=1})
        for _, td in ipairs(TAB_DATA) do
            local refs = tabBtns[td.id]
            if refs then
                tw(refs.lbl, TI_FAST, {TextTransparency=1})
            end
        end
    end

    sidebar.MouseEnter:Connect(function()
        sbHoverTask = task.delay(0.35, expandSidebar)
    end)
    sidebar.MouseLeave:Connect(function()
        if sbHoverTask then task.cancel(sbHoverTask) sbHoverTask=nil end
        collapseSidebar()
    end)

    -- ── CONTENT AREA ─────────────────────────────────────
    local contentArea = new("Frame",{
        Name="Content",
        Size=UDim2.new(1,-CONTENT_X_COL-1,1,0),
        Position=UDim2.new(0,CONTENT_X_COL+1,0,0),
        BackgroundColor3=th.Content,
        BorderSizePixel=0, ClipsDescendants=true,
    }, clipInner)
    corner(14, contentArea)
    new("Frame",{   -- flatten left edge
        Size=UDim2.new(0,14,1,0),
        BackgroundColor3=th.Content,
        BorderSizePixel=0,
    }, contentArea)
    regTheme(contentArea,"BackgroundColor3","Content")

    -- ── CONTENT HEADER ────────────────────────────────────
    local contentHeader = new("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundColor3=th.Root,
        BackgroundTransparency=0.4,
        BorderSizePixel=0,
    }, contentArea)
    corner(14, contentHeader)
    new("Frame",{
        Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),
        BackgroundColor3=th.Root, BackgroundTransparency=0.4, BorderSizePixel=0,
    }, contentHeader)

    local headerDivider = new("Frame",{
        Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),
        BackgroundColor3=th.Border, BorderSizePixel=0,
    }, contentHeader)
    regTheme(headerDivider,"BackgroundColor3","Border")

    local headerTitle = new("TextLabel",{
        Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,16,0,0),
        BackgroundTransparency=1,
        Text="Identity",
        Font=Enum.Font.GothamBold, TextSize=15,
        TextColor3=th.TextPri,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, contentHeader)
    regTheme(headerTitle,"TextColor3","TextPri")

    -- Version label in header right
    local headerVer = new("TextLabel",{
        Size=UDim2.new(0,80,1,0),
        Position=UDim2.new(1,-90,0,0),
        BackgroundTransparency=1,
        Text="v2  anomia",
        Font=Enum.Font.Gotham, TextSize=11,
        TextColor3=th.TextSec,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, contentHeader)
    regTheme(headerVer,"TextColor3","TextSec")

    -- ── COMPONENT BUILDERS ────────────────────────────────
    local function makeScroll(tabId)
        local f = new("ScrollingFrame",{
            Name=tabId,
            Size=UDim2.new(1,0,1,-50),
            Position=UDim2.new(0,0,0,50),
            BackgroundColor3=th.Content,
            BackgroundTransparency=0,
            BorderSizePixel=0,
            ScrollBarThickness=2,
            ScrollBarImageColor3=T.Accent,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=tabId==activeTab,
        }, contentArea)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)}, f)
        pad(10,10,12,12, f)
        tabFrames[tabId] = f
        regTheme(f,"BackgroundColor3","Content")
        return f
    end

    -- Section header
    local function secHead(parent, text, lo)
        local f = new("Frame",{
            Size=UDim2.new(1,-4,0,22), BackgroundTransparency=1,
            LayoutOrder=lo or 1,
        }, parent)
        local accent = new("Frame",{
            Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,0,0.5,-7),
            BackgroundColor3=T.Accent, BorderSizePixel=0,
        }, f)
        corner(2, accent)
        new("TextLabel",{
            Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,8,0,0),
            BackgroundTransparency=1,
            Text=text:upper(),
            Font=Enum.Font.GothamBold, TextSize=10,
            TextColor3=T.TextSec,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, f)
        return f
    end

    -- Row card
    local function card(parent, lo, h)
        h = h or 40
        local f = new("Frame",{
            Size=UDim2.new(1,0,0,h),
            BackgroundColor3=T.Card,
            BorderSizePixel=0, LayoutOrder=lo or 1,
        }, parent)
        corner(8, f)
        pad(0,0,12,12, f)
        -- hover
        f.MouseEnter:Connect(function() tw(f,TI_FAST,{BackgroundColor3=T.CardHover}) end)
        f.MouseLeave:Connect(function() tw(f,TI_FAST,{BackgroundColor3=T.Card}) end)
        regTheme(f,"BackgroundColor3","Card")
        return f
    end

    -- Label + optional tooltip
    local function rowLabel(parent, text, tip)
        local lbl = new("TextLabel",{
            Size=UDim2.new(0.5,-4,1,0),
            BackgroundTransparency=1,
            Text=text,
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=T.TextPri,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, parent)
        regTheme(lbl,"TextColor3","TextPri")
        if tip then
            local tipBtn = new("TextButton",{
                Size=UDim2.new(0,14,0,14),
                Position=UDim2.new(0, #text*6+8, 0.5,-7),
                BackgroundColor3=T.AccentDim,
                BackgroundTransparency=0.3,
                Text="i", Font=Enum.Font.GothamBold, TextSize=9,
                TextColor3=Color3.new(1,1,1),
                BorderSizePixel=0,
            }, parent)
            corner(9, tipBtn)
            local tt
            tipBtn.MouseEnter:Connect(function()
                if tt then tt:Destroy() end
                tt = new("Frame",{
                    Size=UDim2.new(0,math.max(140,#tip*6.5),0,26),
                    Position=UDim2.new(0,0,1,4),
                    BackgroundColor3=T.Card,
                    BorderSizePixel=0, ZIndex=30,
                }, tipBtn)
                corner(6, tt)
                stroke(T.Accent,1,0.5,tt)
                new("TextLabel",{
                    Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,5,0,0),
                    BackgroundTransparency=1, Text=tip,
                    Font=Enum.Font.Gotham, TextSize=10,
                    TextColor3=T.TextPri, ZIndex=30,
                    TextXAlignment=Enum.TextXAlignment.Left,
                }, tt)
            end)
            tipBtn.MouseLeave:Connect(function()
                if tt then tt:Destroy(); tt=nil end
            end)
        end
        return lbl
    end

    -- Toggle switch
    local function toggle(parent, cfgKey, onChange)
        local on = CFG[cfgKey]
        local track = new("TextButton",{
            Size=UDim2.new(0,42,0,22),
            Position=UDim2.new(1,-42,0.5,-11),
            BackgroundColor3=on and T.Toggle_ON or T.Toggle_OFF,
            Text="", BorderSizePixel=0,
        }, parent)
        corner(11, track)

        local knob = new("Frame",{
            Size=UDim2.new(0,16,0,16),
            Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3=Color3.new(1,1,1),
            BorderSizePixel=0,
        }, track)
        corner(9, knob)
        new("UIDropShadowEffect",{ShadowTransparency=0.65,BlurRadius=4}, knob)

        track.MouseButton1Click:Connect(function()
            CFG[cfgKey] = not CFG[cfgKey]
            local v = CFG[cfgKey]
            tw(track, TI_FAST, {BackgroundColor3=v and T.Toggle_ON or T.Toggle_OFF})
            tw(knob,  TI_FAST, {Position=v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            if onChange then onChange(v) end
        end)
        return track
    end

    -- Text input
    local function textInput(parent, cfgKey, placeholder, onDone)
        local box = new("TextBox",{
            Size=UDim2.new(0.45,0,0,26),
            Position=UDim2.new(0.52,0,0.5,-13),
            BackgroundColor3=T.Content,
            BackgroundTransparency=0.3,
            BorderSizePixel=0,
            Text=tostring(CFG[cfgKey] or ""),
            PlaceholderText=placeholder or "",
            Font=Enum.Font.Gotham, TextSize=12,
            TextColor3=T.TextPri,
            PlaceholderColor3=T.TextSec,
            ClearTextOnFocus=false,
        }, parent)
        corner(7, box)
        stroke(T.Border, 1, 0, box)
        regTheme(box,"TextColor3","TextPri")
        box.Focused:Connect(function()
            tw(box, TI_FAST, {BackgroundTransparency=0})
            for _,s in ipairs(box:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,TI_FAST,{Color=T.Accent}) end
            end
        end)
        box.FocusLost:Connect(function()
            tw(box, TI_FAST, {BackgroundTransparency=0.3})
            for _,s in ipairs(box:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,TI_FAST,{Color=T.Border}) end
            end
            local v = box.Text
            local n = tonumber(v)
            CFG[cfgKey] = (n ~= nil and type(CFG[cfgKey])=="number") and n or v
            if onDone then onDone(CFG[cfgKey]) end
        end)
        return box
    end

    -- Dropdown
    local function dropdown(parent, cfgKey, opts, onChange)
        local cur = tostring(CFG[cfgKey] or opts[1])
        local isOpen = false
        local dropFrame

        local btn = new("TextButton",{
            Size=UDim2.new(0.45,0,0,26),
            Position=UDim2.new(0.52,0,0.5,-13),
            BackgroundColor3=T.Content,
            BackgroundTransparency=0.3,
            BorderSizePixel=0,
            Text="",
        }, parent)
        corner(7, btn)
        stroke(T.Border, 1, 0, btn)

        local btnTxt = new("TextLabel",{
            Size=UDim2.new(1,-22,1,0), Position=UDim2.new(0,8,0,0),
            BackgroundTransparency=1,
            Text=cur,
            Font=Enum.Font.Gotham, TextSize=12,
            TextColor3=T.TextPri,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, btn)
        regTheme(btnTxt,"TextColor3","TextPri")

        local chevron = new("TextLabel",{
            Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0),
            BackgroundTransparency=1, Text="v",
            Font=Enum.Font.GothamBold, TextSize=9,
            TextColor3=T.TextSec,
        }, btn)

        local function closeDropdown()
            if dropFrame then dropFrame:Destroy(); dropFrame=nil end
            isOpen=false
            tw(chevron, TI_FAST, {Rotation=0})
        end

        btn.MouseButton1Click:Connect(function()
            if isOpen then closeDropdown() return end
            isOpen=true
            tw(chevron, TI_FAST, {Rotation=180})

            dropFrame = new("Frame",{
                Size=UDim2.new(0, btn.AbsoluteSize.X, 0, math.min(#opts,5)*30+6),
                Position=UDim2.new(0, btn.AbsolutePosition.X - contentArea.AbsolutePosition.X,
                                   0, btn.AbsolutePosition.Y - contentArea.AbsolutePosition.Y + btn.AbsoluteSize.Y + 3),
                BackgroundColor3=T.Card,
                BorderSizePixel=0, ZIndex=50, ClipsDescendants=true,
            }, contentArea)
            corner(8, dropFrame)
            stroke(T.Accent, 1, 0.4, dropFrame)
            new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)}, dropFrame)
            pad(3,3,4,4, dropFrame)

            for i,opt in ipairs(opts) do
                local isCur = opt==cur
                local optBtn = new("TextButton",{
                    Size=UDim2.new(1,0,0,26),
                    BackgroundColor3=isCur and T.CardHover or T.Card,
                    BackgroundTransparency=isCur and 0 or 0.4,
                    Text="",
                    BorderSizePixel=0, ZIndex=51, LayoutOrder=i,
                }, dropFrame)
                corner(6, optBtn)
                new("TextLabel",{
                    Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
                    BackgroundTransparency=1, Text=opt,
                    Font=isCur and Enum.Font.GothamBold or Enum.Font.Gotham,
                    TextSize=12,
                    TextColor3=isCur and T.Accent or T.TextPri,
                    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=51,
                }, optBtn)
                optBtn.MouseEnter:Connect(function() tw(optBtn,TI_FAST,{BackgroundTransparency=0}) end)
                optBtn.MouseLeave:Connect(function() tw(optBtn,TI_FAST,{BackgroundTransparency=isCur and 0 or 0.4}) end)
                optBtn.MouseButton1Click:Connect(function()
                    cur=opt; CFG[cfgKey]=opt
                    btnTxt.Text=opt
                    closeDropdown()
                    if onChange then onChange(opt) end
                end)
            end
        end)
        return btn
    end

    -- Number slider
    local function slider(parent, cfgKey, minV, maxV, step, onChange)
        local valLbl = new("TextLabel",{
            Size=UDim2.new(0,38,0,26),
            Position=UDim2.new(1,-150,0.5,-13),
            BackgroundTransparency=1,
            Text=tostring(CFG[cfgKey]),
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=T.Accent,
            TextXAlignment=Enum.TextXAlignment.Right,
        }, parent)

        local track = new("Frame",{
            Size=UDim2.new(0,96,0,4),
            Position=UDim2.new(1,-100,0.5,-2),
            BackgroundColor3=T.Toggle_OFF,
            BorderSizePixel=0,
        }, parent)
        corner(2, track)

        local fill = new("Frame",{
            Size=UDim2.new((CFG[cfgKey]-minV)/(maxV-minV),0,1,0),
            BackgroundColor3=T.Accent, BorderSizePixel=0,
        }, track)
        corner(2, fill)

        local knob = new("Frame",{
            Size=UDim2.new(0,12,0,12),
            Position=UDim2.new((CFG[cfgKey]-minV)/(maxV-minV),-6,0.5,-6),
            BackgroundColor3=Color3.new(1,1,1), BorderSizePixel=0,
        }, track)
        corner(8, knob)
        new("UIDropShadowEffect",{ShadowTransparency=0.6,BlurRadius=4}, knob)

        local sliding=false
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end
        end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not sliding or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
            local ap = track.AbsolutePosition
            local as = track.AbsoluteSize
            local pct = math.clamp((i.Position.X-ap.X)/as.X,0,1)
            local raw = minV+pct*(maxV-minV)
            local v = math.clamp(math.round(raw/step)*step, minV, maxV)
            CFG[cfgKey]=v
            valLbl.Text=tostring(v)
            local fp = (v-minV)/(maxV-minV)
            tw(fill,  TweenInfo.new(0.05), {Size=UDim2.new(fp,0,1,0)})
            tw(knob,  TweenInfo.new(0.05), {Position=UDim2.new(fp,-6,0.5,-6)})
            if onChange then onChange(v) end
        end)
        return track
    end

    -- Action button
    local function actionBtn(parent, text, accentCol, lo, cb)
        local r = card(parent, lo, 40)
        local b = new("TextButton",{
            Size=UDim2.new(0,120,0,26),
            Position=UDim2.new(1,-120,0.5,-13),
            BackgroundColor3=accentCol or T.Accent,
            BackgroundTransparency=0.2,
            Text=text,
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=Color3.new(1,1,1),
            BorderSizePixel=0,
        }, r)
        corner(7, b)
        b.MouseEnter:Connect(function() tw(b,TI_FAST,{BackgroundTransparency=0}) end)
        b.MouseLeave:Connect(function() tw(b,TI_FAST,{BackgroundTransparency=0.2}) end)
        b.MouseButton1Click:Connect(cb)
        new("TextLabel",{
            Size=UDim2.new(0.5,0,1,0),
            BackgroundTransparency=1, Text=text,
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=T.TextPri,
            TextXAlignment=Enum.TextXAlignment.Left,
        }, r)
        return r
    end

    -- ── IDENTITY TAB ─────────────────────────────────────
    local tId = makeScroll("identity")

    secHead(tId,"Username",1)

    local c2 = card(tId,2)
    rowLabel(c2,"Spoof Username","Replaces your real Roblox username across all UIs")
    toggle(c2,"SpoofUsername")

    local c3 = card(tId,3)
    rowLabel(c3,"Fake Username","Username shown instead of your real one")
    textInput(c3,"FakeUsername","e.g. AnoPlayer")

    local c4 = card(tId,4)
    rowLabel(c4,"Show on Billboard","Custom overhead nametag on your character")
    toggle(c4,"ShowOnBillboard",function(v)
        if v then
            if lp.Character then applyBillboard(lp.Character) end
        elseif activeBillboard then
            activeBillboard:Destroy(); activeBillboard=nil
        end
    end)

    secHead(tId,"Display Name",5)

    local c6 = card(tId,6)
    rowLabel(c6,"Spoof Display Name","Changes the display name shown across all UIs")
    toggle(c6,"SpoofDisplay")

    local c7 = card(tId,7)
    rowLabel(c7,"Fake Display Name","The name that replaces your display name")
    textInput(c7,"FakeDisplay","e.g. anomia")

    secHead(tId,"Performance Display",8)

    local c9 = card(tId,9)
    rowLabel(c9,"Spoof Ping","Show fake ping value in watermark")
    toggle(c9,"SpoofPing")

    local c10 = card(tId,10)
    rowLabel(c10,"Fake Ping (ms)","")
    slider(c10,"FakePing",1,999,1)

    local c11 = card(tId,11)
    rowLabel(c11,"Spoof FPS","Show fake FPS value in watermark")
    toggle(c11,"SpoofFPS")

    local c12 = card(tId,12)
    rowLabel(c12,"Fake FPS","")
    slider(c12,"FakeFPS",1,500,1)

    local c13 = card(tId,13)
    rowLabel(c13,"Spoof Region","Custom region string in watermark")
    toggle(c13,"SpoofRegion")

    local c14 = card(tId,14)
    rowLabel(c14,"Fake Region","e.g. EU-West, NA-East")
    textInput(c14,"FakeRegion","EU-West")

    secHead(tId,"Name Cycling",15)

    local c16 = card(tId,16)
    rowLabel(c16,"Cycle Through Names","Auto-rotates your spoofed username through a list")
    toggle(c16,"CycleNames",function(v)
        if v then startNameCycle() end
    end)

    local c17 = card(tId,17)
    rowLabel(c17,"Cycle Interval (s)","Seconds between each name swap")
    slider(c17,"CycleInterval",1,60,1)

    -- ── STATS TAB ─────────────────────────────────────────
    local tStats = makeScroll("stats")

    local statDefs = {
        {k="SpoofKills",   vk="FakeKills",   lbl="Kills",       tip="Spoofs kill count in all Rivals UIs",          min=0,max=999999,step=1},
        {k="SpoofDeaths",  vk="FakeDeaths",  lbl="Deaths",      tip="Spoofs death count in all stat displays",      min=0,max=999999,step=1},
        {k="SpoofStreak",  vk="FakeStreak",  lbl="Win Streak",  tip="Win streak shown above head + in leaderboard", min=0,max=9999,  step=1},
        {k="SpoofWins",    vk="FakeWins",    lbl="Wins",        tip="Total duel wins on Career page",               min=0,max=999999,step=1},
        {k="SpoofLosses",  vk="FakeLosses",  lbl="Losses",      tip="Total losses shown in Career stats",           min=0,max=999999,step=1},
        {k="SpoofELO",     vk="FakeELO",     lbl="ELO",         tip="Spoofs ELO rating — rank auto-calculates",     min=0,max=5000,  step=25},
        {k="SpoofLevel",   vk="FakeLevel",   lbl="Career Level",tip="Career level shown in lobby + menus",          min=1,max=999,   step=1},
    }

    for i,def in ipairs(statDefs) do
        local base = i*3
        secHead(tStats, def.lbl, base-2)

        local cToggle = card(tStats, base-1)
        rowLabel(cToggle, "Spoof "..def.lbl, def.tip)
        toggle(cToggle, def.k)

        local cVal = card(tStats, base)
        rowLabel(cVal, def.lbl.." Value","")
        slider(cVal, def.vk, def.min, def.max, def.step)
    end

    -- ELO rank preview
    secHead(tStats, "Rank Preview", 50)
    local cRank = card(tStats, 51)
    local rankPreviewLbl = new("TextLabel",{
        Size=UDim2.new(1,-24,1,0), BackgroundTransparency=1,
        Text="Rank: "..eloToRank(CFG.FakeELO).."  |  ELO: "..CFG.FakeELO,
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=T.Accent,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cRank)
    -- Update rank preview every second
    task.spawn(function()
        while rankPreviewLbl and rankPreviewLbl.Parent do
            rankPreviewLbl.Text = "Rank: "..eloToRank(CFG.FakeELO).."  |  ELO: "..CFG.FakeELO
            task.wait(1)
        end
    end)

    secHead(tStats, "Apply Scope", 52)
    local cCareer = card(tStats,53)
    rowLabel(cCareer,"Apply to Career Page","Patch Rivals Career page with spoofed stats")
    toggle(cCareer,"ApplyToCareer")

    local cLDB = card(tStats,54)
    rowLabel(cLDB,"Apply to Leaderboard","Patch in-game leaderboard with spoofed stats")
    toggle(cLDB,"ApplyToLDB")

    -- ── STATUS TAB ────────────────────────────────────────
    local tStatus = makeScroll("status")

    secHead(tStatus,"Account Badge",1)
    local cBadge = card(tStatus,2,40)
    rowLabel(cBadge,"Status Badge","Badge prepended to your display name")
    dropdown(cBadge,"StatusBadge",{"None","Roblox+","Moderator","Developer","RobloxMod"})

    -- Badge preview
    local cBadgePrev = card(tStatus,3,40)
    local prevLbl = new("TextLabel",{
        Size=UDim2.new(1,-24,1,0), BackgroundTransparency=1,
        Text="Preview: "..spoofDisplay(),
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=T.Accent,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cBadgePrev)
    task.spawn(function()
        while prevLbl and prevLbl.Parent do
            prevLbl.Text = "Preview:  "..spoofDisplay()
            task.wait(0.5)
        end
    end)

    secHead(tStatus,"Rank Season Spoofer",4)
    local cRankE = card(tStatus,5)
    rowLabel(cRankE,"Enable Rank Spoof","Replaces rank tier text in all Rivals UIs")
    toggle(cRankE,"RankSpoofEnabled")

    local cRankSeason = card(tStatus,6,40)
    rowLabel(cRankSeason,"Season","Season 0, 1 or 2")
    dropdown(cRankSeason,"RankSeason",{"Season 0","Season 1","Season 2"})

    local cRankTier = card(tStatus,7,40)
    rowLabel(cRankTier,"Rank Tier","Rank shown in place of real rank")
    dropdown(cRankTier,"RankTier",{
        "Unranked","Bronze III","Bronze II","Bronze I",
        "Silver III","Silver II","Silver I",
        "Gold III","Gold II","Gold I",
        "Platinum III","Platinum II","Platinum I",
        "Diamond III","Diamond II","Diamond I",
        "Onyx III","Onyx II","Onyx I",
        "Nemesis","Archnemesis",
    })

    -- ── KILL FEED TAB ─────────────────────────────────────
    local tKF = makeScroll("killfeed")

    secHead(tKF,"Kill Feed Override",1)
    local ckfE = card(tKF,2)
    rowLabel(ckfE,"Enable Kill Feed Spoof","Override kill feed entries with custom text")
    toggle(ckfE,"SpoofKillfeed")

    local ckfKiller = card(tKF,3)
    rowLabel(ckfKiller,"Killer Name","Name shown as killer in custom feed")
    textInput(ckfKiller,"KFKiller","anomia")

    local ckfVictim = card(tKF,4)
    rowLabel(ckfVictim,"Victim Name","Name shown as victim in custom feed")
    textInput(ckfVictim,"KFVictim","target")

    local ckfWeapon = card(tKF,5)
    rowLabel(ckfWeapon,"Weapon","Weapon string in feed")
    textInput(ckfWeapon,"KFWeapon","AK-47")

    local ckfStyle = card(tKF,6,40)
    rowLabel(ckfStyle,"Style","Visual style of the kill feed text")
    dropdown(ckfStyle,"KFStyle",{"Clean","Arrow","Bracket","Hacker","Minimal"})

    secHead(tKF,"Test",7)
    actionBtn(tKF,"Fire Test Entry",T.Accent,8,function()
        pushKF(CFG.KFKiller, CFG.KFWeapon, CFG.KFVictim)
    end)

    -- ── SKINS TAB ─────────────────────────────────────────
    local tSkins = makeScroll("skins")

    secHead(tSkins,"Visual Cosmetic Unlock",1)
    local note = card(tSkins,2,44)
    new("TextLabel",{
        Size=UDim2.new(1,-24,1,0), BackgroundTransparency=1,
        Text="All unlocks are client-side visuals only.",
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=T.TextSec,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
    }, note)

    local cSkinAll = card(tSkins,3)
    rowLabel(cSkinAll,"Unlock All Skins","Visually unlocks all weapon skins (your view only)")
    toggle(cSkinAll,"SkinUnlockAll",function(v)
        if v then
            -- Scan workspace for weapon tools and try to visually apply
            task.spawn(function()
                local char = lp.Character
                if not char then return end
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, part in ipairs(tool:GetDescendants()) do
                            if part:IsA("SpecialMesh") then
                                part.TextureId = "rbxassetid://0"
                            end
                        end
                    end
                end
            end)
        end
    end)

    local cWrapAll = card(tSkins,4)
    rowLabel(cWrapAll,"Unlock All Wraps","Visually marks all wraps as owned in UI")
    toggle(cWrapAll,"WrapUnlockAll")

    local cCharmAll = card(tSkins,5)
    rowLabel(cCharmAll,"Unlock All Charms","Marks all charms as owned in UI")
    toggle(cCharmAll,"CharmUnlockAll")

    secHead(tSkins,"Skin Selection",6)
    local skinList = {
        "Default","AK-47 Phoenix","AK-47 Dark Matter","AKEY-47 Mythical",
        "Boneclaw Rifle","Void SMG","Pixel Pistol",
        "Tommy Gun Legendary","Warp Handgun","Nemesis Blade",
        "Crystal Rifle","Obsidian Shotgun","Rainbow Wrap","Chibi AK",
    }
    local cSkinPick = card(tSkins,7,40)
    rowLabel(cSkinPick,"Equipped Skin","Skin displayed in your UI/watermark")
    dropdown(cSkinPick,"SelectedSkin",skinList)

    local cSkinPrev = card(tSkins,8,44)
    local skinPrevLbl = new("TextLabel",{
        Size=UDim2.new(1,-24,1,0), BackgroundTransparency=1,
        Text="",
        Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=T.Accent,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, cSkinPrev)
    task.spawn(function()
        while skinPrevLbl and skinPrevLbl.Parent do
            skinPrevLbl.Text = "Active: "..CFG.SelectedSkin
                ..(CFG.SkinUnlockAll and "  [ALL UNLOCKED]" or "")
            task.wait(0.5)
        end
    end)

    -- ── WATERMARK TAB ─────────────────────────────────────
    local tWM = makeScroll("watermark")

    secHead(tWM,"Watermark",1)
    local cwmE = card(tWM,2)
    rowLabel(cwmE,"Show Watermark","Toggle the anomia watermark overlay")
    toggle(cwmE,"WMEnabled",function(v)
        if WM_GUI then WM_GUI.Enabled=v end
    end)

    local cwmText = card(tWM,3)
    rowLabel(cwmText,"Main Text","Primary watermark line")
    textInput(cwmText,"WMText","anomia  |  v2",function(v)
        if WM_MAIN then WM_MAIN.Text=v end
    end)

    local cwmSub = card(tWM,4)
    rowLabel(cwmSub,"Auto Sub-Text","Auto-fill name/ping/fps/region")
    toggle(cwmSub,"WMSubAuto")

    local cwmSubText = card(tWM,5)
    rowLabel(cwmSubText,"Custom Sub-Text","Used when Auto Sub-Text is off")
    textInput(cwmSubText,"WMSubText","custom line here")

    local cwmSize = card(tWM,6)
    rowLabel(cwmSize,"Font Size","")
    slider(cwmSize,"WMSize",8,22,1,function(v)
        if WM_MAIN then WM_MAIN.TextSize=v end
    end)

    local cwmRainbow = card(tWM,7)
    rowLabel(cwmRainbow,"Rainbow Text","Cycles watermark through hue spectrum")
    toggle(cwmRainbow,"WMRainbow")

    -- ── EXTRA TAB ─────────────────────────────────────────
    local tExtra = makeScroll("extra")

    secHead(tExtra,"Extra Utilities",1)

    local extras = {
        {k="InfJump",   l="Infinite Jump",       t="Jump infinitely mid-air",               cb=function(v) if v then startInfJump() end end},
        {k="Noclip",    l="Noclip",               t="Phase through all collision",            cb=function(v) if v then startNoclip() end end},
        {k="FakeAFK",   l="Anti-AFK",             t="Nudge character every 55s to avoid kick",cb=function(v) if v then startFakeAFK() end end},
        {k="AntiDead",  l="Skip Death Screen",    t="Attempt to skip elimination overlay",    cb=nil},
        {k="CleanHUD",  l="Clean HUD",            t="Hide health/backpack via CoreGui toggle", cb=function(v)
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,  not v)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not v)
            end)
        end},
        {k="ESPNames",  l="ESP Player Names",     t="Billboard name labels through walls",    cb=nil},
    }

    for i, ex in ipairs(extras) do
        local cx = card(tExtra, i+1)
        rowLabel(cx, ex.l, ex.t)
        toggle(cx, ex.k, ex.cb)
    end

    -- ── CONFIG TAB ────────────────────────────────────────
    local tCfg = makeScroll("config")

    secHead(tCfg,"Appearance",1)
    local cTheme = card(tCfg,2,40)
    rowLabel(cTheme,"Theme","Dark = deep blue-black  |  Light = clean white")
    dropdown(cTheme,"Theme",{"Dark","Light"},function(v)
        CFG.Theme=v
        applyTheme()
        if WM_GUI then buildWatermark() end
        if LDB_GUI then buildLDB() end
    end)

    secHead(tCfg,"Config Slots",3)
    for slot=1,3 do
        local cSlot = card(tCfg, 3+slot*2-1, 40)
        rowLabel(cSlot,"Slot "..slot..(CFG.ConfigSlot==slot and "  (active)" or ""),"Config slot "..slot)
        local slotFrame = new("Frame",{
            Size=UDim2.new(0,200,0,26),
            Position=UDim2.new(1,-200,0.5,-13),
            BackgroundTransparency=1,
        }, cSlot)
        new("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,6),
            HorizontalAlignment=Enum.HorizontalAlignment.Right,
        }, slotFrame)

        local function miniBtn(txt, col, cb)
            local b = new("TextButton",{
                Size=UDim2.new(0,56,1,0),
                BackgroundColor3=col,BackgroundTransparency=0.25,
                Text=txt,Font=Enum.Font.GothamBold,TextSize=11,
                TextColor3=Color3.new(1,1,1),BorderSizePixel=0,
            }, slotFrame)
            corner(6, b)
            b.MouseEnter:Connect(function() tw(b,TI_FAST,{BackgroundTransparency=0}) end)
            b.MouseLeave:Connect(function() tw(b,TI_FAST,{BackgroundTransparency=0.25}) end)
            b.MouseButton1Click:Connect(cb)
        end
        local savedSlot = slot  -- capture
        miniBtn("Save",  Color3.fromRGB(50,165,80),  function() saveSlot(savedSlot) CFG.ConfigSlot=savedSlot
            pcall(function() StarterGui:SetCore("SendNotification",{Title="anomia",Text="Slot "..savedSlot.." saved",Duration=2}) end)
        end)
        miniBtn("Load",  Color3.fromRGB(50,120,210), function() loadSlot(savedSlot) CFG.ConfigSlot=savedSlot
            pcall(function() StarterGui:SetCore("SendNotification",{Title="anomia",Text="Slot "..savedSlot.." loaded",Duration=2}) end)
        end)
    end

    secHead(tCfg,"Keybinds",10)

    local bindDefs = {
        {lbl="Toggle Menu",      tip="Open/close the anomia menu",        k1="MenuKey",       k2="MenuKey2"},
        {lbl="Cycle Config Slot",tip="Switch between config slots 1-3",   k1="ConfigCycleKey",k2="ConfigCycleKey2"},
    }
    for i, bd in ipairs(bindDefs) do
        local cBind = card(tCfg, 10+i, 40)
        rowLabel(cBind, bd.lbl, bd.tip)
        local bindFrame = new("Frame",{
            Size=UDim2.new(0.46,0,0,26),
            Position=UDim2.new(0.52,0,0.5,-13),
            BackgroundTransparency=1,
        }, cBind)
        new("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,4),
        }, bindFrame)

        for _, kKey in ipairs({bd.k1, bd.k2}) do
            local box = new("TextButton",{
                Size=UDim2.new(0.5,-2,1,0),
                BackgroundColor3=T.Content,BackgroundTransparency=0.2,
                Text=CFG[kKey]=="" and "—" or CFG[kKey],
                Font=Enum.Font.GothamBold,TextSize=10,
                TextColor3=T.Accent, BorderSizePixel=0,
            }, bindFrame)
            corner(6, box)
            stroke(T.Border,1,0,box)
            local listening=false
            box.MouseButton1Click:Connect(function()
                if listening then return end
                listening=true
                box.Text="..."
                local conn
                conn = UIS.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    local kname = inp.KeyCode.Name
                    if kname=="Unknown" then kname="" end
                    CFG[kKey] = kname
                    box.Text = kname=="" and "—" or kname
                    listening=false
                    conn:Disconnect()
                end)
            end)
        end
    end

    -- ── HEADER TITLE UPDATER ──────────────────────────────
    task.spawn(function()
        local tabNames = {}
        for _,td in ipairs(TAB_DATA) do tabNames[td.id]=td.label end
        while headerTitle and headerTitle.Parent do
            headerTitle.Text = tabNames[activeTab] or "anomia"
            task.wait(0.2)
        end
    end)

    -- Show first tab
    if tabFrames[activeTab] then tabFrames[activeTab].Visible=true end
end

-- ┌─────────────────────────────────────────────────────┐
--   KEYBIND HANDLER
-- └─────────────────────────────────────────────────────┘
local ldbVisible = false
local cfgCycling = false

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    local kn = inp.KeyCode.Name

    -- Menu toggle (1 or 2 keys)
    if kn == CFG.MenuKey or (CFG.MenuKey2 ~= "" and kn == CFG.MenuKey2) then
        menuOpen = not menuOpen
        if MAIN_GUI then
            MAIN_GUI.Enabled = menuOpen
        end
    end

    -- Leaderboard toggle (Tab key)
    if inp.KeyCode == Enum.KeyCode.Tab then
        ldbVisible = not ldbVisible
        if LDB_GUI then
            LDB_GUI.Enabled = ldbVisible
            if ldbVisible then refreshLDB() end
        end
    end

    -- Config slot cycling
    if kn == CFG.ConfigCycleKey or (CFG.ConfigCycleKey2~="" and kn==CFG.ConfigCycleKey2) then
        if not cfgCycling then
            cfgCycling = true
            CFG.ConfigSlot = (CFG.ConfigSlot % 3) + 1
            loadSlot(CFG.ConfigSlot)
            pcall(function()
                StarterGui:SetCore("SendNotification",{
                    Title="anomia",
                    Text="Config slot "..CFG.ConfigSlot.." loaded",
                    Duration=2,
                })
            end)
            task.delay(0.5, function() cfgCycling=false end)
        end
    end
end)

-- ┌─────────────────────────────────────────────────────┐
--   LEADERBOARD REFRESH LOOP  (3s — light)
-- └─────────────────────────────────────────────────────┘
task.spawn(function()
    while true do
        task.wait(3)
        if ldbVisible and LDB_GUI then
            refreshLDB()
        end
    end
end)

-- ┌─────────────────────────────────────────────────────┐
--   INIT
-- └─────────────────────────────────────────────────────┘
local function init()
    disableVanillaLDB()
    buildLDB()
    buildKFGui()
    buildWatermark()
    buildUI()

    task.spawn(function()
        task.wait(1.2)
        pcall(function()
            StarterGui:SetCore("SendNotification",{
                Title = "anomia  |  v2",
                Text  = "Rivals spoofer loaded — "..CFG.MenuKey.." to toggle menu",
                Duration = 5,
            })
        end)
    end)
end

init()
