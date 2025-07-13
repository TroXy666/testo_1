-- 📦 Настройки
local settings = {
	DefaultColor = Color3.fromRGB(255, 0, 0),
	BoxScale = 0.7,
	TeamCheck = false
}

-- 📦 Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 📦 Drawing хранилище
local espCache = {}
local espEnabled = false

-- 📦 UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ESP_Menu"
gui.ResetOnSpawn = false

-- Основной контейнер
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Заголовок
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.Text = "ESP MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.BorderSizePixel = 0

-- Кнопка
local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0, 20, 0, 45)
toggle.Size = UDim2.new(0, 180, 0, 40)
toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggle.Text = "Box ESP: OFF"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSans
toggle.TextSize = 18
toggle.BorderSizePixel = 0

-- 📦 ESP Box функция
local function createBox()
	local box = Drawing.new("Square")
	box.Visible = false
	box.Filled = false
	box.Thickness = 1
	box.Color = settings.DefaultColor
	return box
end

-- 📦 Создание ESP
local function addEsp(player)
	if espCache[player] then return end
	espCache[player] = {
		Box = createBox()
	}
end

-- 📦 Удаление ESP
local function removeEsp(player)
	if espCache[player] then
		for _, obj in pairs(espCache[player]) do
			if obj then obj:Remove() end
		end
		espCache[player] = nil
	end
end

-- 📦 Обновление ESP
local function updateEsp(player, data)
	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
	if not (onScreen and pos.Z > 0) then
		data.Box.Visible = false
		return
	end

	local distance = pos.Z
	local scale = settings.BoxScale / (distance * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
	local width, height = 4 * scale, 5 * scale
	local x, y = pos.X - width / 2, pos.Y - height / 2

	data.Box.Size = Vector2.new(width, height)
	data.Box.Position = Vector2.new(x, y)
	data.Box.Color = settings.DefaultColor
	data.Box.Visible = true
end

-- 📦 Переключение ESP
toggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggle.Text = "Box ESP: " .. (espEnabled and "ON" or "OFF")
	if not espEnabled then
		for _, v in pairs(espCache) do
			v.Box.Visible = false
		end
	end
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

-- 📦 Цикл ESP
RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	for player, data in pairs(espCache) do
		if player and player ~= LocalPlayer and player.Character then
			if settings.TeamCheck and player.Team == LocalPlayer.Team then
				data.Box.Visible = false
			else
				updateEsp(player, data)
			end
		else
			data.Box.Visible = false
		end
	end
end)
