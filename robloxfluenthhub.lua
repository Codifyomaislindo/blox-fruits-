--// Blox Fruits Update 26 – Complete Fluent UI Script
--// Author: 0xVoid | Discord: voiddev
--// Optimized for Synapse X / Electron
--// Last Update: 2025-07-15

--[[
   ⚠️  DISCLAIMER
   This script is provided for educational purposes only.
   Use at your own risk. I am not responsible for any bans or game issues.
]]

--// Anti-cheat bypass (basic)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

--// Basic anti-kick & anti-idle
local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    if Method == "Kick" then
        return warn("Bypassed kick attempt")
    end
    return OldNamecall(Self, ...)
end)

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// Fluent UI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

--// UI Window
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits v26 | Fluent",
    SubTitle = "by 0xVoid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Events = Window:AddTab({ Title = "Events", Icon = "megaphone" }),
    Utils = Window:AddTab({ Title = "Utils", Icon = "wrench" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Raids = Window:AddTab({ Title = "Raids", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--// Sea Detection
local CurrentSea = 1
local function DetectSea()
    local level = Players.LocalPlayer.Data.Level.Value
    if level >= 1500 then
        CurrentSea = 3
    elseif level >= 700 then
        CurrentSea = 2
    else
        CurrentSea = 1
    end
    Fluent:Notify({
        Title = "Sea Detected",
        Content = string.format("You are in the %s Sea.", {"First", "Second", "Third"}[CurrentSea]),
        Duration = 3
    })
end
DetectSea()

--// Locals & Data
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Config
local Config = {
    AutoFarm = {
        Enabled = false,
        Target = "Bandit",
        Distance = 50,
        AutoHaki = true,
        AutoKen = true
    },
    ESP = {
        Players = false,
        Fruits = false,
        Chests = false,
        Bosses = false
    },
    Utils = {
        NoClip = false,
        Fly = false,
        Speed = 16,
        JumpPower = 50,
        AntiAFK = true
    },
    Shop = {
        AutoBuy = false,
        TargetFruits = {"Leopard", "Dragon", "Dough"}
    },
    Raids = {
        AutoChip = false,
        AutoStart = false,
        FarmFragments = false
    }
}

--// Mobs & Bosses by Sea
local SeaData = {
    [1] = {
        Mobs = {"Bandit", "Gorilla", "Pirate", "Desert Bandit", "Fishman Warrior"},
        Bosses = {"Gorilla King", "Bobby", "Yeti", "Vice Admiral", "Warden", "Swan", "Magma Admiral", "Fishman Lord", "Thunder God", "Cyborg"},
        Islands = {"Jungle", "Pirate Village", "Desert", "Marine Fortress", "Skylands", "Prison", "Colosseum", "Magma Village", "Underwater City", "Fountain City"}
    },
    [2] = {
        Mobs = {"Raider", "Mercenary", "Swan Pirate", "Marine Lieutenant", "Zombie", "Vampire", "Lava Pirate"},
        Bosses = {"Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain", "Darkbeard", "Order", "Awakened Ice Admiral"},
        Islands = {"Kingdom of Rose", "Usoap's Island", "Green Zone", "Graveyard", "Snow Mountain", "Hot and Cold", "Cursed Ship", "Ice Castle", "Forgotten Island"}
    },
    [3] = {
        Mobs = {"Pirate Millionaire", "Dragon Crew Warrior", "Female Islander", "Marine Commodore", "Forest Pirate", "Jungle Pirate", "Reborn Skeleton", "Peanut Scout", "Cocoa Warrior"},
        Bosses = {"Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "rip_indra", "Longma", "Soul Reaper", "Cake Prince", "Dough King", "Tyrant of the Sky"},
        Islands = {"Port Town", "Hydra Island", "Great Tree", "Floating Turtle", "Castle on the Sea", "Haunted Castle", "Sea of Treats", "Tiki Outpost"}
    }
}

--// Auto Farm
local AutoFarmTab = Tabs.AutoFarm
AutoFarmTab:AddToggle("AutoFarmToggle", {
    Title = "Enable Auto Farm",
    Default = false,
    Callback = function(v)
        Config.AutoFarm.Enabled = v
    end
})

AutoFarmTab:AddDropdown("TargetMob", {
    Title = "Target Mob",
    Values = SeaData[CurrentSea].Mobs,
    Default = SeaData[CurrentSea].Mobs[1],
    Callback = function(v)
        Config.AutoFarm.Target = v
    end
})

--// Teleport
local TeleportTab = Tabs.Teleport
TeleportTab:AddDropdown("IslandTP", {
    Title = "Teleport to Island",
    Values = SeaData[CurrentSea].Islands,
    Callback = function(island)
        --// Simple teleport logic
        local target = workspace:IsA("Model") and workspace:FindFirstChild(island)
        if target and target:FindFirstChild("HumanoidRootPart") then
            HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
        end
    end
})

--// ESP
local ESPTab = Tabs.ESP
ESPTab:AddToggle("ESPPlayers", {
    Title = "ESP Players",
    Callback = function(v)
        Config.ESP.Players = v
    end
})

--// Utils
local UtilsTab = Tabs.Utils
UtilsTab:AddToggle("NoClip", {
    Title = "NoClip",
    Callback = function(v)
        Config.Utils.NoClip = v
        if v then
            for _,v in pairs(Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
})

UtilsTab:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(v)
        Config.Utils.AntiAFK = v
    end
})

--// Shop
local ShopTab = Tabs.Shop
ShopTab:AddToggle("AutoBuyFruits", {
    Title = "Auto Buy Fruits",
    Callback = function(v)
        Config.Shop.AutoBuy = v
    end
})

--// Raids
local RaidsTab = Tabs.Raids
RaidsTab:AddToggle("AutoStartRaid", {
    Title = "Auto Start Raid",
    Callback = function(v)
        Config.Raids.AutoStart = v
    end
})

--// Settings
local SettingsTab = Tabs.Settings
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:BuildConfigSection(SettingsTab)
InterfaceManager:BuildInterfaceSection(SettingsTab)

--// Main tab
Tabs.Main:AddButton({
    Title = "Redeploy UI",
    Description = "Reloads the GUI",
    Callback = function()
        Fluent:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/0xVoid/bloxfruits/main/loader.lua"))()
    end
})

--// Auto Farm Loop
task.spawn(function()
    while true do
        if Config.AutoFarm.Enabled then
            --// Find target
            local targetMob = nil
            for _,v in pairs(workspace.Enemies:GetChildren()) do
                if v.Name == Config.AutoFarm.Target and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    targetMob = v
                    break
                end
            end
            if targetMob then
                HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 0, Config.AutoFarm.Distance)
                --// Attack logic
                local tool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                if tool then
                    tool.Parent = Character
                    tool:Activate()
                end
            end
        end
        task.wait(0.5)
    end
end)

--// Auto Buy Fruits Loop
task.spawn(function()
    while true do
        if Config.Shop.AutoBuy then
            local shop = workspace:FindFirstChild("Shop")
            if shop then
                for _,v in pairs(shop:GetChildren()) do
                    if table.find(Config.Shop.TargetFruits, v.Name) and v:FindFirstChild("HumanoidRootPart") then
                        fireproximityprompt(v:FindFirstChild("ProximityPrompt"))
                        Fluent:Notify({ Title = "Auto Buy", Content = "Bought " .. v.Name, Duration = 3 })
                    end
                end
            end
        end
        task.wait(5)
    end
end)

--// Save & Load
SaveManager:LoadAutoloadConfig()