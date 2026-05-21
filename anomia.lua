-- ═══════════════════════════════════════════════════
--  ANOMIA  v3.0  |  rivals  |  minimal clean build
--  RightShift = toggle  |  4 features only
-- ═══════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local SG = game:GetService("StarterGui")

local lp  = Players.LocalPlayer
local lpg = lp:WaitForChild("PlayerGui")

-- ── CONFIG ───────────────────────────────────────────
local CFG = {
    SpoofUsername  = false, FakeUsername = "AnoPlayer",
    SpoofDisplay   = false, FakeDisplay  = "anomia",
    KillMsg        = false, KillMsgText  = "anomia wiped target",
    SpoofOthers    = false, OtherReplace = "[ anon ]",
    MenuKey        = "RightShift",
}

-- ── SAVE / LOAD ──────────────────────────────────────
local function save()
    if not writefile then return end
    local ok,_ = pcall(writefile,"anomia_v30.json",Http:JSONEncode({
        SpoofUsername=CFG.SpoofUsername, FakeUsername=CFG.FakeUsername,
        SpoofDisplay=CFG.SpoofDisplay,   FakeDisplay=CFG.FakeDisplay,
        KillMsg=CFG.KillMsg,             KillMsgText=CFG.KillMsgText,
        SpoofOthers=CFG.SpoofOthers,     OtherReplace=CFG.OtherReplace,
    }))
end
local function load()
    if not readfile then return end
    local ok,raw = pcall(readfile,"anomia_v30.json")
    if not ok or not raw then return end
    local ok2,t = pcall(function() return Http:JSONDecode(raw) end)
    if not ok2 or not t then return end
    for k,v in pairs(t) do
        if CFG[k]~=nil and type(CFG[k])==type(v) then CFG[k]=v end
    end
end
load()

-- ── THEME ────────────────────────────────────────────
local ACC   = Color3.fromRGB(100, 170, 255)
local BG    = Color3.fromRGB(9,   11,  18)
local SIDE  = Color3.fromRGB(7,   9,   15)
local CARD  = Color3.fromRGB(17,  19,  30)
local CARDH = Color3.fromRGB(22,  24,  38)
local TXP   = Color3.fromRGB(228, 232, 245)
local TXS   = Color3.fromRGB(98,  106, 138)
local BDR   = Color3.fromRGB(24,  27,  44)
local TON   = Color3.fromRGB(36,  38,  56)
local WHITE = Color3.new(1,1,1)

local TI_F  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tw(i,p) TweenSvc:Create(i,TI_F,p):Play() end

local function new(c,p,par)
    local i=Instance.new(c)
    for k,v in pairs(p or {}) do i[k]=v end
    if par then i.Parent=par end
    return i
end
local function cor(r,p) return new("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function str(c,t,tr,p) return new("UIStroke",{Color=c,Thickness=t,Transparency=tr or 0},p) end
local function pd(t,b,l,r,p)
    return new("UIPadding",{
        PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),
        PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),
    },p)
end

-- ═══════════════════════════════════════════════════
--  SPOOF ENGINE
--  Rules:
--   1. Never touch our own GUI (AnoMain)
--   2. Never touch labels with RichText containing XML tags
--   3. Never touch chat / bubble / task GUIs
--   4. Kill message only fires on short labels that start with "Eliminated"
--   5. Zero polling loops — pure event-driven only
-- ═══════════════════════════════════════════════════

-- GUIs we must NEVER touch
local SKIP = {
    AnoMain=true,
    -- Rivals/Roblox GUIs to protect from contamination
    BubbleChat=true, PlayerChatGui=true, ChatGui=true,
    Chat=true, TextChatGui=true, RobloxGui=true,
    TopbarApp=true, ControlGui=true, TouchGui=true,
}

local function isSafe(obj)
    -- Walk up and check for forbidden parents
    local p = obj
    while p and p ~= game do
        if SKIP[p.Name] then return false end
        p = p.Parent
    end
    -- Never touch labels that have RichText XML tags
    -- (setting .Text on these would show raw XML as literal text)
    if obj.Text:find("<") and obj.Text:find(">") then return false end
    return true
end

-- Track which objects we already hooked (weak so GC can collect destroyed ones)
local hooked = {}; setmetatable(hooked, {__mode="k"})

-- Returns replaced text, or nil if nothing changed
local function spoof(text)
    local t = text
    if CFG.SpoofUsername and lp.Name ~= "" then
        t = t:gsub(lp.Name, CFG.FakeUsername)
    end
    if CFG.SpoofDisplay and lp.DisplayName ~= "" then
        t = t:gsub(lp.DisplayName, CFG.FakeDisplay)
    end
    return t ~= text and t or nil
end

-- Kill message: only replace SHORT labels that begin with "Eliminated"
local function isElimMsg(text)
    if #text > 100 then return false end
    local lo = text:lower():gsub("^%s+","")
    return lo:sub(1,10) == "eliminated"
end

-- Core hook: attaches to one label/button
local function hookLabel(obj)
    if hooked[obj] then return end
    if not(obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    if not isSafe(obj) then return end
    hooked[obj] = true

    local busy = false

    local function patch()
        if busy then return end
        busy = true

        -- Kill message check first (before spoof, so we don't double-process)
        if CFG.KillMsg and isElimMsg(obj.Text) then
            -- Disable RichText only here, only when it's truly an elim label
            if obj:IsA("TextLabel") then pcall(function() obj.RichText=false end) end
            obj.Text = CFG.KillMsgText
            busy = false; return
        end

        -- Name spoof
        local replaced = spoof(obj.Text)
        if replaced then obj.Text = replaced end

        busy = false
    end

    -- Connect ONCE
    obj:GetPropertyChangedSignal("Text"):Connect(function()
        if not isSafe(obj) then return end
        patch()
    end)
    patch()
end

-- Scan a subtree (batched — yields every 80 items to stay frame-rate safe)
local function scanTree(root)
    task.spawn(function()
        local d = root:GetDescendants()
        for i = 1, #d do
            pcall(hookLabel, d[i])
            if i % 80 == 0 then task.wait() end
        end
    end)
    root.DescendantAdded:Connect(function(v)
        task.defer(function() pcall(hookLabel, v) end)
    end)
end

-- Initial scan: fire at 1s, 2.5s, 5s to catch lazily-loaded Rivals UIs
-- (career page, match end screen, etc. all load on-demand)
for _, t in ipairs({1, 2.5, 5}) do
    task.delay(t, function() scanTree(lpg) end)
end

-- Re-scan whenever a new top-level GUI appears (Rivals spawns new GUIs per match)
lpg.ChildAdded:Connect(function(child)
    task.wait(0.1)
    if not SKIP[child.Name] then
        pcall(scanTree, child)
    end
end)

-- Re-scan on character respawn (overhead nametag resets)
lp.CharacterAdded:Connect(function(char)
    -- Patch the overhead BillboardGui Rivals creates for this player
    local function patchBB(v)
        if not(v:IsA("BillboardGui") or v:IsA("SurfaceGui")) then return end
        for _, lbl in ipairs(v:GetDescendants()) do
            if lbl:IsA("TextLabel") and not hooked[lbl] then
                pcall(hookLabel, lbl)
            end
        end
        v.DescendantAdded:Connect(function(d)
            if d:IsA("TextLabel") then task.defer(function() pcall(hookLabel,d) end) end
        end)
    end
    for _, v in ipairs(char:GetDescendants()) do pcall(patchBB, v) end
    char.DescendantAdded:Connect(function(v) task.defer(function() pcall(patchBB,v) end) end)

    -- Also re-scan PlayerGui after spawn (Rivals refreshes some UIs on respawn)
    task.wait(0.5)
    scanTree(lpg)
end)

if lp.Character then
    task.spawn(function()
        local char = lp.Character
        local function patchBB(v)
            if not(v:IsA("BillboardGui") or v:IsA("SurfaceGui")) then return end
            for _, lbl in ipairs(v:GetDescendants()) do pcall(hookLabel, lbl) end
        end
        for _, v in ipairs(char:GetDescendants()) do pcall(patchBB, v) end
        char.DescendantAdded:Connect(function(v) task.defer(function() pcall(patchBB,v) end) end)
    end)
end

-- Other players: hook their BillboardGui overhead names
local function hookOtherPlayer(plr)
    if plr == lp then return end
    local function hookChar(char)
        task.wait(0.3)
        local function patchBB(v)
            if not(v:IsA("BillboardGui") or v:IsA("SurfaceGui")) then return end
            for _, lbl in ipairs(v:GetDescendants()) do
                if lbl:IsA("TextLabel") and not hooked[lbl] then
                    local realName  = plr.Name
                    local realDisp  = plr.DisplayName
                    hooked[lbl] = true
                    local busy = false
                    local function p()
                        if busy or not CFG.SpoofOthers then return end
                        busy = true
                        local t = lbl.Text
                        -- Only replace if it's literally the player's name (not embedded in other text)
                        if t == realName or t == realDisp then
                            lbl.Text = CFG.OtherReplace
                        else
                            local r = t:gsub(realName, CFG.OtherReplace):gsub(realDisp, CFG.OtherReplace)
                            if r ~= t then lbl.Text = r end
                        end
                        busy = false
                    end
                    p()
                    lbl:GetPropertyChangedSignal("Text"):Connect(p)
                end
            end
        end
        for _, v in ipairs(char:GetDescendants()) do pcall(patchBB,v) end
        char.DescendantAdded:Connect(function(v) task.defer(function() pcall(patchBB,v) end) end)
    end
    if plr.Character then task.spawn(function() hookChar(plr.Character) end) end
    plr.CharacterAdded:Connect(function(c) task.spawn(function() hookChar(c) end) end)
end

for _, p in ipairs(Players:GetPlayers()) do hookOtherPlayer(p) end
Players.PlayerAdded:Connect(hookOtherPlayer)

-- Also hook other players' names in the PlayerGui scoreboards/kill feeds
-- (Rivals shows other player names in match UI)
Players.PlayerAdded:Connect(function(plr)
    if plr == lp then return end
    task.spawn(function()
        task.wait(0.5)
        -- Scan PlayerGui for any label containing this player's name
        for _, lbl in ipairs(lpg:GetDescendants()) do
            if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and not hooked[lbl] then
                if lbl.Text:find(plr.Name,1,true) or lbl.Text:find(plr.DisplayName,1,true) then
                    local busy=false
                    local rN=plr.Name; local rD=plr.DisplayName
                    hooked[lbl]=true
                    local function p()
                        if busy or not CFG.SpoofOthers then return end
                        busy=true
                        lbl.Text=lbl.Text:gsub(rN,CFG.OtherReplace):gsub(rD,CFG.OtherReplace)
                        busy=false
                    end
                    p(); lbl:GetPropertyChangedSignal("Text"):Connect(p)
                end
            end
        end
    end)
end)

-- ═══════════════════════════════════════════════════
--  UI  — minimal card, 4 feature rows, no tabs
-- ═══════════════════════════════════════════════════
local MAIN_GUI, menuOpen = nil, true
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

local function buildUI()
    if MAIN_GUI then MAIN_GUI:Destroy() end

    MAIN_GUI = new("ScreenGui", {
        Name="AnoMain", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=200, Enabled=menuOpen,
    }, lpg)

    -- Mobile show/hide button
    if isMobile then
        local mb = new("TextButton",{
            Size=UDim2.new(0,44,0,44), Position=UDim2.new(0,8,1,-54),
            BackgroundColor3=BG, Text="A", Font=Enum.Font.Fantasy,
            TextSize=22, TextColor3=ACC, BorderSizePixel=0,
        }, MAIN_GUI)
        cor(12,mb); str(ACC,1.5,0.4,mb)
        mb.MouseButton1Click:Connect(function()
            local r=MAIN_GUI:FindFirstChild("Root")
            if r then r.Visible=not r.Visible end
        end)
    end

    -- Root card
    local root = new("Frame",{
        Name="Root",
        Size=UDim2.new(0, isMobile and 300 or 340, 0, 10),
        AutomaticSize=Enum.AutomaticSize.Y,
        Position=isMobile and UDim2.new(0.5,-150,0.2,0) or UDim2.new(0.5,-170,0.5,-120),
        BackgroundColor3=BG, BorderSizePixel=0,
    }, MAIN_GUI)
    cor(14, root)
    str(BDR, 1.2, 0, root)

    -- Shadow
    new("ImageLabel",{
        Size=UDim2.new(1,36,1,36), Position=UDim2.new(0,-18,0,-18),
        BackgroundTransparency=1, Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0), ImageTransparency=0.52,
        ZIndex=0, ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(49,49,450,450),
    }, root)

    -- Drag
    do
        local drag,ds,rs=false,nil,nil
        local dragConn1, dragConn2
        root.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                drag=true;ds=i.Position;rs=root.Position
            end
        end)
        -- Use root-scoped move (no global UIS listener accumulation)
        dragConn1 = UIS.InputChanged:Connect(function(i)
            if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-ds
                root.Position=UDim2.new(rs.X.Scale,rs.X.Offset+d.X,rs.Y.Scale,rs.Y.Offset+d.Y)
            end
        end)
        dragConn2 = UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
        end)
        -- Clean up old drag connections if buildUI is called again
        MAIN_GUI.Destroying:Connect(function()
            if dragConn1 then dragConn1:Disconnect() end
            if dragConn2 then dragConn2:Disconnect() end
        end)
    end

    local content = new("Frame",{
        Size=UDim2.new(1,0,0,10), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, BorderSizePixel=0,
    }, root)
    new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},content)

    -- ── TITLE BAR ────────────────────────────────────
    local titleBar = new("Frame",{
        Size=UDim2.new(1,0,0,44),
        BackgroundColor3=SIDE, BorderSizePixel=0, LayoutOrder=0,
    }, content)
    new("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),
        BackgroundColor3=SIDE,BorderSizePixel=0},titleBar)
    -- Left accent line
    local ab=new("Frame",{Size=UDim2.new(0,3,0,20),Position=UDim2.new(0,12,0.5,-10),
        BackgroundColor3=ACC,BorderSizePixel=0},titleBar)
    cor(2,ab)
    -- A logo
    new("TextLabel",{Size=UDim2.new(0,32,1,0),Position=UDim2.new(0,20,0,0),
        BackgroundTransparency=1,Text="A",Font=Enum.Font.Fantasy,TextSize=24,
        TextColor3=WHITE,TextXAlignment=Enum.TextXAlignment.Center},titleBar)
    -- Title
    new("TextLabel",{Size=UDim2.new(0,160,1,0),Position=UDim2.new(0,56,0,0),
        BackgroundTransparency=1,Text="anomia  v3.0",
        Font=Enum.Font.GothamBold,TextSize=14,TextColor3=TXP,
        TextXAlignment=Enum.TextXAlignment.Left},titleBar)
    -- Sub
    new("TextLabel",{Size=UDim2.new(0,100,1,0),Position=UDim2.new(1,-108,0,0),
        BackgroundTransparency=1,Text="rivals",
        Font=Enum.Font.Gotham,TextSize=11,TextColor3=TXS,
        TextXAlignment=Enum.TextXAlignment.Right},titleBar)
    -- Divider
    local div=new("Frame",{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,1,-1),
        BackgroundColor3=BDR,BorderSizePixel=0},titleBar)

    -- ── FEATURE ROW BUILDER ──────────────────────────
    -- Each row: toggle on left, text box input below when enabled
    local rowOrder = 1

    local function makeRow(toggleKey, inputKey, label, placeholder)
        local lo = rowOrder; rowOrder = rowOrder + 1

        local wrap = new("Frame",{
            Size=UDim2.new(1,0,0,10), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, BorderSizePixel=0, LayoutOrder=lo,
        }, content)
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},wrap)

        -- Top row: label + toggle
        local topRow = new("Frame",{
            Size=UDim2.new(1,0,0,42),
            BackgroundColor3=CARD, BorderSizePixel=0, LayoutOrder=1,
        }, wrap)
        pd(0,0,14,14,topRow)

        -- Hover effect
        topRow.MouseEnter:Connect(function() tw(topRow,{BackgroundColor3=CARDH}) end)
        topRow.MouseLeave:Connect(function() tw(topRow,{BackgroundColor3=CARD}) end)

        -- Label
        local lbl = new("TextLabel",{
            Size=UDim2.new(0.6,0,1,0),
            BackgroundTransparency=1, Text=label,
            Font=Enum.Font.GothamBold, TextSize=12,
            TextColor3=TXP, TextXAlignment=Enum.TextXAlignment.Left,
        }, topRow)

        -- Toggle
        local on = CFG[toggleKey]
        local track = new("TextButton",{
            Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-40,0.5,-10),
            BackgroundColor3=on and ACC or TON,
            Text="", BorderSizePixel=0,
        }, topRow)
        cor(10, track)
        local knob = new("Frame",{
            Size=UDim2.new(0,14,0,14),
            Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=WHITE, BorderSizePixel=0,
        }, track)
        cor(8, knob)

        -- Input row (shown when toggle is ON)
        local inputRow = new("Frame",{
            Size=UDim2.new(1,0,0,on and 36 or 0),
            BackgroundColor3=SIDE, BorderSizePixel=0, LayoutOrder=2,
            ClipsDescendants=true,
        }, wrap)

        local bx = new("TextBox",{
            Size=UDim2.new(1,-24,0,24), Position=UDim2.new(0,12,0.5,-12),
            BackgroundColor3=BG, BackgroundTransparency=0.1,
            BorderSizePixel=0,
            Text=tostring(CFG[inputKey] or ""),
            PlaceholderText=placeholder or "",
            Font=Enum.Font.Gotham, TextSize=12,
            TextColor3=TXP, PlaceholderColor3=TXS,
            ClearTextOnFocus=false,
        }, inputRow)
        cor(7,bx); str(BDR,1,0,bx)
        bx.Focused:Connect(function()
            tw(bx,{BackgroundTransparency=0})
            for _,s in ipairs(bx:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,{Color=ACC}) end
            end
        end)
        bx.FocusLost:Connect(function()
            tw(bx,{BackgroundTransparency=0.1})
            for _,s in ipairs(bx:GetChildren()) do
                if s:IsA("UIStroke") then tw(s,{Color=BDR}) end
            end
            CFG[inputKey] = bx.Text
            save()
        end)

        -- Toggle click
        track.MouseButton1Click:Connect(function()
            CFG[toggleKey] = not CFG[toggleKey]
            local v = CFG[toggleKey]
            tw(track, {BackgroundColor3=v and ACC or TON})
            tw(knob,  {Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)})
            -- Expand/collapse input row
            tw(inputRow, {Size=UDim2.new(1,0,0,v and 36 or 0)})
            save()
        end)

        -- Divider at bottom of each row
        local rowDiv = new("Frame",{
            Size=UDim2.new(1,-24,0,1), Position=UDim2.new(0,12,1,-1),
            BackgroundColor3=BDR, BorderSizePixel=0, LayoutOrder=3,
        }, wrap)
        -- Hide last divider (handled by checking if it's last)
        return wrap
    end

    makeRow("SpoofUsername",  "FakeUsername",  "Username Changer",    "fake username...")
    makeRow("SpoofDisplay",   "FakeDisplay",   "Display Name Changer","fake display name...")
    makeRow("KillMsg",        "KillMsgText",   "Kill Message",        "custom kill text...")
    makeRow("SpoofOthers",    "OtherReplace",  "Others' Names",       "replacement name...")

    -- ── SAVE INDICATOR ───────────────────────────────
    local footer = new("Frame",{
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=SIDE, BorderSizePixel=0, LayoutOrder=rowOrder,
    }, content)
    new("Frame",{Size=UDim2.new(1,0,0,12),BackgroundColor3=SIDE,BorderSizePixel=0},footer)
    new("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1,Text="anomia v3.0  |  auto-saved  |  "..CFG.MenuKey.." = toggle",
        Font=Enum.Font.Gotham,TextSize=10,TextColor3=TXS,TextXAlignment=Enum.TextXAlignment.Left},footer)
end

-- ── KEYBIND ──────────────────────────────────────────
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode.Name == CFG.MenuKey then
        menuOpen = not menuOpen
        if MAIN_GUI then MAIN_GUI.Enabled = menuOpen end
    end
end)

-- ── INIT ─────────────────────────────────────────────
buildUI()

pcall(function()
    task.wait(1)
    SG:SetCore("SendNotification",{
        Title="anomia v3.0",
        Text="rivals spoofer loaded — "..CFG.MenuKey.." to toggle",
        Duration=4,
    })
end)
