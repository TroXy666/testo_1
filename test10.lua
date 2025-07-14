-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Флаги и кэш
local currentTab = "ESP"
_G.espBoxEnabled = false
_G.espMurderEnabled = false
_G.espSheriffEnabled = false
_G.outlineEspEnabled = false
_G.outlineMurderEnabled = false
_G.outlineSheriffEnabled = false
_G.tracerAllEnabled = false
_G.tracerMurderEnabled = false
_G.tracerSheriffEnabled = false
_G.otherNameEnabled = false
_G.otherDistanceEnabled = false
_G.otherPingEnabled = false
_G.otherSkeletonEnabled = false
_G.otherRoleEnabled = false

-- ESP Box
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
    if billboards[player] then billboards[player]:Destroy() billboards[player] = nil end
    if skeletonLines[player] then for _, l in pairs(skeletonLines[player]) do l:Remove() end skeletonLines[player] = nil end
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

-- Outline ESP
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

-- Tracer ESP
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

-- Other: Name, Distance, Ping, Role (BillboardGui) + Skeleton (Drawing)
local billboards = {}
local skeletonJoints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local skeletonLines = {}

local function updateBillboards()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            if billboards[player] then
                billboards[player]:Destroy()
                billboards[player] = nil
            end
            continue
        end

        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if head and (_G.otherNameEnabled or _G.otherDistanceEnabled or _G.otherPingEnabled or _G.otherRoleEnabled) then
            if not billboards[player] then
                local gui = Instance.new("BillboardGui")
                gui.AlwaysOnTop = true
                gui.Size = UDim2.new(5,0,1,0)
                gui.StudsOffset = Vector3.new(0, 3, 0)
                gui.Adornee = head

                local label = Instance.new("TextLabel", gui)
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextStrokeTransparency = 0.5
                label.Font = Enum.Font.SourceSansBold
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.TextScaled = true
                billboards[player] = gui
                gui.Parent = CoreGui
            end

            local textTable = {}

            if _G.otherNameEnabled then
                table.insert(textTable, player.DisplayName or player.Name)
            end
            if _G.otherDistanceEnabled then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    table.insert(textTable, ("%.0f studs"):format(dist))
                end
            end
            if _G.otherPingEnabled then
                local ping = "?"
                pcall(function()
                    ping = math.floor(tonumber(LocalPlayer:GetNetworkPing() * 1000)) .. " ms"
                end)
                table.insert(textTable, ping)
            end
            if _G.otherRoleEnabled then
                table.insert(textTable, getRole(player))
            end

            billboards[player].TextLabel.Text = table.concat(textTable, " | ")
            billboards[player].Adornee = head
            billboards[player].Enabled = true
        else
            if billboards[player] then
                billboards[player].Enabled = false
            end
        end
    end
end

local function updateSkeletons()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            if skeletonLines[player] then
                for _, l in pairs(skeletonLines[player]) do l:Remove() end
                skeletonLines[player] = nil
            end
            continue
        end
        if not _G.otherSkeletonEnabled then
            if skeletonLines[player] then
                for _, l in pairs(skeletonLines[player]) do l.Visible = false end
            end
            continue
        end

        local char = player.Character
        if not char then
            if skeletonLines[player] then
                for _, l in pairs(skeletonLines[player]) do l.Visible = false end
            end
            continue
        end
        if not skeletonLines[player] then
            skeletonLines[player] = {}
            for _ = 1, #skeletonJoints do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = Color3.fromRGB(0, 255, 0)
                line.Thickness = 2
                table.insert(skeletonLines[player], line)
            end
        end
        for i, joint in ipairs(skeletonJoints) do
            local a = char:FindFirstChild(joint[1])
            local b = char:FindFirstChild(joint[2])
            if a and b then
                local a2, aok = Camera:WorldToViewportPoint(a.Position)
                local b2, bok = Camera:WorldToViewportPoint(b.Position)
                if aok and bok then
                    local l = skeletonLines[player][i]
                    l.From = Vector2.new(a2.X, a2.Y)
                    l.To = Vector2.new(b2.X, b2.Y)
                    l.Visible = true
                else
                    skeletonLines[player][i].Visible = false
                end
            else
                skeletonLines[player][i].Visible = false
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if billboards[player] then billboards[player]:Destroy() billboards[player] = nil end
    if skeletonLines[player] then for _, l in pairs(skeletonLines[player]) do l:Remove() end skeletonLines[player] = nil end
end)

-- ========== GUI С ВКЛАДКАМИ ==========
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "RoleESP_GUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 400)
frame.Position = UDim2.new(0.5, -200, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Вкладки
local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1, 0, 0, 36)
tabFrame.Position = UDim2.new(0, 0, 0, 0)
tabFrame.BackgroundTransparency = 1
tabFrame.BorderSizePixel = 0

local tabEsp = Instance.new("TextButton", tabFrame)
tabEsp.Size = UDim2.new(0, 80, 1, 0)
tabEsp.Position = UDim2.new(0, 10, 0, 0)
tabEsp.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
tabEsp.TextColor3 = Color3.fromRGB(255,255,255)
tabEsp.Font = Enum.Font.SourceSansBold
tabEsp.Text = "ESP"
tabEsp.TextSize = 18
tabEsp.BorderSizePixel = 0

local tabChams = Instance.new("TextButton", tabFrame)
tabChams.Size = UDim2.new(0, 100, 1, 0)
tabChams.Position = UDim2.new(0, 110, 0, 0)
tabChams.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tabChams.TextColor3 = Color3.fromRGB(255,255,255)
tabChams.Font = Enum.Font.SourceSansBold
tabChams.Text = "CHAMS"
tabChams.TextSize = 18
tabChams.BorderSizePixel = 0

-- ScrollingFrames
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -36)
scroll.Position = UDim2.new(0, 0, 0, 36)
scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
scroll.ScrollBarThickness = 8
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Visible = true

local chamsScroll = Instance.new("ScrollingFrame", frame)
chamsScroll.Size = UDim2.new(1, 0, 1, -36)
chamsScroll.Position = UDim2.new(0, 0, 0, 36)
chamsScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
chamsScroll.ScrollBarThickness = 8
chamsScroll.BackgroundTransparency = 1
chamsScroll.BorderSizePixel = 0
chamsScroll.Visible = false

-- Обработка вкладок
local function setTab(tabName)
    currentTab = tabName
    if tabName == "ESP" then
        scroll.Visible = true
        chamsScroll.Visible = false
        tabEsp.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
        tabChams.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    else
        scroll.Visible = false
        chamsScroll.Visible = true
        tabEsp.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        tabChams.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
    end
end

tabEsp.MouseButton1Click:Connect(function() setTab("ESP") end)
tabChams.MouseButton1Click:Connect(function() setTab("CHAMS") end)

-- Чекбоксы в ESP
local offset = 10
local function createCheckbox(labelText, offsetY, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 180, 0, 22)
    toggleFrame.Position = UDim2.new(0, 20, 0, offsetY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = scroll
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
    offset = offset + 30
end

createCheckbox("Box ESP",     offset, function(v) _G.espBoxEnabled = v end)
createCheckbox("Murder ESP",  offset, function(v) _G.espMurderEnabled = v end)
createCheckbox("Sheriff ESP", offset, function(v) _G.espSheriffEnabled = v end)
offset = offset + 10

local outlineText = Instance.new("TextLabel")
outlineText.Size = UDim2.new(1, -20, 0, 22)
outlineText.Position = UDim2.new(0, 20, 0, offset)
outlineText.BackgroundTransparency = 1
outlineText.Text = "outline"
outlineText.Font = Enum.Font.SourceSansBold
outlineText.TextSize = 16
outlineText.TextColor3 = Color3.fromRGB(200, 200, 200)
outlineText.TextXAlignment = Enum.TextXAlignment.Left
outlineText.Parent = scroll
offset = offset + 30

createCheckbox("Outline ESP",     offset, function(v) _G.outlineEspEnabled = v; updateOutlineEsp() end)
createCheckbox("Outline Murder",  offset, function(v) _G.outlineMurderEnabled = v; updateOutlineEsp() end)
createCheckbox("Outline Sheriff", offset, function(v) _G.outlineSheriffEnabled = v; updateOutlineEsp() end)
offset = offset + 10

local tracerLabel = Instance.new("TextLabel")
tracerLabel.Size = UDim2.new(1, -20, 0, 22)
tracerLabel.Position = UDim2.new(0, 20, 0, offset)
tracerLabel.BackgroundTransparency = 1
tracerLabel.Text = "tracer"
tracerLabel.Font = Enum.Font.SourceSansBold
tracerLabel.TextSize = 16
tracerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tracerLabel.TextXAlignment = Enum.TextXAlignment.Left
tracerLabel.Parent = scroll
offset = offset + 30

createCheckbox("Tracer Murder",  offset, function(v) _G.tracerMurderEnabled = v end)
createCheckbox("Tracer Sheriff", offset, function(v) _G.tracerSheriffEnabled = v end)
createCheckbox("Tracer All",     offset, function(v) _G.tracerAllEnabled = v end)
offset = offset + 10

local otherLabel = Instance.new("TextLabel")
otherLabel.Size = UDim2.new(1, -20, 0, 22)
otherLabel.Position = UDim2.new(0, 20, 0, offset)
otherLabel.BackgroundTransparency = 1
otherLabel.Text = "other"
otherLabel.Font = Enum.Font.SourceSansBold
otherLabel.TextSize = 16
otherLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
otherLabel.TextXAlignment = Enum.TextXAlignment.Left
otherLabel.Parent = scroll
offset = offset + 30

createCheckbox("Name",     offset, function(v) _G.otherNameEnabled = v end)
createCheckbox("Distance", offset, function(v) _G.otherDistanceEnabled = v end)
createCheckbox("Ping",     offset, function(v) _G.otherPingEnabled = v end)
createCheckbox("Skeleton", offset, function(v) _G.otherSkeletonEnabled = v end)
createCheckbox("Role",     offset, function(v) _G.otherRoleEnabled = v end)

-- CHAMS TAB (пока только кнопки)
local function createChamsButton(labelText, offsetY)
    local btn = Instance.new("TextButton", chamsScroll)
    btn.Size = UDim2.new(0, 160, 0, 32)
    btn.Position = UDim2.new(0, 30, 0, offsetY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 120, 160)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    -- btn.MouseButton1Click:Connect(function() ... end) -- здесь потом сделаешь функцию chams
end
createChamsButton("chams all", 30)
createChamsButton("chams murder", 72)
createChamsButton("chams sheriff", 114)

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
    if billboards[player] then billboards[player]:Destroy() billboards[player] = nil end
    if skeletonLines[player] then for _, l in pairs(skeletonLines[player]) do l:Remove() end skeletonLines[player] = nil end
end)

RunService.RenderStepped:Connect(function()
    for player, data in pairs(espCache) do
        if player and player ~= LocalPlayer then
            updateEsp(player, data)
        end
    end
    updateOutlineEsp()
    updateTracers()
    updateBillboards()
    updateSkeletons()
end)
