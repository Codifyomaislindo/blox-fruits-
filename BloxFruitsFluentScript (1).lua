-- Load the Fluent library and addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the main window
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits - Fluent Hub",
    SubTitle = "by dawid-scripts",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Create tabs
local Tabs = {
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "lucide-map-pin" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "lucide-wheat" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "lucide-bar-chart" }),
    Items = Window:AddTab({ Title = "Items", Icon = "lucide-package" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "lucide-eye" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "lucide-tool" }),
    Quests = Window:AddTab({ Title = "Quests", Icon = "lucide-scroll" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "lucide-settings" })
}

-- Notify user that the script has loaded
Fluent:Notify({
    Title = "Fluent Hub",
    Content = "Blox Fruits script loaded successfully! Use RightShift to toggle GUI.",
    Duration = 5
})

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Teleport Locations (First, Second, Third Sea)
local TeleportLocations = {
    ["Middle Town (First Sea)"] = Vector3.new(-653.2, 7.8, 1567.5),
    ["Marine Starter (First Sea)"] = Vector3.new(-2597.8, 6.9, 2060.3),
    ["Jungle Island (First Sea)"] = Vector3.new(-1234.6, 11.7, -1047.2),
    ["Pirate Village (First Sea)"] = Vector3.new(-1189.3, 4.8, 3828.1),
    ["Desert (First Sea)"] = Vector3.new(1094.7, 6.4, 4130.9),
    ["Fruit Dealer (First Sea)"] = Vector3.new(-450.7, 73.1, 1496.3),
    ["Boat Dealer (First Sea)"] = Vector3.new(-277.2, 7.9, 1510.8),
    ["Port Town (Second Sea)"] = Vector3.new(-321.2, 44.1, 5867.3),
    ["Cafe (Second Sea)"] = Vector3.new(-379.8, 73.8, 6180.4),
    ["Mansion (Second Sea)"] = Vector3.new(-390.1, 331.8, 6866.2),
    ["Tiki Outpost (Third Sea)"] = Vector3.new(-16236.7, 36.1, 430.2),
    ["Port Town (Third Sea)"] = Vector3.new(-16236.7, 36.1, 430.2),
    ["Hydra Island (Third Sea)"] = Vector3.new(5228.8, 602.8, 400.1),
    ["Quest Giver (Middle Town)"] = Vector3.new(-606.1, 7.8, 1520.4),
    ["Fruit Awakener (Second Sea)"] = Vector3.new(-408.2, 73.8, 6170.9)
}

-- ESP Variables
local ESPEnabled = false
local ESPFruitEnabled = false
local ESPChestEnabled = false
local ESPBoxes = {}
local ESPUpdateConnection = nil

-- Auto-Farm Variables
local AutoCollectChests = false
local AutoCollectFruits = false
local AutoQuest = false

-- Utility Variables
local WalkSpeedEnabled = false
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local AutoRejoinEnabled = false

-- Stat Upgrade Variables
local AutoUpgradeMelee = false
local AutoUpgradeDefense = false
local AutoUpgradeSword = false
local AutoUpgradeGun = false
local AutoUpgradeFruit = false

-- Teleport Function
local function TeleportTo(position)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        Fluent:Notify({
            Title = "Teleport Error",
            Content = "Character not found. Please wait and try again.",
            Duration = 5
        })
        return false
    end

    local humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character.Humanoid
    local wasAnchored = humanoidRootPart.Anchored

    -- Anchor to prevent physics reset
    humanoidRootPart.Anchored = true

    -- Tween for smooth teleport
    local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut) -- Slower teleport (3 seconds)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = CFrame.new(position + Vector3.new(0, 5, 0)) }) -- Slightly above ground

    local success, err = pcall(function()
        tween:Play()
        tween.Completed:Wait()
        -- Lock position after tween
        humanoidRootPart.CFrame = CFrame.new(position)
    end)

    -- Unanchor after teleport
    humanoidRootPart.Anchored = wasAnchored

    if success then
        Fluent:Notify({
            Title = "Teleport",
            Content = "Teleported successfully!",
            Duration = 3
        })
        return true
    else
        Fluent:Notify({
            Title = "Teleport Error",
            Content = "Failed to teleport: " .. tostring(err),
            Duration = 5
        })
        return false
    end
end

-- ESP Function
local function UpdateESP()
    if not ESPEnabled and not ESPFruitEnabled and not ESPChestEnabled then
        for _, data in pairs(ESPBoxes) do
            if data.Box then
                data.Box.Visible = false
                data.Box:Remove()
            end
        end
        ESPBoxes = {}
        return
    end

    local camera = Workspace.CurrentCamera
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero

    -- Update existing boxes
    for target, data in pairs(ESPBoxes) do
        local box = data.Box
        local rootPart = data.RootPart
        local isFruit = data.IsFruit
        local isChest = data.IsChest

        if not target:IsDescendantOf(Workspace) or not rootPart or (not isFruit and not isChest and (not rootPart.Parent:FindFirstChild("Humanoid") or rootPart.Parent.Humanoid.Health <= 0)) then
            box.Visible = false
            box:Remove()
            ESPBoxes[target] = nil
            continue
        end

        local distance = (playerPos - rootPart.Position).Magnitude
        if distance > 1000 then
            box.Visible = false
            continue
        end

        local vector, onScreen = camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
            box.Size = size
            box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
            box.Color = isFruit and Color3.fromRGB(255, 165, 0) or isChest and Color3.fromRGB(255, 255, 0) or (rootPart.Parent.Humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            box.Visible = true
        else
            box.Visible = false
        end
    end

    -- Add new targets
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and not ESPBoxes[player.Character] then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Thickness = 2
                box.Filled = false
                ESPBoxes[player.Character] = { Box = box, RootPart = player.Character.HumanoidRootPart, IsFruit = false, IsChest = false }
            end
        end
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(model) and not ESPBoxes[model] then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Thickness = 2
                box.Filled = false
                ESPBoxes[model] = { Box = box, RootPart = model.HumanoidRootPart, IsFruit = false, IsChest = false }
            end
        end
    end

    if ESPFruitEnabled then
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit.Name == "Fruit" and fruit:FindFirstChild("Handle") and not ESPBoxes[fruit] then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Thickness = 2
                box.Filled = false
                ESPBoxes[fruit] = { Box = box, RootPart = fruit.Handle, IsFruit = true, IsChest = false }
            end
        end
    end

    if ESPChestEnabled then
        for _, chest in ipairs(Workspace:GetChildren()) do
            if chest.Name:match("Chest") and chest:FindFirstChild("Root") and not ESPBoxes[chest] then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Thickness = 2
                box.Filled = false
                ESPBoxes[chest] = { Box = box, RootPart = chest.Root, IsFruit = false, IsChest = true }
            end
        end
    end
end

-- Auto-Collect Chests
local function AutoCollectChestsLoop()
    while AutoCollectChests and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        for _, chest in ipairs(Workspace:GetChildren()) do
            if chest.Name:match("Chest") and chest:FindFirstChild("Root") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - chest.Root.Position).Magnitude
                if distance < 50 then
                    TeleportTo(chest.Root.Position)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chest.Root, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chest.Root, 1)
                end
            end
        end
        task.wait(0.5)
    end
end

-- Auto-Collect Fruits
local function AutoCollectFruitsLoop()
    while AutoCollectFruits and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit.Name == "Fruit" and fruit:FindFirstChild("Handle") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
                if distance < 50 then
                    TeleportTo(fruit.Handle.Position)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, fruit.Handle, 0)
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, fruit.Handle, 1)
                end
            end
        end
        task.wait(0.5)
    end
end

-- Auto-Quest (Example: Bandit Quest in First Sea)
local function AutoQuestLoop()
    while AutoQuest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        -- Accept Bandit Quest
        local questGiverPos = Vector3.new(-606.1, 7.8, 1520.4)
        TeleportTo(questGiverPos)
        task.wait(1)
        -- Simulate quest interaction (replace with actual RemoteEvent if known)
        Fluent:Notify({
            Title = "Auto-Quest",
            Content = "Interacting with Bandit Quest Giver (placeholder).",
            Duration = 3
        })
        task.wait(5)
    end
end

-- Auto-Upgrade Stats
local function AutoUpgradeStat(stat)
    while _G["AutoUpgrade" .. stat] and LocalPlayer.Character do
        -- Simulate stat upgrade (replace with actual RemoteEvent if known)
        Fluent:Notify({
            Title = "Auto-Upgrade",
            Content = "Upgrading " .. stat .. " (placeholder).",
            Duration = 3
        })
        task.wait(2)
    end
end

-- Walk Speed
local function SetWalkSpeed(enabled)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = enabled and 50 or 16
    end
end

-- Infinite Jump
local function SetupInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- No-Clip
local function SetupNoClip()
    RunService.Stepped:Connect(function()
        if NoClipEnabled and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Auto-Rejoin
local function SetupAutoRejoin()
    while AutoRejoinEnabled do
        if not LocalPlayer.Character then
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end
        task.wait(60)
    end
end

-- Teleport Section (15 functions)
local TeleportSection = Tabs.Teleport:AddSection("Teleport to Locations")
for location, position in pairs(TeleportLocations) do
    TeleportSection:AddButton({
        Title = "Teleport to " .. location,
        Description = "Teleports to " .. location,
        Callback = function()
            pcall(function()
                TeleportTo(position)
            end)
        end
    })
end

-- Farming Section (6 functions)
local FarmingSection = Tabs.Farming:AddSection("Auto-Farming")
FarmingSection:AddToggle("AutoCollectChests", {
    Title = "Auto-Collect Chests",
    Description = "Automatically collects nearby chests",
    Default = false,
    Callback = function(value)
        AutoCollectChests = value
        if value then
            spawn(AutoCollectChestsLoop)
        end
    end
})
FarmingSection:AddToggle("AutoCollectFruits", {
    Title = "Auto-Collect Fruits",
    Description = "Automatically collects nearby fruits",
    Default = false,
    Callback = function(value)
        AutoCollectFruits = value
        if value then
            spawn(AutoCollectFruitsLoop)
        end
    end
})
FarmingSection:AddButton({
    Title = "Teleport to Nearest Chest",
    Description = "Teleports to the closest chest",
    Callback = function()
        local closestChest, minDistance = nil, math.huge
        for _, chest in ipairs(Workspace:GetChildren()) do
            if chest.Name:match("Chest") and chest:FindFirstChild("Root") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - chest.Root.Position).Magnitude
                if distance < minDistance then
                    closestChest = chest
                    minDistance = distance
                end
            end
        end
        if closestChest then
            TeleportTo(closestChest.Root.Position)
        else
            Fluent:Notify({
                Title = "Error",
                Content = "No chests found.",
                Duration = 3
            })
        end
    end
})
FarmingSection:AddButton({
    Title = "Teleport to Nearest Fruit",
    Description = "Teleports to the closest fruit",
    Callback = function()
        local closestFruit, minDistance = nil, math.huge
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit.Name == "Fruit" and fruit:FindFirstChild("Handle") then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - fruit.Handle.Position).Magnitude
                if distance < minDistance then
                    closestFruit = fruit
                    minDistance = distance
                end
            end
        end
        if closestFruit then
            TeleportTo(closestFruit.Handle.Position)
        else
            Fluent:Notify({
                Title = "Error",
                Content = "No fruits found.",
                Duration = 3
            })
        end
    end
})
FarmingSection:AddButton({
    Title = "Collect All Chests Once",
    Description = "Collects all chests in the map once",
    Callback = function()
        for _, chest in ipairs(Workspace:GetChildren()) do
            if chest.Name:match("Chest") and chest:FindFirstChild("Root") then
                TeleportTo(chest.Root.Position)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chest.Root, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chest.Root, 1)
                task.wait(0.5)
            end
        end
    end
})
FarmingSection:AddButton({
    Title = "Collect All Fruits Once",
    Description = "Collects all fruits in the map once",
    Callback = function()
        for _, fruit in ipairs(Workspace:GetChildren()) do
            if fruit.Name == "Fruit" and fruit:FindFirstChild("Handle") then
                TeleportTo(fruit.Handle.Position)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, fruit.Handle, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, fruit.Handle, 1)
                task.wait(0.5)
            end
        end
    end
})

-- Stats Section (5 functions)
local StatsSection = Tabs.Stats:AddSection("Auto-Upgrade Stats")
StatsSection:AddToggle("AutoUpgradeMelee", {
    Title = "Auto-Upgrade Melee",
    Description = "Automatically upgrades Melee stat",
    Default = false,
    Callback = function(value)
        _G.AutoUpgradeMelee = value
        if value then
            spawn(function() AutoUpgradeStat("Melee") end)
        end
    end
})
StatsSection:AddToggle("AutoUpgradeDefense", {
    Title = "Auto-Upgrade Defense",
    Description = "Automatically upgrades Defense stat",
    Default = false,
    Callback = function(value)
        _G.AutoUpgradeDefense = value
        if value then
            spawn(function() AutoUpgradeStat("Defense") end)
        end
    end
})
StatsSection:AddToggle("AutoUpgradeSword", {
    Title = "Auto-Upgrade Sword",
    Description = "Automatically upgrades Sword stat",
    Default = false,
    Callback = function(value)
        _G.AutoUpgradeSword = value
        if value then
            spawn(function() AutoUpgradeStat("Sword") end)
        end
    end
})
StatsSection:AddToggle("AutoUpgradeGun", {
    Title = "Auto-Upgrade Gun",
    Description = "Automatically upgrades Gun stat",
    Default = false,
    Callback = function(value)
        _G.AutoUpgradeGun = value
        if value then
            spawn(function() AutoUpgradeStat("Gun") end)
        end
    end
})
StatsSection:AddToggle("AutoUpgradeFruit", {
    Title = "Auto-Upgrade Fruit",
    Description = "Automatically upgrades Fruit stat",
    Default = false,
    Callback = function(value)
        _G.AutoUpgradeFruit = value
        if value then
            spawn(function() AutoUpgradeStat("Fruit") end)
        end
    end
})

-- Items Section (4 functions)
local ItemsSection = Tabs.Items:AddSection("Item Management")
ItemsSection:AddButton({
    Title = "Teleport to Fruit Dealer",
    Description = "Teleports to the Fruit Dealer",
    Callback = function()
        pcall(function()
            TeleportTo(TeleportLocations["Fruit Dealer (First Sea)"])
        end)
    end
})
ItemsSection:AddButton({
    Title = "Teleport to Boat Dealer",
    Description = "Teleports to the Boat Dealer",
    Callback = function()
        pcall(function()
            TeleportTo(TeleportLocations["Boat Dealer (First Sea)"])
        end)
    end
})
ItemsSection:AddButton({
    Title = "Store All Fruits",
    Description = "Stores all fruits in inventory (placeholder)",
    Callback = function()
        Fluent:Notify({
            Title = "Item Management",
            Content = "Storing all fruits (placeholder).",
            Duration = 3
        })
    end
})
ItemsSection:AddButton({
    Title = "Equip Best Weapon",
    Description = "Equips the best weapon (placeholder)",
    Callback = function()
        Fluent:Notify({
            Title = "Item Management",
            Content = "Equipping best weapon (placeholder).",
            Duration = 3
        })
    end
})

-- ESP Section (3 functions)
local ESPSection = Tabs.ESP:AddSection("ESP Controls")
ESPSection:AddToggle("ESPPlayersNPCs", {
    Title = "ESP Players & NPCs",
    Description = "Toggles ESP for players and NPCs",
    Default = false,
    Callback = function(value)
        ESPEnabled = value
        if value and not ESPUpdateConnection then
            ESPUpdateConnection = RunService.RenderStepped:Connect(UpdateESP)
        elseif not value and not ESPFruitEnabled and not ESPChestEnabled and ESPUpdateConnection then
            ESPUpdateConnection:Disconnect()
            ESPUpdateConnection = nil
            UpdateESP()
        end
        Fluent:Notify({
            Title = "ESP",
            Content = value and "Players & NPCs ESP Enabled" or "Players & NPCs ESP Disabled",
            Duration = 3
        })
    end
})
ESPSection:AddToggle("ESPFruits", {
    Title = "ESP Fruits",
    Description = "Toggles ESP for fruits",
    Default = false,
    Callback = function(value)
        ESPFruitEnabled = value
        if value and not ESPUpdateConnection then
            ESPUpdateConnection = RunService.RenderStepped:Connect(UpdateESP)
        elseif not value and not ESPEnabled and not ESPChestEnabled and ESPUpdateConnection then
            ESPUpdateConnection:Disconnect()
            ESPUpdateConnection = nil
            UpdateESP()
        end
        Fluent:Notify({
            Title = "ESP",
            Content = value and "Fruits ESP Enabled" or "Fruits ESP Disabled",
            Duration = 3
        })
    end
})
ESPSection:AddToggle("ESPChests", {
    Title = "ESP Chests",
    Description = "Toggles ESP for chests",
    Default = false,
    Callback = function(value)
        ESPChestEnabled = value
        if value and not ESPUpdateConnection then
            ESPUpdateConnection = RunService.RenderStepped:Connect(UpdateESP)
        elseif not value and not ESPEnabled and not ESPFruitEnabled and ESPUpdateConnection then
            ESPUpdateConnection:Disconnect()
            ESPUpdateConnection = nil
            UpdateESP()
        end
        Fluent:Notify({
            Title = "ESP",
            Content = value and "Chests ESP Enabled" or "Chests ESP Disabled",
            Duration = 3
        })
    end
})

-- Utility Section (6 functions)
local UtilitySection = Tabs.Utility:AddSection("Utility Features")
UtilitySection:AddToggle("WalkSpeed", {
    Title = "Enable Walk Speed",
    Description = "Increases walk speed to 50",
    Default = false,
    Callback = function(value)
        WalkSpeedEnabled = value
        SetWalkSpeed(value)
    end
})
UtilitySection:AddToggle("InfiniteJump", {
    Title = "Enable Infinite Jump",
    Description = "Allows infinite jumping",
    Default = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
        if value then
            spawn(SetupInfiniteJump)
        end
    end
})
UtilitySection:AddToggle("NoClip", {
    Title = "Enable No-Clip",
    Description = "Allows walking through walls",
    Default = false,
    Callback = function(value)
        NoClipEnabled = value
        if value then
            spawn(SetupNoClip)
        end
    end
})
UtilitySection:AddToggle("AutoRejoin", {
    Title = "Enable Auto-Rejoin",
    Description = "Rejoins if disconnected",
    Default = false,
    Callback = function(value)
        AutoRejoinEnabled = value
        if value then
            spawn(SetupAutoRejoin)
        end
    end
})
UtilitySection:AddButton({
    Title = "Remove Fog",
    Description = "Removes fog for better visibility",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.FogEnd = 100000
        Fluent:Notify({
            Title = "Utility",
            Content = "Fog removed.",
            Duration = 3
        })
    end
})
UtilitySection:AddButton({
    Title = "Full Bright",
    Description = "Increases brightness",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 2
        lighting.GlobalShadows = false
        Fluent:Notify({
            Title = "Utility",
            Content = "Full bright enabled.",
            Duration = 3
        })
    end
})

-- Quests Section (2 functions)
local QuestsSection = Tabs.Quests:AddSection("Quest Automation")
QuestsSection:AddToggle("AutoQuest", {
    Title = "Auto Bandit Quest",
    Description = "Automatically accepts and completes Bandit Quest",
    Default = false,
    Callback = function(value)
        AutoQuest = value
        if value then
            spawn(AutoQuestLoop)
        end
    end
})
QuestsSection:AddButton({
    Title = "Teleport to Quest Giver",
    Description = "Teleports to the Bandit Quest Giver",
    Callback = function()
        pcall(function()
            TeleportTo(TeleportLocations["Quest Giver (Middle Town)"])
        end)
    end
})

-- Hand over to managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentBloxFruits")
SaveManager:SetFolder("FluentBloxFruits/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select the Teleport tab by default
Window:SelectTab(1)

-- Auto-load config if available
SaveManager:LoadAutoloadConfig()

-- Ensure ESP updates when character spawns
LocalPlayer.CharacterAdded:Connect(function(character)
    if WalkSpeedEnabled then
        SetWalkSpeed(true)
    end
    if ESPEnabled or ESPFruitEnabled or ESPChestEnabled then
        UpdateESP()
    end
end)
