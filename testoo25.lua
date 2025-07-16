-- Глобальные состояния (оставь в начале)
_G.espBoxEnabled = false
_G.espGunEnabled = false
_G.espMurderEnabled = false
_G.espSheriffEnabled = false
_G.outlineEspEnabled = false
_G.outlineGunEnabled = false
_G.outlineMurderEnabled = false
_G.outlineSheriffEnabled = false
_G.tracerAllEnabled = false
_G.tracerGunEnabled = false
_G.tracerMurderEnabled = false
_G.tracerSheriffEnabled = false
_G.otherNameEnabled = false
_G.otherDistanceEnabled = false
_G.otherDistanceGunEnabled = false
_G.otherPingEnabled = false
_G.otherSkeletonEnabled = false
_G.otherRoleEnabled = false
_G.chamsAllEnabled = false
_G.chamsMurderEnabled = false
_G.chamsSheriffEnabled = false

-- ЧЕКБОКСЫ
local function createCheckbox(labelText, offsetY, globalVarName, parent)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 220, 0, 26)
    toggleFrame.Position = UDim2.new(0, 24, 0, offsetY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 22, 0, 22)
    box.Position = UDim2.new(0, 0, 0, 2)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.BorderColor3 = Color3.fromRGB(120, 120, 120)
    box.BorderSizePixel = 1
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = toggleFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -28, 1, 0)
    label.Position = UDim2.new(0, 28, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = "✔"
    check.TextColor3 = Color3.fromRGB(0, 170, 255)
    check.TextSize = 18
    check.Font = Enum.Font.SourceSansBold
    check.Visible = _G[globalVarName]
    check.Parent = box

    -- при запуске
    if _G[globalVarName] then
        check.Visible = true
    end

    box.MouseButton1Click:Connect(function()
        _G[globalVarName] = not _G[globalVarName]
        check.Visible = _G[globalVarName]
    end)
end

-- Пример создания всех чекбоксов ESP (раздел scroll):
local offset = 10
createCheckbox("Box Gun", offset, "espGunEnabled", scroll)
offset = offset + 34
createCheckbox("Tracer Gun", offset, "tracerGunEnabled", scroll)
offset = offset + 34
createCheckbox("Outline Gun", offset, "outlineGunEnabled", scroll)
offset = offset + 34
createCheckbox("Distance Gun", offset, "otherDistanceGunEnabled", scroll)
offset = offset + 34
createCheckbox("Box ESP", offset, "espBoxEnabled", scroll)
offset = offset + 34
createCheckbox("Murder ESP", offset, "espMurderEnabled", scroll)
offset = offset + 34
createCheckbox("Sheriff ESP", offset, "espSheriffEnabled", scroll)
offset = offset + 34
createCheckbox("Role", offset, "otherRoleEnabled", scroll)

-- ====== CHAMS CHECKBOXES ======
local chamsOffset = 10
createCheckbox("Chams all", chamsOffset, "chamsAllEnabled", chamsScroll)
chamsOffset = chamsOffset + 34
createCheckbox("Chams murder", chamsOffset, "chamsMurderEnabled", chamsScroll)
chamsOffset = chamsOffset + 34
createCheckbox("Chams sheriff", chamsOffset, "chamsSheriffEnabled", chamsScroll)


UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

-- ========================== ФУНКЦИИ ESP ==========================
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

-- ===== GUN ESP (Drawing + Highlight + Billboard) =====
local gunBox = Drawing.new("Square")
gunBox.Visible = false
gunBox.Filled = false
gunBox.Thickness = 2
gunBox.Color = Color3.fromRGB(30, 144, 255)

local gunTracer = Drawing.new("Line")
gunTracer.Visible = false
gunTracer.Thickness = 2
gunTracer.Color = Color3.fromRGB(30, 144, 255)

local gunHighlight = nil
local gunBillboard = nil

local function getGunPart()
    local w = workspace:FindFirstChild("Workplace")
    if w and w:FindFirstChild("GunDrop") then
        return w.GunDrop
    end
    return nil
end

-- ===== RenderStepped =====
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

    -- ==== GUN ESP ====
    local gun = getGunPart()
    -- Box Gun
    if gun and _G.espGunEnabled then
        local pos, vis = Camera:WorldToViewportPoint(gun.Position)
        if vis then
            local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 800
            local w, h = 2.5 * scale, 1.5 * scale
            gunBox.Size = Vector2.new(w, h)
            gunBox.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
            gunBox.Visible = true
        else
            gunBox.Visible = false
        end
    else
        gunBox.Visible = false
    end

    -- Tracer Gun
    if gun and _G.tracerGunEnabled then
        local pos, vis = Camera:WorldToViewportPoint(gun.Position)
        if vis then
            gunTracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            gunTracer.To = Vector2.new(pos.X, pos.Y)
            gunTracer.Visible = true
        else
            gunTracer.Visible = false
        end
    else
        gunTracer.Visible = false
    end

    -- Outline Gun
    if gun and _G.outlineGunEnabled then
        if not gunHighlight then
            gunHighlight = Instance.new("Highlight", CoreGui)
            gunHighlight.Adornee = gun
            gunHighlight.OutlineColor = Color3.fromRGB(30,144,255)
            gunHighlight.FillTransparency = 1
            gunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            gunHighlight.Enabled = true
        elseif gunHighlight.Adornee ~= gun then
            gunHighlight.Adornee = gun
            gunHighlight.OutlineColor = Color3.fromRGB(30,144,255)
            gunHighlight.Enabled = true
        else
            gunHighlight.Enabled = true
        end
    else
        if gunHighlight then gunHighlight.Enabled = false end
    end

    -- Distance Gun (Billboard)
    if gun and _G.otherDistanceGunEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not gunBillboard then
            gunBillboard = Instance.new("BillboardGui", CoreGui)
            gunBillboard.Size = UDim2.new(4, 0, 1, 0)
            gunBillboard.StudsOffset = Vector3.new(0, 1.6, 0)
            gunBillboard.AlwaysOnTop = true
            gunBillboard.Adornee = gun
            local tl = Instance.new("TextLabel", gunBillboard)
            tl.Name = "Label"
            tl.Size = UDim2.new(1,0,1,0)
            tl.BackgroundTransparency = 1
            tl.TextStrokeTransparency = 0.5
            tl.Font = Enum.Font.SourceSansBold
            tl.TextColor3 = Color3.fromRGB(30,144,255)
            tl.TextScaled = true
        end
        local dist = (root.Position - gun.Position).Magnitude
        gunBillboard.Label.Text = ("Gun: %.0f studs"):format(dist)
        gunBillboard.Adornee = gun
        gunBillboard.Enabled = true
    else
        if gunBillboard then gunBillboard.Enabled = false end
    end
end)

print("hello world")
