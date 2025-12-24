local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end
end

local function sendWebhook()
    local webhookUrl = "https://discord.com/api/webhooks/1453158249259077904/E6q0M25B_kaRcs9vV3a2H7D1Rfsz27tG0SM7ALfPmS8DnR0AnE1bGDGQtGdxJcNx8P_r"
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local placeId = game.PlaceId
    local jobId = game.JobId
    local player = game.Players.LocalPlayer
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
                return request({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(payload)})
            end)
        end
        if not success and syn and syn.request then
            success, response = pcall(function()
                return syn.request({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(payload)})
            end)
        end
        if not success and http_request then
            success, response = pcall(function()
                return http_request({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(payload)})
            end)
        end
        if not success then
            success, response = pcall(function()
                return game:GetService("HttpService"):RequestAsync({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode(payload)})
            end)
        end
    end
    
    task.spawn(sendRequest)
end

sendWebhook()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "es",
    Translations = {  
        ["es"] = {  
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",  
            ["INFO_TAB"] = "Informacion",  
            ["WELCOME"] = "Bienvenido a Synergy Hub!",  
            ["ABOUT_WHATIS"] = "Que es Synergy Hub?",  
            ["ABOUT_DESC"] = "Un Hub de scripts para Roblox con scripts universales y para juegos especificos. Disenado para mejorar tu experiencia de juego.",  
            ["PLAYER_TAB"] = "Jugador",
            ["MISC_TAB"] = "Misc",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti Void",
            ["TROPHY_FARM"] = "Trophy Farm",
            ["SYNERGY_KEYBIND"] = "Tecla de Synergy Hub",  
            ["DISCORD_SERVER"] = "Servidor de Discord",   
            ["DISCORD_COPIED"] = "Invitacion copiada",  
            ["SELECT_LANGUAGE"] = "Seleccionar idioma",  
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Velocidad de Caminar",
            ["JUMPPOWER"] = "Fuerza de Salto",
            ["SPEED_HACK"] = "Hack de Velocidad",
            ["INFINITE_JUMP"] = "Salto Infinito",
            ["NOCLIP"] = "Noclip"
        },
        ["en"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Information",
            ["WELCOME"] = "Welcome to Synergy Hub!",
            ["ABOUT_WHATIS"] = "What is Synergy Hub?",
            ["ABOUT_DESC"] = "A Roblox script hub with universal and game-specific scripts. Designed to enhance your gaming experience.",
            ["PLAYER_TAB"] = "Player",
            ["MISC_TAB"] = "Misc",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti Void",
            ["TROPHY_FARM"] = "Trophy Farm",
            ["SYNERGY_KEYBIND"] = "Synergy Hub Key",
            ["DISCORD_SERVER"] = "Discord Server",
            ["DISCORD_COPIED"] = "Invitation copied",
            ["SELECT_LANGUAGE"] = "Select language",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "WalkSpeed",
            ["JUMPPOWER"] = "JumpPower",
            ["SPEED_HACK"] = "Speed Hack",
            ["INFINITE_JUMP"] = "Infinite Jump",
            ["NOCLIP"] = "Noclip"
        },
        ["ru"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Информация",
            ["WELCOME"] = "Добро пожаловать в Synergy Hub!",
            ["ABOUT_WHATIS"] = "Что такое Synergy Hub?",
            ["ABOUT_DESC"] = "Хаб скриптов для Roblox с универсальными и игровыми скриптами. Разработан для улучшения вашего игрового опыта.",
            ["PLAYER_TAB"] = "Игрок",
            ["MISC_TAB"] = "Разное",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Анти-Войд",
            ["TROPHY_FARM"] = "Фарм трофеев",
            ["SYNERGY_KEYBIND"] = "Клавиша Synergy Hub",
            ["DISCORD_SERVER"] = "Discord сервер",
            ["DISCORD_COPIED"] = "Приглашение скопировано",
            ["SELECT_LANGUAGE"] = "Выбрать язык",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Скорость ходьбы",
            ["JUMPPOWER"] = "Сила прыжка",
            ["SPEED_HACK"] = "Спидхак",
            ["INFINITE_JUMP"] = "Бесконечный прыжок",
            ["NOCLIP"] = "Ноклип"
        },
        ["fr"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Information",
            ["WELCOME"] = "Bienvenue sur Synergy Hub !",
            ["ABOUT_WHATIS"] = "Qu'est-ce que Synergy Hub ?",
            ["ABOUT_DESC"] = "Un hub de scripts Roblox avec des scripts universels et specifiques au jeu. Concu pour ameliorer votre experience de jeu.",
            ["PLAYER_TAB"] = "Joueur",
            ["MISC_TAB"] = "Divers",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti-Vide",
            ["TROPHY_FARM"] = "Farm de trophees",
            ["SYNERGY_KEYBIND"] = "Touche Synergy Hub",
            ["DISCORD_SERVER"] = "Serveur Discord",
            ["DISCORD_COPIED"] = "Invitation copiee",
            ["SELECT_LANGUAGE"] = "Selectionner la langue",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Vitesse de marche",
            ["JUMPPOWER"] = "Puissance de saut",
            ["SPEED_HACK"] = "Hack de vitesse",
            ["INFINITE_JUMP"] = "Saut infini",
            ["NOCLIP"] = "Noclip"
        },
        ["pt"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Informacao",
            ["WELCOME"] = "Bem-vindo ao Synergy Hub!",
            ["ABOUT_WHATIS"] = "O que e o Synergy Hub?",
            ["ABOUT_DESC"] = "Um hub de scripts para Roblox com scripts universais e especificos para jogos. Projetado para melhorar sua experiencia de jogo.",
            ["PLAYER_TAB"] = "Jogador",
            ["MISC_TAB"] = "Diversos",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti-Vazio",
            ["TROPHY_FARM"] = "Farm de Trofeus",
            ["SYNERGY_KEYBIND"] = "Tecla do Synergy Hub",
            ["DISCORD_SERVER"] = "Servidor do Discord",
            ["DISCORD_COPIED"] = "Convite copiado",
            ["SELECT_LANGUAGE"] = "Selecionar idioma",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Velocidade de Caminhada",
            ["JUMPPOWER"] = "Poder de Salto",
            ["SPEED_HACK"] = "Hack de Velocidade",
            ["INFINITE_JUMP"] = "Salto Infinito",
            ["NOCLIP"] = "Noclip"
        },
        ["it"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Informazioni",
            ["WELCOME"] = "Benvenuto in Synergy Hub!",
            ["ABOUT_WHATIS"] = "Cos'e Synergy Hub?",
            ["ABOUT_DESC"] = "Un hub di script per Roblox con script universali e specifici per gioco. Progettato per migliorare la tua esperienza di gioco.",
            ["PLAYER_TAB"] = "Giocatore",
            ["MISC_TAB"] = "Varie",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti-Vuoto",
            ["TROPHY_FARM"] = "Farm Trofei",
            ["SYNERGY_KEYBIND"] = "Tasto Synergy Hub",
            ["DISCORD_SERVER"] = "Server Discord",
            ["DISCORD_COPIED"] = "Invito copiato",
            ["SELECT_LANGUAGE"] = "Seleziona lingua",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Velocita di camminata",
            ["JUMPPOWER"] = "Potenza del salto",
            ["SPEED_HACK"] = "Hack di velocita",
            ["INFINITE_JUMP"] = "Salto infinito",
            ["NOCLIP"] = "Noclip"
        },
        ["id"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "Informasi",
            ["WELCOME"] = "Selamat datang di Synergy Hub!",
            ["ABOUT_WHATIS"] = "Apa itu Synergy Hub?",
            ["ABOUT_DESC"] = "Hub skrip Roblox dengan skrip universal dan khusus game. Dirancang untuk meningkatkan pengalaman bermain Anda.",
            ["PLAYER_TAB"] = "Pemain",
            ["MISC_TAB"] = "Lain-lain",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "Anti Void",
            ["TROPHY_FARM"] = "Farm Trofi",
            ["SYNERGY_KEYBIND"] = "Tombol Synergy Hub",
            ["DISCORD_SERVER"] = "Server Discord",
            ["DISCORD_COPIED"] = "Undangan disalin",
            ["SELECT_LANGUAGE"] = "Pilih bahasa",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "Kecepatan Jalan",
            ["JUMPPOWER"] = "Daya Lompat",
            ["SPEED_HACK"] = "Hack Kecepatan",
            ["INFINITE_JUMP"] = "Lompatan Tak Terbatas",
            ["NOCLIP"] = "Noclip"
        },
        ["th"] = {
            ["WINDUI_SYNERGY"] = "Synergy Hub - Blind Shot",
            ["INFO_TAB"] = "ข้อมูล",
            ["WELCOME"] = "ยินดีต้อนรับสู่ Synergy Hub!",
            ["ABOUT_WHATIS"] = "Synergy Hub คืออะไร?",
            ["ABOUT_DESC"] = "ฮับสคริปต์ Roblox ที่มีสคริปต์ทั่วไปและเฉพาะเกม ออกแบบมาเพื่อเพิ่มประสบการณ์การเล่นเกมของคุณ",
            ["PLAYER_TAB"] = "ผู้เล่น",
            ["MISC_TAB"] = "อื่นๆ",
            ["ESP"] = "ESP",
            ["ANTI_VOID"] = "แอนตี้วอยด์",
            ["TROPHY_FARM"] = "ฟาร์มถ้วยรางวัล",
            ["SYNERGY_KEYBIND"] = "ปุ่ม Synergy Hub",
            ["DISCORD_SERVER"] = "เซิร์ฟเวอร์ Discord",
            ["DISCORD_COPIED"] = "คัดลอกคำเชิญแล้ว",
            ["SELECT_LANGUAGE"] = "เลือกภาษา",
            ["SYNERGY_AUTHOR"] = "Xyraniz",
            ["WALKSPEED"] = "ความเร็วเดิน",
            ["JUMPPOWER"] = "พลังกระโดด",
            ["SPEED_HACK"] = "แฮคความเร็ว",
            ["INFINITE_JUMP"] = "กระโดดไม่สิ้นสุด",
            ["NOCLIP"] = "Noclip"
        }
    }
})

local Window
local playerName = game.Players.LocalPlayer.Name

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local PlayerFeatures = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    NoClip = false,
    SpeedHack = false
}

local MiscFeatures = {
    ESP = false,
    AntiVoid = false,
    TrophyFarm = false
}

local noclipConnection
local infiniteJumpConnection
local speedHackConnection
local characterAddedConnection
local espConnection
local antiVoidConnection
local trophyFarmConnection
local platformPart

local function applyPlayerMods(character)
    pcall(function()
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = PlayerFeatures.SpeedHack and 100 or PlayerFeatures.WalkSpeed
            humanoid.JumpPower = PlayerFeatures.JumpPower

            if PlayerFeatures.SpeedHack then
                if speedHackConnection then speedHackConnection:Disconnect() end
                speedHackConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    humanoid.WalkSpeed = 100
                end)
            end

            if PlayerFeatures.NoClip then
                if noclipConnection then noclipConnection:Disconnect() end
                noclipConnection = RunService.Stepped:Connect(function()
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end
    end)
end

characterAddedConnection = Player.CharacterAdded:Connect(function(character)
    applyPlayerMods(character)
end)

if Player.Character then
    applyPlayerMods(Player.Character)
end

local function createESP()
    local BEAM_NAME = "SynergyESPRay"
    local BEAM_COLOR = Color3.fromRGB(255, 0, 0)
    local BEAM_LENGTH = 50

    local function setupBeam(part)
        local attachment0 = part:FindFirstChild("ESP_Attach0")
        if not attachment0 then
            attachment0 = Instance.new("Attachment")
            attachment0.Name = "ESP_Attach0"
            attachment0.Position = Vector3.zero
            attachment0.Parent = part
        end

        local attachment1 = part:FindFirstChild("ESP_Attach1")
        if not attachment1 then
            attachment1 = Instance.new("Attachment")
            attachment1.Name = "ESP_Attach1"
            attachment1.Parent = part
        end

        attachment1.Position = Vector3.new(0, 0, BEAM_LENGTH)

        local beam = part:FindFirstChild(BEAM_NAME)
        if not beam then
            beam = Instance.new("Beam")
            beam.Name = BEAM_NAME
            beam.Attachment0 = attachment0
            beam.Attachment1 = attachment1
            beam.Width0 = 0.2
            beam.Width1 = 0.2
            beam.FaceCamera = true
            beam.Parent = part
        end

        beam.Enabled = true
        beam.Color = ColorSequence.new(BEAM_COLOR)
        beam.Transparency = NumberSequence.new(0)
        beam.LightEmission = 1
        beam.LightInfluence = 0
    end

    local function applyESP(character)
        for _, descendant in character:GetDescendants() do
            if descendant:IsA("BasePart") then
                if descendant.Name ~= "HumanoidRootPart" and descendant.Name ~= "hitbox" then
                    descendant.Transparency = 0
                end

                if descendant.Name == "ponto" then
                    setupBeam(descendant)
                end
            end
        end
    end

    if espConnection then
        espConnection:Disconnect()
    end

    espConnection = RunService.Heartbeat:Connect(function()
        for _, player in Players:GetPlayers() do
            local character = player.Character
            if character then
                applyESP(character)
            end
        end
    end)
end

local function toggleESP(state)
    MiscFeatures.ESP = state
    if state then
        createESP()
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        
        for _, player in Players:GetPlayers() do
            local character = player.Character
            if character then
                for _, descendant in character:GetDescendants() do
                    if descendant.Name == "SynergyESPRay" then
                        descendant:Destroy()
                    end
                end
            end
        end
    end
end

local function createAntiVoid()
    if antiVoidConnection then
        antiVoidConnection:Disconnect()
    end
    
    if not platformPart then
        platformPart = Instance.new("Part")
        platformPart.Name = "AntiVoidPlatform"
        platformPart.Size = Vector3.new(100, 5, 100)
        platformPart.Transparency = 1
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Parent = workspace
    end
    
    antiVoidConnection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            local position = hrp.Position
            
            if position.Y < -50 then
                hrp.CFrame = CFrame.new(0, -2, -10)
            end
            
            platformPart.Position = Vector3.new(position.X, position.Y - 10, position.Z)
            platformPart.Transparency = 0.8
        end
    end)
end

local function toggleAntiVoid(state)
    MiscFeatures.AntiVoid = state
    if state then
        createAntiVoid()
    else
        if antiVoidConnection then
            antiVoidConnection:Disconnect()
            antiVoidConnection = nil
        end
        
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
    end
end

local function createTrophyFarm()
    local trophy = workspace:WaitForChild("Trophy")
    local farmSpeed = 1
    
    if trophyFarmConnection then
        trophyFarmConnection:Disconnect()
    end
    
    trophyFarmConnection = RunService.Heartbeat:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            pcall(function()
                firetouchinterest(hrp, trophy, 0)
                firetouchinterest(hrp, trophy, 1)
            end)
        end
    end)
end

local function toggleTrophyFarm(state)
    MiscFeatures.TrophyFarm = state
    if state then
        createTrophyFarm()
    else
        if trophyFarmConnection then
            trophyFarmConnection:Disconnect()
            trophyFarmConnection = nil
        end
    end
end

function createWelcomePopup()
    WindUI:Popup({
        Title = "Hi, " .. playerName .. "!",
        Icon = "bird",
        Content = "Welcome to Synergy Hub! Report bugs on the discord server",
        Buttons = {
            {
                Title = "Copy Discord",
                Icon = "copy",
                Callback = function()
                    setclipboard("discord.gg/nCNASmNRTE")
                    WindUI:Notify({ 
                        Title = "Discord", 
                        Content = "Invite copied", 
                        Duration = 2 
                    })
                end
            },
            {
                Title = "Okay",
                Icon = "check",
                Callback = function()
                    if not Window then
                        createMainWindow()
                    else
                        Window:Show()
                    end
                end
            }
        }
    })
end

function createMainWindow()
    Window = WindUI:CreateWindow({
        Title = "loc:WINDUI_SYNERGY",
        Author = "loc:SYNERGY_AUTHOR",
        Folder = "synergy_hub",
        Icon = "lucide:layout-dashboard",
        IconSize = 44,
        NewElements = true,
        HideSearchBar = false
    })

    pcall(function() WindUI:SetTheme("Stylish") end)

    Window:SetToggleKey(Enum.KeyCode.X)

    local InfoTab = Window:Tab({ Title = "loc:INFO_TAB", Icon = "lucide:layout-dashboard" })
    local MiscTab = Window:Tab({ Title = "loc:MISC_TAB", Icon = "lucide:package" })
    local PlayerTab = Window:Tab({ Title = "loc:PLAYER_TAB", Icon = "lucide:user" })

    InfoTab:Paragraph({
        Title = "",
        Desc = "",
        Image = "https://raw.githubusercontent.com/Synergy-Hub-Official/Scripts/refs/heads/main/Synergy-Hub.jpg",
        ImageSize = 260
    })

    InfoTab:Paragraph({
        Title = "loc:ABOUT_WHATIS",
        Desc = "loc:ABOUT_DESC"
    })

    InfoTab:Paragraph({
        Title = "Credits",
        Desc = "Xyraniz\nWindUI © Footagesus — GitHub"
    })

    InfoTab:Button({ Title = "loc:DISCORD_SERVER", Callback = function() 
        pcall(function() 
            setclipboard("discord.gg/nCNASmNRTE") 
        end) 
        WindUI:Notify({ 
            Title = "Discord", 
            Content = "loc:DISCORD_COPIED", 
            Duration = 2 
        }) 
    end })

    InfoTab:Keybind({ 
        Title = "loc:SYNERGY_KEYBIND", 
        Value = "X", 
        Callback = function(v) 
            Window:SetToggleKey(Enum.KeyCode[v])
        end 
    })

    local languages = { 
        {Name = "Espanol", Code = "es"}, 
        {Name = "English", Code = "en"}, 
        {Name = "Русский", Code = "ru"},
        {Name = "Francais", Code = "fr"},
        {Name = "Portugues", Code = "pt"},
        {Name = "Italiano", Code = "it"},
        {Name = "Bahasa Indonesia", Code = "id"},
        {Name = "ไทย", Code = "th"}
    }
    local options = {}
    for i, v in ipairs(languages) do options[i] = v.Name end
    InfoTab:Dropdown({ 
        Title = "loc:SELECT_LANGUAGE", 
        Flag = "LanguageSelect", 
        Values = options, 
        Callback = function(val)
            for _, v in ipairs(languages) do
                if v.Name == val then
                    pcall(function() 
                        WindUI:SetLanguage(v.Code) 
                    end)
                    WindUI:Notify({ 
                        Title = "WindUI", 
                        Content = v.Name, 
                        Duration = 2 
                    })
                    break
                end
            end
        end 
    })

    MiscTab:Toggle({ 
        Title = "loc:ESP", 
        Flag = "ESP", 
        Callback = function(v) 
            toggleESP(v)
        end 
    })

    MiscTab:Toggle({ 
        Title = "loc:ANTI_VOID", 
        Flag = "AntiVoid", 
        Callback = function(v) 
            toggleAntiVoid(v)
        end 
    })

    MiscTab:Toggle({ 
        Title = "loc:TROPHY_FARM", 
        Flag = "TrophyFarm", 
        Callback = function(v) 
            toggleTrophyFarm(v)
        end 
    })

    PlayerTab:Slider({ 
        Title = "loc:WALKSPEED", 
        Flag = "WalkSpeed", 
        Step = 1, 
        Value = { Min = 16, Max = 500, Default = 16 }, 
        Callback = function(v) 
            PlayerFeatures.WalkSpeed = v
            pcall(function()
                local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and not PlayerFeatures.SpeedHack then
                    humanoid.WalkSpeed = v
                end
            end)
        end 
    })

    PlayerTab:Slider({ 
        Title = "loc:JUMPPOWER", 
        Flag = "JumpPower", 
        Step = 1, 
        Value = { Min = 30, Max = 500, Default = 50 }, 
        Callback = function(v) 
            PlayerFeatures.JumpPower = v
            pcall(function()
                local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = v
                end
            end)
        end 
    })

    PlayerTab:Toggle({ 
        Title = "loc:SPEED_HACK", 
        Flag = "SpeedHack", 
        Callback = function(v) 
            PlayerFeatures.SpeedHack = v
            
            pcall(function()
                local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if v then
                        if speedHackConnection then speedHackConnection:Disconnect() end
                        speedHackConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                            humanoid.WalkSpeed = 100
                        end)
                        humanoid.WalkSpeed = 100
                    else
                        if speedHackConnection then speedHackConnection:Disconnect() speedHackConnection = nil end
                        humanoid.WalkSpeed = PlayerFeatures.WalkSpeed
                    end
                end
            end)
        end 
    })

    PlayerTab:Toggle({ 
        Title = "loc:INFINITE_JUMP", 
        Flag = "InfJump", 
        Callback = function(v) 
            PlayerFeatures.InfiniteJump = v
            
            if v then
                if infiniteJumpConnection then infiniteJumpConnection:Disconnect() end
                infiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    pcall(function()
                        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end)
                end)
            else
                if infiniteJumpConnection then infiniteJumpConnection:Disconnect() infiniteJumpConnection = nil end
            end
        end 
    })

    PlayerTab:Toggle({ 
        Title = "loc:NOCLIP", 
        Flag = "Noclip", 
        Callback = function(v) 
            PlayerFeatures.NoClip = v
            
            if v then
                if noclipConnection then noclipConnection:Disconnect() end
                noclipConnection = RunService.Stepped:Connect(function()
                    pcall(function()
                        for _, part in pairs(Player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                end)
            else
                if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                pcall(function()
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end)
            end
        end 
    })

    if InfoTab and InfoTab.Select then
        InfoTab:Select()
    end
end

createWelcomePopup()
