--[[
    LAJ HUB v2 - Flee the Facility Script
    Using OrionX UI
    
    Features:
    - ESP for players, computers, and exits
    - Auto-hack computers
    - No crawl (prevent being knocked down)
    - Instant revive teammates
    - Speed and jump modifiers
    - Beast notification (know when you're targeted)
    - Teleport to computers, exits, and players
    - Auto-escape
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
    -- ESP Settings
    PlayerESP = false,
    ShowBeastESP = true,
    ShowSurvivorESP = true,
    BeastColor = Color3.fromRGB(255, 0, 0),
    SurvivorColor = Color3.fromRGB(0, 255, 0),
    ComputerESP = false,
    ComputerColor = Color3.fromRGB(0, 0, 255),
    ExitESP = false,
    ExitColor = Color3.fromRGB(255, 255, 0),
    
    -- Features
    AutoHack = false,
    NoCrawl = false,
    InstantRevive = false,
    BeastAlert = false,
    AutoEscape = false,
    
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
    Name = "LAJ HUB v2 | Flee the Facility", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "LAJHUBv2_FTF",
    IntroEnabled = true,
    IntroText = "LAJ HUB v2",
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

InfoSection:AddParagraph("Welcome to LAJ HUB v2", "The ultimate script for Flee the Facility with ESP, auto-hack, teleports and more.")

-- Get player role
local function GetPlayerRole(player)
    -- Try various ways to detect beast
    local isBeast = false
    
    -- Method 1: Check if player has beast tools
    if player.Backpack then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool.Name == "Hammer" or tool.Name == "Beast" then
                isBeast = true
                break
            end
        end
    end
    
    -- Method 2: Check if player is holding beast tools
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool.Name == "Hammer" or tool.Name == "Beast" then
                isBeast = true
                break
            end
        end
    end
    
    -- Method 3: Check for beast tag/attribute
    if player:GetAttribute("Role") == "Beast" or player:FindFirstChild("Role") and player.Role.Value == "Beast" then
        isBeast = true
    end
    
    return isBeast and "Beast" or "Survivor"
end

-- Display current status
local function UpdateGameStatus()
    local statusText = "Your Role: " .. GetPlayerRole(LocalPlayer)
    
    -- Add info about the beast
    local beastPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Beast" then
            beastPlayer = player
            break
        end
    end
    
    if beastPlayer then
        statusText = statusText .. "\nBeast: " .. beastPlayer.Name
    else
        statusText = statusText .. "\nBeast: Unknown"
    end
    
    -- Add computer info
    local computers = GetComputers()
    local hackedCount = 0
    for _, computer in pairs(computers) do
        if computer:FindFirstChild("Hacked") and computer.Hacked.Value then
            hackedCount = hackedCount + 1
        end
    end
    
    statusText = statusText .. "\nComputers: " .. hackedCount .. "/" .. #computers
    
    InfoSection:AddParagraph("Game Status", statusText)
end

-- Update status periodically
task.spawn(function()
    while true do
        UpdateGameStatus()
        task.wait(5)
    end
end)

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

-- ESP Tab
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "eye",
    PremiumOnly = false
})

local PlayerESPSection = ESPTab:AddSection({
    Name = "Player ESP"
})

-- Player ESP Toggle
PlayerESPSection:AddToggle({
    Name = "Player ESP",
    Default = false,
    Flag = "PlayerESP",
    Save = true,
    Callback = function(Value)
        Config.PlayerESP = Value
        
        if Value then
            EnablePlayerESP()
            OrionLib:MakeNotification({
                Name = "Player ESP",
                Content = "Player ESP has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisablePlayerESP()
            OrionLib:MakeNotification({
                Name = "Player ESP",
                Content = "Player ESP has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Beast ESP Toggle
PlayerESPSection:AddToggle({
    Name = "Show Beast ESP",
    Default = true,
    Flag = "ShowBeastESP",
    Save = true,
    Callback = function(Value)
        Config.ShowBeastESP = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- Survivor ESP Toggle
PlayerESPSection:AddToggle({
    Name = "Show Survivor ESP",
    Default = true,
    Flag = "ShowSurvivorESP",
    Save = true,
    Callback = function(Value)
        Config.ShowSurvivorESP = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- Beast Color Picker
PlayerESPSection:AddColorpicker({
    Name = "Beast Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "BeastColor",
    Save = true,
    Callback = function(Value)
        Config.BeastColor = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- Survivor Color Picker
PlayerESPSection:AddColorpicker({
    Name = "Survivor Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "SurvivorColor",
    Save = true,
    Callback = function(Value)
        Config.SurvivorColor = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

local ObjectESPSection = ESPTab:AddSection({
    Name = "Object ESP"
})

-- Computer ESP Toggle
ObjectESPSection:AddToggle({
    Name = "Computer ESP",
    Default = false,
    Flag = "ComputerESP",
    Save = true,
    Callback = function(Value)
        Config.ComputerESP = Value
        
        if Value then
            EnableComputerESP()
            OrionLib:MakeNotification({
                Name = "Computer ESP",
                Content = "Computer ESP has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableComputerESP()
            OrionLib:MakeNotification({
                Name = "Computer ESP",
                Content = "Computer ESP has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Computer Color Picker
ObjectESPSection:AddColorpicker({
    Name = "Computer Color",
    Default = Color3.fromRGB(0, 0, 255),
    Flag = "ComputerColor",
    Save = true,
    Callback = function(Value)
        Config.ComputerColor = Value
        if Config.ComputerESP then
            UpdateComputerESP()
        end
    end
})

-- Exit ESP Toggle
ObjectESPSection:AddToggle({
    Name = "Exit ESP",
    Default = false,
    Flag = "ExitESP",
    Save = true,
    Callback = function(Value)
        Config.ExitESP = Value
        
        if Value then
            EnableExitESP()
            OrionLib:MakeNotification({
                Name = "Exit ESP",
                Content = "Exit ESP has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableExitESP()
            OrionLib:MakeNotification({
                Name = "Exit ESP",
                Content = "Exit ESP has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Exit Color Picker
ObjectESPSection:AddColorpicker({
    Name = "Exit Color",
    Default = Color3.fromRGB(255, 255, 0),
    Flag = "ExitColor",
    Save = true,
    Callback = function(Value)
        Config.ExitColor = Value
        if Config.ExitESP then
            UpdateExitESP()
        end
    end
})

-- Features Tab
local FeaturesTab = Window:MakeTab({
    Name = "Features",
    Icon = "bolt",
    PremiumOnly = false
})

local HackerSection = FeaturesTab:AddSection({
    Name = "Hacker Features"
})

-- Auto-Hack Toggle
HackerSection:AddToggle({
    Name = "Auto-Hack Computers",
    Default = false,
    Flag = "AutoHack",
    Save = true,
    Callback = function(Value)
        Config.AutoHack = Value
        
        if Value then
            EnableAutoHack()
            OrionLib:MakeNotification({
                Name = "Auto-Hack",
                Content = "Auto-Hack has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAutoHack()
            OrionLib:MakeNotification({
                Name = "Auto-Hack",
                Content = "Auto-Hack has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Auto-Escape Toggle
HackerSection:AddToggle({
    Name = "Auto-Escape",
    Default = false,
    Flag = "AutoEscape",
    Save = true,
    Callback = function(Value)
        Config.AutoEscape = Value
        
        if Value then
            EnableAutoEscape()
            OrionLib:MakeNotification({
                Name = "Auto-Escape",
                Content = "Auto-Escape has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAutoEscape()
            OrionLib:MakeNotification({
                Name = "Auto-Escape",
                Content = "Auto-Escape has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

local SurvivorSection = FeaturesTab:AddSection({
    Name = "Survivor Features"
})

-- No Crawl Toggle
SurvivorSection:AddToggle({
    Name = "No Crawl",
    Default = false,
    Flag = "NoCrawl",
    Save = true,
    Callback = function(Value)
        Config.NoCrawl = Value
        
        if Value then
            EnableNoCrawl()
            OrionLib:MakeNotification({
                Name = "No Crawl",
                Content = "No Crawl has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableNoCrawl()
            OrionLib:MakeNotification({
                Name = "No Crawl",
                Content = "No Crawl has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Instant Revive Toggle
SurvivorSection:AddToggle({
    Name = "Instant Revive",
    Default = false,
    Flag = "InstantRevive",
    Save = true,
    Callback = function(Value)
        Config.InstantRevive = Value
        
        if Value then
            EnableInstantRevive()
            OrionLib:MakeNotification({
                Name = "Instant Revive",
                Content = "Instant Revive has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableInstantRevive()
            OrionLib:MakeNotification({
                Name = "Instant Revive",
                Content = "Instant Revive has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Beast Alert Toggle
SurvivorSection:AddToggle({
    Name = "Beast Alert",
    Default = false,
    Flag = "BeastAlert",
    Save = true,
    Callback = function(Value)
        Config.BeastAlert = Value
        
        if Value then
            EnableBeastAlert()
            OrionLib:MakeNotification({
                Name = "Beast Alert",
                Content = "Beast Alert has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableBeastAlert()
            OrionLib:MakeNotification({
                Name = "Beast Alert",
                Content = "Beast Alert has been disabled",
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
    Max = 5,
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
    Max = 5,
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

local ComputerTeleportSection = TeleportTab:AddSection({
    Name = "Computer Teleports"
})

-- Get all computers for teleport list
local function GetComputers()
    local computers = {}
    
    -- Method 1: Find computers directly
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ComputerTable" or obj.Name == "Computer" then
            table.insert(computers, obj)
        end
    end
    
    return computers
end

-- Computer Teleport Dropdown
ComputerTeleportSection:AddDropdown({
    Name = "Select Computer",
    Default = "Nearest Computer",
    Flag = "SelectedComputer",
    Save = false,
    Options = {"Nearest Computer", "Random Computer", "Nearest Unhacked Computer"},
    Callback = function(Value)
        -- Store selected computer strategy
        _G.SelectedComputer = Value
    end
})

-- Teleport to Computer Button
ComputerTeleportSection:AddButton({
    Name = "Teleport to Computer",
    Callback = function()
        local computers = GetComputers()
        
        if #computers == 0 then
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "No computers found",
                Image = "warning",
                Time = 3
            })
            return
        end
        
        local selectedComputer = nil
        
        if _G.SelectedComputer == "Nearest Computer" or not _G.SelectedComputer then
            -- Find nearest computer
            local nearestDistance = math.huge
            for _, computer in pairs(computers) do
                local distance = (computer:GetModelCFrame().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    selectedComputer = computer
                end
            end
        elseif _G.SelectedComputer == "Random Computer" then
            -- Select a random computer
            selectedComputer = computers[math.random(1, #computers)]
        elseif _G.SelectedComputer == "Nearest Unhacked Computer" then
            -- Find nearest unhacked computer
            local nearestDistance = math.huge
            for _, computer in pairs(computers) do
                if not (computer:FindFirstChild("Hacked") and computer.Hacked.Value) then
                    local distance = (computer:GetModelCFrame().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        selectedComputer = computer
                    end
                end
            end
            
            if not selectedComputer then
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "No unhacked computers found",
                    Image = "warning",
                    Time = 3
                })
                return
            end
        end
        
        if selectedComputer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Find a suitable teleport position near the computer
            local teleportPos = selectedComputer:GetModelCFrame().Position + Vector3.new(0, 3, 0)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPos)
            
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Teleported to computer",
                Image = "teleport",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Failed to teleport",
                Image = "warning",
                Time = 3
            })
        end
    end
})

local ExitTeleportSection = TeleportTab:AddSection({
    Name = "Exit Teleports"
})

-- Get all exits for teleport list
local function GetExits()
    local exits = {}
    
    -- Find exits
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "ExitDoor" or obj.Name == "Exit" or obj.Name == "ExitRegion" then
            table.insert(exits, obj)
        end
    end
    
    return exits
end

-- Exit Teleport Dropdown
ExitTeleportSection:AddDropdown({
    Name = "Select Exit",
    Default = "Nearest Exit",
    Flag = "SelectedExit",
    Save = false,
    Options = {"Nearest Exit", "Random Exit"},
    Callback = function(Value)
        -- Store selected exit strategy
        _G.SelectedExit = Value
    end
})

-- Teleport to Exit Button
ExitTeleportSection:AddButton({
    Name = "Teleport to Exit",
    Callback = function()
        local exits = GetExits()
        
        if #exits == 0 then
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "No exits found",
                Image = "warning",
                Time = 3
            })
            return
        end
        
        local selectedExit = nil
        
        if _G.SelectedExit == "Nearest Exit" or not _G.SelectedExit then
            -- Find nearest exit
            local nearestDistance = math.huge
            for _, exit in pairs(exits) do
                local pos = nil
                if exit:IsA("BasePart") then
                    pos = exit.Position
                elseif exit:IsA("Model") and exit.PrimaryPart then
                    pos = exit.PrimaryPart.Position
                else
                    -- Find a suitable part in the model
                    for _, part in pairs(exit:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pos = part.Position
                            break
                        end
                    end
                end
                
                if pos then
                    local distance = (pos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        selectedExit = exit
                        selectedExitPos = pos
                    end
                end
            end
        elseif _G.SelectedExit == "Random Exit" then
            -- Select a random exit
            selectedExit = exits[math.random(1, #exits)]
            
            if selectedExit:IsA("BasePart") then
                selectedExitPos = selectedExit.Position
            elseif selectedExit:IsA("Model") and selectedExit.PrimaryPart then
                selectedExitPos = selectedExit.PrimaryPart.Position
            else
                -- Find a suitable part in the model
                for _, part in pairs(selectedExit:GetDescendants()) do
                    if part:IsA("BasePart") then
                        selectedExitPos = part.Position
                        break
                    end
                end
            end
        end
        
        if selectedExitPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport near the exit
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(selectedExitPos + Vector3.new(0, 3, 0))
            
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Teleported to exit",
                Image = "teleport",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "Failed to teleport",
                Image = "warning",
                Time = 3
            })
        end
    end
})

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
            -- ESP Settings
            PlayerESP = false,
            ShowBeastESP = true,
            ShowSurvivorESP = true,
            BeastColor = Color3.fromRGB(255, 0, 0),
            SurvivorColor = Color3.fromRGB(0, 255, 0),
            ComputerESP = false,
            ComputerColor = Color3.fromRGB(0, 0, 255),
            ExitESP = false,
            ExitColor = Color3.fromRGB(255, 255, 0),
            
            -- Features
            AutoHack = false,
            NoCrawl = false,
            InstantRevive = false,
            BeastAlert = false,
            AutoEscape = false,
            
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
local playerESPObjects = {}
local computerESPObjects = {}
local exitESPObjects = {}
local playerESPConnection = nil
local computerESPConnection = nil
local exitESPConnection = nil
local autoHackConnection = nil
local noCrawlConnection = nil
local instantReviveConnection = nil
local beastAlertConnection = nil
local autoEscapeConnection = nil
local speedHackConnection = nil
local jumpHackConnection = nil
local antiAFKConnection = nil

-- Helper functions
function IsAlive(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
        return player.Character.Humanoid.Health > 0
    end
    return false
end

-- Player ESP Implementation
function EnablePlayerESP()
    DisablePlayerESP() -- Clear existing ESP
    
    -- Create ESP for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreatePlayerESP(player)
        end
    end
    
    -- Connect events for new players
    playerESPConnection = Players.PlayerAdded:Connect(function(player)
        CreatePlayerESP(player)
    end)
    
    -- Update ESP periodically
    RunService:BindToRenderStep("PlayerESP", 5, function()
        UpdatePlayerESP()
    end)
}

function DisablePlayerESP()
    -- Disconnect events
    if playerESPConnection then
        playerESPConnection:Disconnect()
        playerESPConnection = nil
    end
    
    -- Unbind render step
    pcall(function()
        RunService:UnbindFromRenderStep("PlayerESP")
    end)
    
    -- Remove ESP from all players
    for playerName, espItems in pairs(playerESPObjects) do
        for _, item in pairs(espItems) do
            if item and typeof(item) == "table" and item.Remove then
                item:Remove()
            end
        end
    end
    
    playerESPObjects = {}
}

function CreatePlayerESP(player)
    -- Skip if we already have this player
    if playerESPObjects[player.Name] then
        return
    end
    
    -- Determine if player is Beast or Survivor
    local role = GetPlayerRole(player)
    
    -- Skip if ESP for this role is disabled
    if (role == "Beast" and not Config.ShowBeastESP) or (role == "Survivor" and not Config.ShowSurvivorESP) then
        return
    end
    
    playerESPObjects[player.Name] = {}
    
    -- Create Box ESP
    local boxESP = Drawing.new("Square")
    boxESP.Visible = false
    boxESP.Color = role == "Beast" and Config.BeastColor or Config.SurvivorColor
    boxESP.Thickness = 2
    boxESP.Transparency = 1
    boxESP.Filled = false
    playerESPObjects[player.Name].Box = boxESP
    
    -- Create Name ESP
    local nameESP = Drawing.new("Text")
    nameESP.Visible = false
    nameESP.Color = role == "Beast" and Config.BeastColor or Config.SurvivorColor
    nameESP.Size = 18
    nameESP.Center = true
    nameESP.Outline = true
    nameESP.Font = 2
    nameESP.Text = player.Name .. " (" .. role .. ")"
    playerESPObjects[player.Name].Name = nameESP
    
    -- Create Distance ESP
    local distanceESP = Drawing.new("Text")
    distanceESP.Visible = false
    distanceESP.Color = role == "Beast" and Config.BeastColor or Config.SurvivorColor
    distanceESP.Size = 16
    distanceESP.Center = true
    distanceESP.Outline = true
    distanceESP.Font = 2
    playerESPObjects[player.Name].Distance = distanceESP
}

function UpdatePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = GetPlayerRole(player)
            
            -- Skip if ESP for this role is disabled
            if (role == "Beast" and not Config.ShowBeastESP) or (role == "Survivor" and not Config.ShowSurvivorESP) then
                if playerESPObjects[player.Name] then
                    for _, item in pairs(playerESPObjects[player.Name]) do
                        item.Visible = false
                    end
                end
                continue
            end
            
            -- Create ESP if it doesn't exist
            if not playerESPObjects[player.Name] then
                CreatePlayerESP(player)
            end
            
            -- Skip if player is not alive
            if not IsAlive(player) then
                if playerESPObjects[player.Name] then
                    for _, item in pairs(playerESPObjects[player.Name]) do
                        item.Visible = false
                    end
                end
                continue
            end
            
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if not rootPart or not head then
                if playerESPObjects[player.Name] then
                    for _, item in pairs(playerESPObjects[player.Name]) do
                        item.Visible = false
                    end
                end
                continue
            end
            
            -- Update role in case it changed
            local currentRole = GetPlayerRole(player)
            local espColor = currentRole == "Beast" and Config.BeastColor or Config.SurvivorColor
            
            -- Calculate 3D position and size
            local rootPos = rootPart.Position
            local headPos = head.Position + Vector3.new(0, 0.5, 0)
            local distance = (rootPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            
            -- Convert to screen position
            local rootScreenPos, rootOnScreen = Workspace.CurrentCamera:WorldToScreenPoint(rootPos)
            local headScreenPos, headOnScreen = Workspace.CurrentCamera:WorldToScreenPoint(headPos)
            
            if not rootOnScreen and not headOnScreen then
                if playerESPObjects[player.Name] then
                    for _, item in pairs(playerESPObjects[player.Name]) do
                        item.Visible = false
                    end
                end
                continue
            end
            
            -- Calculate box size based on character size
            local boxSize = headScreenPos.Y - rootScreenPos.Y
            local boxWidth = boxSize / 2
            
            -- Update Box ESP
            local box = playerESPObjects[player.Name].Box
            box.Size = Vector2.new(boxWidth, boxSize)
            box.Position = Vector2.new(rootScreenPos.X - boxWidth / 2, rootScreenPos.Y - boxSize / 2)
            box.Color = espColor
            box.Visible = true
            
            -- Update Name ESP
            local nameESP = playerESPObjects[player.Name].Name
            nameESP.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 25)
            nameESP.Text = player.Name .. " (" .. currentRole .. ")"
            nameESP.Color = espColor
            nameESP.Visible = true
            
            -- Update Distance ESP
            local distanceESP = playerESPObjects[player.Name].Distance
            distanceESP.Position = Vector2.new(rootScreenPos.X, rootScreenPos.Y + 15)
            distanceESP.Text = math.floor(distance) .. " studs"
            distanceESP.Color = espColor
            distanceESP.Visible = true
        end
    end
}

-- Computer ESP Implementation
function EnableComputerESP()
    DisableComputerESP() -- Clear existing ESP
    
    -- Create ESP for all computers
    local computers = GetComputers()
    for _, computer in pairs(computers) do
        CreateComputerESP(computer)
    end
    
    -- Update ESP periodically
    computerESPConnection = RunService.Heartbeat:Connect(function()
        if not Config.ComputerESP then return end
        
        -- Check for new computers
        local currentComputers = GetComputers()
        for _, computer in pairs(currentComputers) do
            if not computerESPObjects[computer:GetFullName()] then
                CreateComputerESP(computer)
            end
        end
        
        -- Update positions
        UpdateComputerESP()
    end)
}

function DisableComputerESP()
    -- Disconnect events
    if computerESPConnection then
        computerESPConnection:Disconnect()
        computerESPConnection = nil
    end
    
    -- Remove ESP from all computers
    for computerName, espItems in pairs(computerESPObjects) do
        for _, item in pairs(espItems) do
            if item and typeof(item) == "table" and item.Remove then
                item:Remove()
            end
        end
    end
    
    computerESPObjects = {}
}

function CreateComputerESP(computer)
    -- Skip if we already have this computer
    if computerESPObjects[computer:GetFullName()] then
        return
    end
    
    computerESPObjects[computer:GetFullName()] = {}
    
    -- Create Text ESP
    local textESP = Drawing.new("Text")
    textESP.Visible = false
    textESP.Color = Config.ComputerColor
    textESP.Size = 18
    textESP.Center = true
    textESP.Outline = true
    textESP.Font = 2
    
    -- Set text based on computer status
    local isHacked = computer:FindFirstChild("Hacked") and computer.Hacked.Value
    textESP.Text = isHacked and "Computer (Hacked)" or "Computer"
    
    computerESPObjects[computer:GetFullName()].Text = textESP
    
    -- Create Distance ESP
    local distanceESP = Drawing.new("Text")
    distanceESP.Visible = false
    distanceESP.Color = Config.ComputerColor
    distanceESP.Size = 16
    distanceESP.Center = true
    distanceESP.Outline = true
    distanceESP.Font = 2
    computerESPObjects[computer:GetFullName()].Distance = distanceESP
}

function UpdateComputerESP()
    -- Update computer ESP positions
    for computerName, espItems in pairs(computerESPObjects) do
        local computer = game:FindFirstChild(computerName, true)
        
        if not computer then
            -- Computer no longer exists, remove ESP
            for _, item in pairs(espItems) do
                if item.Remove then
                    item:Remove()
                end
            end
            computerESPObjects[computerName] = nil
            continue
        end
        
        -- Get computer position
        local computerPos = nil
        if computer:IsA("BasePart") then
            computerPos = computer.Position
        elseif computer:IsA("Model") then
            if computer.PrimaryPart then
                computerPos = computer.PrimaryPart.Position
            else
                -- Find a suitable part in the model
                for _, part in pairs(computer:GetDescendants()) do
                    if part:IsA("BasePart") then
                        computerPos = part.Position
                        break
                    end
                end
            end
        end
        
        if not computerPos then
            -- Can't determine position, hide ESP
            for _, item in pairs(espItems) do
                item.Visible = false
            end
            continue
        end
        
        -- Convert to screen position
        local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(computerPos)
        
        if not onScreen then
            -- Computer is off screen, hide ESP
            for _, item in pairs(espItems) do
                item.Visible = false
            end
            continue
        end
        
        -- Calculate distance
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            distance = (computerPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        
        -- Update text ESP with hacked status
        local isHacked = computer:FindFirstChild("Hacked") and computer.Hacked.Value
        espItems.Text.Text = isHacked and "Computer (Hacked)" or "Computer"
        espItems.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
        espItems.Text.Color = Config.ComputerColor
        espItems.Text.Visible = true
        
        -- Update distance ESP
        espItems.Distance.Position = Vector2.new(screenPos.X, screenPos.Y)
        espItems.Distance.Text = math.floor(distance) .. " studs"
        espItems.Distance.Color = Config.ComputerColor
        espItems.Distance.Visible = true
    end
}

-- Exit ESP Implementation
function EnableExitESP()
    DisableExitESP() -- Clear existing ESP
    
    -- Create ESP for all exits
    local exits = GetExits()
    for _, exit in pairs(exits) do
        CreateExitESP(exit)
    end
    
    -- Update ESP periodically
    exitESPConnection = RunService.Heartbeat:Connect(function()
        if not Config.ExitESP then return end
        
        -- Check for new exits
        local currentExits = GetExits()
        for _, exit in pairs(currentExits) do
            if not exitESPObjects[exit:GetFullName()] then
                CreateExitESP(exit)
            end
        end
        
        -- Update positions
        UpdateExitESP()
    end)
}

function DisableExitESP()
    -- Disconnect events
    if exitESPConnection then
        exitESPConnection:Disconnect()
        exitESPConnection = nil
    end
    
    -- Remove ESP from all exits
    for exitName, espItems in pairs(exitESPObjects) do
        for _, item in pairs(espItems) do
            if item and typeof(item) == "table" and item.Remove then
                item:Remove()
            end
        end
    end
    
    exitESPObjects = {}
}

function CreateExitESP(exit)
    -- Skip if we already have this exit
    if exitESPObjects[exit:GetFullName()] then
        return
    end
    
    exitESPObjects[exit:GetFullName()] = {}
    
    -- Create Text ESP
    local textESP = Drawing.new("Text")
    textESP.Visible = false
    textESP.Color = Config.ExitColor
    textESP.Size = 18
    textESP.Center = true
    textESP.Outline = true
    textESP.Font = 2
    textESP.Text = "Exit"
    exitESPObjects[exit:GetFullName()].Text = textESP
    
    -- Create Distance ESP
    local distanceESP = Drawing.new("Text")
    distanceESP.Visible = false
    distanceESP.Color = Config.ExitColor
    distanceESP.Size = 16
    distanceESP.Center = true
    distanceESP.Outline = true
    distanceESP.Font = 2
    exitESPObjects[exit:GetFullName()].Distance = distanceESP
}

function UpdateExitESP()
    -- Update exit ESP positions
    for exitName, espItems in pairs(exitESPObjects) do
        local exit = game:FindFirstChild(exitName, true)
        
        if not exit then
            -- Exit no longer exists, remove ESP
            for _, item in pairs(espItems) do
                if item.Remove then
                    item:Remove()
                end
            end
            exitESPObjects[exitName] = nil
            continue
        end
        
        -- Get exit position
        local exitPos = nil
        if exit:IsA("BasePart") then
            exitPos = exit.Position
        elseif exit:IsA("Model") then
            if exit.PrimaryPart then
                exitPos = exit.PrimaryPart.Position
            else
                -- Find a suitable part in the model
                for _, part in pairs(exit:GetDescendants()) do
                    if part:IsA("BasePart") then
                        exitPos = part.Position
                        break
                    end
                end
            end
        end
        
        if not exitPos then
            -- Can't determine position, hide ESP
            for _, item in pairs(espItems) do
                item.Visible = false
            end
            continue
        end
        
        -- Convert to screen position
        local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(exitPos)
        
        if not onScreen then
            -- Exit is off screen, hide ESP
            for _, item in pairs(espItems) do
                item.Visible = false
            end
            continue
        end
        
        -- Calculate distance
        local distance = 0
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            distance = (exitPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        end
        
        -- Update text ESP
        espItems.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 25)
        espItems.Text.Color = Config.ExitColor
        espItems.Text.Visible = true
        
        -- Update distance ESP
        espItems.Distance.Position = Vector2.new(screenPos.X, screenPos.Y)
        espItems.Distance.Text = math.floor(distance) .. " studs"
        espItems.Distance.Color = Config.ExitColor
        espItems.Distance.Visible = true
    end
}

-- Auto-Hack Implementation
function EnableAutoHack()
    if autoHackConnection then
        autoHackConnection:Disconnect()
    end
    
    autoHackConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoHack then return end
        
        -- Check if we're not the beast
        if GetPlayerRole(LocalPlayer) == "Beast" then return end
        
        -- Check if we're not crawling
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Physics then
                return -- We're crawling, can't hack
            end
        end
        
        -- Find nearby computers that aren't hacked
        local computers = GetComputers()
        for _, computer in pairs(computers) do
            -- Check if computer is not already hacked
            if not (computer:FindFirstChild("Hacked") and computer.Hacked.Value) then
                -- Check if we're close enough to hack
                local computerPos = nil
                if computer:IsA("BasePart") then
                    computerPos = computer.Position
                elseif computer:IsA("Model") then
                    if computer.PrimaryPart then
                        computerPos = computer.PrimaryPart.Position
                    else
                        -- Find a suitable part in the model
                        for _, part in pairs(computer:GetDescendants()) do
                            if part:IsA("BasePart") then
                                computerPos = part.Position
                                break
                            end
                        end
                    end
                end
                
                if computerPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (computerPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= 10 then -- If we're close enough
                        -- Send the remote event for hacking computers
                        local hackEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or 
                                        ReplicatedStorage:FindFirstChild("Hack") or
                                        ReplicatedStorage:FindFirstChild("HackComputer")
                        
                        if hackEvent then
                            hackEvent:FireServer(computer)
                        else
                            -- Try alternate method
                            for _, event in pairs(ReplicatedStorage:GetDescendants()) do
                                if event:IsA("RemoteEvent") and (event.Name:lower():find("hack") or event.Name:lower():find("computer")) then
                                    event:FireServer(computer)
                                    break
                                end
                            end
                        end
                        
                        -- Wait a bit to avoid spamming the server
                        task.wait(0.5)
                    end
                end
            end
        end
    end)
}

function DisableAutoHack()
    if autoHackConnection then
        autoHackConnection:Disconnect()
        autoHackConnection = nil
    end
}

-- No Crawl Implementation
function EnableNoCrawl()
    if noCrawlConnection then
        noCrawlConnection:Disconnect()
    end
    
    noCrawlConnection = RunService.Heartbeat:Connect(function()
        if not Config.NoCrawl then return end
        
        -- Check if we're crawling
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Physics then
                -- Force normal state
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                
                -- Also try to send the remote event for getting up
                local getUpEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or 
                                 ReplicatedStorage:FindFirstChild("GetUp") or
                                 ReplicatedStorage:FindFirstChild("Revive")
                
                if getUpEvent then
                    getUpEvent:FireServer(LocalPlayer.Character)
                else
                    -- Try alternate method
                    for _, event in pairs(ReplicatedStorage:GetDescendants()) do
                        if event:IsA("RemoteEvent") and (event.Name:lower():find("getup") or event.Name:lower():find("revive")) then
                            event:FireServer(LocalPlayer.Character)
                            break
                        end
                    end
                end
            end
        end
    end)
}

function DisableNoCrawl()
    if noCrawlConnection then
        noCrawlConnection:Disconnect()
        noCrawlConnection = nil
    end
}

-- Instant Revive Implementation
function EnableInstantRevive()
    if instantReviveConnection then
        instantReviveConnection:Disconnect()
    end
    
    instantReviveConnection = RunService.Heartbeat:Connect(function()
        if not Config.InstantRevive then return end
        
        -- Check if we're not the beast
        if GetPlayerRole(LocalPlayer) == "Beast" then return end
        
        -- Find downed players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                -- Check if player is downed (crawling)
                if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then
                    -- Check if we're close enough
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        
                        if distance <= 10 then -- If we're close enough
                            -- Send the remote event for reviving
                            local reviveEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or 
                                             ReplicatedStorage:FindFirstChild("Revive") or
                                             ReplicatedStorage:FindFirstChild("RevivePlayer")
                            
                            if reviveEvent then
                                reviveEvent:FireServer(player.Character)
                            else
                                -- Try alternate method
                                for _, event in pairs(ReplicatedStorage:GetDescendants()) do
                                    if event:IsA("RemoteEvent") and (event.Name:lower():find("revive") or event.Name:lower():find("getup")) then
                                        event:FireServer(player.Character)
                                        break
                                    end
                                end
                            end
                            
                            -- Notify that we revived someone
                            OrionLib:MakeNotification({
                                Name = "Instant Revive",
                                Content = "Revived " .. player.Name,
                                Image = "check",
                                Time = 2
                            })
                            
                            -- Wait a bit to avoid spamming the server
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end)
}

function DisableInstantRevive()
    if instantReviveConnection then
        instantReviveConnection:Disconnect()
        instantReviveConnection = nil
    end
}

-- Beast Alert Implementation
function EnableBeastAlert()
    if beastAlertConnection then
        beastAlertConnection:Disconnect()
    end
    
    -- Find the beast
    local beastPlayer = nil
    for _, player in pairs(Players:GetPlayers()) do
        if GetPlayerRole(player) == "Beast" then
            beastPlayer = player
            break
        end
    end
    
    -- Store the last alert time to avoid spam
    _G.LastBeastAlertTime = 0
    
    beastAlertConnection = RunService.Heartbeat:Connect(function()
        if not Config.BeastAlert then return end
        
        -- Check if we're not the beast
        if GetPlayerRole(LocalPlayer) == "Beast" then return end
        
        -- Find the beast
        local beastPlayer = nil
        for _, player in pairs(Players:GetPlayers()) do
            if GetPlayerRole(player) == "Beast" then
                beastPlayer = player
                break
            end
        end
        
        if beastPlayer and beastPlayer.Character and LocalPlayer.Character then
            -- Check distance to beast
            local distance = (beastPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            
            -- If beast is close and we haven't alerted recently
            if distance <= 30 and tick() - _G.LastBeastAlertTime > 5 then
                -- Play alert sound if possible
                if LocalPlayer.PlayerGui then
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://138081509" -- Alert sound
                    sound.Volume = 1
                    sound.Parent = LocalPlayer.PlayerGui
                    sound:Play()
                    
                    game:GetService("Debris"):AddItem(sound, 2)
                end
                
                -- Notify the player
                OrionLib:MakeNotification({
                    Name = "Beast Alert",
                    Content = "Beast is nearby! Distance: " .. math.floor(distance) .. " studs",
                    Image = "warning",
                    Time = 5
                })
                
                -- Update last alert time
                _G.LastBeastAlertTime = tick()
            end
        end
    end)
}

function DisableBeastAlert()
    if beastAlertConnection then
        beastAlertConnection:Disconnect()
        beastAlertConnection = nil
    end
}

-- Auto-Escape Implementation
function EnableAutoEscape()
    if autoEscapeConnection then
        autoEscapeConnection:Disconnect()
    end
    
    autoEscapeConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoEscape then return end
        
        -- Check if all computers are hacked
        local computers = GetComputers()
        local allHacked = true
        for _, computer in pairs(computers) do
            if not (computer:FindFirstChild("Hacked") and computer.Hacked.Value) then
                allHacked = false
                break
            end
        end
        
        if allHacked then
            -- Find the nearest exit
            local exits = GetExits()
            local nearestExit = nil
            local nearestDistance = math.huge
            local nearestPos = nil
            
            for _, exit in pairs(exits) do
                local exitPos = nil
                if exit:IsA("BasePart") then
                    exitPos = exit.Position
                elseif exit:IsA("Model") then
                    if exit.PrimaryPart then
                        exitPos = exit.PrimaryPart.Position
                    else
                        -- Find a suitable part in the model
                        for _, part in pairs(exit:GetDescendants()) do
                            if part:IsA("BasePart") then
                                exitPos = part.Position
                                break
                            end
                        end
                    end
                end
                
                if exitPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (exitPos - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestExit = exit
                        nearestPos = exitPos
                    end
                end
            end
            
            if nearestPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                -- Check if we're close to the exit
                if nearestDistance <= 10 then
                    -- Try to use the exit
                    local exitEvent = ReplicatedStorage:FindFirstChild("RemoteEvent") or 
                                    ReplicatedStorage:FindFirstChild("ExitDoor") or
                                    ReplicatedStorage:FindFirstChild("UseExit")
                    
                    if exitEvent then
                        exitEvent:FireServer(nearestExit)
                    else
                        -- Try alternate method
                        for _, event in pairs(ReplicatedStorage:GetDescendants()) do
                            if event:IsA("RemoteEvent") and (event.Name:lower():find("exit") or event.Name:lower():find("door")) then
                                event:FireServer(nearestExit)
                                break
                            end
                        end
                    end
                else
                    -- Move towards the exit
                    LocalPlayer.Character.Humanoid:MoveTo(nearestPos)
                end
            end
        end
    end)
}

function DisableAutoEscape()
    if autoEscapeConnection then
        autoEscapeConnection:Disconnect()
        autoEscapeConnection = nil
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
