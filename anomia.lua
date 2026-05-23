local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local CFG = {
    KillMsgEnabled = true,
    KillMsgText = "anomia",
}

local kmLabels = setmetatable({}, {__mode = "k"})
local originalText = setmetatable({}, {__mode = "k"})

local function buildStyled(raw)
    if raw:find("%*.-%*") then
        return true, (raw:gsub("%*(.-)%*", '<stroke color="rgb(0,0,0)" thickness="2.8" joins="miter"><font color="rgb(255,220,0)"><b>%1</b></font></stroke>'))
    end
    return false, raw
end

local function isOurGui(obj)
    local p = obj
    while p and p ~= game do
        if p.Name and p.Name:find("^Ano") then return true end
        p = p.Parent
    end
    return false
end

local function matchesKill(s)
    if not s or s == "" then return false end
    local l = s:lower()
    return l:find("eliminat") or l:find("wiped") or l:find("defeat") or l:find("killed") ~= nil
end

local function applyReplace(lbl)
    if not lbl or not lbl.Parent then return end
    local ok, cur = pcall(function() return lbl.Text end)
    if not ok then return end

    local stored = originalText[lbl]
    if stored == cur then return end

    if not matchesKill(cur) and not matchesKill(stored or "") then
        return
    end

    local useRich, styled = buildStyled(CFG.KillMsgText)
    pcall(function()
        lbl.RichText = useRich
        lbl.Text = styled
    end)
    originalText[lbl] = styled
end

local function hookKillLabel(lbl)
    if kmLabels[lbl] or isOurGui(lbl) then return end
    if not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then return end
    kmLabels[lbl] = true

    applyReplace(lbl)

    lbl:GetPropertyChangedSignal("Text"):Connect(function()
        applyReplace(lbl)
    end)

    lbl:GetPropertyChangedSignal("RichText"):Connect(function()
        applyReplace(lbl)
    end)

    lbl.AncestryChanged:Connect(function(_, parent)
        if parent then
            applyReplace(lbl)
        end
    end)

    task.spawn(function()
        local t0 = tick()
        while lbl.Parent and tick() - t0 < 1.5 do
            applyReplace(lbl)
            RunService.RenderStepped:Wait()
        end
    end)
end

local function tryHook(v)
    if not v or isOurGui(v) then return end
    if not (v:IsA("TextLabel") or v:IsA("TextButton")) then return end
    local ok, txt = pcall(function() return v.Text end)
    if ok and matchesKill(txt) then
        hookKillLabel(v)
    end
end

local scanned = setmetatable({}, {__mode = "k"})

local function scanForKillFeed(root)
    if not root or isOurGui(root) or scanned[root] then return end
    scanned[root] = true

    for _, v in ipairs(root:GetDescendants()) do
        tryHook(v)
    end

    root.DescendantAdded:Connect(function(v)
        if isOurGui(v) then return end
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            tryHook(v)
            v:GetPropertyChangedSignal("Text"):Connect(function()
                tryHook(v)
            end)
        end
    end)
end

task.spawn(function()
    local playerGui = lp:WaitForChild("PlayerGui", 10)
    if playerGui then scanForKillFeed(playerGui) end

    pcall(function()
        local cg = game:GetService("CoreGui")
        scanForKillFeed(cg)
    end)

    lp.ChildAdded:Connect(function(c)
        if c.Name == "PlayerGui" then
            scanForKillFeed(c)
        end
    end)

    if playerGui then
        playerGui.ChildAdded:Connect(function()
            scanForKillFeed(playerGui)
        end)
    end

    RunService.RenderStepped:Connect(function()
        for lbl in pairs(kmLabels) do
            if lbl.Parent then
                local ok, cur = pcall(function() return lbl.Text end)
                if ok and cur ~= originalText[lbl] then
                    applyReplace(lbl)
                end
            end
        end
    end)

    print("Anomia Loaded, to change config u have to edit the code ( its easy ), u can find the code at github and discord.gg/pKxWMrNBT")
end)
