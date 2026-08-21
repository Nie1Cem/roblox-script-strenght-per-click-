-- PLAYER FEATURE (Fixed)
local Feature = {}

local contentFrame
local player
local toggleStates
local settings
local UserInputService
local TweenService
local addConnection

local highlightedPlayers = {}
local featureConnections = {}

-- ============================================================
-- FUNGSI HIGHLIGHT
-- ============================================================
local function addHighlight(targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    local character = targetPlayer.Character
    if not character then return end
    
    -- Remove existing highlight
    if highlightedPlayers[targetPlayer] then
        local oldHighlight = highlightedPlayers[targetPlayer]
        if oldHighlight and oldHighlight.Parent then 
            oldHighlight:Destroy()
        end
        highlightedPlayers[targetPlayer] = nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlightedPlayers[targetPlayer] = highlight
end

local function removeHighlight(targetPlayer)
    if highlightedPlayers[targetPlayer] then
        local highlight = highlightedPlayers[targetPlayer]
        if highlight then 
            pcall(function() highlight:Destroy() end)
        end
        highlightedPlayers[targetPlayer] = nil
    end
end

local function clearAllHighlights()
    for targetPlayer, highlight in pairs(highlightedPlayers) do
        if highlight then 
            pcall(function() highlight:Destroy() end)
        end
    end
    highlightedPlayers = {}
end

-- ============================================================
-- FUNGSI UI
-- ============================================================
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
        
        if stateKey == "JUMP_POWER" then
            settings.JUMP_POWER = value
            if toggleStates.JUMP_HIGH then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then humanoid.JumpPower = value end
                end
            end
        elseif stateKey == "WALK_SPEED" then
            settings.WALK_SPEED = value
            if toggleStates.SPEED then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then humanoid.WalkSpeed = value end
                end
            end
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

-- ============================================================
-- INIT FUNCTION (FIXED)
-- ============================================================
function Feature.Init(context)
    contentFrame = context.ContentFrame
    player = context.Player
    toggleStates = context.ToggleStates
    settings = context.Settings
    UserInputService = context.UserInputService
    TweenService = context.TweenService
    addConnection = context.AddConnection
    
    clearContent()
    
    -- Create toggles
    local espLabel, espToggle, espKnob = createToggle("ESP", 10, "ESP")
    local jumpLabel, jumpToggle, jumpKnob = createToggle("JUMP HIGH", 55, "JUMP_HIGH")
    local flyLabel, flyToggle, flyKnob = createToggle("FLY", 100, "FLY")
    local speedLabel, speedToggle, speedKnob = createToggle("SPEED", 145, "SPEED")
    
    local jumpSlider = nil
    local speedSlider = nil
    
    local function refreshSliders()
        if jumpSlider then jumpSlider:Destroy() end
        if speedSlider then speedSlider:Destroy() end
        
        local currentY = 190
        
        if toggleStates.JUMP_HIGH then
            jumpSlider = createSlider("JUMP POWER", currentY, 50, 200, settings.JUMP_POWER, "JUMP_POWER")
            currentY = currentY + 75
        end
        
        if toggleStates.SPEED then
            speedSlider = createSlider("WALK SPEED", currentY, 16, 100, settings.WALK_SPEED, "WALK_SPEED")
        end
    end
    
    -- Setup ESP toggle - FIXED
    setupToggle(espToggle, espKnob, "ESP", function()
        print("ESP ENABLED")
        local Players = game:GetService("Players")
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                task.wait(0.1)
                addHighlight(otherPlayer)
            end
        end
    end, function()
        print("ESP DISABLED")
        clearAllHighlights()
    end)
    
    -- Setup Jump toggle
    setupToggle(jumpToggle, jumpKnob, "JUMP_HIGH", function()
        print("JUMP HIGH ENABLED")
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.JumpPower = settings.JUMP_POWER 
            end
        end
        refreshSliders()
    end, function()
        print("JUMP HIGH DISABLED")
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.JumpPower = 50 
            end
        end
        refreshSliders()
    end)
    
    -- Setup Fly toggle
    setupToggle(flyToggle, flyKnob, "FLY")
    
    -- Setup Speed toggle
    setupToggle(speedToggle, speedKnob, "SPEED", function()
        print("SPEED ENABLED")
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.WalkSpeed = settings.WALK_SPEED 
            end
        end
        refreshSliders()
    end, function()
        print("SPEED DISABLED")
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.WalkSpeed = 16 
            end
        end
        refreshSliders()
    end)
    
    refreshSliders()
    
    -- ============================================================
    -- EVENT HANDLERS (FIXED)
    -- ============================================================
    local Players = game:GetService("Players")
    
    -- Handler untuk player baru masuk
    local function onPlayerAdded(newPlayer)
        if newPlayer == player then return end
        if toggleStates.ESP then
            local conn = newPlayer.CharacterAdded:Connect(function(character)
                task.wait(1)
                if toggleStates.ESP and character and character.Parent then
                    addHighlight(newPlayer)
                end
            end)
            addConnection("PLAYER", conn)
        end
    end
    
    -- Handler untuk player keluar
    local function onPlayerRemoving(leftPlayer)
        removeHighlight(leftPlayer)
    end
    
    -- Handler untuk respawn player sendiri
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        if toggleStates.JUMP_HIGH then 
            humanoid.JumpPower = settings.JUMP_POWER 
        end
        if toggleStates.SPEED then 
            humanoid.WalkSpeed = settings.WALK_SPEED 
        end
    end
    
    -- Handler untuk respawn player lain
    local function onOtherCharacterAdded(existingPlayer)
        return function(character)
            task.wait(0.5)
            if toggleStates.ESP and character and character.Parent then
                removeHighlight(existingPlayer)
                addHighlight(existingPlayer)
            end
        end
    end
    
    -- Register events
    local conn1 = Players.PlayerAdded:Connect(onPlayerAdded)
    local conn2 = Players.PlayerRemoving:Connect(onPlayerRemoving)
    local conn3 = player.CharacterAdded:Connect(onCharacterAdded)
    
    addConnection("PLAYER", conn1)
    addConnection("PLAYER", conn2)
    addConnection("PLAYER", conn3)
    
    -- Register untuk player lain yang sudah ada
    for _, existingPlayer in pairs(Players:GetPlayers()) do
        if existingPlayer ~= player then
            local conn = existingPlayer.CharacterAdded:Connect(onOtherCharacterAdded(existingPlayer))
            addConnection("PLAYER", conn)
            
            -- Apply highlight jika ESP already ON
            if toggleStates.ESP then
                task.wait(0.2)
                addHighlight(existingPlayer)
            end
        end
    end
end

-- ============================================================
-- DESTROY FUNCTION
-- ============================================================
function Feature.Destroy()
    print("PLAYER FEATURE DESTROYED")
    clearAllHighlights()
    if contentFrame then
        for _, child in pairs(contentFrame:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end
end

return Feature
