local SynergyUI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local function getDefaultParent()
    if RunService:IsStudio() then
        local player = Players.LocalPlayer
        if player then
            return player:WaitForChild("PlayerGui")
        end
    end
    return CoreGui
end

local function addCorner(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = frame
end

local function createToast(message, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyToast"
    gui.Parent = getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, -10, 0, 10)
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.AnchorPoint = Vector2.new(1, 0)
    addCorner(frame, 6)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Font = Enum.Font.Gotham
    label.Text = message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.TextWrapped = true

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, -10, 0, 10)}):Play()
    task.wait(duration or 3)
    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, 210, 0, 10)}):Play()
    task.wait(0.3)
    gui:Destroy()
end

function SynergyUI:Notify(message, duration)
    createToast(message, duration)
end

function SynergyUI:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Synergy Hub"
    local font = options.Font or Enum.Font.Gotham
    local accent = options.AccentColor or Color3.fromRGB(0, 255, 100)
    local bgColor = options.BackgroundColor or Color3.fromRGB(15, 15, 15)
    local sidebarColor = options.SidebarColor or Color3.fromRGB(20, 20, 20)
    local closeColor = options.CloseButtonColor or Color3.fromRGB(255, 50, 50)
    local minColor = options.MinimizeButtonColor or Color3.fromRGB(255, 255, 255)
    local parent = options.Parent or getDefaultParent()
    local toggleKey = options.ToggleKey or Enum.KeyCode.X
    local configFile = options.ConfigFile or ""

    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyUI_" .. tostring(os.time())
    gui.Parent = parent
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = gui
    mainFrame.BackgroundColor3 = bgColor
    mainFrame.BorderColor3 = accent
    mainFrame.BorderSizePixel = 1
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.ClipsDescendants = true
    addCorner(mainFrame, 6)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Parent = mainFrame
    topBar.BackgroundColor3 = sidebarColor
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.ZIndex = 2
    addCorner(topBar, 6)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = topBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Font = font
    titleLabel.Text = title
    titleLabel.TextColor3 = accent
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 2

    local controlContainer = Instance.new("Frame")
    controlContainer.Parent = topBar
    controlContainer.BackgroundTransparency = 1
    controlContainer.Position = UDim2.new(1, -70, 0, 0)
    controlContainer.Size = UDim2.new(0, 70, 1, 0)
    controlContainer.ZIndex = 2

    local minBtn = Instance.new("TextButton")
    minBtn.Parent = controlContainer
    minBtn.BackgroundTransparency = 1
    minBtn.Size = UDim2.new(0.5, 0, 1, 0)
    minBtn.Font = font
    minBtn.Text = "-"
    minBtn.TextColor3 = minColor
    minBtn.TextSize = 18
    minBtn.ZIndex = 2

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = controlContainer
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(0.5, 0, 0, 0)
    closeBtn.Size = UDim2.new(0.5, 0, 1, 0)
    closeBtn.Font = font
    closeBtn.Text = "X"
    closeBtn.TextColor3 = closeColor
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 2

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = mainFrame
    sidebar.BackgroundColor3 = sidebarColor
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.Size = UDim2.new(0, 130, 1, -35)

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Parent = sidebar
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = mainFrame
    contentArea.BackgroundColor3 = bgColor
    contentArea.BorderSizePixel = 0
    contentArea.Position = UDim2.new(0, 130, 0, 35)
    contentArea.Size = UDim2.new(1, -130, 1, -35)

    local dragging = false
    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 35)}):Play()
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 550, 0, 350)}):Play()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local uiVisible = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            uiVisible = not uiVisible
            gui.Enabled = uiVisible
        end
    end)

    local window = {
        Flags = {},
        gui = gui,
        mainFrame = mainFrame,
        tabs = {},
        currentTab = nil,
        font = font,
        accent = accent,
        bgColor = bgColor,
        sidebarColor = sidebarColor,
        controls = {},
        configFile = configFile,
    }

    local function updateAccentColor(newAccent)
        window.accent = newAccent
        mainFrame.BorderColor3 = newAccent
        titleLabel.TextColor3 = newAccent
        for _, tab in ipairs(window.tabs) do
            if tab.btn.TextColor3 == window.accent then
                tab.btn.TextColor3 = newAccent
            end
        end
        for _, control in ipairs(window.controls) do
            if control.updateAccent then
                control.updateAccent(newAccent)
            end
        end
    end

    function window:SetAccentColor(newAccent)
        updateAccentColor(newAccent)
    end

    local function saveConfig()
        if window.configFile == "" then return end
        local config = {
            position = {mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset},
            size = {mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, mainFrame.Size.Y.Scale, mainFrame.Size.Y.Offset},
            accent = {window.accent.R, window.accent.G, window.accent.B},
            controls = {}
        }
        for _, control in ipairs(window.controls) do
            if control.saveState then
                config.controls[control.id] = control.saveState()
            end
        end
        local json = HttpService:JSONEncode(config)
        if type(writefile) == "function" then
            writefile(window.configFile, json)
        end
    end

    local function loadConfig()
        if window.configFile == "" then return end
        local content
        if type(readfile) == "function" then
            local success, res = pcall(readfile, window.configFile)
            if success then content = res end
        end
        if not content then return end
        local config
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
        if success then config = decoded end
        if not config then return end
        if config.position then
            mainFrame.Position = UDim2.new(config.position[1], config.position[2], config.position[3], config.position[4])
        end
        if config.size then
            mainFrame.Size = UDim2.new(config.size[1], config.size[2], config.size[3], config.size[4])
        end
        if config.accent then
            updateAccentColor(Color3.new(config.accent[1], config.accent[2], config.accent[3]))
        end
        if config.controls then
            for _, control in ipairs(window.controls) do
                if control.loadState and config.controls[control.id] then
                    control.loadState(config.controls[control.id])
                end
            end
        end
    end

    function window:SaveConfig(filename)
        filename = filename or window.configFile
        if filename == "" then return end
        local old = window.configFile
        window.configFile = filename
        saveConfig()
        window.configFile = old
    end

    function window:LoadConfig(filename)
        filename = filename or window.configFile
        if filename == "" then return end
        local old = window.configFile
        window.configFile = filename
        loadConfig()
        window.configFile = old
    end

    function window:Toggle()
        uiVisible = not uiVisible
        gui.Enabled = uiVisible
    end

    function window:Destroy()
        gui:Destroy()
    end

    function window:CreateTab(tabName, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = sidebar
        tabBtn.BackgroundColor3 = sidebarColor
        tabBtn.BorderSizePixel = 0
        tabBtn.Size = UDim2.new(1, 0, 0, 35)
        tabBtn.Font = font
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.TextSize = 14

        if icon then
            local iconLabel = Instance.new("ImageLabel")
            iconLabel.Parent = tabBtn
            iconLabel.BackgroundTransparency = 1
            iconLabel.Position = UDim2.new(0, 5, 0.5, -8)
            iconLabel.Size = UDim2.new(0, 16, 0, 16)
            iconLabel.Image = icon
            iconLabel.ImageColor3 = Color3.fromRGB(200, 200, 200)
            tabBtn.Text = "    " .. tabName
        end

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Parent = contentArea
        tabContent.Active = true
        tabContent.BackgroundColor3 = bgColor
        tabContent.BorderSizePixel = 0
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = accent
        tabContent.Visible = (#window.tabs == 0)

        local layout = Instance.new("UIListLayout")
        layout.Parent = tabContent
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 5)

        local padding = Instance.new("UIPadding")
        padding.Parent = tabContent
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        if #window.tabs == 0 then
            tabBtn.TextColor3 = accent
            window.currentTab = tabContent
        end

        table.insert(window.tabs, {btn = tabBtn, content = tabContent})

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window.tabs) do
                t.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                t.content.Visible = false
            end
            tabBtn.TextColor3 = accent
            tabContent.Visible = true
            window.currentTab = tabContent
        end)

        local tab = {}

        function tab:Select()
            for _, t in ipairs(window.tabs) do
                t.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                t.content.Visible = false
            end
            tabBtn.TextColor3 = accent
            tabContent.Visible = true
            window.currentTab = tabContent
        end

        function tab:CreateSection(sectionName)
            local label = Instance.new("TextLabel")
            label.Parent = tabContent
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 25)
            label.Font = font
            label.Text = sectionName
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
        end

        function tab:CreateParagraph(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 60)
            addCorner(frame, 4)

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Parent = frame
            titleLbl.BackgroundTransparency = 1
            titleLbl.Position = UDim2.new(0, 10, 0, 5)
            titleLbl.Size = UDim2.new(1, -20, 0, 20)
            titleLbl.Font = font
            titleLbl.Text = options.Title or ""
            titleLbl.TextColor3 = accent
            titleLbl.TextSize = 14
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left

            local contentLbl = Instance.new("TextLabel")
            contentLbl.Parent = frame
            contentLbl.BackgroundTransparency = 1
            contentLbl.Position = UDim2.new(0, 10, 0, 25)
            contentLbl.Size = UDim2.new(1, -20, 0, 30)
            contentLbl.Font = font
            contentLbl.Text = options.Content or ""
            contentLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            contentLbl.TextSize = 12
            contentLbl.TextWrapped = true
            contentLbl.TextXAlignment = Enum.TextXAlignment.Left
            contentLbl.TextYAlignment = Enum.TextYAlignment.Top
        end

        function tab:CreateButton(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Font = font
            btn.Text = options.Name or ""
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                local success, err = pcall(options.Callback)
                if not success then
                    SynergyUI:Notify("Error: " .. tostring(err), 3)
                end
                TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = accent}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
        end

        function tab:CreateToggle(options)
            local toggled = options.CurrentValue or false
            local flag = options.Flag or options.Name
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = toggled and accent or Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local outer = Instance.new("Frame")
            outer.Parent = frame
            outer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            outer.Position = UDim2.new(1, -40, 0.5, -10)
            outer.Size = UDim2.new(0, 30, 0, 20)
            addCorner(outer, 30)

            local inner = Instance.new("Frame")
            inner.Parent = outer
            inner.BackgroundColor3 = toggled and accent or Color3.fromRGB(100, 100, 100)
            inner.Position = toggled and UDim2.new(0, 12, 0, 2) or UDim2.new(0, 2, 0, 2)
            inner.Size = UDim2.new(0, 16, 0, 16)
            addCorner(inner, 16)

            local click = Instance.new("TextButton")
            click.Parent = frame
            click.BackgroundTransparency = 1
            click.Size = UDim2.new(1, 0, 1, 0)
            click.Text = ""

            local function setToggle(state)
                toggled = state
                if toggled then
                    TweenService:Create(inner, TweenInfo.new(0.2), {Position = UDim2.new(0, 12, 0, 2), BackgroundColor3 = accent}):Play()
                    label.TextColor3 = accent
                else
                    TweenService:Create(inner, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                options.Callback(toggled)
                if window.configFile ~= "" then saveConfig() end
            end

            window.Flags[flag] = { Set = function(_, v) setToggle(v) end }
            click.MouseButton1Click:Connect(function() setToggle(not toggled) end)

            if toggled then options.Callback(toggled) end

            local controlId = flag
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return toggled end,
                loadState = function(state) setToggle(state) end,
                updateAccent = function(newAccent)
                    if toggled then inner.BackgroundColor3 = newAccent end
                    if toggled then label.TextColor3 = newAccent end
                end
            })
        end

        function tab:CreateSlider(options)
            local value = options.CurrentValue or options.Range[1]
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(0.7, 0, 0, 15)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local valLabel = Instance.new("TextLabel")
            valLabel.Parent = frame
            valLabel.BackgroundTransparency = 1
            valLabel.Position = UDim2.new(1, -60, 0, 5)
            valLabel.Size = UDim2.new(0, 50, 0, 15)
            valLabel.Font = font
            valLabel.Text = tostring(value)
            valLabel.TextColor3 = accent
            valLabel.TextSize = 14
            valLabel.TextXAlignment = Enum.TextXAlignment.Right

            local bg = Instance.new("Frame")
            bg.Parent = frame
            bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            bg.Position = UDim2.new(0, 10, 0, 25)
            bg.Size = UDim2.new(1, -20, 0, 10)
            addCorner(bg, 10)

            local fill = Instance.new("Frame")
            fill.Parent = bg
            fill.BackgroundColor3 = accent
            fill.Size = UDim2.new((value - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0)
            addCorner(fill, 10)

            local dragBtn = Instance.new("TextButton")
            dragBtn.Parent = bg
            dragBtn.BackgroundTransparency = 1
            dragBtn.Size = UDim2.new(1, 0, 1, 0)
            dragBtn.Text = ""

            local draggingSlider = false

            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                local val = options.Range[1] + pos * (options.Range[2] - options.Range[1])
                local increment = options.Increment or 1
                val = math.floor(val / increment + 0.5) * increment
                val = math.clamp(val, options.Range[1], options.Range[2])
                local formatted = math.floor(val) == val and tostring(val) or string.format("%.2f", val)
                valLabel.Text = formatted
                fill.Size = UDim2.new((val - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0)
                options.Callback(val)
                if window.configFile ~= "" then saveConfig() end
            end

            dragBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = true
                    updateSlider(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSlider = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return value end,
                loadState = function(state)
                    value = state
                    local formatted = math.floor(value) == value and tostring(value) or string.format("%.2f", value)
                    valLabel.Text = formatted
                    fill.Size = UDim2.new((value - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0)
                    options.Callback(value)
                end,
                updateAccent = function(newAccent)
                    fill.BackgroundColor3 = newAccent
                    valLabel.TextColor3 = newAccent
                end
            })
        end

        function tab:CreateDropdown(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.Size = UDim2.new(1, -20, 0, 35)
            btn.Font = font
            btn.Text = options.Name .. " : " .. (options.CurrentOption or "")
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left

            local container = Instance.new("ScrollingFrame")
            container.Parent = frame
            container.Active = true
            container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            container.BorderSizePixel = 0
            container.Position = UDim2.new(0, 0, 0, 35)
            container.Size = UDim2.new(1, 0, 1, -35)
            container.ScrollBarThickness = 2
            container.ScrollBarImageColor3 = accent

            local layout = Instance.new("UIListLayout")
            layout.Parent = container
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local currentOption = options.CurrentOption or (options.Options[1] or "")
            local function rebuildOptions(optList)
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, opt in ipairs(optList) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Parent = container
                    optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    optBtn.BorderSizePixel = 0
                    optBtn.Size = UDim2.new(1, 0, 0, 25)
                    optBtn.Font = font
                    optBtn.Text = opt
                    optBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optBtn.TextSize = 12
                    optBtn.MouseButton1Click:Connect(function()
                        currentOption = opt
                        btn.Text = options.Name .. " : " .. opt
                        isOpen = false
                        TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                        options.Callback(opt)
                        if window.configFile ~= "" then saveConfig() end
                    end)
                end
                container.CanvasSize = UDim2.new(0, 0, 0, #optList * 25)
            end

            rebuildOptions(options.Options)

            local isOpen = false
            btn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local targetHeight = math.min(35 + (#options.Options * 25), 135)
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                else
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                end
            end)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return currentOption end,
                loadState = function(state)
                    currentOption = state
                    btn.Text = options.Name .. " : " .. state
                    options.Callback(state)
                end,
                updateAccent = function(newAccent)
                    container.ScrollBarImageColor3 = newAccent
                end
            })

            return { SetOptions = function(_, newOpts) rebuildOptions(newOpts); options.Options = newOpts end }
        end

        function tab:CreateColorPicker(options)
            local color = options.Color or Color3.fromRGB(255, 255, 255)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 0, 35)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local preview = Instance.new("Frame")
            preview.Parent = frame
            preview.BackgroundColor3 = color
            preview.Position = UDim2.new(1, -40, 0, 5)
            preview.Size = UDim2.new(0, 30, 0, 25)
            addCorner(preview, 4)

            local expandBtn = Instance.new("TextButton")
            expandBtn.Parent = frame
            expandBtn.BackgroundTransparency = 1
            expandBtn.Size = UDim2.new(1, 0, 0, 35)
            expandBtn.Text = ""

            local rgbContainer = Instance.new("Frame")
            rgbContainer.Parent = frame
            rgbContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            rgbContainer.Position = UDim2.new(0, 0, 0, 35)
            rgbContainer.Size = UDim2.new(1, 0, 1, -35)

            local r, g, b = color.R, color.G, color.B

            local function updateFinal()
                local newColor = Color3.new(r, g, b)
                preview.BackgroundColor3 = newColor
                options.Callback(newColor)
                if window.configFile ~= "" then saveConfig() end
            end

            local function makeSlider(name, yOffset, colorTint, initial, callback)
                local sFrame = Instance.new("Frame")
                sFrame.Parent = rgbContainer
                sFrame.BackgroundTransparency = 1
                sFrame.Position = UDim2.new(0, 0, 0, yOffset)
                sFrame.Size = UDim2.new(1, 0, 0, 30)

                local sLabel = Instance.new("TextLabel")
                sLabel.Parent = sFrame
                sLabel.BackgroundTransparency = 1
                sLabel.Position = UDim2.new(0, 10, 0, 0)
                sLabel.Size = UDim2.new(0, 15, 1, 0)
                sLabel.Font = font
                sLabel.Text = name
                sLabel.TextColor3 = colorTint
                sLabel.TextSize = 14

                local sBg = Instance.new("Frame")
                sBg.Parent = sFrame
                sBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                sBg.Position = UDim2.new(0, 35, 0.5, -5)
                sBg.Size = UDim2.new(1, -45, 0, 10)
                addCorner(sBg, 10)

                local sFill = Instance.new("Frame")
                sFill.Parent = sBg
                sFill.BackgroundColor3 = colorTint
                sFill.Size = UDim2.new(initial, 0, 1, 0)
                addCorner(sFill, 10)

                local drag = Instance.new("TextButton")
                drag.Parent = sBg
                drag.BackgroundTransparency = 1
                drag.Size = UDim2.new(1, 0, 1, 0)
                drag.Text = ""

                local dragging = false
                local function updateSlider(input)
                    local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                    sFill.Size = UDim2.new(pos, 0, 1, 0)
                    callback(pos)
                end
                drag.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
            end

            makeSlider("R", 5, Color3.fromRGB(255, 50, 50), r, function(v) r = v; updateFinal() end)
            makeSlider("G", 35, Color3.fromRGB(50, 255, 50), g, function(v) g = v; updateFinal() end)
            makeSlider("B", 65, Color3.fromRGB(50, 50, 255), b, function(v) b = v; updateFinal() end)

            local isOpen = false
            expandBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 135)}):Play()
                else
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 35)}):Play()
                end
            end)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return {r, g, b} end,
                loadState = function(state)
                    r, g, b = state[1], state[2], state[3]
                    updateFinal()
                end,
                updateAccent = function(newAccent) end
            })
        end

        function tab:CreateKeybind(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bindBtn = Instance.new("TextButton")
            bindBtn.Parent = frame
            bindBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            bindBtn.Position = UDim2.new(1, -70, 0, 5)
            bindBtn.Size = UDim2.new(0, 60, 0, 25)
            bindBtn.Font = font
            bindBtn.Text = options.CurrentKeybind or "None"
            bindBtn.TextColor3 = accent
            bindBtn.TextSize = 12
            addCorner(bindBtn, 4)

            local binding = false
            bindBtn.MouseButton1Click:Connect(function()
                binding = true
                bindBtn.Text = "..."
            end)

            local currentKey = options.CurrentKeybind or ""
            local function trigger()
                options.Callback(currentKey)
            end

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    currentKey = input.KeyCode.Name
                    bindBtn.Text = currentKey
                    options.Callback(currentKey)
                    if window.configFile ~= "" then saveConfig() end
                elseif not binding and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == currentKey then
                    trigger()
                end
            end)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return currentKey end,
                loadState = function(state)
                    currentKey = state
                    bindBtn.Text = currentKey
                end,
                updateAccent = function(newAccent)
                    bindBtn.TextColor3 = newAccent
                end
            })
        end

        function tab:CreateTextInput(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(1, -20, 0, 15)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local input = Instance.new("TextBox")
            input.Parent = frame
            input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            input.Position = UDim2.new(0, 10, 0, 25)
            input.Size = UDim2.new(1, -20, 0, 15)
            input.Font = font
            input.Text = options.CurrentText or ""
            input.TextColor3 = Color3.fromRGB(200, 200, 200)
            input.TextSize = 12
            input.PlaceholderText = options.Placeholder or ""
            addCorner(input, 4)

            input.FocusLost:Connect(function()
                options.Callback(input.Text)
                if window.configFile ~= "" then saveConfig() end
            end)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return input.Text end,
                loadState = function(state)
                    input.Text = state
                end,
                updateAccent = function(newAccent) end
            })
        end

        function tab:CreateChecklist(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35 + (#options.Options * 35))
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local header = Instance.new("TextLabel")
            header.Parent = frame
            header.BackgroundTransparency = 1
            header.Position = UDim2.new(0, 10, 0, 5)
            header.Size = UDim2.new(1, -20, 0, 25)
            header.Font = font
            header.Text = options.Name
            header.TextColor3 = Color3.fromRGB(255, 255, 255)
            header.TextSize = 14
            header.TextXAlignment = Enum.TextXAlignment.Left

            local container = Instance.new("Frame")
            container.Parent = frame
            container.BackgroundTransparency = 1
            container.Position = UDim2.new(0, 0, 0, 35)
            container.Size = UDim2.new(1, 0, 1, -35)

            local layout = Instance.new("UIListLayout")
            layout.Parent = container
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 5)

            local toggles = {}
            local selected = options.CurrentValues or {}

            local function updateCallback()
                options.Callback(selected)
                if window.configFile ~= "" then saveConfig() end
            end

            for _, opt in ipairs(options.Options) do
                local itemFrame = Instance.new("Frame")
                itemFrame.Parent = container
                itemFrame.BackgroundTransparency = 1
                itemFrame.Size = UDim2.new(1, 0, 0, 30)

                local label = Instance.new("TextLabel")
                label.Parent = itemFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 35, 0, 0)
                label.Size = UDim2.new(1, -45, 1, 0)
                label.Font = font
                label.Text = opt
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 12
                label.TextXAlignment = Enum.TextXAlignment.Left

                local outer = Instance.new("Frame")
                outer.Parent = itemFrame
                outer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                outer.Position = UDim2.new(0, 10, 0.5, -10)
                outer.Size = UDim2.new(0, 20, 0, 20)
                addCorner(outer, 20)

                local inner = Instance.new("Frame")
                inner.Parent = outer
                inner.BackgroundColor3 = table.find(selected, opt) and accent or Color3.fromRGB(100, 100, 100)
                inner.Position = UDim2.new(0, 2, 0, 2)
                inner.Size = UDim2.new(0, 16, 0, 16)
                addCorner(inner, 16)

                local click = Instance.new("TextButton")
                click.Parent = itemFrame
                click.BackgroundTransparency = 1
                click.Size = UDim2.new(1, 0, 1, 0)
                click.Text = ""

                local function setChecked(checked)
                    if checked then
                        if not table.find(selected, opt) then
                            table.insert(selected, opt)
                        end
                        inner.BackgroundColor3 = accent
                    else
                        local index = table.find(selected, opt)
                        if index then table.remove(selected, index) end
                        inner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    end
                    updateCallback()
                end

                setChecked(table.find(selected, opt) ~= nil)

                click.MouseButton1Click:Connect(function()
                    setChecked(inner.BackgroundColor3 ~= accent)
                end)

                toggles[opt] = setChecked
            end

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return selected end,
                loadState = function(state)
                    selected = state
                    for opt, setter in pairs(toggles) do
                        setter(table.find(selected, opt) ~= nil)
                    end
                end,
                updateAccent = function(newAccent)
                    for opt, setter in pairs(toggles) do
                        if table.find(selected, opt) then
                            setter(true)
                        end
                    end
                end
            })
        end

        function tab:CreateRadio(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 35 + (#options.Options * 35))
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local header = Instance.new("TextLabel")
            header.Parent = frame
            header.BackgroundTransparency = 1
            header.Position = UDim2.new(0, 10, 0, 5)
            header.Size = UDim2.new(1, -20, 0, 25)
            header.Font = font
            header.Text = options.Name
            header.TextColor3 = Color3.fromRGB(255, 255, 255)
            header.TextSize = 14
            header.TextXAlignment = Enum.TextXAlignment.Left

            local container = Instance.new("Frame")
            container.Parent = frame
            container.BackgroundTransparency = 1
            container.Position = UDim2.new(0, 0, 0, 35)
            container.Size = UDim2.new(1, 0, 1, -35)

            local layout = Instance.new("UIListLayout")
            layout.Parent = container
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 5)

            local selected = options.CurrentOption or options.Options[1]
            local radios = {}

            local function updateCallback()
                options.Callback(selected)
                if window.configFile ~= "" then saveConfig() end
            end

            for _, opt in ipairs(options.Options) do
                local itemFrame = Instance.new("Frame")
                itemFrame.Parent = container
                itemFrame.BackgroundTransparency = 1
                itemFrame.Size = UDim2.new(1, 0, 0, 30)

                local label = Instance.new("TextLabel")
                label.Parent = itemFrame
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 35, 0, 0)
                label.Size = UDim2.new(1, -45, 1, 0)
                label.Font = font
                label.Text = opt
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.TextSize = 12
                label.TextXAlignment = Enum.TextXAlignment.Left

                local outer = Instance.new("Frame")
                outer.Parent = itemFrame
                outer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                outer.Position = UDim2.new(0, 10, 0.5, -10)
                outer.Size = UDim2.new(0, 20, 0, 20)
                addCorner(outer, 20)

                local inner = Instance.new("Frame")
                inner.Parent = outer
                inner.BackgroundColor3 = (opt == selected) and accent or Color3.fromRGB(100, 100, 100)
                inner.Position = UDim2.new(0, 2, 0, 2)
                inner.Size = UDim2.new(0, 16, 0, 16)
                addCorner(inner, 16)

                local click = Instance.new("TextButton")
                click.Parent = itemFrame
                click.BackgroundTransparency = 1
                click.Size = UDim2.new(1, 0, 1, 0)
                click.Text = ""

                local function setSelected(select)
                    if select then
                        selected = opt
                        for otherOpt, otherInner in pairs(radios) do
                            otherInner.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                        end
                        inner.BackgroundColor3 = accent
                        updateCallback()
                    end
                end

                click.MouseButton1Click:Connect(function()
                    setSelected(true)
                end)

                radios[opt] = inner
            end

            for opt, inner in pairs(radios) do
                if opt == selected then
                    inner.BackgroundColor3 = accent
                end
            end

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return selected end,
                loadState = function(state)
                    selected = state
                    for opt, inner in pairs(radios) do
                        inner.BackgroundColor3 = (opt == selected) and accent or Color3.fromRGB(100, 100, 100)
                    end
                end,
                updateAccent = function(newAccent)
                    for opt, inner in pairs(radios) do
                        if opt == selected then
                            inner.BackgroundColor3 = newAccent
                        end
                    end
                end
            })
        end

        function tab:CreateProgressBar(options)
            local frame = Instance.new("Frame")
            frame.Parent = tabContent
            frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(1, -20, 0, 15)
            label.Font = font
            label.Text = options.Name
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame")
            bg.Parent = frame
            bg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            bg.Position = UDim2.new(0, 10, 0, 25)
            bg.Size = UDim2.new(1, -20, 0, 15)
            addCorner(bg, 10)

            local fill = Instance.new("Frame")
            fill.Parent = bg
            fill.BackgroundColor3 = accent
            fill.Size = UDim2.new((options.CurrentValue or 0) / 100, 0, 1, 0)
            addCorner(fill, 10)

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = bg
            valueLabel.BackgroundTransparency = 1
            valueLabel.Size = UDim2.new(1, 0, 1, 0)
            valueLabel.Font = font
            valueLabel.Text = (options.CurrentValue or 0) .. "%"
            valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            valueLabel.TextSize = 12
            valueLabel.TextStrokeTransparency = 0.5

            local function setProgress(val)
                val = math.clamp(val, 0, 100)
                fill.Size = UDim2.new(val / 100, 0, 1, 0)
                valueLabel.Text = math.floor(val) .. "%"
                if options.Callback then options.Callback(val) end
                if window.configFile ~= "" then saveConfig() end
            end

            setProgress(options.CurrentValue or 0)

            local controlId = options.Flag or options.Name
            table.insert(window.controls, {
                id = controlId,
                saveState = function() return fill.Size.X.Scale * 100 end,
                loadState = function(state) setProgress(state) end,
                updateAccent = function(newAccent) fill.BackgroundColor3 = newAccent end
            })

            return { SetValue = setProgress }
        end

        return tab
    end

    if configFile ~= "" then
        loadConfig()
    end

    return window
end

return SynergyUI
