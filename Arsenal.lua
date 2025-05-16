--[[
    LAJ HUB v2 - Arsenal Script
    Using OrionX UI
    
    Features:
    - Silent Aim with customizable FOV
    - Wallbang (shoot through walls)
    - ESP for players (with team color)
    - Gun Mods (no recoil, no spread, infinite ammo)
    - Speed and jump modifiers
    - Anti-AFK
]]

-- Load the Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local Config = {
    -- Combat
    SilentAim = false,
    SilentAimFOV = 150,
    ShowFOV = true,
    Wallbang = false,
    HeadshotsOnly = true,
    TeamCheck = true,
    
    -- ESP
    PlayerESP = false,
    ESPShowTeam = true,
    ESPShowName = true,
    ESPShowDistance = true,
    ESPShowHealth = true,
    
    -- Gun Mods
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InfiniteAmmo = false,
    FullAuto = false,
    
    -- Character
    SpeedHack = false,
    SpeedMultiplier = 2,
    JumpHack = false,
    JumpMultiplier = 2,
    
    -- Protection
    AntiAFK = true,
    AutoRejoin = true
}

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "LAJ HUB v2 | Arsenal", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "LAJHUBv2_Arsenal",
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

InfoSection:AddParagraph("Welcome to LAJ HUB v2", "The ultimate script for Arsenal with silent aim, ESP, gun mods and more.")

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

-- Combat Tab
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "sword",
    PremiumOnly = false
})

local AimbotSection = CombatTab:AddSection({
    Name = "Silent Aim"
})

-- Silent Aim Toggle
AimbotSection:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Save = true,
    Callback = function(Value)
        Config.SilentAim = Value
        
        if Value then
            EnableSilentAim()
            OrionLib:MakeNotification({
                Name = "Silent Aim",
                Content = "Silent Aim has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableSilentAim()
            OrionLib:MakeNotification({
                Name = "Silent Aim",
                Content = "Silent Aim has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- FOV Slider
AimbotSection:AddSlider({
    Name = "FOV",
    Min = 50,
    Max = 800,
    Default = 150,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 5,
    Flag = "SilentAimFOV",
    Save = true,
    ValueName = "px",
    Callback = function(Value)
        Config.SilentAimFOV = Value
        UpdateFOVCircle()
    end
})

-- Show FOV Toggle
AimbotSection:AddToggle({
    Name = "Show FOV",
    Default = true,
    Flag = "ShowFOV",
    Save = true,
    Callback = function(Value)
        Config.ShowFOV = Value
        UpdateFOVCircle()
    end
})

-- Headshots Only Toggle
AimbotSection:AddToggle({
    Name = "Headshots Only",
    Default = true,
    Flag = "HeadshotsOnly",
    Save = true,
    Callback = function(Value)
        Config.HeadshotsOnly = Value
    end
})

-- Team Check Toggle
AimbotSection:AddToggle({
    Name = "Team Check",
    Default = true,
    Flag = "TeamCheck",
    Save = true,
    Callback = function(Value)
        Config.TeamCheck = Value
    end
})

-- Wallbang Toggle
AimbotSection:AddToggle({
    Name = "Wallbang",
    Default = false,
    Flag = "Wallbang",
    Save = true,
    Callback = function(Value)
        Config.Wallbang = Value
        
        if Value then
            EnableWallbang()
            OrionLib:MakeNotification({
                Name = "Wallbang",
                Content = "Wallbang has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableWallbang()
            OrionLib:MakeNotification({
                Name = "Wallbang",
                Content = "Wallbang has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Gun Mods Section
local GunModsSection = CombatTab:AddSection({
    Name = "Gun Mods"
})

-- No Recoil Toggle
GunModsSection:AddToggle({
    Name = "No Recoil",
    Default = false,
    Flag = "NoRecoil",
    Save = true,
    Callback = function(Value)
        Config.NoRecoil = Value
        
        if Value then
            EnableNoRecoil()
            OrionLib:MakeNotification({
                Name = "No Recoil",
                Content = "No Recoil has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableNoRecoil()
            OrionLib:MakeNotification({
                Name = "No Recoil",
                Content = "No Recoil has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- No Spread Toggle
GunModsSection:AddToggle({
    Name = "No Spread",
    Default = false,
    Flag = "NoSpread",
    Save = true,
    Callback = function(Value)
        Config.NoSpread = Value
        
        if Value then
            EnableNoSpread()
            OrionLib:MakeNotification({
                Name = "No Spread",
                Content = "No Spread has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableNoSpread()
            OrionLib:MakeNotification({
                Name = "No Spread",
                Content = "No Spread has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Rapid Fire Toggle
GunModsSection:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Flag = "RapidFire",
    Save = true,
    Callback = function(Value)
        Config.RapidFire = Value
        
        if Value then
            EnableRapidFire()
            OrionLib:MakeNotification({
                Name = "Rapid Fire",
                Content = "Rapid Fire has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableRapidFire()
            OrionLib:MakeNotification({
                Name = "Rapid Fire",
                Content = "Rapid Fire has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Infinite Ammo Toggle
GunModsSection:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Flag = "InfiniteAmmo",
    Save = true,
    Callback = function(Value)
        Config.InfiniteAmmo = Value
        
        if Value then
            EnableInfiniteAmmo()
            OrionLib:MakeNotification({
                Name = "Infinite Ammo",
                Content = "Infinite Ammo has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableInfiniteAmmo()
            OrionLib:MakeNotification({
                Name = "Infinite Ammo",
                Content = "Infinite Ammo has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Full Auto Toggle
GunModsSection:AddToggle({
    Name = "Full Auto",
    Default = false,
    Flag = "FullAuto",
    Save = true,
    Callback = function(Value)
        Config.FullAuto = Value
        
        if Value then
            EnableFullAuto()
            OrionLib:MakeNotification({
                Name = "Full Auto",
                Content = "Full Auto has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableFullAuto()
            OrionLib:MakeNotification({
                Name = "Full Auto",
                Content = "Full Auto has been disabled",
                Image = "close",
                Time = 3
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

local ESPSection = ESPTab:AddSection({
    Name = "Player ESP"
})

-- Player ESP Toggle
ESPSection:AddToggle({
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

-- ESP Show Team Toggle
ESPSection:AddToggle({
    Name = "Show Team",
    Default = true,
    Flag = "ESPShowTeam",
    Save = true,
    Callback = function(Value)
        Config.ESPShowTeam = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- ESP Show Name Toggle
ESPSection:AddToggle({
    Name = "Show Names",
    Default = true,
    Flag = "ESPShowName",
    Save = true,
    Callback = function(Value)
        Config.ESPShowName = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- ESP Show Distance Toggle
ESPSection:AddToggle({
    Name = "Show Distance",
    Default = true,
    Flag = "ESPShowDistance",
    Save = true,
    Callback = function(Value)
        Config.ESPShowDistance = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
        end
    end
})

-- ESP Show Health Toggle
ESPSection:AddToggle({
    Name = "Show Health",
    Default = true,
    Flag = "ESPShowHealth",
    Save = true,
    Callback = function(Value)
        Config.ESPShowHealth = Value
        if Config.PlayerESP then
            UpdatePlayerESP()
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

-- Auto Rejoin Toggle
AntiSection:AddToggle({
    Name = "Auto Rejoin",
    Default = true,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        Config.AutoRejoin = Value
        
        if Value then
            EnableAutoRejoin()
            OrionLib:MakeNotification({
                Name = "Auto Rejoin",
                Content = "Auto Rejoin has been enabled",
                Image = "check",
                Time = 3
            })
        else
            DisableAutoRejoin()
            OrionLib:MakeNotification({
                Name = "Auto Rejoin",
                Content = "Auto Rejoin has been disabled",
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
            -- Combat
            SilentAim = false,
            SilentAimFOV = 150,
            ShowFOV = true,
            Wallbang = false,
            HeadshotsOnly = true,
            TeamCheck = true,
            
            -- ESP
            PlayerESP = false,
            ESPShowTeam = true,
            ESPShowName = true,
            ESPShowDistance = true,
            ESPShowHealth = true,
            
            -- Gun Mods
            NoRecoil = false,
            NoSpread = false,
            RapidFire = false,
            InfiniteAmmo = false,
            FullAuto = false,
            
            -- Character
            SpeedHack = false,
            SpeedMultiplier = 2,
            JumpHack = false,
            JumpMultiplier = 2,
            
            -- Protection
            AntiAFK = true,
            AutoRejoin = true
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

CreditsTab:AddParagraph("LAJ HUB v2", "Created by the LAJ HUB Team")
CreditsTab:AddParagraph("UI Library", "Using OrionX UI")
CreditsTab:AddParagraph("Credits", "Thanks to all our users and supporters!")

------------------
-- FUNCTIONALITY
------------------

-- Variables
local playerESPObjects = {}
local fovCircle = nil
local silentAimConnection = nil
local playerESPConnection = nil
local speedHackConnection = nil
local jumpHackConnection = nil
local antiAFKConnection = nil
local autoRejoinConnection = nil
local originalGunModules = {}

-- Helper Functions
function IsAlive(player)
    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
        return player.Character.Humanoid.Health > 0
    end
    return false
end

function IsVisible(character, part)
    if not character or not part then return false end
    
    local origin = Workspace.CurrentCamera.CFrame.Position
    local direction = (part.Position - origin).Unit * 100
    
    local ray = Ray.new(origin, direction)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {Workspace.CurrentCamera, LocalPlayer.Character}, false, true)
    
    if hit and hit:IsDescendantOf(character) then
        return true
    end
    
    return false
end

function IsTeammate(player)
    if not Config.TeamCheck then return false end
    
    -- Arsenal uses different team systems in different modes
    -- Method 1: Basic team system
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    
    -- Method 2: Team color system
    if player.TeamColor and LocalPlayer.TeamColor then
        return player.TeamColor == LocalPlayer.TeamColor
    end
    
    -- Method 3: Custom properties
    if player:FindFirstChild("TeamName") and LocalPlayer:FindFirstChild("TeamName") then
        return player.TeamName.Value == LocalPlayer.TeamName.Value
    end
    
    -- Default (failsafe)
    return false
end

function GetTeamColor(player)
    -- Try to get team color
    if player.Team then
        return player.Team.TeamColor.Color
    end
    
    if player.TeamColor then
        return player.TeamColor.Color
    end
    
    -- Default
    return Color3.fromRGB(255, 0, 0)
end

-- FOV Circle Setup
function SetupFOVCircle()
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 36
    fovCircle.Radius = Config.SilentAimFOV
    fovCircle.Filled = false
    fovCircle.Visible = Config.ShowFOV
    fovCircle.ZIndex = 999
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    
    -- Update circle position on RenderStepped
    RunService:BindToRenderStep("FOVCircle", 1, function()
        fovCircle.Position = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
    end)
end

function UpdateFOVCircle()
    if fovCircle then
        fovCircle.Radius = Config.SilentAimFOV
        fovCircle.Visible = Config.ShowFOV and Config.SilentAim
    end
end

-- Silent Aim Implementation
function EnableSilentAim()
    if not fovCircle then
        SetupFOVCircle()
    else
        UpdateFOVCircle()
    end
    
    -- Arsenal specific implementation
    local GunScript = nil
    
    -- Find the gun script
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
        local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if Tool:FindFirstChild("GunScript") then
            GunScript = Tool:FindFirstChild("GunScript")
        elseif Tool:FindFirstChild("Script") then
            GunScript = Tool:FindFirstChild("Script")
        end
    end
    
    -- Hook the mouse event or remote
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    if setreadonly then
        setreadonly(mt, false)
    end
    
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        -- Check if this is a shooting remote
        if Config.SilentAim and (method == "FireServer" and (self.Name == "HitPart" or self.Name == "CreateProjectile" or self.Name == "Hit" or self.Name == "Fire")) then
            -- Find closest enemy in FOV
            local closest = FindClosestEnemy()
            
            if closest and closest.Character and closest.Character:FindFirstChild("Head") then
                -- Different implementations depending on the remote
                if self.Name == "HitPart" then
                    -- Override hit part position to target enemy
                    local targetPart = Config.HeadshotsOnly and closest.Character.Head or closest.Character.Torso
                    args[1] = targetPart
                    args[2] = targetPart.Position
                elseif self.Name == "CreateProjectile" or self.Name == "Fire" then
                    -- Override aim direction
                    local targetPart = Config.HeadshotsOnly and closest.Character.Head or closest.Character.Torso
                    args[3] = targetPart.Position
                end
                
                return oldNamecall(self, unpack(args))
            end
        end
        
        -- Handle Wallbang
        if Config.Wallbang and method == "FindPartOnRayWithIgnoreList" and args[2] then
            -- Add all player characters to the ignore list
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    table.insert(args[2], player.Character)
                end
            end
            
            -- Add workspace.Map to the ignore list (common in Arsenal)
            if Workspace:FindFirstChild("Map") then
                table.insert(args[2], Workspace.Map)
            end
            
            return oldNamecall(self, unpack(args))
        end
        
        return oldNamecall(self, ...)
    end)
    
    if setreadonly then
        setreadonly(mt, true)
    end
}

function DisableSilentAim()
    if fovCircle then
        fovCircle.Visible = false
    end
    
    -- We can't fully restore the metatable after hooking
    -- But we can set the flag to false so our hook won't do anything
    Config.SilentAim = false
}

function FindClosestEnemy()
    local closestPlayer = nil
    local closestDistance = Config.SilentAimFOV
    
    -- Get the mouse position
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) and not IsTeammate(player) then
            -- Check if the player is visible if wallbang is disabled
            if not Config.Wallbang and not IsVisible(player.Character, player.Character.Head) then
                continue
            end
            
            -- Calculate distance from mouse
            local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(player.Character.Head.Position)
            if not onScreen then
                continue
            end
            
            local distanceFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if distanceFromMouse < closestDistance then
                closestPlayer = player
                closestDistance = distanceFromMouse
            end
        end
    end
    
    return closestPlayer
}

-- Wallbang Implementation
function EnableWallbang()
    -- This is handled within the silent aim metatable hook
}

function DisableWallbang()
    Config.Wallbang = false
}

-- ESP Implementation
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
    
    -- Update ESP periodically to reflect position and health changes
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
    if RunService:IsStudio() then
        RunService:UnbindFromRenderStep("PlayerESP")
    end
    
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
    
    -- Don't create ESP for teammates if team ESP is disabled
    if not Config.ESPShowTeam and IsTeammate(player) then
        return
    end
    
    playerESPObjects[player.Name] = {}
    
    -- Create Box ESP
    local boxESP = Drawing.new("Square")
    boxESP.Visible = false
    boxESP.Color = GetTeamColor(player)
    boxESP.Thickness = 1
    boxESP.Transparency = 1
    boxESP.Filled = false
    playerESPObjects[player.Name].Box = boxESP
    
    -- Create Name ESP
    if Config.ESPShowName then
        local nameESP = Drawing.new("Text")
        nameESP.Visible = false
        nameESP.Color = GetTeamColor(player)
        nameESP.Size = 18
        nameESP.Center = true
        nameESP.Outline = true
        nameESP.Font = 2
        nameESP.Text = player.Name
        playerESPObjects[player.Name].Name = nameESP
    end
    
    -- Create Distance ESP
    if Config.ESPShowDistance then
        local distanceESP = Drawing.new("Text")
        distanceESP.Visible = false
        distanceESP.Color = GetTeamColor(player)
        distanceESP.Size = 16
        distanceESP.Center = true
        distanceESP.Outline = true
        distanceESP.Font = 2
        playerESPObjects[player.Name].Distance = distanceESP
    end
    
    -- Create Health ESP
    if Config.ESPShowHealth then
        local healthESP = Drawing.new("Line")
        healthESP.Visible = false
        healthESP.Color = Color3.fromRGB(0, 255, 0)
        healthESP.Thickness = 2
        playerESPObjects[player.Name].Health = healthESP
    end
}

function UpdatePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and playerESPObjects[player.Name] then
            -- Don't update ESP for teammates if team ESP is disabled
            if not Config.ESPShowTeam and IsTeammate(player) then
                for _, item in pairs(playerESPObjects[player.Name]) do
                    item.Visible = false
                end
                continue
            end
            
            local character = player.Character
            if not character or not IsAlive(player) then
                for _, item in pairs(playerESPObjects[player.Name]) do
                    item.Visible = false
                end
                continue
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if not rootPart or not head or not humanoid then
                for _, item in pairs(playerESPObjects[player.Name]) do
                    item.Visible = false
                end
                continue
            end
            
            -- Calculate 3D position and size
            local rootPos = rootPart.Position
            local headPos = head.Position + Vector3.new(0, 0.5, 0)
            local distance = (rootPos - Workspace.CurrentCamera.CFrame.Position).Magnitude
            
            -- Convert to screen position
            local rootScreenPos, rootOnScreen = Workspace.CurrentCamera:WorldToScreenPoint(rootPos)
            local headScreenPos, headOnScreen = Workspace.CurrentCamera:WorldToScreenPoint(headPos)
            
            if not rootOnScreen and not headOnScreen then
                for _, item in pairs(playerESPObjects[player.Name]) do
                    item.Visible = false
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
            box.Color = GetTeamColor(player)
            box.Visible = true
            
            -- Update Name ESP
            if Config.ESPShowName and playerESPObjects[player.Name].Name then
                local nameESP = playerESPObjects[player.Name].Name
                nameESP.Position = Vector2.new(headScreenPos.X, headScreenPos.Y - 25)
                nameESP.Color = GetTeamColor(player)
                nameESP.Text = player.Name
                nameESP.Visible = true
            end
            
            -- Update Distance ESP
            if Config.ESPShowDistance and playerESPObjects[player.Name].Distance then
                local distanceESP = playerESPObjects[player.Name].Distance
                distanceESP.Position = Vector2.new(rootScreenPos.X, rootScreenPos.Y + 15)
                distanceESP.Color = GetTeamColor(player)
                distanceESP.Text = math.floor(distance) .. " studs"
                distanceESP.Visible = true
            end
            
            -- Update Health ESP
            if Config.ESPShowHealth and playerESPObjects[player.Name].Health then
                local healthESP = playerESPObjects[player.Name].Health
                local healthPct = humanoid.Health / humanoid.MaxHealth
                
                healthESP.From = Vector2.new(rootScreenPos.X - boxWidth / 2 - 5, rootScreenPos.Y - boxSize / 2)
                healthESP.To = Vector2.new(rootScreenPos.X - boxWidth / 2 - 5, rootScreenPos.Y - boxSize / 2 + boxSize * healthPct)
                
                -- Gradient color based on health
                healthESP.Color = Color3.fromRGB(
                    255 * (1 - healthPct),
                    255 * healthPct,
                    0
                )
                
                healthESP.Visible = true
            end
        end
    end
}

-- Gun Mods Implementation
function EnableNoRecoil()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Recoil") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule then return end
    
    -- Backup original values
    if not originalGunModules.Recoil then
        originalGunModules.Recoil = {
            RecoilMin = gunModule.Recoil.Min,
            RecoilMax = gunModule.Recoil.Max,
            RecoilKick = gunModule.RecoilKick
        }
    end
    
    -- Apply no recoil
    gunModule.Recoil.Min = Vector3.new(0, 0, 0)
    gunModule.Recoil.Max = Vector3.new(0, 0, 0)
    gunModule.RecoilKick = 0
}

function DisableNoRecoil()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Recoil") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule or not originalGunModules.Recoil then return end
    
    -- Restore original values
    gunModule.Recoil.Min = originalGunModules.Recoil.RecoilMin
    gunModule.Recoil.Max = originalGunModules.Recoil.RecoilMax
    gunModule.RecoilKick = originalGunModules.Recoil.RecoilKick
}

function EnableNoSpread()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Spread") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule then return end
    
    -- Backup original values
    if not originalGunModules.Spread then
        originalGunModules.Spread = {
            SpreadMin = gunModule.Spread.Min,
            SpreadMax = gunModule.Spread.Max
        }
    end
    
    -- Apply no spread
    gunModule.Spread.Min = 0
    gunModule.Spread.Max = 0
}

function DisableNoSpread()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Spread") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule or not originalGunModules.Spread then return end
    
    -- Restore original values
    gunModule.Spread.Min = originalGunModules.Spread.SpreadMin
    gunModule.Spread.Max = originalGunModules.Spread.SpreadMax
}

function EnableRapidFire()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "FireRate") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule then return end
    
    -- Backup original values
    if not originalGunModules.FireRate then
        originalGunModules.FireRate = gunModule.FireRate
    end
    
    -- Apply rapid fire
    gunModule.FireRate = 0.05 -- Extremely fast fire rate
}

function DisableRapidFire()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "FireRate") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule or not originalGunModules.FireRate then return end
    
    -- Restore original values
    gunModule.FireRate = originalGunModules.FireRate
}

function EnableInfiniteAmmo()
    -- Hook the ammo update function
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    
    if setreadonly then
        setreadonly(mt, false)
    end
    
    mt.__index = newcclosure(function(self, key)
        if Config.InfiniteAmmo and key == "Ammo" or key == "CurrentAmmo" or key == "StoredAmmo" then
            return math.huge
        end
        
        return oldIndex(self, key)
    end)
    
    if setreadonly then
        setreadonly(mt, true)
    end
    
    -- Also hook any ammo update functions
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "UpdateAmmo") then
            local oldUpdateAmmo = obj.UpdateAmmo
            
            obj.UpdateAmmo = function(...)
                if Config.InfiniteAmmo then
                    return
                end
                
                return oldUpdateAmmo(...)
            end
        end
    end
}

function DisableInfiniteAmmo()
    -- We can't fully restore the metatable after hooking
    -- But we can set the flag to false so our hook won't do anything
    Config.InfiniteAmmo = false
}

function EnableFullAuto()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "FireMode") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule then return end
    
    -- Backup original values
    if not originalGunModules.FireMode then
        originalGunModules.FireMode = gunModule.FireMode
    end
    
    -- Apply full auto
    gunModule.FireMode = "Auto"
    
    -- Also patch any functions that might reset fire mode
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "SetFireMode") then
            local oldSetFireMode = obj.SetFireMode
            
            obj.SetFireMode = function(...)
                if Config.FullAuto then
                    return "Auto"
                end
                
                return oldSetFireMode(...)
            end
        end
    end
}

function DisableFullAuto()
    -- Get current gun
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("Script")
    if not gunScript then return end
    
    -- Try to access gun module
    local gunModule = nil
    
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "FireMode") then
            gunModule = obj
            break
        end
    end
    
    if not gunModule or not originalGunModules.FireMode then return end
    
    -- Restore original values
    gunModule.FireMode = originalGunModules.FireMode
    
    -- We can't fully restore hooked functions
    Config.FullAuto = false
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
        LocalPlayer.Character.Humanoid.JumpPower = this.JumpPower
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

-- Auto Rejoin Implementation
function EnableAutoRejoin()
    if autoRejoinConnection then
        autoRejoinConnection:Disconnect()
    end
    
    autoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
            local errorText = child.MessageArea.ErrorFrame.ErrorMessage.Text
            if errorText:match("kicked") or errorText:match("game has shutdown") or errorText:match("disconnected") then
                if #Players:GetPlayers() <= 1 then
                    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
                else
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end
        end
    end)
}

function DisableAutoRejoin()
    if autoRejoinConnection then
        autoRejoinConnection:Disconnect()
        autoRejoinConnection = nil
    end
}

-- Initialize features based on saved settings
if Config.AntiAFK then
    EnableAntiAFK()
end

if Config.AutoRejoin then
    EnableAutoRejoin()
end

-- Initialize the UI
OrionLib:Init()
