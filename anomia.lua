-- ═══════════════════════════════════════════════════════════
--  ANOMIA  v2.3  |  RIVALS SPOOFER  |  freemium
-- ═══════════════════════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local Http       = game:GetService("HttpService")
local SG         = game:GetService("StarterGui")
local CG         = game:GetService("CoreGui")

local lp  = Players.LocalPlayer
local lpg = lp:WaitForChild("PlayerGui")
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

-- ── THEMES ──────────────────────────────────────────────────
local TH = {
    Dark={
        Win=Color3.fromRGB(9,11,18),   Side=Color3.fromRGB(7,9,15),
        Cont=Color3.fromRGB(12,14,22), Card=Color3.fromRGB(17,19,30),
        CardH=Color3.fromRGB(22,24,38),Acc=Color3.fromRGB(100,170,255),
        AccDim=Color3.fromRGB(50,98,180),TxtP=Color3.fromRGB(228,232,245),
        TxtS=Color3.fromRGB(98,106,138),Bdr=Color3.fromRGB(24,27,44),
        Logo=Color3.fromRGB(255,255,255),TonOff=Color3.fromRGB(36,38,56),
        TonOn=Color3.fromRGB(100,170,255),WM=Color3.fromRGB(8,10,17),
    },
    Light={
        Win=Color3.fromRGB(248,249,254), Side=Color3.fromRGB(236,238,248),
        Cont=Color3.fromRGB(252,253,255),Card=Color3.fromRGB(255,255,255),
        CardH=Color3.fromRGB(241,243,253),Acc=Color3.fromRGB(52,120,230),
        AccDim=Color3.fromRGB(28,78,178),TxtP=Color3.fromRGB(14,16,28),
        TxtS=Color3.fromRGB(95,103,132),Bdr=Color3.fromRGB(212,216,232),
        Logo=Color3.fromRGB(10,12,22),TonOff=Color3.fromRGB(198,202,218),
        TonOn=Color3.fromRGB(52,120,230),WM=Color3.fromRGB(248,249,254),
    },
}
local T = TH["Dark"]

-- ── CONFIG  (all OFF by default except watermark) ───────────
local CFG = {
    -- Identity
    SpoofUsername=false, FakeUsername="AnoPlayer",
    SpoofDisplay=false,  FakeDisplay="anomia",
    SpoofOtherNames=false, OtherNameReplace="[ anon ]",
    -- Perf
    SpoofPing=false,FakePing=9,SpoofFPS=false,FakeFPS=240,
    SpoofRegion=false,FakeRegion="EU-West",
    -- Stats
    SpoofKills=false,  FakeKills=9999,
    SpoofDeaths=false, FakeDeaths=1,
    SpoofStreak=false, FakeStreak=999,
    SpoofWins=false,   FakeWins=9999,
    SpoofLosses=false, FakeLosses=0,
    SpoofWinRate=false,FakeWinRate=98,
    SpoofELO=false,    FakeELO=3800,
    SpoofLevel=false,  FakeLevel=999,
    -- Loadout spoofer (4 slots)
    SpoofLoadout=false,
    LoadoutPrimary="Assault Rifle",
    LoadoutSecondary="Handgun",
    LoadoutMelee="Katana",
    LoadoutUtility="Grenade",
    -- Rank
    RankSpoof=false,RankSeason="Season 2",RankTier="Nemesis",
    -- Status
    StatusBadge="None",
    -- Cosmetics (visual only — YOUR client only)
    SkinEnabled=false,    SelectedSkin="AK-47",
    WrapEnabled=false,    SelectedWrap="Gold",
    CharmEnabled=false,   SelectedCharm="Ghost",
    FinisherEnabled=false,SelectedFinisher="Reaper",
    RankCharmEnabled=false,RankCharm="Season 0",
    -- Kill Message
    KillMsgEnabled=false, KillMsgText="anomia wiped target",
    -- Watermark
    WMEnabled=true,WMRainbow=false,
    -- Extra
    InfJump=false,Noclip=false,FakeAFK=false,CleanHUD=false,
    -- UI
    Theme="Dark",MenuKey="RightShift",MenuKey2="",
    CfgCycleKey="F8",CfgCycleKey2="",ConfigSlot=1,
}

-- ── REAL RIVALS COSMETICS ────────────────────────────────────
-- Weapon skins (exact names from robloxrivals.miraheze.org)
local SKINS = {
    -- Assault Rifle
    "AK-47","AUG","Tommy Gun","Gingerbread AUG","Boneclaw Rifle",
    "AKEY-47","Phoenix Rifle","10B Visits",
    -- Bow
    "Compound Bow","Raven Bow","Bat Bow","Frostbite Bow",
    -- Burst Rifle
    "Electro Rifle","Aqua Burst","FAMAS","Spectral Burst","Pine Burst","Pixel Burst",
    -- Crossbow
    "Pixel Crossbow","Harpoon Crossbow","Violin Crossbow","Frostbite Crossbow","Arch Crossbow",
    -- Grenade Launcher
    "Swashbuckler","Uranium Launcher","Skull Launcher","Snowball Launcher","Gearnade Launcher",
    -- Gunblade
    "Hyper Gunblade","Crude Gunblade","Gunsaw","Elf's Gunblade",
    -- Minigun
    "Pumpkin Minigun","Wrapped Minigun","Pixel Minigun",
    -- RPG
    "Nuke Launcher","Spaceship Launcher","Squid Launcher","Firework Launcher","RPKey",
    -- Shotgun
    "Balloon Shotgun","Hyper Shotgun","Cactus Shotgun","Broomstick","ShotKey",
    -- Sniper
    "Pixel Sniper","Hyper Sniper","Event Horizon","Eyething Sniper","Gingerbread Sniper",
    -- Paintball
    "Slime Gun","Boba Gun","Ketchup Gun","Brain Gun","Snowball Gun",
    -- Daggers
    "Aces","Paper Planes","Shurikens","Cookies","Crystal Daggers",
    -- Flare Gun
    "Firework Gun","Dynamite Gun","Banana Flare","Vexed Flare Gun",
    -- Handgun
    "Blaster","Hand Gun","Gumball Handgun","Pixel Handgun","Warp Handgun",
    -- Revolver
    "Desert Eagle","Sheriff","Peppergun","Boneclaw Revolver","Peppermint Sheriff","Keyvolver",
    -- Shorty
    "Not So Shorty","Lovely Shorty","Balloon Shorty","Demon Shorty","Too Shorty",
    -- Spray
    "Lovely Spray","Nailgun","Spray Bottle","Pine Spray",
    -- Uzi
    "Water Uzi","Electro Uzi","Money Gun","Demon Uzi","Pine Uzi","Keyzi",
    -- Battle Axe
    "The Shred","Ban Axe","Nordic Axe",
    -- Chainsaw
    "Blobsaw","Handsaws","Mega Drill","Buzzsaw","Festive Buzzsaw",
    -- Fists
    "Boxing Gloves","Brass Knuckles","Fists Of Hurt","Pumpkin Claws","Festive Fists",
    -- Katana
    "Saber","Lightning Bolt","Stellar Katana","Devil's Trident","2025 Katana",
    "Pixel Katana","Keytana","Arch Katana",
    -- Knife
    "Chancla","Karambit","Balisong","Machete","Candy Cane",
    -- Riot Shield
    "Door","Energy Shield","Sled",
    -- Scythe
    "Scythe of Death","Anchor","Sakura Scythe","Bat Scythe","Cryo Scythe",
    -- Flashbang
    "Disco Ball","Camera","Lightbulb","Skullbang","Shining Star","Pixel Flashbang",
    -- Freeze Ray
    "Temporal Ray","Bubble Ray","Gum Ray","Spider Ray","Wrapped Freeze Ray",
    -- Grenade
    "Whoopee Cushion","Water Balloon","Dynamite","Soul Grenade","Jingle Grenade",
    -- Jump Pad
    "Trampoline","Bounce House","Shady Chicken Sandwich",
    -- Molotov
    "Coffee","Torch","Lava Lamp","Vexed Candle","Hot Coals","Arch Molotov",
    -- Satchel
    "Advanced Satchel","Notebook Satchel","Bag O' Money","Suspicious Gift",
    -- Smoke Grenade
    "Emoji Cloud","Balance","Hourglass","Eyeball","Snowglobe",
    -- Subspace Tripmine
    "Don't Press","Spring","DIY Tripmine","Trick or Treat","Dev-in-the-Box",
    -- War Horn
    "Trumpet","Megaphone","Air Horn","Mammoth Horn",
    -- Key Set
    "AKEY-47","ShotKey","Keyzi","Keyvolver","Keytana","RPKey",
    -- Glorious (free unlocks)
    "Glorious Assault Rifle","Glorious Bow","Glorious Shotgun",
    "Glorious Sniper","Glorious Katana","Glorious Knife","Glorious Uzi",
    -- Void / Special
    "Void Rifle","Void Pistols",
}

-- Real wraps (from wiki §3)
local WRAPS = {
    -- Common
    "Beige","Blue","Blush","Brown","Cool","Green","Highlighter","Lumber","Mint",
    "Olive","Pink","Purple","Salmon","Sky","Teal","Yellow","Bluesteel","Cheese",
    "Crimson","Gunmetal","Lemon","Maroon","Navy","Orange","Red","Violet","Copper",
    "Machine","Titanium","Tungsten","Midnight","Haunted","Vexed","Cursed","Frigid",
    -- Rare
    "Gold","Ancient","Arctic Camo","Black","Carbon Wrapping","Celtic","Chrome Webs",
    "Circuit","Clouds","Desert Camo","Digital Camo","Experience","Fire","Forest Camo",
    "Frosted","Honeycomb","Hypnotic","Igneous","Money","Neo","Obsidian","Ocean Camo",
    "Reptile","Scales","Steel","Storm","Surge","Tempest","White","Urban Camo",
    -- Legendary
    "Diamond","Dark Matter","A5","Amber","Aurora","Black Opal","Blaze","Carbon Fiber",
    "Cardinal","Encrypt","Fracture","Glass","Hologram","Iridescent","Lightning",
    "Liquid Gold","Malachite","Pixel Blight","Quasar","Rift","Scourge","Simulation",
    "Slime","Starblaze","Starfall","Sunset","Tiger","Water","Arabesque","Arena",
    -- Special/Exclusive
    "Sensite","Nosnite","Nekore","Boomore","Community","Aegis","Dark Matter Net",
    "Rivalry","Scribbles","Playful Wrap","Pink Lemonade Wrap","Peril Wrap",
    "Magnetite Wrap","Facility","Only Six","Beggar",
}

-- Real charms (from wiki §4)
local CHARMS = {
    -- Common
    "Armchair","Bone","Bowling Pin","Cage","Candy","Candy Corn","Chombie Head",
    "Cobweb","Cog","Cookie","Cupcake","Dice","Fedora Stack","Glory Coin","Hammer",
    "Heart","Hook","Lemon Slice","Life Buoy","Magnet","Mini Candy Cane","Ninja Star",
    "Ornament","Pawn","Potted Cactus","Potted Flower","Rune Ring","Ship Wheel",
    "Snowflake","Spider","Star","Table Lamp","Thorn Circle","Traffic Cone","Witch Hat",
    -- Rare/Legendary
    "Anvil","Basketball","Blobfish","Caramel Apple","Devious Pumpkin","Emoji: Weary",
    "Football","Golf Ball","Gravestone","Hotdog","Moai","Money Bag","Mystery Block",
    "Poop","Potion","Pufferfish","Rainbow","Rocket Ship","Rubber Duck","UFO",
    "Black Cat","Cauldron","Chillman","Emoji: Imp","Eyeclipse","Frankenblob",
    "Ghost","Gingerbread Cat","Keycard 3","Pumpkin Cat","Skullgourd","Warp Disc","Wreath",
    -- Special/Creator
    "Season 0","Season 1","I Survived Season 0","Day 1","Hunt Token",
    "Mega Token","Streamer Microphone","Tanqr","SenseiWarrior","Nosniy",
    "Chibi Weapon Charm","Team Crown","Mini Present","Runes",
}

-- Real finishers (from wiki §5)
local FINISHERS = {
    "Ragdoll",
    -- Common
    "Flop","Confetti","Hacked","Petrify","Toot","Yoink","Faceplant",
    -- Rare
    "Spooky Confetti","Bite","Batsplosion","Festive Confetti","Wrapped",
    "Collapse","Freeze","High Gravity","Rush","Splatter","Tremble",
    "Bogey","Warp Sickness",
    -- Legendary
    "Reaper","Lost Soul","Bonesplosion","Frozen","Gingerbreadify","Balloons",
    "BONK!","Boogie","Darkheart","Electrocute","Heartbeat","Ignite",
    "Low Gravity","OOF","Opulent","Orbital Strike","Pixel Coins","Stiff",
    "Tough Crowd","Zombified","RIP","Disintegrate","Broom Ride","Snowballed",
    "Falling Icicles","David","Giant Ice Spike","DRIP","Instability",
    -- Special
    "Jolly Judgement","5B Visits","Midas Touch","Diamond Hands",
}

local RANK_CHARMS = {
    "Season 0","Season 1","Season 2",
    "I Survived Season 0","Day 1","Hunt Token",
    "Bronze Charm","Silver Charm","Gold Charm",
    "Platinum Charm","Diamond Charm","Onyx Charm",
    "Nemesis Charm","Archnemesis Charm","Team Crown",
}

-- Skin → color tint for client-side visual change
local SKIN_TINTS = {
    ["AK-47"]=Color3.fromRGB(85,72,58),
    ["AKEY-47"]=Color3.fromRGB(220,190,50),
    ["Phoenix Rifle"]=Color3.fromRGB(220,80,30),
    ["AUG"]=Color3.fromRGB(60,60,60),
    ["Tommy Gun"]=Color3.fromRGB(130,100,70),
    ["Crystal Daggers"]=Color3.fromRGB(100,200,255),
    ["Arch Katana"]=Color3.fromRGB(180,50,220),
    ["Keytana"]=Color3.fromRGB(220,200,50),
    ["Saber"]=Color3.fromRGB(200,160,80),
    ["Hyper Gunblade"]=Color3.fromRGB(0,180,220),
    ["Pixel Sniper"]=Color3.fromRGB(50,200,120),
}
local DEFAULT_TINT = Color3.fromRGB(80,80,80)

-- Loadout options
local PRIMARIES   = {"Assault Rifle","Bow","Burst Rifle","Crossbow","Energy Rifle","Flamethrower","Grenade Launcher","Gunblade","Minigun","Paintball Gun","RPG","Shotgun","Sniper","Distortion","Scepter"}
local SECONDARIES = {"Daggers","Flare Gun","Handgun","Revolver","Shorty","Spray","Uzi","Energy Pistols","Exogun","Slingshot","Warper","Glass Cannon"}
local MELEES      = {"Battle Axe","Chainsaw","Fists","Katana","Knife","Riot Shield","Scythe","Trowel","Glast Shard"}
local UTILITIES   = {"Flashbang","Freeze Ray","Grenade","Jump Pad","Molotov","Satchel","Smoke Grenade","War Horn","Medkit","Subspace Tripmine","Warpstone","Elixir","RNG Dice"}

local BADGES={None="",["Roblox+"]="[R+] ",Moderator="[MOD] ",Developer="[DEV] ",RobloxMod="[RBLX] "}
local RANKS={
    [0]="Unranked",[200]="Bronze III",[400]="Bronze II",[600]="Bronze I",
    [800]="Silver III",[1000]="Silver II",[1200]="Silver I",
    [1400]="Gold III",[1600]="Gold II",[1800]="Gold I",
    [2000]="Plat III",[2200]="Plat II",[2400]="Plat I",
    [2600]="Diamond III",[2800]="Diamond II",[3000]="Diamond I",
    [3200]="Onyx III",[3400]="Onyx II",[3600]="Nemesis",[4000]="Archnemesis",
}
local function elo2rank(e)
    local b,bv="Unranked",0
    for t,n in pairs(RANKS) do if e>=t and t>=bv then b=n;bv=t end end
    return b
end
local function fakeName() return CFG.SpoofUsername and CFG.FakeUsername or lp.Name end
local function fakeDisp() return (BADGES[CFG.StatusBadge] or "")..(CFG.SpoofDisplay and CFG.FakeDisplay or lp.DisplayName) end

-- ── SAVE/LOAD ───────────────────────────────────────────────
local CF="anomia_v23_slot"
local function saveSlot(s)
    if not writefile then return end
    local o={}
    for k,v in pairs(CFG) do if type(v)~="function" and type(v)~="userdata" then o[k]=v end end
    pcall(writefile,CF..s..".json",Http:JSONEncode(o))
end
local function loadSlot(s)
    if not readfile then return end
    local ok,raw=pcall(readfile,CF..s..".json")
    if not ok or not raw then return end
    local ok2,tbl=pcall(function() return Http:JSONDecode(raw) end)
    if not ok2 or not tbl then return end
    for k,v in pairs(tbl) do if CFG[k]~=nil and type(CFG[k])==type(v) then CFG[k]=v end end
    T=TH[CFG.Theme]
end
loadSlot(CFG.ConfigSlot)

-- ── UTIL ─────────────────────────────────────────────────────
local TI_F=TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local TI_M=TweenInfo.new(0.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
local function tw(i,ti,p) TweenSvc:Create(i,ti,p):Play() end
local function new(c,p,par)
    local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end
    if par then i.Parent=par end; return i
end
local function cor(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function str(c,t,tr,p) return new("UIStroke",{Color=c,Thickness=t,Transparency=tr or 0},p) end
local function pd(t,b,l,r,p)
    return new("UIPadding",{PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),
        PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r)},p)
end
local function hsvC(t) return Color3.fromHSV(t%1,0.8,1) end

-- ═══════════════════════════════════════════════════════════
--  GLOBAL SLIDER — one active at a time, FIXED
-- ═══════════════════════════════════════════════════════════
local _sliderFn = nil

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        _sliderFn = nil
    end
end)
UIS.InputChanged:Connect(function(i)
    if _sliderFn and (i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch) then
        _sliderFn(i.Position.X)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  SPOOF ENGINE
--  KEY FIX: OUR OWN GUI IS NEVER PATCHED.
--  No bare ^%d+$ in applySpoof — only in billboard context.
-- ═══════════════════════════════════════════════════════════

-- Our GUI names — NEVER patch these
local OUR_GUIS = {AnoMain=true,AnoWM=true,AnoKF=true}
local function isOurGui(obj)
    local p=obj
    while p and p~=game do
        if OUR_GUIS[p.Name] then return true end
        p=p.Parent
    end
    return false
end

local hooked={}; setmetatable(hooked,{__mode="k"})
local cached={}; setmetatable(cached,{__mode="k"})

-- Kill message labels (separate tracking to prevent duplicate)
local kmLabels={}; setmetatable(kmLabels,{__mode="k"})

local PATS = {
    {"Kills:%s*%d+",         function() return "Kills: "..CFG.FakeKills       end,"SpoofKills"},
    {"Eliminations:%s*%d+",  function() return "Eliminations: "..CFG.FakeKills end,"SpoofKills"},
    {"Elims:%s*%d+",         function() return "Elims: "..CFG.FakeKills        end,"SpoofKills"},
    {"Deaths:%s*%d+",        function() return "Deaths: "..CFG.FakeDeaths     end,"SpoofDeaths"},
    {"Winstreak:%s*%d+",     function() return "Winstreak: "..CFG.FakeStreak  end,"SpoofStreak"},
    {"Win Streak:%s*%d+",    function() return "Win Streak: "..CFG.FakeStreak end,"SpoofStreak"},
    {"Wins:%s*%d+",          function() return "Wins: "..CFG.FakeWins         end,"SpoofWins"},
    {"Duel Wins:%s*%d+",     function() return "Duel Wins: "..CFG.FakeWins    end,"SpoofWins"},
    {"Losses:%s*%d+",        function() return "Losses: "..CFG.FakeLosses     end,"SpoofLosses"},
    {"Win Rate:%s*%d+%%?",   function() return "Win Rate: "..CFG.FakeWinRate.."%" end,"SpoofWinRate"},
    {"Winrate:%s*%d+%%?",    function() return "Winrate: "..CFG.FakeWinRate.."%" end,"SpoofWinRate"},
    {"ELO:%s*%d+",           function() return "ELO: "..CFG.FakeELO           end,"SpoofELO"},
    {"Elo:%s*%d+",           function() return "Elo: "..CFG.FakeELO           end,"SpoofELO"},
    {"%d+ ELO",              function() return CFG.FakeELO.." ELO"            end,"SpoofELO"},
    {"Level:%s*%d+",         function() return "Level: "..CFG.FakeLevel       end,"SpoofLevel"},
    {"Lvl%s*%d+",            function() return "Lvl "..CFG.FakeLevel          end,"SpoofLevel"},
    -- Loadout
    {"Primary:%s*.+",        function() return "Primary: "..CFG.LoadoutPrimary    end,"SpoofLoadout"},
    {"Secondary:%s*.+",      function() return "Secondary: "..CFG.LoadoutSecondary end,"SpoofLoadout"},
    {"Melee:%s*.+",          function() return "Melee: "..CFG.LoadoutMelee        end,"SpoofLoadout"},
    {"Utility:%s*.+",        function() return "Utility: "..CFG.LoadoutUtility    end,"SpoofLoadout"},
    -- Rank
    {"Archnemesis", function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Nemesis",     function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Onyx %a+",    function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Diamond %a+", function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Platinum %a+",function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Gold %a+",    function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Silver %a+",  function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Bronze %a+",  function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
    {"Unranked",    function() return CFG.RankSpoof and CFG.RankTier or nil end,"RankSpoof"},
}

-- Strip rich text tags before pattern matching
local function stripRT(s)
    return s:gsub("<[^>]+>","")
end

local function applySpoof(lbl)
    if isOurGui(lbl) then return end
    local orig = lbl.Text
    local t    = orig

    -- Disable RichText on labels we're patching (prevents HTML garbage)
    if lbl:IsA("TextLabel") or lbl:IsA("TextButton") then
        pcall(function() lbl.RichText=false end)
    end

    -- Strip rich text from working copy (don't write stripped back unless changed)
    local stripped = stripRT(t)

    if CFG.SpoofUsername and lp.Name~="" then
        stripped=stripped:gsub(lp.Name, fakeName())
    end
    if CFG.SpoofDisplay and lp.DisplayName~="" then
        stripped=stripped:gsub(lp.DisplayName, fakeDisp())
    end

    for _,def in ipairs(PATS) do
        local pat,fn,key=def[1],def[2],def[3]
        if CFG[key] then
            local rep=fn(); if rep then stripped=stripped:gsub(pat,rep) end
        end
    end

    if stripped~=stripRT(orig) then
        lbl.Text=stripped
        return true
    end
    return false
end

-- Kill message: targeted, debounced, no duplicates
local function hookKillLabel(lbl)
    if kmLabels[lbl] then return end
    kmLabels[lbl]=true
    local busy=false
    local function patch()
        if busy or not CFG.KillMsgEnabled then return end
        local t=lbl.Text
        -- Rivals shows "eliminated" (lower or mixed case)
        if t:lower():find("eliminat") then
            busy=true
            pcall(function() lbl.RichText=false end)
            lbl.Text=CFG.KillMsgText
            busy=false
        end
    end
    lbl:GetPropertyChangedSignal("Text"):Connect(patch)
    patch()
end

local function hookLabel(obj)
    if hooked[obj] then return end
    if isOurGui(obj) then return end   -- NEVER touch our own UI
    if not(obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    hooked[obj]=true
    cached[obj]=true

    -- Check if this is likely a kill message label
    local t=obj.Text
    if t:lower():find("eliminat") then hookKillLabel(obj) return end

    local busy=false
    local function patch()
        if busy or isOurGui(obj) then return end
        busy=true; pcall(applySpoof,obj); busy=false
    end
    obj:GetPropertyChangedSignal("Text"):Connect(function()
        -- Re-check for kill message (Rivals sets text after label appears)
        if obj.Text:lower():find("eliminat") then
            hookKillLabel(obj)
            return
        end
        patch()
    end)
    patch()
end

local function scanTree(root)
    if isOurGui(root) then return end
    task.spawn(function()
        local d=root:GetDescendants()
        for i=1,#d do
            pcall(hookLabel,d[i])
            if i%60==0 then task.wait() end
        end
    end)
    root.DescendantAdded:Connect(function(v)
        if not isOurGui(v) then task.defer(function() pcall(hookLabel,v) end) end
    end)
end

-- 350ms pulse on cached labels
task.spawn(function()
    while true do
        task.wait(0.35)
        for lbl in pairs(cached) do
            if lbl and lbl.Parent and not isOurGui(lbl) then
                pcall(applySpoof,lbl)
            else cached[lbl]=nil end
        end
    end
end)

task.spawn(function()
    task.wait(1.5); scanTree(lpg); pcall(scanTree,CG)
end)
lpg.ChildAdded:Connect(function(c)
    task.wait(0.08)
    if not isOurGui(c) then pcall(scanTree,c) end
end)
lp.CharacterAdded:Connect(function()
    task.wait(0.5); pcall(scanTree,CG)
end)

-- Other player names
local function hookOtherPlayer(plr)
    if plr==lp then return end
    local function doHook(char)
        task.wait(0.3)
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                if v.Text:find(plr.Name,1,true) or v.Text:find(plr.DisplayName,1,true) then
                    if not hooked[v] then
                        hooked[v]=true; local busy=false
                        local function p()
                            if busy or not CFG.SpoofOtherNames then return end
                            busy=true
                            pcall(function()
                                lbl.RichText=false
                                v.Text=v.Text:gsub(plr.Name,CFG.OtherNameReplace)
                                    :gsub(plr.DisplayName,CFG.OtherNameReplace)
                            end)
                            busy=false
                        end
                        p(); v:GetPropertyChangedSignal("Text"):Connect(p)
                    end
                end
            end
        end
    end
    if plr.Character then task.spawn(function() doHook(plr.Character) end) end
    plr.CharacterAdded:Connect(function(c) task.spawn(function() doHook(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do hookOtherPlayer(p) end
Players.PlayerAdded:Connect(hookOtherPlayer)

-- Rivals streak billboard patch (bare numbers)
local function patchBillboards(char)
    if not char then return end
    local function tryB(v)
        if not(v:IsA("BillboardGui") or v:IsA("SurfaceGui")) then return end
        for _,lbl in ipairs(v:GetDescendants()) do
            if lbl:IsA("TextLabel") then
                local busy=false
                local function p()
                    if busy or not CFG.SpoofStreak then return end
                    if lbl.Text:match("^%d+$") then
                        busy=true; lbl.Text=tostring(CFG.FakeStreak); busy=false
                    end
                end
                p(); lbl:GetPropertyChangedSignal("Text"):Connect(p)
            end
        end
        v.DescendantAdded:Connect(function(d)
            task.defer(function()
                if d:IsA("TextLabel") then
                    local busy=false
                    d:GetPropertyChangedSignal("Text"):Connect(function()
                        if not busy and CFG.SpoofStreak and d.Text:match("^%d+$") then
                            busy=true; d.Text=tostring(CFG.FakeStreak); busy=false
                        end
                    end)
                    if CFG.SpoofStreak and d.Text:match("^%d+$") then
                        d.Text=tostring(CFG.FakeStreak)
                    end
                end
            end)
        end)
    end
    for _,v in ipairs(char:GetDescendants()) do pcall(tryB,v) end
    char.DescendantAdded:Connect(function(v) task.defer(function() pcall(tryB,v) end) end)
end
if lp.Character then task.spawn(function() patchBillboards(lp.Character) end) end
lp.CharacterAdded:Connect(function(c) task.wait(0.3); patchBillboards(c) end)

-- ═══════════════════════════════════════════════════════════
--  SKIN CHANGER — client-side visual tint on equipped weapon
-- ═══════════════════════════════════════════════════════════
local function applySkinTint()
    if not CFG.SkinEnabled then return end
    local char=lp.Character; if not char then return end
    local tint=SKIN_TINTS[CFG.SelectedSkin] or DEFAULT_TINT
    for _,tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            for _,p in ipairs(tool:GetDescendants()) do
                pcall(function()
                    if p:IsA("MeshPart") or p:IsA("Part") or p:IsA("UnionOperation") then
                        if p.Name~="Handle" then return end
                        p.Color=tint
                    end
                end)
            end
        end
    end
end

lp.CharacterAdded:Connect(function(c)
    c.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then task.wait(0.1); applySkinTint() end
    end)
end)

-- ═══════════════════════════════════════════════════════════
--  KILL FEED OVERLAY  (our custom entries, separate from game)
-- ═══════════════════════════════════════════════════════════
local KF_GUI, KF_FRAME

local function buildKF()
    if KF_GUI then KF_GUI:Destroy() end
    KF_GUI=new("ScreenGui",{Name="AnoKF",ResetOnSpawn=false,DisplayOrder=56},lpg)
    KF_FRAME=new("Frame",{
        Size=UDim2.new(0,320,0,180),Position=UDim2.new(1,-336,0,108),
        BackgroundTransparency=1,BorderSizePixel=0,
    },KF_GUI)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,Padding=UDim.new(0,3)},KF_FRAME)
end

local kfIdx=0
local function pushKF()
    if not KF_FRAME then return end
    kfIdx+=1
    local entry=new("Frame",{
        Size=UDim2.new(1,0,0,26),BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0.45,BorderSizePixel=0,LayoutOrder=kfIdx,
    },KF_FRAME)
    cor(6,entry)
    new("TextLabel",{
        Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,Text=CFG.KillMsgText,
        Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Acc,
        TextXAlignment=Enum.TextXAlignment.Right,
    },entry)
    task.delay(4,function()
        if not entry.Parent then return end
        tw(entry,TI_M,{BackgroundTransparency=1})
        for _,c in ipairs(entry:GetChildren()) do
            if c:IsA("TextLabel") then tw(c,TI_M,{TextTransparency=1}) end
        end
        task.wait(0.4); if entry.Parent then entry:Destroy() end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  WATERMARK
-- ═══════════════════════════════════════════════════════════
local WM_GUI, WM_MAIN, WM_SUB

local function buildWM()
    if WM_GUI then WM_GUI:Destroy() end
    WM_GUI=new("ScreenGui",{Name="AnoWM",ResetOnSpawn=false,DisplayOrder=100,Enabled=CFG.WMEnabled},lpg)
    -- shadow
    local sh=new("Frame",{Position=UDim2.new(0,12,0,12),Size=UDim2.new(0,280,0,40),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,BorderSizePixel=0},WM_GUI)
    cor(12,sh)
    -- main
    local f=new("Frame",{Position=UDim2.new(0,10,0,10),Size=UDim2.new(0,280,0,40),
        BackgroundColor3=T.WM,BorderSizePixel=0},WM_GUI)
    cor(12,f); str(T.Acc,1,0.55,f)
    -- A logo
    local logo=new("TextLabel",{
        Size=UDim2.new(0,38,1,0),BackgroundTransparency=1,Text="A",
        Font=Enum.Font.Fantasy,TextSize=22,TextColor3=T.Logo,TextXAlignment=Enum.TextXAlignment.Center,
    },f)
    new("Frame",{Size=UDim2.new(0,1,0.7,0),Position=UDim2.new(0,38,0.15,0),
        BackgroundColor3=T.Bdr,BorderSizePixel=0},f)
    WM_MAIN=new("TextLabel",{
        Size=UDim2.new(1,-46,0,22),Position=UDim2.new(0,44,0,2),
        BackgroundTransparency=1,Text="Anomia V2  |  Freemium Spoofer",
        Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),
        TextXAlignment=Enum.TextXAlignment.Left,
    },f)
    WM_SUB=new("TextLabel",{
        Size=UDim2.new(1,-46,0,14),Position=UDim2.new(0,44,0,24),
        BackgroundTransparency=1,Text="Roblox Rivals",
        Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.TxtS,
        TextXAlignment=Enum.TextXAlignment.Left,
    },f)
    task.spawn(function()
        while f and f.Parent do
            task.wait(1)
            if WM_MAIN then
                WM_MAIN.TextColor3=CFG.WMRainbow and hsvC(tick()*0.2) or Color3.new(1,1,1)
            end
            if WM_SUB and WM_GUI.Enabled then
                WM_SUB.Text=string.format("Rivals  %s  %dms  %dfps",
                    CFG.SpoofRegion and CFG.FakeRegion or "?",
                    CFG.SpoofPing and CFG.FakePing or 0,
                    CFG.SpoofFPS and CFG.FakeFPS or 60)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  EXTRAS
-- ═══════════════════════════════════════════════════════════
local xConns={}
local function xStop(k) if xConns[k] then pcall(function() xConns[k]:Disconnect() end);xConns[k]=nil end end
local function startInfJump()
    xStop("ij")
    xConns["ij"]=UIS.JumpRequest:Connect(function()
        if not CFG.InfJump then xStop("ij") return end
        local c=lp.Character; if c then local h=c:FindFirstChildWhichIsA("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end)
end
local ncConn
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    ncConn=RunService.Stepped:Connect(function()
        if not CFG.Noclip then ncConn:Disconnect() return end
        local c=lp.Character; if c then for _,v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end end end
    end)
end
local afkTh
local function startAFK()
    if afkTh then task.cancel(afkTh) end
    afkTh=task.spawn(function()
        while CFG.FakeAFK do
            task.wait(55); local c=lp.Character
            if c then local h=c:FindFirstChild("HumanoidRootPart")
                if h then h.CFrame=h.CFrame*CFrame.new(0.001,0,0) end end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  MAIN UI
-- ═══════════════════════════════════════════════════════════
local MAIN_GUI, menuOpen = nil, true
local SB_C=50; local SB_E=176

local TABS={
    {id="identity", icon="🆔", lbl="Identity"},
    {id="stats",    icon="📊", lbl="Stats"},
    {id="status",   icon="🏅", lbl="Status"},
    {id="cosmetics",icon="🎨", lbl="Cosmetics"},
    {id="killmsg",  icon="💬", lbl="Kill Message"},
    {id="watermark",icon="🔖", lbl="Watermark"},
    {id="extra",    icon="⚡",  lbl="Extra"},
    {id="config",   icon="⚙",  lbl="Config"},
}

local tabFrames,tabBtns,themeR={},{},{}
local activeTab="identity"
local function regT(i,p,k) themeR[#themeR+1]={i=i,p=p,k=k} end
local function applyTheme()
    T=TH[CFG.Theme]
    for _,r in ipairs(themeR) do if r.i and r.i.Parent then r.i[r.p]=T[r.k] end end
end

local function buildUI()
    if MAIN_GUI then MAIN_GUI:Destroy() end
    tabFrames,tabBtns,themeR={},{},{}; activeTab="identity"

    MAIN_GUI=new("ScreenGui",{Name="AnoMain",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=200,Enabled=menuOpen},lpg)

    -- Mobile toggle
    if isMobile then
        local mb=new("TextButton",{
            Name="MobToggle",Size=UDim2.new(0,44,0,44),
            Position=UDim2.new(0,8,1,-54),BackgroundColor3=T.Win,
            Text="A",Font=Enum.Font.Fantasy,TextSize=22,TextColor3=T.Acc,
            BorderSizePixel=0,
        },MAIN_GUI)
        cor(12,mb); str(T.Acc,1.5,0.4,mb)
        mb.MouseButton1Click:Connect(function()
            local r=MAIN_GUI:FindFirstChild("Root")
            if r then r.Visible=not r.Visible end
        end)
    end

    local root=new("Frame",{Name="Root",
        Size=isMobile and UDim2.new(0,320,0,430) or UDim2.new(0,640,0,452),
        Position=UDim2.new(0.5,-320,0.5,-226),
        BackgroundColor3=T.Win,BorderSizePixel=0,ClipsDescendants=false,
    },MAIN_GUI)
    cor(14,root)
    local rStr=str(T.Bdr,1.2,0,root); regT(root,"BackgroundColor3","Win"); regT(rStr,"Color","Bdr")
    local clip=new("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true},root)
    cor(14,clip)
    -- shadow
    new("ImageLabel",{Size=UDim2.new(1,40,1,40),Position=UDim2.new(0,-20,0,-20),
        BackgroundTransparency=1,Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),ImageTransparency=0.5,ZIndex=0,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(49,49,450,450)},root)

    -- drag
    do
        local drag,ds,rs=false,nil,nil
        root.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;rs=root.Position end
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

    -- sidebar
    local sb=new("Frame",{Name="Sidebar",Size=UDim2.new(0,SB_C,1,0),
        BackgroundColor3=T.Side,BorderSizePixel=0},clip)
    cor(14,sb)
    new("Frame",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),
        BackgroundColor3=T.Side,BorderSizePixel=0},sb)
    local sbSep=new("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Bdr,BorderSizePixel=0},sb)
    regT(sb,"BackgroundColor3","Side"); regT(sbSep,"BackgroundColor3","Bdr")

    -- logo
    local logoBtn=new("TextButton",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,Text="",BorderSizePixel=0},sb)
    local logoA=new("TextLabel",{Size=UDim2.new(0,SB_C,1,0),BackgroundTransparency=1,
        Text="A",Font=Enum.Font.Fantasy,TextSize=28,TextColor3=T.Logo,TextXAlignment=Enum.TextXAlignment.Center},logoBtn)
    regT(logoA,"TextColor3","Logo")
    local logoTxt=new("TextLabel",{
        Size=UDim2.new(1,-SB_C,1,0),Position=UDim2.new(0,SB_C+2,0,0),
        BackgroundTransparency=1,Text="anomia",Font=Enum.Font.GothamBold,TextSize=15,
        TextColor3=T.TxtP,TextTransparency=1,TextXAlignment=Enum.TextXAlignment.Left},logoBtn)
    regT(logoTxt,"TextColor3","TxtP")
    local ldot=new("Frame",{Size=UDim2.new(0,4,0,4),Position=UDim2.new(0,SB_C/2-2,0,43),
        BackgroundColor3=T.Acc,BorderSizePixel=0},sb)
    cor(3,ldot)
    local ldiv=new("Frame",{Size=UDim2.new(0.7,0,0,1),Position=UDim2.new(0.15,0,0,49),
        BackgroundColor3=T.Bdr,BorderSizePixel=0},sb)
    regT(ldiv,"BackgroundColor3","Bdr")

    -- sidebar expand
    local sbExp,sbLocked,sbTask=false,false,nil
    local function expandSB(lock)
        sbExp=true; if lock then sbLocked=true end
        tw(sb,TI_M,{Size=UDim2.new(0,SB_E,1,0)})
        tw(logoTxt,TI_M,{TextTransparency=0}); tw(logoA,TI_F,{TextColor3=T.Acc})
        for _,td in ipairs(TABS) do local r=tabBtns[td.id]; if r then tw(r.lbl,TI_M,{TextTransparency=0}) end end
    end
    local function collapseSB()
        if sbLocked then return end; sbExp=false
        tw(sb,TI_M,{Size=UDim2.new(0,SB_C,1,0)})
        tw(logoTxt,TI_F,{TextTransparency=1}); tw(logoA,TI_F,{TextColor3=T.Logo})
        for _,td in ipairs(TABS) do local r=tabBtns[td.id]; if r then tw(r.lbl,TI_F,{TextTransparency=1}) end end
    end
    if isMobile then
        logoBtn.MouseButton1Click:Connect(function()
            if sbExp then sbLocked=false;collapseSB() else expandSB(true) end
        end)
    else
        logoBtn.MouseEnter:Connect(function()
            tw(logoA,TI_F,{TextColor3=T.Acc})
            if not sbLocked then sbTask=task.delay(0.1,function() expandSB(false) end) end
        end)
        logoBtn.MouseLeave:Connect(function()
            if not sbLocked then
                if sbTask then task.cancel(sbTask);sbTask=nil end
                collapseSB()
            end
        end)
        logoBtn.MouseButton1Click:Connect(function()
            sbLocked=not sbLocked
            if sbLocked then expandSB(true) else sbExp=false;sbLocked=false;collapseSB() end
        end)
        sb.MouseEnter:Connect(function()
            if not sbLocked then sbTask=task.delay(0.22,function() expandSB(false) end) end
        end)
        sb.MouseLeave:Connect(function()
            if not sbLocked then
                if sbTask then task.cancel(sbTask);sbTask=nil end; collapseSB()
            end
        end)
    end

    -- tab buttons
    local tabList=new("Frame",{Size=UDim2.new(1,0,1,-58),Position=UDim2.new(0,0,0,58),BackgroundTransparency=1},sb)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},tabList)
    pd(3,3,4,4,tabList)

    for i,td in ipairs(TABS) do
        local isA=td.id==activeTab
        local btn=new("TextButton",{Name=td.id,Size=UDim2.new(1,0,0,34),
            BackgroundColor3=isA and T.Card or T.Side,BackgroundTransparency=isA and 0 or 1,
            Text="",BorderSizePixel=0,LayoutOrder=i},tabList)
        cor(7,btn)
        local aBar=new("Frame",{Size=UDim2.new(0,3,0,16),Position=UDim2.new(0,0,0.5,-8),
            BackgroundColor3=T.Acc,BackgroundTransparency=isA and 0 or 1,BorderSizePixel=0},btn)
        cor(2,aBar)
        local ico=new("TextLabel",{Size=UDim2.new(0,SB_C,1,0),BackgroundTransparency=1,
            Text=td.icon,Font=Enum.Font.GothamBold,TextSize=14,
            TextColor3=isA and T.Acc or T.TxtS,TextXAlignment=Enum.TextXAlignment.Center},btn)
        regT(ico,"TextColor3",isA and "Acc" or "TxtS")
        local lbl=new("TextLabel",{Size=UDim2.new(1,-SB_C,1,0),Position=UDim2.new(0,SB_C+2,0,0),
            BackgroundTransparency=1,Text=td.lbl,
            Font=isA and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=12,
            TextColor3=isA and T.Acc or T.TxtP,TextTransparency=1,
            TextXAlignment=Enum.TextXAlignment.Left},btn)
        regT(lbl,"TextColor3",isA and "Acc" or "TxtP")
        tabBtns[td.id]={btn=btn,ico=ico,lbl=lbl,bar=aBar}

        btn.MouseEnter:Connect(function() if td.id~=activeTab then tw(btn,TI_F,{BackgroundTransparency=0.75,BackgroundColor3=T.Card}) end end)
        btn.MouseLeave:Connect(function() if td.id~=activeTab then tw(btn,TI_F,{BackgroundTransparency=1}) end end)
        btn.MouseButton1Click:Connect(function()
            local prev=activeTab; if prev==td.id then return end
            local old=tabBtns[prev]
            if old then
                tw(old.btn,TI_F,{BackgroundTransparency=1}); tw(old.bar,TI_F,{BackgroundTransparency=1})
                tw(old.ico,TI_F,{TextColor3=T.TxtS}); tw(old.lbl,TI_F,{TextColor3=T.TxtP,TextTransparency=1})
                old.lbl.Font=Enum.Font.Gotham
                if tabFrames[prev] then tabFrames[prev].Visible=false end
            end
            activeTab=td.id
            tw(btn,TI_F,{BackgroundTransparency=0,BackgroundColor3=T.Card}); tw(aBar,TI_F,{BackgroundTransparency=0})
            tw(ico,TI_F,{TextColor3=T.Acc}); lbl.Font=Enum.Font.GothamBold
            if tabFrames[activeTab] then tabFrames[activeTab].Visible=true end
        end)
    end

    -- content area
    local ca=new("Frame",{Size=UDim2.new(1,-SB_C-2,1,0),Position=UDim2.new(0,SB_C+2,0,0),
        BackgroundColor3=T.Cont,BorderSizePixel=0,ClipsDescendants=true},clip)
    cor(14,ca)
    new("Frame",{Size=UDim2.new(0,14,1,0),BackgroundColor3=T.Cont,BorderSizePixel=0},ca)
    regT(ca,"BackgroundColor3","Cont")

    local ch=new("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Side,BorderSizePixel=0},ca)
    new("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=T.Side,BorderSizePixel=0},ch)
    regT(ch,"BackgroundColor3","Side")
    local chDiv=new("Frame",{Size=UDim2.new(1,-22,0,1),Position=UDim2.new(0,11,1,-1),BackgroundColor3=T.Bdr,BorderSizePixel=0},ch)
    regT(chDiv,"BackgroundColor3","Bdr")
    local chBar=new("Frame",{Size=UDim2.new(0,3,0,16),Position=UDim2.new(0,11,0.5,-8),BackgroundColor3=T.Acc,BorderSizePixel=0},ch)
    cor(2,chBar)
    local chTitle=new("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,19,0,0),
        BackgroundTransparency=1,Text="Identity",Font=Enum.Font.GothamBold,TextSize=13,
        TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left},ch)
    regT(chTitle,"TextColor3","TxtP")
    new("TextLabel",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-86,0,0),
        BackgroundTransparency=1,Text="anomia v2.3",Font=Enum.Font.Gotham,TextSize=10,
        TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Right},ch)
    local TLBLS={}; for _,td in ipairs(TABS) do TLBLS[td.id]=td.lbl end
    task.spawn(function()
        while chTitle and chTitle.Parent do
            chTitle.Text=TLBLS[activeTab] or "anomia"; chTitle.TextColor3=T.TxtP
            chBar.BackgroundColor3=T.Acc; task.wait(0.15)
        end
    end)

    -- ── component helpers ────────────────────────────────
    local function mkScroll(id)
        local f=new("ScrollingFrame",{Name=id,
            Size=UDim2.new(1,0,1,-44),Position=UDim2.new(0,0,0,44),
            BackgroundColor3=T.Cont,BackgroundTransparency=0,BorderSizePixel=0,
            ScrollBarThickness=2,ScrollBarImageColor3=T.Acc,
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=id==activeTab},ca)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)},f)
        pd(8,10,10,10,f)
        tabFrames[id]=f; regT(f,"BackgroundColor3","Cont"); return f
    end

    local function secH(par,txt,lo)
        local f=new("Frame",{Size=UDim2.new(1,-4,0,18),BackgroundTransparency=1,LayoutOrder=lo or 1},par)
        local ab=new("Frame",{Size=UDim2.new(0,3,0,10),Position=UDim2.new(0,0,0.5,-5),BackgroundColor3=T.Acc,BorderSizePixel=0},f)
        cor(2,ab)
        new("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,7,0,0),BackgroundTransparency=1,
            Text=txt:upper(),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Left},f)
    end

    local function crd(par,lo,h)
        h=h or 36; local f=new("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=T.Card,BorderSizePixel=0,LayoutOrder=lo or 1},par)
        cor(7,f); pd(0,0,10,10,f)
        f.MouseEnter:Connect(function() tw(f,TI_F,{BackgroundColor3=T.CardH}) end)
        f.MouseLeave:Connect(function() tw(f,TI_F,{BackgroundColor3=T.Card}) end)
        regT(f,"BackgroundColor3","Card"); return f
    end

    local function rLbl(par,txt,tip)
        local l=new("TextLabel",{Size=UDim2.new(0.5,-4,1,0),BackgroundTransparency=1,Text=txt,
            Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left},par)
        regT(l,"TextColor3","TxtP")
        if tip then
            local ib=new("TextButton",{Size=UDim2.new(0,13,0,13),
                Position=UDim2.new(0,#txt*6+14,0.5,-6.5),BackgroundColor3=T.AccDim,
                BackgroundTransparency=0.35,Text="i",Font=Enum.Font.GothamBold,TextSize=8,
                TextColor3=Color3.new(1,1,1),BorderSizePixel=0},par)
            cor(8,ib); local tt
            ib.MouseEnter:Connect(function()
                if tt then tt:Destroy() end
                tt=new("Frame",{Size=UDim2.new(0,math.max(110,#tip*5.8),0,22),
                    Position=UDim2.new(0,0,1,3),BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=40},ib)
                cor(5,tt); str(T.Acc,1,0.5,tt)
                new("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),
                    BackgroundTransparency=1,Text=tip,Font=Enum.Font.Gotham,TextSize=10,
                    TextColor3=T.TxtP,ZIndex=40,TextXAlignment=Enum.TextXAlignment.Left},tt)
            end)
            ib.MouseLeave:Connect(function() if tt then tt:Destroy();tt=nil end end)
        end
    end

    local function tog(par,key,cb)
        local on=CFG[key]
        local track=new("TextButton",{Size=UDim2.new(0,40,0,20),Position=UDim2.new(1,-40,0.5,-10),
            BackgroundColor3=on and T.TonOn or T.TonOff,Text="",BorderSizePixel=0},par)
        cor(10,track)
        local knob=new("Frame",{Size=UDim2.new(0,14,0,14),
            Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track)
        cor(8,knob)
        track.MouseButton1Click:Connect(function()
            CFG[key]=not CFG[key]; local v=CFG[key]
            tw(track,TI_F,{BackgroundColor3=v and T.TonOn or T.TonOff})
            tw(knob,TI_F,{Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)})
            if cb then cb(v) end
        end)
    end

    local function txIn(par,key,ph,cb)
        local bx=new("TextBox",{Size=UDim2.new(0.44,0,0,24),Position=UDim2.new(0.54,0,0.5,-12),
            BackgroundColor3=T.Win,BackgroundTransparency=0.15,BorderSizePixel=0,
            Text=tostring(CFG[key] or ""),PlaceholderText=ph or "",
            Font=Enum.Font.Gotham,TextSize=12,TextColor3=T.TxtP,PlaceholderColor3=T.TxtS,
            ClearTextOnFocus=false},par)
        cor(6,bx); str(T.Bdr,1,0,bx); regT(bx,"TextColor3","TxtP")
        bx.Focused:Connect(function()
            tw(bx,TI_F,{BackgroundTransparency=0})
            for _,s in ipairs(bx:GetChildren()) do if s:IsA("UIStroke") then tw(s,TI_F,{Color=T.Acc}) end end
        end)
        bx.FocusLost:Connect(function()
            tw(bx,TI_F,{BackgroundTransparency=0.15})
            for _,s in ipairs(bx:GetChildren()) do if s:IsA("UIStroke") then tw(s,TI_F,{Color=T.Bdr}) end end
            local v=bx.Text; local n=tonumber(v)
            CFG[key]=(n~=nil and type(CFG[key])=="number") and n or v
            if cb then cb(CFG[key]) end
        end)
    end

    -- DROPDOWN — each call gets its OWN isolated cur variable (no bleed between dropdowns)
    local function ddrop(par,key,opts,cb)
        local cur=tostring(CFG[key] or opts[1])   -- isolated per-call closure
        local open=false; local df
        local btn=new("TextButton",{Size=UDim2.new(0.44,0,0,24),Position=UDim2.new(0.54,0,0.5,-12),
            BackgroundColor3=T.Win,BackgroundTransparency=0.15,BorderSizePixel=0,Text=""},par)
        cor(6,btn); str(T.Bdr,1,0,btn)
        local btxt=new("TextLabel",{Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,6,0,0),
            BackgroundTransparency=1,Text=cur,Font=Enum.Font.Gotham,TextSize=11,
            TextColor3=T.TxtP,TextXAlignment=Enum.TextXAlignment.Left},btn)
        regT(btxt,"TextColor3","TxtP")
        local chev=new("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-18,0,0),
            BackgroundTransparency=1,Text="v",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=T.TxtS},btn)
        local function closeDrop() if df then df:Destroy();df=nil end open=false; tw(chev,TI_F,{Rotation=0}) end
        btn.MouseButton1Click:Connect(function()
            if open then closeDrop() return end; open=true; tw(chev,TI_F,{Rotation=180})
            local bap=btn.AbsolutePosition; local bas=btn.AbsoluteSize; local cap=ca.AbsolutePosition
            df=new("Frame",{Size=UDim2.new(0,bas.X,0,math.min(#opts,5)*24+6),
                Position=UDim2.new(0,bap.X-cap.X,0,bap.Y-cap.Y+bas.Y+3),
                BackgroundColor3=T.Card,BorderSizePixel=0,ZIndex=50,ClipsDescendants=true},ca)
            cor(7,df); str(T.Acc,1,0.4,df)
            new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},df)
            pd(3,3,4,4,df)
            for i,opt in ipairs(opts) do
                local isc=opt==cur
                local ob=new("TextButton",{Size=UDim2.new(1,0,0,20),
                    BackgroundColor3=isc and T.CardH or T.Card,BackgroundTransparency=isc and 0 or 0.3,
                    Text="",BorderSizePixel=0,ZIndex=51,LayoutOrder=i},df)
                cor(5,ob)
                new("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,8,0,0),
                    BackgroundTransparency=1,Text=opt,
                    Font=isc and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=11,
                    TextColor3=isc and T.Acc or T.TxtP,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=51},ob)
                ob.MouseEnter:Connect(function() tw(ob,TI_F,{BackgroundTransparency=0}) end)
                ob.MouseLeave:Connect(function() tw(ob,TI_F,{BackgroundTransparency=isc and 0 or 0.3}) end)
                ob.MouseButton1Click:Connect(function()
                    cur=opt; CFG[key]=opt; btxt.Text=opt; closeDrop()
                    if cb then cb(opt) end
                end)
            end
        end)
    end

    -- SLIDER — uses global _sliderFn, each slider captures its own track reference
    local function sldr(par,key,mn,mx,stp,cb)
        local vl=new("TextLabel",{Size=UDim2.new(0,42,0,24),Position=UDim2.new(1,-146,0.5,-12),
            BackgroundTransparency=1,Text=tostring(CFG[key]),
            Font=Enum.Font.GothamBold,TextSize=11,TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Right},par)
        local track=new("Frame",{Size=UDim2.new(0,94,0,4),Position=UDim2.new(1,-98,0.5,-2),
            BackgroundColor3=T.TonOff,BorderSizePixel=0},par)
        cor(2,track)
        local pct0=math.clamp((CFG[key]-mn)/math.max(mx-mn,1),0,1)
        local fill=new("Frame",{Size=UDim2.new(pct0,0,1,0),BackgroundColor3=T.Acc,BorderSizePixel=0},track)
        cor(2,fill)
        local knob=new("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(pct0,-6,0.5,-6),
            BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},track)
        cor(8,knob)

        -- Each slider captures its OWN track + key — no cross-contamination
        local myTrack=track; local myKey=key; local myMn=mn; local myMx=mx; local myStp=stp

        local function doUpdate(x)
            if not myTrack.Parent then return end
            local ap=myTrack.AbsolutePosition; local as=myTrack.AbsoluteSize
            local p=math.clamp((x-ap.X)/math.max(as.X,1),0,1)
            local v=math.clamp(math.round((myMn+p*(myMx-myMn))/myStp)*myStp,myMn,myMx)
            CFG[myKey]=v; vl.Text=tostring(v)
            local fp=(v-myMn)/math.max(myMx-myMn,1)
            fill.Size=UDim2.new(fp,0,1,0); knob.Position=UDim2.new(fp,-6,0.5,-6)
            if cb then cb(v) end
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                _sliderFn=doUpdate; doUpdate(i.Position.X)
            end
        end)
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                _sliderFn=doUpdate
            end
        end)
        -- Extra safety: clear on mouse release over the track too
        track.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then _sliderFn=nil end
        end)
    end

    local function actBtn(par,txt,col,lo,cb)
        local r=crd(par,lo); local b=new("TextButton",{Size=UDim2.new(0,116,0,24),
            Position=UDim2.new(1,-118,0.5,-12),BackgroundColor3=col or T.Acc,BackgroundTransparency=0.2,
            Text=txt,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),BorderSizePixel=0},r)
        cor(6,b)
        b.MouseEnter:Connect(function() tw(b,TI_F,{BackgroundTransparency=0}) end)
        b.MouseLeave:Connect(function() tw(b,TI_F,{BackgroundTransparency=0.2}) end)
        b.MouseButton1Click:Connect(cb); return r
    end

    -- ══ IDENTITY ══════════════════════════════════════════
    local tId=mkScroll("identity")
    secH(tId,"Username",1)
    local c=crd(tId,2); rLbl(c,"Spoof Username","Replaces your username in Rivals UIs"); tog(c,"SpoofUsername")
    local c=crd(tId,3); rLbl(c,"Fake Username",""); txIn(c,"FakeUsername","AnoPlayer")
    secH(tId,"Display Name",4)
    local c=crd(tId,5); rLbl(c,"Spoof Display Name","Replaces display name in all UIs"); tog(c,"SpoofDisplay")
    local c=crd(tId,6); rLbl(c,"Fake Display Name",""); txIn(c,"FakeDisplay","anomia")
    secH(tId,"Other Players",7)
    local c=crd(tId,8); rLbl(c,"Spoof All Server Names","Replace every other player's name in your view"); tog(c,"SpoofOtherNames")
    local c=crd(tId,9); rLbl(c,"Replace With",""); txIn(c,"OtherNameReplace","[ anon ]")
    secH(tId,"Performance Display",10)
    local c=crd(tId,11); rLbl(c,"Spoof Ping",""); tog(c,"SpoofPing")
    local c=crd(tId,12); rLbl(c,"Fake Ping (ms)",""); sldr(c,"FakePing",1,999,1)
    local c=crd(tId,13); rLbl(c,"Spoof FPS",""); tog(c,"SpoofFPS")
    local c=crd(tId,14); rLbl(c,"Fake FPS",""); sldr(c,"FakeFPS",1,500,1)
    local c=crd(tId,15); rLbl(c,"Spoof Region",""); tog(c,"SpoofRegion")
    local c=crd(tId,16); rLbl(c,"Fake Region",""); txIn(c,"FakeRegion","EU-West")

    -- ══ STATS ══════════════════════════════════════════════
    local tStats=mkScroll("stats")
    local sDefs={
        {k="SpoofKills",  vk="FakeKills",   l="Kills",        mn=0,mx=999999,sp=1},
        {k="SpoofDeaths", vk="FakeDeaths",  l="Deaths",       mn=0,mx=999999,sp=1},
        {k="SpoofStreak", vk="FakeStreak",  l="Win Streak",   mn=0,mx=9999,  sp=1},
        {k="SpoofWins",   vk="FakeWins",    l="Wins",         mn=0,mx=999999,sp=1},
        {k="SpoofLosses", vk="FakeLosses",  l="Losses",       mn=0,mx=999999,sp=1},
        {k="SpoofWinRate",vk="FakeWinRate", l="Win Rate %",   mn=0,mx=100,   sp=1},
        {k="SpoofELO",    vk="FakeELO",     l="ELO",          mn=0,mx=5000,  sp=25},
        {k="SpoofLevel",  vk="FakeLevel",   l="Career Level", mn=1,mx=999,   sp=1},
    }
    for i,d in ipairs(sDefs) do
        local b=i*3; secH(tStats,d.l,b-2)
        local c=crd(tStats,b-1); rLbl(c,"Spoof "..d.l,nil); tog(c,d.k)
        local c=crd(tStats,b);   rLbl(c,"Value",""); sldr(c,d.vk,d.mn,d.mx,d.sp)
    end
    secH(tStats,"Loadout Spoofer",40)
    local c=crd(tStats,41); rLbl(c,"Spoof Loadout","Replaces your Primary/Secondary/Melee/Utility in career/UI"); tog(c,"SpoofLoadout")
    local c=crd(tStats,42,36); rLbl(c,"Primary",""); ddrop(c,"LoadoutPrimary",PRIMARIES)
    local c=crd(tStats,43,36); rLbl(c,"Secondary",""); ddrop(c,"LoadoutSecondary",SECONDARIES)
    local c=crd(tStats,44,36); rLbl(c,"Melee",""); ddrop(c,"LoadoutMelee",MELEES)
    local c=crd(tStats,45,36); rLbl(c,"Utility",""); ddrop(c,"LoadoutUtility",UTILITIES)
    secH(tStats,"Rank Preview",46)
    local cRank=crd(tStats,47)
    local rPrev=new("TextLabel",{Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left},cRank)
    task.spawn(function()
        while rPrev and rPrev.Parent do rPrev.Text=elo2rank(CFG.FakeELO).."  ("..CFG.FakeELO.." ELO)"; task.wait(0.8) end
    end)

    -- ══ STATUS ═════════════════════════════════════════════
    local tStatus=mkScroll("status")
    secH(tStatus,"Account Badge",1)
    local c=crd(tStatus,2,36); rLbl(c,"Status Badge","Badge prepended to your display name")
    ddrop(c,"StatusBadge",{"None","Roblox+","Moderator","Developer","RobloxMod"})
    local cPv=crd(tStatus,3)
    local pvL=new("TextLabel",{Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=T.Acc,TextXAlignment=Enum.TextXAlignment.Left},cPv)
    task.spawn(function() while pvL and pvL.Parent do pvL.Text="Preview:  "..fakeDisp(); task.wait(0.5) end end)
    secH(tStatus,"Rank Season Spoofer",4)
    local c=crd(tStatus,5); rLbl(c,"Enable Rank Spoof","Replaces rank tier text in all Rivals UIs"); tog(c,"RankSpoof")
    local c=crd(tStatus,6,36); rLbl(c,"Season",""); ddrop(c,"RankSeason",{"Season 0","Season 1","Season 2"})
    local c=crd(tStatus,7,36); rLbl(c,"Rank Tier","")
    ddrop(c,"RankTier",{"Unranked","Bronze III","Bronze II","Bronze I","Silver III","Silver II","Silver I",
        "Gold III","Gold II","Gold I","Platinum III","Platinum II","Platinum I",
        "Diamond III","Diamond II","Diamond I","Onyx III","Onyx II","Onyx I","Nemesis","Archnemesis"})

    -- ══ COSMETICS ══════════════════════════════════════════
    local tCos=mkScroll("cosmetics")
    local n=crd(tCos,1,30); new("TextLabel",{Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="Visual client-side only. Skin tint changes your equipped weapon's color.",
        Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},n)

    secH(tCos,"Weapon Skins",2)
    local c=crd(tCos,3); rLbl(c,"Enable Skin","Tints equipped weapon to match skin theme"); tog(c,"SkinEnabled",function(v) if v then applySkinTint() end end)
    local c=crd(tCos,4,36); rLbl(c,"Skin","Real Rivals skins (applies tint color)")
    ddrop(c,"SelectedSkin",SKINS,function() applySkinTint() end)

    secH(tCos,"Wraps",5)
    local c=crd(tCos,6); rLbl(c,"Enable Wrap","Shows wrap name in career/UI displays"); tog(c,"WrapEnabled")
    local c=crd(tCos,7,36); rLbl(c,"Wrap","Real Rivals wraps (patches UI text)"); ddrop(c,"SelectedWrap",WRAPS)

    secH(tCos,"Charms",8)
    local c=crd(tCos,9); rLbl(c,"Enable Charm","Shows charm name in career/UI displays"); tog(c,"CharmEnabled")
    local c=crd(tCos,10,36); rLbl(c,"Charm","Real Rivals charms"); ddrop(c,"SelectedCharm",CHARMS)

    secH(tCos,"Finishers",11)
    local c=crd(tCos,12); rLbl(c,"Enable Finisher","Shows finisher name in career/UI displays"); tog(c,"FinisherEnabled")
    local c=crd(tCos,13,36); rLbl(c,"Finisher","Real Rivals finishers"); ddrop(c,"SelectedFinisher",FINISHERS)

    secH(tCos,"Ranked Charm",14)
    local c=crd(tCos,15); rLbl(c,"Enable Ranked Charm","Shows a rank/season-specific charm in UI"); tog(c,"RankCharmEnabled")
    local c=crd(tCos,16,36); rLbl(c,"Charm","Season/rank charm to display"); ddrop(c,"RankCharm",RANK_CHARMS)

    secH(tCos,"Active Preview",17)
    local cCP=crd(tCos,18,46)
    local cpL=new("TextLabel",{Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="",Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.TxtP,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},cCP)
    task.spawn(function()
        while cpL and cpL.Parent do
            cpL.Text=string.format("Skin: %s\nWrap: %s  |  Charm: %s  |  Finish: %s",
                CFG.SkinEnabled and CFG.SelectedSkin or "—",
                CFG.WrapEnabled and CFG.SelectedWrap or "—",
                CFG.CharmEnabled and CFG.SelectedCharm or "—",
                CFG.FinisherEnabled and CFG.SelectedFinisher or "—")
            task.wait(0.5)
        end
    end)

    -- ══ KILL MESSAGE ════════════════════════════════════════
    local tKM=mkScroll("killmsg")
    secH(tKM,"Kill Message Override",1)
    local n=crd(tKM,2,34); new("TextLabel",{Size=UDim2.new(1,-24,1,0),BackgroundTransparency=1,
        Text="Replaces the 'Eliminated [name]' text Rivals shows. Disable RichText automatically.",
        Font=Enum.Font.Gotham,TextSize=10,TextColor3=T.TxtS,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},n)
    local c=crd(tKM,3); rLbl(c,"Enable Kill Message","Hook and replace Rivals elimination text"); tog(c,"KillMsgEnabled")
    local c=crd(tKM,4); rLbl(c,"Custom Message",""); txIn(c,"KillMsgText","anomia wiped target")
    actBtn(tKM,"Test Entry",T.Acc,5,function() pushKF() end)

    -- ══ WATERMARK ══════════════════════════════════════════
    local tWM=mkScroll("watermark")
    local c=crd(tWM,1); rLbl(c,"Show Watermark",""); tog(c,"WMEnabled",function(v) if WM_GUI then WM_GUI.Enabled=v end end)
    local c=crd(tWM,2); rLbl(c,"Rainbow Text",""); tog(c,"WMRainbow")

    -- ══ EXTRA ══════════════════════════════════════════════
    local tExt=mkScroll("extra")
    secH(tExt,"Utilities",1)
    local xd={
        {k="InfJump", l="Infinite Jump",  t="Jump in mid-air infinitely",  cb=function(v) if v then startInfJump() end end},
        {k="Noclip",  l="Noclip",         t="Phase through geometry",      cb=function(v) if v then startNoclip()  end end},
        {k="FakeAFK", l="Anti-AFK",       t="Nudge every 55s vs kick",     cb=function(v) if v then startAFK()     end end},
        {k="CleanHUD",l="Clean HUD",      t="Hide health/backpack HUD",    cb=function(v)
            pcall(function()
                SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health,not v)
                SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,not v)
            end)
        end},
    }
    for i,x in ipairs(xd) do local c=crd(tExt,i+1); rLbl(c,x.l,x.t); tog(c,x.k,x.cb) end

    -- ══ CONFIG ══════════════════════════════════════════════
    local tCfg=mkScroll("config")
    secH(tCfg,"Theme",1)
    local c=crd(tCfg,2,36); rLbl(c,"Theme","Dark = deep blue-black | Light = white")
    ddrop(c,"Theme",{"Dark","Light"},function(v) CFG.Theme=v; applyTheme(); buildWM() end)

    secH(tCfg,"Config Slots",3)
    for s=1,3 do
        local c=crd(tCfg,3+s,40); rLbl(c,"Slot "..s..(CFG.ConfigSlot==s and " (active)" or ""),nil)
        local fr=new("Frame",{Size=UDim2.new(0,120,0,24),Position=UDim2.new(1,-122,0.5,-12),BackgroundTransparency=1},c)
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Right},fr)
        local slot=s
        local function mBtn(txt,col,cb2)
            local b=new("TextButton",{Size=UDim2.new(0,54,1,0),BackgroundColor3=col,BackgroundTransparency=0.25,
                Text=txt,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.new(1,1,1),BorderSizePixel=0},fr)
            cor(5,b)
            b.MouseEnter:Connect(function() tw(b,TI_F,{BackgroundTransparency=0}) end)
            b.MouseLeave:Connect(function() tw(b,TI_F,{BackgroundTransparency=0.25}) end)
            b.MouseButton1Click:Connect(cb2)
        end
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
    local kbDefs={{l="Toggle Menu",k1="MenuKey",k2="MenuKey2"},{l="Cycle Config",k1="CfgCycleKey",k2="CfgCycleKey2"}}
    for i,kd in ipairs(kbDefs) do
        local c=crd(tCfg,10+i,40); rLbl(c,kd.l,"Two keys supported")
        local fr=new("Frame",{Size=UDim2.new(0.42,0,0,24),Position=UDim2.new(0.56,0,0.5,-12),BackgroundTransparency=1},c)
        new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)},fr)
        for _,kk in ipairs({kd.k1,kd.k2}) do
            local box=new("TextButton",{Size=UDim2.new(0.5,-2,1,0),BackgroundColor3=T.Win,BackgroundTransparency=0.15,
                Text=CFG[kk]=="" and "—" or CFG[kk],Font=Enum.Font.GothamBold,TextSize=10,
                TextColor3=T.Acc,BorderSizePixel=0},fr)
            cor(5,box); str(T.Bdr,1,0,box)
            local ls=false
            box.MouseButton1Click:Connect(function()
                if ls then return end;ls=true;box.Text="..."
                local cn; cn=UIS.InputBegan:Connect(function(inp,gp)
                    if gp then return end; local kn=inp.KeyCode.Name; if kn=="Unknown" then kn="" end
                    CFG[kk]=kn; box.Text=kn=="" and "—" or kn; ls=false; cn:Disconnect()
                end)
            end)
        end
    end

    if tabFrames[activeTab] then tabFrames[activeTab].Visible=true end
end

-- ═══════════════════════════════════════════════════════════
--  KEYBINDS
-- ═══════════════════════════════════════════════════════════
local cfgCD=false
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end; local kn=inp.KeyCode.Name
    if kn==CFG.MenuKey or (CFG.MenuKey2~="" and kn==CFG.MenuKey2) then
        menuOpen=not menuOpen; if MAIN_GUI then MAIN_GUI.Enabled=menuOpen end
    end
    if not cfgCD and (kn==CFG.CfgCycleKey or (CFG.CfgCycleKey2~="" and kn==CFG.CfgCycleKey2)) then
        cfgCD=true; CFG.ConfigSlot=(CFG.ConfigSlot%3)+1; loadSlot(CFG.ConfigSlot)
        pcall(function() SG:SetCore("SendNotification",{Title="anomia",Text="Slot "..CFG.ConfigSlot.." loaded",Duration=2}) end)
        task.delay(0.5,function() cfgCD=false end)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  INIT
-- ═══════════════════════════════════════════════════════════
local function init()
    buildKF(); buildWM(); buildUI()
    task.spawn(function()
        task.wait(1)
        pcall(function()
            SG:SetCore("SendNotification",{
                Title="Anomia V2  |  Freemium",
                Text="Rivals Spoofer — "..CFG.MenuKey.." to toggle menu",Duration=5,
            })
        end)
    end)
end
init()
