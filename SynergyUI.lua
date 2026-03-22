local SynergyUI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

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
    return corner
end

local function createTween(instance, duration, properties)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createToast(message, duration, typeColor)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyToast_" .. HttpService:GenerateGUID(false)
    gui.Parent = getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- CORREGIDO: Antes era Global
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, 210, 0, 10)
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.AnchorPoint = Vector2.new(1, 0)
    addCorner(frame, 6)

    local indicator = Instance.new("Frame")
    indicator.Parent = frame
    indicator.BackgroundColor3 = typeColor or Color3.fromRGB(0, 255, 100)
    indicator.Size = UDim2.new(0, 4, 1, 0)
    addCorner(indicator, 6)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Font = Enum.Font.Gotham
    label.Text = message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left

    createTween(frame, 0.4, {Position = UDim2.new(1, -10, 0, 10)})
    
    task.spawn(function()
        task.wait(duration or 3)
        createTween(frame, 0.4, {Position = UDim2.new(1, 260, 0, 10)})
        task.wait(0.4)
        gui:Destroy()
    end)
end

function SynergyUI:Notify(message, duration, typeColor)
    createToast(message, duration, typeColor)
end

function SynergyUI:CreateWindow(options)
    options = options or {}
    local window = {
        Flags = {},
        Tabs = {},
        Controls = {},
        Connections = {},
        CurrentTab = nil,
        ConfigFile = options.ConfigFile or "",
        Theme = {
            Accent = options.AccentColor or Color3.fromRGB(0, 255, 100),
            Background = options.BackgroundColor or Color3.fromRGB(15, 15, 15),
            Sidebar = options.SidebarColor or Color3.fromRGB(20, 20, 20),
            Element = Color3.fromRGB(25, 25, 25),
            ElementDark = Color3.fromRGB(15, 15, 15),
            Text = Color3.fromRGB(255, 255, 255),
            TextMuted = Color3.fromRGB(180, 180, 180),
            Font = options.Font or Enum.Font.Gotham
        },
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
        IsVisible = true,
        IsMinimized = false
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyUI_" .. HttpService:GenerateGUID(false)
    gui.Parent = options.Parent or getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- CORREGIDO: Esto arregla Tabs y Dropdowns invisibles
    gui.IgnoreGuiInset = true
    window.Gui = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = gui
    mainFrame.BackgroundColor3 = window.Theme.Background
    mainFrame.BorderColor3 = window.Theme.Accent
    mainFrame.BorderSizePixel = 1
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    mainFrame.Size = UDim2.new(0, 550, 0, 350)
    mainFrame.ClipsDescendants = true
    addCorner(mainFrame, 6)
    window.MainFrame = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Parent = mainFrame
    topBar.BackgroundColor3 = window.Theme.Sidebar
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.ZIndex = 10
    addCorner(topBar, 6)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = topBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Font = window.Theme.Font
    titleLabel.Text = options.Title or "Synergy Hub"
    titleLabel.TextColor3 = window.Theme.Accent
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 10

    local controlContainer = Instance.new("Frame")
    controlContainer.Parent = topBar
    controlContainer.BackgroundTransparency = 1
    controlContainer.Position = UDim2.new(1, -70, 0, 0)
    controlContainer.Size = UDim2.new(0, 70, 1, 0)
    controlContainer.ZIndex = 10

    local minBtn = Instance.new("TextButton")
    minBtn.Parent = controlContainer
    minBtn.BackgroundTransparency = 1
    minBtn.Size = UDim2.new(0.5, 0, 1, 0)
    minBtn.Font = window.Theme.Font
    minBtn.Text = "-"
    minBtn.TextColor3 = window.Theme.Text
    minBtn.TextSize = 18
    minBtn.ZIndex = 10

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = controlContainer
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(0.5, 0, 0, 0)
    closeBtn.Size = UDim2.new(0.5, 0, 1, 0)
    closeBtn.Font = window.Theme.Font
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 10

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = mainFrame
    sidebar.BackgroundColor3 = window.Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 35)
    sidebar.Size = UDim2.new(0, 140, 1, -35)
    sidebar.ZIndex = 5

    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.Parent = sidebar
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Parent = mainFrame
    contentArea.BackgroundColor3 = window.Theme.Background
    contentArea.BorderSizePixel = 0
    contentArea.Position = UDim2.new(0, 140, 0, 35)
    contentArea.Size = UDim2.new(1, -140, 1, -35)
    contentArea.ZIndex = 1

    local resizeGrip = Instance.new("TextButton")
    resizeGrip.Name = "ResizeGrip"
    resizeGrip.Parent = mainFrame
    resizeGrip.BackgroundTransparency = 1
    resizeGrip.Position = UDim2.new(1, -15, 1, -15)
    resizeGrip.Size = UDim2.new(0, 15, 0, 15)
    resizeGrip.Text = "◢"
    resizeGrip.TextColor3 = window.Theme.TextMuted
    resizeGrip.TextSize = 10
    resizeGrip.ZIndex = 20

    local function addConnection(conn)
        table.insert(window.Connections, conn)
        return conn
    end

    local dragging = false
    local dragStart, startPos
    addConnection(topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end))

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))

    local resizing = false
    local resizeStart, startSize
    addConnection(resizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.Size
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end))

    addConnection(UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X.Offset + delta.X, 400, 1200)
            local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 250, 800)
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end))

    addConnection(minBtn.MouseButton1Click:Connect(function()
        window.IsMinimized = not window.IsMinimized
        if window.IsMinimized then
            createTween(mainFrame, 0.3, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 35)})
        else
            createTween(mainFrame, 0.3, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 350)})
        end
    end))

    addConnection(closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end))

    addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.ToggleKey then
            window.IsVisible = not window.IsVisible
            gui.Enabled = window.IsVisible
        end
    end))

    local function saveConfig()
        if window.ConfigFile == "" then return end
        local config = {
            position = {mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset},
            size = {mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, mainFrame.Size.Y.Scale, mainFrame.Size.Y.Offset},
            accent = {window.Theme.Accent.R, window.Theme.Accent.G, window.Theme.Accent.B},
            controls = {}
        }
        for _, control in ipairs(window.Controls) do
            if control.Save then
                config.controls[control.Id] = control.Save()
            end
        end
        if type(writefile) == "function" then
            writefile(window.ConfigFile, HttpService:JSONEncode(config))
        end
    end

    local function loadConfig()
        if window.ConfigFile == "" then return end
        if type(readfile) == "function" then
            local success, res = pcall(readfile, window.ConfigFile)
            if success then
                local s, decoded = pcall(HttpService.JSONDecode, HttpService, res)
                if s and decoded then
                    if decoded.position then
                        mainFrame.Position = UDim2.new(decoded.position[1], decoded.position[2], decoded.position[3], decoded.position[4])
                    end
                    if decoded.size then
                        mainFrame.Size = UDim2.new(decoded.size[1], decoded.size[2], decoded.size[3], decoded.size[4])
                    end
                    if decoded.accent then
                        window:SetAccent(Color3.new(decoded.accent[1], decoded.accent[2], decoded.accent[3]))
                    end
                    if decoded.controls then
                        for _, control in ipairs(window.Controls) do
                            if control.Load and decoded.controls[control.Id] ~= nil then
                                control.Load(decoded.controls[control.Id])
                            end
                        end
                    end
                end
            end
        end
    end

    function window:SaveConfig(filename)
        if filename then window.ConfigFile = filename end
        saveConfig()
    end

    function window:LoadConfig(filename)
        if filename then window.ConfigFile = filename end
        loadConfig()
    end

    function window:SetAccent(color)
        window.Theme.Accent = color
        mainFrame.BorderColor3 = color
        titleLabel.TextColor3 = color
        for _, tab in ipairs(window.Tabs) do
            if tab.Button.TextColor3 ~= window.Theme.TextMuted then
                tab.Button.TextColor3 = color
            end
        end
        for _, control in ipairs(window.Controls) do
            if control.UpdateTheme then control.UpdateTheme(color) end
        end
    end

    function window:Destroy()
        for _, conn in ipairs(window.Connections) do
            if conn.Connected then conn:Disconnect() end
        end
        gui:Destroy()
    end

    function window:CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Parent = sidebar
        tabBtn.BackgroundColor3 = window.Theme.Sidebar
        tabBtn.BorderSizePixel = 0
        tabBtn.Size = UDim2.new(1, 0, 0, 35)
        tabBtn.Font = window.Theme.Font
        tabBtn.Text = name
        tabBtn.TextColor3 = window.Theme.TextMuted
        tabBtn.TextSize = 13

        if icon then
            local iconLabel = Instance.new("ImageLabel")
            iconLabel.Parent = tabBtn
            iconLabel.BackgroundTransparency = 1
            iconLabel.Position = UDim2.new(0, 10, 0.5, -8)
            iconLabel.Size = UDim2.new(0, 16, 0, 16)
            iconLabel.Image = icon
            iconLabel.ImageColor3 = window.Theme.TextMuted
            tabBtn.Text = "      " .. name
            tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        else
            tabBtn.TextXAlignment = Enum.TextXAlignment.Center
        end

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Parent = contentArea
        scrollFrame.Active = true
        scrollFrame.BackgroundColor3 = window.Theme.Background
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = window.Theme.Accent
        scrollFrame.Visible = (#window.Tabs == 0)
        scrollFrame.ZIndex = 1

        local layout = Instance.new("UIListLayout")
        layout.Parent = scrollFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)

        local padding = Instance.new("UIPadding")
        padding.Parent = scrollFrame
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 15)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)

        addConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end))

        local tabData = {Button = tabBtn, Content = scrollFrame}
        table.insert(window.Tabs, tabData)

        if #window.Tabs == 1 then
            tabBtn.TextColor3 = window.Theme.Accent
            window.CurrentTab = scrollFrame
        end

        addConnection(tabBtn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window.Tabs) do
                t.Button.TextColor3 = window.Theme.TextMuted
                t.Content.Visible = false
            end
            tabBtn.TextColor3 = window.Theme.Accent
            scrollFrame.Visible = true
            window.CurrentTab = scrollFrame
        end))

        local elements = {}

        local function registerControl(id, saveFunc, loadFunc, themeFunc)
            table.insert(window.Controls, {
                Id = id,
                Save = saveFunc,
                Load = loadFunc,
                UpdateTheme = themeFunc
            })
        end

        function elements:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Parent = scrollFrame
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Font = window.Theme.Font
            label.Text = text
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function elements:CreateSeparator()
            local sep = Instance.new("Frame")
            sep.Parent = scrollFrame
            sep.BackgroundColor3 = window.Theme.ElementDark
            sep.BorderSizePixel = 0
            sep.Size = UDim2.new(1, 0, 0, 2)
            
            registerControl("sep_"..HttpService:GenerateGUID(false), nil, nil, function(color) end)
        end

        function elements:CreateButton(opts)
            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Font = window.Theme.Font
            btn.Text = opts.Name
            btn.TextColor3 = window.Theme.Text
            btn.TextSize = 13

            addConnection(btn.MouseButton1Click:Connect(function()
                local s, e = pcall(opts.Callback)
                if not s then SynergyUI:Notify("Error: " .. tostring(e), 3, Color3.fromRGB(255, 50, 50)) end
                createTween(btn, 0.1, {TextColor3 = window.Theme.Accent})
                task.wait(0.1)
                createTween(btn, 0.1, {TextColor3 = window.Theme.Text})
            end))
        end

        function elements:CreateToggle(opts)
            local state = opts.CurrentValue or false
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = state and window.Theme.Accent or window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local outer = Instance.new("Frame")
            outer.Parent = frame
            outer.BackgroundColor3 = window.Theme.ElementDark
            outer.Position = UDim2.new(1, -40, 0.5, -10)
            outer.Size = UDim2.new(0, 30, 0, 20)
            addCorner(outer, 20)

            local inner = Instance.new("Frame")
            inner.Parent = outer
            inner.BackgroundColor3 = state and window.Theme.Accent or window.Theme.TextMuted
            inner.Position = state and UDim2.new(0, 12, 0, 2) or UDim2.new(0, 2, 0, 2)
            inner.Size = UDim2.new(0, 16, 0, 16)
            addCorner(inner, 16)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            local function update(val)
                state = val
                createTween(inner, 0.2, {
                    Position = state and UDim2.new(0, 12, 0, 2) or UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = state and window.Theme.Accent or window.Theme.TextMuted
                })
                label.TextColor3 = state and window.Theme.Accent or window.Theme.Text
                pcall(opts.Callback, state)
                saveConfig()
            end

            window.Flags[flag] = {Set = function(_, v) update(v) end}
            addConnection(btn.MouseButton1Click:Connect(function() update(not state) end))
            if state then pcall(opts.Callback, state) end

            registerControl(flag, 
                function() return state end, 
                function(v) update(v) end, 
                function(c) if state then inner.BackgroundColor3 = c; label.TextColor3 = c end end
            )
        end

        function elements:CreateSlider(opts)
            local val = opts.CurrentValue or opts.Range[1]
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(0.7, 0, 0, 15)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local valLabel = Instance.new("TextLabel")
            valLabel.Parent = frame
            valLabel.BackgroundTransparency = 1
            valLabel.Position = UDim2.new(1, -60, 0, 5)
            valLabel.Size = UDim2.new(0, 50, 0, 15)
            valLabel.Font = window.Theme.Font
            valLabel.Text = tostring(val)
            valLabel.TextColor3 = window.Theme.Accent
            valLabel.TextSize = 13
            valLabel.TextXAlignment = Enum.TextXAlignment.Right

            local bg = Instance.new("Frame")
            bg.Parent = frame
            bg.BackgroundColor3 = window.Theme.ElementDark
            bg.Position = UDim2.new(0, 10, 0, 25)
            bg.Size = UDim2.new(1, -20, 0, 8)
            addCorner(bg, 8)

            local fill = Instance.new("Frame")
            fill.Parent = bg
            fill.BackgroundColor3 = window.Theme.Accent
            fill.Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)
            addCorner(fill, 8)

            local btn = Instance.new("TextButton")
            btn.Parent = bg
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            local dragging = false
            local function move(input)
                local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                local calc = opts.Range[1] + pos * (opts.Range[2] - opts.Range[1])
                local inc = opts.Increment or 1
                calc = math.floor(calc / inc + 0.5) * inc
                calc = math.clamp(calc, opts.Range[1], opts.Range[2])
                
                val = calc
                valLabel.Text = math.floor(val) == val and tostring(val) or string.format("%.2f", val)
                createTween(fill, 0.1, {Size = UDim2.new((val - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)})
                pcall(opts.Callback, val)
            end

            addConnection(btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    move(input)
                end
            end))

            addConnection(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then saveConfig() end
                    dragging = false
                end
            end))

            addConnection(UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    move(input)
                end
            end))

            registerControl(flag, 
                function() return val end, 
                function(v) 
                    val = v
                    valLabel.Text = tostring(v)
                    fill.Size = UDim2.new((v - opts.Range[1]) / (opts.Range[2] - opts.Range[1]), 0, 1, 0)
                    pcall(opts.Callback, v)
                end, 
                function(c) fill.BackgroundColor3 = c; valLabel.TextColor3 = c end
            )
        end

        function elements:CreateDropdown(opts)
            local current = opts.CurrentOption or opts.Options[1] or ""
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.Size = UDim2.new(1, -20, 0, 35)
            btn.Font = window.Theme.Font
            btn.Text = opts.Name .. " : " .. current
            btn.TextColor3 = window.Theme.Text
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left

            local icon = Instance.new("TextLabel")
            icon.Parent = btn
            icon.BackgroundTransparency = 1
            icon.Position = UDim2.new(1, -20, 0, 0)
            icon.Size = UDim2.new(0, 20, 1, 0)
            icon.Font = window.Theme.Font
            icon.Text = "+"
            icon.TextColor3 = window.Theme.TextMuted
            icon.TextSize = 14

            local container = Instance.new("ScrollingFrame")
            container.Parent = frame
            container.BackgroundColor3 = window.Theme.ElementDark
            container.BorderSizePixel = 0
            container.Position = UDim2.new(0, 0, 0, 35)
            container.Size = UDim2.new(1, 0, 1, -35)
            container.ScrollBarThickness = 2
            container.ScrollBarImageColor3 = window.Theme.Accent

            local layout = Instance.new("UIListLayout")
            layout.Parent = container
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local isOpen = false

            local function build(optionsList)
                for _, c in ipairs(container:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(optionsList) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Parent = container
                    optBtn.BackgroundColor3 = window.Theme.ElementDark
                    optBtn.BorderSizePixel = 0
                    optBtn.Size = UDim2.new(1, 0, 0, 25)
                    optBtn.Font = window.Theme.Font
                    optBtn.Text = opt
                    optBtn.TextColor3 = window.Theme.TextMuted
                    optBtn.TextSize = 12

                    addConnection(optBtn.MouseButton1Click:Connect(function()
                        current = opt
                        btn.Text = opts.Name .. " : " .. opt
                        isOpen = false
                        createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
                        icon.Text = "+"
                        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.UIListLayout.AbsoluteContentSize.Y + 20)
                        pcall(opts.Callback, opt)
                        saveConfig()
                    end))
                end
                container.CanvasSize = UDim2.new(0, 0, 0, #optionsList * 25)
            end
            build(opts.Options)

            addConnection(btn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local target = math.min(35 + (#opts.Options * 25), 135)
                    createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, target)})
                    icon.Text = "-"
                    frame.ZIndex = 5
                else
                    createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
                    icon.Text = "+"
                    frame.ZIndex = 1
                end
            end))

            registerControl(flag, 
                function() return current end, 
                function(v) 
                    current = v; btn.Text = opts.Name .. " : " .. v; pcall(opts.Callback, v) 
                end, 
                function(c) container.ScrollBarImageColor3 = c end
            )

            return {SetOptions = function(_, newOpts) opts.Options = newOpts; build(newOpts) end}
        end

        function elements:CreateTextInput(opts)
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(1, -20, 0, 15)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local input = Instance.new("TextBox")
            input.Parent = frame
            input.BackgroundColor3 = window.Theme.ElementDark
            input.Position = UDim2.new(0, 10, 0, 25)
            input.Size = UDim2.new(1, -20, 0, 15)
            input.Font = window.Theme.Font
            input.Text = opts.CurrentText or ""
            input.TextColor3 = window.Theme.TextMuted
            input.TextSize = 12
            input.PlaceholderText = opts.Placeholder or ""
            addCorner(input, 4)

            addConnection(input.FocusLost:Connect(function()
                pcall(opts.Callback, input.Text)
                saveConfig()
            end))

            registerControl(flag, 
                function() return input.Text end, 
                function(v) input.Text = v end, 
                function(c) end
            )
        end

        function elements:CreateNumberInput(opts)
            local flag = opts.Flag or opts.Name
            local currentVal = tonumber(opts.CurrentValue) or 0

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 45)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 5)
            label.Size = UDim2.new(1, -20, 0, 15)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local input = Instance.new("TextBox")
            input.Parent = frame
            input.BackgroundColor3 = window.Theme.ElementDark
            input.Position = UDim2.new(0, 10, 0, 25)
            input.Size = UDim2.new(1, -20, 0, 15)
            input.Font = window.Theme.Font
            input.Text = tostring(currentVal)
            input.TextColor3 = window.Theme.TextMuted
            input.TextSize = 12
            addCorner(input, 4)

            addConnection(input:GetPropertyChangedSignal("Text"):Connect(function()
                input.Text = input.Text:gsub("[^%d%.%-]", "")
            end))

            addConnection(input.FocusLost:Connect(function()
                local num = tonumber(input.Text)
                if num then
                    currentVal = num
                    pcall(opts.Callback, currentVal)
                    saveConfig()
                else
                    input.Text = tostring(currentVal)
                end
            end))

            registerControl(flag, 
                function() return currentVal end, 
                function(v) currentVal = tonumber(v) or 0; input.Text = tostring(currentVal) end, 
                function(c) end
            )
        end

        function elements:CreateKeybind(opts)
            local current = opts.CurrentKeybind or "None"
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 35)
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local bindBtn = Instance.new("TextButton")
            bindBtn.Parent = frame
            bindBtn.BackgroundColor3 = window.Theme.ElementDark
            bindBtn.Position = UDim2.new(1, -70, 0, 5)
            bindBtn.Size = UDim2.new(0, 60, 0, 25)
            bindBtn.Font = window.Theme.Font
            bindBtn.Text = current
            bindBtn.TextColor3 = window.Theme.Accent
            bindBtn.TextSize = 12
            addCorner(bindBtn, 4)

            local binding = false
            addConnection(bindBtn.MouseButton1Click:Connect(function()
                binding = true
                bindBtn.Text = "..."
            end))

            addConnection(UserInputService.InputBegan:Connect(function(input, gp)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType:find("MouseButton") then
                        local keyName = input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name
                        if keyName == "Escape" then keyName = "None" end
                        current = keyName
                        bindBtn.Text = current
                        binding = false
                        pcall(opts.Callback, current)
                        saveConfig()
                    end
                elseif not gp then
                    local inputName = input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name
                    if inputName == current and current ~= "None" then
                        pcall(opts.Callback, current)
                    end
                end
            end))

            registerControl(flag, 
                function() return current end, 
                function(v) current = v; bindBtn.Text = v end, 
                function(c) bindBtn.TextColor3 = c end
            )
        end

        function elements:CreateColorPicker(opts)
            local color = opts.Color or Color3.fromRGB(255, 255, 255)
            local flag = opts.Flag or opts.Name

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.Size = UDim2.new(1, 0, 0, 35)
            frame.ClipsDescendants = true
            addCorner(frame, 4)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0.7, 0, 0, 35)
            label.Font = window.Theme.Font
            label.Text = opts.Name
            label.TextColor3 = window.Theme.Text
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left

            local preview = Instance.new("Frame")
            preview.Parent = frame
            preview.BackgroundColor3 = color
            preview.Position = UDim2.new(1, -40, 0, 5)
            preview.Size = UDim2.new(0, 30, 0, 25)
            addCorner(preview, 4)

            local btn = Instance.new("TextButton")
            btn.Parent = frame
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.Text = ""

            local container = Instance.new("Frame")
            container.Parent = frame
            container.BackgroundColor3 = window.Theme.ElementDark
            container.Position = UDim2.new(0, 0, 0, 35)
            container.Size = UDim2.new(1, 0, 1, -35)

            local r, g, b = color.R, color.G, color.B
            local function update()
                local c = Color3.new(r, g, b)
                preview.BackgroundColor3 = c
                pcall(opts.Callback, c)
                saveConfig()
            end

            local function make(name, y, tint, init, cb)
                local sFrame = Instance.new("Frame")
                sFrame.Parent = container
                sFrame.BackgroundTransparency = 1
                sFrame.Position = UDim2.new(0, 0, 0, y)
                sFrame.Size = UDim2.new(1, 0, 0, 30)

                local sLbl = Instance.new("TextLabel")
                sLbl.Parent = sFrame
                sLbl.BackgroundTransparency = 1
                sLbl.Position = UDim2.new(0, 10, 0, 0)
                sLbl.Size = UDim2.new(0, 15, 1, 0)
                sLbl.Font = window.Theme.Font
                sLbl.Text = name
                sLbl.TextColor3 = tint
                sLbl.TextSize = 13

                local sBg = Instance.new("Frame")
                sBg.Parent = sFrame
                sBg.BackgroundColor3 = window.Theme.Element
                sBg.Position = UDim2.new(0, 35, 0.5, -4)
                sBg.Size = UDim2.new(1, -45, 0, 8)
                addCorner(sBg, 8)

                local sFill = Instance.new("Frame")
                sFill.Parent = sBg
                sFill.BackgroundColor3 = tint
                sFill.Size = UDim2.new(init, 0, 1, 0)
                addCorner(sFill, 8)

                local sBtn = Instance.new("TextButton")
                sBtn.Parent = sBg
                sBtn.BackgroundTransparency = 1
                sBtn.Size = UDim2.new(1, 0, 1, 0)
                sBtn.Text = ""

                local dragging = false
                addConnection(sBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                        sFill.Size = UDim2.new(pos, 0, 1, 0)
                        cb(pos)
                    end
                end))
                addConnection(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end))
                addConnection(UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                        sFill.Size = UDim2.new(pos, 0, 1, 0)
                        cb(pos)
                    end
                end))
            end

            make("R", 5, Color3.fromRGB(255, 80, 80), r, function(v) r = v update() end)
            make("G", 35, Color3.fromRGB(80, 255, 80), g, function(v) g = v update() end)
            make("B", 65, Color3.fromRGB(80, 150, 255), b, function(v) b = v update() end)

            local isOpen = false
            addConnection(btn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, isOpen and 135 or 35)})
            end))

            registerControl(flag, 
                function() return {r, g, b} end, 
                function(v) r, g, b = v[1], v[2], v[3]; update() end, 
                function(c) end
            )
        end

        function elements:CreateSection(name)
            local section = Instance.new("TextLabel")
            section.Parent = scrollFrame
            section.BackgroundTransparency = 1
            section.Size = UDim2.new(1, 0, 0, 25)
            section.Font = window.Theme.Font
            section.Text = name
            section.TextColor3 = window.Theme.Text
            section.TextSize = 14
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Center
            registerControl("section_"..HttpService:GenerateGUID(false), nil, nil, function(c) end)
        end

        function elements:CreateParagraph(opts)
            local title = opts.Title or ""
            local content = opts.Content or ""
            local imageUrl = opts.Image

            local frame = Instance.new("Frame")
            frame.Parent = scrollFrame
            frame.BackgroundColor3 = window.Theme.Element
            frame.BorderSizePixel = 0
            frame.Size = UDim2.new(1, 0, 0, 0)
            addCorner(frame, 4)

            local imageLabel = nil
            local textContainer = nil

            if imageUrl and imageUrl ~= "" then
                imageLabel = Instance.new("ImageLabel")
                imageLabel.Parent = frame
                imageLabel.BackgroundColor3 = window.Theme.ElementDark
                imageLabel.Position = UDim2.new(0, 8, 0, 8)
                imageLabel.Size = UDim2.new(0, 50, 0, 50)
                imageLabel.Image = imageUrl
                imageLabel.ScaleType = Enum.ScaleType.Fit
                addCorner(imageLabel, 4)

                textContainer = Instance.new("Frame")
                textContainer.Parent = frame
                textContainer.BackgroundTransparency = 1
                textContainer.Position = UDim2.new(0, 66, 0, 8)
                textContainer.Size = UDim2.new(1, -74, 0, 0)
            else
                textContainer = Instance.new("Frame")
                textContainer.Parent = frame
                textContainer.BackgroundTransparency = 1
                textContainer.Position = UDim2.new(0, 8, 0, 8)
                textContainer.Size = UDim2.new(1, -16, 0, 0)
            end

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Parent = textContainer
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.Font = window.Theme.Font
            titleLabel.Text = title
            titleLabel.TextColor3 = window.Theme.Accent
            titleLabel.TextSize = 14
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextYAlignment = Enum.TextYAlignment.Top
            titleLabel.TextWrapped = true

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Parent = textContainer
            contentLabel.BackgroundTransparency = 1
            contentLabel.Position = UDim2.new(0, 0, 0, 0)
            contentLabel.Size = UDim2.new(1, 0, 0, 0)
            contentLabel.Font = window.Theme.Font
            contentLabel.Text = content
            contentLabel.TextColor3 = window.Theme.TextMuted
            contentLabel.TextSize = 12
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextYAlignment = Enum.TextYAlignment.Top
            contentLabel.TextWrapped = true

            local function updateSize()
                local titleHeight = 0
                local contentHeight = 0
                if title ~= "" then
                    titleHeight = TextService:GetTextSize(title, 14, window.Theme.Font, Vector2.new(textContainer.AbsoluteSize.X, 1000)).Y
                end
                if content ~= "" then
                    contentHeight = TextService:GetTextSize(content, 12, window.Theme.Font, Vector2.new(textContainer.AbsoluteSize.X, 1000)).Y
                end
                local totalTextHeight = titleHeight + contentHeight + 8
                if imageUrl and imageUrl ~= "" then
                    totalTextHeight = math.max(totalTextHeight, 58)
                end
                titleLabel.Size = UDim2.new(1, 0, 0, titleHeight)
                contentLabel.Position = UDim2.new(0, 0, 0, titleHeight + 4)
                contentLabel.Size = UDim2.new(1, 0, 0, contentHeight)
                textContainer.Size = UDim2.new(1, textContainer.Size.X.Offset, 0, totalTextHeight)
                frame.Size = UDim2.new(1, 0, 0, totalTextHeight + 16)
            end

            frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
            titleLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
            contentLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
            if textContainer then
                textContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
            end
            updateSize()
            registerControl("paragraph_"..HttpService:GenerateGUID(false), nil, nil, function(c) end)
        end

        return elements
    end

    if window.ConfigFile ~= "" then loadConfig() end
    return window
end

return SynergyUI
