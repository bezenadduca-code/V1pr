-- SAKIWARE | maintained by mitsuki | original by v1pr/glov
print("SAKIWARE loaded")

------------------------------------------------------------------------
-- services
------------------------------------------------------------------------
local svc = {
    Players        = game:GetService("Players"),
    Run            = game:GetService("RunService"),
    Input          = game:GetService("UserInputService"),
    RS             = game:GetService("ReplicatedStorage"),
    WS             = game:GetService("Workspace"),
    TweenService   = game:GetService("TweenService"),
    TextChat       = game:GetService("TextChatService"),
    Http           = game:GetService("HttpService"),
}

local lp  = svc.Players.LocalPlayer
local gui = lp:WaitForChild("PlayerGui", 10)

------------------------------------------------------------------------
-- filesystem shims
------------------------------------------------------------------------
local fs = {
    hasFolder = isfolder     or function() return false end,
    makeFolder= makefolder   or function() end,
    write     = writefile    or function() end,
    hasFile   = isfile       or function() return false end,
    read      = readfile     or function() return "" end,
    asset     = getcustomasset or function(p) return p end,
}



------------------------------------------------------------------------
-- WindUI
------------------------------------------------------------------------
local ui = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local win = ui:CreateWindow({
    Title          = "SAKIWARE",
    Icon           = "sparkles",
    Author         = "mitsuki",
    Folder         = "SAKIWARE",
    Size           = UDim2.fromOffset(350, 300),
    Transparent    = false,
    Theme          = "Dark",
    Resizable      = false,
    SideBarWidth   = 150,
    HideSearchBar  = true,
    ScrollBarEnabled = false,
})

local ConfigManager = win.ConfigManager
local sakiConfig = ConfigManager:CreateConfig("sakiware")

win:SetToggleKey(Enum.KeyCode.L)
ui:SetFont("rbxasset://fonts/families/AccanthisADFStd.json")

win:EditOpenButton({
    Title          = "SAKIWARE",
    Icon           = "sparkles",
    CornerRadius   = UDim.new(0, 16),
    StrokeThickness = 0,
    Color = ColorSequence.new(Color3.fromHex("000000"), Color3.fromHex("000000")),
    OnlyMobile = true,
    Enabled    = true,
    Draggable  = true,
})

------------------------------------------------------------------------
-- helpers
------------------------------------------------------------------------
local function getTeamFolder(name)
    local root = svc.WS:FindFirstChild("Players")
    return root and root:FindFirstChild(name)
end
local function getIngame()
    local m = svc.WS:FindFirstChild("Map")
    return m and m:FindFirstChild("Ingame")
end
local function getMapContent()
    local ig = getIngame()
    return ig and ig:FindFirstChild("Map")
end

-- FIX: centralised Network require so path is corrected in one place
local _networkModule = nil
local function getNetwork()
    if _networkModule then return _networkModule end
    local ok, m = pcall(function()
        return require(svc.RS.Modules.Network.Network)
    end)
    if ok and m then _networkModule = m end
    return _networkModule
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: SETTINGS
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabSettings = win:Tab({ Title = "Settings", Icon = "settings" })
local secInterface = tabSettings:Section({ Title = "Interface", Opened = true })

local chatForceEnabled = false
local chatForceConn    = nil
local function enforceChatOn()
    if not chatForceEnabled then return end
    local cw = svc.TextChat:FindFirstChild("ChatWindowConfiguration")
    local ci = svc.TextChat:FindFirstChild("ChatInputBarConfiguration")
    if cw and not cw.Enabled then cw.Enabled = true end
    if ci and not ci.Enabled then ci.Enabled = true end
end
secInterface:Toggle({
    Title = "Show Chat Logs", Type = "Checkbox", Flag = "chatForceEnabled", Default = chatForceEnabled,
    Callback = function(on)
        chatForceEnabled = on; sakiConfig:Save()
        if chatForceConn then chatForceConn:Disconnect(); chatForceConn = nil end
        if on then
            enforceChatOn()
            chatForceConn = svc.Run.Heartbeat:Connect(enforceChatOn)
            for _, key in ipairs({ "ChatWindowConfiguration", "ChatInputBarConfiguration" }) do
                local obj = svc.TextChat:FindFirstChild(key)
                if obj then obj:GetPropertyChangedSignal("Enabled"):Connect(enforceChatOn) end
            end
        end
    end
})

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: GLOBAL
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabGlobal  = win:Tab({ Title = "Global", Icon = "globe" })
local secStamina = tabGlobal:Section({ Title = "Stamina", Opened = true })

local stam = {
    on      = false,
    loss    = 10,
    gain    = 20,
    max     = 100,
    current = 100,
    noLoss  = false,
    thread  = nil,
}

-- FIX: corrected path — verify this in your explorer under ReplicatedStorage.Systems
local function stamModule()
    local ok, m = pcall(function() return require(svc.RS.Systems.Character.Game.Sprinting) end)
    return ok and m or nil
end
local function stamIsKiller()
    local ch = lp.Character; if not ch then return false end
    local kf = getTeamFolder("Killers")
    return kf and ch:IsDescendantOf(kf)
end
local function stamApply()
    local m = stamModule(); if not m then return end
    if not m.DefaultsSet then pcall(function() m.Init() end) end
    local forceNoLoss = stam.noLoss or stamIsKiller()
    m.StaminaLoss = stam.loss; m.StaminaGain = stam.gain
    local abilityCapActive = type(m.StaminaCap) == "number" and m.StaminaCap < (m.MaxStamina or math.huge)
    if not abilityCapActive then
        m.MaxStamina = stam.max
        if type(m.StaminaCap) == "number" then m.StaminaCap = stam.max end
    end
    m.StaminaLossDisabled = forceNoLoss
    if m.Stamina and m.Stamina > stam.max then m.Stamina = stam.current end
    pcall(function() if m.__staminaChangedEvent then m.__staminaChangedEvent:Fire() end end)
end
local function stamStart()
    if stam.thread then return end
    stam.thread = task.spawn(function()
        while stam.on do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then stamApply() end
            task.wait(0.5)
        end; stam.thread = nil
    end)
end
local function stamStop()
    stam.on = false
    if stam.thread then task.cancel(stam.thread); stam.thread = nil end
end
secStamina:Toggle({ Title = "Custom Stamina", Type = "Checkbox", Flag = "stamOn", Default = stam.on,
    Callback = function(on) stam.on = on; sakiConfig:Save(); if on then stamStart() else stamStop() end end })
secStamina:Slider({ Title = "Loss Rate",     Flag = "stamLoss",    Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.loss    }, Callback = function(v) stam.loss    = v; sakiConfig:Save() end })
secStamina:Slider({ Title = "Gain Rate",     Flag = "stamGain",    Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.gain    }, Callback = function(v) stam.gain    = v; sakiConfig:Save() end })
secStamina:Slider({ Title = "Max Pool",      Flag = "stamMax",     Step = 1, Value = { Min = 50, Max = 500, Default = stam.max     }, Callback = function(v) stam.max     = v; sakiConfig:Save() end })
secStamina:Slider({ Title = "Current Value", Flag = "stamCurrent", Step = 1, Value = { Min = 0,  Max = 500, Default = stam.current }, Callback = function(v) stam.current = v; sakiConfig:Save() end })
secStamina:Toggle({ Title = "Infinite Stamina", Type = "Checkbox", Flag = "stamNoLoss", Default = stam.noLoss,
    Callback = function(on)
        stam.noLoss = on; sakiConfig:Save(); stamApply()
        if on and not stam.on then stam.on = true; stamStart() end
    end
})
if stam.on then stamStart() end
lp.CharacterAdded:Connect(function()
    task.delay(1.5, function()
        if stam.on then stamApply(); if not stam.thread then stamStart() end end
    end)
end)

local secStatus = tabGlobal:Section({ Title = "Status", Opened = true })
-- FIX: correct paths confirmed as Modules.Schematics.StatusEffects.*
-- Glitched is a LocalScript inside KillerExclusive.Glitched.Frame — handled separately
local statusGroups = {
    Slowness      = { on = false, paths = { "Modules.Schematics.StatusEffects.Slowness" } },
    Hallucination = { on = false, paths = { "Modules.Schematics.StatusEffects.KillerExclusive.Hallucination" } },
    Visual        = { on = false, paths = {
        "Modules.Schematics.StatusEffects.Blindness",
        "Modules.Schematics.StatusEffects.SurvivorExclusive.Subspaced",
        -- Glitched is a LocalScript inside a Frame, destroyed via parent folder instead
        "Modules.Schematics.StatusEffects.KillerExclusive.Glitched",
    }},
}
local statusBackup = {}
local function statusResolve(path)
    local node = svc.RS
    for seg in path:gmatch("[^%.]+") do node = node:FindFirstChild(seg); if not node then return nil end end
    return node
end
local function statusBlock(path)
    if statusBackup[path] then return end
    local mod = statusResolve(path)
    if not mod then return end
    -- Glitched is a Folder containing a Frame containing a LocalScript — destroy the folder
    if mod:IsA("Folder") then
        statusBackup[path] = { clone = mod:Clone(), isFolder = true, parentPath = path:match("^(.-)%.?[^%.]+$") }
        mod:Destroy()
    elseif mod:IsA("ModuleScript") or mod:IsA("LocalScript") then
        statusBackup[path] = { clone = mod:Clone(), src = mod.Source, isFolder = false }
        mod:Destroy()
    end
end
local function statusRestore(path)
    local saved = statusBackup[path]; if not saved then return end
    local existing = statusResolve(path); if existing then existing:Destroy() end
    local parentPath = saved.parentPath or path:match("^(.-)%.?[^%.]+$")
    local parent = statusResolve(parentPath)
    if parent then
        if not saved.isFolder then saved.clone.Source = saved.src end
        saved.clone.Parent = parent
    end
    statusBackup[path] = nil
end
local statusLoopThread = nil
local function statusTick()
    if statusLoopThread then return end
    statusLoopThread = task.spawn(function()
        while true do
            local any = false
            for _, g in pairs(statusGroups) do
                if g.on then any = true; for _, p in ipairs(g.paths) do local m = statusResolve(p); if m then m:Destroy() end end end
            end
            if not any then break end; task.wait(0.8)
        end; statusLoopThread = nil
    end)
end
local function statusToggle(name)
    local g = statusGroups[name]; if not g then return end; g.on = not g.on
    for _, p in ipairs(g.paths) do if g.on then statusBlock(p) else statusRestore(p) end end
    local any = false; for _, sg in pairs(statusGroups) do if sg.on then any = true; break end end
    if any then statusTick() elseif statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
end
secStatus:Button({ Title = "Toggle: Slowness",       Callback = function() statusToggle("Slowness")      end })
secStatus:Button({ Title = "Toggle: Hallucination",  Callback = function() statusToggle("Hallucination") end })
secStatus:Button({ Title = "Toggle: Visual Effects", Callback = function() statusToggle("Visual")        end })
lp.CharacterAdded:Connect(function()
    statusBackup = {}; for _, g in pairs(statusGroups) do g.on = false end
    if statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
end)

------------------------------------------------------------------------
-- remote helper (used by aimbot + combat)
------------------------------------------------------------------------
local _hbRemote = nil
local function hbGetRemote()
    if _hbRemote and _hbRemote.Parent then return _hbRemote end
    local ok, re = pcall(function()
        return svc.RS.Modules.Network.Network:FindFirstChild("RemoteEvent")
    end)
    if ok and re then _hbRemote = re; return re end
    return nil
end

------------------------------------------------------------------------
-- Speed Hack
------------------------------------------------------------------------
local secSpeed = tabGlobal:Section({ Title = "Speed Hack", Opened = true })
local speedHack = { on=false, speed=30, thread=nil, lastApplied=0 }
local function speedModule()
    local ok, m = pcall(function() return require(svc.RS.Systems.Character.Game.Sprinting) end)
    return ok and m or nil
end
local function speedApply()
    if not speedHack.on then return end
    local m = speedModule(); if not m then return end
    if not m.DefaultsSet then pcall(function() m.Init() end) end
    if speedHack.speed ~= speedHack.lastApplied then
        m.SprintSpeed = speedHack.speed; pcall(function() m.MaxSprintSpeed = speedHack.speed end)
        speedHack.lastApplied = speedHack.speed
    end
end
local function speedStart()
    if speedHack.thread then return end
    speedHack.thread = task.spawn(function()
        while speedHack.on do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then speedApply() end
            task.wait(0.2)
        end; speedHack.thread = nil
    end)
end
local function speedStop()
    speedHack.on = false
    if speedHack.thread then task.cancel(speedHack.thread); speedHack.thread = nil end
    local m = speedModule(); if m then m.SprintSpeed = 26; pcall(function() m.MaxSprintSpeed = 26 end) end
end
lp.CharacterAdded:Connect(function()
    task.delay(1, function() speedHack.lastApplied=0; if speedHack.on then speedApply(); if not speedHack.thread then speedStart() end end end)
end)
if speedHack.on then speedStart() end
secSpeed:Toggle({ Title="Custom Sprint Speed", Type="Checkbox", Flag="speedOn", Default=speedHack.on,
    Callback=function(on) speedHack.on=on; sakiConfig:Save(); speedHack.lastApplied=0; if on then speedStart() else speedStop() end end })
secSpeed:Input({ Title="Sprint Speed Value", Flag="speedValue", CurrentValue=tostring(speedHack.speed), Placeholder="e.g. 30",
    Callback=function(t) local n=tonumber(t); if n and n>0 and n<=200 then speedHack.speed=n; sakiConfig:Save(); speedHack.lastApplied=0 end end })
secSpeed:Button({ Title="Reset to Default", Callback=function() speedStop() end })

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: GENERATOR
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabGen     = win:Tab({ Title = "Generator", Icon = "circuit-board" })
local secGenAuto = tabGen:Section({ Title = "Auto Solve", Opened = true })

local flow = { on = false, nodeDelay = 0.04, lineDelay = 0.60 }
local function flowKey(n) return n.row.."-"..n.col end
local function flowNeighbour(r1,c1,r2,c2)
    if r2==r1-1 and c2==c1 then return"up" end; if r2==r1+1 and c2==c1 then return"down" end
    if r2==r1 and c2==c1-1 then return"left" end; if r2==r1 and c2==c1+1 then return"right" end; return false
end
local function flowOrder(path, endpoints)
    if not path or #path == 0 then return path end
    local lookup = {}
    for _, n in ipairs(path) do lookup[flowKey(n)] = n end
    local start
    -- prefer starting from a known endpoint
    for _, ep in ipairs(endpoints or {}) do
        for _, n in ipairs(path) do
            if n.row == ep.row and n.col == ep.col then
                start = { row = ep.row, col = ep.col }
                break
            end
        end
        if start then break end
    end
    -- fall back to any dead-end node (only one neighbour in path)
    if not start then
        for _, n in ipairs(path) do
            local nb = 0
            for _, d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                if lookup[(n.row+d[1]).."-"..(n.col+d[2])] then nb += 1 end
            end
            if nb == 1 then start = { row = n.row, col = n.col }; break end
        end
    end
    if not start then start = { row = path[1].row, col = path[1].col } end
    local pool, ordered = {}, {}
    for _, n in ipairs(path) do pool[flowKey(n)] = { row = n.row, col = n.col } end
    local cur = start
    table.insert(ordered, { row = cur.row, col = cur.col })
    pool[flowKey(cur)] = nil
    while next(pool) do
        local moved = false
        for k, node in pairs(pool) do
            if flowNeighbour(cur.row, cur.col, node.row, node.col) then
                table.insert(ordered, { row = node.row, col = node.col })
                pool[k] = nil; cur = node; moved = true; break
            end
        end
        if not moved then break end
    end
    return ordered
end
local function flowSolve(puzzle)
    if not puzzle or not puzzle.Solution then return end
    -- shuffle solve order so it looks more natural
    local indices = {}
    for i = 1, #puzzle.Solution do indices[i] = i end
    for i = #indices, 2, -1 do
        local j = math.random(1, i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    for _, ci in ipairs(indices) do
        local solution = puzzle.Solution[ci]
        if not solution then continue end
        -- order the path starting from one of the target endpoints
        local ordered = flowOrder(solution, puzzle.targetPairs[ci])
        if not ordered or #ordered == 0 then continue end
        -- reset this color's path then write nodes one by one
        puzzle.paths[ci] = {}
        for _, node in ipairs(ordered) do
            table.insert(puzzle.paths[ci], { row = node.row, col = node.col })
            -- updateGui rebuilds connections internally via getGrid() — no manual gridConnections needed
            puzzle:updateGui()
            task.wait(flow.nodeDelay)
        end
        task.wait(flow.lineDelay)
        puzzle:checkForWin()
    end
end

-- FIX: FlowGameManager is a Folder — FlowGame is the ModuleScript inside it
-- The module returns the u61 class table; hook u61.new to intercept new puzzle instances
do
    local modFolder  = svc.RS:FindFirstChild("Modules")
    local miniFolder = modFolder and modFolder:FindFirstChild("Minigames")
    local fgFolder   = miniFolder and miniFolder:FindFirstChild("FlowGameManager")
    local fgModule   = fgFolder and fgFolder:FindFirstChild("FlowGame")
    if fgModule then
        local ok, FG = pcall(require, fgModule)
        if ok and FG and FG.new then
            local orig = FG.new
            FG.new = function(...)
                local p = orig(...)
                if flow.on then
                    task.spawn(function()
                        task.wait(0.3) -- let Init() finish and GUI tween begin
                        flowSolve(p)
                    end)
                end
                return p
            end
        else
            warn("[sakiware] FlowGame: failed to require FlowGame module — auto-solve disabled")
        end
    else
        warn("[sakiware] FlowGame: Modules.Minigames.FlowGameManager.FlowGame not found — auto-solve disabled")
    end
end

secGenAuto:Toggle({ Title = "Auto Solve", Type = "Checkbox", Flag = "flowOn", Default = flow.on, Callback = function(on) flow.on = on; sakiConfig:Save() end })
secGenAuto:Slider({ Title = "Node Speed", Flag = "flowNodeDelay", Step = 0.02, Value = { Min = 0.01, Max = 0.50, Default = flow.nodeDelay }, Callback = function(v) flow.nodeDelay = v; sakiConfig:Save() end })
secGenAuto:Slider({ Title = "Line Pause", Flag = "flowLineDelay", Step = 0.10, Value = { Min = 0.00, Max = 1.00, Default = flow.lineDelay }, Callback = function(v) flow.lineDelay = v; sakiConfig:Save() end })

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: KILLER
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabKiller = win:Tab({ Title = "Killer", Icon = "crosshair" })
local secAimbot = tabKiller:Section({ Title = "Aimbot", Opened = true })

local aim = {
    on=false, cooldown=0.3, lockTime=0.4,
    maxDist=30, smooth=0.35,
    targeting=false, target=nil, deathConn=nil, autoRotate=nil, lastFired=0,
    hum=nil, hrp=nil, cache={},
}
local function aimAmIKiller() local ch=lp.Character; if not ch then return false end; local kf=getTeamFolder("Killers"); return kf and ch:IsDescendantOf(kf) end
local function aimRefreshChar(ch) aim.hum=ch:FindFirstChildOfClass("Humanoid"); aim.hrp=ch:FindFirstChild("HumanoidRootPart") end
local function aimRefreshTargets()
    aim.cache = {}
    local sf=getTeamFolder("Survivors"); if not sf then return end
    for _,model in ipairs(sf:GetChildren()) do
        if model~=lp.Character and model:IsA("Model") then
            local h=model:FindFirstChildOfClass("Humanoid")
            local r=model:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health>0 and r:IsDescendantOf(workspace) then
                table.insert(aim.cache, { model=model, humanoid=h, root=r })
            end
        end
    end
end
local function aimNearest()
    aimRefreshTargets(); if not aim.hrp or #aim.cache==0 then return nil end
    local best,bd=nil,math.huge
    for _,t in ipairs(aim.cache) do
        if t.humanoid.Health>0 and t.root and t.root.Parent then
            -- predict position using velocity so fast survivors don't escape
            local vel = t.root.AssemblyLinearVelocity or Vector3.zero
            local predictedPos = t.root.Position + vel * 0.1
            local d=(predictedPos-aim.hrp.Position).Magnitude
            if d<bd and d<=aim.maxDist then bd=d; best=t end
        end
    end
    return best
end
local function aimUnlock()
    if not aim.targeting then return end
    if aim.deathConn then aim.deathConn:Disconnect(); aim.deathConn=nil end
    if aim.autoRotate~=nil and aim.hum then aim.hum.AutoRotate=aim.autoRotate end
    aim.targeting=false; aim.target=nil
end
local function aimLock(t)
    if not t or not t.root or not t.humanoid then return end
    if t.humanoid.Health<=0 then return end
    if not aim.hum or not aim.hrp then return end
    if aim.targeting and aim.target==t then return end
    aimUnlock(); aim.target=t; aim.targeting=true; aim.autoRotate=aim.hum.AutoRotate; aim.hum.AutoRotate=false
    aim.deathConn=t.humanoid.Died:Connect(aimUnlock)
    task.delay(aim.lockTime, function() if aim.target==t then aimUnlock() end end)
end
svc.Run.RenderStepped:Connect(function()
    if not aim.on or not aim.targeting or not aim.hrp or not aim.target then return end
    local t=aim.target
    if not t.root or not t.root.Parent then aimUnlock(); return end
    if not t.humanoid or t.humanoid.Health<=0 then aimUnlock(); return end
    -- use velocity prediction to rotate toward where target is heading
    local vel = t.root.AssemblyLinearVelocity or Vector3.zero
    local predictedPos = t.root.Position + vel * 0.1
    local flat=Vector3.new(predictedPos.X-aim.hrp.Position.X,0,predictedPos.Z-aim.hrp.Position.Z).Unit
    if flat.Magnitude>0 then aim.hrp.CFrame=aim.hrp.CFrame:Lerp(CFrame.new(aim.hrp.Position,aim.hrp.Position+flat),aim.smooth) end
end)

-- FIX: use getNetwork()/hbGetRemote() instead of WaitForChild on Network as a folder
task.spawn(function()
    local remote = hbGetRemote()
    if not remote then
        warn("[sakiware] Aimbot: could not find RemoteEvent — aimbot trigger disabled")
        return
    end
    remote.OnClientEvent:Connect(function(...)
        if not aim.on then return end
        local a={...}; if typeof(a[1])~="string" then return end; local n=a[1]
        if not (n:match("Ability") or n:match("[QER]") or n=="Slash" or n=="Dagger" or n=="Charge") then return end
        if tick()-aim.lastFired<aim.cooldown then return end; aim.lastFired=tick()
        if aimAmIKiller() then local t=aimNearest(); if t then aimLock(t) end end
    end)
end)

lp.CharacterAdded:Connect(function(ch) task.wait(0.5); aimRefreshChar(ch) end)
if lp.Character then aimRefreshChar(lp.Character) end

secAimbot:Toggle({ Title="Enable Aimbot",      Type="Checkbox", Flag="aimOn",       Default=aim.on,       Callback=function(on) aim.on=on;       sakiConfig:Save(); if not on then aimUnlock() end end })
secAimbot:Slider({ Title="Cooldown (s)",        Flag="aimCooldown", Step=0.05, Value={Min=0.1, Max=2.0, Default=aim.cooldown}, Callback=function(v) aim.cooldown=v; sakiConfig:Save() end })
secAimbot:Slider({ Title="Lock Time (s)",       Flag="aimLockTime", Step=0.1,  Value={Min=0.1, Max=3.0, Default=aim.lockTime}, Callback=function(v) aim.lockTime=v; sakiConfig:Save()  end })
secAimbot:Slider({ Title="Max Distance",        Flag="aimMaxDist",  Step=5,    Value={Min=5,   Max=100, Default=aim.maxDist},  Callback=function(v) aim.maxDist=v;  sakiConfig:Save()   end })
secAimbot:Slider({ Title="Rotation Smoothing",  Flag="aimSmooth",   Step=0.05, Value={Min=0.05,Max=1.0, Default=aim.smooth},  Callback=function(v) aim.smooth=v;   sakiConfig:Save()    end })

local secABS = tabKiller:Section({ Title = "Anti-Backstab", Opened = true })
local abs = { on=false, range=40, duration=1.5, locked=false, soundConn=nil, scanThread=nil, rings={} }
local absTriggerSounds = { ["86710781315432"]=true, ["99820161736138"]=true }
local absScreenGui = nil
local function absGui()
    if absScreenGui and absScreenGui.Parent then return absScreenGui end
    local pg=lp:FindFirstChild("PlayerGui"); if not pg then return nil end
    absScreenGui=Instance.new("ScreenGui"); absScreenGui.Name="AbsGui"; absScreenGui.ResetOnSpawn=false; absScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; absScreenGui.Parent=pg; return absScreenGui
end
local function absShowLabel(show)
    local g=absGui(); if not g then return end; local lbl=g:FindFirstChild("AbsTaunt")
    if not lbl then lbl=Instance.new("TextLabel"); lbl.Name="AbsTaunt"; lbl.Size=UDim2.new(0,500,0,50); lbl.Position=UDim2.new(0.5,-250,0.38,0); lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.new(1,1,1); lbl.TextStrokeTransparency=0.4; lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.Text="At least they tried 😂"; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=36; lbl.TextTransparency=1; lbl.Parent=g end
    pcall(function() svc.TweenService:Create(lbl,TweenInfo.new(show and 0.15 or 0.5),{TextTransparency=show and 0 or 1}):Play() end)
end
local function absAddRing(model)
    local hrp=model:FindFirstChild("HumanoidRootPart"); if not hrp or abs.rings[model] then return end
    pcall(function()
        local ring=Instance.new("Part"); ring.Name="AbsRing"; ring.Shape=Enum.PartType.Cylinder; ring.Size=Vector3.new(0.1,abs.range*2,abs.range*2); ring.Color=Color3.fromRGB(220,50,50); ring.Material=Enum.Material.ForceField; ring.Transparency=0.5; ring.CanCollide=false; ring.CanTouch=false; ring.CFrame=hrp.CFrame*CFrame.Angles(0,0,math.rad(90)); ring.Parent=hrp
        local w=Instance.new("WeldConstraint"); w.Part0=hrp; w.Part1=ring; w.Parent=ring; abs.rings[model]=ring
    end)
end
local function absRemoveRing(model) local r=abs.rings[model]; if r then pcall(function()r:Destroy()end); abs.rings[model]=nil end end
local function absResizeRings() for _,r in pairs(abs.rings) do if r and r.Parent then r.Size=Vector3.new(0.1,abs.range*2,abs.range*2) end end end
local function absCleanRings() for m in pairs(abs.rings) do absRemoveRing(m) end end
local function absFindTwoTime() local players=svc.WS:FindFirstChild("Players"); if not players then return nil end; for _,folder in ipairs(players:GetChildren()) do local tt=folder:FindFirstChild("TwoTime"); if tt then return tt end end; return nil end
local function absTrigger()
    if abs.locked then return end; local ch=lp.Character; local myRoot=ch and ch:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
    local ttModel=absFindTwoTime(); if not ttModel then return end; local ttRoot=ttModel:FindFirstChild("HumanoidRootPart"); if not ttRoot then return end
    if (myRoot.Position-ttRoot.Position).Magnitude>abs.range then return end
    abs.locked=true; absShowLabel(true)
    task.spawn(function()
        local deadline=tick()+abs.duration
        while tick()<deadline do if not abs.on then break end; local ch2=lp.Character; local r2=ch2 and ch2:FindFirstChild("HumanoidRootPart"); if not r2 or not ttRoot.Parent then break end; r2.CFrame=CFrame.lookAt(r2.Position,Vector3.new(ttRoot.Position.X,r2.Position.Y,ttRoot.Position.Z)); svc.Run.RenderStepped:Wait() end
        abs.locked=false; absShowLabel(false)
    end)
end
local function absHookSounds()
    if abs.soundConn then abs.soundConn:Disconnect(); abs.soundConn=nil end
    abs.soundConn=svc.WS.DescendantAdded:Connect(function(obj)
        if not abs.on or not obj:IsA("Sound") then return end; local id=obj.SoundId:match("%d+"); if id and absTriggerSounds[id] then absTrigger() end
    end)
end
local function absStartScan()
    if abs.scanThread then return end
    abs.scanThread=task.spawn(function()
        while abs.on do
            local players=svc.WS:FindFirstChild("Players")
            if players then for _,folder in ipairs(players:GetChildren()) do for _,model in ipairs(folder:GetChildren()) do if model.Name=="TwoTime" then absAddRing(model) end end end end
            for m in pairs(abs.rings) do if not m.Parent then absRemoveRing(m) end end; task.wait(1)
        end; abs.scanThread=nil
    end)
end
local function absStart() absHookSounds(); absStartScan() end
local function absStop() abs.on=false; if abs.soundConn then abs.soundConn:Disconnect(); abs.soundConn=nil end; if abs.scanThread then task.cancel(abs.scanThread); abs.scanThread=nil end; absCleanRings(); abs.locked=false; absShowLabel(false) end
lp.CharacterAdded:Connect(function() abs.locked=false; if abs.on then absStart() end end)
secABS:Toggle({ Title="Enable Anti-Backstab", Type="Checkbox", Flag="absOn", Default=abs.on, Callback=function(on) abs.on=on; sakiConfig:Save(); if on then absStart() else absStop() end end })
secABS:Slider({ Title="Detection Range",   Flag="absRange", Step=5,  Value={Min=10,Max=120,Default=abs.range},    Callback=function(v) abs.range=v;    sakiConfig:Save(); absResizeRings() end })
secABS:Slider({ Title="Look Duration (s)", Flag="absDur",   Step=0.1,Value={Min=0.3,Max=5.0,Default=abs.duration}, Callback=function(v) abs.duration=v; sakiConfig:Save()                   end })

------------------------------------------------------------------------
-- KILLER ABILITY CONTROLS
------------------------------------------------------------------------

-- c00lkidd Dash Turn (WSO)
local coolkidWSOOn = false
local function coolkidGetInputDir()
    local cf       = svc.WS.CurrentCamera.CFrame
    local camFwd   = Vector3.new(cf.LookVector.X,  0, cf.LookVector.Z)
    local camRight = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
    local x, z = 0, 0
    if svc.Input:IsKeyDown(Enum.KeyCode.W) or svc.Input:IsKeyDown(Enum.KeyCode.Up)    then z = z - 1 end
    if svc.Input:IsKeyDown(Enum.KeyCode.S) or svc.Input:IsKeyDown(Enum.KeyCode.Down)  then z = z + 1 end
    if svc.Input:IsKeyDown(Enum.KeyCode.A) or svc.Input:IsKeyDown(Enum.KeyCode.Left)  then x = x - 1 end
    if svc.Input:IsKeyDown(Enum.KeyCode.D) or svc.Input:IsKeyDown(Enum.KeyCode.Right) then x = x + 1 end
    local dir = camFwd * -z + camRight * x
    if dir.Magnitude > 0.01 then return dir.Unit end
    if camFwd.Magnitude > 0.01 then return camFwd.Unit end
    return Vector3.new(0, 0, -1)
end
svc.Run.RenderStepped:Connect(function(dt)
    if not coolkidWSOOn then return end
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end
    if char:GetAttribute("FootstepsMuted") ~= true then return end
    local dir = coolkidGetInputDir()
    local lv  = hrp:FindFirstChildWhichIsA("LinearVelocity")
    if lv then lv.LineDirection = dir end
    if dir.Magnitude > 0.01 then
        local targetRot = CFrame.new(hrp.Position, hrp.Position + dir).Rotation
        hrp.CFrame = CFrame.new(hrp.Position) * hrp.CFrame.Rotation:Lerp(targetRot, math.min(dt * 16, 1))
    end
end)

-- Noli Void Rush
local noliVoidRushOn     = false
local noliOverrideActive = false
local noliOrigWalkSpeed  = nil
local noliConn           = nil
local function noliStop()
    if not noliOverrideActive then return end
    noliOverrideActive = false
    local char = lp.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed=noliOrigWalkSpeed or 16; hum.AutoRotate=true; pcall(function() hum:Move(Vector3.new(0,0,0)) end) end
    noliOrigWalkSpeed = nil
    if noliConn then noliConn:Disconnect(); noliConn = nil end
end
local function noliStart()
    if noliOverrideActive then return end
    noliOverrideActive = true
    noliConn = svc.Run.RenderStepped:Connect(function()
        local char = lp.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if not noliOrigWalkSpeed then noliOrigWalkSpeed = hum.WalkSpeed end
        hum.WalkSpeed=60; hum.AutoRotate=false
        local horiz = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
        if horiz.Magnitude > 0 then hum:Move(horiz.Unit) end
    end)
end
svc.Run.RenderStepped:Connect(function()
    if not noliVoidRushOn then if noliOverrideActive then noliStop() end; return end
    local char = lp.Character; if not char then return end
    if char:GetAttribute("VoidRushState") == "Dashing" then noliStart() else noliStop() end
end)
lp.CharacterAdded:Connect(function() noliStop(); noliOrigWalkSpeed = nil end)

-- Killer Ability UI
local secKillerAbilities = tabKiller:Section({ Title = "Killer Abilities", Opened = true })
secKillerAbilities:Toggle({ Title="c00lkidd — Dash Turn",     Type="Checkbox", Flag="coolkidWSOOn",  Default=coolkidWSOOn,  Callback=function(on) coolkidWSOOn=on;  sakiConfig:Save()  end })
secKillerAbilities:Toggle({ Title="Noli — Void Rush Control", Type="Checkbox", Flag="noliVoidRushOn",Default=noliVoidRushOn,Callback=function(on) noliVoidRushOn=on; sakiConfig:Save(); if not on then noliStop() end end })

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: VISUAL (ESP)
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabVisual = win:Tab({ Title = "Visual", Icon = "eye" })
local secESP    = tabVisual:Section({ Title = "ESP", Opened = true })

local esp = {
    killers    = false,
    survivors  = false,
    generators = false,
    items      = false,
    buildings  = false,
    killerFolder=nil, survivorFolder=nil, mapFolder=nil,
    playerConns={}, mapConns={}, healthConns={}, progConns={}, guardConns={}, ready=false,
}

local function espItemColor(name)
    local n = name:lower()
    if n:find("medkit")    then return Color3.fromRGB(0, 255, 255) end  -- Cyan
    if n:find("bloxycola") then return Color3.fromRGB(0, 255, 255) end  -- Cyan
    return Color3.fromRGB(0, 255, 255)
end

local function espItemHeld(obj)
    for _, plr in ipairs(svc.Players:GetPlayers()) do
        local ch = plr.Character
        if ch and obj:IsDescendantOf(ch) then return true end
        local bp = plr:FindFirstChildOfClass("Backpack")
        if bp and obj:IsDescendantOf(bp) then return true end
    end
    return false
end

local espAttach
local espDetach

espAttach = function(obj, tag, color, isChar)
    if not obj or not obj.Parent then return end
    if obj:FindFirstChild(tag) and obj:FindFirstChild(tag.."_bb") then return end
    if esp.guardConns[obj]  then pcall(function() esp.guardConns[obj]:Disconnect()  end); esp.guardConns[obj]  = nil end
    if esp.healthConns[obj] then pcall(function() esp.healthConns[obj]:Disconnect() end); esp.healthConns[obj] = nil end
    if esp.progConns[obj]   then pcall(function() esp.progConns[obj]:Disconnect()   end); esp.progConns[obj]   = nil end
    pcall(function()
        local h = obj:FindFirstChild(tag);        if h then h:Destroy() end
        local b = obj:FindFirstChild(tag.."_bb"); if b then b:Destroy() end
    end)
    local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("Base") or obj:FindFirstChild("Main")
    if not root then for _,d in ipairs(obj:GetDescendants()) do if d:IsA("BasePart") then root=d; break end end end
    if not root and obj:IsA("BasePart") then root = obj end
    if not root then return end
    pcall(function()
        local hl = Instance.new("Highlight"); hl.Name=tag; hl.FillColor=color; hl.FillTransparency=0.8; hl.OutlineColor=color; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=obj; hl.Parent=obj
        local bb = Instance.new("BillboardGui"); bb.Name=tag.."_bb"; bb.Adornee=root; bb.Size=UDim2.new(0,100,0,20); bb.StudsOffset=Vector3.new(0,isChar and 3.5 or 3.8,0); bb.AlwaysOnTop=true; bb.MaxDistance=1000; bb.Parent=obj
        local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.TextColor3=color; lbl.TextStrokeTransparency=0.5; lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.TextSize=15; lbl.FontFace=Font.new("rbxasset://fonts/families/AccanthisADFStd.json"); lbl.Parent=bb
        if isChar then
            local hum=obj:FindFirstChildOfClass("Humanoid")
            if hum then
                lbl.Text=obj.Name.." (100%)"
                local c=hum.HealthChanged:Connect(function() if lbl.Parent then lbl.Text=obj.Name.." ("..math.floor(hum.Health/hum.MaxHealth*100).."%)"; end end)
                esp.healthConns[obj]=c
            else lbl.Text=obj.Name end
        else
            local prog=obj:FindFirstChild("Progress")
            if prog and prog:IsA("NumberValue") then
                lbl.Text=math.floor(prog.Value).."%"
                local c=prog.Changed:Connect(function() if lbl.Parent then lbl.Text=math.floor(prog.Value).."%" end end)
                esp.progConns[obj]=c
            else lbl.Text=obj.Name end
        end
    end)
    if esp.guardConns[obj] then pcall(function() esp.guardConns[obj]:Disconnect() end) end
    esp.guardConns[obj] = obj.ChildRemoved:Connect(function(removed)
        if removed.Name~=tag and removed.Name~=(tag.."_bb") then return end
        task.defer(function()
            if not obj or not obj.Parent then return end
            if not isChar and espItemHeld(obj) then return end
            espAttach(obj,tag,color,isChar)
        end)
    end)
end

espDetach = function(obj, tag)
    if not obj then return end
    if esp.guardConns[obj] then pcall(function() esp.guardConns[obj]:Disconnect() end); esp.guardConns[obj]=nil end
    pcall(function()
        for _,name in ipairs({tag, tag.."_bb"}) do local c=obj:FindFirstChild(name); if c then c:Destroy() end end
        if esp.healthConns[obj] then esp.healthConns[obj]:Disconnect(); esp.healthConns[obj]=nil end
        if esp.progConns[obj]   then esp.progConns[obj]:Disconnect();   esp.progConns[obj]=nil   end
    end)
end

local function espDoKillers(on)
    if not esp.killerFolder then return end
    for _,k in ipairs(esp.killerFolder:GetChildren()) do if k:IsA("Model") then if on then espAttach(k,"esp_k",Color3.fromRGB(255,80,80),true) else espDetach(k,"esp_k") end end end
end
local function espDoSurvivors(on)
    if not esp.survivorFolder then return end
    for _,s in ipairs(esp.survivorFolder:GetChildren()) do if s:IsA("Model") then if on then espAttach(s,"esp_s",Color3.fromRGB(50,255,50),true) else espDetach(s,"esp_s") end end end
end
local function espDoGenerators(on)
    local map=getMapContent(); if not map then return end
    for _,obj in ipairs(map:GetChildren()) do if obj.Name=="Generator" then if on then espAttach(obj,"esp_g",Color3.fromRGB(255,105,180),false) else espDetach(obj,"esp_g") end end end
end
local function espDoItems(on)
    for _,obj in ipairs(svc.WS:GetDescendants()) do
        if obj.Name=="BloxyCola" or obj.Name=="Medkit" then
            if not espItemHeld(obj) then
                if on then espAttach(obj,"esp_i",espItemColor(obj.Name),false) else espDetach(obj,"esp_i") end
            end
        end
    end
end
local function espDoBuildings(on)
    local ig=getIngame(); if not ig then return end
    for _,obj in ipairs(ig:GetChildren()) do if obj.Name=="BuildermanSentry" or obj.Name=="SubspaceTripmine" or obj.Name=="BuildermanDispenser" then if on then espAttach(obj,"esp_b",Color3.fromRGB(255,80,0),false) else espDetach(obj,"esp_b") end end end
end

local function espBindPlayers()
    for _,c in pairs(esp.playerConns) do if c.Connected then c:Disconnect() end end; esp.playerConns={}
    if esp.killerFolder then
        table.insert(esp.playerConns, esp.killerFolder.ChildAdded:Connect(function(ch) task.wait(0.2); if esp.killers and ch and ch.Parent and ch:IsA("Model") then espAttach(ch,"esp_k",Color3.fromRGB(255,80,80),true) end end))
        table.insert(esp.playerConns, esp.killerFolder.ChildRemoved:Connect(function(ch) espDetach(ch,"esp_k") end))
    end
    if esp.survivorFolder then
        table.insert(esp.playerConns, esp.survivorFolder.ChildAdded:Connect(function(ch) task.wait(0.2); if esp.survivors and ch and ch.Parent and ch:IsA("Model") then espAttach(ch,"esp_s",Color3.fromRGB(50,255,50),true) end end))
        table.insert(esp.playerConns, esp.survivorFolder.ChildRemoved:Connect(function(ch) espDetach(ch,"esp_s") end))
    end
end
local function espBindWorld()
    for _,c in pairs(esp.mapConns) do if c.Connected then c:Disconnect() end end; esp.mapConns={}
    local ig=getIngame(); if not ig then return end
    table.insert(esp.mapConns, ig.ChildAdded:Connect(function(obj)
        task.wait(0.2)
        if esp.buildings and (obj.Name=="BuildermanSentry" or obj.Name=="SubspaceTripmine" or obj.Name=="BuildermanDispenser") then espAttach(obj,"esp_b",Color3.fromRGB(255,80,0),false) end
        if obj.Name=="Map" then
            task.wait(1); esp.mapFolder=obj
            obj.ChildAdded:Connect(function(child) task.wait(0.2); if esp.generators and child.Name=="Generator" then espAttach(child,"esp_g",Color3.fromRGB(255,105,180),false) end end)
            obj.ChildRemoved:Connect(function(child) if child.Name=="Generator" then espDetach(child,"esp_g") end end)
            if esp.generators then task.spawn(function() espDoGenerators(true) end) end
            if esp.items      then task.spawn(function() espDoItems(true) end)      end
        end
    end))
    table.insert(esp.mapConns, ig.ChildRemoved:Connect(function(obj)
        if obj.Name=="BuildermanSentry" or obj.Name=="SubspaceTripmine" then espDetach(obj,"esp_b") end
        if obj.Name=="Map" then esp.mapFolder=nil end
    end))
    table.insert(esp.mapConns, svc.WS.DescendantAdded:Connect(function(obj)
        if not esp.items then return end
        if obj.Name ~= "BloxyCola" and obj.Name ~= "Medkit" then return end
        task.wait(0.2); if obj and obj.Parent and not espItemHeld(obj) then espAttach(obj,"esp_i",espItemColor(obj.Name),false) end
    end))
    local existing=getMapContent(); if existing then esp.mapFolder=existing; task.spawn(function() task.wait(2); if esp.generators then espDoGenerators(true) end; if esp.items then espDoItems(true) end end) end
end

secESP:Toggle({ Title="Killers",    Type="Checkbox", Flag="espKillers",    Default=esp.killers,    Callback=function(on) esp.killers=on;    sakiConfig:Save(); task.spawn(function() espDoKillers(on)    end) end })
secESP:Toggle({ Title="Survivors",  Type="Checkbox", Flag="espSurvivors",  Default=esp.survivors,  Callback=function(on) esp.survivors=on;  sakiConfig:Save(); task.spawn(function() espDoSurvivors(on)  end) end })
secESP:Toggle({ Title="Generators", Type="Checkbox", Flag="espGenerators", Default=esp.generators, Callback=function(on) esp.generators=on; sakiConfig:Save(); task.spawn(function() espDoGenerators(on) end) end })
secESP:Toggle({ Title="Items",      Type="Checkbox", Flag="espItems",      Default=esp.items,      Callback=function(on) esp.items=on;      sakiConfig:Save(); task.spawn(function() espDoItems(on)      end) end })
secESP:Toggle({ Title="Buildings",  Type="Checkbox", Flag="espBuildings",  Default=esp.buildings,  Callback=function(on) esp.buildings=on;  sakiConfig:Save(); task.spawn(function() espDoBuildings(on)  end) end })

------------------------------------------------------------------------
-- Minion + Puddle ESP
------------------------------------------------------------------------
local secMinion = tabVisual:Section({ Title = "Minion & Ability ESP", Opened = true })
local mset = { pizza=false, zombie=false, puddle=false, transparency=0.25 }
local tracked = { pizza={}, zombie={}, puddle={} }

local function isRealPlayer(obj)
    for _, plr in ipairs(svc.Players:GetPlayers()) do
        if plr.Character == obj then return true end
        if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
    end
    return false
end
local function addHighlight(obj, color, tag, label, offset)
    if not obj or tracked[tag][obj] then return end
    if isRealPlayer(obj) then return end
    tracked[tag][obj] = true
    local root = obj
    if obj:IsA("Model") then
        root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
        if not root then for _, child in ipairs(obj:GetChildren()) do if child:IsA("BasePart") then root=child; break end end end
    end
    local hl = Instance.new("Highlight")
    hl.Name=tag.."_HL"; hl.FillColor=color; hl.FillTransparency=mset.transparency; hl.OutlineColor=color; hl.OutlineTransparency=0.1; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=obj; hl.Parent=obj
    if root then
        local bb = Instance.new("BillboardGui"); bb.Name=tag.."_BB"; bb.Adornee=root; bb.Size=UDim2.new(0,130,0,24); bb.StudsOffset=Vector3.new(0,offset or 3,0); bb.AlwaysOnTop=true; bb.Parent=obj
        local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=color; lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.TextStrokeTransparency=0.2; lbl.TextSize=12; lbl.Font=Enum.Font.GothamBold; lbl.Parent=bb
    end
    local conn; conn = obj.AncestryChanged:Connect(function()
        if obj.Parent then return end; conn:Disconnect(); hl:Destroy()
        local bb=obj:FindFirstChild(tag.."_BB"); if bb then bb:Destroy() end
        tracked[tag][obj] = nil
    end)
end
local function updateTransparency()
    for tag, tbl in pairs(tracked) do for obj in pairs(tbl) do local hl=obj:FindFirstChild(tag.."_HL"); if hl then hl.FillTransparency=mset.transparency end end end
end
local function clearTag(tag)
    for obj in pairs(tracked[tag]) do
        local hl=obj:FindFirstChild(tag.."_HL"); if hl then hl:Destroy() end
        local bb=obj:FindFirstChild(tag.."_BB"); if bb then bb:Destroy() end
        if tag=="puddle" then local h=obj:FindFirstChild("PuddleHolder"); if h then h:Destroy() end end
    end
    tracked[tag]={}
end
local function addPuddleHighlight(part, color, tag, label)
    if not part or tracked[tag][part] then return end
    if isRealPlayer(part) then return end
    tracked[tag][part] = true
    local hl = Instance.new("Highlight")
    hl.Name=tag.."_HL"; hl.FillColor=color; hl.FillTransparency=mset.transparency; hl.OutlineColor=color; hl.OutlineTransparency=0.1; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Adornee=part; hl.Parent=part
    task.wait(0.05)
    local puddleSize=math.max(part.Size.X,part.Size.Z); local radius=math.max(puddleSize*0.5,3)
    local holder=Instance.new("Part"); holder.Name="PuddleHolder"; holder.Size=Vector3.new(1,0.1,1); holder.Transparency=1; holder.CanCollide=false; holder.Anchored=true; holder.Position=part.Position+Vector3.new(0,0.05,0); holder.Parent=part
    local blackCircle=Instance.new("CylinderHandleAdornment"); blackCircle.Name="PuddleBlack"; blackCircle.Adornee=holder; blackCircle.Color3=Color3.fromRGB(0,0,0); blackCircle.Transparency=0.2; blackCircle.Radius=radius; blackCircle.Height=0.02; blackCircle.CFrame=CFrame.Angles(math.rad(90),0,0); blackCircle.ZIndex=5; blackCircle.AlwaysOnTop=true; blackCircle.Parent=holder
    local redOutline=Instance.new("CylinderHandleAdornment"); redOutline.Name="PuddleRed"; redOutline.Adornee=holder; redOutline.Color3=Color3.fromRGB(255,0,0); redOutline.Transparency=0.4; redOutline.Radius=radius+0.8; redOutline.Height=0.02; redOutline.CFrame=CFrame.Angles(math.rad(90),0,0); redOutline.ZIndex=4; redOutline.AlwaysOnTop=true; redOutline.Parent=holder
    local bb=Instance.new("BillboardGui"); bb.Name=tag.."_BB"; bb.Adornee=holder; bb.Size=UDim2.new(0,140,0,20); bb.StudsOffset=Vector3.new(0,1.5,0); bb.AlwaysOnTop=true; bb.Parent=holder
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextStrokeColor3=Color3.fromRGB(255,0,0); lbl.TextStrokeTransparency=0.1; lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.Parent=bb
    local sizeConn; sizeConn=part:GetPropertyChangedSignal("Size"):Connect(function()
        if not part.Parent then sizeConn:Disconnect(); return end
        local nr=math.max(math.max(part.Size.X,part.Size.Z)*0.5,3); blackCircle.Radius=nr; redOutline.Radius=nr+0.8
    end)
    local conn; conn=part.AncestryChanged:Connect(function()
        if part.Parent then return end; conn:Disconnect()
        pcall(function() sizeConn:Disconnect() end); pcall(function() hl:Destroy() end); pcall(function() holder:Destroy() end)
        tracked[tag][part]=nil
    end)
end
local function isJohnDoePuddle(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Name ~= "Shadow" then return false end
    local parent = obj.Parent
    return parent and parent.Name:find("Shadows$") ~= nil
end
local function scanPizza()
    if not mset.pizza then return end
    for _,obj in ipairs(svc.WS:GetDescendants()) do if obj.Name=="PizzaDeliveryRig" and obj:IsA("Model") and not isRealPlayer(obj) and not tracked.pizza[obj] then addHighlight(obj,Color3.fromRGB(255,100,0),"pizza","C00LKIDD PIZZA DELIVERY",3) end end
end
local function scanZombie()
    if not mset.zombie then return end
    for _,obj in ipairs(svc.WS:GetDescendants()) do if obj.Name=="1x1x1x1Zombie" and obj:IsA("Model") and not isRealPlayer(obj) and not tracked.zombie[obj] then addHighlight(obj,Color3.fromRGB(80,255,120),"zombie","1X1X1X1 ZOMBIE",3) end end
end
local function scanPuddles()
    if not mset.puddle then return end
    for _,obj in ipairs(svc.WS:GetDescendants()) do if isJohnDoePuddle(obj) and not tracked.puddle[obj] then addPuddleHighlight(obj,Color3.fromRGB(255,50,50),"puddle","JOHN DOE PUDDLE") end end
end
local function setupMinionWatcher()
    svc.WS.DescendantAdded:Connect(function(obj)
        task.wait(0.1); if not obj or not obj.Parent then return end
        if mset.pizza  and obj.Name=="PizzaDeliveryRig"  and obj:IsA("Model") and not isRealPlayer(obj) and not tracked.pizza[obj]  then addHighlight(obj,Color3.fromRGB(255,100,0),"pizza","C00LKIDD PIZZA DELIVERY",3) end
        if mset.zombie and obj.Name=="1x1x1x1Zombie"     and obj:IsA("Model") and not isRealPlayer(obj) and not tracked.zombie[obj] then addHighlight(obj,Color3.fromRGB(80,255,120),"zombie","1X1X1X1 ZOMBIE",3) end
        if mset.puddle and isJohnDoePuddle(obj) and not tracked.puddle[obj] then task.wait(0.15); if obj.Parent then addPuddleHighlight(obj,Color3.fromRGB(255,50,50),"puddle","JOHN DOE PUDDLE") end end
    end)
end

task.spawn(function()
    while true do
        task.wait(3)
        if esp.killers    then task.spawn(function() espDoKillers(true)    end) end
        if esp.survivors  then task.spawn(function() espDoSurvivors(true)  end) end
        if esp.generators then task.spawn(function() espDoGenerators(true) end) end
        if esp.items      then task.spawn(function() espDoItems(true)      end) end
        if esp.buildings  then task.spawn(function() espDoBuildings(true)  end) end
        scanPizza(); scanZombie(); scanPuddles()
    end
end)

task.spawn(function()
    task.wait(3)
    local pf=svc.WS:FindFirstChild("Players")
    if pf then
        esp.killerFolder=pf:FindFirstChild("Killers"); esp.survivorFolder=pf:FindFirstChild("Survivors")
        espBindPlayers()
        if esp.killers   then task.spawn(function() espDoKillers(true)   end) end
        if esp.survivors then task.spawn(function() espDoSurvivors(true) end) end
    end
    espBindWorld()
    if esp.buildings then task.spawn(function() espDoBuildings(true) end) end
    setupMinionWatcher()
    if mset.pizza  then scanPizza()   end
    if mset.zombie then scanZombie()  end
    if mset.puddle then scanPuddles() end
    esp.ready=true
end)

lp.CharacterAdded:Connect(function()
    task.wait(4); espBindPlayers(); espBindWorld()
    if esp.killers    then task.spawn(function() espDoKillers(true)    end) end
    if esp.survivors  then task.spawn(function() espDoSurvivors(true)  end) end
    if esp.generators then task.spawn(function() espDoGenerators(true) end) end
    if esp.items      then task.spawn(function() espDoItems(true)      end) end
    if esp.buildings  then task.spawn(function() espDoBuildings(true)  end) end
    if mset.pizza  then scanPizza()   end
    if mset.zombie then scanZombie()  end
    if mset.puddle then scanPuddles() end
end)

secMinion:Toggle({ Title="c00lkidd Pizza Bots",   Desc="PizzaDeliveryRig — orange highlight", Type="Checkbox", Flag="espPizza",      Default=mset.pizza,  Callback=function(on) mset.pizza=on;  sakiConfig:Save(); if on then scanPizza()   else clearTag("pizza")  end end })
secMinion:Toggle({ Title="1x1x1x1 Zombies",       Desc="1x1x1x1Zombie — green highlight",     Type="Checkbox", Flag="espZombie",     Default=mset.zombie, Callback=function(on) mset.zombie=on; sakiConfig:Save(); if on then scanZombie()  else clearTag("zombie") end end })
secMinion:Toggle({ Title="JD Digital Footprints", Desc="Black disc + red glow",               Type="Checkbox", Flag="espPuddle",     Default=mset.puddle, Callback=function(on) mset.puddle=on; sakiConfig:Save(); if on then scanPuddles() else clearTag("puddle") end end })
secMinion:Slider({ Title="Highlight Transparency", Flag="espMinionTrans", Step=0.05, Value={Min=0,Max=1,Default=mset.transparency}, Callback=function(v) mset.transparency=v; sakiConfig:Save(); updateTransparency() end })
secMinion:Button({ Title="🔄 Force Rescan", Callback=function() clearTag("pizza"); clearTag("zombie"); clearTag("puddle"); task.wait(0.1); scanPizza(); scanZombie(); scanPuddles() end })

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: MUSIC (LMS replacer)
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabMusic = win:Tab({ Title = "Music", Icon = "music" })
local secLMS   = tabMusic:Section({ Title = "LMS Music", Opened = true })

local music = { on=false, selected="CondemnedLMS", cached={}, origId=nil, thread=nil }
local musicDir = "SAKIWARE/LMS_Songs"
if not fs.hasFolder("SAKIWARE") then fs.makeFolder("SAKIWARE") end
if not fs.hasFolder(musicDir) then fs.makeFolder(musicDir) end
local musicTracks = {
    ["AbberantLMS"]              = "https://files.catbox.moe/4bb0g9.mp3",
    ["OvertimeLMS"]              = "https://files.catbox.moe/puf7xu.mp3",
    ["PhotoshopLMS"]             = "https://files.catbox.moe/yui8km.mp3",
    ["JX1DX1LMS"]                = "https://files.catbox.moe/52p5yh.mp3",
    ["CondemnedLMS"]             = "https://files.catbox.moe/l470am.mp3",
    ["GeometryLMS"]              = "https://files.catbox.moe/bqzc7u.mp3",
    ["Milestone4LMS"]            = "https://files.catbox.moe/z68ns9.mp3",
    ["BluududLMS"]               = "https://files.catbox.moe/gemz4k.mp3",
    ["JohnDoeLMS"]               = "https://files.catbox.moe/p72236.mp3",
    ["ShedVS1xLMS"]              = "https://files.catbox.moe/0q5v9p.mp3",
    ["EternalIShallEndure"]      = "https://files.catbox.moe/c3ohcm.mp3",
    ["ChanceVSMafiosoLMS"]       = "https://files.catbox.moe/0hlm8m.mp3",
    ["JohnVsJaneLMS"]            = "https://files.catbox.moe/inonzr.mp3",
    ["SceneSlasherLMS"]          = "https://files.catbox.moe/ap3x4x.mp3",
    ["SynonymsForEternity"]      = "https://files.catbox.moe/uj45ih.mp3",
    ["EternityEpicfied"]         = "https://files.catbox.moe/yrmpvx.mp3",
    ["EternalHopeEternalFight"]  = "https://files.catbox.moe/xdm5q8.mp3",
}
local musicList = {}; for k in pairs(musicTracks) do table.insert(musicList, k) end; table.sort(musicList)
local function musicFetch(name)
    if music.cached[name] then return music.cached[name] end
    local url=musicTracks[name]; if not url then return nil end
    local path=musicDir.."/"..name:gsub("[^%w]","_")..".mp3"
    if not fs.hasFile(path) then local ok,data=pcall(function() return game:HttpGet(url) end); if not ok or not data or #data==0 then return nil end; fs.write(path,data) end
    music.cached[name]=fs.asset(path); return music.cached[name]
end
-- FIX: LastSurvivor sound only exists during a round, not in lobby.
-- Poll for it so musicGetSound() always returns the live instance if present.
local function musicGetSound()
    local t = svc.WS:FindFirstChild("Themes")
    if not t then return nil end
    -- Try direct child first, then deep search in case it's nested
    return t:FindFirstChild("LastSurvivor") or t:FindFirstChild("LastSurvivor", true)
end
local function musicPlay(name)
    local snd=musicGetSound(); if not snd then return false end
    if not music.origId then music.origId=snd.SoundId end
    local asset=musicFetch(name); if not asset then return false end
    snd.SoundId=asset; snd:Stop(); task.wait(); snd:Play(); return true
end
local function musicReset() local snd=musicGetSound(); if snd and music.origId then snd.SoundId=music.origId; snd:Stop(); task.wait(); snd:Play() end end
local function musicIsLMS()
    local sf=getTeamFolder("Survivors")
    if sf then local alive=0; for _,s in ipairs(sf:GetChildren()) do local h=s:FindFirstChildOfClass("Humanoid"); if h and h.Health>0 then alive+=1 end end; if alive==1 then return true end end
    local snd=musicGetSound(); return snd and snd.IsPlaying and (not music.origId or snd.SoundId~=music.origId)
end
local function musicMonitor()
    local i=0
    while music.on and i<2000 do
        i+=1
        if musicIsLMS() then
            local snd=musicGetSound()
            if not snd or not snd.IsPlaying or snd.SoundId~=(music.cached[music.selected] or "") then musicPlay(music.selected) end
            task.wait(3)
        else task.wait(1) end
    end
end
secLMS:Toggle({ Title="Auto-Play on LMS", Type="Checkbox", Flag="musicOn", Default=music.on, Callback=function(on) music.on=on; sakiConfig:Save(); if on then music.thread=task.spawn(musicMonitor) else if music.thread then task.cancel(music.thread); music.thread=nil end; musicReset() end end })
secLMS:Dropdown({ Title="Track", Flag="musicSel", Values=musicList, Value=music.selected, Callback=function(sel) music.selected=type(sel)=="table" and sel[1] or sel; sakiConfig:Save(); task.spawn(function()musicFetch(music.selected)end) end })
secLMS:Button({ Title="▶  Play",        Callback=function() musicPlay(music.selected) end })
secLMS:Button({ Title="■  Stop",        Callback=function() musicReset() end })
secLMS:Button({ Title="↓  Preload LMS", Callback=function() for name in pairs(musicTracks) do task.spawn(function()musicFetch(name)end); task.wait(0.1) end end })
lp.CharacterAdded:Connect(function() task.wait(3); if music.on then if music.thread then task.cancel(music.thread) end; music.thread=task.spawn(musicMonitor) end end)

local tabElliot  = win:Tab({ Title = "Elliot",    Icon = "pizza"     })
local tabChance  = win:Tab({ Title = "Chance",    Icon = "crosshair" })

-- Elliot Aimbot
do
    local sec_014 = tabElliot:Section({ Title = "Elliot Aimbot", Opened = true })

    local elliotEnabled     = false
    local elliotConnection  = nil
    local elliotAutoRotBak  = nil
    local elliotPredDist    = 5
    local elliotVelThresh   = 16
    local elliotAimType     = "Camera + Character"
    local elliotThrowDur    = 0.5
    local elliotIsThrowing  = false
    local elliotThrowTS     = 0
    local elliotRequireAnim = true
    local elliotShowArc     = false
    local elliotArcFolder   = nil
    local elliotArcParts    = {}
    local elliotArcSegs     = 50
    local elliotThrowForce  = 80
    local elliotUpComp      = 0.5
    local elliotGravity     = 196.2
    local elliotHum, elliotHRP = nil, nil
    local elliotCamera      = svc.WS.CurrentCamera

    local function elliotSetupChar(char)
        elliotHum = char:WaitForChild("Humanoid")
        elliotHRP = char:WaitForChild("HumanoidRootPart")
    end
    if lp.Character then elliotSetupChar(lp.Character) end
    lp.CharacterAdded:Connect(function(c) elliotSetupChar(c) end)

    task.spawn(function()
        local ok, re = pcall(function()
            return svc.RS:WaitForChild("Modules",5):WaitForChild("Network",5):WaitForChild("RemoteEvent",5)
        end)
        if ok and re then
            local oldNC
            oldNC = hookmetamethod(game,"__namecall",function(self,...)
                local method = getnamecallmethod()
                local args = {...}
                if method=="FireServer" and self==re then
                    if args[1]=="UseActorAbility" and args[2] and args[2][1] then
                        local ok2, bs = pcall(function() return buffer.tostring(args[2][1]) end)
                        if ok2 and bs and string.find(bs,"ThrowPizza") then
                            elliotIsThrowing = true
                            elliotThrowTS    = tick()
                        end
                    end
                end
                return oldNC(self,...)
            end)
        end
    end)

    local function elliotClearArc()
        for _, p in ipairs(elliotArcParts) do if p and p.Parent then p:Destroy() end end
        elliotArcParts = {}
    end
    local function elliotCreateArcFolder()
        if elliotArcFolder then elliotArcFolder:Destroy() end
        elliotArcFolder = Instance.new("Folder"); elliotArcFolder.Name="ElliotArc"; elliotArcFolder.Parent=svc.WS
    end

    local function elliotFindTarget()
        local sf = svc.WS:FindFirstChild("Players") and svc.WS.Players:FindFirstChild("Survivors")
        if not sf then sf = svc.WS:FindFirstChild("Survivors") end
        if not sf or not elliotHRP then return nil end
        local best, bestHP = nil, math.huge
        for _, s in ipairs(sf:GetChildren()) do
            if s ~= lp.Character then
                local h = s:FindFirstChildOfClass("Humanoid")
                local r = s:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 and h.Health < bestHP then
                    best = r; bestHP = h.Health
                end
            end
        end
        return best
    end

    local function elliotAimAt(tgt)
        if not tgt or not tgt.Parent then return end
        local vel = tgt.AssemblyLinearVelocity
        local pos = tgt.Position
        local predPos = pos + (tgt.CFrame.LookVector * 2)
        if vel.Magnitude > elliotVelThresh then predPos = predPos + (vel.Unit * elliotPredDist) end
        if elliotAimType == "HRP Aimbot" or elliotAimType == "Camera + Character" then
            if elliotHRP then
                if not elliotAutoRotBak then elliotAutoRotBak = elliotHum.AutoRotate end
                elliotHum.AutoRotate = false
                elliotHRP.AssemblyAngularVelocity = Vector3.new(0,0,0)
                local dir = (predPos - elliotHRP.Position)
                local flat = Vector3.new(dir.X,0,dir.Z).Unit
                local tCF = CFrame.new(elliotHRP.Position, elliotHRP.Position + flat)
                local cur = elliotHRP.CFrame
                local nCF = cur:Lerp(tCF, 0.35)
                elliotHRP.CFrame = CFrame.new(cur.Position) * (nCF - nCF.Position)
            end
        end
        if elliotAimType == "Camera Aimbot" or elliotAimType == "Camera + Character" then
            elliotCamera.CFrame = CFrame.lookAt(elliotCamera.CFrame.Position, predPos)
        end
    end

    local function elliotArcCalc(startPos, lookVec)
        local dir = (lookVec + Vector3.new(0, elliotUpComp, 0)).Unit
        local iv   = dir * elliotThrowForce
        local maxT = 3
        local pts  = {}
        local step = maxT / elliotArcSegs
        local last = startPos
        local rp   = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { lp.Character, elliotArcFolder }
        for i = 0, elliotArcSegs do
            local t   = i * step
            local pos = startPos + iv*t + Vector3.new(0,-0.5*elliotGravity*t*t,0)
            if i > 0 then
                local d = pos - last
                local dm = d.Magnitude
                if dm > 0 then
                    local res = svc.WS:Raycast(last, d.Unit*dm, rp)
                    if res then table.insert(pts, res.Position); break end
                end
            end
            if pos.Y < -100 then break end
            table.insert(pts, pos); last = pos
        end
        return pts
    end

    local _elliotLastArcUpdate = 0
    local function elliotUpdateArc()
        if not elliotShowArc or not elliotHRP then elliotClearArc(); return end
        local now = tick()
        if now - _elliotLastArcUpdate < 0.1 then return end
        _elliotLastArcUpdate = now
        local char = lp.Character
        local lArm = char and (char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand") or char:FindFirstChild("LeftLowerArm"))
        local startPos = lArm and lArm.Position or (elliotHRP.Position + Vector3.new(-1,1,0) + elliotHRP.CFrame.LookVector*2)
        local pts = elliotArcCalc(startPos, elliotHRP.CFrame.LookVector)
        elliotClearArc()
        if not elliotArcFolder then elliotCreateArcFolder() end
        for i, p in ipairs(pts) do
            local part = Instance.new("Part"); part.Name="ArcSeg"..i; part.Size=Vector3.new(0.25,0.25,0.25)
            part.Position=p; part.Anchored=true; part.CanCollide=false; part.Material=Enum.Material.Neon
            part.Shape=Enum.PartType.Ball
            if i == #pts and #pts > 1 then part.Size=Vector3.new(0.5,0.5,0.5); part.Color=Color3.fromRGB(255,255,0); part.Transparency=0
            else part.Color=Color3.fromRGB(255,0,0); part.Transparency=0.15 end
            part.Parent=elliotArcFolder; table.insert(elliotArcParts, part)
        end
    end

    sec_014:Paragraph({ Title = "How it works", Content = "Hooks the UseActorAbility FireServer call to detect when you throw a pizza. While throwing, it aims your HRP and/or camera toward the lowest-health survivor." })
    sec_014:Slider({ Title = "Prediction Studs", Value = {Min=0,Max=50,Default=5}, Step = 1, Callback=function(v) elliotPredDist=v end })
    sec_014:Slider({ Title = "Aim Duration (s)", Value = {Min=0.1,Max=2,Default=0.5}, Step = 0.1, Callback=function(v) elliotThrowDur=v end })
    sec_014:Slider({ Title = "Pizza Throw Force", Value = {Min=50,Max=150,Default=80}, Step = 5, Callback=function(v) elliotThrowForce=v end })
    sec_014:Slider({ Title = "Arc Segments", Value = {Min=20,Max=100,Default=50}, Step = 5, Callback=function(v) elliotArcSegs=v end })
    sec_014:Dropdown({ Title = "Aimbot Type", Values = {"HRP Aimbot","Camera Aimbot","Camera + Character"}, Default = "Camera + Character", Callback=function(v) elliotAimType=v end })
    sec_014:Toggle({ Title = "Show Pizza Arc", Default = false, Callback=function(v)
        elliotShowArc=v
        if v then elliotCreateArcFolder()
        else elliotClearArc(); if elliotArcFolder then elliotArcFolder:Destroy(); elliotArcFolder=nil end end
    end, Type = "Checkbox"})
    sec_014:Toggle({ Title = "Require Throw Animation", Default = true, Callback=function(v) elliotRequireAnim=v end, Type = "Checkbox"})
    sec_014:Toggle({ Title = "Enable Elliot Aimbot", Default = false, Callback=function(v)
        elliotEnabled = v
        if v then
            elliotConnection = svc.Run.RenderStepped:Connect(function()
                if not elliotEnabled or not elliotHum or not elliotHRP then return end
                if elliotIsThrowing and (tick()-elliotThrowTS)>elliotThrowDur then elliotIsThrowing=false end
                if elliotShowArc then elliotUpdateArc() end
                local shouldAim = elliotRequireAnim and elliotIsThrowing or (not elliotRequireAnim)
                if not shouldAim then
                    if elliotAutoRotBak ~= nil then elliotHum.AutoRotate=elliotAutoRotBak; elliotAutoRotBak=nil end
                    return
                end
                local tgt = elliotFindTarget()
                if not tgt then
                    if elliotAutoRotBak ~= nil then elliotHum.AutoRotate=elliotAutoRotBak; elliotAutoRotBak=nil end
                    return
                end
                elliotAimAt(tgt)
            end)
        else
            if elliotConnection then elliotConnection:Disconnect(); elliotConnection=nil end
            if elliotAutoRotBak ~= nil then elliotHum.AutoRotate=elliotAutoRotBak; elliotAutoRotBak=nil end
            elliotClearArc()
        end
    end, Type = "Checkbox"})
end



------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: CHANCE
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Chance Aimbot
do
    local sec_020 = tabChance:Section({ Title = "Chance Aimbot", Opened = true })

    local chanceAimEnabled  = false
    local chancePredMode    = "Velocity"
    local chancePredValue   = 0.5
    local chanceAimBehavior = "Normal"
    local chanceSpinDur     = 0.5
    local chanceMsgOnAim    = false
    local chanceMsgText     = ""
    local chanceCustomAnim  = false
    local chanceCustomAnimID= ""
    local chanceAntiBait    = true
    local chanceSmoothSpeed = 14
    local chanceHeightAim   = true
    local chanceHoldToAim   = true
    local chanceAimKey      = Enum.KeyCode.Q
    local chanceHoldingKey  = false
    local chanceAiming      = false
    local chanceStartTime   = 0
    local chanceAimDuration = 1.7

    local chanceKillerSpeeds = {
        Slasher={walk=9,run=28}, c00lkidd={walk=7.75,run=28}, JohnDoe={walk=9,run=27.25},
        ["1x1x1x1"]={walk=8.5,run=27}, Noli={walk=7.5,run=27.5}, Guest666={walk=9,run=27},
        Nosferatu={walk=7.25,run=27.5}, Doombringer={walk=8,run=27}, JaneDoe={walk=9,run=27},
        Builderman={walk=8.5,run=27.5}, Dusekkar={walk=8,run=27.5},
    }

    local chanceHum, chanceHRP, chanceBodyGyro, chanceSavedAutoRotate
    local function chanceSetChar(c) chanceHum=c:WaitForChild("Humanoid"); chanceHRP=c:WaitForChild("HumanoidRootPart") end
    if lp.Character then chanceSetChar(lp.Character) end
    lp.CharacterAdded:Connect(chanceSetChar)

    local chanceMotion = {}
    local function chanceGetMotion(hrp)
        local now=tick(); local pos=hrp.Position; local data=chanceMotion[hrp]
        if not data then chanceMotion[hrp]={lastPos=pos,lastTime=now,velocity=Vector3.zero,accel=Vector3.zero}; return Vector3.zero,Vector3.zero end
        local dt=now-data.lastTime; if dt<=0 then return data.velocity,data.accel end
        local vel=(pos-data.lastPos)/dt; local acc=(vel-data.velocity)/dt
        data.lastPos=pos; data.lastTime=now; data.accel=acc; data.velocity=vel
        return vel,acc
    end

    local chancePingSamples={}
    local _chanceLastPingTime=0
    local _chanceLastPingVal=0.1
    local function chanceGetPing()
        local now=tick()
        if now-_chanceLastPingTime<1 then return _chanceLastPingVal end
        _chanceLastPingTime=now
        local ok,stat=pcall(function() return svc.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        local raw=(ok and stat or 100)/1000
        table.insert(chancePingSamples,raw); if #chancePingSamples>5 then table.remove(chancePingSamples,1) end
        local s=0; for _,v in ipairs(chancePingSamples) do s=s+v end
        _chanceLastPingVal=s/#chancePingSamples
        return _chanceLastPingVal
    end

    local function chanceGetNearest()
        if not chanceHRP then return end
        local folder=getTeamFolder("Killers"); if not folder then return end
        local closest,dist=nil,math.huge
        for _,m in ipairs(folder:GetChildren()) do
            local r=m:FindFirstChild("HumanoidRootPart"); local h=m:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health>0 then local d=(r.Position-chanceHRP.Position).Magnitude; if d<dist then dist=d; closest=r end end
        end
        return closest
    end

    local function chancePredict(hrp)
        local vel,accel=chanceGetMotion(hrp); local pos=hrp.Position; local speed=vel.Magnitude
        if chanceAntiBait then
            local model=hrp.Parent
            if model and chanceKillerSpeeds[model.Name] then
                local maxSpd=chanceKillerSpeeds[model.Name].run+2
                if speed>maxSpd then vel=vel.Unit*maxSpd; speed=maxSpd end
            end
        end
        local ping=chanceGetPing(); local dist=chanceHRP and (hrp.Position-chanceHRP.Position).Magnitude or 0
        local ds=dist*0.003; local lead
        if chancePredMode=="Velocity" then lead=chancePredValue+ds
        elseif chancePredMode=="Ping" then lead=ping*chancePredValue+ds
        elseif chancePredMode=="Look" then return pos+hrp.CFrame.LookVector*(speed*chancePredValue)
        elseif chancePredMode=="LookPing" then return pos+hrp.CFrame.LookVector*(speed*ping)
        else lead=chancePredValue end
        if speed<0.5 then return pos end
        local ac=accel*lead*lead*0.5
        if ac.Magnitude>speed*0.4 then ac=ac.Unit*(speed*0.4) end
        return pos+vel*lead+ac
    end

    local function chanceHookAnimator(char)
        local hum=char:WaitForChild("Humanoid"); local anim=hum:WaitForChild("Animator")
        local chanceTriggers={["133607163653602"]=true,["133491532453922"]=true,["131189930305001"]=true,["111384272984267"]=true,["103601716322988"]=true,["76649505662612"]=true}
        anim.AnimationPlayed:Connect(function(track)
            if not chanceAimEnabled or chanceHoldToAim then return end
            local id=track.Animation.AnimationId:match("%d+")
            if id and chanceTriggers[id] then
                if chanceHum then chanceSavedAutoRotate = chanceHum.AutoRotate; chanceHum.AutoRotate = false end
                chanceAiming=true; chanceStartTime=tick()
                track.Ended:Connect(function()
                    if chanceHum and chanceSavedAutoRotate ~= nil then chanceHum.AutoRotate = chanceSavedAutoRotate end
                    if chanceBodyGyro and chanceBodyGyro.Parent then chanceBodyGyro:Destroy(); chanceBodyGyro = nil end
                    chanceAiming = false
                end)
            end
        end)
    end
    if lp.Character then chanceHookAnimator(lp.Character) end
    lp.CharacterAdded:Connect(chanceHookAnimator)

    svc.Input.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        if chanceHoldToAim and input.KeyCode==chanceAimKey then chanceHoldingKey=true; chanceAiming=true; chanceStartTime=tick() end
    end)
    svc.Input.InputEnded:Connect(function(input)
        if chanceHoldToAim and input.KeyCode==chanceAimKey then chanceHoldingKey=false; chanceAiming=false end
    end)

    svc.Run.RenderStepped:Connect(function()
        if not chanceAimEnabled or not chanceHRP then return end
        if chanceHoldToAim then if not chanceHoldingKey then return end
        else if not chanceAiming then return end; if tick()-chanceStartTime>chanceAimDuration then chanceAiming=false; return end end
        local target=chanceGetNearest(); if not target then return end
        local pos=chancePredict(target); if not pos then return end
        local aimPos=chanceHeightAim and pos or Vector3.new(pos.X,chanceHRP.Position.Y,pos.Z)
        if chanceAimBehavior=="360" then
            local prog=(tick()-chanceStartTime)/chanceSpinDur
            if prog<1 then chanceHRP.CFrame=CFrame.new(chanceHRP.Position)*CFrame.Angles(0,math.rad(360*prog),0); return end
        end
        if not chanceBodyGyro or not chanceBodyGyro.Parent then
            chanceBodyGyro = Instance.new("BodyGyro")
            chanceBodyGyro.MaxTorque = Vector3.new(0, math.huge, 0)
            chanceBodyGyro.P = 10000; chanceBodyGyro.D = 500
            chanceBodyGyro.Parent = chanceHRP
        end
        chanceBodyGyro.CFrame = CFrame.lookAt(chanceHRP.Position, aimPos)
    end)

    sec_020:Paragraph({ Title = "How it works", Content = "Aims your HRP toward the nearest killer using a BodyGyro. Velocity mode predicts where the killer will be based on their current speed." })
    sec_020:Toggle({ Title = "Enable Aimbot", Default = false, Callback=function(v) chanceAimEnabled=v end, Type = "Checkbox"})
    sec_020:Dropdown({ Title = "Prediction Mode", Values = {"Velocity","Ping","Look","LookPing"}, Default = "Velocity", Callback=function(v) chancePredMode=v end })
    sec_020:Input({ Title = "Prediction Value", Placeholder = "0.5", Callback=function(v) local n=tonumber(v); if n then chancePredValue=n end end })
    sec_020:Slider({ Title = "Smooth Speed", Value = {Min=1,Max=30,Default=14}, Step = 1, Callback=function(v) chanceSmoothSpeed=v end })
    sec_020:Toggle({ Title = "Height-Aware Aim", Default = true, Callback=function(v) chanceHeightAim=v end, Type = "Checkbox"})
    sec_020:Dropdown({ Title = "Aim Behavior", Values = {"Normal","360"}, Default = "Normal", Callback=function(v) chanceAimBehavior=v end })
    sec_020:Input({ Title = "Spin Duration", Placeholder = "0.5", Callback=function(v) local n=tonumber(v); if n then chanceSpinDur=n end end })
    sec_020:Toggle({ Title = "Anti Bait", Default = true, Callback=function(v) chanceAntiBait=v end, Type = "Checkbox"})
    sec_020:Toggle({ Title = "Hold-to-Aim", Default = true, Callback=function(v) chanceHoldToAim=v end, Type = "Checkbox"})
    sec_020:Dropdown({ Title = "Aim Key", Values = {"Q","E","R","T","F","G","X","C","V"}, Default = "Q", Callback=function(v) chanceAimKey=Enum.KeyCode[v] end })
    sec_020:Toggle({ Title = "Message When Aim", Default = false, Callback=function(v) chanceMsgOnAim=v end, Type = "Checkbox"})
    sec_020:Input({ Title = "Message Text", Placeholder = "...", Callback=function(v) chanceMsgText=v end })
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: VEERONICA
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabVeeronica = win:Tab({ Title = "Veeronica", Icon = "zap" })

local sec_022 = tabVeeronica:Section({ Title = "Auto Trick", Opened = true })

sec_022:Paragraph({ Title = "How it works", Content = "Monitors Veeronica's Behavior folder for Highlight instances that switch Adornee to your character. The moment that happens it automatically fires the SprintingButton press so the trick executes instantly." })

do
    local atEnabled = false
    local atActiveMonitors = {}
    local atDescendantAddedConn = nil

    local function atGetBehaviorFolder()
        return svc.RS:WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("Veeronica"):WaitForChild("Behavior")
    end
    local function atGetSprintingButton()
        return lp.PlayerGui:WaitForChild("MainUI"):WaitForChild("SprintingButton")
    end

    local atBehaviorFolder = nil
    task.spawn(function()
        local ok, f = pcall(atGetBehaviorFolder)
        if ok and f then atBehaviorFolder = f end
    end)

    local function atMonitorHighlight(h)
        if not h or atActiveMonitors[h] then return end
        local connections = {}
        local prevState = false
        local function cleanup()
            for _, conn in ipairs(connections) do if conn and conn.Connected then conn:Disconnect() end end
            atActiveMonitors[h] = nil
        end
        local function adorneeIsPlayer(hh)
            if not hh then return false end
            local adornee = hh.Adornee
            local char = lp.Character
            if not adornee or not char then return false end
            return adornee == char or adornee:IsDescendantOf(char)
        end
        local function onChanged()
            if not atEnabled then return end
            if not h or not h.Parent then cleanup(); return end
            local currState = adorneeIsPlayer(h)
            if prevState ~= currState then
                if currState then
                    local ok2, btn = pcall(atGetSprintingButton)
                    if ok2 and btn then
                        for _, v in pairs(getconnections(btn.MouseButton1Down)) do
                            pcall(function() v:Fire() end)
                        end
                    end
                end
            end
            prevState = currState
        end
        local c = h:GetPropertyChangedSignal("Adornee"):Connect(onChanged)
        if c then table.insert(connections, c) end
        table.insert(connections, h.AncestryChanged:Connect(function(_, parent)
            if not parent then cleanup() else onChanged() end
        end))
        atActiveMonitors[h] = cleanup
        task.spawn(onChanged)
    end

    local function atStartManager()
        if atDescendantAddedConn or not atBehaviorFolder then return end
        for _, desc in ipairs(atBehaviorFolder:GetDescendants()) do
            if desc:IsA("Highlight") then atMonitorHighlight(desc) end
        end
        atDescendantAddedConn = atBehaviorFolder.DescendantAdded:Connect(function(child)
            if child:IsA("Highlight") then atMonitorHighlight(child) end
        end)
    end
    local function atStopManager()
        if atDescendantAddedConn and atDescendantAddedConn.Connected then atDescendantAddedConn:Disconnect() end
        atDescendantAddedConn = nil
        for _, cleanup in pairs(atActiveMonitors) do if type(cleanup) == "function" then pcall(cleanup) end end
        atActiveMonitors = {}
    end

    sec_022:Toggle({
        Title = "Auto Trick", Default = false, Callback = function(on)
            atEnabled = on
            if on then
                if not atBehaviorFolder then local ok, f = pcall(atGetBehaviorFolder); if ok and f then atBehaviorFolder = f end end
                atStartManager()
            else
                atStopManager()
            end
        end, Type = "Checkbox"})
end

------------------------------------------------------------------------
-- SK8 Control
------------------------------------------------------------------------
local sec_023 = tabVeeronica:Section({ Title = "SK8 Control", Opened = true })

do
    local sk8_camera = workspace.CurrentCamera
    local sk8_shiftlockEnabled = false
    local sk8_shiftConn = nil

    local function sk8_setShiftlock(state)
        sk8_shiftlockEnabled = state
        if sk8_shiftConn then sk8_shiftConn:Disconnect(); sk8_shiftConn = nil end
        if sk8_shiftlockEnabled then
            svc.Input.MouseBehavior = Enum.MouseBehavior.LockCenter
            sk8_shiftConn = svc.Run.RenderStepped:Connect(function()
                local character = lp.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    local camCF = sk8_camera.CFrame
                    root.CFrame = CFrame.new(root.Position, Vector3.new(camCF.LookVector.X+root.Position.X, root.Position.Y, camCF.LookVector.Z+root.Position.Z))
                end
            end)
        else
            svc.Input.MouseBehavior = Enum.MouseBehavior.Default
        end
    end

    local sk8_chargeAnimIds = { "117058860640843" }
    local sk8_DASH_SPEED = 60
    local sk8_controlEnabled = true
    local sk8_controlActive = false
    local sk8_overrideConn = nil
    local sk8_savedHumState = {}

    local function sk8_getHumanoid()
        if not lp or not lp.Character then return nil end
        return lp.Character:FindFirstChildOfClass("Humanoid")
    end
    local function sk8_saveHumState(hum)
        if not hum or sk8_savedHumState[hum] then return end
        local s = {}
        pcall(function()
            s.WalkSpeed = hum.WalkSpeed
            local ok, ar = pcall(function() return hum.AutoRotate end)
            if ok then s.AutoRotate = ar end
        end)
        sk8_savedHumState[hum] = s
    end
    local function sk8_restoreHumState(hum)
        if not hum then return end
        local s = sk8_savedHumState[hum]; if not s then return end
        pcall(function()
            if s.WalkSpeed ~= nil then hum.WalkSpeed = s.WalkSpeed end
            if s.AutoRotate ~= nil then pcall(function() hum.AutoRotate = s.AutoRotate end) end
        end)
        sk8_savedHumState[hum] = nil
    end
    local function sk8_startOverride()
        if sk8_controlActive then return end
        local hum = sk8_getHumanoid(); if not hum then return end
        sk8_controlActive = true; sk8_saveHumState(hum)
        pcall(function() hum.WalkSpeed = sk8_DASH_SPEED; hum.AutoRotate = false end)
        sk8_setShiftlock(true)
        sk8_overrideConn = svc.Run.RenderStepped:Connect(function()
            local humanoid = sk8_getHumanoid()
            local rootPart = humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
            if not humanoid or not rootPart then return end
            pcall(function() humanoid.WalkSpeed = sk8_DASH_SPEED; humanoid.AutoRotate = false end)
            local direction = rootPart.CFrame.LookVector
            local horizontal = Vector3.new(direction.X, 0, direction.Z)
            if horizontal.Magnitude > 0 then humanoid:Move(horizontal.Unit) end
        end)
    end
    local function sk8_stopOverride()
        if not sk8_controlActive then return end
        sk8_controlActive = false
        if sk8_overrideConn then pcall(function() sk8_overrideConn:Disconnect() end); sk8_overrideConn = nil end
        sk8_setShiftlock(false)
        local hum = sk8_getHumanoid()
        if hum then
            pcall(function()
                sk8_restoreHumState(hum)
                hum.AutoRotate = true  -- always force-restore rotation regardless of saved state
                hum:Move(Vector3.new(0,0,0))
            end)
        end
    end
    local function sk8_detectChargeAnim()
        local hum = sk8_getHumanoid(); if not hum then return false end
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local ok, animId = pcall(function()
                return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
            end)
            if ok and animId and animId ~= "" then
                if table.find(sk8_chargeAnimIds, animId) then return true end
            end
        end
        return false
    end

    svc.Run.RenderStepped:Connect(function()
        if not sk8_controlEnabled then if sk8_controlActive then sk8_stopOverride() end; return end
        local hum = sk8_getHumanoid()
        if not hum then if sk8_controlActive then sk8_stopOverride() end; return end
        if sk8_detectChargeAnim() then if not sk8_controlActive then sk8_startOverride() end
        else if sk8_controlActive then sk8_stopOverride() end end
    end)

    lp.CharacterAdded:Connect(function()
        if sk8_shiftConn then sk8_shiftConn:Disconnect(); sk8_shiftConn = nil end
        sk8_savedHumState = {}
    end)

    sec_023:Toggle({
        Title = "Enable SK8 Control", Default = sk8_controlEnabled, Flag = "sk8ControlEnabled", Callback = function(on)
            sk8_controlEnabled = on; sakiConfig:Save()
            if not on and sk8_controlActive then sk8_stopOverride() end
        end, Type = "Checkbox"})
    sec_023:Paragraph({ Title = "How it works", Content = "Detects when Veeronica's charge animation is playing and takes over movement: forces 60 walkspeed, locks direction forward, and enables shiftlock." })
end

------------------------------------------------------------------------
-- FAST SPRAY (Veeronica)
------------------------------------------------------------------------
local sec_vee_spray = tabVeeronica:Section({ Title = "Fast Spray", Opened = true })

do
    local SPRAY_ANIM_ID   = "96618767275101"  -- CanSpray animation
    local vee_fastSpray   = false
    local sprayPhase      = 0
    local sprayBaseCF     = nil

    local function isSprayPainting()
        local char = lp.Character; if not char then return false end
        local hum  = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local ok, id = pcall(function()
                return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
            end)
            if ok and id == SPRAY_ANIM_ID then return true end
        end
        return false
    end

    svc.Run.RenderStepped:Connect(function(dt)
        if not vee_fastSpray then
            sprayPhase  = 0
            sprayBaseCF = nil
            return
        end
        if not isSprayPainting() then
            sprayPhase  = 0
            sprayBaseCF = nil
            return
        end
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Re-anchor near sine zero-crossing to prevent drift
        if not sprayBaseCF or math.abs(math.sin(sprayPhase)) < 0.05 then
            sprayBaseCF = hrp.CFrame
        end

        sprayPhase = sprayPhase + dt * (math.pi * 4.5)   -- ~1.5 full cycles/sec
        local offset = math.sin(sprayPhase) * 2           -- ±2 studs side-to-side
        hrp.CFrame = sprayBaseCF + (sprayBaseCF.LookVector * (-offset))
    end)

    lp.CharacterAdded:Connect(function()
        sprayPhase  = 0
        sprayBaseCF = nil
    end)

    sec_vee_spray:Paragraph({
        Title   = "How it works",
        Content = "While Veeronica's spray animation is active, rapidly oscillates her side-to-side (±2 studs) so she covers more wall area without moving manually.",
    })
    sec_vee_spray:Toggle({
        Title = "Enable Fast Spray", Type = "Checkbox", Flag = "veeeFastSpray", Default = vee_fastSpray,
        Callback = function(on)
            vee_fastSpray = on; sakiConfig:Save()
            if not on then sprayPhase = 0; sprayBaseCF = nil end
        end
    })
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: JANE DOE
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabJaneDoe  = win:Tab({ Title = "Jane Doe",  Icon = "gem"  })
local tabSpecial  = tabJaneDoe -- alias for any shared refs

do
    local jd_Run    = svc.Run
    local jd_RS     = svc.RS
    local jd_lp     = lp
    local jd_Camera = svc.WS.CurrentCamera

    local jd_RemoteEvent = nil
    local jd_NetworkRF   = nil
    pcall(function()
        jd_RemoteEvent = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
    end)
    pcall(function()
        jd_NetworkRF = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteFunction",10)
    end)

    local jd_enabled       = false
    local jd_aimbotOn      = false
    local jd_patched       = false
    local jd_crystalCB     = nil
    local jd_unloaded      = false
    local jd_AIM_OFFSET    = -0.3
    local jd_PREDICTION    = 0.6
    local jd_HOLD_DURATION = 0.9
    local jd_axeEnabled    = false
    local jd_AXE_RATE      = 0.3
    local jd_killerMotionData  = {}

    local function jd_getKillerVelocity(hrp)
        local now=tick(); local pos=hrp.Position; local data=jd_killerMotionData[hrp]
        if not data then jd_killerMotionData[hrp]={lastPos=pos,lastTime=now,velocity=Vector3.zero}; return Vector3.zero end
        local dt=now-data.lastTime; if dt<=0 then return data.velocity end
        local vel=(pos-data.lastPos)/dt; data.lastPos=pos; data.lastTime=now; data.velocity=vel
        return vel
    end

    local function jd_getNearestKiller(fromPos)
        local folder=getTeamFolder("Killers"); if not folder then return nil end
        local nearest,best=nil,math.huge
        for _,model in ipairs(folder:GetChildren()) do
            local hrp=model:FindFirstChild("HumanoidRootPart"); local hum=model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then local d=(hrp.Position-fromPos).Magnitude; if d<best then best=d; nearest=model end end
        end
        return nearest
    end

    local function jd_isCrystalBuf(buf)
        if typeof(buf) ~= "buffer" then return false end
        local s = buffer.tostring(buf)
        return s:find("Crystal") ~= nil
    end

    local function jd_fireCrystal()
        if not jd_RemoteEvent then return end
        jd_RemoteEvent:FireServer("UseActorAbility", {
            buffer.fromstring("\x03\x07\x00\x00\x00Crystal")
        })
    end

    local function jd_holdCrystal()
        if not jd_RemoteEvent then return end
        local b = buffer.create(8)
        buffer.writeu32(b, 0, 2)
        buffer.writef32(b, 4, svc.WS.DistributedGameTime)
        jd_RemoteEvent:FireServer(jd_lp.Name .. "CrystalInput", { b })
    end

    -- Axe hook: detect when player fires axe, lock HRP to nearest killer for 1.7s
    local jd_axeEnabled = false
    local jd_AXE_LOCK_DURATION = 1.7
    local jd_axeLocked = false

    local function jd_axeDoLock()
        if jd_axeLocked then return end
        local char = jd_lp.Character
        local myHRP = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not myHRP or not hum then return end
        local killer = jd_getNearestKiller(myHRP.Position)
        local killerHRP = killer and killer:FindFirstChild("HumanoidRootPart")
        if not killerHRP then return end
        jd_axeLocked = true
        local savedAutoRotate = hum.AutoRotate
        hum.AutoRotate = false
        local deadline = tick() + jd_AXE_LOCK_DURATION
        local conn; conn = svc.Run.RenderStepped:Connect(function()
            if tick() >= deadline or not jd_axeEnabled then
                conn:Disconnect()
                pcall(function() hum.AutoRotate = savedAutoRotate end)
                jd_axeLocked = false
                return
            end
            if not myHRP.Parent or not killerHRP.Parent then
                conn:Disconnect()
                pcall(function() hum.AutoRotate = savedAutoRotate end)
                jd_axeLocked = false
                return
            end
            local dir = Vector3.new(killerHRP.Position.X - myHRP.Position.X, 0, killerHRP.Position.Z - myHRP.Position.Z)
            if dir.Magnitude > 0 then
                myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + dir.Unit)
            end
        end)
    end



    local function jd_buildCamCF(myHRP, killerHRP, v0, g)
        local hum=myHRP.Parent and myHRP.Parent:FindFirstChildOfClass("Humanoid")
        local hipH=hum and hum.HipHeight or 1.35
        local v238=(hipH+myHRP.Size.Y/2)/2
        local spawnPos=myHRP.CFrame.Position+Vector3.new(0,v238,0)
        local vel=jd_getKillerVelocity(killerHRP)
        local predicted=killerHRP.Position+vel*jd_PREDICTION
        local target=predicted+Vector3.new(0,jd_AIM_OFFSET,0)
        local delta=target-spawnPos
        local flatV=Vector3.new(delta.X,0,delta.Z)
        local dx=flatV.Magnitude; local dy=delta.Y
        if dx<0.01 then
            local d=dy>=0 and Vector3.new(0,1,0) or Vector3.new(0,-1,0)
            return CFrame.new(jd_Camera.CFrame.Position,jd_Camera.CFrame.Position+d)
        end
        local flatDir=flatV.Unit; local v2=v0*v0
        local disc=v2*v2-g*(g*dx*dx+2*dy*v2)
        local theta=disc<0 and math.atan2(dy,dx) or math.atan2(v2-math.sqrt(disc),g*dx)
        local T=math.tan(theta); local denom=3+T
        local alpha=math.abs(denom)<0.0001 and -math.pi/2 or math.atan2(3*T-1,denom)
        local yawCF=CFrame.new(jd_Camera.CFrame.Position,jd_Camera.CFrame.Position+flatDir)
        return yawCF*CFrame.Angles(alpha,0,0)
    end

    local function jd_getLocalActor() return jd_lp.Character end

    local function jd_applyPatch(actor)
        if jd_patched or not actor or not jd_NetworkRF then return end
        if type(getcallbackvalue)=="function" then
            pcall(function() jd_crystalCB=getcallbackvalue(jd_NetworkRF,"OnClientInvoke") end)
        end
        jd_NetworkRF.OnClientInvoke=function(reqName,...)
            if reqName=="GetCameraCF" and jd_enabled and jd_aimbotOn then
                local char=jd_lp.Character; local myHRP=char and char:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    local killer=jd_getNearestKiller(myHRP.Position)
                    local killerHRP=killer and killer:FindFirstChild("HumanoidRootPart")
                    if killerHRP then
                        local ok,cf=pcall(jd_buildCamCF,myHRP,killerHRP,250,40)
                        if ok and cf then return cf end
                    end
                end
            end
            if jd_crystalCB then return jd_crystalCB(reqName,...) end
        end
        jd_patched=true
    end
    local function jd_removePatch()
        if not jd_patched then return end
        pcall(function() if jd_NetworkRF then jd_NetworkRF.OnClientInvoke=jd_crystalCB end end)
        jd_crystalCB=nil; jd_patched=false
    end


    -- Single merged hook: handles both CrystalInput and Axe detection
    local jd_holdActive = false
    task.spawn(function()
        local ok, re = pcall(function()
            return svc.RS:WaitForChild("Modules",5):WaitForChild("Network",5):WaitForChild("Network",5):WaitForChild("RemoteEvent",5)
        end)
        if not ok or not re then return end
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if method == "FireServer" and self == re then
                local eventName = tostring(args[1])
                if jd_enabled and eventName == (jd_lp.Name .. "CrystalInput") then
                    if not jd_holdActive then
                        jd_holdActive = true
                        task.spawn(function()
                            local deadline = tick() + jd_HOLD_DURATION
                            while tick() < deadline and jd_enabled and not jd_unloaded do
                                jd_holdCrystal()
                                task.wait(1/30)
                            end
                            jd_holdActive = false
                        end)
                    end
                end
                -- Axe: detect UseActorAbility with Axe buffer
                if jd_axeEnabled and eventName == "UseActorAbility" and args[2] and args[2][1] then
                    local ok2, bs = pcall(function() return buffer.tostring(args[2][1]) end)
                    if ok2 and bs and bs:find("Axe") then
                        task.spawn(jd_axeDoLock)
                    end
                end
            end
            return oldNC(self, ...)
        end)
    end)

    task.spawn(function()
        local lastActor=nil
        while not jd_unloaded do
            task.wait(0.5)
            local cur=jd_getLocalActor()
            if cur~=lastActor then
                if lastActor~=nil then jd_patched=false; jd_crystalCB=nil; jd_killerMotionData={} end
                lastActor=cur
                if cur and jd_enabled then jd_applyPatch(cur) end
            end
        end
    end)

    local sec_024 = tabJaneDoe:Section({ Title = "Crystal Auto-Fire", Opened = true })
    sec_024:Paragraph({ Title = "How it works", Content = "Patches Jane Doe's RemoteFunction so every crystal throw auto-fires on a loop with silent aim." })
    sec_024:Toggle({ Title = "Enable Jane Doe Aimbot", Default = false,
        Callback=function(on)
            jd_enabled=on; local actor=jd_getLocalActor()
            if on and not jd_patched and actor then jd_applyPatch(actor) end
        end, Type = "Checkbox"})
    sec_024:Toggle({ Title = "Aimbot (Silent Aim)", Default = false,
        Callback=function(on)
            jd_aimbotOn=on
            local actor=jd_getLocalActor(); if on and not jd_patched and actor then jd_applyPatch(actor) end
        end, Type = "Checkbox"})
    sec_024:Slider({ Title = "Aim Offset (Y)", Value = {Min=-5.0,Max=5.0,Default=jd_AIM_OFFSET}, Step = 0.1, Callback=function(v) jd_AIM_OFFSET=v end })
    sec_024:Slider({ Title = "Prediction", Value = {Min=0.0,Max=1.0,Default=jd_PREDICTION}, Step = 0.01, Callback=function(v) jd_PREDICTION=v end })
    sec_024:Slider({ Title = "Hold Duration (s)", Value = {Min=0.3,Max=2.0,Default=jd_HOLD_DURATION}, Step = 0.1, Callback=function(v) jd_HOLD_DURATION=v end })

    local sec_025 = tabJaneDoe:Section({ Title = "Axe Lock-On", Opened = true })
    sec_025:Paragraph({ Title = "How it works", Content = "Detects when you use the Axe ability and locks your character to face the nearest killer for 1.7 seconds." })
    sec_025:Toggle({ Title = "Enable Axe Lock-On", Default = false,
        Callback=function(on) jd_axeEnabled=on end, Type = "Checkbox"})
    sec_025:Slider({ Title = "Lock Duration (s)", Value = {Min=0.5,Max=3.0,Default=jd_AXE_LOCK_DURATION}, Step = 0.1, Callback=function(v) jd_AXE_LOCK_DURATION=v end })

    local sec_026 = tabJaneDoe:Section({ Title = "Control", Opened = true })
    sec_026:Button({ Title = "Unload Jane Doe", Callback=function()
        if jd_unloaded then return end
        jd_unloaded=true; jd_enabled=false; jd_aimbotOn=false; jd_axeEnabled=false
        pcall(jd_removePatch)
    end})end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: DUSEKKAR
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabDusekkar = win:Tab({ Title = "Dusekkar", Icon = "zap" })

do
    local sec_027 = tabDusekkar:Section({ Title = "PlasmaBeam Silent Aim", Opened = true })

    sec_027:Paragraph({
        Title   = "How it works",
        Content = "Dual hook system: (1) RemoteFunction GetMousePosition callback for mouse-based aiming, (2) UseActorAbility namecall hook with PlasmaBeam buffer check for direct CFrame injection.",
    })

    local plasma_enabled    = false
    local plasma_aimOffset  = 0.0
    local plasma_prediction = 0.12
    
    -- RemoteFunction callback vars
    local plasma_oldCB     = nil
    local plasma_rf        = nil

    local function plasmaGetNearestKiller()
        local char = lp.Character; if not char then return nil end
        local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
        local pf = svc.WS:FindFirstChild("Players")
        local kf = pf and pf:FindFirstChild("Killers")
        if not kf then return nil end
        local best, bestDist = nil, math.huge
        for _, model in ipairs(kf:GetChildren()) do
            if model ~= char then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < bestDist then bestDist = d; best = hrp end
                end
            end
        end
        return best
    end

    local plasma_motionData = {}
    local function plasmaGetVelocity(hrp)
        local now = tick(); local pos = hrp.Position
        local data = plasma_motionData[hrp]
        if not data then
            plasma_motionData[hrp] = { lastPos = pos, lastTime = now, vel = Vector3.zero }
            return Vector3.zero
        end
        local dt = now - data.lastTime
        if dt > 0 then
            data.vel     = (pos - data.lastPos) / dt
            data.lastPos = pos
            data.lastTime = now
        end
        return data.vel
    end

    -- Hook: RemoteFunction GetMousePosition callback (same style as Nova)
    local function plasmaPatchRF()
        if plasma_rf then return end
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 10)
                :WaitForChild("Network", 10)
                :WaitForChild("Network", 10)
                :WaitForChild("RemoteFunction", 10)
        end)
        if not ok or not rf then warn("[SAKIWARE] Dusekkar: RemoteFunction not found"); return end
        plasma_rf = rf
        plasma_oldCB = getcallbackvalue(rf, "OnClientInvoke")
        rf.OnClientInvoke = function(reqName, data, ...)
            if reqName == "GetMousePosition" and plasma_enabled then
                local hrp = plasmaGetNearestKiller()
                if hrp then
                    local vel     = plasmaGetVelocity(hrp)
                    local predPos = hrp.Position + vel * plasma_prediction
                                  + Vector3.new(0, plasma_aimOffset, 0)
                    return predPos
                end
            end
            if plasma_oldCB then return plasma_oldCB(reqName, data, ...) end
        end
    end

    local function plasmaUnpatch()
        if plasma_rf and plasma_oldCB then
            plasma_rf.OnClientInvoke = plasma_oldCB
        end
        plasma_rf = nil; plasma_oldCB = nil
    end

    -- Start hook
    task.spawn(plasmaPatchRF)
    
    lp.CharacterAdded:Connect(function() plasma_motionData = {} end)

    sec_027:Toggle({
        Title = "Enable PlasmaBeam Aim", Default = plasma_enabled, Type = "Checkbox", Flag = "plasmaEnabled",
        Callback = function(on) plasma_enabled = on; sakiConfig:Save() end })
    sec_027:Slider({
        Title = "Prediction (s)", Flag = "plasmaPrediction", Value = {Min=0.0,Max=0.5,Default=plasma_prediction}, Step = 0.01,
        Callback = function(v) plasma_prediction = v; sakiConfig:Save() end
    })
    sec_027:Slider({
        Title = "Aim Height Offset", Flag = "plasmaAimOffset", Value = {Min=-5.0, Max=5.0, Default=plasma_aimOffset}, Step = 0.1,
        Callback = function(v) plasma_aimOffset = v; sakiConfig:Save() end })

    local sec_028 = tabDusekkar:Section({ Title = "Control", Opened = true })
    sec_028:Button({
        Title = "Unload PlasmaBeam Hook", Callback = function()
            plasma_enabled = false; plasmaUnpatch()
        end
    })
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- TAB: NOLI
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabNoli = win:Tab({ Title = "Noli", Icon = "wind" })

do
    local sec_029 = tabNoli:Section({ Title = "Nova Silent Aim", Opened = true })

    sec_029:Paragraph({
        Title   = "How it works",
        Content = "Hooks the RemoteFunction's GetMousePosition callback. When Nova fires, the server asks the client where the mouse is — we return the nearest survivor's predicted position instead.",
    })

    local nova_enabled    = false
    local nova_aimOffset  = 0.0
    local nova_prediction = 0.12
    local nova_oldCB      = nil
    local nova_rf         = nil

    local nova_motionData = {}
    
    local function novaGetVelocity(hrp)
        local now = tick(); local pos = hrp.Position
        local data = nova_motionData[hrp]
        if not data then
            nova_motionData[hrp] = { lastPos = pos, lastTime = now, vel = Vector3.zero }
            return Vector3.zero
        end
        local dt = now - data.lastTime
        if dt > 0 then
            data.vel     = (pos - data.lastPos) / dt
            data.lastPos = pos
            data.lastTime = now
        end
        return data.vel
    end

    local function novaGetNearestSurvivor()
        local char = lp.Character; if not char then return nil end
        local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return nil end
        local pf = svc.WS:FindFirstChild("Players")
        local sf = pf and pf:FindFirstChild("Survivors")
        if not sf then return nil end
        local best, bestDist = nil, math.huge
        for _, model in ipairs(sf:GetChildren()) do
            if model ~= char then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < bestDist then bestDist = d; best = hrp end
                end
            end
        end
        return best
    end

    local function novaPatch()
        if nova_rf then return end
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 10)
                :WaitForChild("Network", 10)
                :WaitForChild("Network", 10)
                :WaitForChild("RemoteFunction", 10)
        end)
        if not ok or not rf then warn("[SAKIWARE] Noli: RemoteFunction not found"); return end
        nova_rf = rf
        nova_oldCB = getcallbackvalue(rf, "OnClientInvoke")
        rf.OnClientInvoke = function(reqName, data, ...)
            if reqName == "GetMousePosition" and nova_enabled then
                local hrp = novaGetNearestSurvivor()
                if hrp then
                    -- Calculate velocity and predicted position
                    local vel = novaGetVelocity(hrp)
                    local predPos = hrp.Position + vel * nova_prediction
                                  + Vector3.new(0, nova_aimOffset, 0)
                    return predPos
                end
            end
            if nova_oldCB then return nova_oldCB(reqName, data, ...) end
        end
    end

    local function novaUnpatch()
        if nova_rf and nova_oldCB then
            nova_rf.OnClientInvoke = nova_oldCB
        end
        nova_rf = nil; nova_oldCB = nil
    end

    task.spawn(novaPatch)
    
    lp.CharacterAdded:Connect(function() nova_motionData = {} end)

    sec_029:Toggle({
        Title = "Enable Nova Aim", Default = nova_enabled, Type = "Checkbox", Flag = "novaEnabled",
        Callback = function(on) nova_enabled = on; sakiConfig:Save() end })
    sec_029:Slider({
        Title = "Prediction (s)", Flag = "novaPrediction", Value = {Min=0.0,Max=0.5,Default=nova_prediction}, Step = 0.01,
        Callback = function(v) nova_prediction = v; sakiConfig:Save() end
    })
    sec_029:Slider({
        Title = "Aim Height Offset", Flag = "novaAimOffset", Value = {Min=-5.0, Max=5.0, Default=nova_aimOffset}, Step = 0.1,
        Callback = function(v) nova_aimOffset = v; sakiConfig:Save() end })

    local sec_029b = tabNoli:Section({ Title = "Control", Opened = true })
    sec_029b:Button({
        Title = "Unload Nova Hook", Callback = function()
            nova_enabled = false; novaUnpatch()
        end
    })
end

-- TAB: AI PLAY (Killer-side)
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabAI = win:Tab({ Title = "AI", Icon = "cpu" })
local secAIMain = tabAI:Section({ Title = "Killer AI", Opened = true })

secAIMain:Paragraph({
    Title   = "What this does",
    Content = "Pathfinds to the nearest survivor using PathfindingService. Killer-only — switch to killer before enabling.",
})

local ai_enabled      = false
local ai_resetOnDeath = true
local ai_thread       = nil
local PathfindingService = game:GetService("PathfindingService")

-----------------------------------------------------------------------
-- KILLER AI — Config
-----------------------------------------------------------------------
local aiCfg = {
    slashRange    = 15,
    slashCooldown = 2,
    pathInterval  = 0.6,
    predScale     = 0.08,
}

-----------------------------------------------------------------------
-- KILLER AI — State
-----------------------------------------------------------------------
local aiState = {
    target      = nil,
    lastSlash   = 0,
    lastPath    = 0,
    waypoints   = {},
    wpIndex     = 1,
    moveConn    = nil,
    lastMovePos = nil,
}

-----------------------------------------------------------------------
-- KILLER AI — Helpers
-----------------------------------------------------------------------
local function aiGetSurvivorsFolder()
    local p = svc.WS:FindFirstChild("Players")
    return p and p:FindFirstChild("Survivors")
end

local function aiPredictPosition(hrp, t)
    local vel = hrp.AssemblyLinearVelocity or Vector3.zero
    return hrp.Position + vel * t
end

local function aiGetNearest()
    local char = lp.Character; if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local sf = aiGetSurvivorsFolder(); if not sf then return end
    local best, dist = nil, math.huge
    for _, m in ipairs(sf:GetChildren()) do
        local h = m:FindFirstChildOfClass("Humanoid")
        local r = m:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health > 0 then
            local d = (aiPredictPosition(r, aiCfg.predScale) - myHRP.Position).Magnitude
            if d < dist then dist = d; best = {model = m, humanoid = h, root = r} end
        end
    end
    return best
end

local function aiFireSlash()
    local re = svc.RS:FindFirstChild("RemoteEvent", true)
    if re then pcall(function() re:FireServer("Slash") end) end
end

-----------------------------------------------------------------------
-- KILLER AI — Movement Loop (NEVER STOPS)
-----------------------------------------------------------------------
local function aiStartMove()
    if aiState.moveConn then aiState.moveConn:Disconnect() end

    aiState.moveConn = svc.Run.Heartbeat:Connect(function()
        if not ai_enabled then return end
        local char = lp.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        if not aiState.target then return end
        local targetHRP = aiState.target.root
        if not targetHRP then return end

        -- If close, discard stale waypoints and track live position directly
        local directDist = (targetHRP.Position - hrp.Position).Magnitude
        if directDist <= 20 then
            aiState.waypoints   = {}
            aiState.wpIndex     = 1
            aiState.lastMovePos = nil
            hum:MoveTo(targetHRP.Position)
            return
        end

        -- Follow waypoints
        if aiState.wpIndex <= #aiState.waypoints then
            local wp = aiState.waypoints[aiState.wpIndex]
            if (hrp.Position - wp.Position).Magnitude < 5 then
                aiState.wpIndex += 1
            end
            hum:MoveTo(wp.Position)
            return
        end

        -- Direct chase with smooth lerp (ALWAYS ACTIVE, never stops)
        aiState.lastMovePos = aiState.lastMovePos or hrp.Position
        local targetPos = aiPredictPosition(targetHRP, aiCfg.predScale)
        aiState.lastMovePos = aiState.lastMovePos:Lerp(targetPos, 0.15)
        hum:MoveTo(aiState.lastMovePos)
    end)
end

-----------------------------------------------------------------------
-- KILLER AI — Main Loop (NEVER DIES)
-----------------------------------------------------------------------
local function aiKillerLoop()
    aiStartMove()

    while ai_enabled do
        task.wait(0.1)
        local char = lp.Character; if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            if ai_resetOnDeath then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end) end
            task.wait(3); continue
        end

        -- Retarget only if current target is dead/gone
        if not aiState.target or not aiState.target.root
            or aiState.target.humanoid.Health <= 0 then
            aiState.target    = aiGetNearest()
            aiState.waypoints = {}
            aiState.wpIndex   = 1
        end

        if not aiState.target then continue end
        local targetHRP = aiState.target.root

        -- Attack
        local dist = (targetHRP.Position - hrp.Position).Magnitude
        if dist <= aiCfg.slashRange then
            if tick() - aiState.lastSlash > aiCfg.slashCooldown then
                aiFireSlash()
                aiState.lastSlash = tick()
            end
        end

        -- Pathfinding (safe, refreshes every interval)
        if tick() - aiState.lastPath > aiCfg.pathInterval then
            aiState.lastPath = tick()
            local path = PathfindingService:CreatePath({
                AgentRadius = 2, AgentHeight = 5, AgentCanJump = true
            })
            local ok = pcall(function()
                path:ComputeAsync(hrp.Position, aiPredictPosition(targetHRP, aiCfg.predScale))
            end)
            if ok and path.Status == Enum.PathStatus.Success then
                aiState.waypoints = path:GetWaypoints()
                aiState.wpIndex   = 1
            else
                aiState.waypoints = {} -- fallback: direct chase via Heartbeat
            end
        end
    end

    -- Cleanup on stop
    if aiState.moveConn then aiState.moveConn:Disconnect(); aiState.moveConn = nil end
end

secAIMain:Toggle({
    Title = "Enable Killer AI Farm", Type = "Checkbox", Flag = "aiKillerEnabled", Default = ai_enabled,
    Callback = function(on)
        ai_enabled = on; sakiConfig:Save()
        if on then
            if ai_thread then task.cancel(ai_thread) end
            aiState.target      = nil
            aiState.waypoints   = {}
            aiState.wpIndex     = 1
            aiState.lastMovePos = nil
            ai_thread = task.spawn(aiKillerLoop)
        else
            ai_enabled = false
            if ai_thread then task.cancel(ai_thread); ai_thread = nil end
            if aiState.moveConn then aiState.moveConn:Disconnect(); aiState.moveConn = nil end
            aiState.target    = nil
            aiState.waypoints = {}
            aiState.wpIndex   = 1
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:MoveTo(char.HumanoidRootPart.Position) end
            end
        end
    end
})

secAIMain:Toggle({
    Title = "Auto Reset on Death", Type = "Checkbox", Flag = "aiResetOnDeath", Default = ai_resetOnDeath,
    Callback = function(on) ai_resetOnDeath = on; sakiConfig:Save() end
})

local secAICtrl = tabAI:Section({ Title = "Control", Opened = true })
secAICtrl:Button({
    Title = "Stop AI", Callback = function()
        ai_enabled = false
        if ai_thread then task.cancel(ai_thread); ai_thread = nil end
        if aiState.moveConn then aiState.moveConn:Disconnect(); aiState.moveConn = nil end
        aiState.target    = nil
        aiState.waypoints = {}
        aiState.wpIndex   = 1
    end
})

-- TAB: INTERFACE
------------------------------------------------------------------------
------------------------------------------------------------------------
local tabInterface = win:Tab({ Title = "Interface", Icon = "layout-dashboard" })
local sec_030 = tabInterface:Section({ Title = "UI Functions", Opened = true })

sec_030:Button({ Title = "Close UI", Locked = false, Callback = function()
    local ok = pcall(function() win:Destroy() end)
    if not ok then pcall(function() win:Close() end) end
end })

print("SAKIWARE ready")

sakiConfig:Load()
