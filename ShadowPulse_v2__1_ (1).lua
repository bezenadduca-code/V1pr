-- BetrayalHub - Complete Final Version with Guest 1337 Tab
print("betrayalhub loading...")

-- ============================================================
-- ERROR HANDLER - Flashes errors on screen
-- ============================================================
local function flashError(msg)
    local ok, flashErr = pcall(function()
        local player = game:GetService("Players").LocalPlayer
        local gui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
        if not gui then return end
        
        local errorGui = Instance.new("ScreenGui")
        errorGui.Name = "BetrayalHub_Error"
        errorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        errorGui.Parent = gui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 500, 0, 100)
        frame.Position = UDim2.new(0.5, -250, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        frame.BackgroundTransparency = 0.15
        frame.BorderSizePixel = 3
        frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
        frame.Parent = errorGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -20)
        label.Position = UDim2.new(0, 10, 0, 10)
        label.Text = "⚠️ BetrayalHub ERROR\n\n" .. tostring(msg):sub(1, 150)
        label.TextColor3 = Color3.fromRGB(255, 200, 200)
        label.TextScaled = true
        label.BackgroundTransparency = 1
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 80, 0, 30)
        closeBtn.Position = UDim2.new(1, -90, 1, -40)
        closeBtn.Text = "Dismiss"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeBtn.BorderSizePixel = 0
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = frame
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            errorGui:Destroy()
        end)
        
        task.delay(15, function()
            pcall(function() errorGui:Destroy() end)
        end)
    end)
    if not ok then warn("[betrayalhub] flashError itself failed: " .. tostring(flashErr)) end
end

local success, err = pcall(function()

local svc = {
    Players        = game:GetService("Players"),
    Run            = game:GetService("RunService"),
    Input          = game:GetService("UserInputService"),
    RS             = game:GetService("ReplicatedStorage"),
    WS             = game:GetService("Workspace"),
    TweenService   = game:GetService("TweenService"),
    TextChat       = game:GetService("TextChatService"),
    Http           = game:GetService("HttpService"),
    SoundService   = game:GetService("SoundService"),
    Stats          = game:GetService("Stats"),
}

local lp  = svc.Players.LocalPlayer
local gui = lp:WaitForChild("PlayerGui", 10)

local fs = {
    hasFolder = isfolder     or function() return false end,
    makeFolder= makefolder   or function() end,
    write     = writefile    or function() end,
    hasFile   = isfile       or function() return false end,
    read      = readfile     or function() return "" end,
    asset     = getcustomasset or function(p) return p end,
}

local WIND_DIR  = "betrayalhub"
local WIND_FILE = WIND_DIR .. "/WindUI.lua"
local WIND_URL  = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

local function loadWindUI()
    if fs.hasFolder(WIND_DIR) and fs.hasFile(WIND_FILE) then
        local src = fs.read(WIND_FILE)
        if src and #src > 100 then
            local ok, result = pcall(loadstring, src)
            if ok and result then
                local ok2, ui = pcall(result)
                if ok2 and ui then
                    print("[betrayalhub] WindUI loaded from cache")
                    return ui
                end
            end
        end
    end
    
    print("[betrayalhub] Downloading WindUI...")
    local success, src = pcall(game.HttpGet, game, WIND_URL)
    if success and src and #src > 100 then
        pcall(function()
            if not fs.hasFolder(WIND_DIR) then fs.makeFolder(WIND_DIR) end
            fs.write(WIND_FILE, src)
        end)
        
        local ok, result = pcall(loadstring, src)
        if ok and result then
            local ok2, ui = pcall(result)
            if ok2 and ui then
                print("[betrayalhub] WindUI downloaded and loaded")
                return ui
            end
        end
    end
    
    print("[betrayalhub] Trying alternative WindUI URL...")
    local altURL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"
    local success2, src2 = pcall(game.HttpGet, game, altURL)
    if success2 and src2 and #src2 > 100 then
        local ok, result = pcall(loadstring, src2)
        if ok and result then
            local ok2, ui = pcall(result)
            if ok2 and ui then
                print("[betrayalhub] WindUI loaded from alternative URL")
                return ui
            end
        end
    end
    
    error("Failed to load WindUI from all sources")
    return nil
end

local ui = loadWindUI()

if not ui then
    error("WindUI is nil - cannot create window")
end

local win
pcall(function()
    win = ui:CreateWindow({
        Title          = "BetrayalHub",
        Icon           = "sparkles",
        Author         = " By Mitsuki And Samuel",
        Folder         = "betrayalhub",
        Size           = UDim2.fromOffset(350, 480),
        Transparent    = false,
        Theme          = "Crimson",
        Resizable      = false,
        SideBarWidth   = 150,
        HideSearchBar  = true,
        ScrollBarEnabled = false,
        
        KeySystem = {
            Key = { "RELEASE" },
            Note = "join the server for key its in Script",
            URL = "https://discord.gg/H5GdzJA2Nb",
            SaveKey = true,
        },
    })
end)

if not win then
    error("Failed to create window - WindUI may be incompatible")
end

local ConfigManager = win.ConfigManager
local v1prConfig = ConfigManager:CreateConfig("betrayalhub")

win:SetToggleKey(Enum.KeyCode.L)
pcall(function() ui:SetFont("rbxasset://fonts/families/AccanthisADFStd.json") end)

pcall(function()
    win:EditOpenButton({
        Title          = "BetrayalHub",
        Icon           = "sparkles",
        CornerRadius   = UDim.new(0, 16),
        StrokeThickness = 0,
        Color = ColorSequence.new(Color3.fromHex("000000"), Color3.fromHex("000000")),
        OnlyMobile = false,
        Enabled    = true,
        Draggable  = true,
    })
end)

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

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

local _networkModule = nil
local function getNetwork()
    if _networkModule then return _networkModule end
    local ok, m = pcall(function() return require(svc.RS.Modules.Network.Network) end)
    if ok and m then _networkModule = m end
    return _networkModule
end

local _hbRemote = nil
local function hbGetRemote()
    if _hbRemote and _hbRemote.Parent then return _hbRemote end
    local ok, re = pcall(function()
        return svc.RS.Modules.Network.Network:FindFirstChild("RemoteEvent")
    end)
    if ok and re then _hbRemote = re; return re end
    return nil
end

-- ============================================================
-- SHARED RF DISPATCHER SYSTEM (for silent aim)
-- ============================================================
local rfDispatch = {
    hooks = {},
    installed = false,
    originalCallback = nil,
    activeRemote = nil
}

function rfDispatch:register(id, callback)
    self.hooks[id] = callback
end

function rfDispatch:unregister(id)
    self.hooks[id] = nil
end

function rfDispatch:install(remoteFunction)
    if self.installed then return end
    
    self.activeRemote = remoteFunction
    
    if typeof(getcallbackvalue) == "function" then
        self.originalCallback = getcallbackvalue(remoteFunction, "OnClientInvoke")
    else
        self.originalCallback = remoteFunction.OnClientInvoke
    end

    remoteFunction.OnClientInvoke = function(requestName, ...)
        local shouldIntercept = false
        local interceptRequests = {"GetMousePosition", "GetCameraCF"}
        
        for _, req in ipairs(interceptRequests) do
            if requestName == req then
                shouldIntercept = true
                break
            end
        end
        
        if shouldIntercept then
            for id, hookFunc in pairs(self.hooks) do
                local success, result = pcall(hookFunc, requestName, ...)
                if success and result ~= nil then
                    return result
                end
            end
        end
        
        if self.originalCallback then
            local ok, res = pcall(self.originalCallback, requestName, ...)
            if ok then return res end
        end
    end
    self.installed = true
end

function rfDispatch:uninstall(remoteFunction)
    if not self.installed then return end
    if remoteFunction and self.originalCallback then
        remoteFunction.OnClientInvoke = self.originalCallback
    end
    self.hooks = {}
    self.originalCallback = nil
    self.installed = false
    self.activeRemote = nil
end

-- ============================================================
-- SETTINGS TAB
-- ============================================================

do -- tabSettings
local tabSettings = win:Tab({ Title = "Setting", Icon = "settings" })

-- QTE SECTION
local secQTE = tabSettings:Section({ Title = "QTE", Opened = true })

local qteConfig = {
    enabled = false,
    clickDelay = 0.08,
    debounceTime = 0.25,
    zoneMargin = 0.02,
    clickOffset = 0.0,
    spamWaitTime = 0.03,
    preClickAttempts = 3,
}

local qteConnection = nil

local function disarmQTEStart()
    if qteConnection then return end
    
    pcall(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer
        
        local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
        
        local autoQTEEnabled = true
        local qteModuleInstance = nil
        local qteActive = false
        local qteUI = nil
        
        local lastClickTime = 0
        local clickCount = 0
        local successCount = 0
        local failCount = 0
        local qteStartTime = 0
        local lastLinePos = 0
        local lineDirection = 1
        
        local function getQTEModule()
            if qteModuleInstance then return qteModuleInstance end
            local assets = ReplicatedStorage:FindFirstChild("Assets")
            if not assets then return nil end
            local killers = assets:FindFirstChild("Killers")
            if not killers then return nil end
            local azure = killers:FindFirstChild("Azure")
            if not azure then return nil end
            local config = azure:FindFirstChild("mike old")
            if not config then return nil end
            config = config:FindFirstChild("[OLD] Config")
            if not config then return nil end
            local workaround = config:FindFirstChild("cl_WorkaroundModules")
            if not workaround then return nil end
            local module = workaround:FindFirstChild("cl_QTEUI")
            if not module then return nil end
            local result = require(module)
            if type(result) ~= "table" then return nil end
            qteModuleInstance = result
            return qteModuleInstance
        end
        
        local function getQTEUI()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not playerGui then return nil end
            local tempUI = playerGui:FindFirstChild("TemporaryUI")
            if tempUI then local qte = tempUI:FindFirstChild("QTE") if qte then return qte end end
            local mainUI = playerGui:FindFirstChild("MainUI")
            if mainUI then local qte = mainUI:FindFirstChild("QTE") if qte then return qte end end
            return playerGui:FindFirstChild("QTE")
        end
        
        local function onQTEAppeared()
            if qteActive then return end
            qteActive = true
            qteStartTime = os.clock()
            clickCount = 0 successCount = 0 failCount = 0 lastLinePos = 0
            getQTEModule()
        end
        
        local function onQTEDisappeared()
            if not qteActive then return end
            qteActive = false
        end
        
        local function getClickableArea(ui)
            if not ui then return nil end
            for _, name in ipairs({"ClickArea", "Button", "TextLabel", "Frame", "ImageLabel"}) do
                local obj = ui:FindFirstChild(name)
                if obj and obj.Visible then return obj end
            end
            for _, child in ipairs(ui:GetChildren()) do
                if (child:IsA("ImageButton") or child:IsA("TextButton")) and child.Visible then return child end
            end
            if ui:IsA("GuiObject") and ui.Visible then return ui end
            return nil
        end
        
        local function simulateMouseClick(ui)
            local clickable = getClickableArea(ui)
            if not clickable or not VirtualInputManager then return false end
            local absPos = clickable.AbsolutePosition
            local absSize = clickable.AbsoluteSize
            if absPos.X <= 0 or absPos.Y <= 0 then return false end
            local x = absPos.X + absSize.X / 2
            local y = absPos.Y + absSize.Y / 2
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
            return true
        end
        
        local function simulateTouch(ui)
            local clickable = getClickableArea(ui)
            if not clickable or not VirtualInputManager then return false end
            local absPos = clickable.AbsolutePosition
            local absSize = clickable.AbsoluteSize
            if absPos.X <= 0 or absPos.Y <= 0 then return false end
            local x = absPos.X + absSize.X / 2
            local y = absPos.Y + absSize.Y / 2
            local screenSize = game:GetService("Workspace").CurrentCamera.ViewportSize
            if x > screenSize.X or y > screenSize.Y then x = screenSize.X / 2 y = screenSize.Y / 2 end
            VirtualInputManager:SendTouchEvent(1, 0, x, y)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(1, 2, x, y)
            return true
        end
        
        local function useModuleMethod(ui)
            local module = getQTEModule()
            if not module or not module.OnButtonPressed then return false end
            module.OnButtonPressed(ui)
            return true
        end
        
        local function pressQTE()
            if not qteActive then return false end
            local ui = getQTEUI()
            if not ui or not ui.Visible then return false end
            local currentTime = os.clock()
            if currentTime - lastClickTime < qteConfig.debounceTime then return false end
            lastClickTime = currentTime
            clickCount = clickCount + 1
            local success = isMobile and simulateTouch(ui) or simulateMouseClick(ui)
            if not success then success = useModuleMethod(ui) end
            if success then successCount = successCount + 1 return true end
            failCount = failCount + 1
            return false
        end
        
        local function trackLineMovement(ui)
            local line = ui:FindFirstChild("Line")
            if not line then return end
            local currentPos = line.Position.X.Scale
            local delta = currentPos - lastLinePos
            if math.abs(delta) > 0.001 then lineDirection = delta > 0 and 1 or -1 end
            lastLinePos = currentPos
        end
        
        local function autoQTELoop()
            if not qteActive then return end
            local ui = getQTEUI()
            if not ui or not ui.Visible then onQTEDisappeared() return end
            trackLineMovement(ui)
            local line = ui:FindFirstChild("Line")
            if not line then return end
            local linePos = line.Position.X.Scale
            local zones = {}
            for _, child in ipairs(ui:GetChildren()) do
                if child.Name:find("Zone") and child.Visible then
                    table.insert(zones, {
                        Min = child.Position.X.Scale - child.Size.X.Scale / 2,
                        Max = child.Position.X.Scale + child.Size.X.Scale / 2,
                        Center = child.Position.X.Scale
                    })
                end
            end
            if #zones == 0 then return end
            for _, zone in ipairs(zones) do
                if linePos >= zone.Min and linePos <= zone.Max then
                    local retries = 0
                    while retries < 5 do
                        local stillInZone = line.Position.X.Scale >= zone.Min and line.Position.X.Scale <= zone.Max
                        if not stillInZone then break end
                        pressQTE()
                        retries = retries + 1
                        task.wait(qteConfig.spamWaitTime)
                    end
                    task.wait(qteConfig.debounceTime)
                    return
                end
                local distToEdge = lineDirection > 0 and (zone.Min - linePos) or (linePos - zone.Max)
                if distToEdge > 0 and distToEdge <= qteConfig.zoneMargin then
                    task.wait(qteConfig.clickDelay)
                    for _ = 1, qteConfig.preClickAttempts do
                        local currentPos = line.Position.X.Scale
                        if currentPos >= zone.Min and currentPos <= zone.Max then
                            pressQTE()
                            task.wait(qteConfig.spamWaitTime)
                        else
                            break
                        end
                    end
                    task.wait(qteConfig.debounceTime)
                    return
                end
            end
        end
        
        local function setupQTEWatcher()
            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not playerGui then return end
            local function checkForQTE()
                local ui = getQTEUI()
                if ui and not qteUI then
                    qteUI = ui
                    ui:GetPropertyChangedSignal("Visible"):Connect(function()
                        if ui.Visible then onQTEAppeared() else onQTEDisappeared() end
                    end)
                    if ui.Visible then onQTEAppeared() end
                end
            end
            checkForQTE()
            playerGui.ChildAdded:Connect(function(child)
                if child.Name == "TemporaryUI" or child.Name == "MainUI" then
                    task.wait(0.1) checkForQTE()
                end
            end)
            task.spawn(function()
                while autoQTEEnabled do
                    task.wait(0.5)
                    local ui = getQTEUI()
                    if ui and ui.Visible and not qteActive then onQTEAppeared()
                    elseif (not ui or not ui.Visible) and qteActive then onQTEDisappeared() end
                end
            end)
        end
        
        autoQTEEnabled = true
        qteActive = false
        qteStartTime = 0
        setupQTEWatcher()
        qteConnection = RunService.Heartbeat:Connect(function()
            if autoQTEEnabled then autoQTELoop() end
        end)
    end)
end

local function disarmQTEStop()
    if qteConnection then
        qteConnection:Disconnect()
        qteConnection = nil
    end
end

secQTE:Toggle({
    Title = "Enable Disarm QTE",
    Type = "Checkbox",
    Flag = "disarmQTEEnabled",
    Default = qteConfig.enabled,
    Callback = function(on)
        pcall(function()
            qteConfig.enabled = on
            if on then disarmQTEStart() else disarmQTEStop() end
        end)
    end
})

secQTE:Slider({
    Title = "Click Delay (s)",
    Flag = "qteClickDelay",
    Step = 0.01,
    Value = { Min = 0.01, Max = 0.5, Default = qteConfig.clickDelay },
    Callback = function(v)
        pcall(function()
            qteConfig.clickDelay = v
        end)
    end
})

secQTE:Slider({
    Title = "Debounce Time (s)",
    Flag = "qteDebounceTime",
    Step = 0.01,
    Value = { Min = 0.05, Max = 0.5, Default = qteConfig.debounceTime },
    Callback = function(v)
        pcall(function()
            qteConfig.debounceTime = v
        end)
    end
})

secQTE:Slider({
    Title = "Zone Margin",
    Flag = "qteZoneMargin",
    Step = 0.005,
    Value = { Min = 0.005, Max = 0.1, Default = qteConfig.zoneMargin },
    Callback = function(v)
        pcall(function()
            qteConfig.zoneMargin = v
        end)
    end
})

secQTE:Slider({
    Title = "Spam Click Interval (s)",
    Flag = "qteSpamWaitTime",
    Step = 0.005,
    Value = { Min = 0.005, Max = 0.1, Default = qteConfig.spamWaitTime },
    Callback = function(v)
        pcall(function()
            qteConfig.spamWaitTime = v
        end)
    end
})

secQTE:Slider({
    Title = "Pre-Click Attempts",
    Flag = "qtePreClickAttempts",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = qteConfig.preClickAttempts },
    Callback = function(v)
        pcall(function()
            qteConfig.preClickAttempts = v
        end)
    end
})

secQTE:Slider({
    Title = "Click Offset",
    Flag = "qteClickOffset",
    Step = 0.01,
    Value = { Min = -0.5, Max = 0.5, Default = qteConfig.clickOffset },
    Callback = function(v)
        pcall(function()
            qteConfig.clickOffset = v
        end)
    end
})

local secInterface = tabSettings:Section({ Title = "Interface", Opened = true })

-- Spoof Usernames
local spoofActive = false
local spoofText   = "BetrayalHub"
local spoofCache  = {}
local spoofConns  = {}

local function spoofApply(lbl)
    pcall(function()
        if not (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) then return end
        if lbl.Name ~= "Username" then return end
        if not spoofCache[lbl] then spoofCache[lbl] = lbl.Text end
        if spoofActive then lbl.Text = spoofText end
    end)
end

local function spoofRevert()
    pcall(function()
        for lbl, orig in pairs(spoofCache) do if lbl and lbl.Parent then lbl.Text = orig end end
        spoofCache = {}
    end)
end

local function spoofScan()
    pcall(function()
        local pg = lp:FindFirstChild("PlayerGui"); if not pg then return end
        task.defer(function()
            for _, root in ipairs({ pg:FindFirstChild("MainUI"), pg:FindFirstChild("TemporaryUI") }) do
                if root then for _, obj in ipairs(root:GetDescendants()) do spoofApply(obj) end end
            end
        end)
    end)
end

local function spoofWatch(root)
    pcall(function()
        if not root then return end
        table.insert(spoofConns, root.DescendantAdded:Connect(function(obj)
            if spoofActive then task.defer(spoofApply, obj) end
        end))
    end)
end

local function spoofStart()
    pcall(function()
        for _, c in ipairs(spoofConns) do if c.Connected then c:Disconnect() end end
        spoofConns = {}
        local pg = lp:FindFirstChild("PlayerGui"); if not pg then return end
        spoofScan()
        spoofWatch(pg:FindFirstChild("MainUI"))
        spoofWatch(pg:FindFirstChild("TemporaryUI"))
        table.insert(spoofConns, pg.ChildAdded:Connect(function(child)
            if (child.Name == "MainUI" or child.Name == "TemporaryUI") and spoofActive then
                task.delay(0.1, spoofScan); spoofWatch(child)
            end
        end))
    end)
end

local function spoofStop()
    pcall(function()
        for _, c in ipairs(spoofConns) do if c.Connected then c:Disconnect() end end
        spoofConns = {}; spoofRevert()
    end)
end

secInterface:Toggle({
    Title = "Spoof Usernames", Type = "Checkbox", Flag = "spoofActive", Default = spoofActive,
    Callback = function(on) pcall(function() spoofActive = on; if on then spoofStart() else spoofStop() end end) end
})

-- Show Chat Logs
local chatForceEnabled = false
local chatForceConn    = nil

local function enforceChatOn()
    pcall(function()
        if not chatForceEnabled then return end
        local cw = svc.TextChat:FindFirstChild("ChatWindowConfiguration")
        local ci = svc.TextChat:FindFirstChild("ChatInputBarConfiguration")
        if cw and not cw.Enabled then cw.Enabled = true end
        if ci and not ci.Enabled then ci.Enabled = true end
    end)
end

secInterface:Toggle({
    Title = "Show Chat Logs", Type = "Checkbox", Flag = "chatForceEnabled", Default = chatForceEnabled,
    Callback = function(on)
        pcall(function()
            chatForceEnabled = on; 
            if chatForceConn then chatForceConn:Disconnect(); chatForceConn = nil end
            if on then
                enforceChatOn()
                chatForceConn = svc.Run.Heartbeat:Connect(enforceChatOn)
                for _, key in ipairs({ "ChatWindowConfiguration", "ChatInputBarConfiguration" }) do
                    local obj = svc.TextChat:FindFirstChild(key)
                    if obj then obj:GetPropertyChangedSignal("Enabled"):Connect(enforceChatOn) end
                end
            end
        end)
    end
})

-- Timer Position
local timerSide = "Middle"

local function applyTimerPos()
    pcall(function()
        local rt = lp.PlayerGui:FindFirstChild("RoundTimer")
        local m  = rt and rt:FindFirstChild("Main")
        if m then m.Position = UDim2.new(timerSide == "Middle" and 0.5 or 0.9, 0, m.Position.Y.Scale, m.Position.Y.Offset) end
    end)
end

applyTimerPos()

secInterface:Dropdown({
    Title = "Timer Position", Flag = "timerSide", Values = { "Middle", "Right" }, Value = timerSide,
    Callback = function(v) pcall(function() timerSide = v; applyTimerPos() end) end
})

-- Disable Jump Button
local jumpDisabled = false
local jumpBackup = nil

local function toggleJump(enabled)
    pcall(function()
        local gui = lp:FindFirstChild("PlayerGui")
        if not gui then return end
        local touchGui = gui:FindFirstChild("TouchGui")
        if not touchGui then return end
        local frame = touchGui:FindFirstChild("TouchControlFrame")
        if not frame then return end
        
        if enabled then
            -- Delete jump button
            local jump = frame:FindFirstChild("JumpButton")
            if jump then
                jumpBackup = jump:Clone()
                jump:Destroy()
                print("[betrayalhub] Jump button disabled!")
            end
        else
            -- Restore jump button
            if jumpBackup then
                local newJump = jumpBackup:Clone()
                newJump.Parent = frame
                print("[betrayalhub] Jump button enabled!")
            end
        end
    end)
end

secInterface:Toggle({
    Title = "Disable Jump", Type = "Checkbox", Flag = "jumpDisabled", Default = jumpDisabled,
    Callback = function(v)
        pcall(function()
            jumpDisabled = v
            toggleJump(v)
        end)
    end
})

lp.CharacterAdded:Connect(function()
    task.delay(1, function()
        pcall(function()
            if spoofActive then spoofStart() end
            applyTimerPos()
            if jumpDisabled then toggleJump(true) end
        end)
    end)
end)

-- Platform Spoofer
local secPlatform = tabSettings:Section({ Title = "Platform Spoofer", Opened = true })
local platEnabled = false
local platDevice  = "Console"
local platLoop    = nil
local platConn    = nil

local function platPush()
    pcall(function()
        if not platEnabled then return end
        local net = getNetwork()
        if net then pcall(function() net:FireServerConnection("SetDevice", "REMOTE_EVENT", platDevice) end) end
    end)
end

local function platStart()
    pcall(function()
        if platLoop then return end; platPush()
        if platConn then platConn:Disconnect() end
        platConn = svc.Input.LastInputTypeChanged:Connect(function() if platEnabled then platPush() end end)
        platLoop = task.spawn(function() while platEnabled do platPush(); task.wait(1) end; platLoop = nil end)
    end)
end

local function platStop()
    pcall(function()
        platEnabled = false
        if platLoop then task.cancel(platLoop); platLoop = nil end
        if platConn then platConn:Disconnect(); platConn = nil end
    end)
end

secPlatform:Toggle({ Title = "Enable Spoofer", Type = "Checkbox", Flag = "platEnabled", Default = platEnabled,
    Callback = function(on) pcall(function() platEnabled = on; if on then platStart() else platStop() end end) end })

secPlatform:Dropdown({ Title = "Device", Flag = "platDevice", Values = { "PC", "Mobile", "Console" }, Value = platDevice,
    Callback = function(v) pcall(function() platDevice = v; if platEnabled then platPush() end end) end })

lp.CharacterAdded:Connect(function() task.delay(1, function() pcall(function() if platEnabled then platPush() end end) end) end)

-- ============================================================
-- EMOTES  (Settings Tab)
-- ============================================================
local secEmotes = tabSettings:Section({ Title = "Emotes", Opened = true })

do
    local EmFolderPath = svc.RS:FindFirstChild("Assets") and svc.RS.Assets:FindFirstChild("Emotes")

    local emState = {
        emoting = false, track = nil,
        spd = 16, jump = 50,
        rotConn = nil, guiOn = false, sg = nil,
    }

    local function emStop()
        if not emState.emoting then return end
        emState.emoting = false
        if emState.rotConn then emState.rotConn:Disconnect(); emState.rotConn = nil end
        local ch = lp.Character
        if ch then
            local root = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
            local hum  = ch:FindFirstChildOfClass("Humanoid")
            local vfx  = ch:FindFirstChild("PlayerEmoteVFX"); if vfx then vfx:Destroy() end
            if root then
                root.Anchored = false
                local snd = root:FindFirstChild("EmoteSound"); if snd then snd:Destroy() end
                local att = root:FindFirstChild("RootAttachment"); if att then att:Destroy() end
            end
            if hum then hum.WalkSpeed = emState.spd; hum.JumpPower = emState.jump end
        end
        if emState.track then pcall(function() emState.track:Stop() end); emState.track = nil end
    end

    local function emPlay(mod)
        if emState.emoting then emStop(); task.wait(0.1) end
        local ch   = lp.Character; if not ch then return end
        local hum  = ch:FindFirstChildOfClass("Humanoid")
        local root = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
        local anim = hum and hum:WaitForChild("Animator", 2)
        if not hum or not root or not anim then return end
        local ok, data = pcall(require, mod)
        if not ok or not data.AssetID then return end
        emState.emoting = true
        emState.spd = hum.WalkSpeed; emState.jump = hum.JumpPower
        hum.WalkSpeed = 0; hum.JumpPower = 0; root.Anchored = true
        local an = Instance.new("Animation"); an.AnimationId = tostring(data.AssetID)
        emState.track = anim:LoadAnimation(an); emState.track.Looped = true; emState.track:Play()
        if emState.rotConn then emState.rotConn:Disconnect() end
        emState.rotConn = svc.Run.RenderStepped:Connect(function()
            if not emState.emoting then return end
            local cam = workspace.CurrentCamera; if not cam then return end
            if cam.CameraType ~= Enum.CameraType.Custom then return end
            local ch2 = lp.Character; if not ch2 then return end
            local r2  = ch2:FindFirstChild("HumanoidRootPart"); if not r2 then return end
            if lp.CameraMode ~= Enum.CameraMode.LockFirstPerson then return end
            local _, camY, _ = cam.CFrame:ToEulerAnglesYXZ()
            r2.CFrame = CFrame.new(r2.Position) * CFrame.Angles(0, camY, 0)
        end)
        if data.SFX then
            local old2 = root:FindFirstChild("EmoteSound"); if old2 then old2:Destroy() end
            local snd = Instance.new("Sound"); snd.Name = "EmoteSound"
            snd.SoundId = tostring(data.SFX); snd.Volume = 1; snd.Looped = true
            snd.RollOffMode = Enum.RollOffMode.Inverse
            snd.RollOffMaxDistance = 60; snd.RollOffMinDistance = 10
            snd.Parent = root; snd:Play()
        end
        local att = Instance.new("Attachment"); att.Name = "RootAttachment"; att.Parent = root
        local burst = Instance.new("ParticleEmitter"); burst.Name = "EmoteBurst"
        burst.Texture = "rbxassetid://635533604"; burst.Rate = 60
        burst.Speed = NumberRange.new(2,5); burst.Lifetime = NumberRange.new(0.5,1.2)
        burst.Drag = 5; burst.Parent = att
        if string.lower(mod.Name) == "hakaridance" or string.lower(mod.Name) == "hakari" then
            local beamVFX = mod:FindFirstChild("HakariBeamEffect")
            if beamVFX then
                local v3 = beamVFX:Clone(); v3.Name = "PlayerEmoteVFX"
                v3.CFrame = root.CFrame * CFrame.new(0,-1,-0.3)
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = root; weld.Part1 = v3; weld.Parent = v3; v3.Parent = ch
            end
        end
        local remote = svc.RS:FindFirstChild("EmoteHandler") or svc.RS:FindFirstChild("PlayEmote") or svc.RS:FindFirstChild("Emote")
        if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer("PlayEmote", mod.Name) end) end
    end

    local function buildEmoteGui()
        if emState.sg and emState.sg.Parent then return end
        local PGui2 = lp:WaitForChild("PlayerGui")
        local old3 = PGui2:FindFirstChild("V1PR_EmoteGUI"); if old3 then old3:Destroy() end
        local SG2 = Instance.new("ScreenGui"); SG2.Name = "V1PR_EmoteGUI"
        SG2.ResetOnSpawn = false; SG2.IgnoreGuiInset = true
        SG2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG2.Parent = PGui2
        emState.sg = SG2
        local function rnd2(i,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=i end
        local function tw2(o,t,p) svc.TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
        local Tog2=Instance.new("TextButton"); Tog2.Size=UDim2.new(0,50,0,50); Tog2.Position=UDim2.new(1,-70,1,-70)
        Tog2.Text="🎵"; Tog2.TextSize=24; Tog2.BackgroundColor3=Color3.fromRGB(30,30,40)
        Tog2.AutoButtonColor=false; Tog2.BorderSizePixel=0; Tog2.ZIndex=20; Tog2.Parent=SG2; rnd2(Tog2,25)
        local togDragging=false; local togDragStart; local togStartPos; local togMoved=false
        Tog2.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                togDragging=true; togMoved=false
                togDragStart=inp.Position; togStartPos=Tog2.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then togDragging=false end
                end)
            end
        end)
        svc.Input.InputChanged:Connect(function(inp)
            if togDragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                local d=inp.Position-togDragStart
                if d.Magnitude > 4 then togMoved=true end
                Tog2.Position=UDim2.new(togStartPos.X.Scale,togStartPos.X.Offset+d.X,togStartPos.Y.Scale,togStartPos.Y.Offset+d.Y)
            end
        end)
        local PW,PH=220,340
        local Panel2=Instance.new("Frame"); Panel2.Size=UDim2.new(0,PW,0,PH)
        Panel2.Position=UDim2.new(0.5,-PW/2,0.5,-PH/2); Panel2.BackgroundColor3=Color3.fromRGB(16,16,22)
        Panel2.BorderSizePixel=0; Panel2.ClipsDescendants=true; Panel2.Visible=false; Panel2.ZIndex=15; Panel2.Parent=SG2; rnd2(Panel2,10)
        local drag2,dInp2,dSt2,sSt2
        Panel2.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                drag2=true; dSt2=inp.Position; sSt2=Panel2.Position
                inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then drag2=false end end)
            end
        end)
        svc.Input.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dInp2=inp end
        end)
        svc.Input.InputChanged:Connect(function(inp)
            if inp==dInp2 and drag2 then
                local d=inp.Position-dSt2
                Panel2.Position=UDim2.new(sSt2.X.Scale,sSt2.X.Offset+d.X,sSt2.Y.Scale,sSt2.Y.Offset+d.Y)
            end
        end)
        local Ac2=Instance.new("Frame"); Ac2.Size=UDim2.new(1,0,0,2); Ac2.BackgroundColor3=Color3.fromRGB(80,140,255); Ac2.BorderSizePixel=0; Ac2.Parent=Panel2
        local Hdr2=Instance.new("Frame"); Hdr2.Size=UDim2.new(1,0,0,34); Hdr2.Position=UDim2.new(0,0,0,2); Hdr2.BackgroundTransparency=1; Hdr2.Parent=Panel2
        local HTit2=Instance.new("TextLabel"); HTit2.Size=UDim2.new(1,-36,1,0); HTit2.Position=UDim2.new(0,10,0,0)
        HTit2.Text="Emotes"; HTit2.TextSize=14; HTit2.Font=Enum.Font.GothamBold
        HTit2.TextColor3=Color3.fromRGB(220,220,235); HTit2.BackgroundTransparency=1
        HTit2.TextXAlignment=Enum.TextXAlignment.Left; HTit2.Parent=Hdr2
        local CX2=Instance.new("TextButton"); CX2.Size=UDim2.new(0,26,0,26); CX2.Position=UDim2.new(1,-30,0,4)
        CX2.Text="✕"; CX2.TextSize=12; CX2.Font=Enum.Font.GothamBold
        CX2.TextColor3=Color3.fromRGB(140,140,160); CX2.BackgroundColor3=Color3.fromRGB(30,30,42)
        CX2.AutoButtonColor=false; CX2.BorderSizePixel=0; CX2.Parent=Hdr2; rnd2(CX2,6)
        local Srch2=Instance.new("TextBox"); Srch2.Size=UDim2.new(1,-12,0,28); Srch2.Position=UDim2.new(0,6,0,38)
        Srch2.PlaceholderText="Search..."; Srch2.Text=""
        Srch2.TextColor3=Color3.fromRGB(210,210,225); Srch2.PlaceholderColor3=Color3.fromRGB(90,90,110)
        Srch2.TextSize=12; Srch2.Font=Enum.Font.Gotham; Srch2.BackgroundColor3=Color3.fromRGB(24,24,34)
        Srch2.BorderSizePixel=0; Srch2.ClearTextOnFocus=false; Srch2.Parent=Panel2; rnd2(Srch2,6)
        do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8); p.Parent=Srch2 end
        local Scrl2=Instance.new("ScrollingFrame"); Scrl2.Size=UDim2.new(1,-8,1,-106); Scrl2.Position=UDim2.new(0,4,0,72)
        Scrl2.BackgroundTransparency=1; Scrl2.BorderSizePixel=0; Scrl2.CanvasSize=UDim2.new(0,0,0,0)
        Scrl2.ScrollBarThickness=3; Scrl2.ScrollBarImageColor3=Color3.fromRGB(80,140,255)
        Scrl2.ScrollBarImageTransparency=0.5; Scrl2.ScrollingDirection=Enum.ScrollingDirection.Y; Scrl2.Parent=Panel2
        local LL3=Instance.new("UIListLayout"); LL3.SortOrder=Enum.SortOrder.LayoutOrder; LL3.Padding=UDim.new(0,2); LL3.Parent=Scrl2
        LL3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scrl2.CanvasSize=UDim2.new(0,0,0,LL3.AbsoluteContentSize.Y+6)
        end)
        local Dv2=Instance.new("Frame"); Dv2.Size=UDim2.new(1,0,0,1); Dv2.Position=UDim2.new(0,0,1,-37)
        Dv2.BackgroundColor3=Color3.fromRGB(36,36,50); Dv2.BorderSizePixel=0; Dv2.Parent=Panel2
        local Stp2=Instance.new("TextButton"); Stp2.Size=UDim2.new(1,0,0,36); Stp2.Position=UDim2.new(0,0,1,-36)
        Stp2.Text="■  Stop Emote"; Stp2.TextSize=12; Stp2.Font=Enum.Font.GothamBold
        Stp2.TextColor3=Color3.fromRGB(255,100,100); Stp2.BackgroundColor3=Color3.fromRGB(22,14,14)
        Stp2.AutoButtonColor=false; Stp2.BorderSizePixel=0; Stp2.Parent=Panel2
        Stp2.MouseEnter:Connect(function() tw2(Stp2,0.1,{BackgroundColor3=Color3.fromRGB(40,16,16)}) end)
        Stp2.MouseLeave:Connect(function() tw2(Stp2,0.1,{BackgroundColor3=Color3.fromRGB(22,14,14)}) end)
        Stp2.MouseButton1Click:Connect(function() emStop() end)
        local rows2={}
        local function refreshList2(q)
            for _,r in ipairs(rows2) do pcall(function() r:Destroy() end) end; rows2={}
            q=q and string.lower(q) or ""
            if not EmFolderPath then return end
            local emotes={}
            for _,v in ipairs(EmFolderPath:GetDescendants()) do if v:IsA("ModuleScript") then table.insert(emotes,v) end end
            table.sort(emotes,function(a,b) return a.Name<b.Name end)
            local n=0
            for _,ch in ipairs(emotes) do
                if q=="" or string.find(string.lower(ch.Name),q,1,true) then
                    n+=1
                    local row=Instance.new("TextButton"); row.Size=UDim2.new(1,0,0,28)
                    row.Text=ch.Name; row.TextColor3=Color3.fromRGB(200,200,215)
                    row.TextSize=11; row.Font=Enum.Font.Gotham; row.TextXAlignment=Enum.TextXAlignment.Left
                    row.BackgroundColor3=Color3.fromRGB(22,22,32); row.BackgroundTransparency=0
                    row.AutoButtonColor=false; row.BorderSizePixel=0; row.LayoutOrder=n; row.Parent=Scrl2; rnd2(row,4)
                    do local p=Instance.new("UIPadding"); p.PaddingLeft=UDim.new(0,8); p.Parent=row end
                    row.MouseEnter:Connect(function()     tw2(row,0.08,{BackgroundColor3=Color3.fromRGB(38,38,56)}) end)
                    row.MouseLeave:Connect(function()     tw2(row,0.08,{BackgroundColor3=Color3.fromRGB(22,22,32)}) end)
                    row.MouseButton1Down:Connect(function() tw2(row,0.05,{BackgroundColor3=Color3.fromRGB(50,80,160)}) end)
                    row.MouseButton1Click:Connect(function() emPlay(ch) end)
                    table.insert(rows2,row)
                end
            end
            if n==0 then
                local e=Instance.new("TextLabel"); e.Size=UDim2.new(1,0,0,28); e.Text="None found"
                e.TextColor3=Color3.fromRGB(90,90,110); e.TextSize=11; e.Font=Enum.Font.Gotham
                e.BackgroundTransparency=1; e.TextXAlignment=Enum.TextXAlignment.Center; e.Parent=Scrl2
                table.insert(rows2,e)
            end
        end
        Srch2:GetPropertyChangedSignal("Text"):Connect(function() refreshList2(Srch2.Text) end)
        local pOpen2=false
        local function setPanel2(open)
            pOpen2=open; Tog2.Text=open and "✕" or "🎵"; Panel2.Visible=open
            if open then refreshList2(Srch2.Text) end
        end
        Tog2.MouseButton1Click:Connect(function() if not togMoved then setPanel2(not pOpen2) end; togMoved=false end)
        CX2.MouseButton1Click:Connect(function() setPanel2(false) end)
    end

    local function destroyEmoteGui()
        emStop()
        if emState.sg then emState.sg:Destroy(); emState.sg=nil end
    end

    secEmotes:Toggle({
        Title="Show Emotes GUI", Type="Checkbox", Flag="emoteGuiOn", Default=false,
        Callback=function(on) pcall(function()
            emState.guiOn=on
            if on then buildEmoteGui() else destroyEmoteGui() end
        end) end
    })

    lp.CharacterAdded:Connect(function() task.wait(0.5); if emState.emoting then emStop() end end)
    lp.CharacterRemoving:Connect(function() if emState.emoting then emStop() end end)
end


-- ============================================================
-- GLOBAL TAB
-- ============================================================

end -- tabSettings
do -- tabGlobal
local tabGlobal  = win:Tab({ Title = "Global", Icon = "globe" })

-- Stamina
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

-- Cached module + original Init for restore
local _stamMod = nil
local _stamOrigInit = nil

local function stamModule()
    if _stamMod then return _stamMod end
    local ok, m = pcall(function() return require(svc.RS.Systems.Character.Game.Sprinting) end)
    if ok and m then _stamMod = m; _stamOrigInit = m.Init end
    return ok and m or nil
end

local function stamIsKiller()
    local ch = lp.Character; if not ch then return false end
    local kf = getTeamFolder("Killers")
    return kf and ch:IsDescendantOf(kf)
end

-- Patch Init so any internal re-init can't re-enable stamina loss
local function stamPatchInit(m)
    if not m then return end
    m.Init = function(...)
        local res = (_stamOrigInit or function() end)(...)
        m.StaminaLossDisabled = true
        return res
    end
end

local function stamUnpatchInit(m)
    if not m or not _stamOrigInit then return end
    m.Init = _stamOrigInit
end

local function stamApply()
    pcall(function()
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
        if forceNoLoss then stamPatchInit(m) else stamUnpatchInit(m) end
        if m.Stamina and m.Stamina > stam.max then m.Stamina = stam.current end
        pcall(function() if m.__staminaChangedEvent then m.__staminaChangedEvent:Fire() end end)
    end)
end

local function stamStart()
    if stam.thread then return end
    stam.thread = task.spawn(function()
        while stam.on do
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then stamApply() end
            end)
            task.wait(0.5)
        end; stam.thread = nil
    end)
end

local function stamStop()
    stam.on = false
    if stam.thread then task.cancel(stam.thread); stam.thread = nil end
end

secStamina:Toggle({ Title = "Custom Stamina", Type = "Checkbox", Flag = "stamOn", Default = stam.on,
    Callback = function(on) pcall(function() if stam then stam.on = on; if on then stamStart() else stamStop() end end end) end })

secStamina:Slider({ Title = "Loss Rate",     Flag = "stamLoss", Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.loss    }, Callback = function(v) pcall(function() stam.loss = v end) end })
secStamina:Slider({ Title = "Gain Rate",     Flag = "stamGain", Step = 1, Value = { Min = 0,  Max = 50,  Default = stam.gain    }, Callback = function(v) pcall(function() stam.gain = v end) end })
secStamina:Slider({ Title = "Max Pool",      Flag = "stamMax", Step = 1, Value = { Min = 50, Max = 500, Default = stam.max     }, Callback = function(v) pcall(function() stam.max = v end) end })
secStamina:Slider({ Title = "Current Value", Flag = "stamCurrent", Step = 1, Value = { Min = 0,  Max = 500, Default = stam.current }, Callback = function(v) pcall(function() stam.current = v end) end })
secStamina:Toggle({ Title = "Infinite Stamina", Type = "Checkbox", Flag = "stamNoLoss", Default = stam.noLoss,
    Callback = function(on)
        pcall(function()
            stam.noLoss = on
            local m = stamModule()
            if m then
                m.StaminaLossDisabled = on
                if on then
                    stamPatchInit(m)
                else
                    stamUnpatchInit(m)
                end
            end
            stamApply()
        end)
    end
})

-- Auto-enable infinite stamina on load using goku hub method
pcall(function()
    local m = stamModule()
    if m then
        m.StaminaLossDisabled = true
        stamPatchInit(m)
    end
end)

if stam.on then stamStart() end

lp.CharacterAdded:Connect(function()
    task.delay(1.5, function()
        pcall(function()
            if stam.on then stamApply(); if not stam.thread then stamStart() end end
        end)
    end)
end)

-- Speed Hack
local secSpeed = tabGlobal:Section({ Title = "Speed Hack", Opened = true })
local speedHack = { on=false, speed=30, thread=nil, lastApplied=0 }

local function speedModule()
    local ok, m = pcall(function() return require(svc.RS.Systems.Character.Game.Sprinting) end)
    return ok and m or nil
end

local function speedApply()
    pcall(function()
        if not speedHack.on then return end
        local m = speedModule(); if not m then return end
        if not m.DefaultsSet then pcall(function() m.Init() end) end
        if speedHack.speed ~= speedHack.lastApplied then
            m.SprintSpeed = speedHack.speed; pcall(function() m.MaxSprintSpeed = speedHack.speed end)
            speedHack.lastApplied = speedHack.speed
        end
    end)
end

local function speedStart()
    if speedHack.thread then return end
    speedHack.thread = task.spawn(function()
        while speedHack.on do
            pcall(function()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then speedApply() end
            end)
            task.wait(0.2)
        end; speedHack.thread = nil
    end)
end

local function speedStop()
    speedHack.on = false
    if speedHack.thread then task.cancel(speedHack.thread); speedHack.thread = nil end
    pcall(function()
        local m = speedModule(); if m then m.SprintSpeed = 26; pcall(function() m.MaxSprintSpeed = 26 end) end
    end)
end

lp.CharacterAdded:Connect(function()
    task.delay(1, function() pcall(function() speedHack.lastApplied=0; if speedHack.on then speedApply(); if not speedHack.thread then speedStart() end end end) end)
end)

if speedHack.on then speedStart() end

secSpeed:Toggle({ Title="Custom Sprint Speed", Type="Checkbox", Flag="speedOn", Default=speedHack.on,
    Callback=function(on) pcall(function() if speedHack then speedHack.on=on; speedHack.lastApplied=0; if on then speedStart() else speedStop() end end end) end })

secSpeed:Input({ Title="Sprint Speed Value", Flag="speedValue", CurrentValue=tostring(speedHack.speed), Placeholder="e.g. 30",
    Callback=function(t) pcall(function() local n=tonumber(t); if n and n>0 and n<=200 then speedHack.speed=n; speedHack.lastApplied=0 end end) end })

-- Status Effects
local secStatus = tabGlobal:Section({ Title = "Status", Opened = true })

local statusGroups = {
    Slowness      = { on = false, paths = { "Modules.Schematics.StatusEffects.Slowness" } },
    Hallucination = { on = false, paths = { "Modules.Schematics.StatusEffects.KillerExclusive.Hallucination" } },
    Visual        = { on = false, paths = {
        "Modules.Schematics.StatusEffects.Blindness",
        "Modules.Schematics.StatusEffects.SurvivorExclusive.Subspaced",
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
    pcall(function()
        if statusBackup[path] then return end
        local mod = statusResolve(path); if not mod then return end
        if mod:IsA("Folder") then
            statusBackup[path] = { clone = mod:Clone(), isFolder = true, parentPath = path:match("^(.-)%.?[^%.]+$") }
            mod:Destroy()
        elseif mod:IsA("ModuleScript") or mod:IsA("LocalScript") then
            statusBackup[path] = { clone = mod:Clone(), src = mod.Source, isFolder = false }
            mod:Destroy()
        end
    end)
end

local function statusRestore(path)
    pcall(function()
        local saved = statusBackup[path]; if not saved then return end
        local existing = statusResolve(path); if existing then existing:Destroy() end
        local parentPath = saved.parentPath or path:match("^(.-)%.?[^%.]+$")
        local parent = statusResolve(parentPath)
        if parent then
            if not saved.isFolder then saved.clone.Source = saved.src end
            saved.clone.Parent = parent
        end
        statusBackup[path] = nil
    end)
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
    pcall(function()
        local g = statusGroups[name]; if not g then return end; g.on = not g.on
        for _, p in ipairs(g.paths) do if g.on then statusBlock(p) else statusRestore(p) end end
        local any = false; for _, sg in pairs(statusGroups) do if sg.on then any = true; break end end
        if any then statusTick() elseif statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
    end)
end

secStatus:Toggle({ Title = "Disable Slowness",       Default = false, Callback = function(v) if v then statusToggle("Slowness") end end })
secStatus:Toggle({ Title = "Disable Hallucination",  Default = false, Callback = function(v) if v then statusToggle("Hallucination") end end })
secStatus:Toggle({ Title = "Disable Visual Effects", Default = false, Callback = function(v) if v then statusToggle("Visual") end end })

lp.CharacterAdded:Connect(function()
    pcall(function()
        statusBackup = {}; for _, g in pairs(statusGroups) do g.on = false end
        if statusLoopThread then task.cancel(statusLoopThread); statusLoopThread = nil end
    end)
end)

-- Hitbox Expander
local secHitbox = tabGlobal:Section({ Title = "Hitbox", Opened = true })
local hb = { on = false, strength = 50, conn = nil, active = {} }

local hbAbilities = {
    Slash=1,Swing=1,Dagger=1,Punch=1,PlasmaBeam=1,Shoot=1,Behead=1,
    GashingWound=1,WalkspeedOverride=1,Stab=1,Nova=1,MassInfection=1,
    Axe=1,["INFERNALCRY"]=1,["Carving Slash"]=1,Carving=1,
}

local function hbReadName(raw)
    if typeof(raw) == "buffer" then
        local s = buffer.tostring(raw)
        local name = s:match("^[%c%z%p]*(.+)$") or s
        name = name:match("^(.-)%s*$") or name
        return name ~= "" and name or nil
    end
    return tostring(raw):gsub("\"","")
end

local function hbPush(dist)
    pcall(function()
        local ch = lp.Character; if not ch then return end
        local r  = ch:FindFirstChild("HumanoidRootPart"); if not r then return end
        local was = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = was + r.CFrame.LookVector * dist
        svc.Run.RenderStepped:Wait()
        if ch and ch.Parent and r and r.Parent then r.AssemblyLinearVelocity = was end
    end)
end

local function hbStart()
    pcall(function()
        if hb.conn then return end
        local remote = hbGetRemote()
        if not remote then warn("[betrayalhub] hbStart: could not find RemoteEvent for hitbox — feature disabled"); return end
        hb.conn = remote.OnClientEvent:Connect(function(action, data)
            if not hb.on or action ~= "UseActorAbility" then return end
            if typeof(data) ~= "table" or not data[1] then return end
            local name = hbReadName(data[1])
            if not name or not hbAbilities[name] or hb.active[name] then return end
            hb.active[name] = true; local t0 = tick()
            local c; c = svc.Run.Heartbeat:Connect(function()
                if tick() - t0 >= 1 then c:Disconnect(); hb.active[name] = nil; return end
                if hb.on then hbPush(hb.strength) else c:Disconnect(); hb.active[name] = nil end
            end)
        end)
    end)
end

local function hbStop()
    pcall(function()
        if hb.conn then hb.conn:Disconnect(); hb.conn = nil end
        for k in pairs(hb.active) do hb.active[k] = nil end
    end)
end

secHitbox:Toggle({ Title = "Hitbox Expander", Type = "Checkbox", Flag = "hbOn", Default = hb.on,
    Callback = function(on) pcall(function() if hb then hb.on = on; if on then hbStart() else hbStop() end end end) end })

secHitbox:Slider({ Title = "Strength", Flag = "hbStrength", Step = 1, Value = { Min = 5, Max = 100, Default = hb.strength },
    Callback = function(v) pcall(function() hb.strength = v end) end })

lp.CharacterAdded:Connect(function()
    pcall(function()
        for k in pairs(hb.active) do hb.active[k] = nil end
        task.delay(1, function() if hb.on then hbStop(); hbStart() end end)
    end)
end)

lp.CharacterRemoving:Connect(function() pcall(function() for k in pairs(hb.active) do hb.active[k] = nil end end) end)

-- Auto Collision
local ac = {
    on         = false,
    strength   = 50,
    maxDist    = 100,
    active     = {},
    chaseTarget  = nil,
    damageTarget = nil,
}

local function acGetHRP(model)
    if not model or not model.Parent then return nil end
    local h = model:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    local r = model:FindFirstChild("HumanoidRootPart")
    return r and r.Parent and r or nil
end

local function acFindChaseTarget()
    local sf = getTeamFolder("Survivors"); if not sf then return nil end
    for _, model in ipairs(sf:GetChildren()) do
        if model ~= lp.Character and model:IsA("Model") then
            local chased = model:GetAttribute("IsChased") or model:GetAttribute("InChase")
                        or model:GetAttribute("ChasedBy") or model:GetAttribute("IsBeingChased")
            if chased and chased ~= false and chased ~= "" then
                local r = acGetHRP(model); if r then return r end
            end
        end
    end
    return nil
end

local function acPickTarget()
    if ac.chaseTarget and ac.chaseTarget.Parent then
        local model = ac.chaseTarget.Parent
        local h = model:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then
            local chased = model:GetAttribute("IsChased") or model:GetAttribute("InChase")
                        or model:GetAttribute("ChasedBy") or model:GetAttribute("IsBeingChased")
            if chased and chased ~= false and chased ~= "" then return ac.chaseTarget end
        end
        ac.chaseTarget = nil
    end
    local fresh = acFindChaseTarget()
    if fresh then ac.chaseTarget = fresh; return fresh end
    if ac.damageTarget and ac.damageTarget.Parent then
        local model = ac.damageTarget.Parent
        local h = model:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return ac.damageTarget end
        ac.damageTarget = nil
    end
    local sf = getTeamFolder("Survivors"); local myChar = lp.Character
    if not sf or not myChar then return nil end
    local origin = myChar:FindFirstChild("QueryHitbox", true) or myChar:FindFirstChild("HumanoidRootPart")
    if not origin then return nil end
    local myPos = origin.Position
    local best, bd = nil, math.huge
    for _, model in ipairs(sf:GetChildren()) do
        if model ~= myChar and model:IsA("Model") then
            local r = acGetHRP(model)
            if r then local d = (r.Position - myPos).Magnitude; if d < bd and d <= ac.maxDist then bd = d; best = r end end
        end
    end
    return best
end

local function acPickKillerTarget()
    local kf = getTeamFolder("Killers"); local myChar = lp.Character
    if not kf or not myChar then return nil end
    local origin = myChar:FindFirstChild("HumanoidRootPart"); if not origin then return nil end
    local myPos = origin.Position
    local best, bd = nil, math.huge
    for _, model in ipairs(kf:GetChildren()) do
        if model ~= myChar and model:IsA("Model") then
            local r = acGetHRP(model)
            if r then local d = (r.Position - myPos).Magnitude; if d < bd and d <= ac.maxDist then bd = d; best = r end end
        end
    end
    return best
end

local function acPush(targetRoot, facingOverrideCFrame)
    pcall(function()
        if not targetRoot or not targetRoot.Parent then return end
        local myChar = lp.Character; if not myChar then return end
        local hrp = myChar:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local dir = (targetRoot.Position - hrp.Position)
        if dir.Magnitude < 0.1 then return end
        dir = dir.Unit
        local lookDir
        if facingOverrideCFrame then
            lookDir = facingOverrideCFrame.LookVector * Vector3.new(1, 0, 1)
        else
            lookDir = dir * Vector3.new(1, 0, 1)
        end
        if lookDir.Magnitude > 0.01 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir.Unit)
        end
        local was = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = was + dir * ac.strength
        svc.Run.RenderStepped:Wait()
        if myChar and myChar.Parent and hrp and hrp.Parent then hrp.AssemblyLinearVelocity = was end
    end)
end

local acAttrConns = {}

local function acWatchModel(model)
    pcall(function()
        if acAttrConns[model] then return end
        acAttrConns[model] = model.AttributeChanged:Connect(function(attr)
            if attr ~= "IsChased" and attr ~= "InChase" and attr ~= "ChasedBy" and attr ~= "IsBeingChased" then return end
            local chased = model:GetAttribute(attr)
            if chased and chased ~= false and chased ~= "" then
                local r = acGetHRP(model); if r then ac.chaseTarget = r end
            else
                if ac.chaseTarget and ac.chaseTarget.Parent == model then ac.chaseTarget = nil end
            end
        end)
    end)
end

local function acStopWatchModel(model)
    pcall(function()
        if acAttrConns[model] then pcall(function() acAttrConns[model]:Disconnect() end); acAttrConns[model] = nil end
    end)
end

local function acSetupWatchers()
    pcall(function()
        local sf = getTeamFolder("Survivors"); if not sf then return end
        for _, model in ipairs(sf:GetChildren()) do if model:IsA("Model") then acWatchModel(model) end end
        sf.ChildAdded:Connect(function(child) if child:IsA("Model") then task.wait(0.1); acWatchModel(child) end end)
        sf.ChildRemoved:Connect(function(child)
            acStopWatchModel(child)
            if ac.chaseTarget  and ac.chaseTarget.Parent  == child then ac.chaseTarget  = nil end
            if ac.damageTarget and ac.damageTarget.Parent == child then ac.damageTarget = nil end
        end)
    end)
end

task.spawn(function()
    pcall(function()
        local remote = hbGetRemote()
        if not remote then warn("[betrayalhub] AutoCollision: could not find RemoteEvent — feature disabled"); return end
        task.spawn(acSetupWatchers)
        remote.OnClientEvent:Connect(function(action, data)
            if not ac.on then return end
            if action ~= "UseActorAbility" then return end
            if typeof(data) ~= "table" or not data[1] then return end
            local name = hbReadName(data[1])
            if not name or not hbAbilities[name] then return end
            if ac.active[name] then return end
            local myChar = lp.Character
            local killerFolder   = getTeamFolder("Killers")
            local survivorFolder = getTeamFolder("Survivors")
            local amKiller   = killerFolder   and myChar and myChar:IsDescendantOf(killerFolder)
            local amSurvivor = survivorFolder and myChar and myChar:IsDescendantOf(survivorFolder)
            if amKiller and data[2] and typeof(data[2]) == "Instance" then
                local hrpTarget = nil
                if data[2]:IsA("Model") then
                    hrpTarget = data[2]:FindFirstChild("HumanoidRootPart")
                elseif data[2]:IsA("BasePart") then
                    local model = data[2]:FindFirstAncestorOfClass("Model")
                    if model then hrpTarget = model:FindFirstChild("HumanoidRootPart") end
                end
                if hrpTarget and hrpTarget.Parent then
                    local sf = getTeamFolder("Survivors")
                    if sf and hrpTarget.Parent:IsDescendantOf(sf) then
                        local h = hrpTarget.Parent:FindFirstChildOfClass("Humanoid")
                        if h and h.Health > 0 then ac.damageTarget = hrpTarget end
                    end
                end
            end
            ac.active[name] = true
            local t0 = tick()
            local conn; conn = svc.Run.Heartbeat:Connect(function()
                if tick() - t0 >= 1 or not ac.on then conn:Disconnect(); ac.active[name] = nil; return end
                local target
                local facingOverride = nil
                if amKiller then
                    target = acPickTarget()
                elseif amSurvivor then
                    target = acPickKillerTarget()
                    if target and target.Parent and target.Parent.Name == "TwoTime" and name == "Stab" then
                        facingOverride = target.CFrame
                    end
                end
                if target then task.spawn(acPush, target, facingOverride) end
            end)
        end)
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if ac.on then local fresh = acFindChaseTarget(); if fresh then ac.chaseTarget = fresh end end
        end)
    end
end)

lp.CharacterAdded:Connect(function()
    pcall(function()
        for k in pairs(ac.active) do ac.active[k] = nil end
        ac.chaseTarget = nil; ac.damageTarget = nil
    end)
end)

lp.CharacterRemoving:Connect(function()
    pcall(function()
        for k in pairs(ac.active) do ac.active[k] = nil end
        ac.chaseTarget = nil; ac.damageTarget = nil
    end)
end)

local secAutoCollision = tabGlobal:Section({ Title = "Auto Collision", Opened = true })

secAutoCollision:Toggle({
    Title = "Push Hitbox on Ability", Type = "Checkbox", Flag = "acOn", Default = ac.on,
    Callback = function(on)
        pcall(function()
            if ac then ac.on = on; 
            if not on then for k in pairs(ac.active) do ac.active[k] = nil end; ac.chaseTarget = nil; ac.damageTarget = nil end end
        end)
    end
})

secAutoCollision:Slider({ Title = "Push Strength", Flag = "acStrength", Step = 1, Value = { Min = 5,  Max = 100, Default = ac.strength }, Callback = function(v) pcall(function() ac.strength = v end) end })
secAutoCollision:Slider({ Title = "Max Distance",  Flag = "acMaxDist", Step = 5, Value = { Min = 20, Max = 200, Default = ac.maxDist  }, Callback = function(v) pcall(function() ac.maxDist = v end) end })

-- ============================================================
-- GENERATOR TAB
-- ============================================================

end -- tabGlobal
do -- tabGen
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
    for _, ep in ipairs(endpoints or {}) do
        for _, n in ipairs(path) do
            if n.row == ep.row and n.col == ep.col then start = { row = ep.row, col = ep.col }; break end
        end
        if start then break end
    end
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
    table.insert(ordered, { row = cur.row, col = cur.col }); pool[flowKey(cur)] = nil
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
    pcall(function()
        if not puzzle or not puzzle.Solution then return end
        local indices = {}
        for i = 1, #puzzle.Solution do indices[i] = i end
        for i = #indices, 2, -1 do local j = math.random(1, i); indices[i], indices[j] = indices[j], indices[i] end
        for _, ci in ipairs(indices) do
            local solution = puzzle.Solution[ci]; if not solution then continue end
            local ordered = flowOrder(solution, puzzle.targetPairs[ci])
            if not ordered or #ordered == 0 then continue end
            puzzle.paths[ci] = {}
            for _, node in ipairs(ordered) do
                table.insert(puzzle.paths[ci], { row = node.row, col = node.col })
                puzzle:updateGui(); task.wait(flow.nodeDelay)
            end
            task.wait(flow.lineDelay); puzzle:checkForWin()
        end
    end)
end

do
    pcall(function()
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
                    if flow.on then task.spawn(function() task.wait(0.3); flowSolve(p) end) end
                    return p
                end
            else warn("[betrayalhub] FlowGame: failed to require FlowGame module — auto-solve disabled") end
        else warn("[betrayalhub] FlowGame: FlowGame not found — auto-solve disabled") end
    end)
end

secGenAuto:Toggle({ Title = "Auto Solve", Type = "Checkbox", Flag = "flowOn", Default = flow.on, Callback = function(on) pcall(function() if flow then flow.on = on end end) end })
secGenAuto:Slider({ Title = "Node Speed", Flag = "flowNodeDelay", Step = 0.02, Value = { Min = 0.01, Max = 0.50, Default = flow.nodeDelay }, Callback = function(v) pcall(function() flow.nodeDelay = v end) end })
secGenAuto:Slider({ Title = "Line Pause", Flag = "flowLineDelay", Step = 0.10, Value = { Min = 0.00, Max = 1.00, Default = flow.lineDelay }, Callback = function(v) pcall(function() flow.lineDelay = v end) end })

end -- tabGen

-- ============================================================
-- AIMBOT TAB
-- ============================================================


do -- tabESP
local tabESP = win:Tab({ Title = "ESP", Icon = "eye" })

local esp = {
    enabled = true,
    highlights = {}, billboards = {}, connections = {}, healthConnections = {},
    hlMonitorConns = {},
    scanThread = nil,
    showKillers = true, showSurvivors = true, showGenerators = true,
    showItems = true, showStructures = true,
    maxDistance = 200, transparency = 0.5,
    scanRate = 1.0,
    cachedItems = {}, cachedStructures = {},
    itemCacheTime = 0, structCacheTime = 0, cacheLife = 5,
}

-- Groundbulb & Vine ESP initialization (moved to top to prevent nil error)
local gvEsp = {
    on = false,
    showGroundbulb = true,
    showVine = true,
    scanInterval = 0.5,
    trackedEntities = {},
}

-- Generator label system
local genLabels = {}
local genConns  = {}

local function genGetProgress(obj)
    if not obj or not obj.Parent then return 0 end
    local pv = obj:FindFirstChild("Progress")
    if pv and (pv:IsA("NumberValue") or pv:IsA("IntValue")) then return pv.Value end
    local av = obj:GetAttribute("Progress") or obj:GetAttribute("Charge")
    if type(av) == "number" then return av end
    return 0
end

local function genBuildText(progress)
    if progress >= 100 then
        return "Generator  ✓ DONE  (100%)", Color3.fromRGB(100, 255, 100)
    end
    local puzzles = math.floor(progress / 25)
    return string.format("Generator  %d/4  (%d%%)", puzzles, puzzles * 25),
           Color3.fromRGB(255, 200, 50)
end

local function genUpdateLabel(obj)
    if not obj or not obj.Parent then return end
    local label = genLabels[obj]
    if not label then
        local bb = obj:FindFirstChildWhichIsA("BillboardGui")
        if bb then label = bb:FindFirstChildWhichIsA("TextLabel") end
        if label then genLabels[obj] = label else return end
    end
    if not label.Parent then genLabels[obj] = nil; return end
    local txt, col = genBuildText(genGetProgress(obj))
    label.Text = txt; label.TextColor3 = col
    label.TextSize = 9; label.TextStrokeTransparency = 0.2; label.Visible = true
end

local function genDisconnectObj(obj)
    local conns = genConns[obj]
    if conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        genConns[obj] = nil
    end
end

local function genRemoveObj(obj)
    genDisconnectObj(obj)
    genLabels[obj] = nil
end

local function genWatchGenerator(obj)
    if not obj then return end
    genDisconnectObj(obj)
    local conns = {}
    local pv = obj:FindFirstChild("Progress")
    if pv and (pv:IsA("NumberValue") or pv:IsA("IntValue")) then
        table.insert(conns, pv:GetPropertyChangedSignal("Value"):Connect(function()
            pcall(genUpdateLabel, obj)
        end))
    end
    table.insert(conns, obj.ChildAdded:Connect(function(child)
        if child.Name == "Progress" and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            table.insert(conns, child:GetPropertyChangedSignal("Value"):Connect(function()
                pcall(genUpdateLabel, obj)
            end))
            pcall(genUpdateLabel, obj)
        end
    end))
    table.insert(conns, obj.AttributeChanged:Connect(function(attr)
        if attr == "Progress" or attr == "Charge" then pcall(genUpdateLabel, obj) end
    end))
    genConns[obj] = conns
    pcall(genUpdateLabel, obj)
end

local function genSetupGenerator(obj, label)
    if not obj or not label then return end
    genLabels[obj] = label
    local bb = label.Parent
    if bb and bb:IsA("BillboardGui") then
        bb.Enabled = true; bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 200, 0, 18); bb.StudsOffset = Vector3.new(0, 4, 0)
    end
    local txt, col = genBuildText(genGetProgress(obj))
    label.Text = txt; label.TextColor3 = col
    label.TextSize = 9; label.TextStrokeTransparency = 0.2; label.Visible = true
    genWatchGenerator(obj)
end

local function genClearAll()
    pcall(function()
        for obj in pairs(genConns) do genDisconnectObj(obj) end
        genLabels = {}
        genConns  = {}
    end)
end

-- ESP COLORS
local COLORS = {
    Killer = Color3.fromRGB(255,50,50), Survivor = Color3.fromRGB(50,255,50),
    Generator = Color3.fromRGB(255,200,50), Item = Color3.fromRGB(50,200,255),
    Structure = Color3.fromRGB(255,150,50),
}

local function espGetTeamFolder(name)
    local root = svc.WS:FindFirstChild("Players")
    return root and root:FindFirstChild(name)
end

local function espGetIngame()
    local m = svc.WS:FindFirstChild("Map")
    return m and m:FindFirstChild("Ingame")
end

local function espGetMapContent()
    local ig = espGetIngame()
    return ig and ig:FindFirstChild("Map")
end

local function espClearAll()
    pcall(function()
        for obj, hl in pairs(esp.highlights) do pcall(function() hl:Destroy() end) end
        esp.highlights = {}
        for obj, bb in pairs(esp.billboards) do pcall(function() bb:Destroy() end) end
        esp.billboards = {}
        for obj, conn in pairs(esp.healthConnections) do pcall(function() conn:Disconnect() end) end
        esp.healthConnections = {}
        for _, conn in ipairs(esp.connections) do pcall(function() conn:Disconnect() end) end
        esp.connections = {}
        for _, conn in pairs(esp.hlMonitorConns) do pcall(function() conn:Disconnect() end) end
        esp.hlMonitorConns = {}
        genClearAll()
    end)
end

local function espMakeHighlight(obj, color)
    local hl = Instance.new("Highlight")
    hl.Name = "V1PR_Highlight"
    hl.FillColor = color
    hl.FillTransparency = esp.transparency
    hl.OutlineColor = color
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj
    return hl
end

local function espCreate(obj, color, labelText, isCharacter)
    pcall(function()
        if not obj or not obj.Parent or esp.highlights[obj] then return end
        local attach = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChildOfClass("BasePart")
        if not attach then return end

        local hl = espMakeHighlight(obj, color)
        local bb = Instance.new("BillboardGui")
        bb.Adornee = attach
        bb.Size = UDim2.new(0, 120, 0, 18)
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = esp.maxDistance
        bb.Parent = obj
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText or obj.Name
        label.TextColor3 = color
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0.3
        label.TextSize = 9
        label.Font = Enum.Font.GothamBold
        label.Parent = bb
        
        esp.highlights[obj] = hl
        esp.billboards[obj] = bb

        if esp.hlMonitorConns[obj] then
            pcall(function() esp.hlMonitorConns[obj]:Disconnect() end)
        end
        esp.hlMonitorConns[obj] = obj.ChildRemoved:Connect(function(child)
            if not esp.enabled or not obj.Parent then return end
            if child == esp.highlights[obj] or child.Name == "V1PR_Highlight" or child:IsA("Highlight") then
                task.defer(function()
                    if not esp.enabled or not obj.Parent or not esp.highlights[obj] then return end
                    local existing = obj:FindFirstChild("V1PR_Highlight")
                    if not existing then
                        local newHl = espMakeHighlight(obj, color)
                        esp.highlights[obj] = newHl
                    end
                end)
            end
        end)

        if labelText == "Generator" or (not isCharacter and obj.Name == "Generator") then
            genSetupGenerator(obj, label)
        end

        if isCharacter then
            local function updateLabel()
                if not obj or not obj.Parent then return end
                local name = labelText or obj.Name
                local distText = ""
                local hpText = ""
                local myChar = lp.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local a = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                    if a then distText = string.format("%.0f", (a.Position - myRoot.Position).Magnitude) end
                end
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then hpText = string.format("%d", math.floor(hum.Health)) end
                if distText ~= "" and hpText ~= "" then label.Text = string.format("%s (%s) %s HP", name, distText, hpText)
                elseif distText ~= "" then label.Text = string.format("%s (%s)", name, distText)
                elseif hpText ~= "" then label.Text = string.format("%s %s HP", name, hpText)
                else label.Text = name end
            end
            updateLabel()
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then esp.healthConnections[obj] = hum.HealthChanged:Connect(updateLabel) end
            table.insert(esp.connections, svc.Run.Heartbeat:Connect(function()
                if esp.enabled and obj and obj.Parent then pcall(updateLabel) end
            end))
        end

        table.insert(esp.connections, obj.AncestryChanged:Connect(function()
            if not obj.Parent then
                pcall(function()
                    if esp.highlights[obj] then esp.highlights[obj]:Destroy() end
                    if esp.billboards[obj] then esp.billboards[obj]:Destroy() end
                    if esp.healthConnections[obj] then esp.healthConnections[obj]:Disconnect() end
                    if esp.hlMonitorConns[obj] then esp.hlMonitorConns[obj]:Disconnect() end
                    genRemoveObj(obj)
                    esp.highlights[obj] = nil
                    esp.billboards[obj] = nil
                    esp.healthConnections[obj] = nil
                    esp.hlMonitorConns[obj] = nil
                end)
            end
        end))
    end)
end

-- ESP SCAN
local function espScan()
    pcall(function()
        if not esp.enabled or not lp then return end
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position or Vector3.new(0,0,0)
        local toRemove = {}
        for obj in pairs(esp.highlights) do if not obj or not obj.Parent then table.insert(toRemove, obj) end end
        for _, obj in ipairs(toRemove) do pcall(function()
            if esp.highlights[obj] then esp.highlights[obj]:Destroy() end
            if esp.billboards[obj] then esp.billboards[obj]:Destroy() end
            if esp.healthConnections[obj] then esp.healthConnections[obj]:Disconnect() end
            esp.highlights[obj] = nil
            esp.billboards[obj] = nil
            esp.healthConnections[obj] = nil
        end) end
        local processed = {}
        local function addESP(obj, objType, color, label)
            if not obj or not obj.Parent or processed[obj] or esp.highlights[obj] then return end
            processed[obj] = true
            local attach = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChildOfClass("BasePart")
            if not attach then return end
            if myRoot and (attach.Position - myPos).Magnitude > esp.maxDistance then return end
            espCreate(obj, color, label, objType == "Character")
        end
        if esp.showKillers then
            local kf = espGetTeamFolder("Killers")
            if kf then for _, m in ipairs(kf:GetChildren()) do if m:IsA("Model") and m ~= myChar then local h = m:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then addESP(m,"Character",COLORS.Killer,m.Name) end end end end
        end
        if esp.showSurvivors then
            local sf = espGetTeamFolder("Survivors")
            if sf then for _, m in ipairs(sf:GetChildren()) do if m:IsA("Model") and m ~= myChar then local h = m:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 then addESP(m,"Character",COLORS.Survivor,m.Name) end end end end
        end
        if esp.showGenerators then
            local mc = espGetMapContent()
            if mc then
                for _, o in ipairs(mc:GetChildren()) do
                    if o.Name == "Generator" and o.Parent then
                        addESP(o, "Object", COLORS.Generator, "Generator")
                    end
                end
            end
        end
        if esp.showItems then
            local now = tick()
            if now - esp.itemCacheTime > esp.cacheLife then
                esp.itemCacheTime = now
                esp.cachedItems = {}
                pcall(function()
                    for _, o in ipairs(svc.WS:GetDescendants()) do
                        if o.Name == "BloxyCola" or o.Name == "Medkit" then
                            table.insert(esp.cachedItems, o)
                        end
                    end
                end)
            end
            for _, o in ipairs(esp.cachedItems) do addESP(o,"Object",COLORS.Item,o.Name) end
        end
        if esp.showStructures then
            local now = tick()
            if now - esp.structCacheTime > esp.cacheLife then
                esp.structCacheTime = now
                esp.cachedStructures = {}
                pcall(function()
                    local ig = espGetIngame()
                    if ig then
                        for _, o in ipairs(ig:GetChildren()) do
                            if o.Name == "BuildermanSentry" or o.Name == "SubspaceTripmine" or o.Name == "BuildermanDispenser" then
                                table.insert(esp.cachedStructures, o)
                            end
                        end
                    end
                end)
            end
            for _, o in ipairs(esp.cachedStructures) do addESP(o,"Object",COLORS.Structure,o.Name) end
        end
    end)
end

local function espStart()
    pcall(function()
        espClearAll()
        esp.enabled = true
        if esp.scanThread then task.cancel(esp.scanThread) end
        esp.scanThread = task.spawn(function() while esp.enabled do pcall(espScan); task.wait(esp.scanRate) end end)
    end)
end

local function espStop()
    pcall(function()
        esp.enabled = false
        if esp.scanThread then task.cancel(esp.scanThread) end
        esp.scanThread = nil
        espClearAll()
    end)
end

local function espSetupListeners()
    pcall(function()
        if not lp then return end
        local function onTeamChild(child, team, color)
            task.wait(0.2)
            if esp.enabled and child:IsA("Model") and child ~= lp.Character then
                local h = child:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 and esp["show"..team] then espCreate(child, color, child.Name, true) end
            end
        end
        local kf = espGetTeamFolder("Killers")
        if kf then table.insert(esp.connections, kf.ChildAdded:Connect(function(c) onTeamChild(c,"Killers",COLORS.Killer) end)) end
        local sf = espGetTeamFolder("Survivors")
        if sf then table.insert(esp.connections, sf.ChildAdded:Connect(function(c) onTeamChild(c,"Survivors",COLORS.Survivor) end)) end
        table.insert(esp.connections, svc.WS.DescendantAdded:Connect(function(o)
            task.wait(0.1)
            if esp.enabled then
                if o.Name == "Generator" and esp.showGenerators then espCreate(o,COLORS.Generator,"Generator")
                elseif (o.Name == "BloxyCola" or o.Name == "Medkit") and esp.showItems then espCreate(o,COLORS.Item,o.Name)
                elseif esp.showStructures and (o.Name == "BuildermanSentry" or o.Name == "SubspaceTripmine" or o.Name == "BuildermanDispenser") then espCreate(o,COLORS.Structure,o.Name) end
            end
        end))
    end)
end

if lp then lp.CharacterAdded:Connect(function() task.wait(2); if esp.enabled then espClearAll(); espStart() end end) end

task.wait(2)
espSetupListeners()
if esp.enabled then espStart() end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            for obj, label in pairs(genLabels) do
                if obj and obj.Parent and label and label.Parent then
                    pcall(genUpdateLabel, obj)
                else
                    genRemoveObj(obj)
                end
            end
        end)
    end
end)

-- ESP UI
local mainSection = tabESP:Section({ Title = "Main Settings", Opened = true })

mainSection:Toggle({ Title="Enable ESP", Type="Checkbox", Flag="espEnabled", Default=esp.enabled,
    Callback=function(on) pcall(function() esp.enabled=on; if on then espStart() else espStop() end end) end })

local catSection = tabESP:Section({ Title = "Categories", Opened = true })

catSection:Toggle({ Title="Killers", Type="Checkbox", Flag="espKillers", Default=esp.showKillers,
    Callback=function(on) pcall(function() esp.showKillers=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Survivors", Type="Checkbox", Flag="espSurvivors", Default=esp.showSurvivors,
    Callback=function(on) pcall(function() esp.showSurvivors=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Generators", Type="Checkbox", Flag="espGenerators", Default=esp.showGenerators,
    Callback=function(on) pcall(function() esp.showGenerators=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Items", Type="Checkbox", Flag="espItems", Default=esp.showItems,
    Callback=function(on) pcall(function() esp.showItems=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Structures", Type="Checkbox", Flag="espStructures", Default=esp.showStructures,
    Callback=function(on) pcall(function() esp.showStructures=on; if esp.enabled then espClearAll(); espStart() end end) end })

catSection:Toggle({ Title="Groundbulb & Vine", Type="Checkbox", Flag="gvEspOn", Default=gvEsp.on,
    Callback=function(on)
        pcall(function()
            gvEsp.on = on
            if on then gvStartStandalone() else gvStopStandalone() end
        end)
    end })

local visSection = tabESP:Section({ Title = "Visual Settings", Opened = true })

visSection:Slider({ Title="Max Distance", Flag="espMaxDistance", Step=10, Value={Min=50,Max=500,Default=esp.maxDistance},
    Callback=function(v) pcall(function() esp.maxDistance=v; if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Slider({ Title="Highlight Opacity", Flag="espTransparency", Step=0.05, Value={Min=0.1,Max=1.0,Default=esp.transparency},
    Callback=function(v) pcall(function() esp.transparency=v; if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Slider({ Title="Scan Rate (s)", Flag="espScanRate", Step=0.5, Value={Min=0.5,Max=5.0,Default=esp.scanRate},
    Callback=function(v) pcall(function()
        esp.scanRate=v
        if esp.enabled and esp.scanThread then
            task.cancel(esp.scanThread)
            esp.scanThread = task.spawn(function() while esp.enabled do pcall(espScan); task.wait(esp.scanRate) end end)
        end
    end) end })

visSection:Button({ Title="Refresh ESP", Callback=function() pcall(function() if esp.enabled then espClearAll(); espStart() end end) end })

visSection:Button({ Title="Refresh Generator Labels", Callback=function()
    pcall(function()
        for obj in pairs(genLabels) do
            if obj and obj.Parent then genWatchGenerator(obj)
            else genRemoveObj(obj) end
        end
        local mc = espGetMapContent()
        if mc then
            for _, o in ipairs(mc:GetChildren()) do
                if o.Name == "Generator" and o.Parent then
                    if not genLabels[o] then
                        if esp.enabled and not esp.highlights[o] then
                            espCreate(o, COLORS.Generator, "Generator", false)
                        end
                    else
                        genWatchGenerator(o)
                    end
                end
            end
        end
    end)
end })

-- MINION ESP
local secMinion = tabESP:Section({ Title = "Minion & Ability ESP", Opened = true })

local mset = { pizza=false, zombie=false, puddle=false, transparency=0.25 }
local tracked = { pizza={}, zombie={}, puddle={} }

local function isRealPlayer(obj)
    for _, p in ipairs(svc.Players:GetPlayers()) do if p.Character == obj or (p.Character and obj:IsDescendantOf(p.Character)) then return true end end
    return false
end

local function addHighlight(obj, color, tag, label, offset)
    pcall(function()
        if not obj or tracked[tag][obj] or isRealPlayer(obj) then return end
        tracked[tag][obj] = true
        local root = obj
        if obj:IsA("Model") then 
            root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
            if not root then 
                for _, c in ipairs(obj:GetChildren()) do 
                    if c:IsA("BasePart") then 
                        root = c
                        break 
                    end 
                end 
            end
        end -- ⬅️ THIS END WAS MISSING
        
        local hl = Instance.new("Highlight")
        hl.Name = tag .. "_HL"
        hl.FillColor = color
        hl.FillTransparency = mset.transparency
        hl.OutlineColor = color
        hl.OutlineTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = obj
        hl.Parent = obj
        
        if root then
            local bb = Instance.new("BillboardGui")
            bb.Name = tag .. "_BB"
            bb.Adornee = root
            bb.Size = UDim2.new(0, 130, 0, 24)
            bb.StudsOffset = Vector3.new(0, offset or 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = obj
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = color
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            lbl.TextStrokeTransparency = 0.2
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamBold
            lbl.Parent = bb
        end
        
        obj.AncestryChanged:Connect(function() 
            if obj.Parent then return end
            local h2 = obj:FindFirstChild(tag .. "_HL")
            if h2 then h2:Destroy() end
            local b2 = obj:FindFirstChild(tag .. "_BB")
            if b2 then b2:Destroy() end
            tracked[tag][obj] = nil
        end)
    end)
end

local function updateTransparency()
    pcall(function()
        for tag, tbl in pairs(tracked) do for obj in pairs(tbl) do local h=obj:FindFirstChild(tag.."_HL"); if h then h.FillTransparency=mset.transparency end end end
    end)
end

local function clearTag(tag)
    pcall(function()
        for obj in pairs(tracked[tag]) do
            local h=obj:FindFirstChild(tag.."_HL"); if h then h:Destroy() end
            local b=obj:FindFirstChild(tag.."_BB"); if b then b:Destroy() end
            if tag=="puddle" then local h2=obj:FindFirstChild("PuddleHolder"); if h2 then h2:Destroy() end end
        end
        tracked[tag]={}
    end)
end

local function addPuddleHighlight(part, color, tag, label)
    pcall(function()
        if not part or tracked[tag][part] or isRealPlayer(part) then return end
        tracked[tag][part] = true
        local hl = Instance.new("Highlight"); hl.Name=tag.."_HL"; hl.FillColor=color; hl.FillTransparency=mset.transparency
        hl.OutlineColor=color; hl.OutlineTransparency=0.1; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee=part; hl.Parent=part
        task.wait(0.05)
        local radius = math.max(math.max(part.Size.X,part.Size.Z)*0.5,3)
        local holder = Instance.new("Part"); holder.Name="PuddleHolder"; holder.Size=Vector3.new(1,0.1,1)
        holder.Transparency=1; holder.CanCollide=false; holder.Anchored=true
        holder.Position=part.Position+Vector3.new(0,0.05,0); holder.Parent=part
        local bc = Instance.new("CylinderHandleAdornment"); bc.Name="PuddleBlack"; bc.Adornee=holder
        bc.Color3=Color3.fromRGB(0,0,0); bc.Transparency=0.2; bc.Radius=radius; bc.Height=0.02
        bc.CFrame=CFrame.Angles(math.rad(90),0,0); bc.ZIndex=5; bc.AlwaysOnTop=true; bc.Parent=holder
        local ro = Instance.new("CylinderHandleAdornment"); ro.Name="PuddleRed"; ro.Adornee=holder
        ro.Color3=Color3.fromRGB(255,0,0); ro.Transparency=0.4; ro.Radius=radius+0.8; ro.Height=0.02
        ro.CFrame=CFrame.Angles(math.rad(90),0,0); ro.ZIndex=4; ro.AlwaysOnTop=true; ro.Parent=holder
        local bb = Instance.new("BillboardGui"); bb.Name=tag.."_BB"; bb.Adornee=holder
        bb.Size=UDim2.new(0,140,0,20); bb.StudsOffset=Vector3.new(0,1.5,0); bb.AlwaysOnTop=true; bb.Parent=holder
        local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
        lbl.Text=label; lbl.TextColor3=Color3.fromRGB(255,255,255)
        lbl.TextStrokeColor3=Color3.fromRGB(255,0,0); lbl.TextStrokeTransparency=0.1
        lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.Parent=bb
        part:GetPropertyChangedSignal("Size"):Connect(function()
            if not part.Parent then return end
            local nr = math.max(math.max(part.Size.X,part.Size.Z)*0.5,3)
            bc.Radius=nr; ro.Radius=nr+0.8
        end)
        part.AncestryChanged:Connect(function()
            if part.Parent then return end
            hl:Destroy(); holder:Destroy(); tracked[tag][part]=nil
        end)
    end)
end

local function isJohnDoePuddle(o)
    if not o:IsA("BasePart") or o.Name ~= "Shadow" then return false end
    local p = o.Parent; return p and p.Name:find("Shadows$") ~= nil
end

local function scanPizza() pcall(function() if mset.pizza then for _,o in ipairs(svc.WS:GetDescendants()) do if o.Name=="PizzaDeliveryRig" and o:IsA("Model") and not isRealPlayer(o) and not tracked.pizza[o] then addHighlight(o,Color3.fromRGB(255,100,0),"pizza","C00LKIDD PIZZA DELIVERY",3) end end end end) end

local function scanZombie() pcall(function() if mset.zombie then for _,o in ipairs(svc.WS:GetDescendants()) do if o.Name=="1x1x1x1Zombie" and o:IsA("Model") and not isRealPlayer(o) and not tracked.zombie[o] then addHighlight(o,Color3.fromRGB(80,255,120),"zombie","1X1X1X1 ZOMBIE",3) end end end end) end

local function scanPuddles() pcall(function() if mset.puddle then for _,o in ipairs(svc.WS:GetDescendants()) do if isJohnDoePuddle(o) and not tracked.puddle[o] then addPuddleHighlight(o,Color3.fromRGB(255,50,50),"puddle","JOHN DOE PUDDLE") end end end end) end

task.spawn(function() while true do task.wait(3); scanPizza(); scanZombie(); scanPuddles() end end)

secMinion:Toggle({ Title="c00lkidd Pizza Bots", Type="Checkbox", Flag="espPizza", Default=mset.pizza, Callback=function(on) pcall(function() mset.pizza=on; if on then scanPizza() else clearTag("pizza") end end) end })

secMinion:Toggle({ Title="1x1x1x1 Zombies", Type="Checkbox", Flag="espZombie", Default=mset.zombie, Callback=function(on) pcall(function() mset.zombie=on; if on then scanZombie() else clearTag("zombie") end end) end })

secMinion:Toggle({ Title="JD Digital Footprints", Type="Checkbox", Flag="espPuddle", Default=mset.puddle, Callback=function(on) pcall(function() mset.puddle=on; if on then scanPuddles() else clearTag("puddle") end end) end })

secMinion:Slider({ Title="Highlight Transparency", Flag="espMinionTrans", Step=0.05, Value={Min=0,Max=1,Default=mset.transparency}, Callback=function(v) pcall(function() mset.transparency=v; updateTransparency() end) end })

secMinion:Button({ Title="Force Rescan", Callback=function() pcall(function() clearTag("pizza"); clearTag("zombie"); clearTag("puddle"); task.wait(0.1); scanPizza(); scanZombie(); scanPuddles() end) end })

-- ============================================================
-- GROUNDBULB & VINE ESP (Integrated Working Version - FIXED)
-- ============================================================

local secGVEsp = tabESP:Section({ Title = "Groundbulb & Vine Settings", Opened = false })

local gvConfig = {
    HighlightColor = Color3.fromRGB(170, 0, 255),
    FillTransparency = 0.5,
    OutlineTransparency = 0.1,
    ScanInterval = 0.5,
}

local gvStandaloneThread = nil
local gvStandaloneObjects = {}

local function gvStartStandalone()
    if gvStandaloneThread then return end
    
    gvStandaloneThread = task.spawn(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Workspace = game:GetService("Workspace")

        -- Tracked entities: Map<Model, Data>
        local trackedEntities = {}

        -- Function to find the highest part or flower part of the model for top positioning
        local function getTopPart(model)
            local highestPart = model.PrimaryPart
            local highestY = highestPart and highestPart.Position.Y or -math.huge

            for _, descendant in ipairs(model:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    if descendant.Name:find("Flower") or descendant.Position.Y > highestY then
                        highestY = descendant.Position.Y
                        highestPart = descendant
                    end
                end
            end

            return highestPart
        end

        -- Function to highlight a specific target model (Vine or GroundBulb)
        local function highlightEntity(model, displayName)
            if not model or not model:IsA("Model") then return end
            if trackedEntities[model] then return end

            local adornPart = getTopPart(model)
            if not adornPart then
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Name ~= "Handle" then
                        adornPart = descendant
                        break
                    end
                end
            end

            if not adornPart then return end

            if not model.PrimaryPart then
                model.PrimaryPart = adornPart
            end

            local highlight = Instance.new("Highlight")
            highlight.Name = "EntityHighlight"
            highlight.Adornee = model
            highlight.FillColor = gvConfig.HighlightColor
            highlight.FillTransparency = gvConfig.FillTransparency
            highlight.OutlineColor = gvConfig.HighlightColor
            highlight.OutlineTransparency = gvConfig.OutlineTransparency
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.Parent = model

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "EntityTag"
            billboard.Size = UDim2.new(0, 200, 0, 30)
            billboard.Adornee = adornPart
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.MaxDistance = 150
            billboard.AlwaysOnTop = true
            billboard.Parent = model

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = displayName
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            label.TextStrokeTransparency = 0.3
            label.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            label.TextSize = 16
            label.Parent = billboard

            trackedEntities[model] = {
                Model = model,
                Highlight = highlight,
                Billboard = billboard,
            }
            
            table.insert(gvStandaloneObjects, {model, highlight, billboard})
        end

        -- Function to check and classify a model as Vine or GroundBulb
        local function evaluateAndHighlight(child)
            if not child:IsA("Model") then return end

            local nameLower = child.Name:lower()
            local isGroundBulb = nameLower:find("groundbulb")
            local isVine = nameLower:find("vine")

            if not isGroundBulb and not isVine then
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        local descName = descendant.Name:lower()
                        if descName:find("flower") or descName:find("nectar") or descName:find("tentacle") then
                            isVine = true
                            break
                        elseif descName:find("root") then
                            isGroundBulb = true
                            break
                        end
                    end
                end
            end

            if isGroundBulb and gvEsp.showGroundbulb and not trackedEntities[child] then
                highlightEntity(child, "GroundBulb")
            elseif isVine and gvEsp.showVine and not trackedEntities[child] then
                highlightEntity(child, "Vine")
            end
        end

        -- Function to scan the workspace for new Vines and GroundBulbs
        local function scanForSpawns()
            local map = Workspace:FindFirstChild("Map")
            if not map then return end

            local ingame = map:FindFirstChild("Ingame")
            if not ingame then return end

            for _, child in ipairs(ingame:GetChildren()) do
                evaluateAndHighlight(child)
            end
        end

        -- Clean up destroyed models to prevent memory leaks
        local function cleanupEntities()
            for model, data in pairs(trackedEntities) do
                if not model or not model.Parent or not model:IsDescendantOf(Workspace) then
                    if data.Highlight then data.Highlight:Destroy() end
                    if data.Billboard then data.Billboard:Destroy() end
                    trackedEntities[model] = nil
                end
            end
        end

        -- Main update loop
        local function updateLoop()
            cleanupEntities()
            scanForSpawns()
        end

        task.wait(2)
        scanForSpawns()

        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not gvEsp.on then
                heartbeatConn:Disconnect()
                return
            end
            updateLoop()
        end)

        local map = Workspace:FindFirstChild("Map")
        if map then
            local ingame = map:FindFirstChild("Ingame")
            if ingame then
                ingame.ChildAdded:Connect(function(child)
                    if child:IsA("Model") and gvEsp.on then
                        task.wait(0.5)
                        evaluateAndHighlight(child)
                    end
                end)
            end
        end
    end)
end

local function gvStopStandalone()
    if gvStandaloneThread then
        task.cancel(gvStandaloneThread)
        gvStandaloneThread = nil
    end
    
    for _, obj in ipairs(gvStandaloneObjects) do
        local model, hl, bb = obj[1], obj[2], obj[3]
        pcall(function() if hl then hl:Destroy() end end)
        pcall(function() if bb then bb:Destroy() end end)
    end
    gvStandaloneObjects = {}
end

secGVEsp:Toggle({
    Title = "Show Groundbulb",
    Type = "Checkbox",
    Flag = "gvShowGroundbulb",
    Default = gvEsp.showGroundbulb,
    Callback = function(on)
        gvEsp.showGroundbulb = on
    end
})

secGVEsp:Toggle({
    Title = "Show Vine",
    Type = "Checkbox",
    Flag = "gvShowVine",
    Default = gvEsp.showVine,
    Callback = function(on)
        gvEsp.showVine = on
    end
})

secGVEsp:Slider({
    Title = "Highlight Transparency",
    Flag = "gvTransparency",
    Step = 0.05,
    Value = { Min = 0.1, Max = 1.0, Default = gvConfig.FillTransparency },
    Callback = function(v)
        gvConfig.FillTransparency = v
    end
})

secGVEsp:Button({
    Title = "Refresh ESP",
    Callback = function()
        if gvEsp.on then
            gvStopStandalone()
            gvStartStandalone()
        end
    end
})

secGVEsp:Button({
    Title = "Clear All Highlights",
    Callback = function()
        gvStopStandalone()
        gvStandaloneObjects = {}
    end
})

lp.CharacterAdded:Connect(function()
    task.wait(2)
    if gvEsp.on then
        gvStopStandalone()
        gvStartStandalone()
    end
end)
end -- tabESP
do -- tabMusic
local tabMusic = win:Tab({ Title = "Music", Icon = "music" })
local secLMS   = tabMusic:Section({ Title = "LMS Music", Opened = true })

local music = {
    on = false, selected = "CondemnedLMS", cached = {}, origId = nil,
    thread = nil, lastSoundCheck = 0, cachedSound = nil,
}

local musicDir = "betrayalhub/LMS_Songs"
if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
if not fs.hasFolder(musicDir) then fs.makeFolder(musicDir) end

local ghBase = "https://raw.githubusercontent.com/r3take/lmsstuff/main/"
local musicTracks = {
    AbberantLMS=ghBase.."AbberantLMS.mp3", OvertimeLMS=ghBase.."OvertimeLMS.mp3",
    PhotoshopLMS=ghBase.."PhotoshopLMS.mp3", JX1DX1LMS=ghBase.."JX1DX1LMS.mp3",
    CondemnedLMS=ghBase.."CondemnedLMS.mp3", GeometryLMS=ghBase.."GeometryLMS.mp3",
    SixerVsNoobLMS=ghBase.."SixerVsNoobLMS.mp3", Milestone4LMS=ghBase.."MS4LMS.mp3",
    BluududLMS=ghBase.."BluududLMS.mp3", JohnDoeLMS=ghBase.."JohnDoeLMS.mp3",
    EternalIShallEndure=ghBase.."EternallShallEndure.mp3",
    ChanceVSMafiosoLMS=ghBase.."ChanceVSMafioso.mp3",
    MafiosoVsChanceLMS=ghBase.."ChanceVSMafioso.mp3",
    JohnVsJaneLMS=ghBase.."JohnVSJaneLMS.mp3",
    SynonymsForEternity=ghBase.."synonymsforeternity.mp3",
    EternityEpicfied=ghBase.."EternityEpicfied.mp3",
    EternalHopeEternalFight=ghBase.."EternalHopeEternalFight.mp3",
    SlasherVSGuest=ghBase.."slashervguestlms.mp3", Debth=ghBase.."Debth.mp3",
    ShatteredHopes=ghBase.."ShatteredHopesLMS.mp3", EmberRageLMS=ghBase.."emberragelms.mp3",
    SprunkinLMS=ghBase.."SPRUNKINLMS.mp3", AzureVSTwoTimeLMS=ghBase.."azurevstwotimelms.mp3",
    AshleLMS=ghBase.."Ashlelms.mp3", MeetYourMaking=ghBase.."MeetYourMaking.mp3",
    ReceadingLifespan=ghBase.."ReceadingLifespan.mp3", PhoenixLMS=ghBase.."phoenixlms.mp3",
    JerseyDebth=ghBase.."JerseyDebth.mp3",
}

local musicList = {}
for k in pairs(musicTracks) do table.insert(musicList, k) end
table.sort(musicList)

local MUSIC_DIR = "betrayalhub/Music"

local function musicTrackPath(name) return MUSIC_DIR.."/"..name..".mp3" end

local function musicHttpGet(url) local ok,d=pcall(function() return game:HttpGet(url) end); return ok and d or nil end

local function musicFetch(name)
    pcall(function()
        if music.cached[name] then return music.cached[name] end
        local url = musicTracks[name]; if not url then return nil end
        if not fs.hasFolder(MUSIC_DIR) then fs.makeFolder(MUSIC_DIR) end
        local path = musicTrackPath(name)
        if not fs.hasFile(path) then
            local data = musicHttpGet(url); if not data then return nil end
            pcall(function() fs.write(path,data) end)
        end
        local ok, asset = pcall(function() return fs.asset(path) end)
        if ok and asset then music.cached[name]=asset; return asset end
        return nil
    end)
end

local musicFetchInFlight = {}

local function musicFetchAsync(name, cb)
    if music.cached[name] then if cb then cb(music.cached[name]) end; return end
    if musicFetchInFlight[name] then return end
    musicFetchInFlight[name] = true
    task.spawn(function()
        local asset = musicFetch(name)
        musicFetchInFlight[name] = nil
        if asset and cb then cb(asset) end
    end)
end

local function musicGetSound()
    local now = tick()
    if music.cachedSound and music.cachedSound.Parent and (now - music.lastSoundCheck) < 0.5 then return music.cachedSound end
    music.lastSoundCheck = now
    local snd = svc.WS:FindFirstChild("Themes") and svc.WS.Themes:FindFirstChild("LastSurvivor")
        or svc.WS:FindFirstChild("LastSurvivor", true) or svc.SoundService:FindFirstChild("LastSurvivor", true)
    if snd and snd:IsA("Sound") then music.cachedSound=snd; return snd end
    music.cachedSound=nil; return nil
end

local function musicPlay(name)
    pcall(function()
        local snd = musicGetSound(); if not snd then return false end
        if not music.origId then music.origId = snd.SoundId end
        local asset = musicFetch(name); if not asset then return false end
        if snd.SoundId ~= asset then snd.SoundId=asset; snd:Stop(); task.wait(0.05); snd:Play()
        elseif not snd.IsPlaying then snd:Play() end
        return true
    end)
end

local function musicReset()
    pcall(function()
        local snd = musicGetSound()
        if snd and music.origId then snd.SoundId=music.origId; snd:Stop(); task.wait(0.05); snd:Play() end
    end)
end

local function musicMonitor()
    while music.on do
        pcall(function()
            local snd = musicGetSound()
            if snd then
                local asset = music.cached[music.selected]
                if asset then
                    if snd.SoundId ~= asset then
                        if not music.origId then music.origId = snd.SoundId end
                        snd.SoundId=asset; snd:Stop(); task.wait(0.05); snd:Play()
                    elseif not snd.IsPlaying then snd:Play() end
                else
                    musicFetchAsync(music.selected, function(a)
                        local s = musicGetSound(); if s then
                            if not music.origId then music.origId = s.SoundId end
                            s.SoundId=a; s:Stop(); task.wait(0.05); s:Play()
                        end
                    end)
                end
            end
        end)
        task.wait(1)
    end
end

secLMS:Toggle({ Title="Auto-Play on LMS", Type="Checkbox", Flag="musicOn", Default=music.on,
    Callback=function(on) pcall(function() music.on=on; if on then musicFetchAsync(music.selected); music.thread=task.spawn(musicMonitor) else if music.thread then task.cancel(music.thread); music.thread=nil end; musicReset() end end) end })

secLMS:Dropdown({ Title="Track", Flag="musicSel", Values=musicList, Value=music.selected,
    Callback=function(sel) pcall(function() music.selected=type(sel)=="table" and sel[1] or sel; task.spawn(function() musicFetchAsync(music.selected) end) end) end })

secLMS:Button({ Title="Play", Callback=function() pcall(function() musicPlay(music.selected) end) end })

secLMS:Button({ Title="Stop", Callback=function() pcall(function() musicReset() end) end })

secLMS:Button({ Title="Preload LMS", Callback=function() pcall(function() for name in pairs(musicTracks) do musicFetchAsync(name); task.wait(0.05) end end) end })

-- ============================================================
-- JANE DOE TAB (Integrated)
-- ============================================================

local tabJaneDoe = win:Tab({ Title = "Jane Doe", Icon = "gem" })
local jd_Run = svc.Run
local jd_RS = svc.RS
local jd_lp = lp
local jd_Camera = svc.WS.CurrentCamera

local jd_RemoteEvent = nil
local jd_NetworkRF = nil

pcall(function()
    jd_RemoteEvent = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
end)
pcall(function()
    jd_NetworkRF = jd_RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteFunction",10)
end)

local jd_enabled = false
local jd_aimbotOn = false
local jd_patched = false
local jd_unloaded = false
local jd_AIM_OFFSET = -0.3
local jd_PREDICTION = 0.6
local jd_HOLD_DURATION = 0.9
local jd_axeEnabled = false
local jd_AXE_LOCK_DURATION = 1.7
local jd_axeLocked = false
local jd_killerMotionData = {}
local jd_holdActive = false
local jd_crystalAutoHold = false

local function jd_getKillerVelocity(hrp)
    local ok, result = pcall(function()
        local now=tick(); local pos=hrp.Position; local data=jd_killerMotionData[hrp]
        if not data then 
            jd_killerMotionData[hrp]={lastPos=pos,lastTime=now,velocity=Vector3.zero}; 
            return Vector3.zero 
        end
        local dt=now-data.lastTime; if dt<=0 then return data.velocity end
        local vel=(pos-data.lastPos)/dt; data.lastPos=pos; data.lastTime=now; data.velocity=vel
        return vel
    end)
    return ok and result or Vector3.zero
end

local function jd_getNearestKiller(fromPos)
    local ok, result = pcall(function()
        local playerFolder = svc.WS:FindFirstChild("Players")
        local folder = playerFolder and playerFolder:FindFirstChild("Killers")
        if not folder then return nil end
        
        local nearest,best=nil,math.huge
        for _,model in ipairs(folder:GetChildren()) do
            local hrp=model:FindFirstChild("HumanoidRootPart"); local hum=model:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then 
                local d=(hrp.Position-fromPos).Magnitude; 
                if d<best then best=d; nearest=model end 
            end
        end
        return nearest
    end)
    return ok and result or nil
end

local function jd_holdCrystal()
    local ok = pcall(function()
        if not jd_RemoteEvent or not jd_enabled then return end
        local b = buffer.create(8)
        buffer.writeu32(b, 0, 2)
        buffer.writef32(b, 4, svc.WS.DistributedGameTime)
        jd_RemoteEvent:FireServer(jd_lp.Name .. "CrystalInput", { b })
    end)
    if not ok then warn("Failed to hold crystal") end
end

local function jd_axeDoLock()
    local ok = pcall(function()
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
        local conn; conn = jd_Run.RenderStepped:Connect(function()
            local connOk = pcall(function()
                if tick() >= deadline or not jd_axeEnabled or jd_unloaded then
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
            if not connOk then
                pcall(function() conn:Disconnect() end)
                pcall(function() hum.AutoRotate = savedAutoRotate end)
                jd_axeLocked = false
            end
        end)
    end)
    if not ok then warn("Failed to execute axe lock-on"); jd_axeLocked = false end
end

local function jd_buildCamCF(myHRP, killerHRP, v0, g)
    local ok, result = pcall(function()
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
    end)
    return ok and result or nil
end

local function jd_getLocalActor() 
    return jd_lp.Character
end

local function jd_applyPatch(actor)
    local ok = pcall(function()
        if jd_patched or not actor or not jd_NetworkRF then return end
        
        rfDispatch:install(jd_NetworkRF)
        
        rfDispatch:register("jd", function(reqName, ...)
            local hookOk, result = pcall(function()
                if not (jd_enabled and jd_aimbotOn) then return nil end
                local char = jd_lp.Character
                local myHRP = char and char:FindFirstChild("HumanoidRootPart")
                if not myHRP then return nil end
                local killer = jd_getNearestKiller(myHRP.Position)
                local killerHRP = killer and killer:FindFirstChild("HumanoidRootPart")
                if not killerHRP then return nil end
                
                if reqName == "GetMousePosition" then
                    local vel = jd_getKillerVelocity(killerHRP)
                    local pos = killerHRP.Position + vel * jd_PREDICTION + Vector3.new(0, jd_AIM_OFFSET, 0)
                    return pos
                end
                
                if reqName == "GetCameraCF" then
                    local cf = jd_buildCamCF(myHRP, killerHRP, 250, 40)
                    if cf then return cf end
                end
                return nil
            end)
            if hookOk then return result else return nil end
        end)
        jd_patched = true
    end)
    if not ok then warn("Failed to apply patch: " .. tostring(ok)) end
end

local function jd_removePatch()
    local ok = pcall(function()
        if not jd_patched then return end
        rfDispatch:unregister("jd")
        if next(rfDispatch.hooks) == nil then
            rfDispatch:uninstall(jd_NetworkRF)
        end
        jd_patched = false
    end)
    if not ok then warn("Failed to remove patch") end
end

task.spawn(function()
    while not jd_RemoteEvent do task.wait(0.5) end
    
    local connection
    connection = jd_RemoteEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        if not jd_enabled then return end
        
        if jd_crystalAutoHold and args[1] == (jd_lp.Name .. "CrystalInput") and not jd_holdActive then
            jd_holdActive = true
            task.spawn(function()
                local holdOk = pcall(function()
                    local deadline = tick() + jd_HOLD_DURATION
                    while tick() < deadline and jd_enabled and jd_crystalAutoHold and not jd_unloaded do
                        jd_holdCrystal()
                        task.wait(1/30)
                    end
                    jd_holdActive = false
                end)
                if not holdOk then jd_holdActive = false end
            end)
        end
        
        if jd_axeEnabled and args[1] == "UseActorAbility" and args[2] and args[2][1] then
            local ok2, bs = pcall(function() return buffer.tostring(args[2][1]) end)
            if ok2 and bs and bs:find("Axe") then
                task.spawn(jd_axeDoLock)
            end
        end
    end)
    
    getgenv()._jdConnection = connection
end)

task.spawn(function()
    local lastActor=nil
    while not jd_unloaded do
        task.wait(0.5)
        local cur=jd_getLocalActor()
        if cur~=lastActor then
            if lastActor~=nil then 
                jd_patched=false
                jd_killerMotionData={} 
            end
            lastActor=cur
            if cur and jd_enabled then 
                jd_applyPatch(cur) 
            end
        end
    end
end)

local sec_024 = tabJaneDoe:Section({ Title = "Crystal Auto-Fire", Opened = true })

sec_024:Toggle({ 
    Title = "Enable Jane Doe Aimbot", Flag = "jdEnabled", Default = false, Type = "Checkbox",
    Callback = function(on)
        jd_enabled=on
        local actor=jd_getLocalActor()
        if on and not jd_patched and actor then 
            jd_applyPatch(actor) 
        end
    end
})

sec_024:Toggle({ 
    Title = "Aimbot (Silent Aim)", Flag = "jdSilentAim", Default = false, Type = "Checkbox",
    Callback = function(on)
        jd_aimbotOn=on
        local actor=jd_getLocalActor()
        if on and not jd_patched and actor then 
            jd_applyPatch(actor) 
        end
    end
})

sec_024:Toggle({ 
    Title = "Crystal Auto Hold", Flag = "jdCrystalAutoHold", Default = false, Type = "Checkbox",
    Callback = function(on)
        jd_crystalAutoHold=on
    end
})

sec_024:Slider({ 
    Title = "Aim Offset (Y)", Flag = "jdAimOffset", Value = {Min=-5.0,Max=5.0,Default=jd_AIM_OFFSET}, Step = 0.1, 
    Callback = function(v) jd_AIM_OFFSET=v end 
})

sec_024:Slider({ 
    Title = "Prediction", Flag = "jdPrediction", Value = {Min=0.0,Max=1.0,Default=jd_PREDICTION}, Step = 0.01, 
    Callback = function(v) jd_PREDICTION=v end 
})

sec_024:Slider({ 
    Title = "Hold Duration (S)", Flag = "jdHoldDur", Value = {Min=0.3,Max=2.0,Default=jd_HOLD_DURATION}, Step = 0.1, 
    Callback = function(v) jd_HOLD_DURATION=v end 
})

local sec_025 = tabJaneDoe:Section({ Title = "Axe Lock-On", Opened = true })

sec_025:Toggle({ 
    Title = "Enable Axe Lock-On", Flag = "jdAxeEnabled", Default = false, Type = "Checkbox",
    Callback = function(on) 
        jd_axeEnabled=on
    end
})

sec_025:Slider({ 
    Title = "Lock Duration (s)", Flag = "jdAxeLockDur", Value = {Min=0.5,Max=3.0,Default=jd_AXE_LOCK_DURATION}, Step = 0.1, 
    Callback = function(v) 
        jd_AXE_LOCK_DURATION=v
    end 
})

local sec_026 = tabJaneDoe:Section({ Title = "Control", Opened = true })
sec_026:Button({ 
    Title = "Unload Jane Doe", Callback = function()
        if jd_unloaded then return end
        jd_unloaded=true
        jd_enabled=false
        jd_aimbotOn=false
        jd_axeEnabled=false
        jd_crystalAutoHold=false
        jd_removePatch()
        if getgenv()._jdConnection then
            pcall(function() getgenv()._jdConnection:Disconnect() end)
            getgenv()._jdConnection = nil
        end
    end
})

tabJaneDoe:Section({ Title = "System" }):Button({
    Title = "Unload Script Completely",
    Callback = function()
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("RemoteFunction", 2)
        end)
        if ok and rf then
            rfDispatch:uninstall(rf)
        end
        if getgenv()._jdConnection then
            pcall(function() getgenv()._jdConnection:Disconnect() end)
            getgenv()._jdConnection = nil
        end
        tabJaneDoe:Destroy()
    end
})

-- ============================================================
-- ELLIOT AIMBOT TAB (Integrated)
-- ============================================================

local tabElliot = win:Tab({ Title = "Elliot", Icon = "crosshair" })

local elliotEnabled = false
local elliotConnection = nil
local elliotAutoRotBak = nil
local elliotAimType = "Camera + Character"
local elliotThrowDur = 0.6
local elliotIsThrowing = false
local elliotThrowTS = 0
local elliotRequireAnim = true
local elliotShowArc = false
local elliotArcFolder = nil
local elliotArcParts = {}
local elliotArcSegs = 50
local elliotThrowForce = 80
local elliotUpComp = 0.5
local elliotGravity = 196.2
local elliotHum, elliotHRP = nil, nil
local elliotTargetMode = "Low HP"
local elliotLastAimTime = 0
local elliotSmoothness = 0.15
local elliotPredDist = 5
local elliotThrowAnimId = "rbxassetid://114155003741146"

local function elliotSetupChar(char)
    elliotHum = char:WaitForChild("Humanoid", 3)
    elliotHRP = char:WaitForChild("HumanoidRootPart", 3)
    
    if elliotHum then
        local animator = elliotHum:FindFirstChildOfClass("Animator")
        if animator then
            animator.AnimationPlayed:Connect(function(animTrack)
                if not animTrack or not animTrack.Animation then return end
                local animId = ""
                pcall(function() animId = tostring(animTrack.Animation.AnimationId) end)
                if animId:find("114155003741146") or animId:find(elliotThrowAnimId) then
                    elliotIsThrowing = true
                    elliotThrowTS = tick()
                end
            end)
        else
            elliotHum.ChildAdded:Connect(function(child)
                if child:IsA("Animator") then
                    child.AnimationPlayed:Connect(function(animTrack)
                        if not animTrack or not animTrack.Animation then return end
                        local animId = ""
                        pcall(function() animId = tostring(animTrack.Animation.AnimationId) end)
                        if animId:find("114155003741146") or animId:find(elliotThrowAnimId) then
                            elliotIsThrowing = true
                            elliotThrowTS = tick()
                        end
                    end)
                end
            end)
        end
    end
end

if lp.Character then elliotSetupChar(lp.Character) end
lp.CharacterAdded:Connect(function(c) elliotSetupChar(c) end)

local function elliotClearArc()
    for _, p in ipairs(elliotArcParts) do if p and p.Parent then p:Destroy() end end
    elliotArcParts = {}
end

local function elliotCreateArcFolder()
    if elliotArcFolder then elliotArcFolder:Destroy() end
    elliotArcFolder = Instance.new("Folder")
    elliotArcFolder.Name = "ElliotArc"
    elliotArcFolder.Parent = svc.WS
end

local function elliotArcCalc(startPos, lookVec)
    local dir = (lookVec + Vector3.new(0, elliotUpComp, 0)).Unit
    local iv = dir * elliotThrowForce
    local maxT = 3
    local pts = {}
    local step = maxT / elliotArcSegs
    local last = startPos
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { lp.Character, elliotArcFolder }
    
    for i = 0, elliotArcSegs do
        local t = i * step
        local pos = startPos + iv*t + Vector3.new(0, -0.5*elliotGravity*t*t, 0)
        if i > 0 then
            local d = pos - last
            local dm = d.Magnitude
            if dm > 0 then
                local res = svc.WS:Raycast(last, d.Unit*dm, rp)
                if res then
                    table.insert(pts, res.Position)
                    break
                end
            end
        end
        if pos.Y < -100 then break end
        table.insert(pts, pos)
        last = pos
    end
    return pts
end

local _elliotLastArcUpdate = 0
local function elliotUpdateArc()
    if not elliotShowArc or not elliotHRP then
        elliotClearArc()
        return
    end
    
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
        local part = Instance.new("Part")
        part.Name = "ArcSeg"..i
        part.Size = Vector3.new(0.25, 0.25, 0.25)
        part.Position = p
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Shape = Enum.PartType.Ball
        
        if i == #pts and #pts > 1 then
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Color = Color3.fromRGB(255, 255, 0)
            part.Transparency = 0
        else
            part.Color = Color3.fromRGB(255, 0, 0)
            part.Transparency = 0.15
        end
        
        part.Parent = elliotArcFolder
        table.insert(elliotArcParts, part)
    end
end

local function elliotFindTarget()
    local sf = svc.WS:FindFirstChild("Players")
    if sf then sf = sf:FindFirstChild("Survivors") end
    if not sf then sf = svc.WS:FindFirstChild("Survivors") end
    if not sf or not elliotHRP then return nil end
    
    local best, bestVal = nil, math.huge
    for _, s in ipairs(sf:GetChildren()) do
        if s ~= lp.Character then
            local h = s:FindFirstChildOfClass("Humanoid")
            local r = s:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then
                local val = elliotTargetMode == "Closest"
                    and (r.Position - elliotHRP.Position).Magnitude
                    or h.Health
                if val < bestVal then
                    best = r
                    bestVal = val
                end
            end
        end
    end
    return best
end

local function elliotAimAt(tgt)
    if not tgt or not tgt.Parent then return end
    
    local now = tick()
    if now - elliotLastAimTime < 0.016 then return end
    elliotLastAimTime = now
    
    local vel = tgt.AssemblyLinearVelocity or Vector3.zero
    local pos = tgt.Position
    local predPos = pos
    
    if vel.Magnitude > 2 then
        local dist = (tgt.Position - elliotHRP.Position).Magnitude
        local predTime = math.min(dist / elliotThrowForce, 1.0)
        predPos = tgt.Position + (vel * predTime * (elliotPredDist / 5))
    end
    
    if elliotAimType == "HRP Aimbot" or elliotAimType == "Camera + Character" then
        if elliotHRP and elliotHum then
            if elliotAutoRotBak == nil then
                elliotAutoRotBak = elliotHum.AutoRotate
                elliotHum.AutoRotate = false
            end
            
            elliotHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            local direction = (predPos - elliotHRP.Position)
            local flatDirection = Vector3.new(direction.X, 0, direction.Z)
            
            if flatDirection.Magnitude > 0.1 then
                local lookAt = CFrame.lookAt(elliotHRP.Position, elliotHRP.Position + flatDirection.Unit)
                local cur = elliotHRP.CFrame
                local nCF = cur:Lerp(CFrame.new(cur.Position) * lookAt.Rotation, elliotSmoothness)
                elliotHRP.CFrame = nCF
            end
        end
    end
    
    if elliotAimType == "Camera Aimbot" or elliotAimType == "Camera + Character" then
        local cam = svc.WS.CurrentCamera
        if cam then
            local targetCF = CFrame.lookAt(cam.CFrame.Position, predPos)
            cam.CFrame = cam.CFrame:Lerp(targetCF, elliotSmoothness * 1.5)
        end
    end
end

local function elliotStartAimbot()
    if elliotConnection then elliotConnection:Disconnect() end
    
    elliotConnection = svc.Run.RenderStepped:Connect(function()
        if not elliotEnabled or not elliotHum or not elliotHRP then
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            return
        end
        
        if elliotShowArc then elliotUpdateArc() end
        
        local shouldAim = false
        if elliotRequireAnim then
            shouldAim = elliotIsThrowing and (tick() - elliotThrowTS) <= elliotThrowDur
        else
            shouldAim = true
        end
        
        if elliotIsThrowing and (tick() - elliotThrowTS) > elliotThrowDur then
            elliotIsThrowing = false
        end
        
        if not shouldAim then
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            return
        end
        
        local tgt = elliotFindTarget()
        if tgt then
            elliotAimAt(tgt)
        else
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
        end
    end)
end

local elliotMainTab = tabElliot:Section({ Title = "Aimbot", Opened = true })

elliotMainTab:Toggle({
    Title = "Enable Aimbot",
    Description = "Toggle the aimbot on/off",
    Default = false,
    Callback = function(v)
        elliotEnabled = v
        if v then
            elliotStartAimbot()
            print("[Elliot] ✅ Aimbot enabled")
        else
            if elliotConnection then
                elliotConnection:Disconnect()
                elliotConnection = nil
            end
            if elliotAutoRotBak ~= nil and elliotHum then
                elliotHum.AutoRotate = elliotAutoRotBak
                elliotAutoRotBak = nil
            end
            elliotClearArc()
            elliotIsThrowing = false
            print("[Elliot] ❌ Aimbot disabled")
        end
    end
})

elliotMainTab:Dropdown({
    Title = "Aimbot Type",
    Description = "Choose how the aimbot targets",
    Values = {"HRP Aimbot", "Camera Aimbot", "Camera + Character"},
    Value = "Camera + Character",
    Callback = function(v)
        elliotAimType = v
        print("[Elliot] Aimbot type: " .. v)
    end
})

elliotMainTab:Dropdown({
    Title = "Target Mode",
    Description = "How targets are selected",
    Values = {"Low HP", "Closest"},
    Value = "Low HP",
    Callback = function(v)
        elliotTargetMode = v
        print("[Elliot] Target mode: " .. v)
    end
})

elliotMainTab:Slider({
    Title = "Throw Window (s)",
    Description = "Duration of throw animation window",
    Step = 0.1,
    Value = { Min = 0.1, Max = 2, Default = 0.6 },
    Callback = function(v)
        elliotThrowDur = v
    end
})

elliotMainTab:Slider({
    Title = "Smoothness",
    Description = "How smooth the aimbot transitions",
    Step = 0.01,
    Value = { Min = 0.05, Max = 0.5, Default = 0.15 },
    Callback = function(v)
        elliotSmoothness = v
    end
})

elliotMainTab:Slider({
    Title = "Prediction (studs)",
    Description = "How much to predict target movement",
    Step = 1,
    Value = { Min = 0, Max = 50, Default = 5 },
    Callback = function(v)
        elliotPredDist = v
    end
})

elliotMainTab:Slider({
    Title = "Throw Force",
    Description = "Force of the throw",
    Step = 5,
    Value = { Min = 50, Max = 150, Default = 80 },
    Callback = function(v)
        elliotThrowForce = v
    end
})

elliotMainTab:Slider({
    Title = "Arc Segments",
    Description = "Number of segments in arc visualization",
    Step = 5,
    Value = { Min = 20, Max = 100, Default = 50 },
    Callback = function(v)
        elliotArcSegs = v
    end
})

elliotMainTab:Toggle({
    Title = "Require Animation",
    Description = "Only aim when throw animation plays",
    Default = true,
    Callback = function(v)
        elliotRequireAnim = v
        print("[Elliot] Animation requirement: " .. (v and "ON" or "OFF"))
    end
})

elliotMainTab:Toggle({
    Title = "Show Arc Visualization",
    Description = "Display the throw arc",
    Default = false,
    Callback = function(v)
        elliotShowArc = v
        if v then
            elliotCreateArcFolder()
            print("[Elliot] Arc visualization enabled")
        else
            elliotClearArc()
            if elliotArcFolder then
                elliotArcFolder:Destroy()
                elliotArcFolder = nil
            end
            print("[Elliot] Arc visualization disabled")
        end
    end
})

elliotMainTab:Button({
    Title = "Unload Elliot",
    Callback = function()
        elliotEnabled = false
        if elliotConnection then
            elliotConnection:Disconnect()
            elliotConnection = nil
        end
        if elliotAutoRotBak ~= nil and elliotHum then
            elliotHum.AutoRotate = elliotAutoRotBak
            elliotAutoRotBak = nil
        end
        elliotClearArc()
        if elliotArcFolder then
            elliotArcFolder:Destroy()
            elliotArcFolder = nil
        end
        elliotIsThrowing = false
        tabElliot:Destroy()
    end
})

ui:Notify({
    Title = "Elliot Aimbot",
    Content = "Aimbot loaded successfully!",
    Duration = 3
})

-- ============================================================
-- CHANCE AIMBOT TAB (Integrated)
-- ============================================================

local tabChance = win:Tab({ Title = "Chance", Icon = "user" })

local chanceAimEnabled = false
local predMode = "Velocity"
local predValue = 0.5
local aimBehavior = "Normal"
local spinDuration = 0.5
local msgOnAim = false
local msgText = ""
local customAnim = false
local customAnimID = ""
local antiBait = true
local smoothSpeed = 14
local heightAim = true
local holdToAim = true
local aimKey = Enum.KeyCode.Q
local holdingAimKey = false

local chanceKillerSpeeds = {
    Slasher = { walk = 9, run = 28 },
    c00lkidd = { walk = 7.75, run = 28 },
    JohnDoe = { walk = 9, run = 27.25 },
    ["1x1x1x1"] = { walk = 8.5, run = 27 },
    Noli = { walk = 7.5, run = 27.5 },
    Guest666 = { walk = 9, run = 27 },
    Nosferatu = { walk = 7.25, run = 27.5 },
    Doombringer = { walk = 8, run = 27 },
    JaneDoe = { walk = 9, run = 27 },
    Builderman = { walk = 8.5, run = 27.5 },
    Dusekkar = { walk = 8, run = 27.5 },
}

local chanceHumanoid, chanceHRP
local function chanceSetChar(char)
    chanceHumanoid = char:WaitForChild("Humanoid")
    chanceHRP = char:WaitForChild("HumanoidRootPart")
end
if lp.Character then chanceSetChar(lp.Character) end
lp.CharacterAdded:Connect(chanceSetChar)

local function chanceGetNearest()
    if not chanceHRP then return end
    local folder = svc.WS:FindFirstChild("Players")
    folder = folder and folder:FindFirstChild("Killers")
    if not folder then return end
    local closest, dist = nil, math.huge
    for _, m in ipairs(folder:GetChildren()) do
        local r = m:FindFirstChild("HumanoidRootPart")
        local h = m:FindFirstChildOfClass("Humanoid")
        if r and h and h.Health > 0 then
            local d = (r.Position - chanceHRP.Position).Magnitude
            if d < dist then dist = d; closest = r end
        end
    end
    return closest
end

local chanceMotionData = {}

local function chanceGetMotion(hrp)
    local now = tick()
    local pos = hrp.Position
    local data = chanceMotionData[hrp]
    if not data then
        chanceMotionData[hrp] = { lastPos = pos, lastTime = now, velocity = Vector3.zero, accel = Vector3.zero }
        return Vector3.zero, Vector3.zero
    end
    local dt = now - data.lastTime
    if dt <= 0 then return data.velocity, data.accel end

    local vel = (pos - data.lastPos) / dt
    local accel = (vel - data.velocity) / dt

    data.lastPos = pos
    data.lastTime = now
    data.accel = accel
    data.velocity = vel
    return vel, accel
end

local chancePingSamples = {}
local function chanceGetPing()
    local ok, stat = pcall(function()
        return svc.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    local raw = (ok and stat or 100) / 1000
    table.insert(chancePingSamples, raw)
    if #chancePingSamples > 5 then table.remove(chancePingSamples, 1) end
    local sum = 0
    for _, v in ipairs(chancePingSamples) do sum = sum + v end
    return sum / #chancePingSamples
end

local function chancePredict(hrp)
    local vel, accel = chanceGetMotion(hrp)
    local pos = hrp.Position
    local speed = vel.Magnitude

    if antiBait then
        local model = hrp.Parent
        if model and chanceKillerSpeeds[model.Name] then
            local maxSpeed = chanceKillerSpeeds[model.Name].run + 2
            if speed > maxSpeed then
                vel = vel.Unit * maxSpeed
                speed = maxSpeed
            end
        end
    end

    local ping = chanceGetPing()
    local dist = chanceHRP and (hrp.Position - chanceHRP.Position).Magnitude or 0
    local distScale = dist * 0.003

    local lead
    if predMode == "Velocity" then
        lead = predValue + distScale
    elseif predMode == "Ping" then
        lead = ping * predValue + distScale
    elseif predMode == "Look" then
        return pos + hrp.CFrame.LookVector * (speed * predValue)
    elseif predMode == "LookPing" then
        return pos + hrp.CFrame.LookVector * (speed * ping)
    else
        lead = predValue
    end

    if chanceHRP and speed > 1 then
        local toKiller = (hrp.Position - chanceHRP.Position).Unit
        local strafe = math.abs(vel.Unit:Dot(Vector3.new(-toKiller.Z, 0, toKiller.X)))
        if strafe > 0.5 then
            lead = lead + strafe * 0.06
        end
    end

    if speed < 0.5 then return pos end

    local accelContrib = accel * lead * lead * 0.5
    local accelMag = accelContrib.Magnitude
    if accelMag > speed * 0.4 then
        accelContrib = accelContrib.Unit * (speed * 0.4)
    end

    return pos + vel * lead + accelContrib
end

local function chanceSmoothLook(current, goal, dt)
    local alpha = 1 - math.exp(-smoothSpeed * dt)
    return current:Lerp(goal, alpha)
end

local chanceAiming = false
local chanceStartTime = 0
local chanceDuration = 1.7

local chanceTriggers = {
    ["133607163653602"] = true,
    ["133491532453922"] = true,
    ["131189930305001"] = true,
    ["111384272984267"] = true,
    ["103601716322988"] = true,
    ["76649505662612"] = true,
}

local function chanceHookAnimator(char)
    local hum = char:WaitForChild("Humanoid")
    local animator = hum:WaitForChild("Animator")

    animator.AnimationPlayed:Connect(function(track)
        if not chanceAimEnabled or holdToAim then return end
        local id = track.Animation.AnimationId:match("%d+")
        if id and chanceTriggers[id] then
            chanceAiming = true
            chanceStartTime = tick()

            if msgOnAim and msgText ~= "" then
                local ch = svc.TextChat.TextChannels.RBXGeneral
                if ch then pcall(ch.SendAsync, ch, msgText) end
            end

            if customAnim and tonumber(customAnimID) then
                local a = Instance.new("Animation")
                a.AnimationId = "rbxassetid://" .. customAnimID
                hum.Animator:LoadAnimation(a):Play()
            end
        end
    end)
end

if lp.Character then chanceHookAnimator(lp.Character) end
lp.CharacterAdded:Connect(chanceHookAnimator)

svc.Input.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if holdToAim and input.KeyCode == aimKey then
        holdingAimKey = true
        chanceAiming = true
        chanceStartTime = tick()
    end
end)

svc.Input.InputEnded:Connect(function(input)
    if holdToAim and input.KeyCode == aimKey then
        holdingAimKey = false
        chanceAiming = false
    end
end)

svc.Run.RenderStepped:Connect(function(dt)
    if not chanceAimEnabled or not chanceHRP then return end

    if holdToAim then
        if not holdingAimKey then return end
    else
        if not chanceAiming then return end
        if tick() - chanceStartTime > chanceDuration then chanceAiming = false; return end
    end

    local target = chanceGetNearest()
    if not target then return end

    local pos = chancePredict(target)
    if not pos then return end

    local aimPos
    if heightAim then
        aimPos = pos
    else
        aimPos = Vector3.new(pos.X, chanceHRP.Position.Y, pos.Z)
    end

    if aimBehavior == "360" then
        local prog = (tick() - chanceStartTime) / spinDuration
        if prog < 1 then
            local spunCF = CFrame.new(chanceHRP.Position) * CFrame.Angles(0, math.rad(360 * prog), 0)
            chanceHRP.CFrame = spunCF
            return
        end
    end

    local goalCF = CFrame.lookAt(chanceHRP.Position, aimPos)
    local isMoving = chanceHRP.AssemblyLinearVelocity.Magnitude > 0.5
    local speed = isMoving and math.max(smoothSpeed, 20) or smoothSpeed
    local alpha = 1 - math.exp(-speed * dt)
    chanceHRP.CFrame = chanceHRP.CFrame:Lerp(goalCF, alpha)
end)

local chanceAimSec = tabChance:Section({ Title = "Aimbot", Opened = true })
local chancePCSec = tabChance:Section({ Title = "PC / Input", Opened = true })
local chanceMiscSec = tabChance:Section({ Title = "Misc", Opened = true })

chanceAimSec:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(v) chanceAimEnabled = v end,
})

chanceAimSec:Dropdown({
    Title = "Prediction Mode",
    Values = { "Velocity", "Ping", "Look", "LookPing" },
    Value = "Velocity",
    Callback = function(v) predMode = v end,
})

chanceAimSec:Input({
    Title = "Prediction Value",
    CurrentValue = "0.5",
    Callback = function(v)
        local n = tonumber(v)
        if n then predValue = n end
    end,
})

chanceAimSec:Slider({
    Title = "Smooth Speed",
    Description = "Higher = snappier aim (14 default)",
    Step = 1,
    Value = { Min = 1, Max = 30, Default = 14 },
    Callback = function(v) smoothSpeed = v end,
})

chanceAimSec:Toggle({
    Title = "Height-Aware Aim",
    Description = "Aim up/down for slopes and platforms",
    Default = true,
    Callback = function(v) heightAim = v end,
})

chanceAimSec:Dropdown({
    Title = "Aim Behavior",
    Values = { "Normal", "360" },
    Value = "Normal",
    Callback = function(v) aimBehavior = v end,
})

chanceAimSec:Input({
    Title = "Spin Duration",
    CurrentValue = "0.5",
    Callback = function(v)
        local n = tonumber(v)
        if n then spinDuration = n end
    end,
})

chanceAimSec:Toggle({
    Title = "Anti Bait",
    Description = "Caps velocity to known killer run speed",
    Default = true,
    Callback = function(v) antiBait = v end,
})

chanceAimSec:Toggle({
    Title = "Message When Aim",
    Default = false,
    Callback = function(v) msgOnAim = v end,
})

chanceAimSec:Input({
    Title = "Message Text",
    CurrentValue = "",
    Callback = function(v) msgText = v end,
})

chancePCSec:Toggle({
    Title = "Hold-to-Aim",
    Description = "Hold the aim key to snap onto target (PC recommended)",
    Default = true,
    Callback = function(v) holdToAim = v end,
})

chancePCSec:Dropdown({
    Title = "Aim Key",
    Description = "Key to hold when Hold-to-Aim is enabled",
    Values = { "Q", "E", "R", "T", "F", "G", "X", "C", "V" },
    Value = "Q",
    Callback = function(v)
        aimKey = Enum.KeyCode[v]
    end,
})

chanceAimSec:Button({
    Title = "Ping Aim Preset",
    Callback = function()
        chanceAimEnabled = true
        predMode = "Ping"
        predValue = 1.5
        ui:Notify({ Title = "Preset Applied", Content = "Ping mode, value 1.5", Icon = "check", Duration = 3 })
    end,
})

chanceAimSec:Button({
    Title = "Owner's Setting Opinion",
    Callback = function()
        ui:Notify({
            Title = "Owner's Opinion",
            Content = "0.5 works best for 90-120 ping\nSame for ping 1.5\nIf high ping use 0.4 velocity\nElse 1.3 ping",
            Duration = 10,
            Icon = "info",
        })
    end,
})

chanceAimSec:Button({
    Title = "Tester's Setting Opinion",
    Callback = function()
        ui:Notify({
            Title = "Tester's Opinion",
            Content = "60 ping → 0.1-0.2\n120 ping → ~0.5\n200-300 ping → don't use",
            Duration = 10,
            Icon = "message-circle",
        })
    end,
})

chanceMiscSec:Toggle({
    Title = "Custom Shoot Anim",
    Default = false,
    Callback = function(v) customAnim = v end,
})

chanceMiscSec:Input({
    Title = "Animation ID",
    CurrentValue = "",
    Callback = function(v) customAnimID = v end,
})

chanceMiscSec:Button({
    Title = "Unload Chance",
    Callback = function()
        chanceAimEnabled = false
        tabChance:Destroy()
    end
})

-- ============================================================
-- DUSEKKAR TAB (Integrated)
-- ============================================================

local tabDusekkar = win:Tab({ Title = "Dusekkar", Icon = "zap" })

local plasma_enabled = false
local plasma_aimOffset = 0.0
local plasma_prediction = 0.12
local plasma_rf = nil
local plasma_motionData = {}

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

local function plasmaGetVelocity(hrp)
    local now = tick(); local pos = hrp.Position
    local data = plasma_motionData[hrp]
    if not data then
        plasma_motionData[hrp] = { lastPos = pos, lastTime = now, vel = Vector3.zero }
        return Vector3.zero
    end
    local dt = now - data.lastTime
    if dt > 0 then
        data.vel = (pos - data.lastPos) / dt
        data.lastPos = pos
        data.lastTime = now
    end
    return data.vel
end

local function plasmaUnpatch()
    if plasma_rf then
        rfDispatch:uninstall(plasma_rf)
    end
    plasma_rf = nil
end

lp.CharacterAdded:Connect(function() plasma_motionData = {} end)

local sec_027 = tabDusekkar:Section({ Title = "PlasmaBeam Silent Aim", Opened = true })

sec_027:Toggle({
    Title = "Enable PlasmaBeam Aim", Default = plasma_enabled, Type = "Checkbox", Flag = "plasmaEnabled",
    Callback = function(on) plasma_enabled = on end
})

sec_027:Slider({
    Title = "Prediction (s)", Flag = "plasmaPrediction", Value = {Min=0.0, Max=0.5, Default=plasma_prediction}, Step = 0.01,
    Callback = function(v) plasma_prediction = v end
})

sec_027:Slider({
    Title = "Aim Height Offset", Flag = "plasmaAimOffset", Value = {Min=-5.0, Max=5.0, Default=plasma_aimOffset}, Step = 0.1,
    Callback = function(v) plasma_aimOffset = v end
})

local sec_028 = tabDusekkar:Section({ Title = "Control", Opened = true })
sec_028:Button({
    Title = "Unload PlasmaBeam Hook", Callback = function()
        plasma_enabled = false; plasmaUnpatch()
    end
})

local function plasmaPatch()
    local ok, rf = pcall(function()
        return svc.RS:WaitForChild("Modules", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("Network", 10)
            :WaitForChild("RemoteFunction", 10)
    end)
    if not ok or not rf then warn("[betrayalhub] Shared RF not found"); return end
    
    plasma_rf = rf
    rfDispatch:install(rf)
    
    rfDispatch:register("plasma", function(reqName, ...)
        if reqName ~= "GetMousePosition" or not plasma_enabled then return nil end
        local hrp = plasmaGetNearestKiller()
        if not hrp then return nil end
        local vel = plasmaGetVelocity(hrp)
        return hrp.Position + vel * plasma_prediction + Vector3.new(0, plasma_aimOffset, 0)
    end)
end

task.spawn(plasmaPatch)

tabDusekkar:Section({ Title = "System" }):Button({
    Title = "Unload Script Completely",
    Callback = function()
        local ok, rf = pcall(function()
            return svc.RS:WaitForChild("Modules", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("Network", 2)
                :WaitForChild("RemoteFunction", 2)
        end)
        if ok and rf then
            rfDispatch:uninstall(rf)
        end
        tabDusekkar:Destroy()
    end
})

-- ============================================================
-- GUEST 1337 - CORE BLOCK TAB
-- ============================================================

do -- tabGuestCore
local tabGuestCore = win:Tab({ Title = "Guest Block", Icon = "shield" })

local GUEST_CONFIG_PATH = "betrayalhub/guest1337_config.json"

local guestCfg = {
    autoBlockOn = false, blockDelay = 0, detectionRange = 20,
    verifyFacingCheck = true, visionRange = 13.5, visionAngle = 85,
    showVisionCone = false, noHDTCooldown = false, hdtCooldownChecker = false,
    blockCooldown = 0.35, autoPunchDelay = 0.3,
    reverseEnabled = false, legacyFacingEnabled = false,
    legacyVisionRange = 13.5, legacyVisionAngle = 85, legacyShowVisionRange = false,
    pingCheckerEnabled = false, noclipEnabled = false,
    noclipOnlyWhenBlockReady = false, fpsCounterEnabled = false,
    smartDelayEnabled = false, manualDragEnabled = false,
    autoPunchOn = false, aimPunchActive = false,
    punchPrediction = 2.3, customPunchSoundId = 0, aimPunchDuration = 0.5,
    cinematicTextEnabled = false, cinematicText = "PARRY!",
}

local function loadGuestConfig()
    pcall(function()
        if fs.hasFile(GUEST_CONFIG_PATH) then
            local data = fs.read(GUEST_CONFIG_PATH)
            if data and #data > 0 then
                local decoded = svc.Http:JSONDecode(data)
                if decoded and type(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        if guestCfg[k] ~= nil then guestCfg[k] = v end
                    end
                end
            end
        end
    end)
end

local function saveGuestConfig()
    pcall(function()
        if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
        fs.write(GUEST_CONFIG_PATH, svc.Http:JSONEncode(guestCfg))
    end)
end

loadGuestConfig()

-- GUEST STATE
local g = {
    humanoid = nil, hrp = nil, lastBlockTime = 0,
    soundBlockedUntil = {}, soundHooks = {}, killerState = {},
    punchAiming = false, punchLastTriggerTime = 0,
    originalWS = nil, originalJP = nil, originalAutoRotate = nil, aimConnection = nil,
    centerPart = nil, leftPart = nil, rightPart = nil,
    leftToKillerPart = nil, rightToKillerPart = nil,
    leftToCenterPart = nil, centerToRightPart = nil,
    pingLabel = nil, hdtCooldownGui = nil, hdtCooldownLabel = nil,
    fpsGui = nil, fpsLabel = nil, cinematicGui = nil,
    lastFpsUpdate = 0, frameCount = 0, fps = 0,
    noclipConn = nil,
}

local g_remote = nil
pcall(function()
    g_remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
end)

local function g_fireBlock()
    if g_remote then pcall(function() g_remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function g_firePunch()
    if not g_remote then return end
    pcall(function()
        if guestCfg.customPunchSoundId and guestCfg.customPunchSoundId ~= 0 then
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://"..tostring(guestCfg.customPunchSoundId)
            s.Volume = 1; s.Parent = svc.SoundService; s:Play(); svc.Debris:AddItem(s,3)
        end
        g_remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")})
    end)
end

local function g_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function g_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function g_getTeam(n) local r=svc.WS:FindFirstChild("Players"); return r and r:FindFirstChild(n) end

local function g_isBlockReady()
    if guestCfg.noHDTCooldown then return true end
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        local num = ct.Text:match("[%d%.]+")
                        if num then
                            local v = tonumber(num)
                            return not v or v <= 0
                        end
                        return true
                    end
                end
            end
        end
    end
    return tick() - g.lastBlockTime >= guestCfg.blockCooldown
end

local function g_extractId(s)
    if not s then return nil end
    local sid = tostring(s.SoundId)
    local num = sid:match("%d+")
    if num then return num end
    local h = sid:match("[&%?]hash=([^&]+)")
    if h then return "&hash="..h end
    local p = sid:match("rbxasset://sounds/.+")
    if p then return p end
    return nil
end

local function g_getSoundPos(s)
    if not s then return nil end
    if s.Parent and s.Parent:IsA("BasePart") then return s.Parent.Position, s.Parent end
    if s.Parent and s.Parent:IsA("Attachment") and s.Parent.Parent and s.Parent.Parent:IsA("BasePart") then
        return s.Parent.Parent.Position, s.Parent.Parent
    end
    local f = s.Parent and s.Parent:FindFirstChildWhichIsA("BasePart", true)
    if f then return f.Position, f end
    return nil, nil
end

local function g_getCharFromDesc(inst)
    if not inst then return nil end
    local m = inst:FindFirstAncestorOfClass("Model")
    if m and m:FindFirstChildOfClass("Humanoid") then
        local kf = g_getTeam("Killers")
        if kf and m:IsDescendantOf(kf) then return m end
    end
    return nil
end

local function g_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local function g_getKillerPos(m)
    if not m then return nil end
    local q = g_getQueryHitbox(m)
    if q then return q.Position, q end
    local h = m:FindFirstChild("HumanoidRootPart")
    if h then return h.Position, h end
    return nil, nil
end

-- AUTO BLOCK SOUND TRIGGERS
local g_triggerSounds = {
    ["140242176732868"]=true,["136323728355613"]=true,
    ["115026634746636"]=true,["84116622032112"]=true, ["108907358619313"]=true,["127793641088496"]=true,
    ["86174610237192"]=true, ["95079963655241"]=true, ["101199185291628"]=true,["119942598489800"]=true,
    ["84307400688050"]=true, ["105200830849301"]=true,["75330693422988"]=true,
    ["82221759983649"]=true, ["81702359653578"]=true, ["85853080745515"]=true,
    ["108610718831698"]=true,["112395455254818"]=true,["109431876587852"]=true,["12222216"]=true,
    ["79980897195554"]=true, ["119583605486352"]=true,["71834552297085"]=true, ["116581754553533"]=true,
    ["86833981571073"]=true, ["110372418055226"]=true,["105840448036441"]=true,["86494585504534"]=true,
    ["80516583309685"]=true, ["131406927389838"]=true,["89004992452376"]=true, ["117231507259853"]=true,
    ["101698569375359"]=true,["101553872555606"]=true,["140412278320643"]=true,["106300477136129"]=true,
    ["117173212095661"]=true,["104910828105172"]=true,["140194172008986"]=true,["85544168523099"]=true,
    ["114506382930939"]=true,["99829427721752"]=true, ["120059928759346"]=true,["104625283622511"]=true,
    ["105316545074913"]=true,["126131675979001"]=true,["82336352305186"]=true, ["93366464803829"]=true,
    ["84069821282466"]=true, ["128856426573270"]=true,["121954639447247"]=true,["128195973631079"]=true,
    ["124903763333174"]=true,["94317217837143"]=true, ["98111231282218"]=true, ["119089145505438"]=true,
    ["136728245733659"]=true,["107444859834748"]=true,["76959687420003"]=true,
    ["72425554233832"]=true, ["96594507550917"]=true, ["139996647355899"]=true,["107345261604889"]=true,
    ["127557531826290"]=true,["108651070773439"]=true,["74842815979546"]=true, ["124397369810639"]=true,
    ["76467993976301"]=true, ["118493324723683"]=true,["78298577002481"]=true, ["116527305931161"]=true,
    ["5148302439"]=true,     ["98675142200448"]=true, ["128367348686124"]=true,["71805956520207"]=true,
    ["125213046326879"]=true,["103684883268194"]=true,["109246041199659"]=true,
    ["80540530406270"]=true, ["139523195429581"]=true,["105204810054381"]=true,["114742322778642"]=true,
    ["116468089135195"]=true,["112809109188560"]=true,["109348678063422"]=true,
    ["133709029886490"]=true,
}

local g_trackedPunchAnims = {
    ["87259391926321"]=true,["140703210927645"]=true,["136007065400978"]=true,["129843313690921"]=true,
    ["86709774283672"]=true, ["108807732150251"]=true,["138040001965654"]=true,["86096387000557"]=true,
    ["81905101227053"]=true, ["127777649118195"]=true,["99100240941590"]=true, ["92831180929659"]=true,
    ["112081768119093"]=true,["117587689359268"]=true,["91830732867282"]=true, ["91730605416216"]=true,
    ["100184164753080"]=true,
}

local function g_attemptBlockForSound(sound, preId)
    if not guestCfg.autoBlockOn or not sound or not sound:IsA("Sound") then return end
    local id = preId or g_extractId(sound)
    if not id or not g_triggerSounds[id] then return end
    if not g_isBlockReady() then return end
    if g.soundBlockedUntil[sound] and tick() < g.soundBlockedUntil[sound] then return end
    
    local root = g_getRoot()
    if not root then return end
    local _, soundPart = g_getSoundPos(sound)
    if not soundPart then return end
    local killer = g_getCharFromDesc(soundPart)
    if not killer then return end
    local hrp = killer:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local pos = g_getKillerPos(killer) or hrp.Position
    local distSq = (pos - root.Position).Magnitude ^ 2
    local effRange = guestCfg.detectionRange + 0.2 * guestCfg.detectionRange
    if distSq > effRange * effRange then return end
    
    if guestCfg.verifyFacingCheck then
        local ok, res = pcall(function()
            local dir = (root.Position - hrp.Position).Unit
            local dot = hrp.CFrame.LookVector:Dot(dir)
            local cosA = math.cos(math.rad(guestCfg.visionAngle / 2))
            return distSq < 25 or dot >= cosA
        end)
        if not ok or not res then return end
    end
    
    -- ✅ FIX: Add block delay before firing
    if guestCfg.blockDelay and guestCfg.blockDelay > 0 then
        task.wait(guestCfg.blockDelay)
    end
    
    g_fireBlock()
    g.lastBlockTime = tick()
    if guestCfg.autoPunchOn then task.delay(guestCfg.autoPunchDelay, g_firePunch) end
    g.soundBlockedUntil[sound] = tick() + 0.5
end

local function g_hookSound(sound)
    if not sound or not sound:IsA("Sound") or g.soundHooks[sound] then return end
    local preId = g_extractId(sound)
    if not preId then return end
    
    local pc = sound.Played:Connect(function()
        if guestCfg.autoBlockOn then task.spawn(g_attemptBlockForSound, sound, preId) end
    end)
    local pp = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying and guestCfg.autoBlockOn then
            task.spawn(g_attemptBlockForSound, sound, preId)
        end
    end)
    local dc
    dc = sound.Destroying:Connect(function()
        pcall(function() pc:Disconnect(); pp:Disconnect(); dc:Disconnect() end)
        g.soundHooks[sound] = nil
        g.soundBlockedUntil[sound] = nil
    end)
    g.soundHooks[sound] = {pc, pp, dc, id = preId}
    if sound.IsPlaying then task.spawn(g_attemptBlockForSound, sound, preId) end
end

local function g_hookExistingSounds()
    local kf = g_getTeam("Killers")
    if kf then
        for _, killer in pairs(kf:GetChildren()) do
            for _, d in pairs(killer:GetDescendants()) do
                if d:IsA("Sound") then pcall(g_hookSound, d) end
            end
        end
    end
end

local function g_setupSoundHooks()
    task.spawn(function()
        local pf = svc.WS:FindFirstChild("Players")
        if not pf then pf = svc.WS:WaitForChild("Players", 30) end
        if not pf then return end
        local kf = pf:FindFirstChild("Killers")
        if not kf then kf = pf:WaitForChild("Killers", 30) end
        if not kf then return end
        g_hookExistingSounds()
        kf.DescendantAdded:Connect(function(d)
            if d:IsA("Sound") then pcall(g_hookSound, d) end
        end)
        kf.ChildAdded:Connect(function(k)
            task.wait(0.1)
            for _, d in pairs(k:GetDescendants()) do
                if d:IsA("Sound") then pcall(g_hookSound, d) end
            end
        end)
    end)
end

-- VISION CONE
local function g_createVisionPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1); p.Shape = Enum.PartType.Ball
    p.Anchored = true; p.CanCollide = false
    p.Transparency = 0.5; p.Color = Color3.fromRGB(255,0,0)
    p.Parent = svc.WS
    return p
end

local function g_createConnPart()
    local p = Instance.new("Part")
    p.Size = Vector3.new(0.1,0.1,1)
    p.Anchored = true; p.CanCollide = false
    p.Transparency = 0.3; p.Color = Color3.fromRGB(255,0,0)
    p.Parent = svc.WS
    return p
end

local function g_cleanupVision()
    if g.centerPart then g.centerPart:Destroy(); g.centerPart = nil end
    if g.leftPart then g.leftPart:Destroy(); g.leftPart = nil end
    if g.rightPart then g.rightPart:Destroy(); g.rightPart = nil end
    if g.leftToKillerPart then g.leftToKillerPart:Destroy(); g.leftToKillerPart = nil end
    if g.rightToKillerPart then g.rightToKillerPart:Destroy(); g.rightToKillerPart = nil end
    if g.leftToCenterPart then g.leftToCenterPart:Destroy(); g.leftToCenterPart = nil end
    if g.centerToRightPart then g.centerToRightPart:Destroy(); g.centerToRightPart = nil end
end

local function g_updateVision()
    local show = guestCfg.showVisionCone or guestCfg.legacyShowVisionRange
    if not show then
        if g.centerPart then g_cleanupVision() end
        return
    end
    local root = g_getRoot()
    if not root then g_cleanupVision(); return end
    
    local origin
    if guestCfg.reverseEnabled or guestCfg.legacyFacingEnabled then
        origin = root
    else
        local kf = g_getTeam("Killers")
        if not kf then g_cleanupVision(); return end
        local targets = {"Slasher","c00lkidd","JohnDoe","1x1x1x1","Noli","Sixer","Nosferatu"}
        for _, name in ipairs(targets) do
            local t = kf:FindFirstChild(name)
            if t and t:FindFirstChild("HumanoidRootPart") then
                origin = t.HumanoidRootPart
                break
            end
        end
        if not origin then g_cleanupVision(); return end
    end
    
    local range = guestCfg.legacyShowVisionRange and guestCfg.legacyVisionRange or guestCfg.visionRange
    local angle = guestCfg.legacyShowVisionRange and guestCfg.legacyVisionAngle or guestCfg.visionAngle
    local fwd = origin.CFrame.LookVector
    local half = math.rad(angle / 2)
    local right = Vector3.new(-fwd.Z,0,fwd.X).Unit
    local lDir = (fwd * math.cos(half) + right * math.sin(half)).Unit
    local rDir = (fwd * math.cos(half) - right * math.sin(half)).Unit
    local cPos = origin.Position + fwd * range
    local lPos = origin.Position + lDir * range
    local rPos = origin.Position + rDir * range
    
    if not g.centerPart then g.centerPart = g_createVisionPart() end
    if not g.leftPart then g.leftPart = g_createVisionPart() end
    if not g.rightPart then g.rightPart = g_createVisionPart() end
    if not g.leftToKillerPart then g.leftToKillerPart = g_createConnPart() end
    if not g.rightToKillerPart then g.rightToKillerPart = g_createConnPart() end
    if not g.leftToCenterPart then g.leftToCenterPart = g_createConnPart() end
    if not g.centerToRightPart then g.centerToRightPart = g_createConnPart() end
    
    g.centerPart.Position = cPos
    g.leftPart.Position = lPos
    g.rightPart.Position = rPos
    
    local function updateLine(part, p1, p2)
        local mid = (p1+p2)/2
        local dist = (p2-p1).Magnitude
        part.Size = Vector3.new(0.1,0.1,dist)
        part.CFrame = CFrame.new(mid, p2)
    end
    updateLine(g.leftToKillerPart, origin.Position, lPos)
    updateLine(g.rightToKillerPart, origin.Position, rPos)
    updateLine(g.leftToCenterPart, lPos, cPos)
    updateLine(g.centerToRightPart, cPos, rPos)
end

-- CINEMATIC TEXT
local function g_showCinematicText()
    if not guestCfg.cinematicTextEnabled then return end
    if g.cinematicGui then g.cinematicGui:Destroy(); g.cinematicGui = nil end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "GuestCinematic"
    gui.Parent = lp:FindFirstChild("PlayerGui")
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 10000
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 100)
    lbl.Position = UDim2.new(0, 0, 0.4, -50)
    lbl.BackgroundTransparency = 1
    lbl.Text = guestCfg.cinematicText
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextSize = 60
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.RichText = true
    lbl.Parent = gui
    
    g.cinematicGui = gui
    task.delay(1.5, function()
        if g.cinematicGui then g.cinematicGui:Destroy(); g.cinematicGui = nil end
    end)
end

-- VISUAL UPDATERS
local function g_updatePing()
    if not guestCfg.pingCheckerEnabled then
        if g.pingLabel then g.pingLabel.Parent.Parent:Destroy(); g.pingLabel = nil end
        return
    end
    if not g.pingLabel then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestPing"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9998
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,150,0,40); fr.Position = UDim2.new(0,10,1,-50)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "Ping: 0ms"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 18; tl.Parent = fr
        g.pingLabel = tl
    end
    local ping = svc.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    g.pingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
end

local function g_updateHDTCooldown()
    if not guestCfg.hdtCooldownChecker then
        if g.hdtCooldownGui then g.hdtCooldownGui:Destroy(); g.hdtCooldownGui = nil; g.hdtCooldownLabel = nil end
        return
    end
    if not g.hdtCooldownGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestHDTCD"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9998
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,150,0,40); fr.Position = UDim2.new(0,10,0,100)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "Block CD: ?"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 18; tl.Parent = fr
        g.hdtCooldownGui = sg; g.hdtCooldownLabel = tl
    end
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        g.hdtCooldownLabel.Text = "Block CD: " .. ct.Text
                        return
                    end
                end
            end
        end
    end
    g.hdtCooldownLabel.Text = "Block CD: ?"
end

local function g_updateFPS()
    if not guestCfg.fpsCounterEnabled then
        if g.fpsGui then g.fpsGui:Destroy(); g.fpsGui = nil; g.fpsLabel = nil end
        return
    end
    if not g.fpsGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "GuestFPS"; sg.Parent = lp:FindFirstChild("PlayerGui")
        sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 9999
        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0,100,0,30); fr.Position = UDim2.new(0,10,0,150)
        fr.BackgroundColor3 = Color3.fromRGB(0,0,0); fr.BackgroundTransparency = 0.5
        fr.BorderSizePixel = 0; fr.Parent = sg
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0,8)
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,-10,1,-10); tl.Position = UDim2.new(0,5,0,5)
        tl.BackgroundTransparency = 1; tl.TextColor3 = Color3.fromRGB(255,255,255)
        tl.Text = "FPS: 0"; tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.Parent = fr
        g.fpsGui = sg; g.fpsLabel = tl
        g.lastFpsUpdate = tick(); g.frameCount = 0; g.fps = 0
    end
    g.frameCount = g.frameCount + 1
    local now = tick()
    if now - g.lastFpsUpdate >= 1 then
        g.fps = g.frameCount; g.frameCount = 0; g.lastFpsUpdate = now
        g.fpsLabel.Text = "FPS: " .. g.fps
    end
end

-- CHARACTER SETUP
local function g_setupChar(char)
    g.humanoid = char:FindFirstChild("Humanoid")
    g.hrp = char:FindFirstChild("HumanoidRootPart")
    if g.aimConnection then g.aimConnection:Disconnect(); g.aimConnection = nil end
    
    if guestCfg.aimPunchActive and g.humanoid then
        local animator = g.humanoid:FindFirstChildOfClass("Animator")
        if animator then
            g.aimConnection = animator.AnimationPlayed:Connect(function(track)
                local animId = track.Animation.AnimationId:match("%d+")
                if g_trackedPunchAnims[animId] then
                    g.punchLastTriggerTime = tick()
                    g.punchAiming = true
                end
            end)
        end
    end
end

-- NOCLIP
local function g_enableNoclip()
    if not lp.Character then return end
    if g.noclipConn then g.noclipConn:Disconnect(); g.noclipConn = nil end
    g.noclipConn = svc.Run.Stepped:Connect(function()
        if not guestCfg.noclipEnabled then g.noclipConn:Disconnect(); g.noclipConn = nil; return end
        if guestCfg.noclipOnlyWhenBlockReady and not g_isBlockReady() then return end
        if not lp.Character then return end
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function g_disableNoclip()
    if g.noclipConn then g.noclipConn:Disconnect(); g.noclipConn = nil end
    local c = lp.Character
    if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
end

-- KILLER VELOCITY TRACKING
svc.Run.RenderStepped:Connect(function(dt)
    for k in pairs(g.killerState) do if not k.Parent then g.killerState[k] = nil end end
    local kf = g_getTeam("Killers")
    if not kf then return end
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp then
            local s = g.killerState[killer] or {prevPos=hrp.Position, prevLook=hrp.CFrame.LookVector, vel=Vector3.new(), angVel=0}
            local nv = (hrp.Position - s.prevPos) / math.max(dt, 1e-6)
            s.vel = s.vel:Lerp(nv, 0.22)
            local look = hrp.CFrame.LookVector
            local dot = math.clamp(s.prevLook:Dot(look), -1, 1)
            local ang = math.acos(dot)
            local sign = (s.prevLook:Cross(look).Y >= 0) and 1 or -1
            local na = (ang / math.max(dt, 1e-6)) * sign
            s.angVel = s.angVel * (1 - 0.22) + na * 0.22
            s.prevPos = hrp.Position; s.prevLook = look
            g.killerState[killer] = s
        end
    end
end)

-- MAIN RENDER LOOP
svc.Run.RenderStepped:Connect(function()
    -- Aim punch
    if guestCfg.aimPunchActive and g.humanoid and g.hrp and g.punchAiming then
        local elapsed = tick() - g.punchLastTriggerTime
        if elapsed > guestCfg.aimPunchDuration then
            g.punchAiming = false
            if g.originalWS then
                g.humanoid.WalkSpeed = g.originalWS
                g.humanoid.JumpPower = g.originalJP
                g.humanoid.AutoRotate = g.originalAutoRotate
                g.originalWS = nil; g.originalJP = nil; g.originalAutoRotate = nil
            end
        else
            if not g.originalWS then
                g.originalWS = g.humanoid.WalkSpeed
                g.originalJP = g.humanoid.JumpPower
                -- Fix: if aimbot is active and has already set AutoRotate=false,
                -- use the aimbot's saved pre-lock value so we restore correctly
                if aim.targeting and aim.autoRotate ~= nil then
                    g.originalAutoRotate = aim.autoRotate
                else
                    g.originalAutoRotate = g.humanoid.AutoRotate
                end
            end
            g.humanoid.AutoRotate = false
            g.hrp.AssemblyAngularVelocity = Vector3.zero
            local kf = g_getTeam("Killers")
            if kf and g.hrp then
                local bestDist, targetHRP = math.huge, nil
                for _, killer in ipairs(kf:GetChildren()) do
                    local hrp = killer:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - g.hrp.Position).Magnitude
                        if d < bestDist then bestDist = d; targetHRP = hrp end
                    end
                end
                if targetHRP then
                    local pred = guestCfg.punchPrediction
                    local vel = targetHRP.AssemblyLinearVelocity
                    local predictPos = vel.Magnitude > 0.5 and (targetHRP.Position + vel * (pred / 60)) or targetHRP.Position
                    local dir = (predictPos - g.hrp.Position) * Vector3.new(1, 0, 1)
                    if dir.Magnitude > 0.01 then
                        g.hrp.CFrame = CFrame.new(g.hrp.Position, g.hrp.Position + dir.Unit)
                    end
                end
            end
        end
    end
    
    pcall(g_updateVision)
    pcall(g_updatePing)
    pcall(g_updateHDTCooldown)
    pcall(g_updateFPS)
end)

-- INIT
g_setupSoundHooks()
lp.CharacterAdded:Connect(function(c) task.delay(0.5, function() g_setupChar(c); if guestCfg.noclipEnabled then g_enableNoclip() end end) end)
if lp.Character then g_setupChar(lp.Character) end
if guestCfg.noclipEnabled then g_enableNoclip() end

-- ============================================================
-- UI - CORE BLOCK
-- ============================================================

local secCore = tabGuestCore:Section({ Title = "Core Block", Opened = true })

secCore:Toggle({ Title="Auto Block", Type="Checkbox", Default=guestCfg.autoBlockOn,
    Callback=function(v) guestCfg.autoBlockOn=v; saveGuestConfig() end })

secCore:Slider({ Title="Block Delay", Step=0.05, Value={Min=0,Max=2,Default=guestCfg.blockDelay},
    Callback=function(v) guestCfg.blockDelay=v; saveGuestConfig() end })

secCore:Slider({ Title="Auto Block Radius", Step=1, Value={Min=1,Max=50,Default=guestCfg.detectionRange},
    Callback=function(v) guestCfg.detectionRange=v; saveGuestConfig() end })

secCore:Toggle({ Title="Verify Facing Check", Type="Checkbox", Default=guestCfg.verifyFacingCheck,
    Callback=function(v) guestCfg.verifyFacingCheck=v; saveGuestConfig() end })

secCore:Slider({ Title="Vision Range", Step=0.5, Value={Min=1,Max=20,Default=guestCfg.visionRange},
    Callback=function(v) guestCfg.visionRange=v; saveGuestConfig() end })

secCore:Slider({ Title="Vision Angle", Step=1, Value={Min=1,Max=200,Default=guestCfg.visionAngle},
    Callback=function(v) guestCfg.visionAngle=v; saveGuestConfig() end })

secCore:Toggle({ Title="Show Vision Cone", Type="Checkbox", Default=guestCfg.showVisionCone,
    Callback=function(v) guestCfg.showVisionCone=v; saveGuestConfig(); if not v then g_cleanupVision() end end })

secCore:Toggle({ Title="No HDT Cooldown", Type="Checkbox", Default=guestCfg.noHDTCooldown,
    Callback=function(v) guestCfg.noHDTCooldown=v; saveGuestConfig() end })

secCore:Toggle({ Title="Block Cooldown Checker", Type="Checkbox", Default=guestCfg.hdtCooldownChecker,
    Callback=function(v) guestCfg.hdtCooldownChecker=v; saveGuestConfig(); if not v and g.hdtCooldownGui then g.hdtCooldownGui:Destroy(); g.hdtCooldownGui=nil; g.hdtCooldownLabel=nil end end })

secCore:Slider({ Title="Block Cooldown (s)", Step=0.05, Value={Min=0.05,Max=2,Default=guestCfg.blockCooldown},
    Callback=function(v) guestCfg.blockCooldown=v; saveGuestConfig() end })

secCore:Slider({ Title="Auto Punch Delay (s)", Step=0.05, Value={Min=0,Max=2,Default=guestCfg.autoPunchDelay},
    Callback=function(v) guestCfg.autoPunchDelay=v; saveGuestConfig() end })

secCore:Toggle({ Title="Auto Punch", Type="Checkbox", Default=guestCfg.autoPunchOn,
    Callback=function(v) guestCfg.autoPunchOn=v; saveGuestConfig() end })

secCore:Toggle({ Title="Aim Punch", Type="Checkbox", Default=guestCfg.aimPunchActive,
    Callback=function(v) guestCfg.aimPunchActive=v; saveGuestConfig(); if v and lp.Character then g_setupChar(lp.Character) end end })

secCore:Slider({ Title="Punch Prediction", Step=0.1, Value={Min=0,Max=10,Default=guestCfg.punchPrediction},
    Callback=function(v) guestCfg.punchPrediction=v; saveGuestConfig() end })

secCore:Input({ Title="Custom Punch Sound ID", Placeholder=tostring(guestCfg.customPunchSoundId),
    Callback=function(v) local n=tonumber(v); guestCfg.customPunchSoundId=n or 0; saveGuestConfig() end })

secCore:Slider({ Title="Aim Lock Duration (s)", Step=0.05, Value={Min=0.1,Max=2,Default=guestCfg.aimPunchDuration},
    Callback=function(v) guestCfg.aimPunchDuration=v; saveGuestConfig() end })

-- Cinematic Text
local secCine = tabGuestCore:Section({ Title = "Cinematic Text", Opened = false })
secCine:Toggle({ Title="Enable Cinematic Text", Type="Checkbox", Default=guestCfg.cinematicTextEnabled,
    Callback=function(v) guestCfg.cinematicTextEnabled=v; saveGuestConfig() end })
secCine:Input({ Title="Text Content", Placeholder=guestCfg.cinematicText,
    Callback=function(v) if v ~= "" then guestCfg.cinematicText=v; saveGuestConfig() end end })

-- Reverse Section
local secReverse = tabGuestCore:Section({ Title = "Reverse", Opened = false })
secReverse:Toggle({ Title="Enable Reverse", Type="Checkbox", Default=guestCfg.reverseEnabled,
    Callback=function(v) guestCfg.reverseEnabled=v; saveGuestConfig() end })
secReverse:Paragraph({ Title="Info", Content="When enabled, the block zone is centered on YOU instead of the killer." })

-- Legacy Section
local secLegacy = tabGuestCore:Section({ Title = "Legacy Facing", Opened = false })
secLegacy:Toggle({ Title="Enable Legacy Facing", Type="Checkbox", Default=guestCfg.legacyFacingEnabled,
    Callback=function(v) guestCfg.legacyFacingEnabled=v; saveGuestConfig() end })
secLegacy:Slider({ Title="Vision Range", Step=0.5, Value={Min=1,Max=20,Default=guestCfg.legacyVisionRange},
    Callback=function(v) guestCfg.legacyVisionRange=v; saveGuestConfig() end })
secLegacy:Slider({ Title="Vision Angle", Step=1, Value={Min=1,Max=200,Default=guestCfg.legacyVisionAngle},
    Callback=function(v) guestCfg.legacyVisionAngle=v; saveGuestConfig() end })
secLegacy:Toggle({ Title="Show Vision Range", Type="Checkbox", Default=guestCfg.legacyShowVisionRange,
    Callback=function(v) guestCfg.legacyShowVisionRange=v; saveGuestConfig() end })

-- Misc Section
local secMisc = tabGuestCore:Section({ Title = "Misc", Opened = false })
secMisc:Toggle({ Title="Smart Delay", Type="Checkbox", Default=guestCfg.smartDelayEnabled,
    Callback=function(v) guestCfg.smartDelayEnabled=v; saveGuestConfig() end })
secMisc:Toggle({ Title="Manual Drag", Type="Checkbox", Default=guestCfg.manualDragEnabled,
    Callback=function(v) guestCfg.manualDragEnabled=v; saveGuestConfig() end })
secMisc:Toggle({ Title="Noclip", Type="Checkbox", Default=guestCfg.noclipEnabled,
    Callback=function(v) guestCfg.noclipEnabled=v; saveGuestConfig(); if v then g_enableNoclip() else g_disableNoclip() end end })
secMisc:Toggle({ Title="Noclip Only When Block Ready", Type="Checkbox", Default=guestCfg.noclipOnlyWhenBlockReady,
    Callback=function(v) guestCfg.noclipOnlyWhenBlockReady=v; saveGuestConfig() end })
secMisc:Toggle({ Title="FPS Counter", Type="Checkbox", Default=guestCfg.fpsCounterEnabled,
    Callback=function(v) guestCfg.fpsCounterEnabled=v; saveGuestConfig(); if not v and g.fpsGui then g.fpsGui:Destroy(); g.fpsGui=nil; g.fpsLabel=nil end end })
secMisc:Toggle({ Title="Ping Checker", Type="Checkbox", Default=guestCfg.pingCheckerEnabled,
    Callback=function(v) guestCfg.pingCheckerEnabled=v; saveGuestConfig(); if not v and g.pingLabel then g.pingLabel.Parent.Parent:Destroy(); g.pingLabel=nil end end })

-- Control
local secCtrl = tabGuestCore:Section({ Title = "Control", Opened = true })
secCtrl:Button({ Title="Save Config", Callback=function() saveGuestConfig(); ui:Notify({Title="Config Saved", Content="Guest settings saved", Duration=2}) end })
secCtrl:Button({ Title="Load Config", Callback=function() loadGuestConfig(); ui:Notify({Title="Config Loaded", Content="Guest settings loaded", Duration=2}) end })
secCtrl:Button({ Title="Unload Guest Block", Callback=function()
    pcall(function()
        if g.aimConnection then g.aimConnection:Disconnect() end
        if g.noclipConn then g.noclipConn:Disconnect() end
        g_cleanupVision()
        if g.cinematicGui then g.cinematicGui:Destroy() end
        if g.hdtCooldownGui then g.hdtCooldownGui:Destroy() end
        if g.fpsGui then g.fpsGui:Destroy() end
        if g.pingLabel then g.pingLabel.Parent.Parent:Destroy() end
        for sound in pairs(g.soundHooks) do
            pcall(function()
                if g.soundHooks[sound] then
                    for _, conn in ipairs(g.soundHooks[sound]) do
                        if type(conn) ~= "string" and conn and conn.Disconnect then
                            pcall(function() conn:Disconnect() end)
                        end
                    end
                end
            end)
            g.soundHooks[sound] = nil
            g.soundBlockedUntil[sound] = nil
        end
        g.killerState = {}
    end)
    tabGuestCore:Destroy()
    ui:Notify({Title="Guest Block Unloaded", Content="All features disabled", Duration=2})
end })

print("[Guest Core] Loaded")

end -- tabGuestCore

-- ============================================================
-- GUEST 1337 - HDT TAB (WORKING IMPLEMENTATION)
-- ============================================================

do -- tabGuestHDT
local tabGuestHDT = win:Tab({ Title = "Guest HDT", Icon = "target" })

-- Load config
local GUEST_CONFIG_PATH = "betrayalhub/guest1337_config.json"
local guestCfg = {}
pcall(function()
    if fs.hasFile(GUEST_CONFIG_PATH) then
        local data = fs.read(GUEST_CONFIG_PATH)
        if data and #data > 0 then
            local decoded = svc.Http:JSONDecode(data)
            if decoded and type(decoded) == "table" then
                for k, v in pairs(decoded) do guestCfg[k] = v end
            end
        end
    end
end)

-- HDT Settings
guestCfg.hdtEnabled = guestCfg.hdtEnabled or false
guestCfg.hdtSpeed = guestCfg.hdtSpeed or 5.6
guestCfg.hdtDuration = guestCfg.hdtDuration or 1.4
guestCfg.hdtRange = guestCfg.hdtRange or 6
guestCfg.hdtDelay = guestCfg.hdtDelay or 0
guestCfg.hdtShowRange = guestCfg.hdtShowRange or false
guestCfg.hdtFaceKiller = guestCfg.hdtFaceKiller or true

local function saveCfg()
    pcall(function()
        if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
        fs.write(GUEST_CONFIG_PATH, svc.Http:JSONEncode(guestCfg))
    end)
end

-- HDT STATE
local hdt = {
    active = false,
    target = nil,
    targetHRP = nil,
    connection = nil,
    rangePart = nil,
    origWalkSpeed = nil,
    origJumpPower = nil,
    origPlatformStand = nil,
    origAutoRotate = nil,
    debounce = false,
    animator = nil,
}

-- BLOCK ANIMATION IDs (from working script)
local blockAnimIds = {
    "72722244508749",
    "96959123077498",
    "95802026624883"
}

-- UTILITY FUNCTIONS
local function hdt_getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function hdt_getHum()
    local c = lp.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function hdt_getAnimator()
    local hum = hdt_getHum()
    if hum then
        return hum:FindFirstChildOfClass("Animator")
    end
    return nil
end

local function hdt_getTeam(name)
    local r = svc.WS:FindFirstChild("Players")
    return r and r:FindFirstChild(name)
end

-- Find the best killer target
local function hdt_findTarget()
    local root = hdt_getRoot()
    if not root then return nil, nil end
    
    local kf = hdt_getTeam("Killers")
    if not kf then return nil, nil end
    
    local best, bestDist = nil, math.huge
    local myPos = root.Position
    
    for _, killer in ipairs(kf:GetChildren()) do
        if killer ~= lp.Character then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            local hum = killer:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                if dist < bestDist and dist <= guestCfg.hdtRange then
                    bestDist = dist
                    best = killer
                end
            end
        end
    end
    
    if best then
        local hrp = best:FindFirstChild("HumanoidRootPart")
        return best, hrp
    end
    return nil, nil
end

-- MAIN HDT EXECUTION (using BodyVelocity like the working script)
local function hdt_execute(killer, killerHRP)
    if hdt.debounce then return end
    if not killer or not killerHRP or not killerHRP.Parent then return end
    
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    hdt.debounce = true
    hdt.target = killer
    hdt.targetHRP = killerHRP
    
    print("[HDT] 🚀 Dragging to:", killer.Name)
    
    -- Save original values
    hdt.origWalkSpeed = hum.WalkSpeed
    hdt.origJumpPower = hum.JumpPower
    hdt.origPlatformStand = hum.PlatformStand
    hdt.origAutoRotate = hum.AutoRotate
    
    -- Disable movement
    hum.WalkSpeed = 0
    hum.JumpPower = 0
    hum.PlatformStand = false
    hum.AutoRotate = false
    
    -- Create BodyVelocity for smooth pulling (same as working script)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    
    local startTime = tick()
    local duration = guestCfg.hdtDuration
    local speed = guestCfg.hdtSpeed
    
    -- Main HDT loop
    hdt.connection = svc.Run.Heartbeat:Connect(function(dt)
        local elapsed = tick() - startTime
        
        -- Stop conditions
        if elapsed >= duration or 
           not guestCfg.hdtEnabled or 
           not killer.Parent or
           not killerHRP.Parent or
           not root.Parent or
           not hum.Parent then
            hdt.cleanup()
            return
        end
        
        -- Calculate direction to target
        local toTarget = (killerHRP.Position - root.Position)
        local dist = toTarget.Magnitude
        
        if dist > 1 then
            -- Pull toward target using BodyVelocity
            local horiz = Vector3.new(toTarget.X, 0, toTarget.Z)
            if horiz.Magnitude > 0.01 then
                local dir = horiz.Unit
                bv.Velocity = Vector3.new(dir.X * speed, bv.Velocity.Y, dir.Z * speed)
            end
            
            -- Face the killer if enabled
            if guestCfg.hdtFaceKiller then
                local faceDir = Vector3.new(
                    killerHRP.Position.X - root.Position.X,
                    0,
                    killerHRP.Position.Z - root.Position.Z
                )
                if faceDir.Magnitude > 0.1 then
                    faceDir = faceDir.Unit
                    local targetCF = CFrame.new(root.Position, root.Position + faceDir)
                    root.CFrame = root.CFrame:Lerp(targetCF, 0.5)
                end
            end
        else
            -- Close enough, stop pulling
            bv.Velocity = Vector3.new(0, bv.Velocity.Y, 0)
            if guestCfg.hdtFaceKiller then
                local faceDir = Vector3.new(
                    killerHRP.Position.X - root.Position.X,
                    0,
                    killerHRP.Position.Z - root.Position.Z
                )
                if faceDir.Magnitude > 0.1 then
                    faceDir = faceDir.Unit
                    root.CFrame = CFrame.new(root.Position, root.Position + faceDir)
                end
            end
            -- Don't stop early - let duration slider handle when HDT ends
        end
    end)
    
    -- Safety timeout (cleanup after duration + 0.5s)
    task.delay(duration + 0.5, function()
        if hdt.debounce then
            hdt.cleanup()
        end
    end)
end

-- Cleanup function
function hdt.cleanup()
    if hdt.connection then
        hdt.connection:Disconnect()
        hdt.connection = nil
    end
    
    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- Remove BodyVelocity
        if root then
            local bv = root:FindFirstChildWhichIsA("BodyVelocity")
            if bv then bv:Destroy() end
            root.AssemblyLinearVelocity = Vector3.zero
        end
        
        -- Restore values
        if hum then
            if hdt.origWalkSpeed then
                hum.WalkSpeed = hdt.origWalkSpeed
            end
            if hdt.origJumpPower then
                hum.JumpPower = hdt.origJumpPower
            end
            if hdt.origPlatformStand ~= nil then
                hum.PlatformStand = hdt.origPlatformStand
            end
            if hdt.origAutoRotate ~= nil then
                hum.AutoRotate = hdt.origAutoRotate
            end
        end
    end
    
    hdt.debounce = false
    hdt.target = nil
    hdt.targetHRP = nil
    hdt.origWalkSpeed = nil
    hdt.origJumpPower = nil
    hdt.origPlatformStand = nil
    hdt.origAutoRotate = nil
    
    print("[HDT] 🛑 HDT stopped")
end

-- DETECT BLOCK ANIMATION (THIS IS THE KEY FIX - from working script)
local function hdt_setupBlockDetection()
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        hdt.animator = animator
        
        -- Watch for block animation playing
        local function checkBlockAnimation()
            if not guestCfg.hdtEnabled then return end
            if not animator then return end
            
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local animId = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
                if animId and table.find(blockAnimIds, animId) then
                    local timePos = 0
                    pcall(function() timePos = track.TimePosition or 0 end)
                    if timePos <= 0.12 then
                        local killer, killerHRP = hdt_findTarget()
                        if killer and killerHRP then
                            print("[HDT] 🛡️ Block animation detected!")
                            task.wait(guestCfg.hdtDelay)
                            task.spawn(hdt_execute, killer, killerHRP)
                        end
                    end
                end
            end
        end
        
        -- Check every frame
        svc.Run.RenderStepped:Connect(function()
            pcall(checkBlockAnimation)
        end)
    end)
end

-- Also check if Better Detection (AntiFlick) is active and trigger HDT from it
local function hdt_setupAntiFlickDetection()
    task.spawn(function()
        while true do
            svc.Run.Heartbeat:Wait()
            
            if not guestCfg.hdtEnabled then
                task.wait(0.15)
                continue
            end
            
            local char = lp.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            if not myRoot then 
                task.wait(0.15) 
                continue 
            end
            
            -- Look for AntiFlickZone parts near the player
            for _, part in ipairs(svc.WS:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "AntiFlickZone" then
                    if (part.Position - myRoot.Position).Magnitude <= guestCfg.hdtRange then
                        if not hdt.debounce then
                            local nearest = hdt_findTarget()
                            if nearest then
                                print("[HDT] 🎯 AntiFlickZone detected!")
                                task.wait(guestCfg.hdtDelay)
                                task.spawn(hdt_execute, nearest)
                            end
                        end
                        break
                    end
                end
            end
            task.wait(0.12)
        end
    end)
end

-- Initialize
task.spawn(hdt_setupBlockDetection)
task.spawn(hdt_setupAntiFlickDetection)

-- Range visualization
local function hdt_updateRange()
    if not guestCfg.hdtShowRange then
        if hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
        return
    end
    
    local root = hdt_getRoot()
    if not root then return end
    
    if not hdt.rangePart then
        hdt.rangePart = Instance.new("Part")
        hdt.rangePart.Name = "HDTRange"
        hdt.rangePart.Anchored = true
        hdt.rangePart.CanCollide = false
        hdt.rangePart.Shape = Enum.PartType.Ball
        hdt.rangePart.Transparency = 0.6
        hdt.rangePart.Color = Color3.fromRGB(0, 255, 100)
        hdt.rangePart.Material = Enum.Material.ForceField
        hdt.rangePart.Parent = svc.WS
    end
    
    local r = guestCfg.hdtRange
    hdt.rangePart.Size = Vector3.new(r * 2, r * 2, r * 2)
    hdt.rangePart.CFrame = CFrame.new(root.Position)
end

svc.Run.RenderStepped:Connect(hdt_updateRange)

-- Handle character respawn
lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if hdt.debounce then hdt.cleanup() end
end)

-- ============================================================
-- UI - HDT
-- ============================================================

local secHDT = tabGuestHDT:Section({ Title = "Hitbox Dragging (HDT)", Opened = true })

secHDT:Toggle({
    Title = "Enable HDT",
    Description = "Pulls you into the killer when you block",
    Type = "Checkbox",
    Default = guestCfg.hdtEnabled,
    Callback = function(v)
        guestCfg.hdtEnabled = v
        saveCfg()
        if not v and hdt.debounce then hdt.cleanup() end
    end
})

secHDT:Slider({
    Title = "Pull Speed",
    Description = "How fast you get pulled",
    Step = 0.1,
    Value = { Min = 1, Max = 20, Default = guestCfg.hdtSpeed },
    Callback = function(v)
        guestCfg.hdtSpeed = v
        saveCfg()
    end
})

secHDT:Slider({
    Title = "Pull Duration (s)",
    Description = "How long the pull lasts",
    Step = 0.1,
    Value = { Min = 0.5, Max = 3.0, Default = guestCfg.hdtDuration },
    Callback = function(v)
        guestCfg.hdtDuration = v
        saveCfg()
    end
})

secHDT:Slider({
    Title = "Detection Range",
    Description = "How far to look for killers",
    Step = 1,
    Value = { Min = 3, Max = 20, Default = guestCfg.hdtRange },
    Callback = function(v)
        guestCfg.hdtRange = v
        saveCfg()
    end
})

secHDT:Slider({
    Title = "Delay Before Pull (s)",
    Description = "Delay before starting the pull",
    Step = 0.05,
    Value = { Min = 0, Max = 0.5, Default = guestCfg.hdtDelay },
    Callback = function(v)
        guestCfg.hdtDelay = v
        saveCfg()
    end
})

secHDT:Toggle({
    Title = "Face Killer",
    Description = "Automatically face the killer while pulling",
    Type = "Checkbox",
    Default = guestCfg.hdtFaceKiller,
    Callback = function(v)
        guestCfg.hdtFaceKiller = v
        saveCfg()
    end
})

secHDT:Toggle({
    Title = "Show Detection Range",
    Description = "Visual indicator of your HDT range",
    Type = "Checkbox",
    Default = guestCfg.hdtShowRange,
    Callback = function(v)
        guestCfg.hdtShowRange = v
        saveCfg()
        if not v and hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
    end
})

-- Test Button
secHDT:Button({
    Title = "🧪 Test HDT (Force Pull)",
    Callback = function()
        if not guestCfg.hdtEnabled then
            ui:Notify({
                Title = "HDT Disabled",
                Content = "Enable HDT first!",
                Duration = 2
            })
            return
        end
        
        local killer, killerHRP = hdt_findTarget()
        if killer and killerHRP then
            print("[HDT] 🧪 Force pulling to:", killer.Name)
            task.spawn(hdt_execute, killer, killerHRP)
            ui:Notify({
                Title = "HDT Test",
                Content = "Pulling to " .. killer.Name,
                Duration = 2
            })
        else
            print("[HDT] ❌ No killers within range")
            ui:Notify({
                Title = "No Target",
                Content = "No killers within " .. guestCfg.hdtRange .. " studs",
                Duration = 2
            })
        end
    end
})

-- Stop Button
secHDT:Button({
    Title = "⏹️ Stop HDT",
    Callback = function()
        if hdt.debounce then
            hdt.cleanup()
            ui:Notify({
                Title = "HDT Stopped",
                Content = "Pull canceled",
                Duration = 1
            })
        end
    end
})

-- Unload
secHDT:Button({
    Title = "Unload HDT",
    Callback = function()
        guestCfg.hdtEnabled = false
        if hdt.debounce then hdt.cleanup() end
        if hdt.rangePart then
            hdt.rangePart:Destroy()
            hdt.rangePart = nil
        end
        saveCfg()
        tabGuestHDT:Destroy()
        ui:Notify({
            Title = "HDT Unloaded",
            Content = "All features disabled",
            Duration = 2
        })
    end
})

print("[Guest HDT] ✅ Loaded successfully")

end -- tabGuestHDT

-- ============================================================
-- GUEST 1337 - BETTER DETECTION TAB
-- ============================================================

do -- tabGuestBetter
local tabGuestBetter = win:Tab({ Title = "Guest Detect", Icon = "search" })

-- Load config
local GUEST_CONFIG_PATH = "betrayalhub/guest1337_config.json"
local guestCfg = {}
pcall(function()
    if fs.hasFile(GUEST_CONFIG_PATH) then
        local data = fs.read(GUEST_CONFIG_PATH)
        if data and #data > 0 then
            local decoded = svc.Http:JSONDecode(data)
            if decoded and type(decoded) == "table" then
                for k, v in pairs(decoded) do guestCfg[k] = v end
            end
        end
    end
end)

guestCfg.betterDetectionEnabled = guestCfg.betterDetectionEnabled or false
guestCfg.betterDetectionX = guestCfg.betterDetectionX or 3
guestCfg.betterDetectionY = guestCfg.betterDetectionY or 2.5
guestCfg.betterDetectionZ = guestCfg.betterDetectionZ or 4
guestCfg.betterDetectionMultiplier = guestCfg.betterDetectionMultiplier or 2.4
guestCfg.betterDetectionSegments = guestCfg.betterDetectionSegments or 14
guestCfg.betterStartDist = guestCfg.betterStartDist or 2.2
guestCfg.betterStepDist = guestCfg.betterStepDist or 0.05
guestCfg.betterPreDelay = guestCfg.betterPreDelay or 0.15
guestCfg.betterStagger = guestCfg.betterStagger or 0.03
guestCfg.betterPredForward = guestCfg.betterPredForward or 1.1
guestCfg.betterPredTurn = guestCfg.betterPredTurn or 1.2

local function saveCfg()
    pcall(function()
        if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
        fs.write(GUEST_CONFIG_PATH, svc.Http:JSONEncode(guestCfg))
    end)
end

-- BETTER DETECTION STATE
local bd = { remote = nil, killerState = {} }

local function bd_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function bd_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function bd_getTeam(n) local r=svc.WS:FindFirstChild("Players"); return r and r:FindFirstChild(n) end
local function bd_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local function bd_fireBlock()
    if not bd.remote then
        pcall(function()
            bd.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if bd.remote then pcall(function() bd.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function bd_firePunch()
    if not bd.remote then
        pcall(function()
            bd.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if bd.remote then pcall(function() bd.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function bd_isPointInsidePart(part, point)
    if not part or not point then return false end
    local rel = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5
    return math.abs(rel.X) <= half.X + 0.001
        and math.abs(rel.Y) <= half.Y + 0.001
        and math.abs(rel.Z) <= half.Z + 0.001
end

local function bd_spawnDetection(killer)
    if not guestCfg.betterDetectionEnabled or not killer then return end
    local hrp = killer:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local state = bd.killerState[killer]
    if not state then return end
    
    local size = Vector3.new(
        guestCfg.betterDetectionX,
        guestCfg.betterDetectionY,
        guestCfg.betterDetectionZ
    ) * guestCfg.betterDetectionMultiplier
    
    local count = math.max(1, guestCfg.betterDetectionSegments)
    local qh = bd_getQueryHitbox(killer)
    local origin = qh or hrp
    
    local vel = state.vel or Vector3.zero
    local angVel = state.angVel or 0
    local snapPos = origin.Position
    local snapCF = origin.CFrame
    
    local PRED_SECONDS_FORWARD = 0.25
    local PRED_SECONDS_LATERAL = 0.18
    local PRED_MAX_FORWARD = 6
    local PRED_MAX_LATERAL = 4
    local ANG_TURN_MULTIPLIER = 0.6
    
    local fwdSpd = vel:Dot(snapCF.LookVector)
    local latSpd = vel:Dot(snapCF.RightVector)
    local trnLat = angVel * ANG_TURN_MULTIPLIER * guestCfg.betterPredTurn
    
    local fwdPred = math.clamp(
        fwdSpd * PRED_SECONDS_FORWARD * guestCfg.betterPredForward,
        -PRED_MAX_FORWARD, PRED_MAX_FORWARD)
    local latPred = math.clamp(
        (latSpd * PRED_SECONDS_LATERAL + trnLat) * guestCfg.betterPredForward,
        -PRED_MAX_LATERAL, PRED_MAX_LATERAL)
    
    task.spawn(function()
        if guestCfg.betterPreDelay > 0 then task.wait(guestCfg.betterPreDelay) end
        
        for i = 1, count do
            if not origin or not origin.Parent then break end
            local t = (i - 1) / math.max(count - 1, 1)
            local dist = guestCfg.betterStartDist + (i - 1) * guestCfg.betterStepDist + fwdPred
            local lerpPos = snapPos:Lerp(origin.Position, t * 0.4)
            local spawnPos = lerpPos
                + snapCF.LookVector * dist
                + snapCF.RightVector * latPred
            
            local part = Instance.new("Part")
            part.Name = "BetterDetection"
            part.Size = size
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = true
            part.Transparency = 0.75
            part.Color = Color3.fromRGB(0, 150, 255)
            part.Material = Enum.Material.ForceField
            part.CFrame = CFrame.lookAt(spawnPos, lerpPos)
            part.Parent = svc.WS
            svc.Debris:AddItem(part, 0.15)
            
            local root = bd_getRoot()
            if root and bd_isPointInsidePart(part, root.Position) then
                -- ✅ FIX: Add block delay before firing
                if guestCfg.blockDelay and guestCfg.blockDelay > 0 then
                    task.wait(guestCfg.blockDelay)
                end
                bd_fireBlock()
                if guestCfg.autoPunchOn then
                    task.delay(guestCfg.autoPunchDelay, bd_firePunch)
                end
                break
            end
            
            if i < count and guestCfg.betterStagger > 0 then
                task.wait(guestCfg.betterStagger)
            end
        end
    end)
end

-- Track killer velocity
svc.Run.RenderStepped:Connect(function(dt)
    for k in pairs(bd.killerState) do if not k.Parent then bd.killerState[k] = nil end end
    local kf = bd_getTeam("Killers")
    if not kf then return end
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if hrp then
            local s = bd.killerState[killer] or {prevPos=hrp.Position, prevLook=hrp.CFrame.LookVector, vel=Vector3.new(), angVel=0}
            local nv = (hrp.Position - s.prevPos) / math.max(dt, 1e-6)
            s.vel = s.vel:Lerp(nv, 0.22)
            local look = hrp.CFrame.LookVector
            local dot = math.clamp(s.prevLook:Dot(look), -1, 1)
            local ang = math.acos(dot)
            local sign = (s.prevLook:Cross(look).Y >= 0) and 1 or -1
            local na = (ang / math.max(dt, 1e-6)) * sign
            s.angVel = s.angVel * (1 - 0.22) + na * 0.22
            s.prevPos = hrp.Position; s.prevLook = look
            bd.killerState[killer] = s
        end
    end
end)

-- Hook remote for trigger
local function bd_setupHook()
    local remote = nil
    pcall(function()
        remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
    end)
    if not remote then return end
    
    remote.OnClientEvent:Connect(function(action, data)
        if not guestCfg.betterDetectionEnabled or action ~= "UseActorAbility" then return end
        if typeof(data) ~= "table" or not data[1] then return end
        
        local name = ""
        pcall(function() name = buffer.tostring(data[1]) end)
        if not name or not name:find("Punch") then return end
        
        local root = bd_getRoot()
        if not root then return end
        
        local kf = bd_getTeam("Killers")
        if not kf then return end
        
        local best, bd2 = nil, math.huge
        for _, killer in ipairs(kf:GetChildren()) do
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bd2 and d <= guestCfg.detectionRange then
                    bd2 = d; best = killer
                end
            end
        end
        
        if best then task.spawn(bd_spawnDetection, best) end
    end)
end

task.spawn(bd_setupHook)

-- ============================================================
-- UI - BETTER DETECTION
-- ============================================================

local secBetter = tabGuestBetter:Section({ Title = "Better Detection", Opened = true })

secBetter:Toggle({ Title="Enable Better Detection", Type="Checkbox", Default=guestCfg.betterDetectionEnabled,
    Callback=function(v) guestCfg.betterDetectionEnabled=v; saveCfg() end })

secBetter:Input({ Title="Hitbox X", Placeholder=tostring(guestCfg.betterDetectionX),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionX=n; saveCfg() end end })

secBetter:Input({ Title="Hitbox Y", Placeholder=tostring(guestCfg.betterDetectionY),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionY=n; saveCfg() end end })

secBetter:Input({ Title="Hitbox Z (forward)", Placeholder=tostring(guestCfg.betterDetectionZ),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionZ=n; saveCfg() end end })

secBetter:Input({ Title="Multiplier", Placeholder=tostring(guestCfg.betterDetectionMultiplier),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterDetectionMultiplier=n; saveCfg() end end })

secBetter:Input({ Title="Segments", Placeholder=tostring(guestCfg.betterDetectionSegments),
    Callback=function(v) local n=tonumber(v); if n then n=math.max(1,math.floor(n)); guestCfg.betterDetectionSegments=n; saveCfg() end end })

secBetter:Input({ Title="Start Distance", Placeholder=tostring(guestCfg.betterStartDist),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStartDist=n; saveCfg() end end })

secBetter:Input({ Title="Step Distance", Placeholder=tostring(guestCfg.betterStepDist),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStepDist=n; saveCfg() end end })

secBetter:Input({ Title="Pre-Delay (s)", Placeholder=tostring(guestCfg.betterPreDelay),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPreDelay=n; saveCfg() end end })

secBetter:Input({ Title="Stagger (s)", Placeholder=tostring(guestCfg.betterStagger),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterStagger=n; saveCfg() end end })

secBetter:Input({ Title="Prediction Forward", Placeholder=tostring(guestCfg.betterPredForward),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPredForward=n; saveCfg() end end })

secBetter:Input({ Title="Prediction Turn", Placeholder=tostring(guestCfg.betterPredTurn),
    Callback=function(v) local n=tonumber(v); if n then guestCfg.betterPredTurn=n; saveCfg() end end })

secBetter:Button({ Title="Unload Better Detection", Callback=function()
    guestCfg.betterDetectionEnabled = false
    bd.killerState = {}
    tabGuestBetter:Destroy()
    ui:Notify({Title="Better Detection Unloaded", Content="Features disabled", Duration=2})
end })

print("[Guest Better Detection] Loaded")

end -- tabGuestBetter

-- ============================================================
-- GUEST 1337 - LINE BLOCK TAB
-- ============================================================

do -- tabGuestLine
local tabGuestLine = win:Tab({ Title = "Guest Line", Icon = "minus" })

-- Load config
local GUEST_CONFIG_PATH = "betrayalhub/guest1337_config.json"
local guestCfg = {}
pcall(function()
    if fs.hasFile(GUEST_CONFIG_PATH) then
        local data = fs.read(GUEST_CONFIG_PATH)
        if data and #data > 0 then
            local decoded = svc.Http:JSONDecode(data)
            if decoded and type(decoded) == "table" then
                for k, v in pairs(decoded) do guestCfg[k] = v end
            end
        end
    end
end)

guestCfg.lineBlockEnabled = guestCfg.lineBlockEnabled or false
guestCfg.lineBlockLength = guestCfg.lineBlockLength or 15
guestCfg.lineBlockRadius = guestCfg.lineBlockRadius or 1.5
guestCfg.lineBlockDelay = guestCfg.lineBlockDelay or 0.05
guestCfg.lineBlockFacingDuration = guestCfg.lineBlockFacingDuration or 0.1
guestCfg.lineBlockMinDot = guestCfg.lineBlockMinDot or 0.5
guestCfg.blockCooldown = guestCfg.blockCooldown or 0.35
guestCfg.autoPunchOn = guestCfg.autoPunchOn or false
guestCfg.autoPunchDelay = guestCfg.autoPunchDelay or 0.3

local function saveCfg()
    pcall(function()
        if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
        fs.write(GUEST_CONFIG_PATH, svc.Http:JSONEncode(guestCfg))
    end)
end

-- LINE BLOCK STATE
local line = {
    parts = {},
    facingSince = {},
    pendingKillers = {},
    animConns = {},
    soundKillers = {},
    lastBlockTime = 0,
    remote = nil,
}

local function line_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function line_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end
local function line_getTeam(n) local r=svc.WS:FindFirstChild("Players"); return r and r:FindFirstChild(n) end
local function line_getQueryHitbox(m)
    if not m then return nil end
    local q = m:FindFirstChild("QueryHitbox")
    if q and q:IsA("BasePart") then return q end
    for _, c in ipairs(m:GetChildren()) do
        local n = c:FindFirstChild("QueryHitbox")
        if n and n:IsA("BasePart") then return n end
    end
    return nil
end

local g_trackedPunchAnims = {
    ["87259391926321"]=true,["140703210927645"]=true,["136007065400978"]=true,["129843313690921"]=true,
    ["86709774283672"]=true, ["108807732150251"]=true,["138040001965654"]=true,["86096387000557"]=true,
    ["81905101227053"]=true, ["127777649118195"]=true,["99100240941590"]=true, ["92831180929659"]=true,
    ["112081768119093"]=true,["117587689359268"]=true,["91830732867282"]=true, ["91730605416216"]=true,
    ["100184164753080"]=true,
}

local function line_fireBlock()
    if not line.remote then
        pcall(function()
            line.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if line.remote then pcall(function() line.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Block")}) end) end
end

local function line_firePunch()
    if not line.remote then
        pcall(function()
            line.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if line.remote then pcall(function() line.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function line_isBlockReady()
    local ui = lp:FindFirstChild("PlayerGui")
    if ui then
        local m = ui:FindFirstChild("MainUI")
        if m then
            local ac = m:FindFirstChild("AbilityContainer")
            if ac then
                local bl = ac:FindFirstChild("Block")
                if bl then
                    local ct = bl:FindFirstChild("CooldownTime")
                    if ct and ct:IsA("TextLabel") then
                        local num = ct.Text:match("[%d%.]+")
                        if num then
                            local v = tonumber(num)
                            return not v or v <= 0
                        end
                        return true
                    end
                end
            end
        end
    end
    return tick() - line.lastBlockTime >= guestCfg.blockCooldown
end

local function line_pointInCylinder(origin, look, length, radius, point)
    local offset = point - origin
    local depth = offset:Dot(look)
    if depth < 0 or depth > length then return false end
    local perp = (offset - look * depth).Magnitude
    return perp <= radius
end

local function line_cleanKiller(killer)
    if line.parts[killer] then
        pcall(function() line.parts[killer]:Destroy() end)
        line.parts[killer] = nil
    end
    line.facingSince[killer] = nil
    line.pendingKillers[killer] = nil
    line.soundKillers[killer] = nil
    if line.animConns[killer] then
        pcall(function() line.animConns[killer]:Disconnect() end)
        line.animConns[killer] = nil
    end
end

local function line_hookKillerAnim(killer)
    if line.animConns[killer] then return end
    local hum = killer:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then return end
    
    line.animConns[killer] = anim.AnimationPlayed:Connect(function(track)
        local id = track.Animation.AnimationId:match("%d+")
        if id and g_trackedPunchAnims[id] then
            line.pendingKillers[killer] = true
            task.delay(0.6, function()
                line.pendingKillers[killer] = nil
            end)
        end
    end)
end

local function line_update()
    local root = line_getRoot()
    local now = tick()
    
    for killer in pairs(line.parts) do
        if not killer.Parent then line_cleanKiller(killer) end
    end
    
    if not guestCfg.lineBlockEnabled then
        for killer in pairs(line.parts) do line_cleanKiller(killer) end
        for killer in pairs(line.animConns) do line_cleanKiller(killer) end
        return
    end
    
    if not root then return end
    
    local kf = line_getTeam("Killers")
    if not kf then return end
    
    for _, killer in ipairs(kf:GetChildren()) do
        local hrp = killer:FindFirstChild("HumanoidRootPart")
        if not hrp then
            line_cleanKiller(killer)
        else
            line_hookKillerAnim(killer)
            
            local part = line.parts[killer]
            if not part or not part.Parent then
                part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Transparency = 0.45
                part.Parent = svc.WS
                line.parts[killer] = part
            end
            
            local qh = line_getQueryHitbox(killer)
            local origin = qh or hrp
            local look = origin.CFrame.LookVector
            local halfLen = guestCfg.lineBlockLength / 2
            local midPt = origin.Position + look * halfLen
            local diam = guestCfg.lineBlockRadius * 2
            
            part.Size = Vector3.new(diam, diam, guestCfg.lineBlockLength)
            part.CFrame = CFrame.new(midPt, midPt + look)
            
            local onLine = line_pointInCylinder(
                origin.Position, look,
                guestCfg.lineBlockLength, guestCfg.lineBlockRadius,
                root.Position
            )
            
            local toGuest = root.Position - origin.Position
            local dist = toGuest.Magnitude
            local facingDot = dist > 0.1 and look:Dot(toGuest.Unit) or 0
            
            if facingDot >= guestCfg.lineBlockMinDot then
                if not line.facingSince[killer] then
                    line.facingSince[killer] = now
                end
            else
                line.facingSince[killer] = nil
            end
            
            local facedFor = line.facingSince[killer] and (now - line.facingSince[killer]) or 0
            local soundActive = line.soundKillers[killer] and (now - line.soundKillers[killer]) <= 0.35
            
            if onLine then
                part.Color = Color3.fromRGB(255, 40, 40)
            elseif line.pendingKillers[killer] or soundActive then
                part.Color = Color3.fromRGB(255, 215, 0)
            else
                part.Color = Color3.fromRGB(235, 235, 255)
            end
            
            if onLine and (line.pendingKillers[killer] or soundActive)
                and facedFor >= guestCfg.lineBlockFacingDuration
                and (now - line.lastBlockTime) >= guestCfg.blockCooldown
                and line_isBlockReady()
            then
                line.lastBlockTime = now
                -- ✅ FIX: Add block delay before firing
                if guestCfg.lineBlockDelay and guestCfg.lineBlockDelay > 0 then
                    task.wait(guestCfg.lineBlockDelay)
                end
                line_fireBlock()
                if guestCfg.autoPunchOn then
                    task.delay(guestCfg.autoPunchDelay, line_firePunch)
                end
            end
        end
    end
end

svc.Run.RenderStepped:Connect(line_update)

-- ============================================================
-- UI - LINE BLOCK
-- ============================================================

local secLine = tabGuestLine:Section({ Title = "Line Block", Opened = true })

secLine:Toggle({ Title="Enable Lineblock", Type="Checkbox", Default=guestCfg.lineBlockEnabled,
    Callback=function(v) guestCfg.lineBlockEnabled=v; saveCfg() end })

secLine:Slider({ Title="Line Length", Step=1, Value={Min=2,Max=40,Default=guestCfg.lineBlockLength},
    Callback=function(v) guestCfg.lineBlockLength=v; saveCfg() end })

secLine:Slider({ Title="Line Radius", Step=0.5, Value={Min=0.5,Max=10,Default=guestCfg.lineBlockRadius},
    Callback=function(v) guestCfg.lineBlockRadius=v; saveCfg() end })

secLine:Slider({ Title="Block Delay (x0.05s)", Step=1, Value={Min=0,Max=20,Default=math.floor(guestCfg.lineBlockDelay/0.05+0.5)},
    Callback=function(v) guestCfg.lineBlockDelay=v*0.05; saveCfg() end })

secLine:Slider({ Title="Anti-Bait Hold (x0.01s)", Step=1, Value={Min=0,Max=50,Default=math.floor(guestCfg.lineBlockFacingDuration/0.01+0.5)},
    Callback=function(v) guestCfg.lineBlockFacingDuration=v*0.01; saveCfg() end })

secLine:Slider({ Title="Facing Sensitivity", Step=1, Value={Min=1,Max=10,Default=math.floor(guestCfg.lineBlockMinDot*10+0.5)},
    Callback=function(v) guestCfg.lineBlockMinDot=v/10; saveCfg() end })

secLine:Paragraph({ Title="Color Guide",
    Content="White = idle  |  Yellow = punch anim or sound detected  |  Red = you're on the line (block fires)" })

secLine:Button({ Title="Unload Line Block", Callback=function()
    guestCfg.lineBlockEnabled = false
    for killer in pairs(line.parts) do line_cleanKiller(killer) end
    for killer in pairs(line.animConns) do line_cleanKiller(killer) end
    line.killerState = {}
    tabGuestLine:Destroy()
    ui:Notify({Title="Line Block Unloaded", Content="Features disabled", Duration=2})
end })

print("[Guest Line Block] Loaded")

end -- tabGuestLine

-- ============================================================
-- GUEST 1337 - PUNCH MOBILITY TAB
-- ============================================================

do -- tabGuestMobility
local tabGuestMobility = win:Tab({ Title = "Guest Mobility", Icon = "zap" })

-- Load config
local GUEST_CONFIG_PATH = "betrayalhub/guest1337_config.json"
local guestCfg = {}
pcall(function()
    if fs.hasFile(GUEST_CONFIG_PATH) then
        local data = fs.read(GUEST_CONFIG_PATH)
        if data and #data > 0 then
            local decoded = svc.Http:JSONDecode(data)
            if decoded and type(decoded) == "table" then
                for k, v in pairs(decoded) do guestCfg[k] = v end
            end
        end
    end
end)

guestCfg.punchMobilityEnabled = guestCfg.punchMobilityEnabled or false
guestCfg.lungeBoostEnabled = guestCfg.lungeBoostEnabled or false
guestCfg.lungeMultiplier = guestCfg.lungeMultiplier or 1.0
guestCfg.chargeControlEnabled = guestCfg.chargeControlEnabled or false
guestCfg.chargeSpeedLimit = guestCfg.chargeSpeedLimit or 12
guestCfg.chargeSpeedCapEnabled = guestCfg.chargeSpeedCapEnabled or false

local function saveCfg()
    pcall(function()
        if not fs.hasFolder("betrayalhub") then fs.makeFolder("betrayalhub") end
        fs.write(GUEST_CONFIG_PATH, svc.Http:JSONEncode(guestCfg))
    end)
end

-- MOBILITY STATE
local mob = {
    isCharging = false,
    lungeActive = false,
    lungeThread = nil,
    pinnedConns = {},
    chargePinnedConns = {},
    chargeCapConn = nil,
    chargeWatcher = nil,
    descendantConn = nil,
    remote = nil,
}

local BASE_SPEED = 12
local BASE_PUNCH_FORCE = 40
local PUNCH_WINDUP = 0.7
local PARRY_WINDUP = 0.4

local function mob_getRoot() local c=lp.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function mob_getHum() local c=lp.Character; return c and c:FindFirstChild("Humanoid") end

local function mob_isParryMode() return false end

local function mob_firePunch()
    if not mob.remote then
        pcall(function()
            mob.remote = svc.RS:WaitForChild("Modules",10):WaitForChild("Network",10):WaitForChild("Network",10):WaitForChild("RemoteEvent",10)
        end)
    end
    if mob.remote then pcall(function() mob.remote:FireServer("UseActorAbility", {[1]=buffer.fromstring("\3\5\0\0\0Punch")}) end) end
end

local function mob_pinValue(v)
    if not v or not v:IsA("NumberValue") then return end
    if v.Value > 1.01 then return end
    pcall(function() v.Value = 1 end)
    local conn
    conn = v:GetPropertyChangedSignal("Value"):Connect(function()
        if not guestCfg.punchMobilityEnabled then
            pcall(function() conn:Disconnect() end)
            return
        end
        if v.Value < 1 then pcall(function() v.Value = 1 end) end
    end)
    table.insert(mob.pinnedConns, conn)
end

local function mob_applyLunge()
    if not guestCfg.lungeBoostEnabled then return end
    if mob.lungeActive then return end
    local root = mob_getRoot()
    if not root then return end
    local lv = root.CFrame.LookVector
    local dir = Vector3.new(lv.X, 0, lv.Z)
    if dir.Magnitude == 0 then return end
    dir = dir.Unit
    mob.lungeActive = true
    local speed = BASE_PUNCH_FORCE * guestCfg.lungeMultiplier
    local DURATION = 0.3
    local elapsed = 0
    pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
    svc.Run:BindToRenderStep("GuestLungeBoost", Enum.RenderPriority.Character.Value + 20, function(dt)
        elapsed = elapsed + dt
        local rp = mob_getRoot()
        if not rp or elapsed >= DURATION then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
            mob.lungeActive = false
            return
        end
        local t = 1 - (elapsed / DURATION)
        local currentY = rp.AssemblyLinearVelocity.Y
        rp.AssemblyLinearVelocity = dir * (speed * t) + Vector3.new(0, currentY, 0)
    end)
end

local function mob_startPunchOverride()
    mob_stopPunchOverride()
    local char = lp.Character
    if not char then return end
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("NumberValue") then mob_pinValue(desc) end
    end
    mob.descendantConn = char.DescendantAdded:Connect(function(desc)
        if not guestCfg.punchMobilityEnabled then return end
        if desc:IsA("NumberValue") then
            task.defer(function()
                if desc.Name == "PunchAbility" then
                    if guestCfg.lungeBoostEnabled then
                        if mob.lungeThread then task.cancel(mob.lungeThread) end
                        local delay = mob_isParryMode() and PARRY_WINDUP or PUNCH_WINDUP
                        mob.lungeThread = task.delay(delay, function()
                            mob.lungeThread = nil
                            mob_applyLunge()
                        end)
                    end
                end
                mob_pinValue(desc)
            end)
        end
    end)
    svc.Run:BindToRenderStep("GuestPunchMobility", Enum.RenderPriority.Character.Value + 10, function()
        if mob.lungeActive then return end
        local hum = mob_getHum()
        if not hum then return end
        if hum.WalkSpeed < BASE_SPEED then hum.WalkSpeed = BASE_SPEED end
    end)
end

local function mob_stopPunchOverride()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestPunchMobility") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end)
    mob.lungeActive = false
    for _, conn in pairs(mob.pinnedConns) do pcall(function() conn:Disconnect() end) end
    mob.pinnedConns = {}
    if mob.descendantConn then
        mob.descendantConn:Disconnect()
        mob.descendantConn = nil
    end
    if mob.lungeThread then
        task.cancel(mob.lungeThread)
        mob.lungeThread = nil
    end
end

local function mob_pinChargeValue(v)
    if not v or not v:IsA("NumberValue") then return end
    if v.Value <= 1.01 then return end
    pcall(function() v.Value = 1 end)
    local conn
    conn = v:GetPropertyChangedSignal("Value"):Connect(function()
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then
            pcall(function() conn:Disconnect() end)
            return
        end
        if v.Value > 1 then pcall(function() v.Value = 1 end) end
    end)
    table.insert(mob.chargePinnedConns, conn)
end

local function mob_stopChargeCap()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeCap") end)
    if mob.chargeCapConn then
        mob.chargeCapConn:Disconnect()
        mob.chargeCapConn = nil
    end
    for _, c in pairs(mob.chargePinnedConns) do pcall(function() c:Disconnect() end) end
    mob.chargePinnedConns = {}
end

local function mob_startChargeCap()
    mob_stopChargeCap()
    local char = lp.Character
    if not char then return end
    for _, desc in ipairs(char:GetDescendants()) do mob_pinChargeValue(desc) end
    mob.chargeCapConn = char.DescendantAdded:Connect(function(desc)
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then return end
        if desc:IsA("NumberValue") then task.defer(function() mob_pinChargeValue(desc) end) end
    end)
    svc.Run:BindToRenderStep("GuestChargeCap", Enum.RenderPriority.Character.Value + 20, function()
        if not mob.isCharging or not guestCfg.chargeSpeedCapEnabled then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeCap") end)
            return
        end
        local hum = mob_getHum()
        if hum and hum.WalkSpeed > BASE_SPEED then hum.WalkSpeed = BASE_SPEED end
    end)
end

local function mob_stopLock()
    mob.isCharging = false
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeLock") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
    mob_stopChargeCap()
end

local function mob_startLock()
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeLock") end)
    pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
    mob.isCharging = true
    svc.Run:BindToRenderStep("GuestChargeLock", Enum.RenderPriority.Character.Value + 2, function()
        local hum = mob_getHum()
        if not hum then return end
        local cam = svc.WS.CurrentCamera.CFrame.LookVector
        local dir = Vector3.new(cam.X, 0, cam.Z)
        if dir.Magnitude > 0 then hum:Move(dir.Unit) end
    end)
    svc.Run:BindToRenderStep("GuestChargeSpeedLimit", Enum.RenderPriority.Character.Value + 20, function()
        if not mob.isCharging then
            pcall(function() svc.Run:UnbindFromRenderStep("GuestChargeSpeedLimit") end)
            return
        end
        local hum = mob_getHum()
        if hum and hum.WalkSpeed ~= guestCfg.chargeSpeedLimit then hum.WalkSpeed = guestCfg.chargeSpeedLimit end
    end)
    if guestCfg.chargeSpeedCapEnabled then mob_startChargeCap() end
end

local function mob_setupChargeWatcher(character)
    if mob.chargeWatcher then
        mob.chargeWatcher:Disconnect()
        mob.chargeWatcher = nil
    end
    mob_stopLock()
    mob_stopPunchOverride()
    mob.chargeWatcher = character:GetAttributeChangedSignal("GuestCharging"):Connect(function()
        if not guestCfg.chargeControlEnabled then return end
        if character:GetAttribute("GuestCharging") then
            mob_startLock()
        else
            mob_stopLock()
        end
    end)
end

-- INIT
lp.CharacterAdded:Connect(function(char)
    task.delay(0.5, function()
        mob_setupChargeWatcher(char)
        if guestCfg.punchMobilityEnabled then mob_startPunchOverride() end
    end)
end)

if lp.Character then
    mob_setupChargeWatcher(lp.Character)
end

if guestCfg.punchMobilityEnabled then mob_startPunchOverride() end

-- ============================================================
-- UI - PUNCH MOBILITY
-- ============================================================

local secMob = tabGuestMobility:Section({ Title = "Punch Mobility", Opened = true })

secMob:Toggle({ Title="Enable Punch Mobility", Type="Checkbox", Default=guestCfg.punchMobilityEnabled,
    Callback=function(v) guestCfg.punchMobilityEnabled=v; saveCfg(); if v then mob_startPunchOverride() else mob_stopPunchOverride() end end })

secMob:Toggle({ Title="Lunge Boost", Type="Checkbox", Default=guestCfg.lungeBoostEnabled,
    Callback=function(v) guestCfg.lungeBoostEnabled=v; saveCfg(); if not v then if mob.lungeThread then task.cancel(mob.lungeThread); mob.lungeThread=nil end; pcall(function() svc.Run:UnbindFromRenderStep("GuestLungeBoost") end); mob.lungeActive=false end end })

secMob:Slider({ Title="Lunge Multiplier", Step=0.1, Value={Min=0.5,Max=5,Default=guestCfg.lungeMultiplier},
    Callback=function(v) guestCfg.lungeMultiplier=v; saveCfg() end })

secMob:Toggle({ Title="Charge Control", Type="Checkbox", Default=guestCfg.chargeControlEnabled,
    Callback=function(v) guestCfg.chargeControlEnabled=v; saveCfg(); if not v then mob_stopLock() end end })

secMob:Slider({ Title="Charge Speed Limit", Step=1, Value={Min=1,Max=50,Default=guestCfg.chargeSpeedLimit},
    Callback=function(v) guestCfg.chargeSpeedLimit=v; saveCfg() end })

secMob:Toggle({ Title="Charge Speed Cap", Type="Checkbox", Default=guestCfg.chargeSpeedCapEnabled,
    Callback=function(v) guestCfg.chargeSpeedCapEnabled=v; saveCfg(); if mob.isCharging and v then mob_startChargeCap() elseif not v then mob_stopChargeCap() end end })

secMob:Button({ Title="Unload Punch Mobility", Callback=function()
    guestCfg.punchMobilityEnabled = false
    mob_stopPunchOverride()
    mob_stopLock()
    mob_stopChargeCap()
    tabGuestMobility:Destroy()
    ui:Notify({Title="Punch Mobility Unloaded", Content="Features disabled", Duration=2})
end })

print("[Guest Mobility] Loaded")

end -- tabGuestMobility

-- ============================================================
-- INTERFACE TAB (Continued from Part 2)
-- ============================================================

end -- tabMusic
do -- tabInterface
local tabInterface = win:Tab({ Title = "Interface", Icon = "scan" })
local secUIFunctions = tabInterface:Section({ Title = "UI Functions", Opened = true })

secUIFunctions:Button({ Title = "Close UI", Callback = function()
    pcall(function()
        local ok = pcall(function() win:Destroy() end)
        if not ok then pcall(function() win:Close() end) end
    end)
end })

-- CONFIG SHARE
local secConfigShare = tabInterface:Section({ Title = "Config Share", Opened = true })

local B64CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function b64Encode(str)
    local result = {}
    local bytes = {string.byte(str, 1, #str)}
    for i = 1, #bytes, 3 do
        local b1,b2,b3 = bytes[i] or 0, bytes[i+1] or 0, bytes[i+2] or 0
        local n = b1*65536 + b2*256 + b3
        result[#result+1] = B64CHARS:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
        result[#result+1] = B64CHARS:sub(math.floor(n/4096)%64+1, math.floor(n/4096)%64+1)
        result[#result+1] = bytes[i+1] and B64CHARS:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "="
        result[#result+1] = bytes[i+2] and B64CHARS:sub(n%64+1, n%64+1) or "="
    end
    return table.concat(result)
end

local function b64Decode(str)
    local lookup = {}; for i=1,#B64CHARS do lookup[B64CHARS:sub(i,i)] = i-1 end
    local bytes = {}
    for i = 1, #str, 4 do
        local c1 = lookup[str:sub(i,i)] or 0; local c2 = lookup[str:sub(i+1,i+1)] or 0
        local c3 = lookup[str:sub(i+2,i+2)]; local c4 = lookup[str:sub(i+3,i+3)]
        local n = c1*262144 + c2*4096 + (c3 or 0)*64 + (c4 or 0)
        bytes[#bytes+1] = string.char(math.floor(n/65536)%256)
        if c3 then bytes[#bytes+1] = string.char(math.floor(n/256)%256) end
        if c4 then bytes[#bytes+1] = string.char(n%256) end
    end
    return table.concat(bytes)
end

local CONFIG_PATH = "WindUI/betrayalhub/config/betrayalhub.json"

secConfigShare:Button({
    Title = "📋 Copy Config",
    Icon = "copy",
    Callback = function()
        pcall(function()
            local ok,e = pcall(function()
                local raw = readfile(CONFIG_PATH)
                setclipboard("v1prw_full:"..b64Encode(raw))
                print("[betrayalhub] Config copied!")
            end)
            if not ok then print("[betrayalhub] Copy failed: "..tostring(e)) end
        end)
    end
})

local importStr = ""

secConfigShare:Input({
    Title = "Paste Config String",
    Icon = "clipboard",
    Placeholder = "v1prw_full:...",
    Callback = function(v) pcall(function() importStr = v end) end
})

secConfigShare:Button({
    Title = "🔄 Load Config",
    Icon = "download",
    Callback = function()
        pcall(function()
            if importStr == "" then print("[betrayalhub] Paste a config string first"); return end
            if importStr:match("^v1prw_full:") then
                local ok,e = pcall(function()
                    local d = b64Decode(importStr:sub(12))
                    writefile(CONFIG_PATH, d)
                    v1prConfig:Load()
                    applyConfigFromFlags()
                end)
                if ok then print("[betrayalhub] Config loaded!") else print("[betrayalhub] Load failed: "..tostring(e)) end
            else
                print("[betrayalhub] Must start with v1prw_full:")
            end
        end)
    end
})

secConfigShare:Button({
    Title = "💾 Save Config",
    Icon = "save",
    Callback = function() pcall(function() v1prConfig:Save(); print("[betrayalhub] Config saved") end) end
})

end -- interface tab

-- ============================================================
-- CONFIG APPLY (Continued from Part 2)
-- ============================================================

function applyConfigFromFlags()
    pcall(function()
        task.wait(0.5)
        if not (win and win.Flags) then return end
        print("[betrayalhub] Applying config flags...")
        
        if win.Flags.spoofActive ~= nil then spoofActive=win.Flags.spoofActive; if spoofActive then spoofStart() else spoofStop() end end
        if win.Flags.chatForceEnabled ~= nil then chatForceEnabled=win.Flags.chatForceEnabled; if chatForceConn then chatForceConn:Disconnect(); chatForceConn=nil end; if chatForceEnabled then enforceChatOn(); chatForceConn=svc.Run.Heartbeat:Connect(enforceChatOn) end end
        if win.Flags.timerSide ~= nil then timerSide=type(win.Flags.timerSide)=="table" and win.Flags.timerSide[1] or win.Flags.timerSide; applyTimerPos() end
        if win.Flags.platEnabled ~= nil then platEnabled=win.Flags.platEnabled; if platEnabled then platStart() else platStop() end end
        if win.Flags.platDevice ~= nil then platDevice=win.Flags.platDevice end
        if win.Flags.stamOn ~= nil then stam.on=win.Flags.stamOn end
        if win.Flags.stamNoLoss ~= nil then stam.noLoss=win.Flags.stamNoLoss end
        if type(win.Flags.stamLoss)=="number" then stam.loss=win.Flags.stamLoss end
        if type(win.Flags.stamGain)=="number" then stam.gain=win.Flags.stamGain end
        if type(win.Flags.stamMax)=="number" then stam.max=win.Flags.stamMax end
        if type(win.Flags.stamCurrent)=="number" then stam.current=win.Flags.stamCurrent end
        if stam.on or stam.noLoss then stamStart() end; if stam.noLoss then stamApply() end
        if win.Flags.speedOn ~= nil then speedHack.on=win.Flags.speedOn; if speedHack.on then speedStart() end end
        if type(win.Flags.speedValue)=="number" then speedHack.speed=win.Flags.speedValue; speedHack.lastApplied=0 end
        if win.Flags.hbOn ~= nil then hb.on=win.Flags.hbOn; if hb.on then hbStart() else hbStop() end end
        if type(win.Flags.hbStrength)=="number" then hb.strength=win.Flags.hbStrength end
        if win.Flags.acOn ~= nil then ac.on=win.Flags.acOn; if not ac.on then for k in pairs(ac.active) do ac.active[k]=nil end; ac.chaseTarget=nil; ac.damageTarget=nil end end
        if type(win.Flags.acStrength)=="number" then ac.strength=win.Flags.acStrength end
        if type(win.Flags.acMaxDist)=="number" then ac.maxDist=win.Flags.acMaxDist end
        if win.Flags.flowOn ~= nil then flow.on=win.Flags.flowOn end
        if type(win.Flags.flowNodeDelay)=="number" then flow.nodeDelay=win.Flags.flowNodeDelay end
        if type(win.Flags.flowLineDelay)=="number" then flow.lineDelay=win.Flags.flowLineDelay end
        if win.Flags.aimOn ~= nil then aim.on=win.Flags.aimOn end
        if type(win.Flags.aimCooldown)=="number" then aim.cooldown=win.Flags.aimCooldown end
        if type(win.Flags.aimLockTime)=="number" then aim.lockTime=win.Flags.aimLockTime end
        if type(win.Flags.aimMaxDist)=="number" then aim.maxDist=win.Flags.aimMaxDist end
        if type(win.Flags.aimSmooth)=="number" then aim.smooth=win.Flags.aimSmooth end
        if not aim.on then aimUnlock() end
        if win.Flags.absOn ~= nil then abs.on=win.Flags.absOn; if abs.on then absStart() else absStop() end end
        if type(win.Flags.absRange)=="number" then abs.range=win.Flags.absRange end
        if type(win.Flags.absDur)=="number" then abs.duration=win.Flags.absDur end
        if win.Flags.sixerStrafeOn ~= nil then sixerStrafeOn=win.Flags.sixerStrafeOn end
        if win.Flags.coolkidWSOOn ~= nil then coolkidWSOOn=win.Flags.coolkidWSOOn end
        if win.Flags.noliVoidRushOn ~= nil then noliVoidRushOn=win.Flags.noliVoidRushOn; if not noliVoidRushOn then noliStop() end end
        if win.Flags.qteOn ~= nil then qte.on = win.Flags.qteOn; if qte.on then qteStart() else qteStop() end end
        if type(win.Flags.qteSpeed)=="number" then qte.speed = win.Flags.qteSpeed end
        if win.Flags.batsAimOn ~= nil then batsAim.on=win.Flags.batsAimOn end
        if type(win.Flags.batsPrediction)=="number" then batsAim.prediction=win.Flags.batsPrediction end
        if type(win.Flags.batsDepthOffset)=="number" then batsAim.depthOffset=win.Flags.batsDepthOffset end
        if type(win.Flags.batsMaxDist)=="number" then batsAim.maxDist=win.Flags.batsMaxDist end
        if win.Flags.espEnabled ~= nil then esp.enabled=win.Flags.espEnabled; if esp.enabled then espStart() else espStop() end end
        if win.Flags.espKillers ~= nil then esp.showKillers=win.Flags.espKillers end
        if win.Flags.espSurvivors ~= nil then esp.showSurvivors=win.Flags.espSurvivors end
        if win.Flags.espGenerators ~= nil then esp.showGenerators=win.Flags.espGenerators end
        if win.Flags.espItems ~= nil then esp.showItems=win.Flags.espItems end
        if win.Flags.espStructures ~= nil then esp.showStructures=win.Flags.espStructures end
        if win.Flags.gvEspOn ~= nil then gvEsp.on=win.Flags.gvEspOn; if gvEsp.on then gvStart() else gvStop() end end
        if win.Flags.gvShowGroundbulb ~= nil then gvEsp.showGroundbulb=win.Flags.gvShowGroundbulb end
        if win.Flags.gvShowVine ~= nil then gvEsp.showVine=win.Flags.gvShowVine end
        if win.Flags.espPizza ~= nil then mset.pizza=win.Flags.espPizza end
        if win.Flags.espZombie ~= nil then mset.zombie=win.Flags.espZombie end
        if win.Flags.espPuddle ~= nil then mset.puddle=win.Flags.espPuddle end
        if type(win.Flags.espMaxDistance)=="number" then esp.maxDistance=win.Flags.espMaxDistance end
        if type(win.Flags.espTransparency)=="number" then esp.transparency=win.Flags.espTransparency end
        if type(win.Flags.espScanRate)=="number" then esp.scanRate=win.Flags.espScanRate end
        if type(win.Flags.espMinionTrans)=="number" then mset.transparency=win.Flags.espMinionTrans; updateTransparency() end
        if win.Flags.musicOn ~= nil then music.on=win.Flags.musicOn; if music.on then if music.thread then task.cancel(music.thread) end; music.thread=task.spawn(musicMonitor) else if music.thread then task.cancel(music.thread); music.thread=nil end; musicReset() end end
        if win.Flags.musicSel ~= nil then music.selected=win.Flags.musicSel end
        -- Jane Doe flags
        if win.Flags.jdEnabled ~= nil then jd_enabled=win.Flags.jdEnabled end
        if win.Flags.jdSilentAim ~= nil then jd_aimbotOn=win.Flags.jdSilentAim end
        if win.Flags.jdCrystalAutoHold ~= nil then jd_crystalAutoHold=win.Flags.jdCrystalAutoHold end
        if type(win.Flags.jdAimOffset)=="number" then jd_AIM_OFFSET=win.Flags.jdAimOffset end
        if type(win.Flags.jdPrediction)=="number" then jd_PREDICTION=win.Flags.jdPrediction end
        if type(win.Flags.jdHoldDur)=="number" then jd_HOLD_DURATION=win.Flags.jdHoldDur end
        if win.Flags.jdAxeEnabled ~= nil then jd_axeEnabled=win.Flags.jdAxeEnabled end
        if type(win.Flags.jdAxeLockDur)=="number" then jd_AXE_LOCK_DURATION=win.Flags.jdAxeLockDur end
        -- Elliot flags
        if win.Flags.elliotEnabled ~= nil then elliotEnabled=win.Flags.elliotEnabled; if elliotEnabled then elliotStartAimbot() end end
        if win.Flags.elliotRequireAnim ~= nil then elliotRequireAnim=win.Flags.elliotRequireAnim end
        if win.Flags.elliotShowArc ~= nil then elliotShowArc=win.Flags.elliotShowArc end
        if type(win.Flags.elliotThrowDur)=="number" then elliotThrowDur=win.Flags.elliotThrowDur end
        if type(win.Flags.elliotSmoothness)=="number" then elliotSmoothness=win.Flags.elliotSmoothness end
        if type(win.Flags.elliotPredDist)=="number" then elliotPredDist=win.Flags.elliotPredDist end
        if type(win.Flags.elliotThrowForce)=="number" then elliotThrowForce=win.Flags.elliotThrowForce end
        -- Chance flags
        if win.Flags.chanceAimEnabled ~= nil then chanceAimEnabled=win.Flags.chanceAimEnabled end
        if win.Flags.holdToAim ~= nil then holdToAim=win.Flags.holdToAim end
        -- Plasma flags
        if win.Flags.plasmaEnabled ~= nil then plasma_enabled=win.Flags.plasmaEnabled end
        if type(win.Flags.plasmaPrediction)=="number" then plasma_prediction=win.Flags.plasmaPrediction end
        if type(win.Flags.plasmaAimOffset)=="number" then plasma_aimOffset=win.Flags.plasmaAimOffset end
        -- HDT flags
        if win.Flags.hdtEnabled ~= nil then 
            guestCfg.hdtEnabled = win.Flags.hdtEnabled
            saveCfg()
        end
        if type(win.Flags.hdtSpeed)=="number" then 
            guestCfg.hdtSpeed = win.Flags.hdtSpeed
            saveCfg()
        end
        if type(win.Flags.hdtDuration)=="number" then 
            guestCfg.hdtDuration = win.Flags.hdtDuration
            saveCfg()
        end
        if type(win.Flags.hdtRange)=="number" then 
            guestCfg.hdtRange = win.Flags.hdtRange
            saveCfg()
        end
        if type(win.Flags.hdtDelay)=="number" then 
            guestCfg.hdtDelay = win.Flags.hdtDelay
            saveCfg()
        end
        if win.Flags.hdtFaceKiller ~= nil then 
            guestCfg.hdtFaceKiller = win.Flags.hdtFaceKiller
            saveCfg()
        end
        if win.Flags.hdtShowRange ~= nil then 
            guestCfg.hdtShowRange = win.Flags.hdtShowRange
            saveCfg()
        end
        
        print("[betrayalhub] All features restored from config!")
    end)
end

task.spawn(function()
    while true do task.wait(2); pcall(function() v1prConfig:Save() end) end
end)

task.spawn(function()
    pcall(function()
        task.wait(1.5)
        pcall(function() v1prConfig:Load() end)
        task.defer(function()
            print("[betrayalhub] Syncing flags...")
            if win and win.Flags then applyConfigFromFlags() else print("[betrayalhub] win.Flags not yet available") end
        end)
    end)
end)

print("[betrayalhub] Loaded successfully")

end) -- End of main pcall

-- Error handling
if not success then
    local errMsg = tostring(err)
    warn("BetrayalHub failed to load: " .. errMsg)
    print("BetrayalHub encountered an error: " .. errMsg)
    flashError(errMsg)
end
