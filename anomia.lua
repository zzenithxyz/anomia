-- ANOMIA V2
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local CFG = {
    KillMsgEnabled = true,
    KillMsgText = "anomia",   -- put * like this: *text here* = yellow + black stroke like rivals eliminated text
}

local kmLabels = setmetatable({}, {__mode = "k"})

local function isOurGui(obj)
    local p = obj
    while p and p ~= game do
        if p.Name and p.Name:find("^Ano") then return true end
        p = p.Parent
    end
    return false
end

local function hookKillLabel(lbl)
    if kmLabels[lbl] or isOurGui(lbl) then return end
    kmLabels[lbl] = true

    local function forceReplace()
        local text = lbl.Text
        local lower = text:lower()
        if not (lower:find("eliminat") or lower:find("wiped") or lower:find("defeat")) then
            return
        end

        if CFG.KillMsgText:find("%*.-%*") then
            pcall(function()
                lbl.RichText = true
                local styled = CFG.KillMsgText:gsub("%*(.-)%*", "<stroke color=\"rgb(0,0,0)\" thickness=\"2.8\"><font color=\"rgb(255,220,0)\"><b>%1</b></font></stroke>")
                lbl.Text = styled
            end)
        else
            pcall(function() lbl.RichText = false end)
            lbl.Text = CFG.KillMsgText
        end
    end

    -- Very aggressive connection
    lbl:GetPropertyChangedSignal("Text"):Connect(forceReplace)

    -- Multiple instant forces when label is detected
    task.spawn(function()
        for i = 1, 20 do
            task.wait(0.015)  -- very tight timing
            forceReplace()
        end
    end)

    -- Initial force
    task.delay(0.05, forceReplace)
end

local function scanForKillFeed(root)
    if isOurGui(root) then return end

    task.spawn(function()
        for _, v in ipairs(root:GetDescendants()) do
            if (v:IsA("TextLabel") or v:IsA("TextButton")) then
                local lower = v.Text:lower()
                if lower:find("eliminat") or lower:find("wiped") then
                    hookKillLabel(v)
                end
            end
        end
    end)

    root.DescendantAdded:Connect(function(v)
        if (v:IsA("TextLabel") or v:IsA("TextButton")) and not isOurGui(v) then
            task.delay(0.03, function()
                local lower = v.Text:lower()
                if lower:find("eliminat") or lower:find("wiped") then
                    hookKillLabel(v)
                end
            end)
        end
    end)
end

-- INIT
task.spawn(function()
    task.wait(0.8)

    local playerGui = lp:WaitForChild("PlayerGui", 5)
    if playerGui then scanForKillFeed(playerGui) end
    scanForKillFeed(game:GetService("CoreGui"))

    task.spawn(function()
        while true do
            task.wait(4)
            if playerGui then
                scanForKillFeed(playerGui)
            end
        end
    end)

    print("Anomia Loaded, to change config u have to edit the code ( its easy ), u can find the code at github and discord.gg/pKxWMrNBT")
end)
