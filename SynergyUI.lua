local SynergyUI = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")

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

local function createTween(instance, duration, properties, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function snapToEdges(frame, screenSize)
    local pos = frame.Position
    local size = frame.Size
    local xOffset = pos.X.Offset
    local yOffset = pos.Y.Offset
    local xScale = pos.X.Scale
    local yScale = pos.Y.Scale
    local width = size.X.Offset
    local height = size.Y.Offset

    if xScale == 0 then
        if xOffset < 20 then
            xOffset = 0
        elseif xOffset + width > screenSize.X - 20 then
            xOffset = screenSize.X - width
        end
    else
        if xOffset + (xScale * screenSize.X) < 20 then
            xScale = 0
            xOffset = 0
        elseif xOffset + (xScale * screenSize.X) + width > screenSize.X - 20 then
            xScale = 1
            xOffset = -width
        end
    end

    if yScale == 0 then
        if yOffset < 20 then
            yOffset = 0
        elseif yOffset + height > screenSize.Y - 20 then
            yOffset = screenSize.Y - height
        end
    else
        if yOffset + (yScale * screenSize.Y) < 20 then
            yScale = 0
            yOffset = 0
        elseif yOffset + (yScale * screenSize.Y) + height > screenSize.Y - 20 then
            yScale = 1
            yOffset = -height
        end
    end

    frame.Position = UDim2.new(xScale, xOffset, yScale, yOffset)
end

local function createTooltip(parent, text, theme, delay)
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Parent = parent
    tooltip.BackgroundColor3 = theme.Background
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(0, 0, 1, 2)
    tooltip.Size = UDim2.new(0, 100, 0, 20)
    tooltip.Visible = false
    tooltip.ZIndex = 100
    addCorner(tooltip, 4)

    local label = Instance.new("TextLabel")
    label.Parent = tooltip
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = theme.Font
    label.Text = text
    label.TextColor3 = theme.Text
    label.TextSize = theme.TextSizeSmall
    label.TextWrapped = true

    local showTimer = nil
    local function show()
        if showTimer then return end
        showTimer = task.delay(delay or 0.3, function()
            local pos = parent.AbsolutePosition
            local size = parent.AbsoluteSize
            local screenSize = parent.AbsoluteSize
            tooltip.Size = UDim2.new(0, label.TextBounds.X + 10, 0, label.TextBounds.Y + 4)
            local x = pos.X + size.X / 2 - tooltip.AbsoluteSize.X / 2
            local y = pos.Y + size.Y + 5
            if y + tooltip.AbsoluteSize.Y > screenSize.Y then
                y = pos.Y - tooltip.AbsoluteSize.Y - 5
            end
            tooltip.Position = UDim2.new(0, x, 0, y)
            tooltip.Visible = true
        end)
    end

    local function hide()
        if showTimer then
            task.cancel(showTimer)
            showTimer = nil
        end
        tooltip.Visible = false
    end

    parent.MouseEnter:Connect(show)
    parent.MouseLeave:Connect(hide)
    return tooltip
end

local function errorHandler(callback, context)
    local success, err = pcall(callback)
    if not success then
        SynergyUI:Notify({
            Title = "Error",
            Message = tostring(err),
            Duration = 4,
            TypeColor = Color3.fromRGB(255, 50, 50),
            Icon = "rbxassetid://123456789"
        })
        if context and context.debug then
            warn("Error in " .. context .. ": " .. tostring(err))
        end
    end
    return success, err
end

local NotificationQueue = {}
local function showNextNotification()
    if #NotificationQueue == 0 then return end
    local notification = NotificationQueue[1]
    table.remove(NotificationQueue, 1)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyToast_" .. HttpService:GenerateGUID(false)
    gui.Parent = notification.Parent or getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    local pos = notification.Position or "TopRight"
    if pos == "TopRight" then
        frame.Position = UDim2.new(1, 210, 0, 10)
        frame.AnchorPoint = Vector2.new(1, 0)
    elseif pos == "TopLeft" then
        frame.Position = UDim2.new(0, -210, 0, 10)
        frame.AnchorPoint = Vector2.new(0, 0)
    elseif pos == "BottomRight" then
        frame.Position = UDim2.new(1, 210, 1, -60)
        frame.AnchorPoint = Vector2.new(1, 1)
    elseif pos == "BottomLeft" then
        frame.Position = UDim2.new(0, -210, 1, -60)
        frame.AnchorPoint = Vector2.new(0, 1)
    end
    frame.Size = UDim2.new(0, 250, 0, 50)
    addCorner(frame, 6)

    local indicator = Instance.new("Frame")
    indicator.Parent = frame
    indicator.BackgroundColor3 = notification.TypeColor or Color3.fromRGB(0, 255, 100)
    indicator.Size = UDim2.new(0, 4, 1, 0)
    addCorner(indicator, 6)

    if notification.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Parent = frame
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 8, 0.5, -10)
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Image = notification.Icon
        icon.ImageColor3 = notification.TypeColor or Color3.fromRGB(255, 255, 255)
    end

    local title = nil
    if notification.Title then
        title = Instance.new("TextLabel")
        title.Parent = frame
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 15, 0, 5)
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Font = Enum.Font.GothamBold
        title.Text = notification.Title
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
    end

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    if title then
        label.Position = UDim2.new(0, 15, 0, 25)
        label.Size = UDim2.new(1, -20, 1, -30)
    else
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Size = UDim2.new(1, -20, 1, 0)
    end
    label.Font = Enum.Font.Gotham
    label.Text = notification.Message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left

    if notification.Buttons then
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Parent = frame
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Position = UDim2.new(0, 0, 1, -30)
        buttonContainer.Size = UDim2.new(1, 0, 0, 30)
        local layout = Instance.new("UIListLayout")
        layout.Parent = buttonContainer
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.Padding = UDim.new(0, 8)

        for _, btn in ipairs(notification.Buttons) do
            local button = Instance.new("TextButton")
            button.Parent = buttonContainer
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.BorderSizePixel = 0
            button.Size = UDim2.new(0, 60, 0, 25)
            button.Font = Enum.Font.Gotham
            button.Text = btn.Text
            button.TextColor3 = btn.TextColor or Color3.fromRGB(255, 255, 255)
            button.TextSize = 12
            addCorner(button, 4)
            button.MouseButton1Click:Connect(function()
                if btn.Callback then errorHandler(btn.Callback, "NotificationButton") end
                gui:Destroy()
                showNextNotification()
            end)
        end
        frame.Size = UDim2.new(0, 250, 0, 85)
    end

    local targetPos
    if pos == "TopRight" then
        targetPos = UDim2.new(1, -10, 0, 10)
    elseif pos == "TopLeft" then
        targetPos = UDim2.new(0, 10, 0, 10)
    elseif pos == "BottomRight" then
        targetPos = UDim2.new(1, -10, 1, -60)
    else
        targetPos = UDim2.new(0, 10, 1, -60)
    end
    createTween(frame, 0.4, {Position = targetPos})

    task.spawn(function()
        task.wait(notification.Duration or 3)
        local exitPos
        if pos == "TopRight" then
            exitPos = UDim2.new(1, 260, 0, 10)
        elseif pos == "TopLeft" then
            exitPos = UDim2.new(0, -260, 0, 10)
        elseif pos == "BottomRight" then
            exitPos = UDim2.new(1, 260, 1, -60)
        else
            exitPos = UDim2.new(0, -260, 1, -60)
        end
        createTween(frame, 0.4, {Position = exitPos})
        task.wait(0.4)
        gui:Destroy()
        showNextNotification()
    end)
end

function SynergyUI:Notify(options)
    if type(options) == "string" then
        options = {Message = options, Duration = 3, TypeColor = Color3.fromRGB(0, 255, 100), Position = "TopRight"}
    end
    table.insert(NotificationQueue, options)
    if #NotificationQueue == 1 then
        showNextNotification()
    end
end

local ControlFactory = {}
function ControlFactory:new(parent, theme, saveCallback, loadCallback, updateThemeCallback, window)
    local obj = {}
    obj.parent = parent
    obj.theme = theme
    obj.save = saveCallback
    obj.load = loadCallback
    obj.updateTheme = updateThemeCallback
    obj.window = window
    obj.connections = {}
    obj.controls = {}
    return obj
end

function ControlFactory:createLabel(text)
    local label = Instance.new("TextLabel")
    label.Parent = self.parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, self.theme.LabelHeight)
    label.Font = self.theme.Font
    label.Text = text
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

function ControlFactory:createSeparator()
    local sep = Instance.new("Frame")
    sep.Parent = self.parent
    sep.BackgroundColor3 = self.theme.ElementDark
    sep.BorderSizePixel = 0
    sep.Size = UDim2.new(1, 0, 0, 2)
    return sep
end

function ControlFactory:createButton(options)
    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.ButtonHeight)
    addCorner(frame, self.theme.CornerRadius)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = self.theme.Font
    btn.Text = options.Name
    btn.TextColor3 = self.theme.Text
    btn.TextSize = self.theme.TextSizeNormal

    local connection
    connection = btn.MouseButton1Click:Connect(function()
        errorHandler(options.Callback, "Button:" .. options.Name)
        createTween(btn, 0.1, {TextColor3 = self.theme.Accent})
        task.wait(0.1)
        createTween(btn, 0.1, {TextColor3 = self.theme.Text})
    end)

    if options.Tooltip then
        createTooltip(btn, options.Tooltip, self.theme, self.theme.TooltipDelay)
    end

    return frame, connection
end

function ControlFactory:createToggle(options)
    local state = options.CurrentValue or false
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.ToggleHeight)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = state and self.theme.Accent or self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local outer = Instance.new("Frame")
    outer.Parent = frame
    outer.BackgroundColor3 = self.theme.ElementDark
    outer.Position = UDim2.new(1, -self.theme.ToggleWidth - self.theme.PaddingHorizontal, 0.5, -self.theme.ToggleHeight/2)
    outer.Size = UDim2.new(0, self.theme.ToggleWidth, 0, self.theme.ToggleHeight)
    addCorner(outer, self.theme.ToggleHeight)

    local inner = Instance.new("Frame")
    inner.Parent = outer
    inner.BackgroundColor3 = state and self.theme.Accent or self.theme.TextMuted
    local innerSize = self.theme.ToggleHeight - 4
    inner.Position = state and UDim2.new(0, self.theme.ToggleWidth - innerSize - 2, 0, 2) or UDim2.new(0, 2, 0, 2)
    inner.Size = UDim2.new(0, innerSize, 0, innerSize)
    addCorner(inner, innerSize)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""

    local function update(val)
        state = val
        createTween(inner, 0.2, {
            Position = state and UDim2.new(0, self.theme.ToggleWidth - innerSize - 2, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = state and self.theme.Accent or self.theme.TextMuted
        })
        label.TextColor3 = state and self.theme.Accent or self.theme.Text
        errorHandler(function() options.Callback(state) end, "Toggle:" .. options.Name)
        self.save()
    end

    self.controls[flag] = {Set = function(_, v) update(v) end}
    local connection = btn.MouseButton1Click:Connect(function() update(not state) end)
    if state then errorHandler(function() options.Callback(state) end, "Toggle:" .. options.Name) end

    if options.Tooltip then
        createTooltip(btn, options.Tooltip, self.theme, self.theme.TooltipDelay)
    end

    self.window:registerControl(flag,
        function() return state end,
        function(v) update(v) end,
        function(c)
            if state then
                inner.BackgroundColor3 = c
                label.TextColor3 = c
            end
        end
    )
    return frame, connection
end

function ControlFactory:createSlider(options)
    local val = options.CurrentValue or options.Range[1]
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.SliderHeight)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(0.7, 0, 0, self.theme.TextSizeNormal + 4)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel")
    valLabel.Parent = frame
    valLabel.BackgroundTransparency = 1
    valLabel.Position = UDim2.new(1, -60 - self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    valLabel.Size = UDim2.new(0, 50, 0, self.theme.TextSizeNormal + 4)
    valLabel.Font = self.theme.Font
    valLabel.Text = tostring(val)
    valLabel.TextColor3 = self.theme.Accent
    valLabel.TextSize = self.theme.TextSizeNormal
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bg = Instance.new("Frame")
    bg.Parent = frame
    bg.BackgroundColor3 = self.theme.ElementDark
    bg.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 4)
    bg.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.SliderBarHeight)
    addCorner(bg, self.theme.SliderBarHeight/2)

    local fill = Instance.new("Frame")
    fill.Parent = bg
    fill.BackgroundColor3 = self.theme.Accent
    fill.Size = UDim2.new((val - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0)
    addCorner(fill, self.theme.SliderBarHeight/2)

    local inputBg = Instance.new("Frame")
    inputBg.Parent = frame
    inputBg.BackgroundColor3 = self.theme.ElementDark
    inputBg.Position = UDim2.new(1, -70 - self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 4)
    inputBg.Size = UDim2.new(0, 60, 0, self.theme.SliderBarHeight)
    addCorner(inputBg, 4)

    local numInput = Instance.new("TextBox")
    numInput.Parent = inputBg
    numInput.BackgroundTransparency = 1
    numInput.Size = UDim2.new(1, 0, 1, 0)
    numInput.Font = self.theme.Font
    numInput.Text = tostring(val)
    numInput.TextColor3 = self.theme.Text
    numInput.TextSize = self.theme.TextSizeSmall
    numInput.TextXAlignment = Enum.TextXAlignment.Center

    numInput:GetPropertyChangedSignal("Text"):Connect(function()
        numInput.Text = numInput.Text:gsub("[^%d%.%-]", "")
    end)

    local decrement = Instance.new("TextButton")
    decrement.Parent = frame
    decrement.BackgroundColor3 = self.theme.ElementDark
    decrement.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 4)
    decrement.Size = UDim2.new(0, 25, 0, self.theme.SliderBarHeight)
    decrement.Font = self.theme.Font
    decrement.Text = "-"
    decrement.TextColor3 = self.theme.Text
    decrement.TextSize = 18
    addCorner(decrement, self.theme.SliderBarHeight/2)

    local increment = Instance.new("TextButton")
    increment.Parent = frame
    increment.BackgroundColor3 = self.theme.ElementDark
    increment.Position = UDim2.new(1, -self.theme.PaddingHorizontal - 25, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 4)
    increment.Size = UDim2.new(0, 25, 0, self.theme.SliderBarHeight)
    increment.Font = self.theme.Font
    increment.Text = "+"
    increment.TextColor3 = self.theme.Text
    increment.TextSize = 18
    addCorner(increment, self.theme.SliderBarHeight/2)

    local function setValue(newVal)
        local inc = options.Increment or 1
        newVal = math.floor(newVal / inc + 0.5) * inc
        newVal = math.clamp(newVal, options.Range[1], options.Range[2])
        val = newVal
        valLabel.Text = math.floor(val) == val and tostring(val) or string.format("%.2f", val)
        numInput.Text = valLabel.Text
        fill.Size = UDim2.new((val - options.Range[1]) / (options.Range[2] - options.Range[1]), 0, 1, 0)
        errorHandler(function() options.Callback(val) end, "Slider:" .. options.Name)
        self.save()
    end

    decrement.MouseButton1Click:Connect(function()
        setValue(val - (options.Increment or 1))
    end)

    increment.MouseButton1Click:Connect(function()
        setValue(val + (options.Increment or 1))
    end)

    local dragging = false
    local function move(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local calc = options.Range[1] + pos * (options.Range[2] - options.Range[1])
        setValue(calc)
    end

    local btn = Instance.new("TextButton")
    btn.Parent = bg
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = ""

    local connection1 = btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            move(input)
        end
    end)

    local connection2 = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local connection3 = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            move(input)
        end
    end)

    local connection4 = numInput.FocusLost:Connect(function()
        local newVal = tonumber(numInput.Text)
        if newVal then
            setValue(newVal)
        else
            numInput.Text = tostring(val)
        end
    end)

    self.window:registerControl(flag,
        function() return val end,
        function(v) setValue(v) end,
        function(c)
            fill.BackgroundColor3 = c
            valLabel.TextColor3 = c
        end
    )
    return frame, {connection1, connection2, connection3, connection4}
end

function ControlFactory:createDropdown(options)
    local current = options.CurrentOption or options.Options[1] or ""
    local optionsList = options.Options or {}
    local flag = options.Flag or options.Name
    local dropdown = {}

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.DropdownHeight)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
    btn.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.DropdownHeight)
    btn.Font = self.theme.Font
    btn.Text = options.Name .. " : " .. current
    btn.TextColor3 = self.theme.Text
    btn.TextSize = self.theme.TextSizeNormal
    btn.TextXAlignment = Enum.TextXAlignment.Left

    local icon = Instance.new("TextLabel")
    icon.Parent = btn
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(1, -20, 0, 0)
    icon.Size = UDim2.new(0, 20, 1, 0)
    icon.Font = self.theme.Font
    icon.Text = "+"
    icon.TextColor3 = self.theme.TextMuted
    icon.TextSize = self.theme.TextSizeNormal

    local container = Instance.new("ScrollingFrame")
    container.Parent = frame
    container.BackgroundColor3 = self.theme.ElementDark
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, self.theme.DropdownHeight)
    container.Size = UDim2.new(1, 0, 1, -self.theme.DropdownHeight)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = self.theme.Accent

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local isOpen = false
    local optionButtons = {}

    local function updateButtonText()
        if current == "" then
            btn.Text = options.Name .. " : " .. "None"
        else
            btn.Text = options.Name .. " : " .. current
        end
    end

    local function rebuild()
        for _, btn in ipairs(optionButtons) do
            if btn and btn.Parent then btn:Destroy() end
        end
        optionButtons = {}
        for i, opt in ipairs(optionsList) do
            local optBtn = Instance.new("TextButton")
            optBtn.Parent = container
            optBtn.BackgroundColor3 = self.theme.ElementDark
            optBtn.BorderSizePixel = 0
            optBtn.Size = UDim2.new(1, 0, 0, self.theme.DropdownItemHeight)
            optBtn.Font = self.theme.Font
            optBtn.Text = opt
            optBtn.TextColor3 = self.theme.TextMuted
            optBtn.TextSize = self.theme.TextSizeSmall

            local connection = optBtn.MouseButton1Click:Connect(function()
                current = opt
                updateButtonText()
                isOpen = false
                createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, self.theme.DropdownHeight)})
                icon.Text = "+"
                errorHandler(function() options.Callback(opt) end, "Dropdown:" .. options.Name)
                self.save()
            end)
            table.insert(optionButtons, optBtn)
        end
        container.CanvasSize = UDim2.new(0, 0, 0, #optionsList * self.theme.DropdownItemHeight)
    end
    rebuild()

    local connection = btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local target = self.theme.DropdownHeight + math.min(#optionsList * self.theme.DropdownItemHeight, 150)
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, target)})
            icon.Text = "-"
        else
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, self.theme.DropdownHeight)})
            icon.Text = "+"
        end
    end)

    if options.Tooltip then
        createTooltip(btn, options.Tooltip, self.theme, self.theme.TooltipDelay)
    end

    self.window:registerControl(flag,
        function() return current end,
        function(v)
            current = v
            updateButtonText()
            errorHandler(function() options.Callback(v) end, "Dropdown:" .. options.Name)
        end,
        function(c)
            container.ScrollBarImageColor3 = c
        end
    )

    dropdown.SetOptions = function(_, newOpts)
        optionsList = newOpts
        rebuild()
        if not table.find(optionsList, current) then
            current = ""
            updateButtonText()
            errorHandler(function() options.Callback("") end, "Dropdown:" .. options.Name)
        end
    end

    dropdown.SetValue = function(_, val)
        if table.find(optionsList, val) or val == "" then
            current = val
            updateButtonText()
            errorHandler(function() options.Callback(val) end, "Dropdown:" .. options.Name)
            self.save()
        end
    end

    dropdown.GetValue = function()
        return current
    end

    return frame, connection
end

function ControlFactory:createChecklist(options)
    local optionsList = options.Options or {}
    local selected = {}
    if options.CurrentSelected then
        for _, v in ipairs(options.CurrentSelected) do
            selected[v] = true
        end
    end
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.ChecklistHeight)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
    btn.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.ChecklistHeight)
    btn.Font = self.theme.Font
    btn.Text = options.Name
    btn.TextColor3 = self.theme.Text
    btn.TextSize = self.theme.TextSizeNormal
    btn.TextXAlignment = Enum.TextXAlignment.Left

    local countLabel = Instance.new("TextLabel")
    countLabel.Parent = btn
    countLabel.BackgroundTransparency = 1
    countLabel.Position = UDim2.new(1, -60, 0, 0)
    countLabel.Size = UDim2.new(0, 50, 1, 0)
    countLabel.Font = self.theme.Font
    countLabel.Text = "0 selected"
    countLabel.TextColor3 = self.theme.Accent
    countLabel.TextSize = self.theme.TextSizeSmall
    countLabel.TextXAlignment = Enum.TextXAlignment.Right

    local icon = Instance.new("TextLabel")
    icon.Parent = btn
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(1, -20, 0, 0)
    icon.Size = UDim2.new(0, 20, 1, 0)
    icon.Font = self.theme.Font
    icon.Text = "+"
    icon.TextColor3 = self.theme.TextMuted
    icon.TextSize = self.theme.TextSizeNormal

    local container = Instance.new("ScrollingFrame")
    container.Parent = frame
    container.BackgroundColor3 = self.theme.ElementDark
    container.BorderSizePixel = 0
    container.Position = UDim2.new(0, 0, 0, self.theme.ChecklistHeight)
    container.Size = UDim2.new(1, 0, 1, -self.theme.ChecklistHeight)
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = self.theme.Accent

    local layout = Instance.new("UIListLayout")
    layout.Parent = container
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateSelectedCount()
        local count = 0
        for _, v in pairs(selected) do if v then count = count + 1 end end
        countLabel.Text = count .. " selected"
        errorHandler(function() options.Callback(selected) end, "Checklist:" .. options.Name)
        self.save()
    end

    local function rebuild()
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for _, opt in ipairs(optionsList) do
            local row = Instance.new("Frame")
            row.Parent = container
            row.BackgroundColor3 = self.theme.ElementDark
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, self.theme.ChecklistItemHeight)

            local outer = Instance.new("Frame")
            outer.Parent = row
            outer.BackgroundColor3 = self.theme.Element
            outer.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0.5, -self.theme.ChecklistItemHeight/2)
            outer.Size = UDim2.new(0, self.theme.ToggleWidth, 0, self.theme.ToggleHeight)
            addCorner(outer, self.theme.ToggleHeight)

            local inner = Instance.new("Frame")
            inner.Parent = outer
            inner.BackgroundColor3 = selected[opt] and self.theme.Accent or self.theme.TextMuted
            local innerSize = self.theme.ToggleHeight - 4
            inner.Position = selected[opt] and UDim2.new(0, self.theme.ToggleWidth - innerSize - 2, 0, 2) or UDim2.new(0, 2, 0, 2)
            inner.Size = UDim2.new(0, innerSize, 0, innerSize)
            addCorner(inner, innerSize)

            local optLabel = Instance.new("TextLabel")
            optLabel.Parent = row
            optLabel.BackgroundTransparency = 1
            optLabel.Position = UDim2.new(0, self.theme.PaddingHorizontal + self.theme.ToggleWidth + 8, 0, 0)
            optLabel.Size = UDim2.new(1, -self.theme.PaddingHorizontal - self.theme.ToggleWidth - 8, 1, 0)
            optLabel.Font = self.theme.Font
            optLabel.Text = opt
            optLabel.TextColor3 = self.theme.TextMuted
            optLabel.TextSize = self.theme.TextSizeSmall
            optLabel.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            local connection = btn.MouseButton1Click:Connect(function()
                selected[opt] = not selected[opt]
                createTween(inner, 0.2, {
                    Position = selected[opt] and UDim2.new(0, self.theme.ToggleWidth - innerSize - 2, 0, 2) or UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = selected[opt] and self.theme.Accent or self.theme.TextMuted
                })
                updateSelectedCount()
            end)
        end
        container.CanvasSize = UDim2.new(0, 0, 0, #optionsList * self.theme.ChecklistItemHeight)
        updateSelectedCount()
    end
    rebuild()

    local isOpen = false
    local connection = btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local target = self.theme.ChecklistHeight + math.min(#optionsList * self.theme.ChecklistItemHeight, 200)
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, target)})
            icon.Text = "-"
        else
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, self.theme.ChecklistHeight)})
            icon.Text = "+"
        end
    end)

    local function getSelectedTable()
        local result = {}
        for k, v in pairs(selected) do if v then table.insert(result, k) end end
        return result
    end

    local function setSelectedTable(tbl)
        for _, v in ipairs(optionsList) do selected[v] = false end
        for _, v in ipairs(tbl) do
            if selected[v] ~= nil then selected[v] = true end
        end
        rebuild()
    end

    self.window:registerControl(flag,
        function() return getSelectedTable() end,
        function(v) setSelectedTable(v) end,
        function(c)
            container.ScrollBarImageColor3 = c
            for _, row in ipairs(container:GetChildren()) do
                if row:IsA("Frame") then
                    local inner = row:FindFirstChild("Outer") and row.Outer:FindFirstChild("Inner")
                    if inner and selected[row.Text] then
                        inner.BackgroundColor3 = c
                    end
                end
            end
            countLabel.TextColor3 = c
        end
    )

    return {
        SetOptions = function(_, newOpts)
            optionsList = newOpts
            local newSelected = {}
            for _, v in ipairs(optionsList) do
                if selected[v] then newSelected[v] = true end
            end
            selected = newSelected
            rebuild()
        end,
        GetSelected = function() return getSelectedTable() end,
        SetSelected = function(_, tbl) setSelectedTable(tbl) end
    }, connection
end

function ControlFactory:createTextInput(options)
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.TextInputHeight)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.TextSizeNormal + 4)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox")
    input.Parent = frame
    input.BackgroundColor3 = self.theme.ElementDark
    input.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 8)
    input.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.TextInputFieldHeight)
    input.Font = self.theme.Font
    input.Text = options.CurrentText or ""
    input.TextColor3 = self.theme.TextMuted
    input.TextSize = self.theme.TextSizeSmall
    input.PlaceholderText = options.Placeholder or ""
    addCorner(input, self.theme.CornerRadius)

    local connection = input.FocusLost:Connect(function()
        errorHandler(function() options.Callback(input.Text) end, "TextInput:" .. options.Name)
        self.save()
    end)

    if options.Tooltip then
        createTooltip(input, options.Tooltip, self.theme, self.theme.TooltipDelay)
    end

    self.window:registerControl(flag,
        function() return input.Text end,
        function(v) input.Text = v end,
        function(c) end
    )
    return frame, connection
end

function ControlFactory:createNumberInput(options)
    local flag = options.Flag or options.Name
    local currentVal = tonumber(options.CurrentValue) or 0

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.TextInputHeight)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.TextSizeNormal + 4)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox")
    input.Parent = frame
    input.BackgroundColor3 = self.theme.ElementDark
    input.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + self.theme.TextSizeNormal + 8)
    input.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, self.theme.TextInputFieldHeight)
    input.Font = self.theme.Font
    input.Text = tostring(currentVal)
    input.TextColor3 = self.theme.TextMuted
    input.TextSize = self.theme.TextSizeSmall
    addCorner(input, self.theme.CornerRadius)

    input:GetPropertyChangedSignal("Text"):Connect(function()
        input.Text = input.Text:gsub("[^%d%.%-]", "")
    end)

    local connection = input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            currentVal = num
            errorHandler(function() options.Callback(currentVal) end, "NumberInput:" .. options.Name)
            self.save()
        else
            input.Text = tostring(currentVal)
        end
    end)

    self.window:registerControl(flag,
        function() return currentVal end,
        function(v) currentVal = tonumber(v) or 0; input.Text = tostring(currentVal) end,
        function(c) end
    )
    return frame, connection
end

function ControlFactory:createKeybind(options)
    local current = options.CurrentKeybind or "None"
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.KeybindHeight)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bindBtn = Instance.new("TextButton")
    bindBtn.Parent = frame
    bindBtn.BackgroundColor3 = self.theme.ElementDark
    bindBtn.Position = UDim2.new(1, -self.theme.KeybindWidth - self.theme.PaddingHorizontal, 0.5, -self.theme.KeybindHeight/2)
    bindBtn.Size = UDim2.new(0, self.theme.KeybindWidth, 0, self.theme.KeybindHeight)
    bindBtn.Font = self.theme.Font
    bindBtn.Text = current
    bindBtn.TextColor3 = self.theme.Accent
    bindBtn.TextSize = self.theme.TextSizeSmall
    addCorner(bindBtn, self.theme.CornerRadius)

    local function formatKeybind(key, modifiers)
        local parts = {}
        if modifiers then
            if modifiers.Ctrl then table.insert(parts, "Ctrl") end
            if modifiers.Shift then table.insert(parts, "Shift") end
            if modifiers.Alt then table.insert(parts, "Alt") end
        end
        if key and key ~= "None" then table.insert(parts, key) end
        return table.concat(parts, " + ")
    end

    local binding = false
    local modifiers = {Ctrl = false, Shift = false, Alt = false}
    local connection1 = bindBtn.MouseButton1Click:Connect(function()
        binding = true
        bindBtn.Text = "..."
    end)

    local connection2 = UserInputService.InputBegan:Connect(function(input, gp)
        if binding then
            if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType:FindFirstChild("MouseButton") then
                local keyName = input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name
                if keyName == "Escape" then
                    keyName = "None"
                    modifiers = {Ctrl = false, Shift = false, Alt = false}
                else
                    modifiers.Ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                    modifiers.Shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
                    modifiers.Alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)
                end
                current = formatKeybind(keyName, modifiers)
                bindBtn.Text = current
                binding = false
                errorHandler(function() options.Callback(current) end, "Keybind:" .. options.Name)
                self.save()
            end
        elseif not gp and GuiService.SelectedObject == nil then
            local keyName = input.KeyCode.Name ~= "Unknown" and input.KeyCode.Name or input.UserInputType.Name
            if current == formatKeybind(keyName, {Ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl), Shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift), Alt = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)}) and current ~= "None" then
                errorHandler(function() options.Callback(current) end, "Keybind:" .. options.Name)
            end
        end
    end)

    self.window:registerControl(flag,
        function() return current end,
        function(v) current = v; bindBtn.Text = v end,
        function(c) bindBtn.TextColor3 = c end
    )
    return frame, {connection1, connection2}
end

function ControlFactory:createColorPicker(options)
    local color = options.Color or Color3.fromRGB(255, 255, 255)
    local flag = options.Flag or options.Name
    local r, g, b = color.R, color.G, color.B
    local h, s, v = Color3.toHSV(color)

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, self.theme.ColorPickerHeight)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
    label.Size = UDim2.new(0.7, 0, 0, self.theme.ColorPickerHeight)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame")
    preview.Parent = frame
    preview.BackgroundColor3 = color
    preview.Position = UDim2.new(1, -self.theme.ColorPickerPreviewSize - self.theme.PaddingHorizontal, 0.5, -self.theme.ColorPickerPreviewSize/2)
    preview.Size = UDim2.new(0, self.theme.ColorPickerPreviewSize, 0, self.theme.ColorPickerPreviewSize)
    addCorner(preview, self.theme.CornerRadius)

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 0, self.theme.ColorPickerHeight)
    btn.Text = ""

    local container = Instance.new("Frame")
    container.Parent = frame
    container.BackgroundColor3 = self.theme.ElementDark
    container.Position = UDim2.new(0, 0, 0, self.theme.ColorPickerHeight)
    container.Size = UDim2.new(1, 0, 1, -self.theme.ColorPickerHeight)

    local hexInput = Instance.new("TextBox")
    hexInput.Parent = container
    hexInput.BackgroundColor3 = self.theme.Element
    hexInput.Position = UDim2.new(1, -110 - self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    hexInput.Size = UDim2.new(0, 100, 0, 25)
    hexInput.Font = self.theme.Font
    hexInput.Text = string.format("#%02X%02X%02X", r*255, g*255, b*255)
    hexInput.TextColor3 = self.theme.Text
    hexInput.TextSize = self.theme.TextSizeSmall
    addCorner(hexInput, 4)

    local function updateColor()
        local c = Color3.new(r, g, b)
        preview.BackgroundColor3 = c
        hexInput.Text = string.format("#%02X%02X%02X", r*255, g*255, b*255)
        errorHandler(function() options.Callback(c) end, "ColorPicker:" .. options.Name)
        self.save()
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
        sLbl.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 0)
        sLbl.Size = UDim2.new(0, 15, 1, 0)
        sLbl.Font = self.theme.Font
        sLbl.Text = name
        sLbl.TextColor3 = tint
        sLbl.TextSize = self.theme.TextSizeSmall

        local sBg = Instance.new("Frame")
        sBg.Parent = sFrame
        sBg.BackgroundColor3 = self.theme.Element
        sBg.Position = UDim2.new(0, 35, 0.5, -4)
        sBg.Size = UDim2.new(1, -self.theme.PaddingHorizontal - 35, 0, 8)
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
        local connection1 = sBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                sFill.Size = UDim2.new(pos, 0, 1, 0)
                cb(pos)
            end
        end)
        local connection2 = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        local connection3 = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pos = math.clamp((input.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                sFill.Size = UDim2.new(pos, 0, 1, 0)
                cb(pos)
            end
        end)
        table.insert(self.connections, connection1)
        table.insert(self.connections, connection2)
        table.insert(self.connections, connection3)
    end

    make("R", 5, Color3.fromRGB(255, 80, 80), r, function(v) r = v updateColor() end)
    make("G", 35, Color3.fromRGB(80, 255, 80), g, function(v) g = v updateColor() end)
    make("B", 65, Color3.fromRGB(80, 150, 255), b, function(v) b = v updateColor() end)

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            r = tonumber(hex:sub(1,2), 16) / 255
            g = tonumber(hex:sub(3,4), 16) / 255
            b = tonumber(hex:sub(5,6), 16) / 255
            updateColor()
        end
    end)

    local isOpen = false
    local connection = btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, isOpen and self.theme.ColorPickerExpandedHeight or self.theme.ColorPickerHeight)})
    end)

    self.window:registerControl(flag,
        function() return {r, g, b} end,
        function(v) r, g, b = v[1], v[2], v[3]; updateColor() end,
        function(c) end
    )
    return frame, connection
end

function ControlFactory:createRadioGroup(options)
    local selected = options.CurrentValue or options.Options[1] or ""
    local flag = options.Flag or options.Name
    local group = {}

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, #options.Options * self.theme.RadioItemHeight + 8)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, 4)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 20)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local layout = Instance.new("UIListLayout")
    layout.Parent = frame
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local radioButtons = {}
    local function update(opt)
        selected = opt
        for _, btn in ipairs(radioButtons) do
            if btn.Option == opt then
                btn.Inner.BackgroundColor3 = self.theme.Accent
            else
                btn.Inner.BackgroundColor3 = self.theme.TextMuted
            end
        end
        errorHandler(function() options.Callback(selected) end, "RadioGroup:" .. options.Name)
        self.save()
    end

    for i, opt in ipairs(options.Options) do
        local row = Instance.new("Frame")
        row.Parent = frame
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, self.theme.RadioItemHeight)

        local outer = Instance.new("Frame")
        outer.Parent = row
        outer.BackgroundColor3 = self.theme.ElementDark
        outer.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0.5, -self.theme.RadioItemHeight/2)
        outer.Size = UDim2.new(0, self.theme.ToggleWidth, 0, self.theme.ToggleHeight)
        addCorner(outer, self.theme.ToggleHeight)

        local inner = Instance.new("Frame")
        inner.Parent = outer
        inner.BackgroundColor3 = (opt == selected) and self.theme.Accent or self.theme.TextMuted
        local innerSize = self.theme.ToggleHeight - 4
        inner.Position = UDim2.new(0, 2, 0, 2)
        inner.Size = UDim2.new(0, innerSize, 0, innerSize)
        addCorner(inner, innerSize)

        local optLabel = Instance.new("TextLabel")
        optLabel.Parent = row
        optLabel.BackgroundTransparency = 1
        optLabel.Position = UDim2.new(0, self.theme.PaddingHorizontal + self.theme.ToggleWidth + 8, 0, 0)
        optLabel.Size = UDim2.new(1, -self.theme.PaddingHorizontal - self.theme.ToggleWidth - 8, 1, 0)
        optLabel.Font = self.theme.Font
        optLabel.Text = opt
        optLabel.TextColor3 = self.theme.TextMuted
        optLabel.TextSize = self.theme.TextSizeSmall
        optLabel.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton")
        btn.Parent = row
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Text = ""

        local connection = btn.MouseButton1Click:Connect(function()
            if opt ~= selected then
                update(opt)
            end
        end)

        table.insert(radioButtons, {Option = opt, Inner = inner, Btn = btn})
    end

    self.window:registerControl(flag,
        function() return selected end,
        function(v) if table.find(options.Options, v) then update(v) end end,
        function(c)
            for _, btn in ipairs(radioButtons) do
                if btn.Option == selected then
                    btn.Inner.BackgroundColor3 = c
                end
            end
        end
    )
    return frame, nil
end

function ControlFactory:createListBox(options)
    local items = options.Items or {}
    local multiselect = options.MultiSelect or false
    local selected = {}
    if options.Selected then
        if multiselect then
            for _, v in ipairs(options.Selected) do selected[v] = true end
        else
            selected[options.Selected] = true
        end
    end
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, options.Height or 150)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 20)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = frame
    scroll.BackgroundColor3 = self.theme.ElementDark
    scroll.Position = UDim2.new(0, 0, 0, 40)
    scroll.Size = UDim2.new(1, 0, 1, -40)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = self.theme.Accent

    local layout = Instance.new("UIListLayout")
    layout.Parent = scroll
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)

    local function updateList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        for i, item in ipairs(items) do
            local row = Instance.new("Frame")
            row.Parent = scroll
            row.BackgroundColor3 = self.theme.Element
            row.Size = UDim2.new(1, -10, 0, 25)
            row.Position = UDim2.new(0, 5, 0, 0)
            addCorner(row, 4)

            local icon = nil
            if item.Icon then
                icon = Instance.new("ImageLabel")
                icon.Parent = row
                icon.BackgroundTransparency = 1
                icon.Position = UDim2.new(0, 5, 0.5, -10)
                icon.Size = UDim2.new(0, 20, 0, 20)
                icon.Image = item.Icon
                icon.ImageColor3 = selected[item.Value] and self.theme.Accent or self.theme.TextMuted
            end

            local text = Instance.new("TextLabel")
            text.Parent = row
            text.BackgroundTransparency = 1
            if icon then
                text.Position = UDim2.new(0, 30, 0, 0)
                text.Size = UDim2.new(1, -30, 1, 0)
            else
                text.Position = UDim2.new(0, 10, 0, 0)
                text.Size = UDim2.new(1, -10, 1, 0)
            end
            text.Font = self.theme.Font
            text.Text = item.Text
            text.TextColor3 = selected[item.Value] and self.theme.Accent or self.theme.Text
            text.TextSize = self.theme.TextSizeSmall
            text.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton")
            btn.Parent = row
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Text = ""

            btn.MouseButton1Click:Connect(function()
                if multiselect then
                    selected[item.Value] = not selected[item.Value]
                else
                    for k, _ in pairs(selected) do selected[k] = nil end
                    selected[item.Value] = true
                end
                updateList()
                local result = multiselect and selected or (next(selected) and next(selected) or nil)
                errorHandler(function() options.Callback(result) end, "ListBox:" .. options.Name)
                self.save()
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, #items * 27)
    end
    updateList()

    self.window:registerControl(flag,
        function() return multiselect and selected or (next(selected) and next(selected) or nil) end,
        function(v)
            if multiselect then
                selected = v
            else
                selected = {[v] = true}
            end
            updateList()
        end,
        function(c)
            scroll.ScrollBarImageColor3 = c
            for _, row in ipairs(scroll:GetChildren()) do
                if row:IsA("Frame") then
                    local icon = row:FindFirstChild("ImageLabel")
                    local text = row:FindFirstChild("TextLabel")
                    if icon and text then
                        local val = row:FindFirstChild("TextButton") and row.TextButton.Text or ""
                        icon.ImageColor3 = selected[val] and c or self.theme.TextMuted
                        text.TextColor3 = selected[val] and c or self.theme.Text
                    end
                end
            end
        end
    )
    return frame, nil
end

function ControlFactory:createProgressBar(options)
    local current = options.CurrentValue or 0
    local max = options.MaxValue or 100
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, options.Height or 40)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 20)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local barBg = Instance.new("Frame")
    barBg.Parent = frame
    barBg.BackgroundColor3 = self.theme.ElementDark
    barBg.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + 25)
    barBg.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 10)
    addCorner(barBg, 5)

    local fill = Instance.new("Frame")
    fill.Parent = barBg
    fill.BackgroundColor3 = self.theme.Accent
    fill.Size = UDim2.new(current / max, 0, 1, 0)
    addCorner(fill, 5)

    local percentLabel = Instance.new("TextLabel")
    percentLabel.Parent = frame
    percentLabel.BackgroundTransparency = 1
    percentLabel.Position = UDim2.new(1, -50 - self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    percentLabel.Size = UDim2.new(0, 40, 0, 20)
    percentLabel.Font = self.theme.Font
    percentLabel.Text = string.format("%.0f%%", current / max * 100)
    percentLabel.TextColor3 = self.theme.Accent
    percentLabel.TextSize = self.theme.TextSizeSmall
    percentLabel.TextXAlignment = Enum.TextXAlignment.Right

    local function setValue(val)
        current = math.clamp(val, 0, max)
        fill.Size = UDim2.new(current / max, 0, 1, 0)
        percentLabel.Text = string.format("%.0f%%", current / max * 100)
        errorHandler(function() options.Callback(current) end, "ProgressBar:" .. options.Name)
        self.save()
    end

    self.window:registerControl(flag,
        function() return current end,
        function(v) setValue(v) end,
        function(c) fill.BackgroundColor3 = c; percentLabel.TextColor3 = c end
    )
    return frame, nil
end

function ControlFactory:createTextArea(options)
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, options.Height or 100)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 20)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = frame
    scroll.BackgroundColor3 = self.theme.ElementDark
    scroll.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + 25)
    scroll.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 1, -self.theme.PaddingVertical - 25)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = self.theme.Accent

    local textBox = Instance.new("TextBox")
    textBox.Parent = scroll
    textBox.BackgroundTransparency = 1
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.Font = self.theme.Font
    textBox.Text = options.CurrentText or ""
    textBox.TextColor3 = self.theme.Text
    textBox.TextSize = self.theme.TextSizeSmall
    textBox.TextWrapped = true
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        errorHandler(function() options.Callback(textBox.Text) end, "TextArea:" .. options.Name)
        self.save()
    end)

    local function updateSize()
        local size = TextService:GetTextSize(textBox.Text, self.theme.TextSizeSmall, self.theme.Font, Vector2.new(textBox.AbsoluteSize.X, 10000))
        scroll.CanvasSize = UDim2.new(0, 0, 0, size.Y + 10)
    end
    textBox:GetPropertyChangedSignal("Text"):Connect(updateSize)
    scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    updateSize()

    self.window:registerControl(flag,
        function() return textBox.Text end,
        function(v) textBox.Text = v end,
        function(c) scroll.ScrollBarImageColor3 = c end
    )
    return frame, nil
end

function ControlFactory:createImageDisplay(options)
    local url = options.Url or ""
    local flag = options.Flag or options.Name

    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, options.Height or 100)
    addCorner(frame, self.theme.CornerRadius)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical)
    label.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 0, 20)
    label.Font = self.theme.Font
    label.Text = options.Name
    label.TextColor3 = self.theme.Text
    label.TextSize = self.theme.TextSizeNormal
    label.TextXAlignment = Enum.TextXAlignment.Left

    local image = Instance.new("ImageLabel")
    image.Parent = frame
    image.BackgroundColor3 = self.theme.ElementDark
    image.Position = UDim2.new(0, self.theme.PaddingHorizontal, 0, self.theme.PaddingVertical + 25)
    image.Size = UDim2.new(1, -2 * self.theme.PaddingHorizontal, 1, -self.theme.PaddingVertical - 25)
    image.Image = url
    image.ScaleType = Enum.ScaleType.Fit
    addCorner(image, self.theme.CornerRadius)

    return frame, nil
end

function ControlFactory:createGroupBox(options)
    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, options.Height or 200)
    addCorner(frame, self.theme.CornerRadius)

    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = self.theme.Accent
    titleBar.Position = UDim2.new(0, 10, 0, -8)
    titleBar.Size = UDim2.new(0, #options.Title * self.theme.TextSizeNormal + 20, 0, 16)
    addCorner(titleBar, 4)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Font = self.theme.Font
    titleLabel.Text = options.Title
    titleLabel.TextColor3 = self.theme.Text
    titleLabel.TextSize = self.theme.TextSizeSmall
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center

    local content = Instance.new("Frame")
    content.Parent = frame
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 10)
    content.Size = UDim2.new(1, 0, 1, -10)

    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)

    local function addElement(element)
        element.Parent = content
    end

    return {
        AddElement = addElement,
        Frame = frame
    }
end

function ControlFactory:createCollapsibleSection(options)
    local frame = Instance.new("Frame")
    frame.Parent = self.parent
    frame.BackgroundColor3 = self.theme.Element
    frame.Size = UDim2.new(1, 0, 0, options.CollapsedHeight or 35)
    frame.ClipsDescendants = true
    addCorner(frame, self.theme.CornerRadius)

    local header = Instance.new("TextButton")
    header.Parent = frame
    header.BackgroundColor3 = self.theme.ElementDark
    header.Size = UDim2.new(1, 0, 0, 35)
    header.Font = self.theme.Font
    header.Text = options.Title
    header.TextColor3 = self.theme.Text
    header.TextSize = self.theme.TextSizeNormal
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Padding = UDim.new(0, self.theme.PaddingHorizontal)

    local arrow = Instance.new("TextLabel")
    arrow.Parent = header
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Font = self.theme.Font
    arrow.Text = "▼"
    arrow.TextColor3 = self.theme.TextMuted
    arrow.TextSize = 14

    local content = Instance.new("Frame")
    content.Parent = frame
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 35)
    content.Size = UDim2.new(1, 0, 0, 0)

    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)

    local function updateSize()
        local totalHeight = 0
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("Frame") and child.Visible then
                totalHeight = totalHeight + child.Size.Y.Offset + 4
            end
        end
        content.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    local collapsed = options.Collapsed or false
    if not collapsed then
        frame.Size = UDim2.new(1, 0, 0, 35 + totalHeight)
        arrow.Text = "▲"
    else
        arrow.Text = "▼"
    end

    header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        if collapsed then
            arrow.Text = "▼"
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 35)})
        else
            arrow.Text = "▲"
            createTween(frame, 0.2, {Size = UDim2.new(1, 0, 0, 35 + totalHeight)})
        end
    end)

    local function addElement(element)
        element.Parent = content
        element:GetPropertyChangedSignal("Size"):Connect(updateSize)
        updateSize()
        if not collapsed then
            frame.Size = UDim2.new(1, 0, 0, 35 + totalHeight)
        end
    end

    return {
        AddElement = addElement,
        Frame = frame
    }
end

function SynergyUI:CreateModal(options)
    local modal = {}
    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyModal_" .. HttpService:GenerateGUID(false)
    gui.Parent = options.Parent or getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local overlay = Instance.new("Frame")
    overlay.Parent = gui
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Size = UDim2.new(1, 0, 1, 0)

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.Size = UDim2.new(0, 400, 0, 200)
    addCorner(frame, 8)

    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title or "Modal"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local message = Instance.new("TextLabel")
    message.Parent = frame
    message.BackgroundTransparency = 1
    message.Position = UDim2.new(0, 10, 0, 45)
    message.Size = UDim2.new(1, -20, 0, 60)
    message.Font = Enum.Font.Gotham
    message.Text = options.Message or ""
    message.TextColor3 = Color3.fromRGB(200, 200, 200)
    message.TextSize = 14
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextYAlignment = Enum.TextYAlignment.Top

    local input = nil
    if options.Input then
        input = Instance.new("TextBox")
        input.Parent = frame
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        input.Position = UDim2.new(0, 10, 0, 110)
        input.Size = UDim2.new(1, -20, 0, 30)
        input.Font = Enum.Font.Gotham
        input.Text = ""
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 14
        input.PlaceholderText = options.Placeholder or ""
        addCorner(input, 4)
    end

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = frame
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(0, 0, 1, -40)
    buttonContainer.Size = UDim2.new(1, 0, 0, 40)

    local layout = Instance.new("UIListLayout")
    layout.Parent = buttonContainer
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 10)

    local buttons = {}
    for _, btn in ipairs(options.Buttons or {}) do
        local button = Instance.new("TextButton")
        button.Parent = buttonContainer
        button.BackgroundColor3 = btn.Color or Color3.fromRGB(40, 40, 40)
        button.Size = UDim2.new(0, 80, 0, 30)
        button.Font = Enum.Font.Gotham
        button.Text = btn.Text
        button.TextColor3 = btn.TextColor or Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        addCorner(button, 4)
        button.MouseButton1Click:Connect(function()
            local result = nil
            if options.Input then
                result = input.Text
            end
            if btn.Callback then
                errorHandler(function() btn.Callback(result) end, "ModalButton")
            end
            gui:Destroy()
        end)
        table.insert(buttons, button)
    end

    modal.Destroy = function()
        gui:Destroy()
    end

    return modal
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
            Font = options.Font or Enum.Font.Gotham,
            CornerRadius = options.CornerRadius or 6,
            PaddingHorizontal = options.PaddingHorizontal or 10,
            PaddingVertical = options.PaddingVertical or 6,
            TextSizeNormal = options.TextSizeNormal or 13,
            TextSizeSmall = options.TextSizeSmall or 12,
            LabelHeight = options.LabelHeight or 20,
            ButtonHeight = options.ButtonHeight or 35,
            ToggleHeight = options.ToggleHeight or 35,
            ToggleWidth = options.ToggleWidth or 30,
            SliderHeight = options.SliderHeight or 45,
            SliderBarHeight = options.SliderBarHeight or 8,
            DropdownHeight = options.DropdownHeight or 35,
            DropdownItemHeight = options.DropdownItemHeight or 25,
            ChecklistHeight = options.ChecklistHeight or 35,
            ChecklistItemHeight = options.ChecklistItemHeight or 30,
            TextInputHeight = options.TextInputHeight or 45,
            TextInputFieldHeight = options.TextInputFieldHeight or 15,
            KeybindHeight = options.KeybindHeight or 35,
            KeybindWidth = options.KeybindWidth or 60,
            ColorPickerHeight = options.ColorPickerHeight or 35,
            ColorPickerPreviewSize = options.ColorPickerPreviewSize or 25,
            ColorPickerExpandedHeight = options.ColorPickerExpandedHeight or 200,
            RadioItemHeight = options.RadioItemHeight or 30,
            TooltipDelay = options.TooltipDelay or 0.3,
            AnimationsEnabled = options.AnimationsEnabled ~= false,
        },
        ToggleKey = options.ToggleKey or Enum.KeyCode.RightShift,
        IsVisible = true,
        IsMinimized = false,
        SaveDebounce = nil,
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "SynergyUI_" .. HttpService:GenerateGUID(false)
    gui.Parent = options.Parent or getDefaultParent()
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
    addCorner(mainFrame, window.Theme.CornerRadius)
    window.MainFrame = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Parent = mainFrame
    topBar.BackgroundColor3 = window.Theme.Sidebar
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.ZIndex = 10
    addCorner(topBar, window.Theme.CornerRadius)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = topBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, window.Theme.PaddingHorizontal, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Font = window.Theme.Font
    titleLabel.Text = options.Title or "Synergy Hub"
    titleLabel.TextColor3 = window.Theme.Accent
    titleLabel.TextSize = window.Theme.TextSizeNormal
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

    local function saveConfigNow()
        if window.ConfigFile == "" then return end
        local config = {
            position = {mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset},
            size = {mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, mainFrame.Size.Y.Scale, mainFrame.Size.Y.Offset},
            minimized = window.IsMinimized,
            activeTab = window.CurrentTab and window.CurrentTab:FindFirstAncestorOfClass("ScrollingFrame") and window.CurrentTab.Parent and window.CurrentTab.Parent:FindFirstChild("TextButton") and window.CurrentTab.Parent.TextButton.Text or nil,
            accent = {window.Theme.Accent.R, window.Theme.Accent.G, window.Theme.Accent.B},
            theme = {
                Background = {window.Theme.Background.R, window.Theme.Background.G, window.Theme.Background.B},
                Sidebar = {window.Theme.Sidebar.R, window.Theme.Sidebar.G, window.Theme.Sidebar.B},
                Element = {window.Theme.Element.R, window.Theme.Element.G, window.Theme.Element.B},
                ElementDark = {window.Theme.ElementDark.R, window.Theme.ElementDark.G, window.Theme.ElementDark.B},
                Text = {window.Theme.Text.R, window.Theme.Text.G, window.Theme.Text.B},
                TextMuted = {window.Theme.TextMuted.R, window.Theme.TextMuted.G, window.Theme.TextMuted.B},
                Font = window.Theme.Font.Name,
                CornerRadius = window.Theme.CornerRadius,
                PaddingHorizontal = window.Theme.PaddingHorizontal,
                PaddingVertical = window.Theme.PaddingVertical,
                TextSizeNormal = window.Theme.TextSizeNormal,
                TextSizeSmall = window.Theme.TextSizeSmall,
            },
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

    local function saveConfig()
        if window.SaveDebounce then
            task.cancel(window.SaveDebounce)
        end
        window.SaveDebounce = task.delay(0.5, saveConfigNow)
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
                    if decoded.minimized then
                        window.IsMinimized = decoded.minimized
                        if window.IsMinimized then
                            mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 35)
                        end
                    end
                    if decoded.accent then
                        window:SetAccent(Color3.new(decoded.accent[1], decoded.accent[2], decoded.accent[3]))
                    end
                    if decoded.theme then
                        local theme = decoded.theme
                        window.Theme.Background = Color3.new(theme.Background[1], theme.Background[2], theme.Background[3])
                        window.Theme.Sidebar = Color3.new(theme.Sidebar[1], theme.Sidebar[2], theme.Sidebar[3])
                        window.Theme.Element = Color3.new(theme.Element[1], theme.Element[2], theme.Element[3])
                        window.Theme.ElementDark = Color3.new(theme.ElementDark[1], theme.ElementDark[2], theme.ElementDark[3])
                        window.Theme.Text = Color3.new(theme.Text[1], theme.Text[2], theme.Text[3])
                        window.Theme.TextMuted = Color3.new(theme.TextMuted[1], theme.TextMuted[2], theme.TextMuted[3])
                        window.Theme.Font = Enum.Font[theme.Font] or Enum.Font.Gotham
                        window.Theme.CornerRadius = theme.CornerRadius
                        window.Theme.PaddingHorizontal = theme.PaddingHorizontal
                        window.Theme.PaddingVertical = theme.PaddingVertical
                        window.Theme.TextSizeNormal = theme.TextSizeNormal
                        window.Theme.TextSizeSmall = theme.TextSizeSmall
                        mainFrame.BackgroundColor3 = window.Theme.Background
                        topBar.BackgroundColor3 = window.Theme.Sidebar
                        sidebar.BackgroundColor3 = window.Theme.Sidebar
                        contentArea.BackgroundColor3 = window.Theme.Background
                        titleLabel.Font = window.Theme.Font
                        titleLabel.TextColor3 = window.Theme.Accent
                        minBtn.Font = window.Theme.Font
                        closeBtn.Font = window.Theme.Font
                        for _, tab in ipairs(window.Tabs) do
                            tab.Button.Font = window.Theme.Font
                            tab.Button.BackgroundColor3 = window.Theme.Sidebar
                        end
                        for _, control in ipairs(window.Controls) do
                            if control.UpdateTheme then
                                control.UpdateTheme(window.Theme.Accent)
                            end
                        end
                    end
                    if decoded.controls then
                        for _, control in ipairs(window.Controls) do
                            if control.Load and decoded.controls[control.Id] ~= nil then
                                control.Load(decoded.controls[control.Id])
                            end
                        end
                    end
                    if decoded.activeTab then
                        for _, tab in ipairs(window.Tabs) do
                            if tab.Button.Text == decoded.activeTab then
                                tab.Button:Click()
                                break
                            end
                        end
                    end
                end
            end
        end
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
            snapToEdges(mainFrame, workspace.CurrentCamera.ViewportSize)
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
        if window.Theme.AnimationsEnabled then
            if window.IsMinimized then
                createTween(mainFrame, 0.3, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 35)})
            else
                createTween(mainFrame, 0.3, {Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 350)})
            end
        else
            if window.IsMinimized then
                mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 35)
            else
                mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 350)
            end
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
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape and options.CloseOnEscape then
            window:Destroy()
        end
    end))

    local ctrlTabConn = nil
    if options.EnableCtrlTab then
        ctrlTabConn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.Tab and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                if #window.Tabs > 0 then
                    local currentIdx = nil
                    for i, tab in ipairs(window.Tabs) do
                        if tab.Content.Visible then
                            currentIdx = i
                            break
                        end
                    end
                    local nextIdx = (currentIdx or 1) % #window.Tabs + 1
                    window.Tabs[nextIdx].Button:Click()
                end
            end
        end)
        addConnection(ctrlTabConn)
    end

    function window:SaveConfig(filename)
        if filename then window.ConfigFile = filename end
        saveConfigNow()
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
            if conn and conn.Connected then conn:Disconnect() end
        end
        gui:Destroy()
    end

    function window:registerControl(id, saveFunc, loadFunc, themeFunc)
        table.insert(window.Controls, {
            Id = id,
            Save = saveFunc,
            Load = loadFunc,
            UpdateTheme = themeFunc
        })
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
        tabBtn.TextSize = window.Theme.TextSizeSmall

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
        layout.Padding = UDim.new(0, window.Theme.PaddingVertical)

        local padding = Instance.new("UIPadding")
        padding.Parent = scrollFrame
        padding.PaddingLeft = UDim.new(0, window.Theme.PaddingHorizontal)
        padding.PaddingRight = UDim.new(0, window.Theme.PaddingHorizontal + 5)
        padding.PaddingTop = UDim.new(0, window.Theme.PaddingVertical)
        padding.PaddingBottom = UDim.new(0, window.Theme.PaddingVertical)

        addConnection(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + window.Theme.PaddingVertical*2)
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
        local controlFactory = ControlFactory:new(scrollFrame, window.Theme, saveConfig, loadConfig, window.SetAccent, window)
        controlFactory.connections = window.Connections

        elements.CreateLabel = function(_, text) return controlFactory:createLabel(text) end
        elements.CreateSeparator = function() return controlFactory:createSeparator() end
        elements.CreateButton = function(_, opts) return controlFactory:createButton(opts) end
        elements.CreateToggle = function(_, opts) return controlFactory:createToggle(opts) end
        elements.CreateSlider = function(_, opts) return controlFactory:createSlider(opts) end
        elements.CreateDropdown = function(_, opts) return controlFactory:createDropdown(opts) end
        elements.CreateChecklist = function(_, opts) return controlFactory:createChecklist(opts) end
        elements.CreateTextInput = function(_, opts) return controlFactory:createTextInput(opts) end
        elements.CreateNumberInput = function(_, opts) return controlFactory:createNumberInput(opts) end
        elements.CreateKeybind = function(_, opts) return controlFactory:createKeybind(opts) end
        elements.CreateColorPicker = function(_, opts) return controlFactory:createColorPicker(opts) end
        elements.CreateRadioGroup = function(_, opts) return controlFactory:createRadioGroup(opts) end
        elements.CreateListBox = function(_, opts) return controlFactory:createListBox(opts) end
        elements.CreateProgressBar = function(_, opts) return controlFactory:createProgressBar(opts) end
        elements.CreateTextArea = function(_, opts) return controlFactory:createTextArea(opts) end
        elements.CreateImageDisplay = function(_, opts) return controlFactory:createImageDisplay(opts) end
        elements.CreateGroupBox = function(_, opts) return controlFactory:createGroupBox(opts) end
        elements.CreateCollapsibleSection = function(_, opts) return controlFactory:createCollapsibleSection(opts) end

        function elements:CreateSection(name)
            local section = Instance.new("TextLabel")
            section.Parent = scrollFrame
            section.BackgroundTransparency = 1
            section.Size = UDim2.new(1, 0, 0, 25)
            section.Font = window.Theme.Font
            section.Text = name
            section.TextColor3 = window.Theme.Text
            section.TextSize = window.Theme.TextSizeNormal
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Center
            return section
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
            addCorner(frame, window.Theme.CornerRadius)

            local imageLabel = nil
            local textContainer = nil

            if imageUrl and imageUrl ~= "" then
                imageLabel = Instance.new("ImageLabel")
                imageLabel.Parent = frame
                imageLabel.BackgroundColor3 = window.Theme.ElementDark
                imageLabel.Position = UDim2.new(0, window.Theme.PaddingHorizontal, 0, window.Theme.PaddingVertical)
                imageLabel.Size = UDim2.new(0, 50, 0, 50)
                imageLabel.Image = imageUrl
                imageLabel.ScaleType = Enum.ScaleType.Fit
                addCorner(imageLabel, window.Theme.CornerRadius)

                textContainer = Instance.new("Frame")
                textContainer.Parent = frame
                textContainer.BackgroundTransparency = 1
                textContainer.Position = UDim2.new(0, 66, 0, window.Theme.PaddingVertical)
                textContainer.Size = UDim2.new(1, -74 - window.Theme.PaddingHorizontal, 0, 0)
            else
                textContainer = Instance.new("Frame")
                textContainer.Parent = frame
                textContainer.BackgroundTransparency = 1
                textContainer.Position = UDim2.new(0, window.Theme.PaddingHorizontal, 0, window.Theme.PaddingVertical)
                textContainer.Size = UDim2.new(1, -2 * window.Theme.PaddingHorizontal, 0, 0)
            end

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Parent = textContainer
            titleLabel.BackgroundTransparency = 1
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.Font = window.Theme.Font
            titleLabel.Text = title
            titleLabel.TextColor3 = window.Theme.Accent
            titleLabel.TextSize = window.Theme.TextSizeNormal
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
            contentLabel.TextSize = window.Theme.TextSizeSmall
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextYAlignment = Enum.TextYAlignment.Top
            contentLabel.TextWrapped = true

            local function updateSize()
                local titleHeight = 0
                local contentHeight = 0
                if title ~= "" then
                    titleHeight = TextService:GetTextSize(title, window.Theme.TextSizeNormal, window.Theme.Font, Vector2.new(textContainer.AbsoluteSize.X, 1000)).Y
                end
                if content ~= "" then
                    contentHeight = TextService:GetTextSize(content, window.Theme.TextSizeSmall, window.Theme.Font, Vector2.new(textContainer.AbsoluteSize.X, 1000)).Y
                end
                local totalTextHeight = titleHeight + contentHeight + 8
                if imageUrl and imageUrl ~= "" then
                    totalTextHeight = math.max(totalTextHeight, 58)
                end
                titleLabel.Size = UDim2.new(1, 0, 0, titleHeight)
                contentLabel.Position = UDim2.new(0, 0, 0, titleHeight + 4)
                contentLabel.Size = UDim2.new(1, 0, 0, contentHeight)
                textContainer.Size = UDim2.new(1, textContainer.Size.X.Offset, 0, totalTextHeight)
                frame.Size = UDim2.new(1, 0, 0, totalTextHeight + 2 * window.Theme.PaddingVertical)
            end

            frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
            titleLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
            contentLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
            if textContainer then
                textContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
            end
            updateSize()
            return frame
        end

        return elements
    end

    if window.ConfigFile ~= "" then loadConfig() end
    return window
end

return SynergyUI
