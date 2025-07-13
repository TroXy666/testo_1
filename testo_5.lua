-- 📦 Настройки
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 📦 Состояния
local espCache = {}
local showAllESP = false
local showMurdererESP = false
local showSheriffESP = false

-- 📦 GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RoleESP_GUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.Text = "ROLE ESP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

-- 🔘 Кнопка All
local allBtn = Instance.new("TextButton", frame)
allBtn.Size = UDim2.new(0, 160, 0, 40)
allBtn.Position = UDim2.new(0, 20, 0, 60)
allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
allBtn.Text = "Box ESP: OFF"
allBtn.TextColor3 = Color3.new(1, 1, 1)
allBtn.Font = Enum.Font.SourceSans
allBtn.TextSize = 18

-- 🔪 Murderer
local murderBtn = Instance.new("TextButton", frame)
murderBtn.Size = UDim2.new(0, 160, 0, 40)
murderBtn.Position = UDim2.new(0, 20, 0, 110)
murderBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
murderBtn.Text = "Murderer ESP: OFF"
murderBtn.TextColor3 = Color3.new(1, 1, 1)
murderBtn.Font = Enum.Font.SourceSans
murderBtn.TextSize = 18

-- 🔫 Sheriff
local sheriffBtn = Instance.new("TextButton", frame)
sheriffBtn.Size = UDim2.new(0, 160, 0, 40)
sheriffBtn.Position = UDim2.new(0, 20, 0, 160)
sheriffBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 60)
sheriffBtn.Text = "Sheriff ESP: OFF"
sheriffBtn.TextColor3 = Color3.new(1, 1, 1)
sheriffBtn.Font = Enum.Font.SourceSans
sheriffBtn.TextSize = 18

-- 📦 Создание боксов
local function createBox(color)
	local box = Drawing.new("Square")
	box.Visible = false
	box.Filled = false
	box.Thickness = 2
	box.Color = color
	return box
end

-- 📦 Определение роли
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

-- 📦 Добавление ESP
local function addEsp(player)
	if espCache[player] then return end
	espCache[player] = {
		AllBox = createBox(Color3.fromRGB(255, 255, 255)),
		MurderBox = createBox(Color3.fromRGB(255, 0, 0)),
		SheriffBox = createBox(Color3.fromRGB(0, 150, 255))
	}
end

-- 📦 Удаление ESP
local function removeEsp(player)
	if espCache[player] then
		for _, box in pairs(espCache[player]) do
			box:Remove()
		end
		espCache[player] = nil
	end
end

-- 📦 Отрисовка
local function updateEsp(player, data)
	local char = player.Character
	if not char then
		for _, b in pairs(data) do b.Visible = false end
		return
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		for _, b in pairs(data) do b.Visible = false end
		return
	end

	local pos, visible = Camera:WorldToViewportPoint(hrp.Position)
	if not visible then
		for _, b in pairs(data) do b.Visible = false end
		return
	end

	local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
	local width, height = 4 * scale, 5 * scale
	local x, y = pos.X - width / 2, pos.Y - height / 2

	local role = getRole(player)

	-- General
	if showAllESP then
		data.AllBox.Size = Vector2.new(width, height)
		data.AllBox.Position = Vector2.new(x, y)
		data.AllBox.Visible = true
	else
		data.AllBox.Visible = false
	end

	-- Murderer
	if showMurdererESP and role == "Murderer" then
		data.MurderBox.Size = Vector2.new(width, height)
		data.MurderBox.Position = Vector2.new(x, y)
		data.MurderBox.Visible = true
	else
		data.MurderBox.Visible = false
	end

	-- Sheriff
	if showSheriffESP and role == "Sheriff" then
		data.SheriffBox.Size = Vector2.new(width, height)
		data.SheriffBox.Position = Vector2.new(x, y)
		data.SheriffBox.Visible = true
	else
		data.SheriffBox.Visible = false
	end
end

-- 📦 Кнопки
allBtn.MouseButton1Click:Connect(function()
	showAllESP = not showAllESP
	allBtn.Text = "Box ESP: " .. (showAllESP and "ON" or "OFF")
end)

murderBtn.MouseButton1Click:Connect(function()
	showMurdererESP = not showMurdererESP
	murderBtn.Text = "Murderer ESP: " .. (showMurdererESP and "ON" or "OFF")
end)

sheriffBtn.MouseButton1Click:Connect(function()
	showSheriffESP = not showSheriffESP
	sheriffBtn.Text = "Sheriff ESP: " .. (showSheriffESP and "ON" or "OFF")
end)

-- 📦 Игроки
for _, p in pairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		addEsp(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		addEsp(p)
	end
end)

Players.PlayerRemoving:Connect(removeEsp)

-- 📦 Цикл
RunService.RenderStepped:Connect(function()
	for player, data in pairs(espCache) do
		if player and player ~= LocalPlayer then
			updateEsp(player, data)
		end
	end
end)
