--[[
    ============================================================
    Astra V5.0 - Complete Source
    ============================================================
    Features:
    - Visuals: Custom Blackhole, Shader, Rainbow ESP + Aim Cross
    - Server & Kick: Blob Kick (v1/v2-Orbit/Loop), Drift Kick,
                     Destroy Server, Ragdoll Kill, Grab Kick
    - Anti Kick: 6 types of toys
    - Palette: Palette Magnet
    ============================================================
]]

-- =====================================================
-- Library Load
-- =====================================================
local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Toggles = Library.Toggles
local Options = Library.Options

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local InsertService = game:GetService('InsertService')
local LocalPlayer = Players.LocalPlayer

local OLD_NOTIFY = Library.Notify

function Library:Notify(data)
    if type(data) ~= 'table' then
        data = { Description = tostring(data) }
    end
    data.Title = data.Title or '<b>Astra</b>'
    data.BigIcon = data.BigIcon or 'rbxassetid://118486090436366'
    return OLD_NOTIFY(self, data)
end

local Window = Library:CreateWindow({
    Title = '<b>Astra</b>',
    Icon = '118486090436366',
    Footer = 'V 5.0',
    DisableSearch = false,
    EnableCompacting = true,
    SidebarCompacted = true,
    EnableSidebarResize = true,
    CornerRadius = 30,
    BackgroundImage = 'rbxassetid://',
})

local Tabs = {
    VisualTab = Window:AddTab('Visuals', 'eye', 'Visual effects'),
    ServerKickTab = Window:AddTab('Server & Kick', 'zap', 'Server and Kick features'),
    AntiKickTab = Window:AddTab('Anti Kick', 'shield', 'Anti Kick tools'),
    PaletteTab = Window:AddTab('Palette', 'box', 'Palette tools'),
}

-- =====================================================
-- ★ Visuals タブ - ブラックホール
-- =====================================================
local Custom = Tabs.VisualTab:AddLeftGroupbox('Customs', 'galaxy')

CosmicBlackhole = {
    Enabled = false,
    Active = {},
    Connection = nil,
    Selected = "blackhole1",
    Options = {
        ["blackhole1"] = {Id = "rbxassetid://99340233207059",   Scale = 1.0, Type = "model"},
        ["blackhole2"] = {Id = "rbxassetid://81101997556973",   Scale = 1.0, Type = "model"},
        ["blackhole3"] = {Id = "rbxassetid://108336765562063",  Scale = 1.0, Type = "model"},
        ["blackhole4"] = {Id = "rbxassetid://76490441012398",   Scale = 1.0, Type = "model"},
        ["blackhole5"] = {Id = "rbxassetid://9528329581",       Scale = 1.0, Type = "model"},
        ["blackhole6"] = {Id = "rbxassetid://15601115261",      Scale = 1.0, Type = "model"},
        ["blackhole7"] = {Id = "rbxassetid://13481688755",      Scale = 1.0, Type = "model"},
    },
}

function WipeOriginal(bh)
    if not bh then return end
    for _, desc in ipairs(bh:GetDescendants()) do
        pcall(function()
            if desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation") then
                desc.Transparency = 1
                desc.CastShadow = false
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Beam") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                desc.Enabled = false
            elseif desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
                desc.Enabled = false
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 1
            elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
                desc.Enabled = false
            end
        end)
    end
    pcall(function()
        if bh:IsA("BasePart") then bh.Transparency = 1 end
        if bh:IsA("Model") and bh.PrimaryPart then bh.PrimaryPart.Transparency = 1 end
    end)
end

function RestoreOriginal(bh)
    if not bh then return end
    for _, desc in ipairs(bh:GetDescendants()) do
        pcall(function()
            if desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation") then
                desc.Transparency = 0
            elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Beam") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                desc.Enabled = true
            elseif desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
                desc.Enabled = true
            elseif desc:IsA("Decal") or desc:IsA("Texture") then
                desc.Transparency = 0
            elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then
                desc.Enabled = true
            end
        end)
    end
    pcall(function()
        if bh:IsA("BasePart") then bh.Transparency = 0 end
        if bh:IsA("Model") and bh.PrimaryPart then bh.PrimaryPart.Transparency = 0 end
    end)
end

function Cleanup(bh)
    if not bh then return end
    local data = CosmicBlackhole.Active[bh]
    if not data then return end
    if data.Anim then pcall(function() data.Anim:Disconnect() end) end
    if data.Model then pcall(function() data.Model:Destroy() end) end
    pcall(function() RestoreOriginal(bh) end)
    CosmicBlackhole.Active[bh] = nil
end

local function LoadCustomModel(assetId)
    if not assetId then return nil end
    local cleanId = tonumber((assetId:gsub("rbxassetid://", "")))
    if not cleanId then return nil end
    local ok1, res1 = pcall(function() return game:GetObjects(assetId)[1] end)
    if ok1 and res1 then return res1 end
    local ok2, res2 = pcall(function() return InsertService:LoadAsset(cleanId) end)
    if ok2 and res2 then
        local children = res2:GetChildren()
        if #children > 0 then return children[1] end
        return res2
    end
    return nil
end

function Build(bh)
    if not bh or not bh.Parent then return end
    if CosmicBlackhole.Active[bh] then return end
    local hole = bh:FindFirstChild("Hole") or bh:FindFirstChildWhichIsA("BasePart")
    if not hole then return end
    local option = CosmicBlackhole.Options[CosmicBlackhole.Selected]
    if not option then return end
    local model = LoadCustomModel(option.Id)
    if not model then
        Library:Notify({Title = '<b>Astra</b>', Description = 'アセット読み込み失敗', Time = 4})
        return
    end
    WipeOriginal(bh)
    local pos = hole.Position
    local data = {Time = 0, Hole = hole, Anim = nil, Model = nil, SpinSpeed = 0, TargetSpin = 0.8, Scale = 0, TargetScale = option.Scale, StartTime = tick()}
    model.Parent = bh
    model.Name = "CosmicMesh"
    for _, desc in ipairs(model:GetDescendants()) do
        pcall(function()
            if desc:IsA("AnimationController") or desc:IsA("Animator") or desc:IsA("Animation") then
                desc:Destroy()
            end
        end)
    end
    for _, part in ipairs(model:GetDescendants()) do
        pcall(function()
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Anchored = true
                part.CanCollide = false
                part.CastShadow = false
                part.Size = part.Size * 0.01
            end
            if part:IsA("Smoke") or part:IsA("ParticleEmitter") then
                local n = part.Name:lower()
                if n:find("smog") or n:find("fog") or n:find("mist") or n:find("haze") or n:find("cloud") then
                    part:Destroy()
                end
            end
        end)
    end
    pcall(function()
        if model.PrimaryPart then
            local offset = pos - model.PrimaryPart.Position
            model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame + offset)
        else
            local firstPart = nil
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then firstPart = part break end
            end
            if firstPart then
                local offset = pos - firstPart.Position
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then part.CFrame = part.CFrame + offset end
                end
            end
        end
    end)
    data.Model = model
    data.Anim = RunService.Heartbeat:Connect(function(dt)
        if not bh or not bh.Parent then Cleanup(bh) return end
        local currentPos = hole.Position
        data.Time = data.Time + dt * data.SpinSpeed
        if data.Model and data.Model.Parent then
            if data.Model:IsA("Model") then
                if data.Model.PrimaryPart then
                    local cf = CFrame.new(currentPos) * CFrame.Angles(0, data.Time, 0)
                    pcall(function() data.Model:SetPrimaryPartCFrame(cf) end)
                end
                for _, part in ipairs(data.Model:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        pcall(function()
                            if not part:GetAttribute("BaseSize") then
                                part:SetAttribute("BaseSize", part.Size / 0.01)
                            end
                            local baseSize = part:GetAttribute("BaseSize")
                            part.Size = baseSize * data.Scale
                        end)
                    end
                end
            end
        end
    end)
    bh.AncestryChanged:Connect(function()
        if not bh.Parent then Cleanup(bh) end
    end)
    CosmicBlackhole.Active[bh] = data
end

function StartSystem()
    if CosmicBlackhole.Connection then return end
    CosmicBlackhole.Connection = Workspace.ChildAdded:Connect(function(obj)
        if not CosmicBlackhole.Enabled then return end
        if obj.Name:lower():find("blackhole") then
            task.wait(0.2)
            Build(obj)
        end
    end)
end

Custom:AddDropdown("BlackholeSelect", {
    Text = "Blackhole Model",
    Values = {
        "blackhole1",
        "blackhole2",
        "blackhole3",
        "blackhole4",
        "blackhole5",
        "blackhole6",
        "blackhole7",
    },
    Default = "blackhole1",
    Callback = function(val)
        CosmicBlackhole.Selected = val
        if CosmicBlackhole.Enabled then
            for bh, _ in pairs(CosmicBlackhole.Active) do Cleanup(bh) end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name:lower():find("blackhole") then Build(obj) end
            end
        end
    end,
})

Custom:AddCheckbox("BlackholeToggle", {
    Text = "Enable Custom Blackhole",
    Default = false,
    Callback = function(val)
        local wasEnabled = CosmicBlackhole.Enabled
        CosmicBlackhole.Enabled = val
        if not val then
            if CosmicBlackhole.Connection then
                CosmicBlackhole.Connection:Disconnect()
                CosmicBlackhole.Connection = nil
            end
            for bh, _ in pairs(CosmicBlackhole.Active) do Cleanup(bh) end
            return
        end
        if not wasEnabled then StartSystem() end
        for bh, _ in pairs(CosmicBlackhole.Active) do Cleanup(bh) end
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("blackhole") then Build(obj) end
        end
    end,
})

-- =====================================================
-- ★ Visuals タブ - Shader
-- =====================================================
local VisualGroup = Tabs.VisualTab:AddRightGroupbox("Camera & ESP", "eye")

local shaderActive = false
local shaderMonitorThread = nil
local shaderOriginal = nil

local function SaveLightingOriginal()
    local l = game:GetService("Lighting")
    shaderOriginal = {
        ClockTime = l.ClockTime,
        Brightness = l.Brightness,
        GlobalShadows = l.GlobalShadows,
        OutdoorAmbient = l.OutdoorAmbient,
        Ambient = l.Ambient,
    }
end

local function RestoreLightingOriginal()
    if not shaderOriginal then return end
    local l = game:GetService("Lighting")
    l.ClockTime = shaderOriginal.ClockTime
    l.Brightness = shaderOriginal.Brightness
    l.GlobalShadows = shaderOriginal.GlobalShadows
    l.OutdoorAmbient = shaderOriginal.OutdoorAmbient
    l.Ambient = shaderOriginal.Ambient
    shaderOriginal = nil
end

local function EnableShader()
    if shaderActive then return end
    shaderActive = true

    SaveLightingOriginal()

    local l = game:GetService("Lighting")

    local oldCC = l:FindFirstChild("ShaderCC")
    if oldCC then oldCC:Destroy() end
    local oldBloom = l:FindFirstChild("ShaderBloom")
    if oldBloom then oldBloom:Destroy() end
    local oldSky = l:FindFirstChild("ShaderSky")
    if oldSky then oldSky:Destroy() end

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "ShaderCC"
    cc.Parent = l

    local bloom = Instance.new("BloomEffect")
    bloom.Name = "ShaderBloom"
    bloom.Parent = l

    local sun = Instance.new("Sky")
    sun.Name = "ShaderSky"

    sun.SkyboxBk = "rbxassetid://64125036"
    sun.SkyboxDn = "rbxassetid://64125045"
    sun.SkyboxFt = "rbxassetid://64125067"
    sun.SkyboxLf = "rbxassetid://64125078"
    sun.SkyboxRt = "rbxassetid://64125091"
    sun.SkyboxUp = "rbxassetid://64125103"
    sun.Parent = l

    shaderMonitorThread = task.spawn(function()
        while shaderActive do
            task.wait(0.1)
            if not shaderActive then break end

            l.ClockTime = 17.5
            l.Brightness = 2.2
            l.GlobalShadows = true
            l.OutdoorAmbient = Color3.fromRGB(90, 70, 60)
            l.Ambient = Color3.fromRGB(40, 30, 20)

            local cc = l:FindFirstChild("ShaderCC")
            if not cc then
                cc = Instance.new("ColorCorrectionEffect")
                cc.Name = "ShaderCC"
                cc.Parent = l
            end
            cc.Brightness = 0.05
            cc.Contrast = 0.25
            cc.Saturation = 0.3
            cc.TintColor = Color3.fromRGB(255, 220, 180)

            local bloom = l:FindFirstChild("ShaderBloom")
            if not bloom then
                bloom = Instance.new("BloomEffect")
                bloom.Name = "ShaderBloom"
                bloom.Parent = l
            end
            bloom.Intensity = 0.6
            bloom.Size = 24
            bloom.Threshold = 0.7

            local sun = l:FindFirstChild("ShaderSky")
            if not sun then
                sun = Instance.new("Sky")
                sun.Name = "ShaderSky"
                sun.SkyboxBk = "rbxassetid://64125036"
                sun.SkyboxDn = "rbxassetid://64125045"
                sun.SkyboxFt = "rbxassetid://64125067"
                sun.SkyboxLf = "rbxassetid://64125078"
                sun.SkyboxRt = "rbxassetid://64125091"
                sun.SkyboxUp = "rbxassetid://64125103"
                sun.Parent = l
            elseif sun.Parent ~= l then
                sun.Parent = l
            end
        end
    end)
end

local function DisableShader()
    if not shaderActive then return end
    shaderActive = false

    if shaderMonitorThread then
        pcall(function() task.cancel(shaderMonitorThread) end)
        shaderMonitorThread = nil
    end

    local l = game:GetService("Lighting")
    local cc = l:FindFirstChild("ShaderCC")
    if cc then cc:Destroy() end
    local bloom = l:FindFirstChild("ShaderBloom")
    if bloom then bloom:Destroy() end
    local sun = l:FindFirstChild("ShaderSky")
    if sun then sun:Destroy() end

    RestoreLightingOriginal()
end

_G.Shader = {
    Enable = EnableShader,
    Disable = DisableShader,
    IsActive = function() return shaderActive end,
}

VisualGroup:AddToggle("ShaderToggle", {
    Text = "Shader",
    Default = false,
    Callback = function(Value)
        if Value then
            EnableShader()
            Library:Notify("Shader: Activated ✓", 3)
        else
            DisableShader()
            Library:Notify("Shader: Deactivated", 3)
        end
    end,
})

-- =====================================================
-- ★ Visuals タブ - ESP (Rainbow ESP + Aim Cross)
-- =====================================================
local ESPGroup = Tabs.VisualTab:AddRightGroupbox("ESP", "crosshair")

local esp_Enabled = false
local esp_GuiParent = (gethui and gethui()) or game:GetService("CoreGui")
local esp_Camera = Workspace.CurrentCamera
local esp_StarterGui = game:GetService("StarterGui")

local esp_ApplyCoreGuiDelta = function()
    pcall(function()
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Crosshair, false)
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
        esp_StarterGui:SetCore("TopbarEnabled", true)
    end)
end

local esp_HideAimGui = function()
    local targets = {
        esp_GuiParent,
        LocalPlayer:FindFirstChild("PlayerGui"),
        esp_Camera,
    }
    for _, root in ipairs(targets) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("GuiObject") then
                    local name = obj.Name:lower()
                    if name:find("cross") or name:find("aim") or name:find("reticle") or name:find("cursor") then
                        pcall(function()
                            obj.Visible = false
                            obj.Enabled = false
                        end)
                    end
                end
            end
        end
    end
end

local esp_ScreenGui = Instance.new("ScreenGui")
esp_ScreenGui.Name = "RainbowESP_Astra"
esp_ScreenGui.ResetOnSpawn = false
esp_ScreenGui.IgnoreGuiInset = true
esp_ScreenGui.DisplayOrder = 999999
esp_ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
esp_ScreenGui.Parent = esp_GuiParent
esp_ScreenGui.Enabled = false

local ESP_ROTATION_SPEED = 2
local ESP_BOX_SIZE = 45
local ESP_BRACKET_LENGTH = 8
local ESP_THICKNESS = 2
local ESP_MAX_DISTANCE = 100
local ESP_PULSE_SPEED = 2
local ESP_PULSE_MIN = 0.2

local ESP_AIM_ROTATION_SPEED = 2
local ESP_AIM_SIZE = 8
local ESP_AIM_THICKNESS = 2
local ESP_AIM_GAP = 4

local esp_Objects = {}
local esp_Thread = nil
local esp_CoreGuiThread = nil

local function esp_GetRainbowColor(t)
    return Color3.fromRGB(
        math.sin(t * 2) * 127 + 128,
        math.sin(t * 2 + 2) * 127 + 128,
        math.sin(t * 2 + 4) * 127 + 128
    )
end

local function esp_GetTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild("Head")
        or character:FindFirstChild("CamPart")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("Torso")
end

local function esp_GetMyPosition()
    if LocalPlayer.Character then
        local myPart = esp_GetTargetPart(LocalPlayer.Character)
        if myPart then return myPart.Position end
    end
    return esp_Camera.CFrame.Position
end

local function esp_CreateESP(player)
    if esp_Objects[player] then return end
    local lines = {}
    for i = 1, 8 do
        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BorderSizePixel = 0
        frame.Visible = false
        frame.ZIndex = 999999
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Parent = esp_ScreenGui
        table.insert(lines, frame)
    end
    esp_Objects[player] = lines
end

local function esp_RemoveESP(player)
    if esp_Objects[player] then
        for _, frame in ipairs(esp_Objects[player]) do
            frame:Destroy()
        end
        esp_Objects[player] = nil
    end
end

local function esp_DrawLine(frame, x1, y1, x2, y2, color)
    local dx, dy = x2 - x1, y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then
        frame.Visible = false
        return
    end
    local angle = math.atan2(dy, dx)
    local mx = (x1 + x2) / 2
    local my = (y1 + y2) / 2
    frame.Position = UDim2.new(0, mx, 0, my)
    frame.Size = UDim2.new(0, length, 0, ESP_THICKNESS)
    frame.Rotation = math.deg(angle)
    frame.BackgroundColor3 = color
    frame.Visible = true
end

local esp_AimLines = {}
for i = 1, 4 do
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 1000000
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = esp_ScreenGui
    table.insert(esp_AimLines, frame)
end

local function esp_DrawAimCross(centerX, centerY, angle, color)
    local dirs = {
        {x =  1, y =  1},
        {x =  1, y = -1},
        {x = -1, y = -1},
        {x = -1, y =  1},
    }
    local cosA, sinA = math.cos(angle), math.sin(angle)

    for i, dir in ipairs(dirs) do
        local startX = dir.x * ESP_AIM_GAP
        local startY = dir.y * ESP_AIM_GAP
        local endX = dir.x * (ESP_AIM_GAP + ESP_AIM_SIZE)
        local endY = dir.y * (ESP_AIM_GAP + ESP_AIM_SIZE)

        local rsx = startX * cosA - startY * sinA
        local rsy = startX * sinA + startY * cosA
        local rex = endX * cosA - endY * sinA
        local rey = endX * sinA + endY * cosA

        local sx = centerX + rsx
        local sy = centerY + rsy
        local ex = centerX + rex
        local ey = centerY + rey

        local frame = esp_AimLines[i]
        local dx, dy = ex - sx, ey - sy
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            local a = math.atan2(dy, dx)
            local mx = (sx + ex) / 2
            local my = (sy + ey) / 2
            frame.Position = UDim2.new(0, mx, 0, my)
            frame.Size = UDim2.new(0, length, 0, ESP_AIM_THICKNESS)
            frame.Rotation = math.deg(a)
            frame.BackgroundColor3 = color
            frame.Visible = true
        else
            frame.Visible = false
        end
    end
end

local function esp_ClearAll()
    for player, lines in pairs(esp_Objects) do
        for _, frame in ipairs(lines) do
            frame:Destroy()
        end
        esp_Objects[player] = nil
    end
    for _, frame in ipairs(esp_AimLines) do
        frame.Visible = false
    end
end

local function esp_RenderLoop()
    local t = tick()
    local color = esp_GetRainbowColor(t)
    local angle = t * ESP_ROTATION_SPEED
    local myPos = esp_GetMyPosition()

    local pulseWave = (math.sin(t * math.pi / ESP_PULSE_SPEED) + 1) / 2
    local scale = ESP_PULSE_MIN + (1 - ESP_PULSE_MIN) * pulseWave

    local boxSize = ESP_BOX_SIZE * scale
    local armLen = ESP_BRACKET_LENGTH * scale

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = esp_GetTargetPart(player.Character)
            if not esp_Objects[player] then esp_CreateESP(player) end
            local lines = esp_Objects[player]

            local shouldShow = false
            if part then
                local dist = (part.Position - myPos).Magnitude
                if dist <= ESP_MAX_DISTANCE then
                    shouldShow = true
                end
            end

            if shouldShow then
                local screenPos, onScreen = esp_Camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    local cx, cy = screenPos.X, screenPos.Y
                    local half = boxSize / 2
                    local arm = armLen

                    local corners = {
                        {pos = {x = -half, y = -half}, arms = {{x = 1, y = 0}, {x = 0, y = 1}}},
                        {pos = {x =  half, y = -half}, arms = {{x = -1, y = 0}, {x = 0, y = 1}}},
                        {pos = {x =  half, y =  half}, arms = {{x = -1, y = 0}, {x = 0, y = -1}}},
                        {pos = {x = -half, y =  half}, arms = {{x = 1, y = 0}, {x = 0, y = -1}}},
                    }

                    local cosA, sinA = math.cos(angle), math.sin(angle)
                    local idx = 1

                    for c = 1, 4 do
                        local corner = corners[c]
                        local pos = corner.pos

                        local rx = pos.x * cosA - pos.y * sinA
                        local ry = pos.x * sinA + pos.y * cosA
                        local sx = cx + rx
                        local sy = cy + ry

                        for a = 1, 2 do
                            local dir = corner.arms[a]
                            local dx = dir.x * arm
                            local dy = dir.y * arm
                            local rdx = dx * cosA - dy * sinA
                            local rdy = dx * sinA + dy * cosA
                            local ex = sx + rdx
                            local ey = sy + rdy
                            esp_DrawLine(lines[idx], sx, sy, ex, ey, color)
                            idx = idx + 1
                        end
                    end
                else
                    for _, frame in ipairs(lines) do
                        frame.Visible = false
                    end
                end
            else
                for _, frame in ipairs(lines) do
                    frame.Visible = false
                end
            end
        end
    end

    for player, _ in pairs(esp_Objects) do
        if not player.Parent then
            esp_RemoveESP(player)
        end
    end

    local viewportSize = esp_Camera.ViewportSize
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2
    local aimAngle = t * ESP_AIM_ROTATION_SPEED
    esp_DrawAimCross(centerX, centerY, aimAngle, color)
end

local function esp_Start()
    if esp_Enabled then return end
    esp_Enabled = true
    esp_ScreenGui.Enabled = true

    esp_ApplyCoreGuiDelta()
    esp_CoreGuiThread = task.spawn(function()
        while esp_Enabled do
            esp_ApplyCoreGuiDelta()
            esp_HideAimGui()
            task.wait(0.5)
        end
    end)

    esp_Thread = RunService.RenderStepped:Connect(esp_RenderLoop)
end

local function esp_Stop()
    if not esp_Enabled then return end
    esp_Enabled = false
    esp_ScreenGui.Enabled = false

    if esp_CoreGuiThread then
        pcall(function() task.cancel(esp_CoreGuiThread) end)
        esp_CoreGuiThread = nil
    end
    if esp_Thread then
        pcall(function() esp_Thread:Disconnect() end)
        esp_Thread = nil
    end

    esp_ClearAll()

    pcall(function()
        esp_StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Crosshair, true)
    end)
end

_G.RainbowESP = {
    Start = esp_Start,
    Stop = esp_Stop,
    IsActive = function() return esp_Enabled end,
}

ESPGroup:AddToggle("RainbowESPToggle", {
    Text = "ESP (Rainbow + Aim Cross)",
    Default = false,
    Callback = function(Value)
        if Value then
            esp_Start()
            Library:Notify("Rainbow ESP: Activated ✓", 3)
        else
            esp_Stop()
            Library:Notify("Rainbow ESP: Deactivated", 3)
        end
    end,
})

Players.PlayerRemoving:Connect(esp_RemoveESP)

game:BindToClose(function()
    esp_Stop()
end)

-- =====================================================
-- ★ Server & Kick タブ - Blob Kick
-- =====================================================
local ServerKickGroup = Tabs.ServerKickTab:AddLeftGroupbox("Blob Kick", "zap")

-- =====================================================
-- Blob Kick All (v1)
-- =====================================================
local bka1_LP = LocalPlayer
local bka1_GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
local bka1_lineLagThread = nil
local bka1_lineLagEnabled = false

local function bka1_startLineLag()
    if bka1_lineLagEnabled then return end
    bka1_lineLagEnabled = true
    bka1_lineLagThread = task.spawn(function()
        if not bka1_GrabEvents then return end
        local createLine = bka1_GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        while bka1_lineLagEnabled do
            local target = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (bka1_LP.Character and bka1_LP.Character:FindFirstChild("HumanoidRootPart"))
            if target then
                for i = 1, 10 do
                    local randomX = math.random(-1e9, 1e9)
                    local randomZ = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(randomX, 0, randomZ))
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function bka1_stopLineLag()
    bka1_lineLagEnabled = false
    if bka1_lineLagThread then task.cancel(bka1_lineLagThread) end
end

local bka1_currentBlob = nil
local bka1_isActive = false
local bka1_playerStatus = {}
local bka1_activeBodyPositions = {}
local bka1_rotateThread = nil
local bka1_stopRotate = false

local function bka1_GetAllPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= bka1_LP then
            table.insert(players, player)
        end
    end
    return players
end

local function bka1_GetMyRoot()
    return bka1_LP.Character and bka1_LP.Character:FindFirstChild("HumanoidRootPart")
end

local function bka1_ResetTargets()
    for id, status in pairs(bka1_playerStatus) do
        if status == "Targeting" then bka1_playerStatus[id] = nil end
    end
end

local function bka1_ClearBodyPositions()
    for _, bp in ipairs(bka1_activeBodyPositions) do
        pcall(function() bp:Destroy() end)
    end
    bka1_activeBodyPositions = {}
end

local function bka1_StopRotate()
    bka1_stopRotate = true
    if bka1_rotateThread then
        task.cancel(bka1_rotateThread)
        bka1_rotateThread = nil
    end
end

local function bka1_KickAll()
    if bka1_isActive then return end
    bka1_isActive = true
    local allPlayers = bka1_GetAllPlayers()
    if #allPlayers == 0 then
        bka1_isActive = false
        return
    end
    for _, targetPlayer in ipairs(allPlayers) do
        bka1_playerStatus[targetPlayer.UserId] = "Targeting"
    end
    local rootPart = bka1_GetMyRoot()
    if rootPart then
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
        pcall(function()
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
        end)
    end
    task.wait(0.5)
    local toyFolder = workspace:FindFirstChild(bka1_LP.Name .. "SpawnedInToys")
    bka1_currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
    if not bka1_currentBlob then
        bka1_ResetTargets()
        bka1_isActive = false
        return
    end
    local vehicleSeat = bka1_currentBlob:FindFirstChild("VehicleSeat")
    if vehicleSeat and bka1_LP.Character then
        local humanoid = bka1_LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            vehicleSeat:Sit(humanoid)
        end
    end
    task.wait(0.3)
    local myRoot = bka1_GetMyRoot()
    if not myRoot then
        bka1_ResetTargets()
        bka1_isActive = false
        return
    end
    local tpWait = 0.025
    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(tpWait)
            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            if distance <= 35 then
                for i = 1, 8 do
                    if not targetRoot.Parent or not bka1_currentBlob.Parent then break end
                    pcall(function()
                        bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka1_currentBlob.LeftDetector, targetRoot, bka1_currentBlob.LeftDetector.LeftWeld
                        )
                        bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(bka1_currentBlob.LeftDetector.LeftWeld)
                    end)
                    task.wait()
                end
            end
        end
    end
    myRoot.CFrame = CFrame.new(0, 0, 0)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    for _, part in ipairs(bka1_currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
    end
    task.wait(0.1)
    local radius = 13
    local centerX, centerY, centerZ = 0, 10, 0
    bka1_ClearBodyPositions()
    for i, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #allPlayers))
            local x = centerX + radius * math.cos(angle)
            local z = centerZ + radius * math.sin(angle)
            pcall(function()
                targetRoot.CFrame = CFrame.new(x, centerY, z)
                targetRoot.AssemblyLinearVelocity = Vector3.zero
                targetRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P = 4000
            bp.Position = Vector3.new(x, centerY, z)
            bp.Parent = targetRoot
            table.insert(bka1_activeBodyPositions, bp)
        end
    end
    task.wait(0.1)
    for _ = 1, 2 do
        for _, targetPlayer in ipairs(allPlayers) do
            local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position))
                        ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(targetRoot)
                    end)
                end)
            end
        end
        task.wait(0.1)
    end
    task.wait(0.3)
    local rotateSpeed = 3
    bka1_stopRotate = false
    if bka1_rotateThread then task.cancel(bka1_rotateThread) end
    bka1_rotateThread = task.spawn(function()
        while not bka1_stopRotate do
            local t = tick() * rotateSpeed
            local bx = centerX + radius * math.cos(t)
            local bz = centerZ + radius * math.sin(t)
            if bka1_currentBlob and bka1_currentBlob.Parent then
                pcall(function()
                    bka1_currentBlob:PivotTo(CFrame.new(bx, centerY, bz))
                end)
            else
                break
            end
            for _, targetPlayer in ipairs(allPlayers) do
                local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot and bka1_currentBlob and bka1_currentBlob.Parent then
                    pcall(function()
                        bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka1_currentBlob.LeftDetector, targetRoot, bka1_currentBlob.LeftDetector.LeftWeld
                        )
                        bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka1_currentBlob.RightDetector, targetRoot, bka1_currentBlob.RightDetector.RightWeld
                        )
                    end)
                end
            end
            task.wait(0.1)
        end
    end)
    task.wait(3)
    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and bka1_currentBlob and bka1_currentBlob.Parent then
            task.spawn(function()
                pcall(function()
                    bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        bka1_currentBlob.LeftDetector, targetRoot, bka1_currentBlob.LeftDetector.LeftWeld
                    )
                    bka1_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                        bka1_currentBlob.RightDetector, targetRoot, bka1_currentBlob.RightDetector.RightWeld
                    )
                end)
            end)
        end
    end
    task.wait(0.3)
    for _, targetPlayer in ipairs(allPlayers) do
        if targetPlayer and targetPlayer.Parent == Players then
            bka1_playerStatus[targetPlayer.UserId] = "Kicked"
        end
    end
    task.wait(1)
    bka1_isActive = false
end

ServerKickGroup:AddToggle("BlobKickAllToggle", {
    Text = "Blob Kick All",
    Default = false,
    Callback = function(Value)
        if Value then
            bka1_startLineLag()
            task.spawn(function()
                pcall(function()
                    bka1_KickAll()
                end)
            end)
            task.delay(20, function()
                if bka1_lineLagEnabled then
                    bka1_stopLineLag()
                end
            end)
            Library:Notify("Blob Kick All: Activated ✓", 3)
        else
            bka1_stopLineLag()
            bka1_StopRotate()
            bka1_ClearBodyPositions()
            bka1_isActive = false
            Library:Notify("Blob Kick All: Deactivated", 3)
        end
    end,
})

-- =====================================================
-- Blob Kick All v2 (Orbit版)
-- =====================================================
local bka2_LP = LocalPlayer
local bka2_GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
local bka2_lineLagThread = nil
local bka2_lineLagEnabled = false

local bka2_OrbitRadius = 15
local bka2_OrbitHeight = 12
local bka2_OrbitSpeed = 4

local function bka2_startLineLag()
    if bka2_lineLagEnabled then return end
    bka2_lineLagEnabled = true
    bka2_lineLagThread = task.spawn(function()
        if not bka2_GrabEvents then return end
        local createLine = bka2_GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        while bka2_lineLagEnabled do
            local target = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (bka2_LP.Character and bka2_LP.Character:FindFirstChild("HumanoidRootPart"))
            if target then
                for i = 1, 10 do
                    local randomX = math.random(-1e9, 1e9)
                    local randomZ = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(randomX, 0, randomZ))
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function bka2_stopLineLag()
    bka2_lineLagEnabled = false
    if bka2_lineLagThread then task.cancel(bka2_lineLagThread) end
end

local bka2_currentBlob = nil
local bka2_isActive = false
local bka2_playerStatus = {}
local bka2_activeBodyPositions = {}
local bka2_orbitThread = nil
local bka2_grabThread = nil
local bka2_stopOrbit = false
local bka2_centerPoint = nil

local function bka2_GetAllPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= bka2_LP then
            table.insert(players, player)
        end
    end
    return players
end

local function bka2_GetMyRoot()
    return bka2_LP.Character and bka2_LP.Character:FindFirstChild("HumanoidRootPart")
end

local function bka2_ResetTargets()
    for id, status in pairs(bka2_playerStatus) do
        if status == "Targeting" then bka2_playerStatus[id] = nil end
    end
end

local function bka2_ClearBodyPositions()
    for _, bp in ipairs(bka2_activeBodyPositions) do
        pcall(function() bp:Destroy() end)
    end
    bka2_activeBodyPositions = {}
end

local function bka2_StopOrbit()
    bka2_stopOrbit = true
    if bka2_orbitThread then
        task.cancel(bka2_orbitThread)
        bka2_orbitThread = nil
    end
    if bka2_grabThread then
        task.cancel(bka2_grabThread)
        bka2_grabThread = nil
    end
end

local function bka2_KickAll()
    if bka2_isActive then return end
    bka2_isActive = true
    local allPlayers = bka2_GetAllPlayers()
    if #allPlayers == 0 then
        bka2_isActive = false
        return
    end
    for _, targetPlayer in ipairs(allPlayers) do
        bka2_playerStatus[targetPlayer.UserId] = "Targeting"
    end
    local rootPart = bka2_GetMyRoot()
    if rootPart then
        local spawnPos = rootPart.CFrame * CFrame.new(0, 0, -5)
        pcall(function()
            ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
        end)
    end
    task.wait(0.5)
    local toyFolder = workspace:FindFirstChild(bka2_LP.Name .. "SpawnedInToys")
    bka2_currentBlob = toyFolder and toyFolder:FindFirstChild("CreatureBlobman")
    if not bka2_currentBlob then
        bka2_ResetTargets()
        bka2_isActive = false
        return
    end
    local vehicleSeat = bka2_currentBlob:FindFirstChild("VehicleSeat")
    if vehicleSeat and bka2_LP.Character then
        local humanoid = bka2_LP.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            vehicleSeat:Sit(humanoid)
        end
    end
    task.wait(0.3)
    local myRoot = bka2_GetMyRoot()
    if not myRoot then
        bka2_ResetTargets()
        bka2_isActive = false
        return
    end
    local tpWait = 0.025
    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            myRoot.CFrame = targetRoot.CFrame
            myRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(tpWait)
            local distance = (myRoot.Position - targetRoot.Position).Magnitude
            if distance <= 35 then
                for i = 1, 8 do
                    if not targetRoot.Parent or not bka2_currentBlob.Parent then break end
                    pcall(function()
                        bka2_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka2_currentBlob.LeftDetector, targetRoot, bka2_currentBlob.LeftDetector.LeftWeld
                        )
                        bka2_currentBlob.BlobmanSeatAndOwnerScript.CreatureRelease:FireServer(bka2_currentBlob.LeftDetector.LeftWeld)
                    end)
                    task.wait()
                end
            end
        end
    end
    myRoot.CFrame = CFrame.new(0, 0, 0)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    for _, part in ipairs(bka2_currentBlob:GetDescendants()) do
        if part:IsA("BasePart") then pcall(function() part.Anchored = true end) end
    end
    task.wait(0.1)
    local centerX, centerY, centerZ = 0, 10, 0
    local validTargets = {}
    for _, targetPlayer in ipairs(allPlayers) do
        local targetRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            centerX = centerX + targetRoot.Position.X
            centerZ = centerZ + targetRoot.Position.Z
            table.insert(validTargets, { player = targetPlayer, root = targetRoot })
        end
    end
    if #validTargets == 0 then
        bka2_isActive = false
        return
    end
    centerX = centerX / #validTargets
    centerZ = centerZ / #validTargets
    bka2_centerPoint = Vector3.new(centerX, centerY, centerZ)

    bka2_ClearBodyPositions()
    for i, data in ipairs(validTargets) do
        local targetRoot = data.root
        if targetRoot then
            local angle = math.rad((i - 1) * (360 / #validTargets))
            local clusterRadius = 3
            local x = centerX + clusterRadius * math.cos(angle)
            local z = centerZ + clusterRadius * math.sin(angle)
            pcall(function()
                targetRoot.CFrame = CFrame.new(x, centerY, z)
                targetRoot.AssemblyLinearVelocity = Vector3.zero
                targetRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P = 4000
            bp.Position = Vector3.new(x, centerY, z)
            bp.Parent = targetRoot
            table.insert(bka2_activeBodyPositions, bp)
        end
    end
    task.wait(0.1)
    for _ = 1, 2 do
        for _, data in ipairs(validTargets) do
            local targetRoot = data.root
            if targetRoot then
                task.spawn(function()
                    pcall(function()
                        ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetRoot, CFrame.new(targetRoot.Position))
                        ReplicatedStorage.GrabEvents.DestroyGrabLine:FireServer(targetRoot)
                    end)
                end)
            end
        end
        task.wait(0.1)
    end
    task.wait(0.3)

    local startTime = tick()
    bka2_stopOrbit = false

    bka2_orbitThread = task.spawn(function()
        while not bka2_stopOrbit do
            local elapsed = tick() - startTime
            local currentAngle = elapsed * bka2_OrbitSpeed
            local bx = centerX + bka2_OrbitRadius * math.cos(currentAngle)
            local bz = centerZ + bka2_OrbitRadius * math.sin(currentAngle)
            local by = centerY + bka2_OrbitHeight + math.sin(elapsed * 2) * 2

            if bka2_currentBlob and bka2_currentBlob.Parent then
                pcall(function()
                    bka2_currentBlob:PivotTo(CFrame.new(bx, by, bz))
                end)
            else
                break
            end
            task.wait(0.03)
        end
    end)

    bka2_grabThread = task.spawn(function()
        while not bka2_stopOrbit do
            for _, data in ipairs(validTargets) do
                local targetRoot = data.root
                if targetRoot and targetRoot.Parent and bka2_currentBlob and bka2_currentBlob.Parent then
                    pcall(function()
                        bka2_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka2_currentBlob.LeftDetector, targetRoot, bka2_currentBlob.LeftDetector.LeftWeld
                        )
                        bka2_currentBlob.BlobmanSeatAndOwnerScript.CreatureGrab:FireServer(
                            bka2_currentBlob.RightDetector, targetRoot, bka2_currentBlob.RightDetector.RightWeld
                        )
                    end)
                end
            end
            task.wait(0.02)
        end
    end)

    task.wait(6)

    bka2_StopOrbit()
    task.wait(0.3)

    for _, targetPlayer in ipairs(allPlayers) do
        if targetPlayer and targetPlayer.Parent == Players then
            bka2_playerStatus[targetPlayer.UserId] = "Kicked"
        end
    end
    task.wait(1)
    bka2_isActive = false
end

ServerKickGroup:AddToggle("BlobKickAllV2Toggle", {
    Text = "Blob Kick All v2 (Orbit)",
    Default = false,
    Callback = function(Value)
        if Value then
            bka2_startLineLag()
            task.spawn(function()
                pcall(function()
                    bka2_KickAll()
                end)
            end)
            task.delay(20, function()
                if bka2_lineLagEnabled then
                    bka2_stopLineLag()
                end
            end)
            Library:Notify("Blob Kick All v2 (Orbit): Activated ✓", 3)
        else
            bka2_stopLineLag()
            bka2_StopOrbit()
            bka2_ClearBodyPositions()
            bka2_isActive = false
            Library:Notify("Blob Kick All v2 (Orbit): Deactivated", 3)
        end
    end,
})

-- =====================================================
-- Loop Blob Kick (INIT + PINGY)
-- =====================================================
local lbk_LP = LocalPlayer
local lbk_RS = ReplicatedStorage
local lbk_RunService = RunService
local lbk_GrabEvents = lbk_RS:FindFirstChild("GrabEvents")
local lbk_GrabEventsWait = lbk_RS:WaitForChild("GrabEvents", 10)
local lbk_LineLagThread = nil
local lbk_LineLagEnabled = false
local lbk_Enabled = false
local lbk_TargetName = nil
local lbk_Connections = {}

local function lbk_startLineLag()
    if lbk_LineLagEnabled then return end
    lbk_LineLagEnabled = true
    lbk_LineLagThread = task.spawn(function()
        if not lbk_GrabEvents then return end
        local createLine = lbk_GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        while lbk_LineLagEnabled do
            local target = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChild("Spawn")
                or (lbk_LP.Character and lbk_LP.Character:FindFirstChild("HumanoidRootPart"))
            if target then
                for i = 1, 10 do
                    local randomX = math.random(-1e9, 1e9)
                    local randomZ = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(randomX, 0, randomZ))
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function lbk_stopLineLag()
    lbk_LineLagEnabled = false
    if lbk_LineLagThread then
        task.cancel(lbk_LineLagThread)
        lbk_LineLagThread = nil
    end
end

local function lbk_StopAllVelocity(inst)
    if not inst then return end
    for _, v in pairs(inst:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end
end

local function lbk_FindBlob()
    local folder = Workspace:FindFirstChild(lbk_LP.Name .. "SpawnedInToys")
    if folder then
        local blob = folder:FindFirstChild("CreatureBlobman")
        if blob then return blob end
    end
    local myChar = lbk_LP.Character
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if seat then
        local parent = seat.Parent
        if parent and parent.Name == "CreatureBlobman" then
            return parent
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") then
            return obj
        end
    end
    return nil
end

local function lbk_CheckForPartOwner(head)
    if not head then return false end
    local soundPart = head:FindFirstChild("SoundPart")
    if not soundPart then return false end
    return soundPart:FindFirstChild("PartOwner") ~= nil
end

local function lbk_SpawnBlob()
    local myChar = lbk_LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local spawnPos = myRoot.CFrame * CFrame.new(0, 0, -5)
    pcall(function()
        lbk_RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", spawnPos, Vector3.new(0, 127, 0))
    end)
    task.wait(0.5)

    local blob = lbk_FindBlob()
    if blob then
        local seat = blob:FindFirstChild("VehicleSeat")
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if seat and hum and seat.Occupant ~= hum then
            pcall(function() seat:Sit(hum) end)
            task.wait(0.3)
        end
    end
    return blob
end

local function lbk_Enable()
    if lbk_Enabled then return end
    if not lbk_TargetName then
        Library:Notify("Loop Blob Kick: ターゲットを選択してください", 3)
        return
    end
    lbk_Enabled = true
    lbk_startLineLag()

    task.spawn(function()
        local target = Players:FindFirstChild(lbk_TargetName)
        if not target then
            lbk_Enabled = false
            lbk_stopLineLag()
            Library:Notify("Loop Blob Kick: ターゲットが見つかりません", 3)
            return
        end

        local blob = lbk_FindBlob()
        if not blob then
            blob = lbk_SpawnBlob()
        end
        if not blob then
            lbk_Enabled = false
            lbk_stopLineLag()
            Library:Notify("Loop Blob Kick: Blobman取得失敗", 3)
            return
        end

        local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
        if not scriptObj then
            lbk_Enabled = false
            lbk_stopLineLag()
            Library:Notify("Loop Blob Kick: BlobmanSeatAndOwnerScript なし", 3)
            return
        end

        local CreatureGrab = scriptObj:FindFirstChild("CreatureGrab")
        local CreatureDrop = scriptObj:FindFirstChild("CreatureDrop")
        local CreatureRelease = scriptObj:FindFirstChild("CreatureRelease")
        local LeftDetector = blob:FindFirstChild("LeftDetector")
        local RightDetector = blob:FindFirstChild("RightDetector")
        if not RightDetector then
            lbk_Enabled = false
            lbk_stopLineLag()
            Library:Notify("Loop Blob Kick: RightDetector なし", 3)
            return
        end

        local myChar = lbk_LP.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            lbk_Enabled = false
            lbk_stopLineLag()
            Library:Notify("Loop Blob Kick: 自機HRP なし", 3)
            return
        end

        local etc = {
            TargetPLR = target,
            Root = target.Character and target.Character:FindFirstChild("HumanoidRootPart"),
            Head = target.Character and target.Character:FindFirstChild("Head"),
            Hum = target.Character and target.Character:FindFirstChild("Humanoid"),
        }
        local oldCF = myRoot.CFrame
        local IsPreparing = true
        local IsFirst = true

        if not etc.Root or not etc.TargetPLR then
            lbk_Enabled = false
            lbk_stopLineLag()
            return
        end

        local function lbk_CreateBodyPos(parent)
            if not parent then return end
            for _, v in pairs(parent:GetChildren()) do
                if v.Name == "KickBodyPos1" then
                    pcall(function() v:Destroy() end)
                end
            end
            local BodyPos = Instance.new("BodyPosition")
            BodyPos.Name = "KickBodyPos1"
            BodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyPos.Position = oldCF.Position + Vector3.new(0, 25, 0)
            BodyPos.Parent = parent
            BodyPos.P = 45000
            BodyPos.D = 500
        end

        lbk_Connections["INIT"] = task.spawn(function()
            while lbk_Enabled do
                lbk_RunService.Heartbeat:Wait()
                etc.TargetPLR = lbk_TargetName and Players:FindFirstChild(lbk_TargetName)
                if not etc.TargetPLR then
                    IsPreparing = true
                    continue
                end

                etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                etc.Head = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                etc.Hum = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Humanoid")

                if not etc.Root or not etc.Hum or etc.Hum.Health == 0 or IsFirst then
                    IsPreparing = true
                    if not IsFirst then
                        etc.TargetPLR.CharacterAdded:Wait()
                    end
                    IsFirst = false
                    task.wait(0.3)
                    etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                    etc.Hum = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Humanoid")
                    if not etc.Root then continue end

                    oldCF = myChar and myChar:GetPivot() or oldCF
                    lbk_CreateBodyPos(etc.Root)

                    repeat
                        task.wait(0.01)
                        etc.Root = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
                        etc.Head = etc.TargetPLR.Character and etc.TargetPLR.Character:FindFirstChild("Head")
                        if not etc.Root then break end
                        if etc.TargetPLR.InPlot and etc.TargetPLR.InPlot.Value then continue end
                        if blob and blob.Parent then
                            pcall(function()
                                blob:PivotTo(etc.Root.CFrame * CFrame.new(etc.Root.AssemblyLinearVelocity * 0.1))
                            end)
                        end
                        if etc.Root then
                            pcall(function()
                                local GE = lbk_GrabEventsWait
                                if GE and GE:FindFirstChild("SetNetworkOwner") then
                                    GE.SetNetworkOwner:FireServer(etc.Root, etc.Root.CFrame)
                                end
                            end)
                        end
                    until (not etc.Root or not etc.Head) or lbk_CheckForPartOwner(etc.Head) or not lbk_Enabled

                    if myChar then
                        pcall(function() myChar:PivotTo(oldCF) end)
                    end
                    IsPreparing = false
                    lbk_StopAllVelocity(blob)
                    if etc.TargetPLR and etc.TargetPLR.Character then
                        lbk_StopAllVelocity(etc.TargetPLR.Character)
                        for _, v in pairs(etc.TargetPLR.Character:GetChildren()) do
                            if v:IsA("BasePart") then
                                pcall(function()
                                    v.CFrame = oldCF * CFrame.new(0, 20, 0)
                                end)
                            end
                        end
                    end
                    if blob then
                        local bhum = blob:FindFirstChild("HumanoidCreature")
                        if bhum then
                            pcall(function()
                                bhum.PlatformStand = false
                                bhum:ChangeState(Enum.HumanoidStateType.GettingUp)
                            end)
                        end
                    end
                end
            end
        end)

        lbk_Connections["MAIN"] = lbk_RunService.Heartbeat:Connect(function()
            if not lbk_Enabled or IsPreparing then return end
            if not etc.TargetPLR or not etc.TargetPLR.Character then return end
            etc.Root = etc.TargetPLR.Character:FindFirstChild("HumanoidRootPart")
            if not etc.Root then return end
            pcall(function()
                if CreatureGrab and RightDetector then
                    CreatureGrab:FireServer(RightDetector, etc.Root, RightDetector.RightWeld)
                end
            end)
            task.wait()
            pcall(function()
                if CreatureDrop and RightDetector then
                    CreatureDrop:FireServer(RightDetector.RightWeld, etc.Root)
                end
            end)
        end)
    end)
end

local function lbk_Disable()
    if not lbk_Enabled then return end
    lbk_Enabled = false
    lbk_stopLineLag()

    if lbk_Connections["INIT"] then
        pcall(function() task.cancel(lbk_Connections["INIT"]) end)
        lbk_Connections["INIT"] = nil
    end
    if lbk_Connections["MAIN"] then
        pcall(function() lbk_Connections["MAIN"]:Disconnect() end)
        lbk_Connections["MAIN"] = nil
    end

    local target = lbk_TargetName and Players:FindFirstChild(lbk_TargetName)
    if target and target.Character then
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local kbp = root:FindFirstChild("KickBodyPos1")
            if kbp then pcall(function() kbp:Destroy() end) end
        end
    end
end

_G.LoopBlobKick = {
    Enable = lbk_Enable,
    Disable = lbk_Disable,
    SetTarget = function(name) lbk_TargetName = name end,
    IsActive = function() return lbk_Enabled end,
}

local function lbk_GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lbk_LP then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    table.sort(list)
    if #list == 0 then list = { "(No Players)" } end
    return list
end

ServerKickGroup:AddDropdown("LoopBlobKickTargetDropdown", {
    Text = "Loop Kick Target",
    Values = lbk_GetPlayerList(),
    Default = 1,
    Callback = function(Value)
        local name = Value:match("%(@(.+)%)$")
        lbk_TargetName = name
        Library:Notify("Loop Blob Kick Target: " .. tostring(name or Value), 2)
    end,
})

ServerKickGroup:AddButton("LoopBlobKickRefreshBtn", {
    Text = "Refresh Loop Kick List",
    Func = function()
        local dropdown = Options.LoopBlobKickTargetDropdown
        if dropdown then
            pcall(function() dropdown:Refresh(lbk_GetPlayerList()) end)
            Library:Notify("Player list refreshed ✓", 2)
        end
    end,
})

ServerKickGroup:AddToggle("LoopBlobKickToggle", {
    Text = "Loop Blob Kick (INIT + PINGY)",
    Default = false,
    Callback = function(Value)
        if Value then
            if not lbk_TargetName then
                Library:Notify("Loop Blob Kick: ターゲットを選択してください", 3)
                return
            end
            lbk_Enable()
            Library:Notify("Loop Blob Kick: Activated ✓", 3)
        else
            lbk_Disable()
            Library:Notify("Loop Blob Kick: Deactivated", 3)
        end
    end,
})

local function lbk_refreshDropdown()
    task.wait(0.5)
    local dropdown = Options.LoopBlobKickTargetDropdown
    if dropdown then
        pcall(function() dropdown:Refresh(lbk_GetPlayerList()) end)
    end
end

Players.PlayerAdded:Connect(lbk_refreshDropdown)
Players.PlayerRemoving:Connect(lbk_refreshDropdown)

game:BindToClose(function()
    lbk_Disable()
end)

-- =====================================================
-- ★ Server & Kick タブ - Drift Kick
-- =====================================================
local DriftGroup = Tabs.ServerKickTab:AddLeftGroupbox("Drift Kick", "wind")

local dk_orbitRadius = 19
local dk_orbitSpeed = 8.5
local dk_orbitHeightOffset = 0
local dk_grabReleaseInterval = 0.08
local dk_respawnTrackingEnabled = true

local dk_LP = LocalPlayer
local dk_orbitRunning = false
local dk_orbitAngle = 0
local dk_orbitCurrentLoopId = 1
local dk_myLoopId = 1
local dk_activeThread = nil
local dk_targetName = nil

local dk_GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 10)

local function dk_GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= dk_LP then
            table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
        end
    end
    table.sort(list)
    if #list == 0 then list = { "(No Players)" } end
    return list
end

local function dk_startDriftKick(targetPlayer)
    if dk_orbitRunning then return end
    dk_orbitRunning = true
    dk_orbitCurrentLoopId = dk_orbitCurrentLoopId + 1
    dk_myLoopId = dk_orbitCurrentLoopId

    dk_activeThread = task.spawn(function()
        local target = targetPlayer
        if not target then
            dk_orbitRunning = false
            return
        end

        if not dk_LP.Character or not dk_LP.Character:FindFirstChild("HumanoidRootPart") then
            dk_LP.CharacterAdded:Wait()
            task.wait(0.5)
        end

        local blobman = nil
        local spawned = Workspace:FindFirstChild(dk_LP.Name .. "SpawnedInToys")
        if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
        if not blobman then
            local mt = ReplicatedStorage:FindFirstChild("MenuToys")
            local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction")
            if st then
                local myRoot = dk_LP.Character.HumanoidRootPart
                local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0)
                st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero)
                task.wait(0.8)
                spawned = Workspace:FindFirstChild(dk_LP.Name .. "SpawnedInToys")
                if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
            end
        end
        if not blobman then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") then
                    blobman = obj
                    break
                end
            end
        end
        if not blobman then
            Library:Notify("Drift Kick: Blobman取得失敗", 3)
            dk_orbitRunning = false
            return
        end

        local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
        local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
        local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
        local lDet = blobman:FindFirstChild("LeftDetector")
        local rDet = blobman:FindFirstChild("RightDetector")
        local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint"))
        local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
        local seat = blobman:FindFirstChild("VehicleSeat")
        local hum = dk_LP.Character:FindFirstChild("Humanoid")
        if seat and hum then
            if seat.Occupant ~= hum then
                dk_LP.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.2)
                seat:Sit(hum)
                task.wait(0.5)
            end
        end

        local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
        if not GE or not grabRemote or not dropRemote or not ((lDet and lWeld) or (rDet and rWeld)) then
            Library:Notify("Drift Kick: Remote不足", 3)
            dk_orbitRunning = false
            return
        end

        local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
        local Det = rDet or lDet
        local Weld = rWeld or lWeld

        local function regrabTarget(tRoot, retryCount)
            retryCount = retryCount or 0
            if retryCount > 3 then return false end
            if not tRoot or not blobRoot or not blobman or not blobman.Parent then return false end

            pcall(function()
                local cw = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                if cw then dropRemote:FireServer(cw) end
                GE.DestroyGrabLine:FireServer(tRoot)
            end)
            task.wait(math.min(dk_grabReleaseInterval * 0.3, 0.05))

            local success = false
            local grabDuration = math.min(dk_grabReleaseInterval * 1.5, 0.15)
            local startTime = tick()
            while tick() - startTime < grabDuration do
                if dk_myLoopId ~= dk_orbitCurrentLoopId or not dk_orbitRunning or not blobman or not blobman.Parent then break end
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local currentTRoot = target.Character.HumanoidRootPart
                    blobRoot.CFrame = currentTRoot.CFrame
                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                    pcall(function()
                        if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end
                        GE.CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame)
                    end)
                    success = true
                end
                RunService.Heartbeat:Wait()
            end

            if not success and retryCount < 3 then
                task.wait(dk_grabReleaseInterval * 0.2)
                return regrabTarget(tRoot, retryCount + 1)
            end
            return success
        end

        local function initialGrab()
            local start = tick()
            while tick() - start < 0.4 do
                if dk_myLoopId ~= dk_orbitCurrentLoopId or not dk_orbitRunning or not blobman or not blobman.Parent then return false end
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = target.Character.HumanoidRootPart
                    blobRoot.CFrame = tRoot.CFrame
                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                    pcall(function()
                        if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                        GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
                        GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
                    end)
                    return true
                end
                RunService.Heartbeat:Wait()
            end
            return false
        end

        if not initialGrab() then
            if not dk_respawnTrackingEnabled then
                dk_orbitRunning = false
                return
            else
                while not target.Character and target.Parent and dk_orbitRunning and blobman and blobman.Parent and dk_myLoopId == dk_orbitCurrentLoopId do
                    task.wait(0.5)
                end
                if not target.Character or not target.Parent then
                    dk_orbitRunning = false
                    return
                end
                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if not tRoot then
                    task.wait(0.3)
                    tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if not tRoot then
                        dk_orbitRunning = false
                        return
                    end
                end
                if not regrabTarget(tRoot) then
                    dk_orbitRunning = false
                    return
                end
            end
        end

        local tRoot = target.Character.HumanoidRootPart
        local SavedPos = tRoot.CFrame
        local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)

        local lastTime = tick()
        local lastDropTime = tick()

        while dk_orbitRunning and blobman and blobman.Parent do
            if dk_myLoopId ~= dk_orbitCurrentLoopId then break end
            if not target or not target.Parent then break end

            local tChar = target.Character
            if not tChar then
                if dk_respawnTrackingEnabled then
                    while not target.Character and target.Parent and dk_orbitRunning and blobman and blobman.Parent and dk_myLoopId == dk_orbitCurrentLoopId do
                        task.wait(0.5)
                    end
                    if not target.Character or not target.Parent then break end
                    tChar = target.Character
                    local newRoot = tChar:FindFirstChild("HumanoidRootPart")
                    if not newRoot then
                        task.wait(0.3)
                        newRoot = tChar:FindFirstChild("HumanoidRootPart")
                        if not newRoot then break end
                    end
                    if regrabTarget(newRoot) then
                        SavedPos = newRoot.CFrame
                        targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                        lastDropTime = tick()
                        lastTime = tick()
                    else
                        break
                    end
                else
                    break
                end
            end

            tRoot = tChar:FindFirstChild("HumanoidRootPart")
            local tHum = tChar:FindFirstChild("Humanoid")
            if not tRoot or not tHum or tHum.Health <= 0 then
                if dk_respawnTrackingEnabled then
                    while not target.Character and target.Parent and dk_orbitRunning and blobman and blobman.Parent and dk_myLoopId == dk_orbitCurrentLoopId do
                        task.wait(0.5)
                    end
                    if not target.Character or not target.Parent then break end
                    tChar = target.Character
                    local newRoot = tChar:FindFirstChild("HumanoidRootPart")
                    if not newRoot then
                        task.wait(0.3)
                        newRoot = tChar:FindFirstChild("HumanoidRootPart")
                        if not newRoot then break end
                    end
                    if regrabTarget(newRoot) then
                        SavedPos = newRoot.CFrame
                        targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0)
                        lastDropTime = tick()
                        lastTime = tick()
                    else
                        break
                    end
                else
                    break
                end
            end

            if tRoot and tHum and tHum.Health > 0 and blobRoot then
                local currentTime = tick()
                local dt = currentTime - lastTime
                lastTime = currentTime

                dk_orbitAngle = dk_orbitAngle + (dk_orbitSpeed * dt)
                local offsetX = math.cos(dk_orbitAngle) * dk_orbitRadius
                local offsetZ = math.sin(dk_orbitAngle) * dk_orbitRadius
                local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, dk_orbitHeightOffset, offsetZ)

                blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position)
                blobRoot.AssemblyLinearVelocity = Vector3.zero
                blobRoot.AssemblyAngularVelocity = Vector3.zero

                tRoot.CFrame = targetCenterCFrame
                tRoot.AssemblyLinearVelocity = Vector3.zero
                tRoot.AssemblyAngularVelocity = Vector3.zero

                pcall(function()
                    tHum.PlatformStand = true
                    tHum.Sit = true
                    GE.SetNetworkOwner:FireServer(tRoot, targetCenterCFrame)
                    local cw = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                    if cw then dropRemote:FireServer(cw) end
                    GE.DestroyGrabLine:FireServer(tRoot)
                    if Det then grabRemote:FireServer(Det, tRoot, Weld) end
                    GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false)
                end)

                if (tick() - lastDropTime) > dk_grabReleaseInterval then
                    lastDropTime = tick()
                    pcall(function()
                        local cw = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                        if cw then dropRemote:FireServer(cw) end
                        GE.DestroyGrabLine:FireServer(tRoot)
                    end)
                    blobRoot.CFrame = SavedPos
                    blobRoot.AssemblyLinearVelocity = Vector3.zero
                    task.wait(math.min(dk_grabReleaseInterval * 0.2, 0.03))

                    local recaptureDuration = math.min(dk_grabReleaseInterval * 1.2, 0.12)
                    local recaptureStart = tick()
                    while tick() - recaptureStart < recaptureDuration do
                        if dk_myLoopId ~= dk_orbitCurrentLoopId or not dk_orbitRunning or not blobman or not blobman.Parent then break end
                        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                            local curTRoot = target.Character.HumanoidRootPart
                            blobRoot.CFrame = curTRoot.CFrame
                            blobRoot.AssemblyLinearVelocity = Vector3.zero
                            pcall(function()
                                if Det then grabRemote:FireServer(Det, curTRoot, Weld) end
                                GE.CreateGrabLine:FireServer(curTRoot, Vector3.zero, curTRoot.Position, false)
                                GE.SetNetworkOwner:FireServer(curTRoot, blobRoot.CFrame)
                            end)
                        end
                        RunService.Heartbeat:Wait()
                    end
                    lastTime = tick()
                end
            end
            RunService.Heartbeat:Wait()
        end

        if blobRoot and SavedPos then
            pcall(function()
                local cw = Det:FindFirstChild("RightWeld") or Det:FindFirstChild("LeftWeld") or Det:FindFirstChildWhichIsA("Weld") or Det:FindFirstChild("RigidConstraint")
                if cw then dropRemote:FireServer(cw) end
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    GE.DestroyGrabLine:FireServer(target.Character.HumanoidRootPart)
                end
            end)
            blobRoot.CFrame = SavedPos
            blobRoot.AssemblyLinearVelocity = Vector3.zero
        end

        dk_orbitRunning = false
    end)
end

local function dk_stopDriftKick()
    dk_orbitRunning = false
    dk_orbitCurrentLoopId = dk_orbitCurrentLoopId + 1
    if dk_activeThread then
        pcall(function() task.cancel(dk_activeThread) end)
        dk_activeThread = nil
    end
end

_G.DriftKick = {
    Start = function(name)
        local plr = name and Players:FindFirstChild(name)
        if plr then dk_startDriftKick(plr) end
    end,
    Stop = dk_stopDriftKick,
    IsActive = function() return dk_orbitRunning end,
}

DriftGroup:AddDropdown("DriftKickTargetDropdown", {
    Text = "Select Target",
    Values = dk_GetPlayerList(),
    Default = 1,
    Callback = function(Value)
        local name = Value:match("%(@(.+)%)$")
        dk_targetName = name
        Library:Notify("Drift Kick Target: " .. tostring(name or Value), 2)
    end,
})

DriftGroup:AddButton("DriftKickRefreshBtn", {
    Text = "Refresh Player List",
    Func = function()
        local dropdown = Options.DriftKickTargetDropdown
        if dropdown then
            pcall(function() dropdown:Refresh(dk_GetPlayerList()) end)
            Library:Notify("Player list refreshed ✓", 2)
        end
    end,
})

DriftGroup:AddToggle("DriftKickToggle", {
    Text = "Drift Kick",
    Default = false,
    Callback = function(Value)
        if Value then
            if not dk_targetName then
                Library:Notify("Drift Kick: ターゲットを選択してください", 3)
                return
            end
            local plr = Players:FindFirstChild(dk_targetName)
            if not plr then
                Library:Notify("Drift Kick: ターゲットが見つかりません", 3)
                return
            end
            dk_startDriftKick(plr)
            Library:Notify("Drift Kick: Activated ✓", 3)
        else
            dk_stopDriftKick()
            Library:Notify("Drift Kick: Deactivated", 3)
        end
    end,
})

local function dk_refreshDropdown()
    task.wait(0.5)
    local dropdown = Options.DriftKickTargetDropdown
    if dropdown then
        pcall(function() dropdown:Refresh(dk_GetPlayerList()) end)
    end
end

Players.PlayerAdded:Connect(dk_refreshDropdown)
Players.PlayerRemoving:Connect(dk_refreshDropdown)

game:BindToClose(function()
    dk_stopDriftKick()
end)

-- =====================================================
-- Destroy Server (LagKick)
-- =====================================================
local DestroyGroup = Tabs.ServerKickTab:AddRightGroupbox("Destroy Server", "skull")

_G.LineLagPacketCount = 10
_G.HeightMode = "Spawn"

local ds_LP = LocalPlayer
local ds_GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")

local function ds_getAllPlayers()
    local players = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= ds_LP then
            table.insert(players, plr)
        end
    end
    return players
end

local function ds_spamOwnership(hrp)
    if not ds_GrabEvents then return end
    local setOwner = ds_GrabEvents:FindFirstChild("SetNetworkOwner")
    if setOwner and hrp then
        pcall(function() setOwner:FireServer(hrp, hrp.CFrame) end)
    end
end

local function ds_teleportToPlayer(myHrp, targetHrp)
    if not myHrp or not targetHrp then return end
    pcall(function()
        myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 5, 5)
        myHrp.AssemblyLinearVelocity = Vector3.zero
    end)
end

local function ds_destroyLineOnPlayer(hrp)
    if not ds_GrabEvents then return end
    local createLine = ds_GrabEvents:FindFirstChild("CreateGrabLine")
    local destroyLine = ds_GrabEvents:FindFirstChild("DestroyGrabLine")
    if not createLine or not destroyLine then return end
    pcall(function()
        createLine:FireServer(hrp, CFrame.new(0, 1e9, 0))
        task.wait()
        destroyLine:FireServer(hrp)
    end)
end

local ds_lineLagThread = nil
local ds_lineLagEnabled = false

local function ds_startLineLag()
    if ds_lineLagEnabled then return end
    ds_lineLagEnabled = true
    ds_lineLagThread = task.spawn(function()
        if not ds_GrabEvents then return end
        local createLine = ds_GrabEvents:FindFirstChild("CreateGrabLine")
        if not createLine then return end
        local packetCount = _G.LineLagPacketCount or 10
        while ds_lineLagEnabled do
            local target = Workspace:FindFirstChild("SpawnLocation")
                or Workspace:FindFirstChild("Spawn")
                or (ds_LP.Character and ds_LP.Character:FindFirstChild("HumanoidRootPart"))
            if target then
                for i = 1, packetCount do
                    local randomX = math.random(-1e9, 1e9)
                    local randomZ = math.random(-1e9, 1e9)
                    pcall(function()
                        createLine:FireServer(target, CFrame.new(randomX, 0, randomZ))
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

local function ds_stopLineLag()
    ds_lineLagEnabled = false
    if ds_lineLagThread then
        task.cancel(ds_lineLagThread)
        ds_lineLagThread = nil
    end
end

local ds_running = false

local function ds_destroyServer()
    if ds_running then return end
    ds_running = true
    task.spawn(function()
        local height = (_G.HeightMode == "Heaven") and 1e9 or 35
        ds_startLineLag()
        task.wait(1)
        local players = ds_getAllPlayers()
        if #players == 0 then
            ds_stopLineLag()
            ds_running = false
            return
        end
        local myChar = ds_LP.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then
            ds_stopLineLag()
            ds_running = false
            return
        end
        local playerData = {}
        for _, plr in ipairs(players) do
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(playerData, { player = plr, hrp = hrp })
            end
        end
        for _, data in ipairs(playerData) do
            ds_teleportToPlayer(myHrp, data.hrp)
            task.wait(0.2)
            ds_spamOwnership(data.hrp)
            task.wait()
        end
        local radius = 40
        local angleStep = (math.pi * 2) / #playerData
        for idx, data in ipairs(playerData) do
            local angle = (idx - 1) * angleStep
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            pcall(function()
                data.hrp.CFrame = CFrame.new(x, height, z)
                data.hrp.AssemblyLinearVelocity = Vector3.zero
            end)
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P = 40000000
            bp.Position = Vector3.new(x, height, z)
            bp.Parent = data.hrp
            task.delay(2, function() pcall(function() bp:Destroy() end) end)
            task.wait()
        end
        for i = 1, 8 do
            for _, data in ipairs(playerData) do
                ds_destroyLineOnPlayer(data.hrp)
            end
            task.wait(0.3)
        end
        ds_running = false
    end)
end

DestroyGroup:AddToggle("DestroyServerToggle", {
    Text = "Destroy Server",
    Default = false,
    Callback = function(Value)
        if Value then
            ds_destroyServer()
            Library:Notify("Destroy Server: Activated ✓", 3)
        else
            ds_stopLineLag()
            ds_running = false
            Library:Notify("Destroy Server: Deactivated", 3)
        end
    end,
})

DestroyGroup:AddDropdown("DestroyServerHeightDropdown", {
    Text = "Height Mode",
    Values = { "Spawn", "Heaven" },
    Default = "Spawn",
    Callback = function(Value)
        _G.HeightMode = Value
        Library:Notify("Height Mode: " .. Value, 2)
    end,
})

DestroyGroup:AddSlider("DestroyServerPacketSlider", {
    Text = "Packet Count",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        _G.LineLagPacketCount = Value
    end,
})

_G.LagKick = {
    Destroy = ds_destroyServer,
    Stop = function()
        ds_stopLineLag()
        ds_running = false
    end,
    SetPacketCount = function(n) _G.LineLagPacketCount = n end,
    SetHeightMode = function(m) _G.HeightMode = m end,
}

-- =====================================================
-- ★ Server & Kick タブ - Ragdoll Kill
-- =====================================================
local RagdollGroup = Tabs.ServerKickTab:AddRightGroupbox("Ragdoll Kill", "user")

local rk_targetName = nil
local rk_mode = "ragdoll"

local function rk_GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.DisplayName .. " (@" .. player.Name .. ")")
        end
    end
    table.sort(list)
    if #list == 0 then list = { "(No Players)" } end
    return list
end

local function rk_getLocalChar()
    return LocalPlayer.Character
end

local function rk_getHumanoidRootPart()
    local char = rk_getLocalChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function rk_getSpawnedToysFolder()
    return Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
end

local function rk_destroyAllPencils()
    local folder = rk_getSpawnedToysFolder()
    if not folder then return end
    local destroyToy = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
    if not destroyToy then return end
    for _, child in pairs(folder:GetChildren()) do
        if child.Name == "ToolPencil" then
            pcall(function() destroyToy:FireServer(child) end)
        end
    end
end

local function rk_countPencils()
    local folder = rk_getSpawnedToysFolder()
    if not folder then return 0 end
    local count = 0
    for _, child in pairs(folder:GetChildren()) do
        if child.Name == "ToolPencil" then
            count = count + 1
        end
    end
    return count
end

local function rk_isPencilWeldedToTarget(targetName)
    local folder = rk_getSpawnedToysFolder()
    if not folder then return false end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return false end
    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then return false end
    for _, child in pairs(folder:GetChildren()) do
        if child.Name == "ToolPencil" then
            local stickyPart = child:FindFirstChild("StickyPart")
            if stickyPart then
                local weld = stickyPart:FindFirstChild("StickyWeld")
                if weld and weld.Part1 == targetHead then
                    return true
                end
            end
        end
    end
    return false
end

local function rk_spawnToolPencil()
    local hrp = rk_getHumanoidRootPart()
    if not hrp then return nil end
    local spawnPos = hrp.CFrame * CFrame.new(0, 14, 20)
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    if not menuToys then return nil end
    local spawnRemote = menuToys:FindFirstChild("SpawnToyRemoteFunction")
    if not spawnRemote then return nil end
    local spawned = nil
    local folder = rk_getSpawnedToysFolder()
    if not folder then return nil end
    local conn
    conn = folder.ChildAdded:Connect(function(child)
        if child.Name == "ToolPencil" then
            spawned = child
            conn:Disconnect()
        end
    end)
    task.spawn(function()
        pcall(function() spawnRemote:InvokeServer("ToolPencil", spawnPos, Vector3.zero) end)
    end)
    local start = tick()
    repeat task.wait(0.05) until spawned or (tick() - start) > 3
    if conn then pcall(function() conn:Disconnect() end) end
    return spawned
end

local function rk_setNetworkOwnerPencil(part)
    if not part then return end
    local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not grabEvents then return end
    local setNet = grabEvents:FindFirstChild("SetNetworkOwner")
    if not setNet then return end
    pcall(function()
        setNet:FireServer(part, part.CFrame)
        setNet:FireServer(part, part.CFrame)
        setNet:FireServer(part, part.CFrame)
        setNet:FireServer(part, part.CFrame)
        setNet:FireServer(part, part.CFrame)
    end)
end

local function rk_doSticky(targetName)
    if not targetName or targetName == "" then return false end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return false end
    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then return false end
    rk_destroyAllPencils()
    task.wait(0.05)
    local pencil = rk_spawnToolPencil()
    if not pencil then return false end
    local soundPart = pencil:FindFirstChild("SoundPart")
    local stickyPart = pencil:FindFirstChild("StickyPart")
    if soundPart then rk_setNetworkOwnerPencil(soundPart) end
    task.wait(0.05)
    if stickyPart then
        local stickyEvent = ReplicatedStorage:FindFirstChild("PlayerEvents") and ReplicatedStorage.PlayerEvents:FindFirstChild("StickyPartEvent")
        if stickyEvent then
            pcall(function()
                stickyEvent:FireServer(stickyPart, targetHead, CFrame.new(0, 0/0, 0))
                stickyEvent:FireServer(stickyPart, targetHead, CFrame.new(0, 0/0, 0))
            end)
            task.wait(0.5)
            if not rk_isPencilWeldedToTarget(targetName) then
                rk_destroyAllPencils()
                task.wait(0.05)
                return rk_doSticky(targetName)
            end
            return true
        end
    end
    return false
end

local function rk_setNetworkOwner(part)
    if not part then return end
    local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not grabEvents then return end
    local setNet = grabEvents:FindFirstChild("SetNetworkOwner")
    if not setNet then return end
    pcall(function() setNet:FireServer(part, part.CFrame) end)
end

local function rk_destroyGrabLine(part)
    if not part then return end
    local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
    if not grabEvents then return end
    local destroyLine = grabEvents:FindFirstChild("DestroyGrabLine")
    if not destroyLine then return end
    pcall(function() destroyLine:FireServer(part) end)
end

local function rk_destroyBanana(banana)
    if not banana then return end
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    if not menuToys then return end
    local destroyToy = menuToys:FindFirstChild("DestroyToy")
    if not destroyToy then return end
    pcall(function() destroyToy:FireServer(banana) end)
end

local function rk_spawnBanana()
    local hrp = rk_getHumanoidRootPart()
    if not hrp then return nil end
    local spawnPos = hrp.CFrame * CFrame.new(0, 14, 20)
    local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
    if not menuToys then return nil end
    local spawnRemote = menuToys:FindFirstChild("SpawnToyRemoteFunction")
    if not spawnRemote then return nil end
    local spawned = nil
    local folder = rk_getSpawnedToysFolder()
    if not folder then return nil end
    local conn
    conn = folder.ChildAdded:Connect(function(child)
        if child.Name == "FoodBanana" then
            spawned = child
            conn:Disconnect()
        end
    end)
    task.spawn(function()
        pcall(function() spawnRemote:InvokeServer("FoodBanana", spawnPos, Vector3.zero) end)
    end)
    local start = tick()
    repeat task.wait(0.05) until spawned or (tick() - start) > 3
    if conn then pcall(function() conn:Disconnect() end) end
    return spawned
end

local function rk_holdBanana(banana)
    if not banana then return end
    local holdPart = banana:FindFirstChild("HoldPart")
    if not holdPart then return end
    local holdRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
    if not holdRemote then return end
    local char = rk_getLocalChar()
    if not char then return end
    local success = false
    for i = 1, 5 do
        if not banana or not banana.Parent then break end
        local result = pcall(function() return holdRemote:InvokeServer(banana, char) end)
        if result then success = true break end
        task.wait(0.05)
    end
    return success
end

local function rk_useBanana(banana)
    if not banana then return end
    local useEvent = ReplicatedStorage:FindFirstChild("HoldEvents") and ReplicatedStorage.HoldEvents:FindFirstChild("Use")
    if not useEvent then return end
    pcall(function() useEvent:FireServer(banana) end)
end

local function rk_dropBanana(banana)
    if not banana then return end
    local holdPart = banana:FindFirstChild("HoldPart")
    if not holdPart then return end
    local dropRemote = holdPart:FindFirstChild("DropItemRemoteFunction")
    if not dropRemote then return end
    local hrp = rk_getHumanoidRootPart()
    if not hrp then return end
    local dropPos = hrp.CFrame * CFrame.new(0, 15, 0)
    pcall(function() dropRemote:InvokeServer(banana, dropPos, dropPos) end)
end

local function rk_getTargetLeg(targetName)
    if not targetName then return nil end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return nil end
    return target.Character:FindFirstChild("Left Leg")
end

local function rk_getTargetHealth(targetName)
    if not targetName then return 0 end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return 0 end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return 0 end
    return hum.Health
end

local rk_currentBanana = nil
local rk_isTargetDead = false
local rk_loopConnection = nil
local rk_monitorConnection = nil
local rk_loopActive = false
local rk_monitorTask = nil
local rk_respawnConns = {}

local function rk_fullBananaCycle(targetName)
    if not targetName or targetName == "" then return false end
    local banana = rk_spawnBanana()
    if not banana then return false end
    rk_holdBanana(banana)
    task.wait(0.05)
    rk_holdBanana(banana)
    task.wait(0.05)
    task.wait(0.5)
    rk_useBanana(banana)
    task.wait(2.3)
    rk_dropBanana(banana)
    task.wait(0.05)
    rk_dropBanana(banana)
    task.wait(0.3)
    return banana
end

local function rk_restartLoop(banana, targetName)
    if rk_loopConnection then
        rk_loopConnection:Disconnect()
        rk_loopConnection = nil
    end
    rk_currentBanana = banana
    local hitboxPart = banana:FindFirstChild("HitboxPart")
    if not hitboxPart then return end
    rk_loopConnection = RunService.Heartbeat:Connect(function()
        if not rk_loopActive then
            if rk_loopConnection then
                rk_loopConnection:Disconnect()
                rk_loopConnection = nil
            end
            return
        end
        if not rk_currentBanana or not rk_currentBanana.Parent then return end
        local folder = rk_getSpawnedToysFolder()
        local bananaExists = false
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child.Name == "FoodBanana" then
                    bananaExists = true
                    rk_currentBanana = child
                    hitboxPart = child:FindFirstChild("HitboxPart")
                    break
                end
            end
        end
        if not bananaExists or not hitboxPart then
            rk_loopConnection:Disconnect()
            rk_loopConnection = nil
            rk_currentBanana = nil
            return
        end
        local hrp = rk_getHumanoidRootPart()
        if not hrp then return end
        local targetPos
        local targetCFrame
        local health = rk_getTargetHealth(targetName)
        if health <= 0 then
            rk_isTargetDead = true
            targetPos = hrp.CFrame * CFrame.new(0, 7, 0)
            targetCFrame = CFrame.new(targetPos.Position)
        else
            rk_isTargetDead = false
            local leg = rk_getTargetLeg(targetName)
            if leg then
                targetPos = leg.CFrame * CFrame.new(0, 0.5, 0)
                targetCFrame = leg.CFrame
            else
                targetPos = hrp.CFrame * CFrame.new(0, 7, 0)
                targetCFrame = CFrame.new(targetPos.Position)
            end
        end
        rk_setNetworkOwner(hitboxPart)
        rk_destroyGrabLine(hitboxPart)
        local bp = hitboxPart:FindFirstChild("BodyPosition")
        if bp then
            bp.Position = targetPos.Position
        else
            bp = Instance.new("BodyPosition")
            bp.P = 10000
            bp.D = 100
            bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.Position = targetPos.Position
            bp.Parent = hitboxPart
        end
        local bg = hitboxPart:FindFirstChild("BodyGyro")
        if bg then
            bg.CFrame = targetCFrame
        else
            bg = Instance.new("BodyGyro")
            bg.P = 10000
            bg.D = 100
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.CFrame = targetCFrame
            bg.Parent = hitboxPart
        end
    end)
end

local function rk_startBananaLoop(targetName)
    if not targetName or targetName == "" then return end
    rk_isTargetDead = false
    local banana = rk_fullBananaCycle(targetName)
    if banana then
        rk_restartLoop(banana, targetName)
    end
    rk_monitorConnection = RunService.Heartbeat:Connect(function()
        if not rk_loopActive then return end
        local folder = rk_getSpawnedToysFolder()
        local bananaExists = false
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child.Name == "FoodBanana" then
                    bananaExists = true
                    break
                end
            end
        end
        if not bananaExists then
            if rk_loopConnection then
                rk_loopConnection:Disconnect()
                rk_loopConnection = nil
            end
            task.wait(0.05)
            local newBanana = rk_fullBananaCycle(targetName)
            if newBanana then
                rk_restartLoop(newBanana, targetName)
            end
        end
    end)
end

local function rk_RagdollRespawnMonitor(targetName)
    local target = Players:FindFirstChild(targetName)
    if not target then return end
    if rk_respawnConns[target] then return end
    rk_respawnConns[target] = target.CharacterAdded:Connect(function()
        if rk_loopActive then
            task.wait(0.5)
            rk_doSticky(targetName)
        end
    end)
end

local function rk_PencilMonitor()
    while rk_loopActive do
        local count = rk_countPencils()
        if count == 0 then
            rk_doSticky(rk_targetName)
        elseif count >= 2 then
            rk_destroyAllPencils()
            task.wait(0.05)
            rk_doSticky(rk_targetName)
        elseif count == 1 then
            if not rk_isPencilWeldedToTarget(rk_targetName) then
                rk_destroyAllPencils()
                task.wait(0.05)
                rk_doSticky(rk_targetName)
            end
        end
        task.wait(0.1)
    end
end

local function rk_Start()
    if rk_loopActive then return end
    if not rk_targetName then
        Library:Notify("Ragdoll Kill: ターゲットを選択してください", 3)
        return
    end
    rk_loopActive = true
    if rk_mode == "ragdoll" then
        rk_doSticky(rk_targetName)
        rk_RagdollRespawnMonitor(rk_targetName)
        rk_monitorTask = task.spawn(rk_PencilMonitor)
        Library:Notify("Ragdoll Kill (Pencil): Activated ✓", 3)
    elseif rk_mode == "banana" then
        rk_startBananaLoop(rk_targetName)
        Library:Notify("Ragdoll Kill (Banana): Activated ✓", 3)
    end
end

local function rk_Stop()
    if not rk_loopActive then return end
    rk_loopActive = false
    if rk_monitorTask then
        pcall(function() task.cancel(rk_monitorTask) end)
        rk_monitorTask = nil
    end
    if rk_loopConnection then
        rk_loopConnection:Disconnect()
        rk_loopConnection = nil
    end
    if rk_monitorConnection then
        rk_monitorConnection:Disconnect()
        rk_monitorConnection = nil
    end
    for plr, conn in pairs(rk_respawnConns) do
        pcall(function() conn:Disconnect() end)
    end
    rk_respawnConns = {}
    rk_destroyAllPencils()
    if rk_currentBanana then
        rk_destroyBanana(rk_currentBanana)
        local hitboxPart = rk_currentBanana:FindFirstChild("HitboxPart")
        if hitboxPart then
            local bp = hitboxPart:FindFirstChild("BodyPosition")
            if bp then bp:Destroy() end
            local bg = hitboxPart:FindFirstChild("BodyGyro")
            if bg then bg:Destroy() end
        end
        rk_currentBanana = nil
    end
    local folder = rk_getSpawnedToysFolder()
    if folder then
        for _, child in pairs(folder:GetChildren()) do
            if child.Name == "FoodBanana" then
                rk_destroyBanana(child)
            end
        end
    end
    Library:Notify("Ragdoll Kill: Deactivated", 3)
end

_G.RagdollKill = {
    Start = rk_Start,
    Stop = rk_Stop,
    SetTarget = function(name) rk_targetName = name end,
    SetMode = function(mode) rk_mode = mode end,
    IsActive = function() return rk_loopActive end,
}

RagdollGroup:AddDropdown("RagdollKillTargetDropdown", {
    Text = "Select Target",
    Values = rk_GetPlayerList(),
    Default = 1,
    Callback = function(Value)
        local name = Value:match("%(@(.+)%)$")
        rk_targetName = name
        Library:Notify("Ragdoll Kill Target: " .. tostring(name or Value), 2)
    end,
})

RagdollGroup:AddDropdown("RagdollKillModeDropdown", {
    Text = "Mode",
    Values = { "Ragdoll (Pencil)", "Banana" },
    Default = "Ragdoll (Pencil)",
    Callback = function(Value)
        if Value == "Banana" then
            rk_mode = "banana"
        else
            rk_mode = "ragdoll"
        end
        Library:Notify("Ragdoll Kill Mode: " .. rk_mode, 2)
    end,
})

RagdollGroup:AddButton("RagdollKillRefreshBtn", {
    Text = "Refresh Player List",
    Func = function()
        local dropdown = Options.RagdollKillTargetDropdown
        if dropdown then
            pcall(function() dropdown:Refresh(rk_GetPlayerList()) end)
            Library:Notify("Player list refreshed ✓", 2)
        end
    end,
})

RagdollGroup:AddToggle("RagdollKillToggle", {
    Text = "Ragdoll Kill",
    Default = false,
    Callback = function(Value)
        if Value then rk_Start() else rk_Stop() end
    end,
})

local function rk_refreshDropdown()
    task.wait(0.5)
    local dropdown = Options.RagdollKillTargetDropdown
    if dropdown then
        pcall(function() dropdown:Refresh(rk_GetPlayerList()) end)
    end
end

Players.PlayerAdded:Connect(rk_refreshDropdown)
Players.PlayerRemoving:Connect(rk_refreshDropdown)

game:BindToClose(function()
    rk_Stop()
end)

-- =====================================================
-- ★ Server & Kick タブ - Grab Kick
-- =====================================================
local GrabKickGroup = Tabs.ServerKickTab:AddRightGroupbox("Grab Kick", "hand")

local gk_LP = LocalPlayer
local gk_RS = ReplicatedStorage
local gk_RunService = RunService
local gk_Workspace = Workspace
local gk_GrabEvents = gk_RS:WaitForChild("GrabEvents")

local gk_Enabled = false
local gk_TargetName = ""
local gk_DistanceThreshold = 25

local gk_SpawnRemote = gk_RS:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
local gk_SetNetworkOwner = gk_GrabEvents:WaitForChild("SetNetworkOwner")

local gk_State = { Active = false }
local gk_Target = { Name = nil }
local gk_Connections = {}
local gk_PaleteBusy = false

local gk_CreateLineRemote = gk_GrabEvents:FindFirstChild("CreateGrabLine")

local gk_LagRunning = false

local function gk_startLagSpam()
    if gk_LagRunning then return end
    if not gk_CreateLineRemote then return end
    gk_LagRunning = true

    task.spawn(function()
        while gk_LagRunning do
            local spawnLocation = gk_Workspace:FindFirstChild("SpawnLocation")
                or gk_Workspace:FindFirstChild("Spawn")
                or (gk_LP.Character and gk_LP.Character:FindFirstChild("HumanoidRootPart"))

            if spawnLocation then
                pcall(function()
                    gk_CreateLineRemote:FireServer(
                        spawnLocation,
                        CFrame.new(math.random(-2010000000, 2000000001), 0, math.random(-2008100000, 2000200000))
                    )
                end)
            end
            task.wait()
        end
    end)
end

local function gk_stopLagSpam()
    gk_LagRunning = false
end

local function gk_GetPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= gk_LP then
            table.insert(list, plr.DisplayName .. " (@" .. plr.Name .. ")")
        end
    end
    table.sort(list)
    if #list == 0 then list = { "(No Players)" } end
    return list
end

local function gk_FindPlayerByDisplay(displayStr)
    for _, plr in ipairs(Players:GetPlayers()) do
        local key = plr.DisplayName .. " (@" .. plr.Name .. ")"
        if key == displayStr then return plr end
    end
    return nil
end

local function gk_TeleportToTarget(targetPlayer, myRoot)
    if not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end

    local savedCF = myRoot.CFrame
    targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, 2)

    for i = 1, 15 do
        gk_SetNetworkOwner:FireServer(targetRoot, targetRoot.CFrame)
        task.wait()
    end

    myRoot.CFrame = savedCF
end

local function gk_WaitChild(parent, name, timeout)
    return parent:FindFirstChild(name) or parent:WaitForChild(name, timeout or 5)
end

local function gk_SetOwner(part)
    if part and part:IsA("BasePart") then
        pcall(function()
            gk_SetNetworkOwner:FireServer(part, part.CFrame)
        end)
        task.wait()
    end
end

local function gk_HasChild(parent, name)
    return parent:FindFirstChild(name) ~= nil
end

local function gk_SpawnPallet()
    local char = gk_LP.Character or gk_LP.CharacterAdded:Wait()
    local myRoot = char:WaitForChild("HumanoidRootPart")

    local waitCount = 0
    while (gk_LP.InPlot.Value and not gk_LP.InOwnedPlot.Value) and waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end
    waitCount = 0
    while not gk_LP.CanSpawnToy.Value and waitCount < 50 do
        task.wait(0.1)
        waitCount = waitCount + 1
    end

    local spawnPos = myRoot.CFrame * CFrame.new(0, 14, 20)

    local folder = workspace:FindFirstChild(gk_LP.Name .. "SpawnedInToys")
    if not folder then
        folder = workspace:FindFirstChild("PlotItems")
        if folder then
            folder = folder:FindFirstChild("Plot1")
        end
    end
    if not folder then
        folder = workspace
    end

    local spawned = nil
    local conn = folder.ChildAdded:Connect(function(child)
        if child.Name == "PalletLightBrown" then
            spawned = child
        end
    end)

    task.spawn(function()
        pcall(function()
            gk_SpawnRemote:InvokeServer("PalletLightBrown", spawnPos, Vector3.zero)
        end)
    end)

    local start = tick()
    repeat task.wait(0.05) until spawned or (tick() - start) > 5
    conn:Disconnect()
    return spawned
end

local function gk_CreateRagdollPalete()
    if gk_PaleteBusy then return nil end
    gk_PaleteBusy = true

    local pallet = gk_SpawnPallet()
    if not pallet then
        gk_PaleteBusy = false
        return nil
    end

    local soundPart = gk_WaitChild(pallet, "SoundPart", 3)
    if not soundPart then
        pallet:Destroy()
        gk_PaleteBusy = false
        return nil
    end

    local retryCount = 0
    while retryCount < 10 do
        if not gk_State.Active then
            pallet:Destroy()
            gk_PaleteBusy = false
            return nil
        end
        gk_SetOwner(soundPart)
        task.wait()
        if gk_HasChild(soundPart, "PartOwner") then
            break
        end
        retryCount = retryCount + 1
    end

    if not gk_HasChild(soundPart, "PartOwner") then
        pallet:Destroy()
        gk_PaleteBusy = false
        return nil
    end

    for _, desc in pairs(pallet:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.CanCollide = false
            desc.Transparency = 0.8
        end
    end
    pallet.Name = "RagdollPalete"

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 900, 0)
    bv.Parent = soundPart

    gk_PaleteBusy = false
    return pallet
end

local function gk_Enable()
    if gk_Enabled then return end
    gk_Enabled = true
    gk_State.Active = true
    gk_startLagSpam()

    task.spawn(function()
        while gk_Enabled do
            local targetPlayer = gk_FindPlayerByDisplay(gk_TargetName)
            local char = gk_LP.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")

            if targetPlayer and myRoot then
                local targetChar = targetPlayer.Character
                local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

                if targetRoot then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    if dist > gk_DistanceThreshold then
                        gk_TeleportToTarget(targetPlayer, myRoot)
                    end

                    gk_SetNetworkOwner:FireServer(targetRoot, targetRoot.CFrame)
                    if gk_GrabEvents:FindFirstChild("DestroyGrabLine") then
                        gk_GrabEvents.DestroyGrabLine:FireServer(targetRoot)
                    end

                    targetRoot.AssemblyLinearVelocity = Vector3.zero
                    targetRoot.AssemblyAngularVelocity = Vector3.zero

                    local bp = targetRoot:FindFirstChild("ControlBP")
                    if not bp then
                        bp = Instance.new("BodyPosition")
                        bp.Name = "ControlBP"
                        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bp.P = 800000
                        bp.Parent = targetRoot
                    end
                    bp.Position = myRoot.Position + Vector3.new(5, 10, 5)
                end
            end
            task.wait()
        end

        local targetPlayer = gk_FindPlayerByDisplay(gk_TargetName)
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and targetRoot:FindFirstChild("ControlBP") then
                targetRoot.ControlBP:Destroy()
            end
        end
    end)

    local toysFolder = workspace:FindFirstChild(gk_LP.Name .. "SpawnedInToys")
    local currentPallet = nil

    gk_Connections["RenderStepped"] = gk_RunService.RenderStepped:Connect(function()
        if not gk_State.Active then return end
        if not gk_Target.Name then return end

        local targetPlayer = Players:FindFirstChild(gk_Target.Name)
        if not targetPlayer or not targetPlayer.Character then return end

        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = targetPlayer.Character:FindFirstChild("Humanoid")
        if not targetRoot or not targetHum then return end

        if currentPallet and currentPallet:IsDescendantOf(workspace) then
            local soundPart = currentPallet:FindFirstChild("SoundPart")
            if soundPart then
                if not gk_HasChild(soundPart, "PartOwner") then
                    currentPallet:Destroy()
                    currentPallet = nil
                end
            else
                currentPallet:Destroy()
                currentPallet = nil
            end
        end

        if not gk_PaleteBusy and (not currentPallet or not currentPallet:IsDescendantOf(workspace)) then
            currentPallet = toysFolder and toysFolder:FindFirstChild("RagdollPalete") or gk_CreateRagdollPalete()
        end

        if currentPallet and currentPallet:FindFirstChild("SoundPart") then
            local ragdolled = targetHum:FindFirstChild("Ragdolled")
            if ragdolled and not ragdolled.Value then
                currentPallet.SoundPart.Position = targetRoot.Position
            end
        end
    end)
end

local function gk_Disable()
    if not gk_Enabled then return end
    gk_Enabled = false
    gk_State.Active = false
    gk_stopLagSpam()

    if gk_Connections["RenderStepped"] then
        gk_Connections["RenderStepped"]:Disconnect()
        gk_Connections["RenderStepped"] = nil
    end
end

_G.GrabKick = {
    SetTarget = function(name)
        gk_TargetName = name
        local plr = gk_FindPlayerByDisplay(name)
        gk_Target.Name = plr and plr.Name or nil
    end,
    Enable = gk_Enable,
    Disable = gk_Disable,
    GetPlayers = gk_GetPlayerList,
}

Players.PlayerRemoving:Connect(function(plr)
    if plr and gk_Target.Name == plr.Name then
        gk_Target.Name = nil
    end
end)

GrabKickGroup:AddDropdown("GrabKickTargetDropdown", {
    Text = "Select Target",
    Values = gk_GetPlayerList(),
    Default = 1,
    Callback = function(Value)
        local name = Value:match("%(@(.+)%)$")
        gk_TargetName = Value
        local plr = Players:FindFirstChild(name)
        gk_Target.Name = plr and plr.Name or nil
        Library:Notify("Grab Kick Target: " .. tostring(name or Value), 2)
    end,
})

GrabKickGroup:AddButton("GrabKickRefreshBtn", {
    Text = "Refresh Player List",
    Func = function()
        local dropdown = Options.GrabKickTargetDropdown
        if dropdown then
            pcall(function() dropdown:Refresh(gk_GetPlayerList()) end)
            Library:Notify("Player list refreshed ✓", 2)
        end
    end,
})

GrabKickGroup:AddSlider("GrabKickDistanceSlider", {
    Text = "Teleport Distance",
    Default = 25,
    Min = 5,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        gk_DistanceThreshold = Value
    end,
})

GrabKickGroup:AddToggle("GrabKickToggle", {
    Text = "Grab Kick",
    Default = false,
    Callback = function(Value)
        if Value then
            if not gk_Target.Name then
                Library:Notify("Grab Kick: ターゲットを選択してください", 3)
                return
            end
            gk_Enable()
            Library:Notify("Grab Kick: Activated ✓", 3)
        else
            gk_Disable()
            Library:Notify("Grab Kick: Deactivated", 3)
        end
    end,
})

local function gk_refreshDropdown()
    task.wait(0.5)
    local dropdown = Options.GrabKickTargetDropdown
    if dropdown then
        pcall(function() dropdown:Refresh(gk_GetPlayerList()) end)
    end
end

Players.PlayerAdded:Connect(gk_refreshDropdown)
Players.PlayerRemoving:Connect(gk_refreshDropdown)

game:BindToClose(function()
    gk_Disable()
end)

-- =====================================================
-- ★ Palette タブ - Palette Magnet
-- =====================================================
local PaletteGroup = Tabs.PaletteTab:AddLeftGroupbox("Palette Magnet", "magnet")

local pm_LP = LocalPlayer
local pm_RunService = RunService
local pm_Workspace = Workspace

local pm_Sticking = false
local pm_Connection = nil
local pm_CurrentTarget = nil
local pm_OffsetCFrame = CFrame.new()

local function pm_ScanForPallet()
    local char = pm_LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrpPos = char.HumanoidRootPart.Position
    local rayOrigin = hrpPos
    local rayDirection = Vector3.new(0, -15, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = pm_Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result and result.Instance then
        local hit = result.Instance
        if hit.Name:match("Pallet") or (hit.Parent and hit.Parent.Name:match("Pallet")) then
            return hit
        end
    end
    for _, v in pairs(pm_Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:match("Pallet") or (v.Parent and v.Parent.Name:match("Pallet"))) then
            if (v.Position - hrpPos).Magnitude <= 15 then
                return v
            end
        end
    end
    return nil
end

local function pm_StartMagnet()
    local char = pm_LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local target = pm_ScanForPallet()
    if target then
        pm_CurrentTarget = target
        pm_OffsetCFrame = pm_CurrentTarget.CFrame:ToObjectSpace(hrp.CFrame)
        pm_Sticking = true

        pm_Connection = pm_RunService.Heartbeat:Connect(function()
            if pm_Sticking and pm_CurrentTarget and pm_CurrentTarget.Parent and char and char:FindFirstChild("HumanoidRootPart") then
                if not char:FindFirstChild("GrabLine", true) then
                    char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    char.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    char.HumanoidRootPart.CFrame = pm_CurrentTarget.CFrame * pm_OffsetCFrame
                end
            else
                pm_Sticking = false
                if pm_Connection then pm_Connection:Disconnect() pm_Connection = nil end
            end
        end)
    end
end

local function pm_StopMagnet()
    if pm_CurrentTarget and pm_LP.Character and pm_LP.Character:FindFirstChild("HumanoidRootPart") then
        pm_LP.Character.HumanoidRootPart.Velocity = pm_CurrentTarget.Velocity
        pm_LP.Character.HumanoidRootPart.RotVelocity = pm_CurrentTarget.RotVelocity
    end
    pm_Sticking = false
    pm_CurrentTarget = nil
    if pm_Connection then pm_Connection:Disconnect() pm_Connection = nil end
end

local function pm_ToggleMagnet()
    if not pm_Sticking then
        pm_StartMagnet()
    else
        pm_StopMagnet()
    end
end

_G.PaletteMagnet = {
    Start = pm_StartMagnet,
    Stop = pm_StopMagnet,
    Toggle = pm_ToggleMagnet,
    IsActive = function() return pm_Sticking end,
    Scan = pm_ScanForPallet,
}

PaletteGroup:AddToggle("PaletteMagnetToggle", {
    Text = "Palette Magnet",
    Default = false,
    Callback = function(Value)
        if Value then
            pm_StartMagnet()
            if pm_Sticking then
                Library:Notify("Palette Magnet: Activated ✓", 3)
            else
                Library:Notify("Palette Magnet: パレットが見つかりません", 3)
            end
        else
            pm_StopMagnet()
            Library:Notify("Palette Magnet: Deactivated", 3)
        end
    end,
})

game:BindToClose(function()
    pm_StopMagnet()
end)

-- =====================================================
-- ★ Anti Kick タブ
-- =====================================================
local AntiKickGroup = Tabs.AntiKickTab:AddLeftGroupbox("Anti Kick", "shield")
local AntiKickRightGroup = Tabs.AntiKickTab:AddRightGroupbox("Anti Kick Selector", "user")

local ak_MenuToys        = ReplicatedStorage:WaitForChild("MenuToys")
local ak_SpawnRemote     = ak_MenuToys:WaitForChild("SpawnToyRemoteFunction")
local ak_DestroyToy      = ak_MenuToys:WaitForChild("DestroyToy")

local ak_GrabEvents      = ReplicatedStorage:WaitForChild("GrabEvents")
local ak_SetNetworkOwner = ak_GrabEvents:WaitForChild("SetNetworkOwner")

local ak_PlayerEvents    = ReplicatedStorage:FindFirstChild("PlayerEvents")
local ak_StickyPartEvent = ak_PlayerEvents and ak_PlayerEvents:FindFirstChild("StickyPartEvent")

local ak_AntiToyConfig = {
    ["ToolPickaxe"] = {
        Display = "つるはし",
        AttachTo = "Torso",
        Offset = CFrame.new(-0.02, 0.97, 0.67)
               * CFrame.Angles(math.rad(-88.5), math.rad(-0.4), math.rad(-0.4)),
        Rename = nil,
    },
    ["ToolPencil"] = {
        Display = "鉛筆",
        AttachTo = "Torso",
        Offset = CFrame.new(0, -1, 0) * CFrame.Angles(0, math.pi, 0),
        Rename = nil,
    },
    ["NinjaShuriken"] = {
        Display = "手裏剣",
        AttachTo = "FirePlayerPart",
        Offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)),
        Rename = "AntiKick",
    },
    ["NinjaKatana"] = {
        Display = "刀",
        AttachTo = "Torso",
        Offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)),
        Rename = "AntiKick",
    },
    ["ToolCleaver"] = {
        Display = "クリーバー",
        AttachTo = "Torso",
        Offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)),
        Rename = "AntiKick",
    },
    ["ToolDiggingFork"] = {
        Display = "ディギングフォーク",
        AttachTo = "Torso",
        Offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)),
        Rename = "AntiKick",
    },
}

local ak_SelectedToy = "NinjaShuriken"
local ak_AntiKickActive = false
local ak_AntiKickThread = nil
local ak_CurrentToy = nil
local ak_LastSpawnTime = 0local ak_SpawnCooldown = 0.5
local ak_AntiKickBodyPositions = {}
local ak_AntiKickBodyGyros = {}

local function ak_GetLocalChar()
    return LocalPlayer.Character
end

local function ak_GetHumanoidRootPart()
    local char = ak_GetLocalChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function ak_GetSpawnedToysFolder()
    return Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
end

local function ak_ClearBodyMovers()
    for _, bp in ipairs(ak_AntiKickBodyPositions) do
        pcall(function() bp:Destroy() end)
    end
    for _, bg in ipairs(ak_AntiKickBodyGyros) do
        pcall(function() bg:Destroy() end)
    end
    ak_AntiKickBodyPositions = {}
    ak_AntiKickBodyGyros = {}
end

local function ak_DestroyCurrentToy()
    if ak_CurrentToy and ak_CurrentToy.Parent then
        pcall(function() ak_DestroyToy:FireServer(ak_CurrentToy) end)
    end
    ak_CurrentToy = nil
end

local function ak_GetTargetPart()
    local char = ak_GetLocalChar()
    if not char then return nil end
    local config = ak_AntiToyConfig[ak_SelectedToy]
    if not config then return nil end
    local attachName = config.AttachTo
    if attachName == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso")
    elseif attachName == "FirePlayerPart" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local firePart = hrp:FindFirstChild("FirePlayerPart")
            if not firePart then
                firePart = Instance.new("Part")
                firePart.Name = "FirePlayerPart"
                firePart.Size = Vector3.new(1, 1, 1)
                firePart.Transparency = 1
                firePart.CanCollide = false
                firePart.Massless = true
                firePart.Parent = hrp
                local weld = Instance.new("Weld")
                weld.Part0 = hrp
                weld.Part1 = firePart
                weld.C0 = CFrame.new(0, 0, 0)
                weld.Parent = firePart
            end
            return firePart
        end
    end
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function ak_SetNetworkOwner(part)
    if not part then return end
    pcall(function()
        ak_SetNetworkOwner:FireServer(part, part.CFrame)
        ak_SetNetworkOwner:FireServer(part, part.CFrame)
        ak_SetNetworkOwner:FireServer(part, part.CFrame)
    end)
end

local function ak_DestroyGrabLine(part)
    if not part then return end
    local destroyLine = ak_GrabEvents:FindFirstChild("DestroyGrabLine")
    if destroyLine then
        pcall(function() destroyLine:FireServer(part) end)
    end
end

local function ak_ApplyAntiKickToToy(toy)
    if not toy or not toy.Parent then return end
    local config = ak_AntiToyConfig[ak_SelectedToy]
    if not config then return end

    if config.Rename and toy.Name ~= config.Rename then
        pcall(function() toy.Name = config.Rename end)
    end

    local targetPart = ak_GetTargetPart()
    if not targetPart then return end

    for _, desc in ipairs(toy:GetDescendants()) do
        pcall(function()
            if desc:IsA("BasePart") then
                desc.CanCollide = false
                desc.Massless = true
                desc.Anchored = false
                desc.CFrame = targetPart.CFrame * config.Offset
                ak_SetNetworkOwner(desc)
                ak_DestroyGrabLine(desc)

                local bp = desc:FindFirstChild("AntiKickBP")
                if not bp then
                    bp = Instance.new("BodyPosition")
                    bp.Name = "AntiKickBP"
                    bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    bp.P = 100000
                    bp.D = 1000
                    bp.Position = (targetPart.CFrame * config.Offset).Position
                    bp.Parent = desc
                    table.insert(ak_AntiKickBodyPositions, bp)
                else
                    bp.Position = (targetPart.CFrame * config.Offset).Position
                end

                local bg = desc:FindFirstChild("AntiKickBG")
                if not bg then
                    bg = Instance.new("BodyGyro")
                    bg.Name = "AntiKickBG"
                    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                    bg.P = 100000
                    bg.D = 1000
                    bg.CFrame = targetPart.CFrame * config.Offset
                    bg.Parent = desc
                    table.insert(ak_AntiKickBodyGyros, bg)
                else
                    bg.CFrame = targetPart.CFrame * config.Offset
                end
            end
        end)
    end
end

local function ak_SpawnToy()
    local now = tick()
    if now - ak_LastSpawnTime < ak_SpawnCooldown then return end
    ak_LastSpawnTime = now

    local hrp = ak_GetHumanoidRootPart()
    if not hrp then return end
    local spawnPos = hrp.CFrame * CFrame.new(0, 14, 20)

    local spawned = nil
    local folder = ak_GetSpawnedToysFolder()
    if not folder then return end

    local conn
    conn = folder.ChildAdded:Connect(function(child)
        if child.Name == ak_SelectedToy or child.Name == "AntiKick" then
            spawned = child
            conn:Disconnect()
        end
    end)

    task.spawn(function()
        pcall(function() ak_SpawnRemote:InvokeServer(ak_SelectedToy, spawnPos, Vector3.zero) end)
    end)

    local start = tick()
    repeat task.wait(0.05) until spawned or (tick() - start) > 3
    if conn then pcall(function() conn:Disconnect() end) end

    if spawned then
        ak_CurrentToy = spawned
        task.wait(0.1)
        ak_ApplyAntiKickToToy(spawned)
    end
end

local function ak_AntiKickLoop()
    while ak_AntiKickActive do
        local folder = ak_GetSpawnedToysFolder()
        local toyExists = false

        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child.Name == ak_SelectedToy or child.Name == "AntiKick" then
                    toyExists = true
                    ak_CurrentToy = child
                    ak_ApplyAntiKickToToy(child)
                    break
                end
            end
        end

        if not toyExists then
            ak_SpawnToy()
        end

        task.wait(0.1)
    end
end

local function ak_Start()
    if ak_AntiKickActive then return end
    ak_AntiKickActive = true
    ak_AntiKickThread = task.spawn(ak_AntiKickLoop)
    Library:Notify("Anti Kick: Activated ✓", 3)
end

local function ak_Stop()
    if not ak_AntiKickActive then return end
    ak_AntiKickActive = false
    if ak_AntiKickThread then
        pcall(function() task.cancel(ak_AntiKickThread) end)
        ak_AntiKickThread = nil
    end
    ak_ClearBodyMovers()
    ak_DestroyCurrentToy()
    Library:Notify("Anti Kick: Deactivated", 3)
end

_G.AntiKick = {
    Start = ak_Start,
    Stop = ak_Stop,
    SetToy = function(toy) ak_SelectedToy = toy end,
    IsActive = function() return ak_AntiKickActive end,
}

AntiKickGroup:AddToggle("AntiKickToggle", {
    Text = "Anti Kick",
    Default = false,
    Callback = function(Value)
        if Value then ak_Start() else ak_Stop() end
    end,
})

AntiKickRightGroup:AddDropdown("AntiKickToyDropdown", {
    Text = "Select Toy",
    Values = {
        "NinjaShuriken",
        "NinjaKatana",
        "ToolCleaver",
        "ToolDiggingFork",
        "ToolPickaxe",
        "ToolPencil",
    },
    Default = "NinjaShuriken",
    Callback = function(Value)
        ak_SelectedToy = Value
        if ak_AntiKickActive then
            ak_ClearBodyMovers()
            ak_DestroyCurrentToy()
            task.wait(0.1)
            ak_SpawnToy()
        end
        Library:Notify("Anti Kick Toy: " .. Value, 2)
    end,
})

game:BindToClose(function()
    ak_Stop()
end)
