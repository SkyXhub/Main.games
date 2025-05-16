--[[
    SkyX Hub - Pet Simulator X Script
    Using OrionX UI
    
    Features:
    - Auto Farm (coins, chests, diamonds)
    - Auto Hatch Eggs
    - Auto Collect Loot Bags
    - Auto Use Boosts
    - Auto Upgrade Pets
    - Auto Enchant Pets
    - Teleports to all areas
    - Anti-AFK and Anti-Detection
]]

-- Load the Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Initialize Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Configuration
local Config = {
    AutoFarm = false,
    FarmCoins = true,
    FarmChests = true,
    FarmDiamonds = true,
    FarmDistance = 30,
    IgnoreClaimed = true,
    FarmAllAreas = false,
    CurrentArea = "Spawn",
    AutoHatch = false,
    SelectedEgg = "Basic Egg",
    HatchAmount = "Single",
    SkipAnimation = true,
    AutoCollect = false,
    AutoBoost = false,
    BoostCooldown = 30,
    AutoUpgrade = false,
    AutoEnchant = false,
    AntiAFK = true,
    HideUsername = true
}

-- Create the main window
local Window = OrionLib:MakeWindow({
    Name = "SkyX Hub | Pet Simulator X", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "SkyXHub_PetSimX",
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

InfoSection:AddParagraph("Welcome to SkyX Hub", "The ultimate script for Pet Simulator X with auto farming, hatching, upgrading and more.")

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

-- Farm Tab
local FarmTab = Window:MakeTab({
    Name = "Farming",
    Icon = "coin",
    PremiumOnly = false
})

local FarmSection = FarmTab:AddSection({
    Name = "Auto Farm"
})

-- Auto Farm Toggle
FarmSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config.AutoFarm = Value
        
        if Value then
            StartAutoFarm()
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto Farm has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoFarm()
            OrionLib:MakeNotification({
                Name = "Auto Farm",
                Content = "Auto Farm has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Farm Options
FarmSection:AddToggle({
    Name = "Farm Coins",
    Default = true,
    Flag = "FarmCoins",
    Save = true,
    Callback = function(Value)
        Config.FarmCoins = Value
    end
})

FarmSection:AddToggle({
    Name = "Farm Chests",
    Default = true,
    Flag = "FarmChests",
    Save = true,
    Callback = function(Value)
        Config.FarmChests = Value
    end
})

FarmSection:AddToggle({
    Name = "Farm Diamonds",
    Default = true,
    Flag = "FarmDiamonds",
    Save = true,
    Callback = function(Value)
        Config.FarmDiamonds = Value
    end
})

FarmSection:AddToggle({
    Name = "Ignore Claimed",
    Default = true,
    Flag = "IgnoreClaimed",
    Save = true,
    Callback = function(Value)
        Config.IgnoreClaimed = Value
    end
})

FarmSection:AddToggle({
    Name = "Farm All Areas",
    Default = false,
    Flag = "FarmAllAreas",
    Save = true,
    Callback = function(Value)
        Config.FarmAllAreas = Value
    end
})

-- Farm Distance Slider
FarmSection:AddSlider({
    Name = "Farm Distance",
    Min = 10,
    Max = 100,
    Default = 30,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 5,
    Flag = "FarmDistance",
    Save = true,
    ValueName = "studs",
    Callback = function(Value)
        Config.FarmDistance = Value
    end
})

local CollectSection = FarmTab:AddSection({
    Name = "Auto Collect"
})

-- Auto Collect Toggle
CollectSection:AddToggle({
    Name = "Auto Collect Loot",
    Default = false,
    Flag = "AutoCollect",
    Save = true,
    Callback = function(Value)
        Config.AutoCollect = Value
        
        if Value then
            StartAutoCollect()
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto Collect has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoCollect()
            OrionLib:MakeNotification({
                Name = "Auto Collect",
                Content = "Auto Collect has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

local BoostSection = FarmTab:AddSection({
    Name = "Auto Boosts"
})

-- Auto Boost Toggle
BoostSection:AddToggle({
    Name = "Auto Use Boosts",
    Default = false,
    Flag = "AutoBoost",
    Save = true,
    Callback = function(Value)
        Config.AutoBoost = Value
        
        if Value then
            StartAutoBoost()
            OrionLib:MakeNotification({
                Name = "Auto Boost",
                Content = "Auto Boost has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoBoost()
            OrionLib:MakeNotification({
                Name = "Auto Boost",
                Content = "Auto Boost has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Boost Cooldown Slider
BoostSection:AddSlider({
    Name = "Boost Cooldown",
    Min = 5,
    Max = 60,
    Default = 30,
    Color = Color3.fromRGB(46, 109, 188),
    Increment = 5,
    Flag = "BoostCooldown",
    Save = true,
    ValueName = "seconds",
    Callback = function(Value)
        Config.BoostCooldown = Value
    end
})

-- Eggs Tab
local EggsTab = Window:MakeTab({
    Name = "Eggs",
    Icon = "pet",
    PremiumOnly = false
})

local HatchSection = EggsTab:AddSection({
    Name = "Auto Hatch"
})

-- Auto Hatch Toggle
HatchSection:AddToggle({
    Name = "Auto Hatch Eggs",
    Default = false,
    Flag = "AutoHatch",
    Save = true,
    Callback = function(Value)
        Config.AutoHatch = Value
        
        if Value then
            StartAutoHatch()
            OrionLib:MakeNotification({
                Name = "Auto Hatch",
                Content = "Auto Hatch has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoHatch()
            OrionLib:MakeNotification({
                Name = "Auto Hatch",
                Content = "Auto Hatch has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Get all available eggs
local eggsList = {"Basic Egg"}
local eggsFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Eggs")

if eggsFolder then
    for _, egg in pairs(eggsFolder:GetChildren()) do
        table.insert(eggsList, egg.Name)
    end
else
    -- Try alternative paths
    local altEggsFolder = workspace:FindFirstChild("Eggs") or ReplicatedStorage:FindFirstChild("Eggs")
    if altEggsFolder then
        for _, egg in pairs(altEggsFolder:GetChildren()) do
            table.insert(eggsList, egg.Name)
        end
    end
end

-- Egg Selection Dropdown
HatchSection:AddDropdown({
    Name = "Select Egg",
    Default = "Basic Egg",
    Flag = "SelectedEgg",
    Save = true,
    Options = eggsList,
    Callback = function(Value)
        Config.SelectedEgg = Value
    end
})

-- Hatch Amount Dropdown
HatchSection:AddDropdown({
    Name = "Hatch Amount",
    Default = "Single",
    Flag = "HatchAmount",
    Save = true,
    Options = {"Single", "Triple", "Octuple"},
    Callback = function(Value)
        Config.HatchAmount = Value
    end
})

-- Skip Animation Toggle
HatchSection:AddToggle({
    Name = "Skip Hatch Animation",
    Default = true,
    Flag = "SkipAnimation",
    Save = true,
    Callback = function(Value)
        Config.SkipAnimation = Value
    end
})

-- Pets Tab
local PetsTab = Window:MakeTab({
    Name = "Pets",
    Icon = "pet",
    PremiumOnly = false
})

local UpgradeSection = PetsTab:AddSection({
    Name = "Auto Upgrade"
})

-- Auto Upgrade Toggle
UpgradeSection:AddToggle({
    Name = "Auto Upgrade Pets",
    Default = false,
    Flag = "AutoUpgrade",
    Save = true,
    Callback = function(Value)
        Config.AutoUpgrade = Value
        
        if Value then
            StartAutoUpgrade()
            OrionLib:MakeNotification({
                Name = "Auto Upgrade",
                Content = "Auto Upgrade has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoUpgrade()
            OrionLib:MakeNotification({
                Name = "Auto Upgrade",
                Content = "Auto Upgrade has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

local EnchantSection = PetsTab:AddSection({
    Name = "Auto Enchant"
})

-- Auto Enchant Toggle
EnchantSection:AddToggle({
    Name = "Auto Enchant Pets",
    Default = false,
    Flag = "AutoEnchant",
    Save = true,
    Callback = function(Value)
        Config.AutoEnchant = Value
        
        if Value then
            StartAutoEnchant()
            OrionLib:MakeNotification({
                Name = "Auto Enchant",
                Content = "Auto Enchant has been enabled",
                Image = "check",
                Time = 3
            })
        else
            StopAutoEnchant()
            OrionLib:MakeNotification({
                Name = "Auto Enchant",
                Content = "Auto Enchant has been disabled",
                Image = "close",
                Time = 3
            })
        end
    end
})

-- Teleport Tab
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "teleport",
    PremiumOnly = false
})

local AreasSection = TeleportTab:AddSection({
    Name = "Areas"
})

-- Get all available areas
local areasList = {"Spawn"}
local areasFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Teleports")

if areasFolder then
    for _, area in pairs(areasFolder:GetChildren()) do
        table.insert(areasList, area.Name)
    end
else
    -- Try alternative paths
    local altAreasFolder = workspace:FindFirstChild("Teleports") or workspace:FindFirstChild("Areas")
    if altAreasFolder then
        for _, area in pairs(altAreasFolder:GetChildren()) do
            table.insert(areasList, area.Name)
        end
    else
        -- Add some common areas if none found
        table.insert(areasList, "Fantasy")
        table.insert(areasList, "Tech")
        table.insert(areasList, "Axolotl")
        table.insert(areasList, "Pixel")
    end
end

-- Area Selection Dropdown
AreasSection:AddDropdown({
    Name = "Select Area",
    Default = "Spawn",
    Flag = "CurrentArea",
    Save = true,
    Options = areasList,
    Callback = function(Value)
        Config.CurrentArea = Value
    end
})

-- Teleport Button
AreasSection:AddButton({
    Name = "Teleport to Area",
    Callback = function()
        TeleportToArea(Config.CurrentArea)
    end
})

-- Quick Teleport Buttons for popular areas
local QuickTeleportSection = TeleportTab:AddSection({
    Name = "Quick Teleports"
})

-- Add quick teleport buttons for some key areas
local quickAreas = {"Spawn", "Fantasy", "Tech", "Axolotl", "Pixel"}
for _, area in pairs(quickAreas) do
    if table.find(areasList, area) then
        QuickTeleportSection:AddButton({
            Name = "Teleport to " .. area,
            Callback = function()
                TeleportToArea(area)
            end
        })
    end
end

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

-- Hide Username Toggle
AntiSection:AddToggle({
    Name = "Hide Username",
    Default = true,
    Flag = "HideUsername",
    Save = true,
    Callback = function(Value)
        Config.HideUsername = Value
        
        if Value then
            EnableHideUsername()
            OrionLib:MakeNotification({
                Name = "Hide Username",
                Content = "Username is now hidden from view",
                Image = "check",
                Time = 3
            })
        else
            DisableHideUsername()
            OrionLib:MakeNotification({
                Name = "Hide Username",
                Content = "Username is now visible",
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
            AutoFarm = false,
            FarmCoins = true,
            FarmChests = true,
            FarmDiamonds = true,
            FarmDistance = 30,
            IgnoreClaimed = true,
            FarmAllAreas = false,
            CurrentArea = "Spawn",
            AutoHatch = false,
            SelectedEgg = "Basic Egg",
            HatchAmount = "Single",
            SkipAnimation = true,
            AutoCollect = false,
            AutoBoost = false,
            BoostCooldown = 30,
            AutoUpgrade = false,
            AutoEnchant = false,
            AntiAFK = true,
            HideUsername = true
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
local autoFarmConnection = nil
local autoCollectConnection = nil
local autoBoostConnection = nil
local autoHatchConnection = nil
local autoUpgradeConnection = nil
local autoEnchantConnection = nil
local antiAFKConnection = nil

-- Auto Farm Implementation
function StartAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
    end
    
    autoFarmConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        
        -- Find targets to farm
        local targets = GetFarmTargets()
        
        -- Farm the targets
        for _, target in pairs(targets) do
            FarmTarget(target)
            task.wait(0.1) -- Short delay to prevent overwhelming
        end
    end)
end

function StopAutoFarm()
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
end

function GetFarmTargets()
    local targets = {}
    
    -- Look for coins in the __THINGS folder (most common path)
    local thingsFolder = workspace:FindFirstChild("__THINGS")
    local coinsFolder = thingsFolder and thingsFolder:FindFirstChild("Coins")
    
    if coinsFolder then
        for _, coin in pairs(coinsFolder:GetChildren()) do
            -- Check if it meets our farm criteria
            if ShouldFarmTarget(coin) then
                table.insert(targets, coin)
            end
        end
    else
        -- Try alternative paths
        local altCoinsFolder = workspace:FindFirstChild("Coins")
        if altCoinsFolder then
            for _, coin in pairs(altCoinsFolder:GetChildren()) do
                if ShouldFarmTarget(coin) then
                    table.insert(targets, coin)
                end
            end
        end
    end
    
    return targets
end

function ShouldFarmTarget(target)
    -- Check if this target is within our area
    if not Config.FarmAllAreas and not IsInCurrentArea(target) then
        return false
    end
    
    -- Check if it's already claimed and we're ignoring claimed
    if Config.IgnoreClaimed and target:GetAttribute("Claimed") then
        return false
    end
    
    -- Check if it matches our farm types
    local isCoin = not target:GetAttribute("Chest") and not target:GetAttribute("Diamond")
    local isChest = target:GetAttribute("Chest")
    local isDiamond = target:GetAttribute("Diamond")
    
    if (isCoin and Config.FarmCoins) or
       (isChest and Config.FarmChests) or
       (isDiamond and Config.FarmDiamonds) then
        -- Check distance
        local targetPosition = GetTargetPosition(target)
        local playerPosition = GetPlayerPosition()
        
        if targetPosition and playerPosition then
            local distance = (targetPosition - playerPosition).Magnitude
            return distance <= Config.FarmDistance
        end
    end
    
    return false
end

function IsInCurrentArea(target)
    -- Get the area from the target
    local targetArea = target:GetAttribute("Area") or ""
    
    -- If no specific area, check parent name
    if targetArea == "" then
        local parent = target.Parent
        while parent and parent ~= workspace do
            if parent.Name == Config.CurrentArea then
                return true
            end
            parent = parent.Parent
        end
    end
    
    return targetArea == Config.CurrentArea
end

function GetTargetPosition(target)
    if target:IsA("BasePart") then
        return target.Position
    elseif target:IsA("Model") and target.PrimaryPart then
        return target.PrimaryPart.Position
    end
    
    -- Try to find a part to use for position
    for _, child in pairs(target:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    
    return nil
end

function GetPlayerPosition()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart.Position
    end
    return nil
end

function FarmTarget(target)
    -- Find the remote to send pets to target
    local farmRemote = ReplicatedStorage:FindFirstChild("Network") and
                      ReplicatedStorage.Network:FindFirstChild("Pets_SendPetsToTarget")
                      
    if not farmRemote then
        -- Alternative paths
        farmRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                     ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("TargetFarm")
    end
    
    -- Get target ID (typically the name or a special attribute)
    local targetId = target.Name
    
    -- If remote found, send pets to target
    if farmRemote then
        farmRemote:FireServer(targetId)
    end
end

-- Auto Collect Implementation
function StartAutoCollect()
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
    end
    
    autoCollectConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoCollect then return end
        
        -- Find and collect loot bags
        CollectLootBags()
        
        -- Short delay to prevent overwhelming
        task.wait(0.5)
    end)
end

function StopAutoCollect()
    if autoCollectConnection then
        autoCollectConnection:Disconnect()
        autoCollectConnection = nil
    end
end

function CollectLootBags()
    -- Look for orbs/lootbags in the __THINGS folder (most common path)
    local thingsFolder = workspace:FindFirstChild("__THINGS")
    local orbsFolder = thingsFolder and thingsFolder:FindFirstChild("Orbs")
    
    if orbsFolder then
        -- Find the remote for collecting orbs
        local collectRemote = ReplicatedStorage:FindFirstChild("Network") and
                             ReplicatedStorage.Network:FindFirstChild("Orbs_ClaimOrb")
                             
        if not collectRemote then
            -- Alternative paths
            collectRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                          ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("CollectOrb")
        end
        
        if collectRemote then
            for _, orb in pairs(orbsFolder:GetChildren()) do
                collectRemote:FireServer(orb.Name)
            end
        end
    end
end

-- Auto Boost Implementation
function StartAutoBoost()
    if autoBoostConnection then
        autoBoostConnection:Disconnect()
    end
    
    -- Set last boost time
    _G.LastBoostTime = 0
    
    autoBoostConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoBoost then return end
        
        -- Check if it's time to use boosts
        local currentTime = tick()
        if currentTime - _G.LastBoostTime >= Config.BoostCooldown then
            UseBoosts()
            _G.LastBoostTime = currentTime
        end
    end)
end

function StopAutoBoost()
    if autoBoostConnection then
        autoBoostConnection:Disconnect()
        autoBoostConnection = nil
    end
end

function UseBoosts()
    -- Find the remote for using boosts
    local boostRemote = ReplicatedStorage:FindFirstChild("Network") and
                       ReplicatedStorage.Network:FindFirstChild("Boosts_UseBoost")
                       
    if not boostRemote then
        -- Alternative paths
        boostRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                     ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("UseBoost")
    end
    
    if boostRemote then
        -- Use common boost types
        local boostTypes = {"Triple Coins", "Triple Damage", "Super Lucky"}
        
        for _, boostType in pairs(boostTypes) do
            -- Try to use the boost
            boostRemote:FireServer(boostType)
            task.wait(0.5) -- Short delay between boosts
        end
    end
end

-- Auto Hatch Implementation
function StartAutoHatch()
    if autoHatchConnection then
        autoHatchConnection:Disconnect()
    end
    
    autoHatchConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoHatch then return end
        
        -- Hatch eggs
        HatchEgg()
        
        -- Short delay to prevent overwhelming
        task.wait(0.5)
    end)
end

function StopAutoHatch()
    if autoHatchConnection then
        autoHatchConnection:Disconnect()
        autoHatchConnection = nil
    end
end

function HatchEgg()
    -- Find the remote for hatching eggs
    local hatchRemote = ReplicatedStorage:FindFirstChild("Network") and
                       ReplicatedStorage.Network:FindFirstChild("Eggs_RequestPurchase")
                       
    if not hatchRemote then
        -- Alternative paths
        hatchRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                     ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("HatchEgg")
    end
    
    if hatchRemote then
        -- Convert hatch amount to number
        local hatchCount = 1
        if Config.HatchAmount == "Triple" then
            hatchCount = 3
        elseif Config.HatchAmount == "Octuple" then
            hatchCount = 8
        end
        
        -- Hatch the egg
        hatchRemote:FireServer(Config.SelectedEgg, hatchCount, Config.SkipAnimation)
    end
end

-- Auto Upgrade Implementation
function StartAutoUpgrade()
    if autoUpgradeConnection then
        autoUpgradeConnection:Disconnect()
    end
    
    autoUpgradeConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoUpgrade then return end
        
        -- Upgrade pets
        UpgradePets()
        
        -- Long delay to prevent overwhelming
        task.wait(5)
    end)
end

function StopAutoUpgrade()
    if autoUpgradeConnection then
        autoUpgradeConnection:Disconnect()
        autoUpgradeConnection = nil
    end
end

function UpgradePets()
    -- Find the remote for upgrading pets
    local upgradeRemote = ReplicatedStorage:FindFirstChild("Network") and
                         ReplicatedStorage.Network:FindFirstChild("Pets_UpgradePet")
                         
    if not upgradeRemote then
        -- Alternative paths
        upgradeRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                       ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("UpgradePet")
    end
    
    if upgradeRemote then
        -- Get all pet IDs
        local petIds = GetPetIds()
        
        -- Try to upgrade each pet
        for _, petId in pairs(petIds) do
            upgradeRemote:FireServer(petId)
            task.wait(0.2) -- Short delay between upgrades
        end
    end
end

-- Auto Enchant Implementation
function StartAutoEnchant()
    if autoEnchantConnection then
        autoEnchantConnection:Disconnect()
    end
    
    autoEnchantConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoEnchant then return end
        
        -- Enchant pets
        EnchantPets()
        
        -- Long delay to prevent overwhelming
        task.wait(5)
    end)
end

function StopAutoEnchant()
    if autoEnchantConnection then
        autoEnchantConnection:Disconnect()
        autoEnchantConnection = nil
    end
end

function EnchantPets()
    -- Find the remote for enchanting pets
    local enchantRemote = ReplicatedStorage:FindFirstChild("Network") and
                         ReplicatedStorage.Network:FindFirstChild("Enchants_RequestEnchant")
                         
    if not enchantRemote then
        -- Alternative paths
        enchantRemote = ReplicatedStorage:FindFirstChild("NetworkRemoteEvent") or
                       ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("EnchantPet")
    end
    
    if enchantRemote then
        -- Get all pet IDs
        local petIds = GetPetIds()
        
        -- Try to enchant each pet
        for _, petId in pairs(petIds) do
            enchantRemote:FireServer(petId)
            task.wait(0.2) -- Short delay between enchants
        end
    end
end

-- Helper function to get all pet IDs
function GetPetIds()
    local petIds = {}
    
    -- Try to find pets folder in player
    local petsFolder = LocalPlayer:FindFirstChild("Pets")
    
    if petsFolder then
        for _, pet in pairs(petsFolder:GetChildren()) do
            if pet:IsA("IntValue") or pet:IsA("StringValue") then
                table.insert(petIds, pet.Name)
            end
        end
    else
        -- Try to find pets in DataFolder
        local dataFolder = LocalPlayer:FindFirstChild("Data")
        if dataFolder and dataFolder:FindFirstChild("Pets") then
            for _, pet in pairs(dataFolder.Pets:GetChildren()) do
                if pet:IsA("IntValue") or pet:IsA("StringValue") then
                    table.insert(petIds, pet.Name)
                end
            end
        end
    end
    
    return petIds
end

-- Teleport Implementation
function TeleportToArea(areaName)
    -- Find the teleport location
    local teleportLocation = nil
    
    -- Look in the __THINGS folder (most common path)
    local thingsFolder = workspace:FindFirstChild("__THINGS")
    local teleportsFolder = thingsFolder and thingsFolder:FindFirstChild("Teleports")
    
    if teleportsFolder then
        local areaFolder = teleportsFolder:FindFirstChild(areaName)
        if areaFolder and areaFolder:FindFirstChild("Teleport") then
            teleportLocation = areaFolder.Teleport
        end
    else
        -- Try alternative paths
        local altTeleportsFolder = workspace:FindFirstChild("Teleports") or workspace:FindFirstChild("Areas")
        if altTeleportsFolder then
            local areaFolder = altTeleportsFolder:FindFirstChild(areaName)
            if areaFolder then
                teleportLocation = areaFolder
            end
        end
    end
    
    -- If location found, teleport
    if teleportLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Try to use teleport remote first
        local teleportRemote = ReplicatedStorage:FindFirstChild("Network") and
                             ReplicatedStorage.Network:FindFirstChild("Teleports_RequestTeleport")
                             
        if teleportRemote then
            teleportRemote:FireServer(areaName)
        else
            -- Direct teleport as fallback
            LocalPlayer.Character.HumanoidRootPart.CFrame = teleportLocation.CFrame + Vector3.new(0, 5, 0)
        end
        
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "Teleported to " .. areaName,
            Image = "teleport",
            Time = 3
        })
    else
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "Could not find teleport location for " .. areaName,
            Image = "warning",
            Time = 3
        })
    end
end

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
end

function DisableAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

-- Hide Username Implementation
function EnableHideUsername()
    -- Check if character exists
    if LocalPlayer.Character then
        HideUsernameForCharacter(LocalPlayer.Character)
    end
    
    -- Connect to character added event
    usernameConnection = LocalPlayer.CharacterAdded:Connect(HideUsernameForCharacter)
end

function DisableHideUsername()
    -- Disconnect character added event
    if usernameConnection then
        usernameConnection:Disconnect()
        usernameConnection = nil
    end
    
    -- Show username if character exists
    if LocalPlayer.Character then
        ShowUsernameForCharacter(LocalPlayer.Character)
    end
end

function HideUsernameForCharacter(character)
    -- Hide player name overhead
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.NameDisplayDistance = 0
        humanoid.HealthDisplayDistance = 0
    end
    
    -- Hide name GUI if it exists
    local head = character:FindFirstChild("Head")
    if head then
        for _, gui in pairs(head:GetChildren()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                gui.Enabled = false
            end
        end
    end
end

function ShowUsernameForCharacter(character)
    -- Show player name overhead
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        humanoid.NameDisplayDistance = 100
        humanoid.HealthDisplayDistance = 100
    end
    
    -- Show name GUI if it exists
    local head = character:FindFirstChild("Head")
    if head then
        for _, gui in pairs(head:GetChildren()) do
            if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                gui.Enabled = true
            end
        end
    end
end

-- Initialize features based on saved settings
if Config.AntiAFK then
    EnableAntiAFK()
end

if Config.HideUsername then
    EnableHideUsername()
end

-- Initialize the UI
OrionLib:Init()
