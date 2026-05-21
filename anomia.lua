-- ═══════════════════════════════════════════════════
--  ANOMIA  v2.1  |  RIVALS SPOOFER
--  inject via any executor  |  RightShift = menu
-- ═══════════════════════════════════════════════════

-- ── SERVICES ────────────────────────────────────────
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local TweenSvc    = game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local Http        = game:GetService("HttpService")
local SG          = game:GetService("StarterGui")
local CG          = game:GetService("CoreGui")

local lp  = Players.LocalPlayer
local lpg = lp:WaitForChild("PlayerGui")

-- ── CONFIG ───────────────────────────────────────────
local CFG = {
    -- Identity
    SpoofUsername = true,   FakeUsername = "AnoPlayer",
    SpoofDisplay  = true,   FakeDisplay  = "anomia",
    ShowOnKillfeed = true,

    -- Perf display (watermark only)
    SpoofPing  = true, FakePing   = 9,
    SpoofFPS   = true, FakeFPS    = 240,
    SpoofRegion= true, FakeRegion = "EU-West",

    -- Stats
    SpoofKills   = true, FakeKills   = 9999,
    SpoofDeaths  = true, FakeDeaths  = 1,
    SpoofStreak  = true, FakeStreak  = 999,
    SpoofWins    = true, FakeWins    = 9999,
    SpoofLosses  = true, FakeLosses  = 0,
    SpoofELO     = true, FakeELO     = 3800,
    SpoofLevel   = true, FakeLevel   = 999,

    -- Rank season
    RankSpoof  = false,
    RankSeason = "Season 2",
    RankTier   = "Nemesis",

    -- Status badge
    StatusBadge = "None",

    -- Skins
    SkinUnlockAll  = false,
    WrapUnlockAll  = false,
    CharmUnlockAll = false,
    SelectedSkin   = "Default",

    -- Kill feed
    SpoofKF = true,
    KFKiller = "anomia",
    KFVictim = "target",
    KFWeapon = "AK-47",
    KFStyle  = "Clean",

    -- Watermark
    WMEnabled  = true,
    WMText     = "anomia  |  v2.1",
    WMSubAuto  = true,
    WMSubText  = "",
    WMRainbow  = false,
    WMSize     = 13,

    -- Extra
    InfJump  = false,
    Noclip   = false,
    FakeAFK  = false,
    CleanHUD = false,

    -- UI
    Theme           = "Dark",
    MenuKey         = "RightShift",
    MenuKey2        = "",
    CfgCycleKey     = "F8",
    CfgCycleKey2    = "",
    ConfigSlot      = 1,
}

-- ── THEMES ───────────────────────────────────────────
local TH = {
    Dark = {
        Win    = Color3.fromRGB(9,   11,  18),
        Side   = Color3.fromRGB(7,    9,  15),
        Cont   = Color3.fromRGB(12,  14,  22),
        Card   = Color3.fromRGB(17,  19,  30),
        CardH  = Color3.fromRGB(22,  24,  37),
        Acc    = Color3.fromRGB(96,  168, 255),
        AccDim = Color3.fromRGB(48,  95,  178),
        TxtP   = Color3.fromRGB(228, 232, 245),
        TxtS   = Color3.fromRGB(100, 108, 140),
        Bdr    = Color3.fromRGB(24,  27,  43),
        Logo   = Color3.fromRGB(255, 255, 255),
        TonOff = Color3.fromRGB(36,  38,  55),
        TonOn  = Color3.fromRGB(96,  168, 255),
        WM     = Color3.fromRGB(9,   11,  18),
    },
    Light = {
        Win    = Color3.fromRGB(248, 249, 254),
        Side   = Color3.fromRGB(236, 238, 248),
        Cont   = Color3.fromRGB(252, 253, 255),
        Card   = Color3.fromRGB(255, 255, 255),
        CardH  = Color3.fromRGB(241, 243, 253),
        Acc    = Color3.fromRGB(52,  120, 230),
        AccDim = Color3.fromRGB(28,   78, 178),
        TxtP   = Color3.fromRGB(14,  16,  28),
        TxtS   = Color3.fromRGB(95,  103, 132),
        Bdr    = Color3.fromRGB(212, 216, 232),
        Logo   = Color3.fromRGB(10,  12,  22),
        TonOff = Color3.fromRGB(198, 202, 218),
        TonOn  = Color3.fromRGB(52,  120, 230),
        WM     = Color3.fromRGB(248, 249, 254),
    },
}
local T = TH[CFG.Theme]
local function rt() T = TH[CFG.Theme] end

-- ── SAVE/LOAD ─────────────────────────────────────────
local CFGF = "anomia_rivals_v21_slot"
local function saveSlot(s)
    if not writefile then return end
    local o={}
    for k,v in pairs(CFG) do
        if type(v)~="userdata" and type(v)~="function" then o[k]=v end
    end
    pcall(writefile, CFGF..s..".json", Http:JSONEncode(o))
end
local function loadSlot(s)
    if not readfile then return end
    local ok,raw = pcall(readfile, CFGF..s..".json")
    if not ok or not raw then return end
    local ok2,tbl = pcall(function() return Http:JSONDecode(raw) end)
    if not ok2 or not tbl then return end
    for k,v in pairs(tbl) do
        if CFG[k]~=nil and type(CFG[k])==type(v) then CFG[k]=v end
    end
    rt()
end
loadSlot(CFG.ConfigSlot)

-- ── UTIL ─────────────────────────────────────────────
local TI_F = TweenInfo.new(0.16, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out)
local TI_M = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tw(i,ti,p) TweenSvc:Create(i,ti,p):Play() end

local function new(c,p,par)
    local i=Instance.new(c)
    for k,v in pairs(p or {}) do i[k]=v end
    if par then i.Parent=par end
    return i
end

local function cor(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function str(c,th,tr,p) return new("UIStroke",{Color=c,Thickness=th,Transparency=tr or 0},p) end
local function pd(t,b,l,r,p)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),
        PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)
    },p)
end

local function hsvC(t) return Color3.fromHSV(t%1,0.8,1) end

local RANKS = {
    [0]="Unranked",[200]="Bronze III",[400]="Bronze II",[600]="Bronze I",
    [800]="Silver III",[1000]="Silver II",[1200]="Silver I",
    [1400]="Gold III",[1600]="Gold II",[1800]="Gold I",
    [2000]="Plat III",[2200]="Plat II",[2400]="Plat I",
    [2600]="Diamond III",[2800]="Diamond II",[3000]="Diamond I",
    [3200]="Onyx III",[3400]="Onyx II",[3600]="Nemesis",[4000]="Archnemesis",
}
local function elo2rank(e)
    local b,bv="Unranked",0
    for t,n in pairs(RANKS) do
        if e>=t and t>=bv then b=n;bv=t end
    end
    return b
end

local BADGE = {
    None="",["Roblox+"]="[R+] ",Moderator="[MOD] ",
    Developer="[DEV] ",RobloxMod="[RBLX] ",
}

local function fakeName()
    return CFG.SpoofUsername and CFG.FakeUsername or lp.Name
end
local function fakeDisplay()
    local b=BADGE[CFG.StatusBadge] or ""
    return b..(CFG.SpoofDisplay and CFG.FakeDisplay or lp.DisplayName)
end

-- ═══════════════════════════════════════════════════
--  SPOOF ENGINE
--  Strategy:
--   1. hookLabel  → patches immediately + on every Text change
--   2. scanTree   → batched DescendantAdded + initial sweep
--   3. 350ms pulse → re-applies on cached labels Rivals keeps overwriting
--   4. Rivals billboard → patches Rivals' own streak BillboardGui
-- ═══════════════════════════════════════════════════

local hooked  = {}  -- [label] = true  (prevents double-hooking)
local cached  = {}  -- [label] = true  (labels we actively keep patching)
setmetatable(hooked, {__mode="k"})
setmetatable(cached, {__mode="k"})

-- Stat replace patterns  {pattern, replacement_fn, cfg_key}
local PATS = {
    {"Kills:%s*%d+",          function() return "Kills: "..CFG.FakeKills           end,"SpoofKills"},
    {"Eliminations:%s*%d+",   function() return "Eliminations: "..CFG.FakeKills    end,"SpoofKills"},
    {"Elims:%s*%d+",          function() return "Elims: "..CFG.FakeKills            end,"SpoofKills"},
    {"Deaths:%s*%d+",         function() return "Deaths: "..CFG.FakeDeaths         end,"SpoofDeaths"},
    {"Winstreak:%s*%d+",      function() return "Winstreak: "..CFG.FakeStreak      end,"SpoofStreak"},
    {"Win Streak:%s*%d+",     function() return "Win Streak: "..CFG.FakeStreak     end,"SpoofStreak"},
    {"Streak:%s*%d+",         function() return "Streak: "..CFG.FakeStreak         end,"SpoofStreak"},
    {"Wins:%s*%d+",           function() return "Wins: "..CFG.FakeWins             end,"SpoofWins"},
    {"Duel Wins:%s*%d+",      function() return "Duel Wins: "..CFG.FakeWins        end,"SpoofWins"},
    {"Losses:%s*%d+",         function() return "Losses: "..CFG.FakeLosses         end,"SpoofLosses"},
    {"ELO:%s*%d+",            function() return "ELO: "..CFG.FakeELO               end,"SpoofELO"},
    {"Elo:%s*%d+",            function() return "Elo: "..CFG.FakeELO               end,"SpoofELO"},
    {"%d+ ELO",               function() return CFG.FakeELO.." ELO"               end,"SpoofELO"},
    {"%d+ Elo",               function() return CFG.FakeELO.." Elo"               end,"SpoofELO"},
    {"Level:%s*%d+",          function() return "Level: "..CFG.FakeLevel           end,"SpoofLevel"},
    {"Lvl%s*%d+",             function() return "Lvl "..CFG.FakeLevel              end,"SpoofLevel"},
    -- Rank tier replacements
    {"Bronze%s?[III|II|I]*",  function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Silver%s?[III|II|I]*",  function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Gold%s?[III|II|I]*",    function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Platinum%s?[III|II|I]*",function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Diamond%s?[III|II|I]*", function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Onyx%s?[III|II|I]*",    function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Nemesis",               function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Archnemesis",           function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Unranked",              function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
}

local function applySpoof(lbl)
    local orig = lbl.Text
    local t    = orig

    -- Name replacement
    if CFG.SpoofUsername and lp.Name ~= "" then
        t = t:gsub(lp.Name, fakeName())
    end
    if CFG.SpoofDisplay and lp.DisplayName ~= "" then
        t = t:gsub(lp.DisplayName, fakeDisplay())
    end

    -- Stat/rank replacements
    for _,def in ipairs(PATS) do
        local pat,fn,key = def[1],def[2],def[3]
        if CFG[key] then
            local rep = fn()
            if rep then t = t:gsub(pat, rep) end
        end
    end

    -- Rivals streak: if the label IS just a number and streak spoof is on
    if CFG.SpoofStreak then
        if t:match("^%d+$") then
            t = tostring(CFG.FakeStreak)
        end
        -- "X Streak" format Rivals uses
        t = t:gsub("^(%d+)( Streak)$", CFG.FakeStreak.."%2")
    end

    if t ~= orig then
        lbl.Text = t
        return true  -- changed
    end
    return false
end

local function hookLabel(obj)
    if hooked[obj] then return end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    hooked[obj] = true

    local busy = false
    local function patch()
        if busy then return end
        busy = true
        local changed = pcall(applySpoof, obj)
        cached[obj] = true   -- always keep in cache; Rivals may overwrite
        busy = false
    end

    patch()
    obj:GetPropertyChangedSignal("Text"):Connect(patch)
end

local function scanTree(root)
    task.spawn(function()
        local d = root:GetDescendants()
        for i=1,#d do
            pcall(hookLabel, d[i])
            if i%60==0 then task.wait() end   -- yield every 60 so no frame spikes
        end
    end)
    root.DescendantAdded:Connect(function(v)
        task.defer(function() pcall(hookLabel, v) end)  -- defer = next frame, 0 cost now
    end)
end

-- 350ms pulse: re-applies to the small cache set Rivals keeps overwriting
task.spawn(function()
    while true do
        task.wait(0.35)
        for lbl in pairs(cached) do
            if lbl and lbl.Parent then
                local busy = false
                if not busy then
                    busy=true
                    pcall(applySpoof, lbl)
                    busy=false
                end
            else
                cached[lbl] = nil
            end
        end
    end
end)

-- Initial scans
task.spawn(function()
    task.wait(1.5)
    scanTree(lpg)
    pcall(scanTree, CG)
end)

lpg.ChildAdded:Connect(function(c)
    task.wait(0.08)
    pcall(scanTree, c)
end)

lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    pcall(scanTree, CG)
end)

-- ═══════════════════════════════════════════════════
--  RIVALS STREAK BILLBOARD PATCH
--  Rivals renders a BillboardGui on each player head
--  showing their win streak. We intercept it and force
--  our fake value without adding our own billboard.
-- ═══════════════════════════════════════════════════
local function patchRivalsBillboards(char)
    if not char then return end

    local function tryPatch(v)
        if not (v:IsA("BillboardGui") or v:IsA("SurfaceGui")) then return end
        -- Scan all TextLabels inside the billboard
        for _, lbl in ipairs(v:GetDescendants()) do
            if lbl:IsA("TextLabel") then
                hookLabel(lbl)
                -- Force-set if it looks like a streak number
                if CFG.SpoofStreak and lbl.Text:match("^%d+$") then
                    lbl.Text = tostring(CFG.FakeStreak)
                end
            end
        end
        v.DescendantAdded:Connect(function(d)
            task.defer(function()
                if d:IsA("TextLabel") then hookLabel(d) end
            end)
        end)
    end

    -- Patch existing
    for _,v in ipairs(char:GetDescendants()) do
        pcall(tryPatch, v)
    end
    -- Patch new ones Rivals spawns later
    char.DescendantAdded:Connect(function(v)
        task.defer(function() pcall(tryPatch, v) end)
    end)
end

if lp.Character then
    task.spawn(function() patchRivalsBillboards(lp.Character) end)
end
lp.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    patchRivalsBillboards(c)
end)

-- ═══════════════════════════════════════════════════
--  CUSTOM LEADERBOARD
-- ═══════════════════════════════════════════════════
local LDB_GUI, LDB_LIST, ldbOpen = nil, nil, false

local function killLDB()
    local ok = false
    for _=1,12 do
        ok = pcall(function()
            SG:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
        end)
        if ok then break end
        task.wait(0.1)
    end
end

local function buildLDB()
    if LDB_GUI then LDB_GUI:Destroy() end
    LDB_GUI = new("ScreenGui",{
        Name="AnoLDB",ResetOnSpawn=false,DisplayOrder=55,Enabled=false
    },lpg)

    local panel = new("Frame",{
        Size=UDim2.new(0,308,0,420),
        Position=UDim2.new(1,-322,0,58),
        BackgroundColor3=T.Win,
        BorderSizePixel=0,
    },LDB_GUI)
    cor(12,panel)
    str(T.Bdr,1.2,0,panel)

    -- header
    local hdr = new("Frame",{
        Size=UDim2.new(1,0,0,42),
        BackgroundColor3=T.Side,BorderSizePixel=0,
    },panel)
    cor(12,hdr)
    new("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),
        BackgroundColor3=T.Side,BorderSizePixel=0},hdr)
    local bar = new("Frame",{
        Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,12,0.5,-9),
        BackgroundColor3=T.Acc,BorderSizePixel=0,
    },hdr)
    cor(2,bar)
    new("TextLabel",{
        Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1,Text="Leaderboard",
        Font=Enum.Font.GothamBold,TextSize=13,
        TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left,
    },hdr)

    LDB_LIST = new("ScrollingFrame",{
        Size=UDim2.new(1,-16,1,-54),
        Position=UDim2.new(0,8,0,46),
        BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=2,
        ScrollBarImageColor3=T.Acc,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    },panel)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)},LDB_LIST)
end

local function refreshLDB()
    if not LDB_LIST then return end
    for _,c in ipairs(LDB_LIST:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local all = Players:GetPlayers()
    table.sort(all, function(a,b)
        local ak,bk=0,0
        pcall(function() ak=a.leaderstats.Kills.Value end)
        pcall(function() bk=b.leaderstats.Kills.Value end)
        return ak>bk
    end)
    for i,plr in ipairs(all) do
        local me = plr==lp
        local k,d,ws = 0,0,0
        pcall(function() k=plr.leaderstats.Kills.Value end)
        pcall(function() d=plr.leaderstats.Deaths.Value end)
        if me then
            if CFG.SpoofKills  then k=CFG.FakeKills  end
            if CFG.SpoofDeaths then d=CFG.FakeDeaths end
            if CFG.SpoofStreak then ws=CFG.FakeStreak end
        end
        local dn = me and fakeDisplay() or plr.DisplayName

        local row = new("Frame",{
            Size=UDim2.new(1,0,0,36),
            BackgroundColor3=me and T.Card or T.Cont,
            BackgroundTransparency=me and 0 or 0.25,
            BorderSizePixel=0,LayoutOrder=i,
        },LDB_LIST)
        cor(7,row)
        if me then str(T.Acc,1,0.5,row) end
        pd(0,0,8,8,row)

        new("TextLabel",{
            Size=UDim2.new(0,22,1,0),BackgroundTransparency=1,
            Text="#"..i,Font=Enum.Font.GothamBold,TextSize=11,
            TextColor3=T.Acc,
        },row)
        new("TextLabel",{
            Size=UDim2.new(0,130,1,0),Position=UDim2.new(0,26,0,0),
            BackgroundTransparency=1,Text=dn,
            Font=me and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize=12,TextColor3=me and T.Acc or T.TxtP,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,
        },row)
        new("TextLabel",{
            Size=UDim2.new(0,108,1,0),Position=UDim2.new(0,158,0,0),
            BackgroundTransparency=1,
            Text=k.."K  "..d.."D  "..ws.."WS",
            Font=Enum.Font.Gotham,TextSize=11,
            TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Right,
        },row)
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if ldbOpen and LDB_GUI then refreshLDB() end
    end
end)

-- ═══════════════════════════════════════════════════
--  KILL FEED OVERLAY
-- ═══════════════════════════════════════════════════
local KF_GUI, KF_FRAME
local KF_STYLES = {
    Clean   = function(k,w,v) return k.." killed "..v.." ["..w.."]" end,
    Arrow   = function(k,w,v) return k.." > "..v.." ("..w..")" end,
    Bracket = function(k,w,v) return "["..k.."]["..w.."]["..v.."]" end,
    Hacker  = function(k,w,v) return ">>"..k.."<<"..w..">>"..v.."<<" end,
    Minimal = function(k,w,v) return k.." + "..v end,
}

local function buildKF()
    if KF_GUI then KF_GUI:Destroy() end
    KF_GUI = new("ScreenGui",{Name="AnoKF",ResetOnSpawn=false,DisplayOrder=56},lpg)
    KF_FRAME = new("Frame",{
        Size=UDim2.new(0,340,0,200),
        Position=UDim2.new(1,-356,0,110),
        BackgroundTransparency=1,BorderSizePixel=0,
    },KF_GUI)
    new("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        Padding=UDim.new(0,3),
    },KF_FRAME)
end

local kfIdx=0
local function pushKF(k,w,v)
    if not KF_FRAME then return end
    kfIdx+=1
    local fn = KF_STYLES[CFG.KFStyle] or KF_STYLES.Clean
    local entry = new("Frame",{
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.45,
        BorderSizePixel=0,LayoutOrder=kfIdx,
    },KF_FRAME)
    cor(6,entry)
    new("TextLabel",{
        Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,
        Text=fn(k,w,v),
        Font=Enum.Font.GothamBold,TextSize=12,
        TextColor3=T.Acc,
        TextXAlignment=Enum.TextXAlignment.Right,
    },entry)
    task.delay(4,function()
        if not entry.Parent then return end
        tw(entry,TI_M,{BackgroundTransparency=1})
        for _,c in ipairs(entry:GetChildren()) do
            if c:IsA("TextLabel") then tw(c,TI_M,{TextTransparency=1}) end
        end
        task.wait(0.4)
        if entry.Parent then entry:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════
--  WATERMARK  (1s loop)
-- ═══════════════════════════════════════════════════
local WM_GUI, WM_MAIN, WM_SUB

local function buildWM()
    if WM_GUI then WM_GUI:Destroy() end
    WM_GUI = new("ScreenGui",{
        Name="AnoWM",ResetOnSpawn=false,
        DisplayOrder=100,Enabled=CFG.WMEnabled,
    },lpg)

    local f = new("Frame",{
        Position=UDim2.new(0,12,0,12),
        Size=UDim2.new(0,12,0,42),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=T.WM,
        BackgroundTransparency=0.06,BorderSizePixel=0,
    },WM_GUI)
    cor(10,f)
    str(T.Acc,1,0.5,f)
    pd(7,7,12,14,f)

    local vl = new("Frame",{
        Size=UDim2.new(0,1,1,0),AutomaticSize=Enum.AutomaticSize.XY,
        BackgroundTransparency=1,
    },f)
    new("UIListLayout",{
        SortOrder=Enum.SortOrder.LayoutOrder,
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,2),
    },vl)

    WM_MAIN = new("TextLabel",{
        Size=UDim2.new(0,1,0,18),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,Text=CFG.WMText,
        Font=Enum.Font.GothamBold,TextSize=CFG.WMSize,
        TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=1,
    },vl)
    WM_SUB = new("TextLabel",{
        Size=UDim2.new(0,1,0,14),AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1,Text="",
        Font=Enum.Font.Gotham,TextSize=11,
        TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=2,
    },vl)
end

task.spawn(function()
    local lastFPS = 60
    while true do
        task.wait(1)
        if WM_GUI and WM_GUI.Enabled then
            if WM_MAIN then
                WM_MAIN.Text = CFG.WMText
                WM_MAIN.TextSize = CFG.WMSize
                WM_MAIN.TextColor3 = CFG.WMRainbow and hsvC(tick()*0.2) or T.Acc
            end
            if WM_SUB then
                if CFG.WMSubAuto then
                    WM_SUB.Text = string.format(
                        "%s   %dms   %dfps   %s",
                        fakeName(),
                        CFG.SpoofPing and CFG.FakePing or 0,
                        CFG.SpoofFPS and CFG.FakeFPS or lastFPS,
                        CFG.SpoofRegion and CFG.FakeRegion or "?"
                    )
                else
                    WM_SUB.Text = CFG.WMSubText
                end
            end
        end
        -- lightweight fps sample
        local t0=tick()
        RunService.Heartbeat:Wait()
        lastFPS = math.floor(1/math.max(tick()-t0,0.001))
    end
end)

-- ═══════════════════════════════════════════════════
--  EXTRAS
-- ═══════════════════════════════════════════════════
local xConns = {}
local function xStop(k)
    if xConns[k] then pcall(function() xConns[k]:Disconnect() end); xConns[k]=nil end
end

local function startInfJump()
    xStop("ij")
    xConns["ij"] = UIS.JumpRequest:Connect(function()
        if not CFG.InfJump then xStop("ij") return end
        local c=lp.Character
        if c then
            local h=c:FindFirstChildWhichIsA("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

local ncConn
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    ncConn = RunService.Stepped:Connect(function()
        if not CFG.Noclip then ncConn:Disconnect() return end
        local c=lp.Character
        if c then
            for _,v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide=false end
            end
        end
    end)
end

local afkTh
local function startAFK()
    if afkTh then task.cancel(afkTh) end
    afkTh = task.spawn(function()
        while CFG.FakeAFK do
            task.wait(55)
            local c=lp.Character
            if c then
                local hrp=c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame=hrp.CFrame*CFrame.new(0.001,0,0) end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════
--  MAIN UI
--  710×480, sidebar 52px collapsed / 188px expanded,
--  no X button, dark/light theme, Fantasy "A" logo.
-- ═══════════════════════════════════════════════════
local MAIN_GUI, menuOpen = nil, true

local SB_C = 54       -- sidebar collapsed width
local SB_E = 188      -- sidebar expanded width

local TABS = {
    {id="identity", icon="🆔", lbl="Identity"},
    {id="stats",    icon="📊", lbl="Stats"},
    {id="status",   icon="🏅", lbl="Status"},
    {id="killfeed", icon="💀", lbl="Kill Feed"},
    {id="skins",    icon="🎨", lbl="Skins"},
    {id="watermark",icon="🔖", lbl="Watermark"},
    {id="extra",    icon="⚡", lbl="Extra"},
    {id="config",   icon="⚙", lbl="Config"},
}

local tabFrames = {}
local tabBtns   = {}
local activeTab = "identity"

-- Theme-registered instances for live re-theme
local themeR = {}   -- {inst, prop, key}
local function reg(i,p,k) themeR[#themeR+1]={i=i,p=p,k=k} end
local function applyTheme()
    rt()
    for _,r in ipairs(themeR) do
        if r.i and r.i.Parent then r.i[r.p]=T[r.k] end
    end
end

local function buildUI()
    if MAIN_GUI then MAIN_GUI:Destroy() end
    tabFrames,tabBtns,themeR = {},{},{}
    activeTab = "identity"

    MAIN_GUI = new("ScreenGui",{
        Name="AnoMain",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200,Enabled=menuOpen,
    },lpg)

    -- ── ROOT ─────────────────────────────────────────
    local root = new("Frame",{
        Name="Root",
        Size=UDim2.new(0,710,0,478),
        Position=UDim2.new(0.5,-355,0.5,-239),
        BackgroundColor3=T.Win,BorderSizePixel=0,
        ClipsDescendants=false,
    },MAIN_GUI)
    cor(14,root)
    local rStr = str(T.Bdr,1.2,0,root)
    reg(root,"BackgroundColor3","Win")
    reg(rStr,"Color","Bdr")

    -- inner clip (rounded corners mask content)
    local clip = new("Frame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        ClipsDescendants=true,
    },root)
    cor(14,clip)

    -- shadow (image-based, zero perf cost)
    new("ImageLabel",{
        Size=UDim2.new(1,44,1,44),Position=UDim2.new(0,-22,0,-22),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.5,
        ZIndex=0,ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
    },root)

    -- ── DRAG ─────────────────────────────────────────
    do
        local drag,ds,rs=false,nil,nil
        root.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true;ds=i.Position;rs=root.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-ds
                root.Position=UDim2.new(rs.X.Scale,rs.X.Offset+d.X,rs.Y.Scale,rs.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
    end

    -- ── SIDEBAR ──────────────────────────────────────
    local sb = new("Frame",{
        Name="Sidebar",
        Size=UDim2.new(0,SB_C,1,0),
        BackgroundColor3=T.Side,BorderSizePixel=0,
    },clip)
    cor(14,sb)
    -- flatten right side corners
    new("Frame",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),
        BackgroundColor3=T.Side,BorderSizePixel=0},sb)
    -- thin right border
    local sbSep = new("Frame",{
        Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Bdr,BorderSizePixel=0,
    },sb)
    reg(sb,"BackgroundColor3","Side")
    reg(sbSep,"BackgroundColor3","Bdr")

    -- ── LOGO ─────────────────────────────────────────
    local logoA = new("TextLabel",{
        Size=UDim2.new(0,SB_C,0,54),
        BackgroundTransparency=1,
        Text="A",
        Font=Enum.Font.Fantasy,TextSize=30,
        TextColor3=T.Logo,
        TextXAlignment=Enum.TextXAlignment.Center,
    },sb)
    reg(logoA,"TextColor3","Logo")

    local logoName = new("TextLabel",{
        Size=UDim2.new(1,-SB_C,0,54),
        Position=UDim2.new(0,SB_C+2,0,0),
        BackgroundTransparency=1,
        Text="anomia",
        Font=Enum.Font.GothamBold,TextSize=16,
        TextColor3=T.TxtP,TextTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
    },sb)
    reg(logoName,"TextColor3","TxtP")

    -- accent dot under A
    local logoDot = new("Frame",{
        Size=UDim2.new(0,4,0,4),
        Position=UDim2.new(0,SB_C/2-2,0,46),
        BackgroundColor3=T.Acc,BorderSizePixel=0,
    },sb)
    cor(3,logoDot)

    -- divider
    local logoDivF = new("Frame",{
        Size=UDim2.new(0.7,0,0,1),
        Position=UDim2.new(0.15,0,0,53),
        BackgroundColor3=T.Bdr,BorderSizePixel=0,
    },sb)
    reg(logoDivF,"BackgroundColor3","Bdr")

    -- ── TAB LIST ─────────────────────────────────────
    local tabList = new("Frame",{
        Size=UDim2.new(1,0,1,-62),
        Position=UDim2.new(0,0,0,62),
        BackgroundTransparency=1,
    },sb)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},tabList)
    pd(4,4,5,5,tabList)

    for i,td in ipairs(TABS) do
        local isA = td.id==activeTab
        local btn = new("TextButton",{
            Name=td.id,
            Size=UDim2.new(1,0,0,36),
            BackgroundColor3=isA and T.Card or T.Side,
            BackgroundTransparency=isA and 0 or 1,
            Text="",BorderSizePixel=0,LayoutOrder=i,
        },tabList)
        cor(8,btn)

        local aBar = new("Frame",{
            Size=UDim2.new(0,3,0,18),
            Position=UDim2.new(0,0,0.5,-9),
            BackgroundColor3=T.Acc,
            BackgroundTransparency=isA and 0 or 1,
            BorderSizePixel=0,
        },btn)
        cor(2,aBar)

        -- emoji icon (always renders, no image IDs needed)
        local ico = new("TextLabel",{
            Size=UDim2.new(0,SB_C,1,0),
            BackgroundTransparency=1,
            Text=td.icon,
            Font=Enum.Font.GothamBold,TextSize=16,
            TextColor3=isA and T.Acc or T.TxtS,
            TextXAlignment=Enum.TextXAlignment.Center,
        },btn)
        reg(ico,"TextColor3",isA and "Acc" or "TxtS")

        local lbl = new("TextLabel",{
            Size=UDim2.new(1,-SB_C,1,0),
            Position=UDim2.new(0,SB_C+2,0,0),
            BackgroundTransparency=1,
            Text=td.lbl,
            Font=isA and Enum.Font.GothamBold or Enum.Font.Gotham,
            TextSize=12,TextColor3=isA and T.Acc or T.TxtP,
            TextTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Left,
        },btn)
        reg(lbl,"TextColor3",isA and "Acc" or "TxtP")

        tabBtns[td.id] = {btn=btn,ico=ico,lbl=lbl,bar=aBar}

        btn.MouseEnter:Connect(function()
            if td.id~=activeTab then
                tw(btn,TI_F,{BackgroundTransparency=0.75,BackgroundColor3=T.Card})
            end
        end)
        btn.MouseLeave:Connect(function()
            if td.id~=activeTab then tw(btn,TI_F,{BackgroundTransparency=1}) end
        end)

        btn.MouseButton1Click:Connect(function()
            local prev = activeTab
            if prev==td.id then return end

            -- deactivate old
            local old = tabBtns[prev]
            if old then
                tw(old.btn,TI_F,{BackgroundTransparency=1})
                tw(old.bar,TI_F,{BackgroundTransparency=1})
                tw(old.ico,TI_F,{TextColor3=T.TxtS})
                tw(old.lbl,TI_F,{TextColor3=T.TxtP,TextTransparency=1})
                old.lbl.Font=Enum.Font.Gotham
            end
            if tabFrames[prev] then
                tabFrames[prev].Visible=false
            end

            activeTab = td.id
            tw(btn,TI_F,{BackgroundTransparency=0,BackgroundColor3=T.Card})
            tw(aBar,TI_F,{BackgroundTransparency=0})
            tw(ico,TI_F,{TextColor3=T.Acc})
            lbl.Font=Enum.Font.GothamBold
            -- lbl visibility controlled by sidebar expand state

            if tabFrames[activeTab] then
                tabFrames[activeTab].Visible=true
            end
        end)
    end

    -- ── SIDEBAR HOVER EXPAND ─────────────────────────
    local sbExp = false
    local sbTask

    local function expandSB()
        if sbExp then return end; sbExp=true
        tw(sb,TI_M,{Size=UDim2.new(0,SB_E,1,0)})
        tw(logoName,TI_M,{TextTransparency=0})
        for _,td in ipairs(TABS) do
            local r=tabBtns[td.id]
            if r then tw(r.lbl,TI_M,{TextTransparency=0}) end
        end
    end
    local function collapseSB()
        if not sbExp then return end; sbExp=false
        tw(sb,TI_M,{Size=UDim2.new(0,SB_C,1,0)})
        tw(logoName,TI_F,{TextTransparency=1})
        for _,td in ipairs(TABS) do
            local r=tabBtns[td.id]
            if r then tw(r.lbl,TI_F,{TextTransparency=1}) end
        end
    end

    sb.MouseEnter:Connect(function()
        sbTask = task.delay(0.3, expandSB)
    end)
    sb.MouseLeave:Connect(function()
        if sbTask then task.cancel(sbTask); sbTask=nil end
        collapseSB()
    end)

    -- ── CONTENT ──────────────────────────────────────
    local ca = new("Frame",{
        Size=UDim2.new(1,-SB_C-2,1,0),
        Position=UDim2.new(0,SB_C+2,0,0),
        BackgroundColor3=T.Cont,BorderSizePixel=0,
        ClipsDescendants=true,
    },clip)
    cor(14,ca)
    new("Frame",{Size=UDim2.new(0,14,1,0),BackgroundColor3=T.Cont,BorderSizePixel=0},ca)
    reg(ca,"BackgroundColor3","Cont")

    -- content header
    local ch = new("Frame",{
        Size=UDim2.new(1,0,0,46),
        BackgroundColor3=T.Side,BorderSizePixel=0,
    },ca)
    new("Frame",{
        Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),
        BackgroundColor3=T.Side,BorderSizePixel=0,
    },ch)
    reg(ch,"BackgroundColor3","Side")

    local chDiv = new("Frame",{
        Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),
        BackgroundColor3=T.Bdr,BorderSizePixel=0,
    },ch)
    reg(chDiv,"BackgroundColor3","Bdr")

    local chBar = new("Frame",{
        Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,12,0.5,-10),
        BackgroundColor3=T.Acc,BorderSizePixel=0,
    },ch)
    cor(2,chBar)

    local chTitle = new("TextLabel",{
        Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1,Text="Identity",
        Font=Enum.Font.GothamBold,TextSize=14,
        TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left,
    },ch)
    reg(chTitle,"TextColor3","TxtP")

    new("TextLabel",{
        Size=UDim2.new(0,100,1,0),Position=UDim2.new(1,-108,0,0),
        BackgroundTransparency=1,Text="anomia v2.1",
        Font=Enum.Font.Gotham,TextSize=11,
        TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Right,
    },ch)

    -- header title updater
    local TLABELS = {}
    for _,td in ipairs(TABS) do TLABELS[td.id]=td.lbl end
    task.spawn(function()
        while chTitle and chTitle.Parent do
            chTitle.Text = TLABELS[activeTab] or "anomia"
            chTitle.TextColor3 = T.TxtP
            chBar.BackgroundColor3 = T.Acc
            task.wait(0.15)
        end
    end)

    -- ── COMPONENT HELPERS ────────────────────────────

    local function makeScroll(tabId)
        local f = new("ScrollingFrame",{
            Name=tabId,
            Size=UDim2.new(1,0,1,-48),
            Position=UDim2.new(0,0,0,48),
            BackgroundColor3=T.Cont,
            BackgroundTransparency=0,
            BorderSizePixel=0,
            ScrollBarThickness=2,
            ScrollBarImageColor3=T.Acc,
            CanvasSize=UDim2.new(0,0,0,0),
            AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=tabId==activeTab,
        },ca)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},f)
        pd(10,12,12,12,f)
        tabFrames[tabId]=f
        reg(f,"BackgroundColor3","Cont")
        return f
    end

    local function secH(par,txt,lo)
        local f=new("Frame",{
            Size=UDim2.new(1,-4,0,20),BackgroundTransparency=1,LayoutOrder=lo or 1,
        },par)
        local ab=new("Frame",{
            Size=UDim2.new(0,3,0,12),Position=UDim2.new(0,0,0.5,-6),
            BackgroundColor3=T.Acc,BorderSizePixel=0,
        },f)
        cor(2,ab)
        new("TextLabel",{
            Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,7,0,0),
            BackgroundTransparency=1,Text=txt:upper(),
            Font=Enum.Font.GothamBold,TextSize=10,
            TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Left,
        },f)
        return f
    end

    local function crd(par,lo,h)
        h=h or 40
        local f=new("Frame",{
            Size=UDim2.new(1,0,0,h),BackgroundColor3=T.Card,
            BorderSizePixel=0,LayoutOrder=lo or 1,
        },par)
        cor(8,f)
        pd(0,0,12,12,f)
        f.MouseEnter:Connect(function() tw(f,TI_F,{BackgroundColor3=T.CardH}) end)
        f.MouseLeave:Connect(function() tw(f,TI_F,{BackgroundColor3=T.Card}) end)
        reg(f,"BackgroundColor3","Card")
        return f
    end

    local function rowLbl(par,txt,tip)
        local l=new("TextLabel",{
            Size=UDim2.new(0.5,-4,1,0),BackgroundTransparency=1,
            Text=txt,Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left,
        },par)
        reg(l,"TextColor3","TxtP")
        if tip then
            local ib=new("TextButton",{
                Size=UDim2.new(0,13,0,13),
                Position=UDim2.new(0,#txt*6.5+14,0.5,-6.5),
                BackgroundColor3=T.AccDim,BackgroundTransparency=0.35,
                Text="i",Font=Enum.Font.GothamBold,TextSize=8,
                TextColor3=Color3.new(1,1,1),BorderSizePixel=0,
            },par)
            cor(8,ib)
            local tt
            ib.MouseEnter:Connect(function()
                if tt then tt:Destroy() end
                tt=new("Frame",{
                    Size=UDim2.new(0,math.max(130,#tip*6.2),0,24),
                    Position=UDim2.new(0,0,1,3),
                    BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=40,
                },ib)
                cor(6,tt)
                str(T.Acc,1,0.5,tt)
                new("TextLabel",{
                    Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),
                    BackgroundTransparency=1,Text=tip,
                    Font=Enum.Font.Gotham,TextSize=10,
                    TextColor3=T.TxtP,ZIndex=40,
                    TextXAlignment=Enum.TextXAlignment.Left,
                },tt)
            end)
            ib.MouseLeave:Connect(function()
                if tt then tt:Destroy();tt=nil end
            end)
        end
        return l
    end

    local function tog(par,key,cb)
        local on=CFG[key]
        local track=new("TextButton",{
            Size=UDim2.new(0,42,0,22),
            Position=UDim2.new(1,-42,0.5,-11),
            BackgroundColor3=on and T.TonOn or T.TonOff,
            Text="",BorderSizePixel=0,
        },par)
        cor(11,track)
        local knob=new("Frame",{
            Size=UDim2.new(0,16,0,16),
            Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,
        },track)
        cor(9,knob)
        track.MouseButton1Click:Connect(function()
            CFG[key]=not CFG[key]
            local v=CFG[key]
            tw(track,TI_F,{BackgroundColor3=v and T.TonOn or T.TonOff})
            tw(knob,TI_F,{Position=v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)})
            if cb then cb(v) end
        end)
        return track
    end

    local function txInput(par,key,ph,cb)
        local bx=new("TextBox",{
            Size=UDim2.new(0.45,-4,0,26),
            Position=UDim2.new(0.53,0,0.5,-13),
            BackgroundColor3=T.Win,BackgroundTransparency=0.2,
            BorderSizePixel=0,
            Text=tostring(CFG[key] or ""),
            PlaceholderText=ph or "",
            Font=Enum.Font.Gotham,TextSize=12,
            TextColor3=T.TxtP,PlaceholderColor3=T.TxtS,
            ClearTextOnFocus=false,
        },par)
        cor(7,bx)
        str(T.Bdr,1,0,bx)
        reg(bx,"TextColor3","TxtP")
        bx.Focused:Connect(function()
            tw(bx,TI_F,{BackgroundTransparency=0})
            for _,s in ipairs(bx:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,TI_F,{Color=T.Acc}) end
            end
        end)
        bx.FocusLost:Connect(function()
            tw(bx,TI_F,{BackgroundTransparency=0.2})
            for _,s in ipairs(bx:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,TI_F,{Color=T.Bdr}) end
            end
            local v=bx.Text
            local n=tonumber(v)
            CFG[key]=(n~=nil and type(CFG[key])=="number") and n or v
            if cb then cb(CFG[key]) end
        end)
        return bx
    end

    local function ddrop(par,key,opts,cb)
        local cur=tostring(CFG[key] or opts[1])
        local open=false; local df

        local btn=new("TextButton",{
            Size=UDim2.new(0.45,-4,0,26),
            Position=UDim2.new(0.53,0,0.5,-13),
            BackgroundColor3=T.Win,BackgroundTransparency=0.2,
            BorderSizePixel=0,Text="",
        },par)
        cor(7,btn)
        str(T.Bdr,1,0,btn)

        local btxt=new("TextLabel",{
            Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,8,0,0),
            BackgroundTransparency=1,Text=cur,
            Font=Enum.Font.Gotham,TextSize=12,
            TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left,
        },btn)
        reg(btxt,"TextColor3","TxtP")
        local chev=new("TextLabel",{
            Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),
            BackgroundTransparency=1,Text="v",
            Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.TxtS,
        },btn)

        local function closeDrop()
            if df then df:Destroy();df=nil end
            open=false
            tw(chev,TI_F,{Rotation=0})
        end

        btn.MouseButton1Click:Connect(function()
            if open then closeDrop() return end
            open=true
            tw(chev,TI_F,{Rotation=180})
            local bap=btn.AbsolutePosition
            local bas=btn.AbsoluteSize
            local cap=ca.AbsolutePosition
            df=new("Frame",{
                Size=UDim2.new(0,bas.X,0,math.min(#opts,5)*28+6),
                Position=UDim2.new(0,bap.X-cap.X,0,bap.Y-cap.Y+bas.Y+3),
                BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=50,
                ClipsDescendants=true,
            },ca)
            cor(8,df)
            str(T.Acc,1,0.4,df)
            new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},df)
            pd(3,3,4,4,df)
            for i,opt in ipairs(opts) do
                local isc=opt==cur
                local ob=new("TextButton",{
                    Size=UDim2.new(1,0,0,24),
                    BackgroundColor3=isc and T.CardH or T.Card,
                    BackgroundTransparency=isc and 0 or 0.4,
                    Text="",BorderSizePixel=0,ZIndex=51,LayoutOrder=i,
                },df)
                cor(6,ob)
                new("TextLabel",{
                    Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
                    BackgroundTransparency=1,Text=opt,
                    Font=isc and Enum.Font.GothamBold or Enum.Font.Gotham,
                    TextSize=12,
                    TextColor3=isc and T.Acc or T.TxtP,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51,
                },ob)
                ob.MouseEnter:Connect(function() tw(ob,TI_F,{BackgroundTransparency=0}) end)
                ob.MouseLeave:Connect(function() tw(ob,TI_F,{BackgroundTransparency=isc and 0 or 0.4}) end)
                ob.MouseButton1Click:Connect(function()
                    cur=opt;CFG[key]=opt;btxt.Text=opt
                    closeDrop()
                    if cb then cb(opt) end
                end)
            end
        end)
        return btn
    end

    local function sldr(par,key,mn,mx,stp,cb)
        local pct0=(CFG[key]-mn)/(mx-mn)
        local vl=new("TextLabel",{
            Size=UDim2.new(0,40,0,26),
            Position=UDim2.new(1,-152,0.5,-13),
            BackgroundTransparency=1,
            Text=tostring(CFG[key]),
            Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Right,
        },par)
        local track=new("Frame",{
            Size=UDim2.new(0,96,0,4),
            Position=UDim2.new(1,-104,0.5,-2),
            BackgroundColor3=T.TonOff,BorderSizePixel=0,
        },par)
        cor(2,track)
        local fill=new("Frame",{
            Size=UDim2.new(pct0,0,1,0),
            BackgroundColor3=T.Acc,BorderSizePixel=0,
        },track)
        cor(2,fill)
        local knob=new("Frame",{
            Size=UDim2.new(0,12,0,12),
            Position=UDim2.new(pct0,-6,0.5,-6),
            BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,
        },track)
        cor(8,knob)
        local sl=false
        local function setV(x)
            local ap=track.AbsolutePosition
            local as=track.AbsoluteSize
            local p=math.clamp((x-ap.X)/as.X,0,1)
            local v=math.clamp(math.round((mn+p*(mx-mn))/stp)*stp,mn,mx)
            CFG[key]=v;vl.Text=tostring(v)
            local fp=(v-mn)/(mx-mn)
            tw(fill,TweenInfo.new(0.05),{Size=UDim2.new(fp,0,1,0)})
            tw(knob,TweenInfo.new(0.05),{Position=UDim2.new(fp,-6,0.5,-6)})
            if cb then cb(v) end
        end
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end
        end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                sl=true; setV(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if sl and i.UserInputType==Enum.UserInputType.MouseMovement then setV(i.Position.X) end
        end)
        return track
    end

    local function actBtn(par,txt,col,lo,cb)
        local r=crd(par,lo)
        local b=new("TextButton",{
            Size=UDim2.new(0,120,0,26),
            Position=UDim2.new(1,-122,0.5,-13),
            BackgroundColor3=col or T.Acc,BackgroundTransparency=0.2,
            Text=txt,Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=Color3.new(1,1,1),BorderSizePixel=0,
        },r)
        cor(7,b)
        b.MouseEnter:Connect(function() tw(b,TI_F,{BackgroundTransparency=0}) end)
        b.MouseLeave:Connect(function() tw(b,TI_F,{BackgroundTransparency=0.2}) end)
        b.MouseButton1Click:Connect(cb)
        new("TextLabel",{
            Size=UDim2.new(0.5,0,1,0),BackgroundTransparency=1,Text=txt,
            Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left,
        },r)
        return r
    end

    -- ════════════════════════════════════════════════
    --  IDENTITY TAB
    -- ════════════════════════════════════════════════
    local tId = makeScroll("identity")

    secH(tId,"Username",1)
    local c=crd(tId,2); rowLbl(c,"Spoof Username","Replaces your real username in Rivals UIs"); tog(c,"SpoofUsername")
    local c=crd(tId,3); rowLbl(c,"Fake Username","Username shown instead of your real one"); txInput(c,"FakeUsername","AnoPlayer")
    secH(tId,"Display Name",4)
    local c=crd(tId,5); rowLbl(c,"Spoof Display Name","Replaces display name in all Rivals UIs"); tog(c,"SpoofDisplay")
    local c=crd(tId,6); rowLbl(c,"Fake Display Name","The display name to show"); txInput(c,"FakeDisplay","anomia")
    secH(tId,"Performance Display",7)
    local c=crd(tId,8);  rowLbl(c,"Spoof Ping","Fake ping in watermark");tog(c,"SpoofPing")
    local c=crd(tId,9);  rowLbl(c,"Fake Ping (ms)","");sldr(c,"FakePing",1,999,1)
    local c=crd(tId,10); rowLbl(c,"Spoof FPS","Fake FPS in watermark");tog(c,"SpoofFPS")
    local c=crd(tId,11); rowLbl(c,"Fake FPS","");sldr(c,"FakeFPS",1,500,1)
    local c=crd(tId,12); rowLbl(c,"Spoof Region","Custom region string");tog(c,"SpoofRegion")
    local c=crd(tId,13); rowLbl(c,"Fake Region","e.g. EU-West, NA-East");txInput(c,"FakeRegion","EU-West")

    -- ════════════════════════════════════════════════
    --  STATS TAB
    -- ════════════════════════════════════════════════
    local tStats = makeScroll("stats")
    local sDefs = {
        {k="SpoofKills",  vk="FakeKills",  l="Kills",       t="Kills in kill feed, career, leaderboard", mn=0,mx=999999,sp=1},
        {k="SpoofDeaths", vk="FakeDeaths", l="Deaths",      t="Deaths shown in career stats",             mn=0,mx=999999,sp=1},
        {k="SpoofStreak", vk="FakeStreak", l="Win Streak",  t="Patches Rivals own streak billboard + all stat UIs",mn=0,mx=9999,sp=1},
        {k="SpoofWins",   vk="FakeWins",   l="Wins",        t="Total wins on career page",                mn=0,mx=999999,sp=1},
        {k="SpoofLosses", vk="FakeLosses", l="Losses",      t="Total losses on career page",              mn=0,mx=999999,sp=1},
        {k="SpoofELO",    vk="FakeELO",    l="ELO",         t="ELO + rank tier (rank auto-calculates)",   mn=0,mx=5000,  sp=25},
        {k="SpoofLevel",  vk="FakeLevel",  l="Career Level",t="Career level in lobby and menus",          mn=1,mx=999,   sp=1},
    }
    for i,d in ipairs(sDefs) do
        local b=i*3
        secH(tStats,d.l,b-2)
        local c=crd(tStats,b-1); rowLbl(c,"Spoof "..d.l,d.t); tog(c,d.k)
        local c=crd(tStats,b);   rowLbl(c,d.l.." Value",""); sldr(c,d.vk,d.mn,d.mx,d.sp)
    end
    secH(tStats,"Live Rank Preview",40)
    local cRank=crd(tStats,41)
    local rankPrev=new("TextLabel",{
        Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.GothamBold,TextSize=12,
        TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left,
    },cRank)
    task.spawn(function()
        while rankPrev and rankPrev.Parent do
            rankPrev.Text = elo2rank(CFG.FakeELO).."   (ELO "..CFG.FakeELO..")"
            task.wait(0.8)
        end
    end)

    -- ════════════════════════════════════════════════
    --  STATUS TAB
    -- ════════════════════════════════════════════════
    local tStatus = makeScroll("status")
    secH(tStatus,"Account Badge",1)
    local c=crd(tStatus,2,40); rowLbl(c,"Status Badge","Badge shown next to your name in all UIs")
    ddrop(c,"StatusBadge",{"None","Roblox+","Moderator","Developer","RobloxMod"})
    local cPrev=crd(tStatus,3)
    local prevL=new("TextLabel",{
        Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.GothamBold,TextSize=12,
        TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left,
    },cPrev)
    task.spawn(function()
        while prevL and prevL.Parent do
            prevL.Text="Preview:  "..fakeDisplay()
            task.wait(0.5)
        end
    end)
    secH(tStatus,"Rank Season Spoofer",4)
    local c=crd(tStatus,5); rowLbl(c,"Enable Rank Spoof","Replaces rank tier text across all Rivals UIs"); tog(c,"RankSpoof")
    local c=crd(tStatus,6,40); rowLbl(c,"Season","")
    ddrop(c,"RankSeason",{"Season 0","Season 1","Season 2"})
    local c=crd(tStatus,7,40); rowLbl(c,"Rank Tier","")
    ddrop(c,"RankTier",{
        "Unranked","Bronze III","Bronze II","Bronze I",
        "Silver III","Silver II","Silver I",
        "Gold III","Gold II","Gold I",
        "Platinum III","Platinum II","Platinum I",
        "Diamond III","Diamond II","Diamond I",
        "Onyx III","Onyx II","Onyx I",
        "Nemesis","Archnemesis",
    })

    -- ════════════════════════════════════════════════
    --  KILL FEED TAB
    -- ════════════════════════════════════════════════
    local tKF = makeScroll("killfeed")
    secH(tKF,"Kill Feed Override",1)
    local c=crd(tKF,2); rowLbl(c,"Enable KF Spoof","Override kill feed with custom text"); tog(c,"SpoofKF")
    local c=crd(tKF,3); rowLbl(c,"Killer Name",""); txInput(c,"KFKiller","anomia")
    local c=crd(tKF,4); rowLbl(c,"Victim Name",""); txInput(c,"KFVictim","target")
    local c=crd(tKF,5); rowLbl(c,"Weapon",""); txInput(c,"KFWeapon","AK-47")
    local c=crd(tKF,6,40); rowLbl(c,"Style","")
    ddrop(c,"KFStyle",{"Clean","Arrow","Bracket","Hacker","Minimal"})
    secH(tKF,"Test",7)
    actBtn(tKF,"Fire Test Entry",T.Acc,8,function()
        pushKF(CFG.KFKiller,CFG.KFWeapon,CFG.KFVictim)
    end)

    -- ════════════════════════════════════════════════
    --  SKINS TAB
    -- ════════════════════════════════════════════════
    local tSkins = makeScroll("skins")
    secH(tSkins,"Visual Cosmetic Unlock",1)
    local c=crd(tSkins,2); rowLbl(c,"Unlock All Skins","Marks all weapon skins as owned (visual, your view)"); tog(c,"SkinUnlockAll")
    local c=crd(tSkins,3); rowLbl(c,"Unlock All Wraps","Marks all wraps as owned"); tog(c,"WrapUnlockAll")
    local c=crd(tSkins,4); rowLbl(c,"Unlock All Charms","Marks all charms as owned"); tog(c,"CharmUnlockAll")
    secH(tSkins,"Skin Selection",5)
    local c=crd(tSkins,6,40); rowLbl(c,"Equipped Skin","")
    ddrop(c,"SelectedSkin",{
        "Default","AK-47 Phoenix","AK-47 Dark Matter","AKEY-47 Mythical",
        "Boneclaw Rifle","Void SMG","Pixel Pistol","Tommy Gun Legendary",
        "Warp Handgun","Nemesis Blade","Crystal Rifle","Obsidian Shotgun","Rainbow Wrap",
    })
    local cPv=crd(tSkins,7)
    local skinPL=new("TextLabel",{
        Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.GothamBold,TextSize=12,
        TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left,
    },cPv)
    task.spawn(function()
        while skinPL and skinPL.Parent do
            skinPL.Text = "Active: "..CFG.SelectedSkin..(CFG.SkinUnlockAll and "   [ALL]" or "")
            task.wait(0.5)
        end
    end)

    -- ════════════════════════════════════════════════
    --  WATERMARK TAB
    -- ════════════════════════════════════════════════
    local tWM = makeScroll("watermark")
    secH(tWM,"Watermark",1)
    local c=crd(tWM,2); rowLbl(c,"Show Watermark",""); tog(c,"WMEnabled",function(v) if WM_GUI then WM_GUI.Enabled=v end end)
    local c=crd(tWM,3); rowLbl(c,"Main Text",""); txInput(c,"WMText","anomia  |  v2.1",function(v) if WM_MAIN then WM_MAIN.Text=v end end)
    local c=crd(tWM,4); rowLbl(c,"Auto Sub-Text","Auto-fill name/ping/fps/region"); tog(c,"WMSubAuto")
    local c=crd(tWM,5); rowLbl(c,"Custom Sub-Text","Used when Auto is off"); txInput(c,"WMSubText","")
    local c=crd(tWM,6); rowLbl(c,"Font Size",""); sldr(c,"WMSize",8,22,1,function(v) if WM_MAIN then WM_MAIN.TextSize=v end end)
    local c=crd(tWM,7); rowLbl(c,"Rainbow Text","Cycles through hue spectrum"); tog(c,"WMRainbow")

    -- ════════════════════════════════════════════════
    --  EXTRA TAB
    -- ════════════════════════════════════════════════
    local tExt = makeScroll("extra")
    secH(tExt,"Utilities",1)
    local xd = {
        {k="InfJump", l="Infinite Jump",   t="Jump infinitely in air",              cb=function(v) if v then startInfJump() end end},
        {k="Noclip",  l="Noclip",          t="Phase through all collision geometry", cb=function(v) if v then startNoclip() end end},
        {k="FakeAFK", l="Anti-AFK",        t="Nudge every 55s to avoid AFK kick",   cb=function(v) if v then startAFK() end end},
        {k="CleanHUD",l="Clean HUD",       t="Hide health/backpack CoreGui elements",cb=function(v)
            pcall(function()
                SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health,not v)
                SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not v)
            end)
        end},
    }
    for i,x in ipairs(xd) do
        local c=crd(tExt,i+1); rowLbl(c,x.l,x.t); tog(c,x.k,x.cb)
    end

    -- ════════════════════════════════════════════════
    --  CONFIG TAB
    -- ════════════════════════════════════════════════
    local tCfg = makeScroll("config")
    secH(tCfg,"Theme",1)
    local c=crd(tCfg,2,40); rowLbl(c,"Theme","Dark = deep blue-black  |  Light = clean white")
    ddrop(c,"Theme",{"Dark","Light"},function(v)
        CFG.Theme=v; applyTheme()
        buildWM()
    end)

    secH(tCfg,"Config Slots",3)
    for s=1,3 do
        local c=crd(tCfg,3+s,44)
        rowLbl(c,"Slot "..s..(CFG.ConfigSlot==s and "  (active)" or ""),"Config slot "..s)
        local fr=new("Frame",{
            Size=UDim2.new(0,128,0,26),
            Position=UDim2.new(1,-130,0.5,-13),
            BackgroundTransparency=1,
        },c)
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5),HorizontalAlignment=Enum.HorizontalAlignment.Right},fr)
        local function mBtn(txt,col,cb2)
            local b=new("TextButton",{
                Size=UDim2.new(0,58,1,0),
                BackgroundColor3=col,BackgroundTransparency=0.25,
                Text=txt,Font=Enum.Font.GothamBold,TextSize=11,
                TextColor3=Color3.new(1,1,1),BorderSizePixel=0,
            },fr)
            cor(6,b)
            b.MouseEnter:Connect(function() tw(b,TI_F,{BackgroundTransparency=0}) end)
            b.MouseLeave:Connect(function() tw(b,TI_F,{BackgroundTransparency=0.25}) end)
            b.MouseButton1Click:Connect(cb2)
        end
        local slot=s
        mBtn("Save",Color3.fromRGB(44,160,74),function()
            saveSlot(slot);CFG.ConfigSlot=slot
            pcall(function() SG:SetCore("SendNotification",{Title="anomia",Text="Slot "..slot.." saved",Duration=2}) end)
        end)
        mBtn("Load",Color3.fromRGB(44,118,210),function()
            loadSlot(slot);CFG.ConfigSlot=slot
            pcall(function() SG:SetCore("SendNotification",{Title="anomia",Text="Slot "..slot.." loaded",Duration=2}) end)
        end)
    end

    secH(tCfg,"Keybinds",10)
    local kbDefs = {
        {l="Toggle Menu",      k1="MenuKey",    k2="MenuKey2"},
        {l="Cycle Config Slot",k1="CfgCycleKey",k2="CfgCycleKey2"},
    }
    for i,kd in ipairs(kbDefs) do
        local c=crd(tCfg,10+i,44)
        rowLbl(c,kd.l,"Press both keys or just one to bind")
        local fr=new("Frame",{
            Size=UDim2.new(0.45,0,0,26),
            Position=UDim2.new(0.53,0,0.5,-13),
            BackgroundTransparency=1,
        },c)
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)},fr)
        for _,kk in ipairs({kd.k1,kd.k2}) do
            local box=new("TextButton",{
                Size=UDim2.new(0.5,-2,1,0),
                BackgroundColor3=T.Win,BackgroundTransparency=0.2,
                Text=CFG[kk]=="" and "—" or CFG[kk],
                Font=Enum.Font.GothamBold,TextSize=10,
                TextColor3=T.Acc,BorderSizePixel=0,
            },fr)
            cor(6,box)
            str(T.Bdr,1,0,box)
            local ls=false
            box.MouseButton1Click:Connect(function()
                if ls then return end;ls=true;box.Text="..."
                local cn
                cn=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    local kn=inp.KeyCode.Name
                    if kn=="Unknown" then kn="" end
                    CFG[kk]=kn;box.Text=kn=="" and "—" or kn
                    ls=false;cn:Disconnect()
                end)
            end)
        end
    end

    -- ── show initial tab ──────────────────────────────
    if tabFrames[activeTab] then tabFrames[activeTab].Visible=true end
end

-- ═══════════════════════════════════════════════════
--  KEYBINDS
-- ═══════════════════════════════════════════════════
local cfgCooldown = false

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    local kn = inp.KeyCode.Name

    -- menu toggle
    if kn==CFG.MenuKey or (CFG.MenuKey2~="" and kn==CFG.MenuKey2) then
        menuOpen = not menuOpen
        if MAIN_GUI then MAIN_GUI.Enabled=menuOpen end
    end

    -- leaderboard
    if inp.KeyCode==Enum.KeyCode.Tab then
        ldbOpen = not ldbOpen
        if LDB_GUI then
            LDB_GUI.Enabled=ldbOpen
            if ldbOpen then refreshLDB() end
        end
    end

    -- config cycle
    if not cfgCooldown and (kn==CFG.CfgCycleKey or (CFG.CfgCycleKey2~="" and kn==CFG.CfgCycleKey2)) then
        cfgCooldown=true
        CFG.ConfigSlot=(CFG.ConfigSlot%3)+1
        loadSlot(CFG.ConfigSlot)
        pcall(function()
            SG:SetCore("SendNotification",{
                Title="anomia",Text="Config slot "..CFG.ConfigSlot.." loaded",Duration=2,
            })
        end)
        task.delay(0.5,function() cfgCooldown=false end)
    end
end)

-- ═══════════════════════════════════════════════════
--  INIT
-- ═══════════════════════════════════════════════════
local function init()
    killLDB()
    buildLDB()
    buildKF()
    buildWM()
    buildUI()

    task.spawn(function()
        task.wait(1)
        pcall(function()
            SG:SetCore("SendNotification",{
                Title="anomia  v2.1",
                Text="Rivals spoofer loaded — "..CFG.MenuKey.." to toggle",
                Duration=5,
            })
        end)
    end)
end

init()
