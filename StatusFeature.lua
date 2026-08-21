-- STATUS FEATURE
local Feature = {}

local contentFrame
local player
local addConnection

local function clearContent()
    for _, child in pairs(contentFrame:GetChildren()) do
        pcall(function() child:Destroy() end)
    end
end

local function getPlayerStat(statName)
    local character = player.Character
    if not character then return "N/A" end
    
    local stat = player:FindFirstChild(statName)
    if stat then
        return tostring(stat.Value or stat)
    end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local statValue = leaderstats:FindFirstChild(statName)
        if statValue then
            return tostring(statValue.Value)
        end
    end
    
    local charStat = character:FindFirstChild(statName)
    if charStat then
        return tostring(charStat.Value or charStat)
    end
    
    local attr = player:GetAttribute(statName)
    if attr then
        return tostring(attr)
    end
    
    return "N/A"
end

local function createStatusRow(label, yPosition)
    local rowContainer = Instance.new("Frame")
    rowContainer.Size = UDim2.new(1, -20, 0, 50)
    rowContainer.Position = UDim2.new(0, 10, 0, yPosition)
    rowContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    rowContainer.BackgroundTransparency = 0.3
    rowContainer.BorderSizePixel = 0
    rowContainer.Parent = contentFrame
    
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = rowContainer
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0, 120, 0, 40)
    labelText.Position = UDim2.new(0, 15, 0, 5)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelText.TextSize = 15
    labelText.Font = Enum.Font.SourceSansBold
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = rowContainer
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 150, 0, 40)
    valueText.Position = UDim2.new(1, -165, 0, 5)
    valueText.BackgroundTransparency = 1
    valueText.Text = "Loading..."
    valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueText.TextSize = 16
    valueText.Font = Enum.Font.SourceSansBold
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = rowContainer
    
    return rowContainer, valueText
end

function Feature.Init(context)
    contentFrame = context.ContentFrame
    player = context.Player
    addConnection = context.AddConnection
    
    clearContent()
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Size = UDim2.new(1, -20, 0, 40)
    statusTitle.Position = UDim2.new(0, 10, 0, 10)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "📊 PLAYER STATUS"
    statusTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
    statusTitle.TextSize = 20
    statusTitle.Font = Enum.Font.SourceSansBold
    statusTitle.TextXAlignment = Enum.TextXAlignment.Center
    statusTitle.Parent = contentFrame
    
    local rebirthRow, rebirthValue = createStatusRow("🔄 REBIRTH", 60)
    local strengthRow, strengthValue = createStatusRow("💪 STRENGTH", 115)
    local levelRow, levelValue = createStatusRow("⭐ LEVEL", 170)
    local winsRow, winsValue = createStatusRow("🏆 WINS", 225)
    
    local function updateStats()
        rebirthValue.Text = getPlayerStat("Rebirth") or getPlayerStat("Rebirths") or getPlayerStat("RebirthCount")
        strengthValue.Text = getPlayerStat("Strength") or getPlayerStat("STR")
        levelValue.Text = getPlayerStat("Level") or getPlayerStat("LVL") or getPlayerStat("LV")
        winsValue.Text = getPlayerStat("Wins") or getPlayerStat("Win") or getPlayerStat("WinCount")
    end
    
    local updaterConnection = game:GetService("RunService").Heartbeat:Connect(function()
        updateStats()
    end)
    
    addConnection("STATUS", updaterConnection)
    updateStats()
end

function Feature.Destroy()
    if contentFrame then
        for _, child in pairs(contentFrame:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end
end

return Feature
