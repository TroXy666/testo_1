-- Сервисы и переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Глобальные состояния
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

-- ===== GUI =====
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "RoleESP_GUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 440)
frame.Position = UDim2.new(0.5, -160, 0.5, -220)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local menuTitle = Instance.new("TextLabel", frame)
menuTitle.Size = UDim2.new(1, 0, 0, 40)
menuTitle.Position = UDim2.new(0, 0, 0, 0)
menuTitle.BackgroundTransparency = 1
menuTitle.Text = "menu"
menuTitle.TextColor3 = Color3.new(1, 1, 1)
menuTitle.Font = Enum.Font.SourceSansBold
menuTitle.TextSize = 32
menuTitle.TextXAlignment = Enum.TextXAlignment.Center

local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1, 0, 0, 34)
tabFrame.Position = UDim2.new(0, 0, 0, 40)
tabFrame.BackgroundTransparency = 1
tabFrame.BorderSizePixel = 0

local tabEsp = Instance.new("TextButton", tabFrame)
tabEsp.Size = UDim2.new(0, 70, 1, 0)
tabEsp.Position = UDim2.new(0, 15, 0, 0)
tabEsp.BackgroundColor3 = Color3.fromRGB(30, 120, 255)
tabEsp.TextColor3 = Color3.fromRGB(255,255,255)
tabEsp.Font = Enum.Font.SourceSansBold
tabEsp.Text = "ESP"
tabEsp.TextSize = 20
tabEsp.BorderSizePixel = 0

local tabChams = Instance.new("TextButton", tabFrame)
tabChams.Size = UDim2.new(0, 90, 1, 0)
tabChams.Position = UDim2.new(0, 100, 0, 0)
tabChams.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tabChams.TextColor3 = Color3.fromRGB(255,255,255)
tabChams.Font = Enum.Font.SourceSansBold
tabChams.Text = "CHAMS"
tabChams.TextSize = 20
tabChams.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -74)
scroll.Position = UDim2.new(0, 0, 0, 74)
scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
scroll.ScrollBarThickness = 8
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Visible = true

local chamsScroll = Instance.new("ScrollingFrame", frame)
chamsScroll.Size = UDim2.new(1, 0, 1, -74)
chamsScroll.Position = UDim2.new(0, 0, 0, 74)
chamsScroll.CanvasSize = UDim2.new(0, 0, 0, 200)
chamsScroll.ScrollBarThickness = 8
chamsScroll.BackgroundTransparency = 1
chamsScroll.BorderSizePixel = 0
chamsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
chamsScroll.Visible = false

local function setTab(tabName)
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

local function createCheckbox(labelText, offsetY, callback, parent)
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
    check.Visible = false
    check.Parent = box

    local state = false
    box.MouseButton1Click:Connect(function()
        state = not state
        check.Visible = state
        if callback then callback(state) end
    end)
end

-- Чекбоксы (с Gun)
local offset = 10
createCheckbox("Box ESP", offset, function(v) _G.espBoxEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Box Gun", offset, function(v) _G.espGunEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Murder ESP", offset, function(v) _G.espMurderEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Sheriff ESP", offset, function(v) _G.espSheriffEnabled = v end, scroll)
offset = offset + 40

local outlineText = Instance.new("TextLabel", scroll)
outlineText.Size = UDim2.new(1, -20, 0, 26)
outlineText.Position = UDim2.new(0, 24, 0, offset)
outlineText.BackgroundTransparency = 1
outlineText.Text = "outline"
outlineText.Font = Enum.Font.SourceSansBold
outlineText.TextSize = 18
outlineText.TextColor3 = Color3.fromRGB(200, 200, 200)
outlineText.TextXAlignment = Enum.TextXAlignment.Left
offset = offset + 32

createCheckbox("Outline ESP", offset, function(v) _G.outlineEspEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Outline Gun", offset, function(v) _G.outlineGunEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Outline Murder", offset, function(v) _G.outlineMurderEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Outline Sheriff", offset, function(v) _G.outlineSheriffEnabled = v end, scroll)
offset = offset + 40

local tracerLabel = Instance.new("TextLabel", scroll)
tracerLabel.Size = UDim2.new(1, -20, 0, 26)
tracerLabel.Position = UDim2.new(0, 24, 0, offset)
tracerLabel.BackgroundTransparency = 1
tracerLabel.Text = "tracer"
tracerLabel.Font = Enum.Font.SourceSansBold
tracerLabel.TextSize = 18
tracerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
tracerLabel.TextXAlignment = Enum.TextXAlignment.Left
offset = offset + 32

createCheckbox("Tracer Murder", offset, function(v) _G.tracerMurderEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Tracer Sheriff", offset, function(v) _G.tracerSheriffEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Tracer Gun", offset, function(v) _G.tracerGunEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Tracer All", offset, function(v) _G.tracerAllEnabled = v end, scroll)
offset = offset + 40

local otherLabel = Instance.new("TextLabel", scroll)
otherLabel.Size = UDim2.new(1, -20, 0, 26)
otherLabel.Position = UDim2.new(0, 24, 0, offset)
otherLabel.BackgroundTransparency = 1
otherLabel.Text = "other"
otherLabel.Font = Enum.Font.SourceSansBold
otherLabel.TextSize = 18
otherLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
otherLabel.TextXAlignment = Enum.TextXAlignment.Left
offset = offset + 32

createCheckbox("Name", offset, function(v) _G.otherNameEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Distance", offset, function(v) _G.otherDistanceEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Distance Gun", offset, function(v) _G.otherDistanceGunEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Ping", offset, function(v) _G.otherPingEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Skeleton", offset, function(v) _G.otherSkeletonEnabled = v end, scroll)
offset = offset + 34
createCheckbox("Role", offset, function(v) _G.otherRoleEnabled = v end, scroll)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

-- ========== GUN ESP по пути game:GetService("Workspace").Workplace.GunDrop ==========
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

RunService.RenderStepped:Connect(function()
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

    -- Outline Gun (Highlight)
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
