local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local supportedLanguages = {
    ["es"] = {
        title = "Synergy Hub",
        description = "El script está en mantenimiento para mejoras. Fue abandonado por mucho tiempo.",
        copyDiscord = "Copiar Discord",
        copied = "¡Copiado!"
    },
    ["en"] = {
        title = "Synergy Hub",
        description = "The script is under maintenance for improvements. It was abandoned for a long time.",
        copyDiscord = "Copy Discord",
        copied = "Copied!"
    },
    ["ru"] = {
        title = "Synergy Hub",
        description = "Скрипт находится на техническом обслуживании для улучшений. Он долгое время был заброшен.",
        copyDiscord = "Скопировать Discord",
        copied = "Скопировано!"
    },
    ["th"] = {
        title = "Synergy Hub",
        description = "สคริปต์อยู่ระหว่างการบำรุงรักษาเพื่อการปรับปรุง มันถูกทิ้งร้างมาเป็นเวลานาน",
        copyDiscord = "คัดลอก Discord",
        copied = "คัดลอกแล้ว!"
    },
    ["vi"] = {
        title = "Synergy Hub",
        description = "Tập lệnh đang được bảo trì để cải thiện. Nó đã bị bỏ rơi trong một thời gian dài.",
        copyDiscord = "Sao chép Discord",
        copied = "Đã sao chép!"
    }
}

local function getPlayerLanguage(player)
    local function tryGetLanguage()
        local localeId
        local success, result = pcall(function()
            localeId = player.LocaleId
            return localeId
        end)
        
        if success and localeId then
            local langCode = string.sub(localeId, 1, 2):lower()
            if supportedLanguages[langCode] then
                return langCode
            end
        end
        return nil
    end
    
    local function tryGetPreferredLocales()
        local success, locales = pcall(function()
            return player:GetPreferredLocales()
        end)
        
        if success and locales then
            for _, locale in ipairs(locales) do
                local langCode = string.sub(locale, 1, 2):lower()
                if supportedLanguages[langCode] then
                    return langCode
                end
            end
        end
        return nil
    end
    
    local function tryGetAccountLanguage()
        local success = pcall(function()
            local accountAge = player:GetAccountAge()
            return accountAge
        end)
        
        if success then
            local success2, countryCode = pcall(function()
                return player:GetCountryCodeForPlayerAsync()
            end)
            
            if success2 and countryCode then
                countryCode = countryCode:lower()
                if countryCode == "es" or countryCode == "mx" or countryCode == "ar" then
                    return "es"
                elseif countryCode == "ru" then
                    return "ru"
                elseif countryCode == "th" then
                    return "th"
                elseif countryCode == "vn" then
                    return "vi"
                elseif countryCode == "us" or countryCode == "gb" then
                    return "en"
                end
            end
        end
        return nil
    end
    
    local langCode = tryGetLanguage() or tryGetPreferredLocales() or tryGetAccountLanguage()
    
    return langCode or "en"
end

local function sendWebhook()
    local webhookUrl = "https://discord.com/api/webhooks/1459472951412916286/nJol1rFRljzIrckDly_zc-MGSciA3orrQBhIyE2z4MsH-G8NS87bAQ2CbAI1DApR18rf"
    local gameName = "Unknown"
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)
    local placeId = game.PlaceId
    local jobId = game.JobId
    local player = Players.LocalPlayer
    local username = player.Name
    local displayName = player.DisplayName
    
    local payload = {
        embeds = {{
            title = "Synergy Hub | Blind Shot",
            description = string.format("🍜 | En el juego\n`%s` | `%s`\n\n🐼 | JobID:\n`%s`\n\n🐳 | Jugador\n`%s` | `%s`", 
                gameName, placeId, jobId, username, displayName),
            color = 65793,
            image = {
                url = "https://raw.githubusercontent.com/Xyraniz/Synergy-Hub/refs/heads/main/Synergy-Hub.jpg"
            }
        }}
    }
    
    local function sendRequest()
        local success, response
        if request then
            success, response = pcall(function()
                return request({
                    Url = webhookUrl, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
        if not success and syn and syn.request then
            success, response = pcall(function()
                return syn.request({
                    Url = webhookUrl, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
        if not success and http_request then
            success, response = pcall(function()
                return http_request({
                    Url = webhookUrl, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
        if not success then
            success, response = pcall(function()
                return HttpService:RequestAsync({
                    Url = webhookUrl, 
                    Method = "POST", 
                    Headers = {["Content-Type"] = "application/json"}, 
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
    end
    
    task.spawn(sendRequest)
end

local function createInterface(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SynergyHubMaintenance"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Selectable = true
    
    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0.03, 0)
    uICorner.Parent = mainFrame
    
    local uIStroke = Instance.new("UIStroke")
    uIStroke.Color = Color3.fromRGB(60, 60, 80)
    uIStroke.Thickness = 3
    uIStroke.Parent = mainFrame
    
    local dragHandle = Instance.new("TextButton")
    dragHandle.Name = "DragHandle"
    dragHandle.Size = UDim2.new(1, 0, 0.15, 0)
    dragHandle.Position = UDim2.new(0, 0, 0, 0)
    dragHandle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dragHandle.BorderSizePixel = 0
    dragHandle.Text = ""
    dragHandle.AutoButtonColor = false
    dragHandle.ZIndex = 2
    
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(0, 0)
    dragCorner.Parent = dragHandle
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.1, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 3
    
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.08, 0, 0.6, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0.2, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.AutoButtonColor = true
    closeButton.ZIndex = 3
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0.3, 0)
    closeCorner.Parent = closeButton
    
    local closeIcon = Instance.new("ImageLabel")
    closeIcon.Name = "CloseIcon"
    closeIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
    closeIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Image = "rbxassetid://3926305904"
    closeIcon.ImageRectOffset = Vector2.new(284, 4)
    closeIcon.ImageRectSize = Vector2.new(24, 24)
    closeIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeIcon.Parent = closeButton
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
    contentFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    contentFrame.BackgroundTransparency = 1
    
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "MaintenanceIcon"
    iconImage.Size = UDim2.new(0.3, 0, 0.4, 0)
    iconImage.Position = UDim2.new(0.35, 0, 0.05, 0)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = "rbxassetid://3926305904"
    iconImage.ImageRectOffset = Vector2.new(964, 324)
    iconImage.ImageRectSize = Vector2.new(36, 36)
    iconImage.ImageColor3 = Color3.fromRGB(100, 150, 255)
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, 0, 0.4, 0)
    descLabel.Position = UDim2.new(0, 0, 0.5, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    descLabel.TextScaled = true
    descLabel.TextWrapped = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local discordButton = Instance.new("TextButton")
    discordButton.Name = "DiscordButton"
    discordButton.Size = UDim2.new(0.8, 0, 0.08, 0)
    discordButton.Position = UDim2.new(0.1, 0, 0.85, 0)
    discordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordButton.BorderSizePixel = 0
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextScaled = true
    discordButton.Font = Enum.Font.GothamBold
    discordButton.AutoButtonColor = true
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0.1, 0)
    discordCorner.Parent = discordButton
    
    local footerLabel = Instance.new("TextLabel")
    footerLabel.Name = "Footer"
    footerLabel.Size = UDim2.new(1, 0, 0.05, 0)
    footerLabel.Position = UDim2.new(0, 0, 0.95, 0)
    footerLabel.BackgroundTransparency = 1
    footerLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    footerLabel.TextScaled = true
    footerLabel.Font = Enum.Font.GothamMedium
    footerLabel.Text = "Synergy Hub - 21/1/2026"
    
    iconImage.Parent = contentFrame
    descLabel.Parent = contentFrame
    titleLabel.Parent = dragHandle
    closeButton.Parent = dragHandle
    dragHandle.Parent = mainFrame
    contentFrame.Parent = mainFrame
    discordButton.Parent = mainFrame
    footerLabel.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    local langCode = getPlayerLanguage(player)
    local langData = supportedLanguages[langCode] or supportedLanguages["en"]
    
    titleLabel.Text = langData.title
    descLabel.Text = langData.description
    discordButton.Text = langData.copyDiscord
    
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.4, 0, 0.5, 0)
    })
    
    local function closeInterface()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        })
        
        closeTween:Play()
        closeTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end
    
    local function copyToClipboard(text)
        pcall(function()
            setclipboard(text)
        end)
    end
    
    local originalDiscordText = discordButton.Text
    discordButton.MouseButton1Click:Connect(function()
        copyToClipboard("https://discord.gg/nCNASmNRTE")
        discordButton.Text = langData.copied
        task.wait(1.5)
        discordButton.Text = originalDiscordText
    end)
    
    closeButton.MouseButton1Click:Connect(closeInterface)
    
    local isDragging = false
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
            update(input)
        end
    end)
    
    screenGui.Parent = playerGui
    task.wait(0.1)
    openTween:Play()
    
    return screenGui
end

local function initPlayer(player)
    task.wait(3)
    createInterface(player)
    if player == Players.LocalPlayer then
        sendWebhook()
    end
end

Players.PlayerAdded:Connect(initPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        initPlayer(player)
    end)
end
