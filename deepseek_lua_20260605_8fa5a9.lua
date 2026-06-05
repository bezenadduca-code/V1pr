local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load WindUI (correct URL)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ──────────────────────────────────────────────
--  CONFIG
-- ──────────────────────────────────────────────
local CONFIG = {
    BehindOffset           = 5.5,
    AlreadyBehindTolerance = 3.5,
    FireDelay              = 0.37,
    DashSpeed              = 79,
    ArcSegments            = 5,
    SideWidth              = 0.65,
    TrailLifetime          = 0.35,

    DashAnimLeft           = "rbxassetid://117223862448096",
    DashAnimRight          = "rbxassetid://75203303352791",
    AttackAnimId           = "rbxassetid://100962226150441",

    FacingDotThreshold     = -0.6,
    RetryDelay             = 0.04,
    RetryFire              = true,

    RetryDistance          = 7,
    MaxTargetVelocity      = 28,
    PostDashDelay          = 0.06,

    ESPEnabled             = true,
    ESPColor               = Color3.fromRGB(255, 50, 50),
    ESPFillTransparency    = 0.7,
    ESPOutlineTransparency = 0.3,
}

if _G.retryfire ~= nil then
    CONFIG.RetryFire = _G.retryfire
end

-- ──────────────────────────────────────────────
--  REMOTES
-- ──────────────────────────────────────────────
local function getRemote(...)
    local path = { ... }
    local ok, remote = pcall(function()
        local node = ReplicatedStorage
        for _, child in ipairs(path) do
            node = node:WaitForChild(child, 5)
        end
        return node
    end)
    return ok and remote or nil
end

local targetRemote = getRemote("Knit", "Knit", "Services", "DivergentFistService", "RE", "Activated")
if not targetRemote then
    warn("[DivergentFist] Remote not found!")
    return
end

local returnSkillRemote = getRemote("Knit", "Knit", "Services", "ItadoriService", "RE", "RightActivated")
if not returnSkillRemote then
    warn("[DivergentFist] ReturnSkill remote not found")
end

-- ──────────────────────────────────────────────
--  ESP SYSTEM
-- ──────────────────────────────────────────────
local espObjects = {}

local function createHighlight(model, color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "DivergentFistESP"
    highlight.FillTransparency = CONFIG.ESPFillTransparency
    highlight.OutlineTransparency = CONFIG.ESPOutlineTransparency
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Adornee = model
    highlight.Parent = model
    return highlight
end

local function destroyESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function updateESP()
    if not CONFIG.ESPEnabled then
        destroyESP()
        return
    end

    destroyESP()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local hl = createHighlight(player.Character, CONFIG.ESPColor)
                if hl then table.insert(espObjects, hl) end
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChild("HumanoidRootPart") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and not obj:IsDescendantOf(Players) then
                local hl = createHighlight(obj, CONFIG.ESPColor)
                if hl then table.insert(espObjects, hl) end
            end
        end
    end
end

local function applyTransparencyLive()
    for _, obj in pairs(espObjects) do
        pcall(function()
            obj.FillTransparency = CONFIG.ESPFillTransparency
            obj.OutlineTransparency = CONFIG.ESPOutlineTransparency
        end)
    end
end

task.spawn(function()
    while true do
        if CONFIG.ESPEnabled then
            updateESP()
        end
        task.wait(0.5)
    end
end)

-- ──────────────────────────────────────────────
--  UTILS
-- ──────────────────────────────────────────────
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getAnimator()
    local char = LocalPlayer.Character
    if not char then return nil end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    return humanoid:FindFirstChildOfClass("Animator")
end

local function isAliveModel(model)
    local myChar = LocalPlayer.Character
    if model == myChar then return false end

    local root = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChild("Humanoid")

    return root and humanoid and humanoid.Health > 0
end

-- ──────────────────────────────────────────────
--  TARGET CHECKS
-- ──────────────────────────────────────────────
local function isTargetFacingAway(targetRoot)
    local hrp = getHRP()

    if not hrp or not targetRoot or not targetRoot.Parent then
        return false
    end

    local toPlayer = (hrp.Position - targetRoot.Position)

    if toPlayer.Magnitude < 0.01 then
        return false
    end

    local dot = targetRoot.CFrame.LookVector:Dot(toPlayer.Unit)

    return dot < CONFIG.FacingDotThreshold
end

local function canRetry(targetRoot)
    local hrp = getHRP()

    if not hrp or not targetRoot or not targetRoot.Parent then
        return false
    end

    local dist = (hrp.Position - targetRoot.Position).Magnitude

    if dist > CONFIG.RetryDistance then
        return false
    end

    local behindDot = targetRoot.CFrame.LookVector:Dot(
        (hrp.Position - targetRoot.Position).Unit
    )

    local behindEnough = behindDot < -0.45

    local targetVelocity = targetRoot.AssemblyLinearVelocity.Magnitude

    if targetVelocity > CONFIG.MaxTargetVelocity then
        return false
    end

    return behindEnough
end

-- ──────────────────────────────────────────────
--  TARGET FINDER
-- ──────────────────────────────────────────────
local function findNearestTarget()
    local hrp = getHRP()

    if not hrp then
        return nil
    end

    local nearest = nil
    local bestDist = math.huge

    local function checkModel(model)
        if not isAliveModel(model) then
            return
        end

        local root = model:FindFirstChild("HumanoidRootPart")
        local dist = (hrp.Position - root.Position).Magnitude

        if dist < bestDist then
            bestDist = dist
            nearest = model
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            checkModel(player.Character)
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            checkModel(obj)
        end
    end

    return nearest
end

-- ──────────────────────────────────────────────
--  TRAIL
-- ──────────────────────────────────────────────
local function createTrail(rootPart)
    local a0 = Instance.new("Attachment", rootPart)
    local a1 = Instance.new("Attachment", rootPart)

    a1.Position = Vector3.new(0, 2, 0)

    local trail = Instance.new("Trail", rootPart)
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new(Color3.fromRGB(255,255,255))

    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })

    trail.Lifetime = CONFIG.TrailLifetime
    trail.MinLength = 0
    trail.FaceCamera = true

    task.delay(CONFIG.TrailLifetime + 0.1, function()
        trail:Destroy()
        a0:Destroy()
        a1:Destroy()
    end)
end

-- ──────────────────────────────────────────────
--  ANIMATIONS
-- ──────────────────────────────────────────────
local cachedAnims = {}

local function playDashAnimation(direction, duration)
    local animator = getAnimator()
    if not animator then return nil end

    local animId = (direction == "Left")
        and CONFIG.DashAnimLeft
        or CONFIG.DashAnimRight

    if not cachedAnims[direction] then
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        anim.Name = "DivergentDash_" .. direction
        cachedAnims[direction] = anim
    end

    local track = animator:LoadAnimation(cachedAnims[direction])

    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    task.delay(duration + 0.05, function()
        if track and track.IsPlaying then
            track:Stop(0.15)
        end
    end)

    return track
end

local function playAttackAnimation()
    local animator = getAnimator()
    if not animator then return end

    if not cachedAnims.Attack then
        local anim = Instance.new("Animation")
        anim.AnimationId = CONFIG.AttackAnimId
        cachedAnims.Attack = anim
    end

    local track = animator:LoadAnimation(cachedAnims.Attack)

    track.Priority = Enum.AnimationPriority.Action
    track:Play()

    task.delay(1.113, function()
        if track.IsPlaying then
            track:Stop()
        end
    end)
end

-- ──────────────────────────────────────────────
--  CURVED DASH
-- ──────────────────────────────────────────────
local function performCurvedDash(targetRoot)
    local hrp = getHRP()

    if not hrp then
        return
    end

    local myPos = hrp.Position

    local destPos = (
        targetRoot.CFrame * CFrame.new(0, 0, CONFIG.BehindOffset)
    ).Position

    if (myPos - destPos).Magnitude < CONFIG.AlreadyBehindTolerance then
        playAttackAnimation()
        return
    end

    local dist = (destPos - myPos).Magnitude

    if dist < 0.5 then
        return
    end

    local dir = (destPos - myPos).Unit
    local side = dir:Cross(Vector3.new(0,1,0)).Unit

    local isLeft = math.random(1,2) == 2

    if isLeft then
        side = -side
    end

    local dashDirection = isLeft and "Left" or "Right"

    local arcDef = {
        {0.10, CONFIG.SideWidth * 0.50},
        {0.30, CONFIG.SideWidth * 0.80},
        {0.55, CONFIG.SideWidth * 0.70},
        {0.75, CONFIG.SideWidth * 0.40},
        {1.00, 0},
    }

    local waypoints = {}

    for i = 1, math.min(CONFIG.ArcSegments, #arcDef) do
        table.insert(
            waypoints,
            myPos
            + (dir * dist * arcDef[i][1])
            + (side * dist * arcDef[i][2])
        )
    end

    local totalTime = math.max(dist / CONFIG.DashSpeed, 0.08)
    local segTime = totalTime / #waypoints

    createTrail(hrp)

    local dashTrack = playDashAnimation(dashDirection, totalTime)

    for i, wp in ipairs(waypoints) do
        local lookDir = (i < #waypoints)
            and (waypoints[i + 1] - wp).Unit
            or (targetRoot.Position - wp).Unit

        TweenService:Create(
            hrp,
            TweenInfo.new(segTime, Enum.EasingStyle.Linear),
            {
                CFrame = CFrame.new(wp, wp + lookDir)
            }
        ):Play()

        task.wait(segTime)
    end

    hrp.CFrame = CFrame.lookAt(destPos, targetRoot.Position)

    if dashTrack and dashTrack.IsPlaying then
        dashTrack:Stop(0.1)
    end

    playAttackAnimation()
end

-- ──────────────────────────────────────────────
--  HOOK
-- ──────────────────────────────────────────────
local isCooling = false
local isRetrying = false

local oldNamecall

oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if getnamecallmethod() ~= "FireServer" or self ~= targetRemote then
        return oldNamecall(self, ...)
    end

    if isRetrying then
        return oldNamecall(self, ...)
    end

    if isCooling then
        return oldNamecall(self, ...)
    end

    isCooling = true

    local result = oldNamecall(self, ...)

    local args = { ... }

    local target = findNearestTarget()
    local targetRoot = target and target:FindFirstChild("HumanoidRootPart")

    task.delay(CONFIG.FireDelay, function()

        if targetRoot and targetRoot.Parent and not isTargetFacingAway(targetRoot) then

            if returnSkillRemote then
                pcall(function()
                    returnSkillRemote:FireServer()
                end)
            end

            task.spawn(function()
                task.wait(CONFIG.RetryDelay)

                if not targetRoot.Parent or not isAliveModel(targetRoot.Parent) then
                    isCooling = false
                    return
                end

                performCurvedDash(targetRoot)

                task.wait(CONFIG.PostDashDelay)

                local shouldRetryFire = (
                    _G.retryfire ~= nil
                ) and _G.retryfire or CONFIG.RetryFire

                if not canRetry(targetRoot) then
                    -- Handled internally
                elseif not shouldRetryFire then
                    -- Handled internally
                else
                    isRetrying = true

                    pcall(function()
                        targetRemote:FireServer(table.unpack(args))
                    end)

                    task.wait(CONFIG.FireDelay)

                    pcall(function()
                        targetRemote:FireServer(table.unpack(args))
                    end)

                    isRetrying = false
                end

                task.defer(function()
                    isCooling = false
                end)
            end)

        else

            pcall(function()
                targetRemote:FireServer(table.unpack(args))
            end)

            task.defer(function()
                isCooling = false
            end)
        end
    end)

    task.spawn(function()
        if not targetRoot or not targetRoot.Parent then
            return
        end

        performCurvedDash(targetRoot)
    end)

    return result
end)

-- ──────────────────────────────────────────────
--  WINDUI GUI (Key System Removed)
-- ──────────────────────────────────────────────

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "Eclipse Fury Hub",
    Icon = "swords",
    Author = "Mitsuki/Kitty/storm",
    Folder = "EclipseFuryHub",
    Size = UDim2.fromOffset(580, 460)
})

-- Settings Tab
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

-- Dash Settings Section
SettingsTab:Section("Dash Settings")

SettingsTab:Slider({
    Title = "Dash Speed",
    Desc = "Adjust the speed of the curved dash",
    Value = { Min = 30, Max = 150, Default = CONFIG.DashSpeed },
    Callback = function(value)
        CONFIG.DashSpeed = value
    end
})

SettingsTab:Slider({
    Title = "Behind Offset",
    Desc = "Distance to dash behind the target",
    Value = { Min = 3, Max = 10, Default = CONFIG.BehindOffset, Step = 0.5 },
    Callback = function(value)
        CONFIG.BehindOffset = value
    end
})

SettingsTab:Slider({
    Title = "Fire Delay",
    Desc = "Delay between remote fires (×0.01s)",
    Value = { Min = 10, Max = 100, Default = math.floor(CONFIG.FireDelay * 100) },
    Callback = function(value)
        CONFIG.FireDelay = value / 100
    end
})

-- Combat Settings Section
SettingsTab:Section("Combat Settings")

SettingsTab:Toggle({
    Title = "Retry Fire",
    Desc = "Automatically retry firing the remote when conditions are met",
    Default = CONFIG.RetryFire,
    Callback = function(value)
        CONFIG.RetryFire = value
        _G.retryfire = value
    end
})

-- ESP Tab
local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "eye"
})

-- ESP Settings Section
ESPTab:Section("ESP Settings")

ESPTab:Toggle({
    Title = "Enable ESP",
    Desc = "Toggle ESP visibility for enemies",
    Default = CONFIG.ESPEnabled,
    Callback = function(value)
        CONFIG.ESPEnabled = value
        if not value then
            destroyESP()
        else
            updateESP()
        end
    end
})

ESPTab:ColorPicker({
    Title = "ESP Color",
    Desc = "Choose the highlight color for ESP",
    Default = CONFIG.ESPColor,
    Callback = function(color)
        CONFIG.ESPColor = color
        if CONFIG.ESPEnabled then updateESP() end
    end
})

-- Transparency Section
ESPTab:Section("Transparency")

ESPTab:Slider({
    Title = "Fill Transparency",
    Desc = "Transparency of the ESP fill",
    Value = { Min = 0, Max = 100, Default = math.floor(CONFIG.ESPFillTransparency * 100) },
    Callback = function(value)
        CONFIG.ESPFillTransparency = value / 100
        applyTransparencyLive()
    end
})

ESPTab:Slider({
    Title = "Outline Transparency",
    Desc = "Transparency of the ESP outline",
    Value = { Min = 0, Max = 100, Default = math.floor(CONFIG.ESPOutlineTransparency * 100) },
    Callback = function(value)
        CONFIG.ESPOutlineTransparency = value / 100
        applyTransparencyLive()
    end
})

-- Refresh Button
ESPTab:Button({
    Title = "Refresh ESP",
    Desc = "Manually refresh ESP highlights",
    Callback = function()
        updateESP()
        WindUI:Notify({
            Title = "ESP",
            Content = "ESP highlights refreshed.",
            Duration = 3
        })
    end
})

-- Success notification when script loads
WindUI:Notify({
    Title = "Eclipse Fury Hub",
    Content = "Script loaded successfully!",
    Duration = 3
})