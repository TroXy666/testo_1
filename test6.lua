-- 📦 Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Флаги
_G.espBoxEnabled = false
_G.espMurderEnabled = false
_G.espSheriffEnabled = false
_G.outlineEspEnabled = false
_G.outlineMurderEnabled = false
_G.outlineSheriffEnabled = false
_G.tracerAllEnabled = false
_G.tracerMurderEnabled = false
_G.tracerSheriffEnabled = false

-- Box ESP
local espCache = {}
local function createBox(color)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Filled = false
    box.Thickness = 2
    box.Color = color
    return box
end

local function getRole(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not (char or backpack) then return "Innocent" end
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and char:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun"))
    if hasKnife then return "Murderer"
    elseif hasGun then return "Sheriff"
    else return "Innocent" end
end

local function addEsp(player)
    if espCache[player] then return end
    espCache[player] = {
        Box = createBox(Color3.fromRGB(255, 255, 255)),
        Murder = createBox(Color3.fromRGB(255, 0, 0)),
        Sheriff = createBox(Color3.fromRGB(0, 150, 255))
    }
end

local function removeEsp(player)
    if espCache[player] then
        for _, box in pairs(espCache[player]) do box:Remove() end
        espCache[player] = nil
    end
    if outlineHighlights[player] then
        outlineHighlights[player]:Destroy()
        outlineHighlights[player] = nil
    end
    if tracerLines.All[player] then tracerLines.All[player]:Remove() tracerLines.All[player] = nil end
    if tracerLines.Murder[player] then tracerLines.Murder[player]:Remove() tracerLines.Murder[player] = nil end
    if tracerLines.Sheriff[player] then tracerLines.Sheriff[player]:Remove() tracerLines.Sheriff[player] = nil end
end

local function updateEsp(player, boxes)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        for _, b in pairs(boxes) do b.Visible = false end
        return
    end
    local pos, visible = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
    if not visible then
        for _, b in pairs(boxes) do b.Visible = false end
        return
    end
    local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
    local width, height = 4 * scale, 5 * scale
    local x, y = pos.X - width / 2, pos.Y - height / 2
    local role = getRole(player)
    boxes.Box.Visible = _G.espBoxEnabled
    boxes.Murder.Visible = _G.espMurderEnabled and role == "Murderer"
    boxes.Sheriff.Visible = _G.espSheriffEnabled and role == "Sheriff"
    if boxes.Box.Visible then
        boxes.Box.Size = Vector2.new(width, height)
        boxes.Box.Position = Vector2.new(x, y)
    end
    if boxes.Murder.Visible then
        boxes.Murder.Size = Vector2.new(width, height)
        boxes.Murder.Position = Vector2.new(x, y)
    end
    if boxes.Sheriff.Visible then
        boxes.Sheriff.Size = Vector2.new(width, height)
        boxes.Sheriff.Position = Vector2.new(x, y)
    end
end

-- Outline ESP (Highlight)
local outlineHighlights = {}
local outlineFolder = CoreGui:FindFirstChild("OutlineESPFolder") or Instance.new("Folder", CoreGui)
outlineFolder.Name = "OutlineESPFolder"
local colorAll = Color3.fromRGB(255, 255, 0)
local colorMurder = Color3.fromRGB(255, 0, 0)
local colorSheriff = Color3.fromRGB(0, 150, 255)

local function addHighlight(player, color)
    if outlineHighlights[player] then
        outlineHighlights[player].Adornee = player.Character
        outlineHighlights[player].OutlineColor = color
        outlineHighlights[player].Enabled = true
        return
    end
    local char = player.Character
    if not char then return end
    local highlight = Instance.new("Highlight", outlineFolder)
    highlight.Adornee = char
    highlight.OutlineColor = color
    highlight.FillTransparency = 1
    highlight.Enabled = true
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outlineHighlights[player] = highlight
end

local function removeHighlight(player)
    if outlineHighlights[player] then
        outlineHighlights[player]:Destroy()
        outlineHighlights[player] = nil
    end
end

local function updateOutlineEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getRole(player)
            if _G.outlineEspEnabled then
                addHighlight(player, colorAll)
            elseif _G.outlineMurderEnabled and role == "Murderer" then
                addHighlight(player, colorMurder)
            elseif _G.outlineSheriffEnabled and role == "Sheriff" then
                addHighlight(player, colorSheriff)
            else
                removeHighlight(player)
            end
        else
            removeHighlight(player)
        end
    end
end

-- Tracer ESP (All, Murder, Sheriff)
local tracerLines = { All = {}, Murder = {}, Sheriff = {} }
local function getTracerLine(t)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 2
    if t == "Murder" then
        l.Color = Color3.fromRGB(255, 0, 0)
    elseif t == "Sheriff" then
        l.Color = Color3.fromRGB(0, 150, 255)
    else
        l.Color = Color3.fromRGB(255,255,255)
    end
    return l
end

local function removeAllTracers()
    for _, t in pairs(tracerLines) do
        for _, line in pairs(t) do if line then line:Remove() end end
        table.clear(t)
    end
end

local function updateTracers()
    -- All
    if _G.tracerAllEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not tracerLines.All[player] then
                    tracerLines.All[player] = getTracerLine("All")
                end
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                    if vis then
                        tracerLines.All[player].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        tracerLines.All[player].To = Vector2.new(pos.X, pos.Y)
                        tracerLines.All[player].Visible = true
                    else
                        tracerLines.All[player].Visible = false
                    end
                else
                    tracerLines.All[player].Visible = false
                end
            elseif tracerLines.All[player] then
                tracerLines.All[player].Visible = false
            end
        end
    else
        for _, line in pairs(tracerLines.All) do if line then line.Visible = false end end
    end
    -- Murder
    if _G.tracerMurderEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if getRole(player) == "Murderer" then
                    if not tracerLines.Murder[player] then
                        tracerLines.Murder[player] = getTracerLine("Murder")
                    end
                    local char = player.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                        if vis then
                            tracerLines.Murder[player].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            tracerLines.Murder[player].To = Vector2.new(pos.X, pos.Y)
                            tracerLines.Murder[player].Visible = true
                        else
                            tracerLines.Murder[player].Visible = false
                        end
                    else
                        tracerLines.Murder[player].Visible = false
                    end
                else
                    if tracerLines.Murder[player] then tracerLines.Murder[player].Visible = false end
                end
            elseif tracerLines.Murder[player] then
                tracerLines.Murder[player].Visible = false
            end
        end
    else
        for _, line in pairs(tracerLines.Murder) do if line then line.Visible = false end end
    end
    -- Sheriff
    if _G.tracerSheriffEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if getRole(player) == "Sheriff" then
                    if not tracerLines.Sheriff[player] then
                        tracerLines.Sheriff[player] = getTracerLine("Sheriff")
                    end
                    local char = player.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
                        if vis then
                            tracerLines.Sheriff[player].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            tracerLines.Sheriff[player].To = Vector2.new(pos.X, pos.Y)
                            tracerLines.Sheriff[player].Visible = true
                        else
                            tracerLines.Sheriff[player].Visible = false
                        end
                    else
                        tracerLines.Sheriff[player].Visible = false
                    end
                else
                    if tracerLines.Sheriff[player] then tracerLines.Sheriff[player].Visible = false end
                end
            elseif tracerLines.Sheriff[player] then
                tracerLines.Sheriff[player].Visible = false
            end
        end
    else
        for _, line in pairs(tracerLines.Sheriff) do if line then line.Visible = false end end
    end
end

-- 📦 GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "RoleESP_GUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 430)
frame.Position = UDim2.new(0.5, -200, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.Text = "ROLE ESP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.BorderSizePixel = 0

local function createCheckbox(labelText, offsetY, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 180, 0, 22)
    toggleFrame.Position = UDim2.new(0, 20, 0, offsetY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = frame
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BorderColor3 = Color3.fromRGB(120, 120, 120)
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = toggleFrame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, 0)
    label.Position = UDim2.new(0, 22, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✔"
    check.TextColor3 = Color3.fromRGB(0, 170, 255)
    check.TextSize = 16
    check.Font = Enum.Font.SourceSansBold
    check.Visible = false
    check.Parent = box
    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        callback(state)
        updateOutlineEsp()
    end)
end

createCheckbox("Box ESP",     50, function(v) _G.espBoxEnabled = v end)
createCheckbox("Murder ESP",  80, function(v) _G.espMurderEnabled = v end)
createCheckbox("Sheriff ESP", 110, function(v) _G.espSheriffEnabled = v end)

local outlineText = Instance.new("TextLabel")
outlineText.Size = UDim2.new(1, -20, 0, 22)
outlineText.Position = UDim2.new(0, 20, 0, 155)
outlineText.BackgroundTransparency = 1
outlineText.Text = "outline"
outlineText.Font = Enum.Font.SourceSansBold
outlineText.TextSize = 16
outlineText.TextColor3 = Color3.fromRGB(200, 200, 200)
outlineText.TextXAlignment = Enum.TextXAlignment.Left
outlineText.Parent = frame

createCheckbox("Outline ESP",     180, function(v) _G.outlineEspEnabled = v; updateOutlineEsp() end)
createCheckbox("Outline Murder",  210, function(v) _G.outlineMurderEnabled = v; updateOutlineEsp() end)
createCheckbox("Outline Sheriff", 240, function(v) _G.outlineSheriffEnabled = v; updateOutlineEsp() end)

-- Tracer раздел
local tracerLabel = Instance.new("TextLabel")
tracerLabel.Size = UDim2.new(1, -20, 0, 22)
tracerLabel.Position = UDim2.new(0, 20, 0, 285)
tracerLabel.BackgroundTransparency = 1
tracerLabel.Text = "tracer"
tracerLabel.Font = Enum.Font.SourceSansBold
tracerLabel.TextSize = 16
tracerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tracerLabel.TextXAlignment = Enum.TextXAlignment.Left
tracerLabel.Parent = frame

local function createTracerCheckbox(labelText, offsetY, flagName)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 180, 0, 22)
    toggleFrame.Position = UDim2.new(0, 20, 0, offsetY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = frame

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.BorderColor3 = Color3.fromRGB(120, 120, 120)
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, 0)
    label.Position = UDim2.new(0, 22, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✔"
    check.TextColor3 = Color3.fromRGB(0, 170, 255)
    check.TextSize = 16
    check.Font = Enum.Font.SourceSansBold
    check.Visible = false
    check.Parent = box

    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        _G[flagName] = state
        if not (_G.tracerAllEnabled or _G.tracerMurderEnabled or _G.tracerSheriffEnabled) then
            removeAllTracers()
        end
    end)
end

createTracerCheckbox("Tracer Murder", 310, "tracerMurderEnabled")
createTracerCheckbox("Tracer Sheriff", 340, "tracerSheriffEnabled")
createTracerCheckbox("Tracer All", 370, "tracerAllEnabled")

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then addEsp(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then addEsp(p) end
end)
Players.PlayerRemoving:Connect(removeEsp)
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function() wait(0.1) updateOutlineEsp() end)
end
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() wait(0.1) updateOutlineEsp() end)
end)

Players.PlayerRemoving:Connect(function(player)
    if tracerLines.All[player] then tracerLines.All[player]:Remove() tracerLines.All[player] = nil end
    if tracerLines.Murder[player] then tracerLines.Murder[player]:Remove() tracerLines.Murder[player] = nil end
    if tracerLines.Sheriff[player] then tracerLines.Sheriff[player]:Remove() tracerLines.Sheriff[player] = nil end
end)

RunService.RenderStepped:Connect(function()
    for player, data in pairs(espCache) do
        if player and player ~= LocalPlayer then
            updateEsp(player, data)
        end
    end
    updateOutlineEsp()
    updateTracers()
end)
