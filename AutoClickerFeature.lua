-- AUTO CLICKER FEATURE
local Feature = {}

local contentFrame
local player
local toggleStates
local settings
local UserInputService
local TweenService
local addConnection

local autoClickerKeybind = Enum.KeyCode.C
local autoClickerConnection = nil

local function updateToggle(toggle, knob, enabled)
    if enabled then
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 30, 0, 3)}):Play()
    else
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 3, 0, 3)}):Play()
    end
end

local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do
        pcall(function() child:Destroy() end)
    end
end

local function createToggle(text, yPosition, stateKey)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -20, 0, 40)
    toggleContainer.Position = UDim2.new(0, 10, 0, yPosition)
    toggleContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggleContainer.BackgroundTransparency = 0.3
    toggleContainer.BorderSizePixel = 0
    toggleContainer.Parent = contentFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = toggleContainer
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 0, 35)
    label.Position = UDim2.new(0, 15, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 15
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleContainer
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 55, 0, 28)
    toggle.Position = UDim2.new(1, -65, 0, 6)
    toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = toggleContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    updateToggle(toggle, knob, toggleStates[stateKey])
    
    return label, toggle, knob, toggleContainer
end

local function createSlider(text, yPosition, minValue, maxValue, defaultValue, stateKey)
    local settingFrame = Instance.new("Frame")
    settingFrame.Size = UDim2.new(1, -20, 0, 70)
    settingFrame.Position = UDim2.new(0, 10, 0, yPosition)
    settingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    settingFrame.BackgroundTransparency = 0.3
    settingFrame.BorderSizePixel = 0
    settingFrame.Parent = contentFrame
    
    local settingCorner = Instance.new("UICorner")
    settingCorner.CornerRadius = UDim.new(0, 10)
    settingCorner.Parent = settingFrame
    
    local settingLabel = Instance.new("TextLabel")
    settingLabel.Size = UDim2.new(1, -20, 0, 25)
    settingLabel.Position = UDim2.new(0, 10, 0, 5)
    settingLabel.BackgroundTransparency = 1
    settingLabel.Text = text .. ": " .. defaultValue
    settingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingLabel.TextSize = 13
    settingLabel.Font = Enum.Font.SourceSansBold
    settingLabel.TextXAlignment = Enum.TextXAlignment.Left
    settingLabel.Parent = settingFrame
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, -20, 0, 25)
    sliderButton.Position = UDim2.new(0, 10, 0, 35)
    sliderButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.AutoButtonColor = false
    sliderButton.Parent = settingFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderButton
    
    local fillPercentage = (defaultValue - minValue) / (maxValue - minValue)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(fillPercentage, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderButton
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 19, 0, 19)
    sliderKnob.Position = UDim2.new(fillPercentage, -9, 0, 3)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderButton
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob
    
    local function updateSlider()
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderButton.AbsolutePosition
        local sliderSize = sliderButton.AbsoluteSize
        
        local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize.X)
        local percentage = relativeX / sliderSize.X
        
        local value = math.floor(minValue + (maxValue - minValue) * percentage)
        
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percentage, -9, 0, 3)
        settingLabel.Text = text .. ": " .. value
        
        if stateKey == "CLICK_DELAY" then
            settings.CLICK_DELAY = value / 1000
        end
    end
    
    local isDragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        isDragging = true
        updateSlider()
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    return settingFrame
end

local function setupToggle(toggle, knob, stateKey, onEnable, onDisable)
    toggle.MouseButton1Click:Connect(function()
        toggleStates[stateKey] = not toggleStates[stateKey]
        local enabled = toggleStates[stateKey]
        
        updateToggle(toggle, knob, enabled)
        
        if enabled then
            if onEnable then onEnable() end
        else
            if onDisable then onDisable() end
        end
    end)
end

function Feature.Init(context)
    contentFrame = context.ContentFrame
    player = context.Player
    toggleStates = context.ToggleStates
    settings = context.Settings
    UserInputService = context.UserInputService
    TweenService = context.TweenService
    addConnection = context.AddConnection
    
    clearContent()
    
    local autoClickerLabel, autoClickerToggle, autoClickerKnob = createToggle("AUTO CLICKER", 10, "AUTO_CLICKER")
    
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Size = UDim2.new(1, -20, 0, 40)
    keybindContainer.Position = UDim2.new(0, 10, 0, 55)
    keybindContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    keybindContainer.BackgroundTransparency = 0.3
    keybindContainer.BorderSizePixel = 0
    keybindContainer.Parent = contentFrame
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 10)
    keybindCorner.Parent = keybindContainer
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0, 150, 0, 35)
    keybindLabel.Position = UDim2.new(0, 15, 0, 2)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "KEYBIND"
    keybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindLabel.TextSize = 15
    keybindLabel.Font = Enum.Font.SourceSansBold
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Parent = keybindContainer
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0, 80, 0, 30)
    keybindButton.Position = UDim2.new(1, -90, 0, 5)
    keybindButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    keybindButton.BackgroundTransparency = 0.3
    keybindButton.Text = autoClickerKeybind.Name
    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    keybindButton.TextSize = 14
    keybindButton.Font = Enum.Font.SourceSansBold
    keybindButton.BorderSizePixel = 0
    keybindButton.AutoButtonColor = false
    keybindButton.Parent = keybindContainer
    
    local keybindButtonCorner = Instance.new("UICorner")
    keybindButtonCorner.CornerRadius = UDim.new(0, 8)
    keybindButtonCorner.Parent = keybindButton
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 100)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: OFF"
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = contentFrame
    
    local clickDelaySlider = nil
    
    local function refreshSlider()
        if clickDelaySlider then clickDelaySlider:Destroy() end
        
        if toggleStates.AUTO_CLICKER then
            clickDelaySlider = createSlider("CLICK DELAY (ms)", 135, 50, 1000, settings.CLICK_DELAY * 1000, "CLICK_DELAY")
        end
    end
    
    local function updateStatus()
        if toggleStates.AUTO_CLICKER then
            statusLabel.Text = "Status: ON (Keybind: " .. autoClickerKeybind.Name .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        else
            statusLabel.Text = "Status: OFF (Keybind: " .. autoClickerKeybind.Name .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
    
    setupToggle(autoClickerToggle, autoClickerKnob, "AUTO_CLICKER", function()
        refreshSlider()
        updateStatus()
    end, function()
        refreshSlider()
        updateStatus()
    end)
    
    keybindButton.MouseButton1Click:Connect(function()
        keybindButton.Text = "TEKAN..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                autoClickerKeybind = input.KeyCode
                keybindButton.Text = autoClickerKeybind.Name
                connection:Disconnect()
                updateStatus()
            end
        end)
    end)
    
    refreshSlider()
    updateStatus()
    
    -- Auto Clicker Loop
    local clickerLoop = coroutine.create(function()
        while true do
            if toggleStates.AUTO_CLICKER then
                pcall(function()
                    local mouse = player:GetMouse()
                    mouse1click()
                end)
            end
            task.wait(settings.CLICK_DELAY)
        end
    end)
    coroutine.resume(clickerLoop)
    
    -- Keybind handler
    local keybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == autoClickerKeybind then
            toggleStates.AUTO_CLICKER = not toggleStates.AUTO_CLICKER
            updateStatus()
            refreshSlider()
            -- Update toggle visual
            for _, child in pairs(contentFrame:GetChildren()) do
                if child:IsA("Frame") then
                    local toggle = child:FindFirstChildWhichIsA("TextButton")
                    if toggle and toggle.Size == UDim2.new(0, 55, 0, 28) then
                        local knob = toggle:FindFirstChild("Frame")
                        if knob then
                            updateToggle(toggle, knob, toggleStates.AUTO_CLICKER)
                        end
                    end
                end
            end
        end
        
        if toggleStates.FLY and input.KeyCode == Enum.KeyCode.Space then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and rootPart then
                    humanoid.Sit = false
                    rootPart.Velocity = Vector3.new(0, 50, 0)
                end
            end
        end
    end)
    
    addConnection("AUTO_CLICKER", keybindConnection)
end

function Feature.Destroy()
    if autoClickerConnection then
        autoClickerConnection:Disconnect()
        autoClickerConnection = nil
    end
    if contentFrame then
        for _, child in pairs(contentFrame:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end
end

return Feature
