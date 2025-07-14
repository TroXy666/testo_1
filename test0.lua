-- 📦 Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 📦 Глобальные флаги
_G.espBoxEnabled = false
_G.espMurderEnabled = false
_G.espSheriffEnabled = false

-- 📦 Хранилище ESP
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
		for _, box in pairs(espCache[player]) do
			box:Remove()
		end
		espCache[player] = nil
	end
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

-- 📦 GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RoleESP_GUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0.5, -200, 0.5, -110) -- Центр экрана
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

-- 📦 Чекбокс-шаблон
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
	end)
end

-- 📦 Чекбоксы вертикально
createCheckbox("Box ESP",     50, function(v) _G.espBoxEnabled = v end)
createCheckbox("Murder ESP",  80, function(v) _G.espMurderEnabled = v end)
createCheckbox("Sheriff ESP", 110, function(v) _G.espSheriffEnabled = v end)

-- 📝 Текст outline
local outlineText = Instance.new("TextLabel")
outlineText.Size = UDim2.new(1, -20, 0, 20)
outlineText.Position = UDim2.new(0, 20, 0, 150)
outlineText.BackgroundTransparency = 1
outlineText.Text = "outline"
outlineText.Font = Enum.Font.SourceSansBold
outlineText.TextSize = 16
outlineText.TextColor3 = Color3.fromRGB(200, 200, 200)
outlineText.TextXAlignment = Enum.TextXAlignment.Left
outlineText.Parent = frame

-- 📦 Insert key: показать / скрыть меню
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Insert then
		frame.Visible = not frame.Visible
	end
end)

-- 📦 Подключение игроков
for _, p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then addEsp(p) end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then addEsp(p) end
end)

Players.PlayerRemoving:Connect(removeEsp)

-- 📦 Главный цикл
RunService.RenderStepped:Connect(function()
	for player, data in pairs(espCache) do
		if player and player ~= LocalPlayer then
			updateEsp(player, data)
		end
	end
end)
