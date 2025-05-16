--[[
    SkyX Hub - Natural Disaster Survival Script
    Using OrionX UI
    
    Features:
    - Disaster prediction (know the disaster before announcement)
    - Auto-farm survival wins
    - No fall damage
    - Anti-ragdoll
    - Speed and jump modifiers
    - Teleport to high ground
    - Safe spot teleports for each map
    - Walkspeed and jumppower adjustment
]]

-- Load the Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    -- Survival Features
    DisasterPrediction = false,
    AutoFarm = false,
    NoFallDamage = false,
    AntiRagdoll = false,
    AutoHighGround = false,
    
    -- Character Modifications
    SpeedHack = false,
    SpeedMultiplier = 2,
    JumpHack = false,
    JumpMultiplier = 2,
    
    -- Protection
    AntiAFK = true
}

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "SkyX Hub | Natural Disaster Survival", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SkyXHub_NDS",
    IntroEnabled = true,
    IntroText = "SkyX Hub",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218"
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home",
    PremiumOnly = false
})

local InfoSection = MainTab:AddSection({
    Name = "Information"
})

InfoSection:AddParagraph("Welcome to SkyX Hub", "The ultimate script for Natural Disaster Survival with disaster prediction, auto-farm, and more.")

-- Try to detect current map and disaster
local currentMap = "Unknown"
local currentDisaster = "Unknown"

-- Check for map name
if workspace:FindFirstChild("Structure") then
    for _, child in pairs(workspace.Structure:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Map") then
            currentMap = child.Name
            break
        end
    end
end

-- Check for disaster
if workspace:FindFirstChild("DisasterEvent") and workspace.DisasterEvent:FindFirstChild("Disaster") then
    currentDisaster = workspace.DisasterEvent.Disaster.Value
elseif game.ReplicatedStorage:FindFirstChild("CurrentDisaster") then
    currentDisaster = game.ReplicatedStorage.CurrentDisaster.Value
end

InfoSection:AddParagraph("Game Status", "Current Map: " .. currentMap .. "\nCurrent Disaster: " .. currentDisaster)

-- Update info when values change
if workspace:FindFirstChild("Structure") then
    workspace.Structure.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:WaitForChild("Map", 2) then
            currentMap = child.Name
            InfoSection:AddParagraph("Game Status", "Current Map: " .. currentMap .. "\nCurrent Disaster: " .. currentDisaster)
        end
    end)
end

if workspace:FindFirstChild("DisasterEvent") and workspace.DisasterEvent:FindFirstChild("Disaster") then
    workspace.DisasterEvent.Disaster.Changed:Connect(function()
        currentDisaster = workspace.DisasterEvent.Disaster.Value
        InfoSection:AddParagraph("Game Status", "Current Map: " .. currentMap .. "\nCurrent Disaster: " .. currentDisaster)
    end)
elseif game.ReplicatedStorage:FindFirstChild("CurrentDisaster") then
    game.ReplicatedStorage.CurrentDisaster.Changed:Connect(function()
        currentDisaster = game.ReplicatedStorage.CurrentDisaster.Value
        InfoSection:AddParagraph("Game Status", "Current Map: " .. currentMap .. "\nCurrent Disaster: " .. currentDisaster)
    end)
end

InfoSection:AddButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/skyxhub")
            OrionLib:MakeNotification({
                Name = "Discord",
                Content = "Invite link copied to clipboard!",
                Image = "info",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Your executor doesn't support clipboard functions.",
                Image = "warning",
                Time = 5
            })
        end
    end
})

-- Survival Tab
local SurvivalTab = Window:MakeTab({
    Name = "Survival",
    Icon = "shield",
    PremiumOnly = false
})

local SurvivalSection = SurvivalTab:AddSection({
    Name = "Survival Features"
})

-- Disaster Prediction Toggle
SurvivalSection:AddToggle({
    Name = "Disaster Prediction",
    Default = false,
    Flag = "DisasterPrediction",
    Save = true,
    Callback = function(Value)
        Config.DisasterPrediction = Value
        
        if Value then
            EnableDisasterPrediction()
            OrionLib:MakeNotification({
                Name = "Disaster Prediction",
                Content = "Disaster Prediction has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableDisasterPrediction()
            OrionLib:MakeNotification({
                Name = "Disaster Prediction",
                Content = "Disaster Prediction has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Auto Farm Toggle
SurvivalSection:AddToggle({
    Name = "Auto Farm Survival",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm = Value
        
        if Value then
            EnableAutoFarm()
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto Farm has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAutoFarm()
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto Farm has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- No Fall Damage Toggle
SurvivalSection:AddToggle({
    Name = "No Fall Damage",
    Default = false,
    Flag = "NoFallDamage",
    Save = true,
    Callback = function(Value)
        Config.NoFallDamage = Value
        
        if Value then
            EnableNoFallDamage()
            OrionLib:MakeNotification({
                Name = "No Fall Damage",
                Content = "No Fall Damage has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableNoFallDamage()
            OrionLib:MakeNotification({
                Name = "No Fall Damage",
                Content = "No Fall Damage has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Anti-Ragdoll Toggle
SurvivalSection:AddToggle({
    Name = "Anti-Ragdoll",
    Default = false,
    Flag = "AntiRagdoll",
    Save = true,
    Callback = function(Value)
        Config.AntiRagdoll = Value
        
        if Value then
            EnableAntiRagdoll()
            OrionLib:MakeNotification({
                Name = "Anti-Ragdoll",
                Content = "Anti-Ragdoll has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAntiRagdoll()
            OrionLib:MakeNotification({
                Name = "Anti-Ragdoll",
                Content = "Anti-Ragdoll has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Auto High Ground Toggle
SurvivalSection:AddToggle({
    Name = "Auto High Ground",
    Default = false,
    Flag = "AutoHighGround",
    Save = true,
    Callback = function(Value)
        Config.AutoHighGround = Value
        
        if Value then
            EnableAutoHighGround()
            OrionLib:MakeNotification({
                Name = "Auto High Ground",
                Content = "Auto High Ground has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAutoHighGround()
            OrionLib:MakeNotification({
                Name = "Auto High Ground",
                Content = "Auto High Ground has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Character Tab
local CharacterTab = Window:MakeTab({
    Name = "Character",
    Icon = "person",
    PremiumOnly = false
})

local MovementSection = CharacterTab:AddSection({
    Name = "Movement"
})

-- Speed Hack Toggle
MovementSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedHack",
    Save = true,
    Callback = function(Value)
        Config.SpeedHack = Value
        
        if Value then
            EnableSpeedHack()
            OrionLib:MakeNotification({
                Name = "Speed Hack",
                Content = "Speed Hack has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableSpeedHack()
            OrionLib:MakeNotification({
                Name = "Speed Hack",
                Content = "Speed Hack has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Speed Multiplier Slider
MovementSection:AddSlider({
    Name = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 0.1,
    Flag = "SpeedMultiplier",
    Save = true,
    ValueName = "x",
    Callback = function(Value)
        Config.SpeedMultiplier = Value
        if Config.SpeedHack then
            UpdateSpeedHack()
        end
    end
})

-- Jump Hack Toggle
MovementSection:AddToggle({
    Name = "Jump Hack",
    Default = false,
    Flag = "JumpHack",
    Save = true,
    Callback = function(Value)
        Config.JumpHack = Value
        
        if Value then
            EnableJumpHack()
            OrionLib:MakeNotification({
                Name = "Jump Hack",
                Content = "Jump Hack has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableJumpHack()
            OrionLib:MakeNotification({
                Name = "Jump Hack",
                Content = "Jump Hack has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Jump Multiplier Slider
MovementSection:AddSlider({
    Name = "Jump Multiplier",
    Min = 1,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 0.1,
    Flag = "JumpMultiplier",
    Save = true,
    ValueName = "x",
    Callback = function(Value)
        Config.JumpMultiplier = Value
        if Config.JumpHack then
            UpdateJumpHack()
        end
    end
})

-- Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "teleport",
    PremiumOnly = false
})

local TeleportSection = TeleportTab:AddSection({
    Name = "Map Teleports"
})

-- Map-specific safe spots
local safeSpots = {
    ["Glass Tower Map"] = Vector3.new(37, 183, 5),
    ["The Hotel Map"] = Vector3.new(20, 159, -3),
    ["The Arch Map"] = Vector3.new(218, 83, 76),
    ["The Lighthouse Map"] = Vector3.new(116, 133, -9),
    ["The Trailer Park Map"] = Vector3.new(133, 30, 0),
    ["The Rakish Refinery Map"] = Vector3.new(-47, 150, 27)
}

-- Add teleport buttons for each map
for mapName, position in pairs(safeSpots) do
    TeleportSection:AddButton({
        Name = "Teleport to " .. mapName .. " Safe Spot",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to " .. mapName .. " safe spot",
                    Image = "teleport",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Could not teleport (character not found)",
                    Image = "warning",
                    Time = 3
                })
            end
        end
    })
end

-- General teleport buttons
local GeneralTeleportSection = TeleportTab:AddSection({
    Name = "General Teleports"
})

-- Teleport to High Ground
GeneralTeleportSection:AddButton({
    Name = "Teleport to Highest Point",
    Callback = function()
        TeleportToHighestPoint()
    end
})

-- Teleport to Lobby
GeneralTeleportSection:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        if workspace:FindFirstChild("Lobby") then
            LocalPlayer.Character:SetPrimaryPartCFrame(workspace.Lobby.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
            
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Teleported to Lobby",
                Image = "teleport",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Could not find Lobby",
                Image = "warning",
                Time = 3
            })
        end
    end
})

-- Teleport to Map
GeneralTeleportSection:AddButton({
    Name = "Teleport to Map",
    Callback = function()
        if workspace:FindFirstChild("Structure") then
            for _, child in pairs(workspace.Structure:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChild("Map") then
                    -- Found the map, teleport to its spawn location or a safe position
                    local spawnLocation = child:FindFirstChild("SpawnLocation") or child:FindFirstChild("Spawn")
                    if spawnLocation then
                        LocalPlayer.Character:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0, 5, 0))
                    else
                        -- Teleport to a safe position on the map
                        local mapCenter = child:FindFirstChild("Map").Position
                        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(mapCenter + Vector3.new(0, 50, 0)))
                    end
                    
                    OrionLib:MakeNotification({
                        Name = "Teleport",
                        Content = "Teleported to Map",
                        Image = "teleport",
                        Time = 3
                    })
                    return
                end
            end
            
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Could not find Map",
                Image = "warning",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Could not find Structure",
                Image = "warning",
                Time = 3
            })
        end
    end
})

-- Player teleport dropdown
local PlayerTeleportSection = TeleportTab:AddSection({
    Name = "Player Teleports"
})

-- Get player list
local playerList = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

-- Player teleport dropdown
PlayerTeleportSection:AddDropdown({
    Name = "Select Player",
    Default = playerList[1] or "No players",
    Flag = "SelectedPlayer",
    Save = false,
    Options = playerList,
    Callback = function(Value)
        -- Store selected player
        _G.SelectedPlayer = Value
    end
})

-- Teleport to selected player button
PlayerTeleportSection:AddButton({
    Name = "Teleport to Player",
    Callback = function()
        if _G.SelectedPlayer then
            local targetPlayer = Players:FindFirstChild(_G.SelectedPlayer)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(targetPlayer.Character.HumanoidRootPart.CFrame)
                
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to " .. _G.SelectedPlayer,
                    Image = "teleport",
                    Time = 3
                })
            else
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Could not teleport to " .. _G.SelectedPlayer,
                    Image = "warning",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "No player selected",
                Image = "warning",
                Time = 3
            })
        end
    end
})

-- Protection Tab
local ProtectionTab = Window:MakeTab({
    Name = "Protection",
    Icon = "shield",
    PremiumOnly = false
})

local AntiSection = ProtectionTab:AddSection({
    Name = "Anti-Detection"
})

-- Anti-AFK Toggle
AntiSection:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Flag = "AntiAFK",
    Save = true,
    Callback = function(Value)
        Config.AntiAFK = Value
        
        if Value then
            EnableAntiAFK()
            OrionLib:MakeNotification({
                Name = "Anti-AFK",
                Content = "Anti-AFK has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAntiAFK()
            OrionLib:MakeNotification({
                Name = "Anti-AFK",
                Content = "Anti-AFK has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings",
    PremiumOnly = false
})

-- UI Theme Dropdown
SettingsTab:AddDropdown({
    Name = "UI Theme",
    Default = "SkyX",
    Flag = "UITheme",
    Save = true,
    Options = {"Default", "Dark", "Light", "Ocean", "Blood", "SkyX"},
    Callback = function(Value)
        OrionLib.Themes:SetTheme(Value)
        OrionLib:MakeNotification({
            Name = "Theme",
            Content = "Theme set to " .. Value,
            Image = "check",
            Time = 3
        })
    end
})

-- Mobile Toggle Position
SettingsTab:AddDropdown({
    Name = "Mobile Toggle Position",
    Default = "TopRight",
    Flag = "MobileTogglePos",
    Save = true,
    Options = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"},
    Callback = function(Value)
        OrionLib.Mobile:SetTogglePosition(Value)
    end
})

-- Toggle Keybind
SettingsTab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Flag = "ToggleUI",
    Save = true,
    Callback = function()
        -- This is handled internally by the UI
    end
})

-- Reset All Button
SettingsTab:AddButton({
    Name = "Reset All Settings",
    Callback = function()
        -- Reset toggle states first
        for flag, _ in pairs(OrionLib.Flags) do
            local toggle = OrionLib.Flags[flag]
            if toggle.Type == "Toggle" then
                toggle:Set(false)
            end
        end
        
        -- Reset Config values
        Config = {
            -- Survival Features
            DisasterPrediction = false,
            AutoFarm = false,
            NoFallDamage = false,
            AntiRagdoll = false,
            AutoHighGround = false,
            
            -- Character Modifications
            SpeedHack = false,
            SpeedMultiplier = 2,
            JumpHack = false,
            JumpMultiplier = 2,
            
            -- Protection
            AntiAFK = true
        }
        
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "All settings have been reset",
            Image = "warning",
            Time = 5
        })
    end
})

-- Credits Tab
local CreditsTab = Window:MakeTab({
    Name = "Credits",
    Icon = "info",
    PremiumOnly = false
})

CreditsTab:AddParagraph("SkyX Hub", "Created by the SkyX Team")
CreditsTab:AddParagraph("UI Library", "Using OrionX UI")
CreditsTab:AddParagraph("Credits", "Thanks to all our users and supporters!")

------------------
-- FUNCTIONALITY
------------------

-- Variables
local disasterPredictionConnection = nil
local autoFarmConnection = nil
local noFallDamageConnection = nil
local antiRagdollConnection = nil
local autoHighGroundConnection = nil
local speedHackConnection = nil
local jumpHackConnection = nil
local antiAFKConnection = nil

-- Disaster Prediction Implementation
function EnableDisasterPrediction()
    if disasterPredictionConnection then
        disasterPredictionConnection:Disconnect()
    end
    
    -- Look for disaster type changes before announcement
    local function checkForDisaster()
        -- Method 1: Check for hidden disaster value
        if workspace:FindFirstChild("DisasterEvent") and workspace.DisasterEvent:FindFirstChild("HiddenDisaster") then
            return workspace.DisasterEvent.HiddenDisaster.Value
        end
        
        -- Method 2: Check for special lighting changes (some disasters change lighting before announcement)
        local lighting = game:GetService("Lighting")
        
        -- Check for specific lighting changes that indicate certain disasters
        if lighting.Ambient == Color3.fromRGB(0, 0, 0) and lighting.OutdoorAmbient == Color3.fromRGB(0, 0, 0) then
            return "Thunderstorm"
        elseif lighting.Ambient == Color3.fromRGB(253, 136, 116) and lighting.Brightness < 0.2 then
            return "Fire"
        elseif lighting.FogEnd < 100 then
            return "Blizzard"
        end
        
        -- Method 3: Check for disaster-specific objects that spawn before announcement
        if workspace:FindFirstChild("Tsunami") then
            return "Tsunami"
        elseif workspace:FindFirstChild("Meteor") then
            return "Meteor"
        elseif workspace:FindFirstChild("Tornado") then
            return "Tornado"
        end
        
        return "Unknown"
    end
    
    disasterPredictionConnection = RunService.Heartbeat:Connect(function()
        if not Config.DisasterPrediction then return end
        
        local predictedDisaster = checkForDisaster()
        
        if predictedDisaster ~= "Unknown" and predictedDisaster ~= currentDisaster then
            OrionLib:MakeNotification({
                Name = "Disaster Prediction",
                Content = "Predicted Disaster: " .. predictedDisaster,
                Image = "warning",
                Time = 5
            })
            
            -- Update the disaster info
            currentDisaster = predictedDisaster
            InfoSection:AddParagraph("Game Status", "Current Map: " .. currentMap .. "\nCurrent Disaster: " .. currentDisaster .. " (Predicted)")
            
            -- Briefly pause to avoid spam notifications
            task.wait(5)
        end
    end)
}

function DisableDisasterPrediction()
    if disasterPredictionConnection then
        disasterPredictionConnection:Disconnect()
        disasterPredictionConnection = nil
    end
}

-- Auto Farm Implementation
function EnableAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
    end
    
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        
        -- Check if we're in a round
        local inRound = false
        if workspace:FindFirstChild("Structure") then
            for _, child in pairs(workspace.Structure:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChild("Map") then
                    inRound = true
                    break
                end
            end
        end
        
        if inRound then
            -- Find the best safe spot based on the current map
            local safePosition = FindSafeSpotForCurrentMap()
            
            -- Teleport to the safe spot
            if safePosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safePosition)
            end
        else
            -- If we're in the lobby, wait for the next round
            -- Try to teleport to the spawn tower
            if workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("SpawnLocation") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Lobby.SpawnLocation.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
        
        -- Wait a bit to avoid constant teleporting
        task.wait(1)
    end)
}

function DisableAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
}

function FindSafeSpotForCurrentMap()
    -- Get the current map name
    local mapName = "Unknown"
    if workspace:FindFirstChild("Structure") then
        for _, child in pairs(workspace.Structure:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Map") then
                mapName = child.Name
                break
            end
        end
    end
    
    -- Return the safe spot for the current map or find the highest point
    if safeSpots[mapName] then
        return safeSpots[mapName]
    else
        -- If no predefined safe spot, find the highest point
        return FindHighestPoint()
    end
}

function FindHighestPoint()
    local highestPoint = nil
    local highestY = -math.huge
    
    -- Check if we're in a round
    if workspace:FindFirstChild("Structure") then
        for _, child in pairs(workspace.Structure:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Map") then
                -- Found the map, now find the highest point
                for _, descendant in pairs(child:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.CanCollide then
                        local topY = descendant.Position.Y + (descendant.Size.Y / 2)
                        if topY > highestY then
                            highestY = topY
                            highestPoint = descendant.Position + Vector3.new(0, descendant.Size.Y / 2 + 3, 0)
                        end
                    end
                end
                break
            end
        end
    end
    
    if highestPoint then
        return highestPoint
    else
        -- Fallback: return a generic high position
        return Vector3.new(0, 200, 0)
    end
}

-- No Fall Damage Implementation
function EnableNoFallDamage()
    if noFallDamageConnection then
        noFallDamageConnection:Disconnect()
    end
    
    noFallDamageConnection = RunService.Heartbeat:Connect(function()
        if not Config.NoFallDamage then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Method 1: Detect fall and prevent damage
        if humanoid.FloorMaterial == Enum.Material.Air and humanoid.Health > 0 then
            -- We're falling
            local velocity = character.HumanoidRootPart.Velocity
            
            -- If we're falling fast, prepare to cancel damage
            if velocity.Y < -50 then
                -- Save position
                local currentPosition = character.HumanoidRootPart.Position
                
                -- Check if we're about to hit the ground
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local rayResult = workspace:Raycast(currentPosition, Vector3.new(0, -10, 0), rayParams)
                
                if rayResult then
                    -- We're about to hit the ground, apply anti-fall damage
                    character.HumanoidRootPart.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
                end
            end
        end
    end)
    
    -- Method 2: Hook the fall damage event or function
    local mt = getrawmetatable(game)
    if setreadonly then
        setreadonly(mt, false)
    end
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "FireServer" and tostring(self) == "FallDamage" and Config.NoFallDamage then
            return
        end
        
        return oldNamecall(self, ...)
    end)
    
    if setreadonly then
        setreadonly(mt, true)
    end
}

function DisableNoFallDamage()
    if noFallDamageConnection then
        noFallDamageConnection:Disconnect()
        noFallDamageConnection = nil
    end
    
    -- Can't unhook metatable, but setting the flag to false will make the hook inactive
}

-- Anti-Ragdoll Implementation
function EnableAntiRagdoll()
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
    end
    
    antiRagdollConnection = RunService.Heartbeat:Connect(function()
        if not Config.AntiRagdoll then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Check if we're ragdolled
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            -- Force normal state
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        -- Disable ragdoll attachments if they exist
        for _, joint in pairs(character:GetDescendants()) do
            if joint:IsA("Attachment") and joint.Name:match("RagdollAttachment") then
                joint.Enabled = false
            end
            -- Disable any BallSocketConstraints that may be used for ragdolling
            if joint:IsA("BallSocketConstraint") then
                joint.Enabled = false
            end
        end
    end)
}

function DisableAntiRagdoll()
    if antiRagdollConnection then
        antiRagdollConnection:Disconnect()
        antiRagdollConnection = nil
    end
}

-- Auto High Ground Implementation
function EnableAutoHighGround()
    if autoHighGroundConnection then
        autoHighGroundConnection:Disconnect()
    end
    
    autoHighGroundConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoHighGround then return end
        
        -- Detect when a disaster starts
        if currentDisaster ~= "Unknown" and currentDisaster ~= "None" then
            -- Teleport to the highest point
            local highestPoint = FindHighestPoint()
            
            if highestPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(highestPoint)
                
                -- Wait a bit to avoid constant teleporting
                task.wait(5)
            end
        end
    end)
}

function DisableAutoHighGround()
    if autoHighGroundConnection then
        autoHighGroundConnection:Disconnect()
        autoHighGroundConnection = nil
    end
}

-- Teleport to Highest Point implementation
function TeleportToHighestPoint()
    local highestPoint = FindHighestPoint()
    
    if highestPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(highestPoint)
        
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "Teleported to highest point",
            Image = "teleport",
            Time = 3
        })
    else
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "Could not find highest point",
            Image = "warning",
            Time = 3
        })
    end
}

-- Speed Hack Implementation
function EnableSpeedHack()
    UpdateSpeedHack()
    
    -- Connect to character added event
    speedHackConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if Config.SpeedHack then
            task.wait(0.5)
            UpdateSpeedHack()
        end
    end)
}

function DisableSpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
        speedHackConnection = nil
    end
    
    -- Reset walkspeed
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
}

function UpdateSpeedHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * Config.SpeedMultiplier
    end
}

-- Jump Hack Implementation
function EnableJumpHack()
    UpdateJumpHack()
    
    -- Connect to character added event
    jumpHackConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if Config.JumpHack then
            task.wait(0.5)
            UpdateJumpHack()
        end
    end)
}

function DisableJumpHack()
    if jumpHackConnection then
        jumpHackConnection:Disconnect()
        jumpHackConnection = nil
    end
    
    -- Reset jump power
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
}

function UpdateJumpHack()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = 50 * Config.JumpMultiplier
    end
}

-- Anti-AFK Implementation
function EnableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
    end
    
    antiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        
        OrionLib:MakeNotification({
            Name = "Anti-AFK",
            Content = "Prevented AFK kick",
            Image = "check",
            Time = 3
        })
    end)
}

function DisableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
}

-- Initialize features based on saved settings
if Config.AntiAFK then
    EnableAntiAFK()
end

-- Initialize the UI
OrionLib:Init()
