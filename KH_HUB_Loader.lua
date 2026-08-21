-- LocalScript di dalam StarterGui
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ============================================================
-- KONFIGURASI URL SCRIPT
-- ============================================================
local Scripts = {
    PLAYER = "https://raw.githubusercontent.com/Nie1Cem/roblox-script-strenght-per-click-/refs/heads/main/PlayerFeature.lua",          -- Ganti dengan URL sebenar
    AUTO_CLICKER = "https://raw.githubusercontent.com/Nie1Cem/roblox-script-strenght-per-click-/refs/heads/main/AutoClickerFeature.lua", -- Ganti dengan URL sebenar
    STATUS = "STATUS_URL"           -- Ganti dengan URL sebenar
}

-- ============================================================
-- FEATURE LOADER & CACHE
-- ============================================================
local Features = {}
local FeatureCache = {}
local CurrentTab = nil
local FeatureConnections = {}

local function loadFeature(url)
    if not url or url == "" then
        warn("URL kosong atau tidak sah")
        return nil
    end
    
    if FeatureCache[url] then
        return FeatureCache[url]
    end
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        warn("Gagal load feature:", result)
        return nil
    end
    
    FeatureCache[url] = result
    return result
end

local function cleanupFeature(tabName)
    if FeatureConnections[tabName] then
        for _, connection in pairs(FeatureConnections[tabName]) do
            pcall(function() connection:Disconnect() end)
        end
        FeatureConnections[tabName] = nil
    end
    
    if Features[tabName] and Features[tabName].Destroy then
        pcall(function() Features[tabName].Destroy() end)
    end
    Features[tabName] = nil
end

local function switchTab(tabName, contentFrame)
    -- Cleanup feature sebelumnya
    if CurrentTab then
        cleanupFeature(CurrentTab)
    end
    
    -- Clear content
    for _, child in pairs(contentFrame:GetChildren()) do
        pcall(function() child:Destroy() end)
    end
    
    CurrentTab = tabName
    
    -- Load feature
    local url = Scripts[tabName]
    if not url then
        warn("Tiada URL untuk tab:", tabName)
        return
    end
    
    local featureModule = loadFeature(url)
    if not featureModule then
        warn("Gagal memuatkan feature:", tabName)
        return
    end
    
    if type(featureModule) == "function" then
        featureModule({
            ContentFrame = contentFrame,
            Player = player,
            ToggleStates = toggleStates,
            Settings = settings,
            UserInputService = UserInputService,
            TweenService = TweenService,
            AddConnection = function(tab, connection)
                if not FeatureConnections[tab] then
                    FeatureConnections[tab] = {}
                end
                table.insert(FeatureConnections[tab], connection)
            end
        })
    elseif type(featureModule) == "table" and featureModule.Init then
        Features[tabName] = featureModule
        local context = {
            ContentFrame = contentFrame,
            Player = player,
            ToggleStates = toggleStates,
            Settings = settings,
            UserInputService = UserInputService,
            TweenService = TweenService,
            AddConnection = function(tab, connection)
                if not FeatureConnections[tab] then
                    FeatureConnections[tab] = {}
                end
                table.insert(FeatureConnections[tab], connection)
            end
        }
        Features[tabName].Init(context)
    else
        warn("Feature module tidak mempunyai fungsi Init yang sah:", tabName)
    end
end

-- ============================================================
-- GLOBAL STATE
-- ============================================================
local toggleStates = {
    ESP = false,
    JUMP_HIGH = false,
    FLY = false,
    SPEED = false,
    AUTO_CLICKER = false
}

local settings = {
    JUMP_POWER = 100,
    WALK_SPEED = 32,
    CLICK_DELAY = 0.1
}

-- ============================================================
-- GUI CREATION
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KHHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 550, 0, 420)
frame.Position = UDim2.new(0.5, -275, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 20)
frameCorner.Parent = frame

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = -1
shadow.Parent = frame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 25)
shadowCorner.Parent = shadow

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
topBar.BackgroundTransparency = 0.1
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 20)
topBarCorner.Parent = topBar

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0, 40, 0, 40)
logoLabel.Position = UDim2.new(0, 15, 0, 5)
logoLabel.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
logoLabel.BackgroundTransparency = 0.2
logoLabel.Text = "KH"
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextSize = 20
logoLabel.Font = Enum.Font.SourceSansBold
logoLabel.Parent = topBar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 10)
logoCorner.Parent = logoLabel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 30)
titleLabel.Position = UDim2.new(0, 65, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "KH HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 200, 0, 15)
subtitleLabel.Position = UDim2.new(0, 65, 0, 35)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Premium Script Hub"
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitleLabel.TextSize = 10
subtitleLabel.Font = Enum.Font.SourceSans
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.Parent = topBar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 2)
divider.Position = UDim2.new(0, 0, 0, 50)
divider.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
divider.BackgroundTransparency = 0.3
divider.BorderSizePixel = 0
divider.Parent = frame

local verticalDivider = Instance.new("Frame")
verticalDivider.Size = UDim2.new(0, 2, 1, -50)
verticalDivider.Position = UDim2.new(0, 170, 0, 52)
verticalDivider.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
verticalDivider.BackgroundTransparency = 0.5
verticalDivider.BorderSizePixel = 0
verticalDivider.Parent = frame

-- ============================================================
-- SIDEBAR TABS
-- ============================================================
local function createTabButton(text, yPosition, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 145, 0, 40)
    tabButton.Position = UDim2.new(0, 12, 0, yPosition)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabButton.BackgroundTransparency = 0.1
    tabButton.Text = "  " .. icon .. "  " .. text
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.Parent = frame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 12)
    tabCorner.Parent = tabButton
    
    return tabButton
end

local playerTab = createTabButton("PLAYER", 60, "👤")
local autoClickerTab = createTabButton("AUTO CLICKER", 108, "🖱️")
local statusTab = createTabButton("STATUS", 156, "📊")

-- ============================================================
-- CONTENT FRAME
-- ============================================================
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -185, 1, -70)
contentFrame.Position = UDim2.new(0, 175, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = frame

-- ============================================================
-- TAB SWITCHING & HIGHLIGHT
-- ============================================================
local function updateTabs(activeTab)
    local tabs = {playerTab, autoClickerTab, statusTab}
    for _, tab in pairs(tabs) do
        if tab == activeTab then
            tab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            tab.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

local function onTabClick(tabName)
    updateTabs(tabName == "PLAYER" and playerTab or tabName == "AUTO_CLICKER" and autoClickerTab or statusTab)
    switchTab(tabName, contentFrame)
end

playerTab.MouseButton1Click:Connect(function()
    onTabClick("PLAYER")
end)

autoClickerTab.MouseButton1Click:Connect(function()
    onTabClick("AUTO_CLICKER")
end)

statusTab.MouseButton1Click:Connect(function()
    onTabClick("STATUS")
end)

-- ============================================================
-- DRAG SYSTEM
-- ============================================================
local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -80, 0, 50)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.BorderSizePixel = 0
dragArea.ZIndex = 10
dragArea.Parent = frame

local frameDragging = false
local frameDragStart = nil
local frameStartPos = nil

dragArea.MouseButton1Down:Connect(function()
    frameDragging = true
    frameDragStart = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
    frameStartPos = UserInputService:GetMouseLocation()
end)

UserInputService.InputChanged:Connect(function(input)
    if frameDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = UserInputService:GetMouseLocation()
        local delta = currentPos - frameStartPos
        frame.Position = UDim2.new(0, frameDragStart.X + delta.X, 0, frameDragStart.Y + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        frameDragging = false
    end
end)

-- ============================================================
-- MINIMIZE / CLOSE
-- ============================================================
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 12)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundTransparency = 0
closeButton.Text = ""
closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false
closeButton.ZIndex = 20
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -60, 0, 12)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
minimizeButton.BackgroundTransparency = 0
minimizeButton.Text = ""
minimizeButton.BorderSizePixel = 0
minimizeButton.AutoButtonColor = false
minimizeButton.ZIndex = 20
minimizeButton.Parent = frame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeButton

local iconButton = Instance.new("TextButton")
iconButton.Name = "KHIcon"
iconButton.Size = UDim2.new(0, 55, 0, 55)
iconButton.Position = UDim2.new(0, 10, 0, 10)
iconButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
iconButton.BackgroundTransparency = 0.2
iconButton.Text = "KH"
iconButton.TextColor3 = Color3.fromRGB(255, 255, 255)
iconButton.TextSize = 22
iconButton.Font = Enum.Font.SourceSansBold
iconButton.BorderSizePixel = 0
iconButton.Visible = false
iconButton.ZIndex = 20
iconButton.Parent = screenGui

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = iconButton

local iconDragging = false
local iconDragStart = nil
local iconStartPos = nil

iconButton.MouseButton1Down:Connect(function()
    iconDragging = true
    iconDragStart = Vector2.new(iconButton.Position.X.Offset, iconButton.Position.Y.Offset)
    iconStartPos = UserInputService:GetMouseLocation()
end)

UserInputService.InputChanged:Connect(function(input)
    if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local currentPos = UserInputService:GetMouseLocation()
        local delta = currentPos - iconStartPos
        iconButton.Position = UDim2.new(0, iconDragStart.X + delta.X, 0, iconDragStart.Y + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        iconDragging = false
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    iconButton.Visible = true
    iconButton.Position = UDim2.new(0, 10, 0, 10)
end)

iconButton.MouseButton1Click:Connect(function()
    iconButton.Visible = false
    frame.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
    -- Cleanup all features
    for tabName, _ in pairs(Scripts) do
        cleanupFeature(tabName)
    end
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
            humanoid.WalkSpeed = 16
        end
    end
    screenGui:Destroy()
end)

-- ============================================================
-- LOAD DEFAULT TAB
-- ============================================================
onTabClick("PLAYER")
