--[[
    LAJ HUB v2 - Blade Ball
    
    Features:
    - Auto Parry with multiple advanced methods
    - Player and Ball ESP
    - Auto Ability activation
    - Speed and jump enhancements
    - Anti-AFK and Anti-Kick protection
]]

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "LAJ HUB v2 | Blade Ball", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "LAJHUBv2_BB",
    IntroEnabled = true,
    IntroText = "LAJ HUB v2",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218"
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    -- Auto Parry
    AutoParryEnabled = false,
    ParryMethod = "Hybrid", -- "Distance", "Velocity", "Prediction", "Hybrid"
    ParryDistance = 15,
    PredictionAmount = 0.15,
    
    -- Auto Ability
    AutoAbilityEnabled = false,
    AbilityActivateAt = 25, -- % health to activate ability
    
    -- ESP Settings
    PlayerESPEnabled = false,
    BallESPEnabled = false,
    PlayerESPColor = Color3.fromRGB(0, 255, 0),
    BallESPColor = Color3.fromRGB(255, 0, 0),
    
    -- Enhancements
    WalkSpeedEnabled = false,
    WalkSpeedValue = 30,
    JumpPowerEnabled = false,
    JumpPowerValue = 75,
    
    -- Protection
    AntiAFKEnabled = true,
    AntiKickEnabled = true
}

-- Find the ball
local function GetBall()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Ball" and v:IsA("BasePart") then
            return v
        end
    end
    return nil
end

-- Auto Parry Function
local function AutoParry()
    if not Config.AutoParryEnabled then return end
    
    local ball = GetBall()
    if not ball then return end
    
    local ballPosition = ball.Position
    local ballVelocity = ball.Velocity
    local characterPosition = HumanoidRootPart.Position
    local distance = (ballPosition - characterPosition).Magnitude
    
    -- Check if the ball is heading towards the player
    local directionToBall = (ballPosition - characterPosition).Unit
    local ballDirection = ballVelocity.Unit
    local dotProduct = directionToBall:Dot(ballDirection)
    
    -- If ball is heading away from player, don't parry
    if dotProduct > 0 then return end
    
    local shouldParry = false
    
    -- Different parry methods
    if Config.ParryMethod == "Distance" then
        shouldParry = distance <= Config.ParryDistance
    elseif Config.ParryMethod == "Velocity" then
        local ballSpeed = ballVelocity.Magnitude
        local timeToImpact = distance / ballSpeed
        shouldParry = timeToImpact < 0.5 and distance <= Config.ParryDistance * 2
    elseif Config.ParryMethod == "Prediction" then
        local predictedPosition = ballPosition + ballVelocity * Config.PredictionAmount
        local predictedDistance = (predictedPosition - characterPosition).Magnitude
        shouldParry = predictedDistance <= Config.ParryDistance
    elseif Config.ParryMethod == "Hybrid" then
        -- Combination of methods
        local ballSpeed = ballVelocity.Magnitude
        local predictedPosition = ballPosition + ballVelocity * Config.PredictionAmount
        local predictedDistance = (predictedPosition - characterPosition).Magnitude
        
        -- Adjust parry distance based on ball speed
        local dynamicParryDistance = Config.ParryDistance * (1 + ballSpeed / 100)
        shouldParry = predictedDistance <= dynamicParryDistance
    end
    
    if shouldParry then
        -- Attempt to parry
        local args = {
            [1] = "Parry"
        }
        
        local success, error = pcall(function()
            if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and 
               game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ParryAttempt") then
                game:GetService("ReplicatedStorage").Remotes.ParryAttempt:FireServer(unpack(args))
            end
        end)
        
        if not success then
            -- Fallback method - try to find the correct remote
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("parry") or v.Name:lower():find("block")) then
                    v:FireServer(unpack(args))
                    break
                end
            end
        end
    end
end

-- Auto Ability
local function AutoAbility()
    if not Config.AutoAbilityEnabled then return end
    
    -- Check health percentage
    local healthPercent = (Humanoid.Health / Humanoid.MaxHealth) * 100
    if healthPercent <= Config.AbilityActivateAt then
        -- Try to activate ability
        local success, error = pcall(function()
            if game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and 
               game:GetService("ReplicatedStorage").Remotes:FindFirstChild("AbilityState") then
                game:GetService("ReplicatedStorage").Remotes.AbilityState:FireServer()
            end
        end)
        
        if not success then
            -- Fallback method - try to find the correct remote
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("ability") or v.Name:lower():find("skill")) then
                    v:FireServer()
                    break
                end
            end
        end
    end
end

-- ESP Functions
local ESPObjects = {}

local function CreateESP(object, color, text)
    if ESPObjects[object] then return ESPObjects[object] end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = "ESP"
    esp.AlwaysOnTop = true
    esp.Size = UDim2.new(0, 100, 0, 50)
    esp.StudsOffset = Vector3.new(0, 2, 0)
    esp.Adornee = object
    
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = text or object.Name
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = esp
    
    esp.Parent = game.CoreGui
    
    ESPObjects[object] = esp
    return esp
end

local function UpdateESP()
    -- Update Player ESP
    if Config.PlayerESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and 
               player.Character:FindFirstChild("HumanoidRootPart") then
                CreateESP(player.Character.HumanoidRootPart, Config.PlayerESPColor, player.Name)
            end
        end
    else
        -- Remove Player ESP
        for obj, esp in pairs(ESPObjects) do
            if obj:IsA("Part") and obj.Parent and obj.Parent:FindFirstChild("Humanoid") then
                esp:Destroy()
                ESPObjects[obj] = nil
            end
        end
    end
    
    -- Update Ball ESP
    local ball = GetBall()
    if Config.BallESPEnabled and ball then
        local ballEsp = CreateESP(ball, Config.BallESPColor, "Ball")
        
        -- Update ball info
        if ballEsp and ballEsp:FindFirstChild("TextLabel") then
            local velocity = ball.Velocity.Magnitude
            local direction = ball.Velocity.Unit
            local info = string.format("Ball (%.1f studs/s)", velocity)
            ballEsp.TextLabel.Text = info
        end
    elseif ball and ESPObjects[ball] then
        ESPObjects[ball]:Destroy()
        ESPObjects[ball] = nil
    end
end

-- Enhancement Functions
local function UpdateEnhancements()
    if Config.WalkSpeedEnabled then
        Humanoid.WalkSpeed = Config.WalkSpeedValue
    else
        Humanoid.WalkSpeed = 16 -- Default walk speed
    end
    
    if Config.JumpPowerEnabled then
        Humanoid.JumpPower = Config.JumpPowerValue
    else
        Humanoid.JumpPower = 50 -- Default jump power
    end
end

-- Protection Functions
local function SetupAntiAFK()
    if Config.AntiAFKEnabled then
        -- Anti-AFK
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
        
        -- Simulate random inputs
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end

local function SetupAntiKick()
    if not Config.AntiKickEnabled then return end
    
    -- Override kick function
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "Kick" and self == LocalPlayer then
            return
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Create Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local InfoSection = MainTab:AddSection({
    Name = "Information"
})

InfoSection:AddParagraph("Welcome to LAJ HUB v2", "The ultimate script for Blade Ball with Auto Parry, ESP, and more.")

InfoSection:AddButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/lajhub")
        OrionLib:MakeNotification({
            Name = "Discord Invite",
            Content = "Discord invite copied to clipboard!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Create Auto Parry Tab
local ParryTab = Window:MakeTab({
    Name = "Auto Parry",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ParryTab:AddToggle({
    Name = "Enable Auto Parry",
    Default = false,
    Callback = function(Value)
        Config.AutoParryEnabled = Value
    end
})

ParryTab:AddDropdown({
    Name = "Parry Method",
    Default = "Hybrid",
    Options = {"Distance", "Velocity", "Prediction", "Hybrid"},
    Callback = function(Value)
        Config.ParryMethod = Value
    end
})

ParryTab:AddSlider({
    Name = "Parry Distance",
    Min = 5,
    Max = 30,
    Default = 15,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        Config.ParryDistance = Value
    end
})

ParryTab:AddSlider({
    Name = "Prediction Amount",
    Min = 0.05,
    Max = 0.5,
    Default = 0.15,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.01,
    ValueName = "seconds",
    Callback = function(Value)
        Config.PredictionAmount = Value
    end
})

ParryTab:AddToggle({
    Name = "Auto Ability",
    Default = false,
    Callback = function(Value)
        Config.AutoAbilityEnabled = Value
    end
})

ParryTab:AddSlider({
    Name = "Activate Ability at Health %",
    Min = 10,
    Max = 90,
    Default = 25,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "%",
    Callback = function(Value)
        Config.AbilityActivateAt = Value
    end
})

-- Create ESP Tab
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        Config.PlayerESPEnabled = Value
    end
})

ESPTab:AddToggle({
    Name = "Ball ESP",
    Default = false,
    Callback = function(Value)
        Config.BallESPEnabled = Value
    end
})

ESPTab:AddColorpicker({
    Name = "Player ESP Color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        Config.PlayerESPColor = Value
    end
})

ESPTab:AddColorpicker({
    Name = "Ball ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        Config.BallESPColor = Value
    end
})

-- Create Enhancements Tab
local EnhancementsTab = Window:MakeTab({
    Name = "Enhancements",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

EnhancementsTab:AddToggle({
    Name = "Walk Speed",
    Default = false,
    Callback = function(Value)
        Config.WalkSpeedEnabled = Value
    end
})

EnhancementsTab:AddSlider({
    Name = "Walk Speed Value",
    Min = 16,
    Max = 100,
    Default = 30,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(Value)
        Config.WalkSpeedValue = Value
    end
})

EnhancementsTab:AddToggle({
    Name = "Jump Power",
    Default = false,
    Callback = function(Value)
        Config.JumpPowerEnabled = Value
    end
})

EnhancementsTab:AddSlider({
    Name = "Jump Power Value",
    Min = 50,
    Max = 200,
    Default = 75,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    ValueName = "power",
    Callback = function(Value)
        Config.JumpPowerValue = Value
    end
})

-- Create Protection Tab
local ProtectionTab = Window:MakeTab({
    Name = "Protection",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ProtectionTab:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(Value)
        Config.AntiAFKEnabled = Value
    end
})

ProtectionTab:AddToggle({
    Name = "Anti-Kick",
    Default = true,
    Callback = function(Value)
        Config.AntiKickEnabled = Value
    end
})

-- Initialize the script
SetupAntiAFK()
SetupAntiKick()

-- Start the main loops
RunService.Heartbeat:Connect(function()
    pcall(function()
        if Config.AutoParryEnabled then
            AutoParry()
        end
        
        if Config.AutoAbilityEnabled then
            AutoAbility()
        end
        
        UpdateEnhancements()
    end)
end)

-- ESP Update Loop (less frequent)
coroutine.wrap(function()
    while true do
        pcall(UpdateESP)
        wait(0.1)
    end
end)()

-- Handle character respawning
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    
    SetupAntiAFK()
    UpdateEnhancements()
end)

-- Final notification
OrionLib:MakeNotification({
    Name = "LAJ HUB v2",
    Content = "Blade Ball script loaded successfully!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Initialize UI
OrionLib:Init()
