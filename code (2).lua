--// RedzHub-Style Blox Fruits Script v2.0 - Improved & Expanded
--// Inspired by RedzHub, built with Fluent UI
--// Addresses previous errors, adds UI elements, and implements core features.
--// NOTE: Requires manual updating of placeholder RemoteEvent/Function names for Blox Fruits interaction.

--//=========================================================================================//
--// Roblox Services & Setup
--//=========================================================================================//
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack") -- For checking tools/weapons
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Re-get character parts on respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    print("RedzHub: Character respawned.")
    -- Re-apply noclip/speed if needed
    if Config and Config.Misc.NoClipEnabled.Value then task.wait(0.5); StartNoClip() end
    if Config and Config.Misc.SpeedHackEnabled.Value then task.wait(0.5); UpdateWalkSpeed() end
end)

-- Prevent multiple executions
if getgenv().RedzHubLoaded_v2 then
    warn("RedzHub v2 já está carregado! Feche a UI existente ou reinicie.")
    StarterGui:SetCore("SendNotification", {Title = "RedzHub", Text = "Script já carregado!", Duration = 5})
    return
end
getgenv().RedzHubLoaded_v2 = true

--//=========================================================================================//
--// Library Loading (Fluent UI)
--//=========================================================================================//
local Fluent = nil
local SaveManager = nil
local InterfaceManager = nil -- Less commonly needed

local function SafeLoadLib(url, name, fallbackUrl)
    local success, result
    local libSource
    success, libSource = pcall(function() return game:HttpGet(url, true) end)
    if not success or not libSource then
        warn("Falha ao baixar " .. name .. " de " .. url .. ". Erro: " .. tostring(libSource) .. ". Tentando fallback...")
        if fallbackUrl then
            success, libSource = pcall(function() return game:HttpGet(fallbackUrl, true) end)
            if not success or not libSource then
                warn("Falha ao baixar fallback " .. name .. " de " .. fallbackUrl .. ". Erro: " .. tostring(libSource))
                return nil
            end
        else
            return nil
        end
    end

    success, result = pcall(loadstring(libSource))
    if not success or not result then
        warn("Falha ao executar " .. name .. " library. Erro: " .. tostring(result))
        return nil
    end

    print(name .. " carregado com sucesso.")
    return result() -- Execute the library code
end

Fluent = SafeLoadLib(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "Fluent",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"
)

if not Fluent then
    local errorMsg = "Erro CRÍTICO: Não foi possível carregar a biblioteca Fluent UI. O script não pode iniciar. Verifique sua conexão ou tente executar o script novamente."
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", {Title = "RedzHub ERRO", Text = errorMsg, Duration = 15})
    getgenv().RedzHubLoaded_v2 = false
    return
end

-- Optional Addons
SaveManager = SafeLoadLib(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "SaveManager",
    nil
)
InterfaceManager = SafeLoadLib(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "InterfaceManager",
    nil
)

if not SaveManager then warn("SaveManager addon não carregado. Configurações não serão salvas.") end
if not InterfaceManager then warn("InterfaceManager addon não carregado.") end

--//=========================================================================================//
--// Fluent Window Setup
--//=========================================================================================//
local Window = Fluent:CreateWindow({
    Title = "RedzHub v2.0 - Blox Fruits",
    SubTitle = "by RedzHub (inspired)",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500), -- Slightly larger
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- UI Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10749531619" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "rbxassetid://10749528514" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "rbxassetid://10749529646" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "rbxassetid://10749530396" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10749537493" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "rbxassetid://10749527871" }),
    Items = Window:AddTab({ Title = "Items", Icon = "rbxassetid://10749534026"}), -- Added Items tab
    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://10749541013" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://6031069818" }), -- Different Icon
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10749540028" })
}

-- Utility: Simple notification wrapper
local function Notify(title, content, duration)
    if Config and Config.Settings.NotificationsEnabled.Value then
        Fluent:Notify({
            Title = title or "RedzHub",
            Content = content or "",
            Duration = duration or Config.Settings.NotificationDuration.Value or 5
        })
    end
    -- Optionally log notifications too
    -- Log("Notify", content)
end

-- Utility: Logging (optional, keep simple)
local function Log(category, message)
    -- print("["..category.."] " .. message) -- Simple print logging
end

--//=========================================================================================//
--// Configuration (Using Fluent Options)
--//=========================================================================================//
local Options = Fluent.Options -- Shortcut
local Config = {
    AutoFarm = {
        FarmMode = Options.Dropdown({Text = "Farm Mode", Value = "Level", Values = {"Level", "Mastery", "Quest", "Nearest Mob"}}),
        SelectWeapon = Options.Dropdown({Text = "Weapon", Value = "Auto", Values = {"Auto", "Melee", "Sword", "Gun", "Blox Fruit"}}),
        SelectedEnemy = Options.Dropdown({Text = "Select Enemy", Value = "Auto Select (Level)", Values = {"Auto Select (Level)"}}), -- Populated later
        EnableAutoFarm = Options.Toggle({Text = "Enable Auto Farm", Value = false}),
        BringMobs = Options.Toggle({Text = "Bring Mobs", Value = true}),
        AttackWhileWalking = Options.Toggle({Text = "Attack While Walking", Value = false}),
        AutoSetSpawn = Options.Toggle({Text = "Auto Set Spawn Point", Value = true}),
        AutoQuest = Options.Toggle({Text = "Auto Get/Complete Quest", Value = false}),
        QuestMode = Options.Dropdown({Text = "Quest Mode", Value = "Level Based", Values = {"Level Based", "Selected Enemy"}}),
        FarmChest = Options.Toggle({Text = "Auto Farm Chests", Value = false}),
        FarmRangeChest = Options.Slider({Text = "Chest Farm Range", Min = 50, Max = 5000, Value = 1000, Round = 0}),
        AutoSecondSea = Options.Toggle({Text = "Auto Second Sea (WIP)", Value = false}), -- WIP = Work In Progress
        AutoThirdSea = Options.Toggle({Text = "Auto Third Sea (WIP)", Value = false}),
        WalkToTarget = Options.Toggle({Text = "Walk to Target (No TP)", Value = false}),
        AttackSpeed = Options.Slider({Text = "Attack Delay (ms)", Min = 50, Max = 1000, Value = 300, Round = 0}),
    },
    Combat = {
        KillAuraEnabled = Options.Toggle({Text = "Enable Kill Aura", Value = false}),
        KillAuraRange = Options.Slider({Text = "Kill Aura Range", Min = 10, Max = 200, Value = 40, Round = 0}),
        KillAuraTargetPlayers = Options.Toggle({Text = "Target Players", Value = false}),
        KillAuraTargetNPCs = Options.Toggle({Text = "Target NPCs", Value = true}),
        AutoHakiBuso = Options.Toggle({Text = "Auto Buso/Armament Haki", Value = false}),
        AutoHakiKen = Options.Toggle({Text = "Auto Ken/Observation Haki", Value = false}),
        AutoRaceSkill = Options.Toggle({Text = "Auto Race Skill (V4)", Value = false}),
        SelectAndKillPlayer = Options.Dropdown({Text = "Target Player", Value = "None", Values = {"None"}}), -- Populated later
        BringPlayer = Options.Button({Text = "Bring Selected Player"}),
        GoToPlayer = Options.Button({Text = "Go To Selected Player"}),
    },
    ESP = {
        Enabled = Options.Toggle({Text = "Master ESP Toggle", Value = true}),
        Players = Options.Toggle({Text = "Players", Value = true}),
        PlayerColor = Options.Colorpicker({Text = "Player Color", Value = Color3.fromRGB(255, 255, 0)}),
        ShowTeam = Options.Toggle({Text = "Show Team Color", Value = true}),
        Enemies = Options.Toggle({Text = "Enemies/NPCs", Value = true}),
        EnemyColor = Options.Colorpicker({Text = "Enemy Color", Value = Color3.fromRGB(0, 255, 0)}),
        Bosses = Options.Toggle({Text = "Bosses", Value = true}),
        BossColor = Options.Colorpicker({Text = "Boss Color", Value = Color3.fromRGB(255, 0, 255)}),
        Fruits = Options.Toggle({Text = "Fruits", Value = true}),
        FruitColor = Options.Colorpicker({Text = "Fruit Color", Value = Color3.fromRGB(255, 80, 80)}),
        Chests = Options.Toggle({Text = "Chests", Value = true}),
        ChestColor = Options.Colorpicker({Text = "Chest Color", Value = Color3.fromRGB(255, 215, 0)}),
        Items = Options.Toggle({Text = "Items/Drops", Value = false}),
        ItemColor = Options.Colorpicker({Text = "Item Color", Value = Color3.fromRGB(255, 255, 255)}),
        Flowers = Options.Toggle({Text = "Flowers (Race V4)", Value = true}),
        FlowerColor = Options.Colorpicker({Text = "Flower Color", Value = Color3.fromRGB(0, 191, 255)}),
        ShowNames = Options.Toggle({Text = "Show Names", Value = true}),
        ShowDistance = Options.Toggle({Text = "Show Distance", Value = true}),
        ShowHealth = Options.Toggle({Text = "Show Health", Value = true}),
        TextSize = Options.Slider({Text = "Text Size", Min = 8, Max = 24, Value = 14, Round = 0}),
        MaxDistance = Options.Slider({Text = "Max Render Distance", Min = 100, Max = 20000, Value = 5000, Round = 0}),
        OutlineColor = Options.Colorpicker({Text = "Outline Color", Value = Color3.fromRGB(0, 0, 0)}),
        UpdateInterval = Options.Slider({Text = "Update Interval (s)", Min = 0.1, Max = 2.0, Value = 0.3, Round = 1}),
    },
    Teleport = {
        SelectedIsland = Options.Dropdown({Text = "Select Island", Value = "None", Values = {"None"}}), -- Populated later
        TeleportToIsland = Options.Button({Text = "Teleport to Island"}),
        SelectedNPC = Options.Dropdown({Text = "Select NPC", Value = "None", Values = {"None"}}), -- Populated later
        TeleportToNPC = Options.Button({Text = "Teleport to NPC"}),
        SelectedFruit = Options.Dropdown({Text = "Select Fruit", Value = "None", Values = {"None"}}), -- Populated later
        TeleportToFruit = Options.Button({Text = "Teleport to Fruit"}),
        TeleportToSea1 = Options.Button({Text = "Go to First Sea"}),
        TeleportToSea2 = Options.Button({Text = "Go to Second Sea"}),
        TeleportToSea3 = Options.Button({Text = "Go to Third Sea"}),
        TeleportToHome = Options.Button({Text = "Teleport to Home Spawn"}),
        TeleportSpeed = Options.Slider({Text = "Teleport Speed (Tween)", Min = 50, Max = 1000, Value = 200, Round = 0}),
    },
    Stats = {
        EnableAutoStats = Options.Toggle({Text = "Enable Auto Stats", Value = false}),
        Priority = Options.Dropdown({Text = "Prioritize Stat", Value = "Melee", Values = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}}),
        -- Or use priority sliders like before if preferred
        -- MeleePriority = Options.Slider({Text = "Melee Priority", Min = 0, Max = 100, Value = 50, Round = 0}),
        -- DefensePriority = Options.Slider({Text = "Defense Priority", Min = 0, Max = 100, Value = 50, Round = 0}),
        -- SwordPriority = Options.Slider({Text = "Sword Priority", Min = 0, Max = 100, Value = 0, Round = 0}),
        -- GunPriority = Options.Slider({Text = "Gun Priority", Min = 0, Max = 100, Value = 0, Round = 0}),
        -- FruitPriority = Options.Slider({Text = "Blox Fruit Priority", Min = 0, Max = 100, Value = 0, Round = 0}),
        AllocateButton = Options.Button({Text = "Allocate Remaining Points"}),
        PointsLabel = Options.Label({Text = "Points Available: 0"}),
    },
     Items = {
        EnableFruitSniper = Options.Toggle({Text = "Enable Fruit Sniper", Value = false}),
        SniperTarget = Options.Dropdown({Text = "Snipe Fruit", Value = "Any Rare", Values = {"Any Rare"}}), -- Populated later
        SniperHop = Options.Toggle({Text = "Server Hop if Fruit Found", Value = true}),
        SniperTeleport = Options.Toggle({Text = "Teleport to Sighted Fruit", Value = true}),
        AutoStoreFruit = Options.Toggle({Text = "Auto Store Valuable Fruits", Value = false}),
        StoreFruitList = Options.Dropdown({Text = "Store Fruit", Value = "Any Legendary+", Values = {"Any Legendary+", "Any Mythical"}}), -- Add specific fruits maybe?
        AutoUseRandomFruit = Options.Toggle({Text = "Auto Use Random Fruit (WIP)", Value = false}),
        AutoBuyRandomFruit = Options.Toggle({Text = "Auto Buy Random Fruit (Gacha)", Value = false}),
        GachaDelay = Options.Slider({Text = "Gacha Buy Delay (s)", Min = 1, Max = 10, Value = 2, Round = 0}),
    },
    Misc = {
        SpeedHackEnabled = Options.Toggle({Text = "WalkSpeed Enabled", Value = false}),
        SpeedHackValue = Options.Slider({Text = "Speed Value", Min = 16, Max = 250, Value = 70, Round = 0}),
        JumpPowerEnabled = Options.Toggle({Text = "JumpPower Enabled", Value = false}),
        JumpPowerValue = Options.Slider({Text = "Jump Value", Min = 50, Max = 300, Value = 100, Round = 0}),
        NoClipEnabled = Options.Toggle({Text = "Noclip (V)", Value = false}), -- V = Vertical/Simple Noclip Keybind?
        InfStamina = Options.Toggle({Text = "Infinite Stamina/Energy", Value = true}),
        AntiAFK = Options.Toggle({Text = "Anti-AFK", Value = true}),
        ServerHop = Options.Button({Text = "Hop to New Server"}),
        Rejoin = Options.Button({Text = "Rejoin Current Server"}),
        AutoFactoryFarm = Options.Toggle({Text = "Auto Farm Factory (WIP)", Value = false}),
        AutoSeaBeastFarm = Options.Toggle({Text = "Auto Farm Sea Beasts (WIP)", Value = false}),
        AutoRedeemCodes = Options.Toggle({Text = "Auto Redeem Codes (WIP)", Value = false}),
        PrintRemotes = Options.Button({Text = "Print Remotes (Debug)"}) -- For finding remotes
    },
    Visuals = {
        FOVEnabled = Options.Toggle({Text = "Enable FOV Changer", Value = false}),
        FOVValue = Options.Slider({Text = "Field of View", Min = 30, Max = 120, Value = 70, Round = 0}),
        BrightnessEnabled = Options.Toggle({Text = "Enable Brightness Control", Value = false}),
        BrightnessValue = Options.Slider({Text = "Brightness", Min = 0, Max = 2, Value = 1, Round = 1}),
        NoFog = Options.Toggle({Text = "Disable Fog", Value = false}),
        FullBright = Options.Toggle({Text = "Full Bright", Value = false}),
        RemoveSky = Options.Toggle({Text = "Remove Skybox", Value = false}),
        RemoveWater = Options.Toggle({Text = "Remove Water (Visual)", Value = false}),
        FPSUnlock = Options.Toggle({Text = "Unlock FPS Cap", Value = true}),
    },
    Settings = {
        UI_ToggleKey = Options.Keybind({Text = "Toggle UI Keybind", Value = Enum.KeyCode.RightControl}),
        UI_Theme = Options.Dropdown({Text = "UI Theme", Value = "Darker", Values = {"Darker", "Dark", "Light", "Grey", "MaterialDark"}}),
        NotificationsEnabled = Options.Toggle({Text = "Enable Notifications", Value = true}),
        NotificationDuration = Options.Slider({Text = "Notification Duration (s)", Min = 1, Max = 15, Value = 5, Round = 0}),
        SaveConfig = Options.Button({Text = "Save Config"}),
        LoadConfig = Options.Button({Text = "Load Config"}),
        ResetConfig = Options.Button({Text = "Reset Config to Defaults"}),
        DestroyUI = Options.Button({Text = "Destroy UI (Needs Re-execute)"}),
    },
    -- Internal values, not usually UI options
    Internal = {
        DefaultWalkSpeed = 16,
        DefaultJumpPower = 50,
        RareFruits = { "Leopard", "Kitsune", "Dragon", "Venom", "Dough", "T-Rex", "Mammoth", "Control", "Spirit", "Buddha", "Portal", "Rumble", "Sound", "Shadow", "Blizzard" },
        LegendaryFruits = { "Leopard", "Kitsune", "Dragon", "Venom", "Dough", "T-Rex", "Mammoth", "Control", "Spirit" }, -- Example, adjust as needed
        MythicalFruits = { "Kitsune" }, -- Example
        ESP_UpdateTimer = 0,
        IsNoclipping = false,
        CurrentFarmTarget = nil,
        CurrentQuestObjective = nil, -- Store mob name/count needed
        CurrentQuestGiver = nil,
        LastAttackTime = 0,
        LastHakiBusoTime = 0,
        LastHakiKenTime = 0,
        LastRaceSkillTime = 0,
        LastGachaTime = 0,
        AutoFarmState = "Idle", -- e.g., "Idle", "Finding Mob", "Moving", "Attacking", "Getting Quest"
        OriginalSky = nil, -- Store original skybox
    }
}

--//=========================================================================================//
--// Core Systems (ESP, Teleport, Finders, Remotes Placeholders)
--//=========================================================================================//

--// --- Remote Placeholders ---
-- !! CRITICAL: Replace these with actual Blox Fruits RemoteEvent/Function paths !!
local Remotes = {
    Damage = ReplicatedStorage.Remotes:FindFirstChild("CombatEvent"), -- EXAMPLE
    Interact = ReplicatedStorage.Remotes:FindFirstChild("InteractionEvent"), -- EXAMPLE
    UseSkill = ReplicatedStorage.Remotes:FindFirstChild("SkillEvent"), -- EXAMPLE
    AddStat = ReplicatedStorage.Remotes:FindFirstChild("StatFunction"), -- EXAMPLE (Might be InvokeServer)
    GetQuest = ReplicatedStorage.Remotes:FindFirstChild("QuestEvent"), -- EXAMPLE
    SetSpawn = ReplicatedStorage.Remotes:FindFirstChild("SpawnEvent"), -- EXAMPLE
    StoreFruit = ReplicatedStorage.Remotes:FindFirstChild("InventoryEvent"), -- EXAMPLE
    ActivateHaki = ReplicatedStorage.Remotes:FindFirstChild("HakiEvent"), -- EXAMPLE
    ActivateRace = ReplicatedStorage.Remotes:FindFirstChild("RaceEvent"), -- EXAMPLE
    TeleportToSea = ReplicatedStorage.Remotes:FindFirstChild("WorldEvent"), -- EXAMPLE
    BuyGacha = ReplicatedStorage.Remotes:FindFirstChild("ShopEvent") -- EXAMPLE
    -- Add more as needed
}
-- Function to safely fire/invoke remotes
local function FireRemote(remoteName, ...)
    local remote = Remotes[remoteName]
    if remote then
        local success, err = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...) -- Be careful with InvokeServer, can yield/error
            end
        end)
        if not success then
            Log("RemoteError", "Failed to fire/invoke "..remoteName..": "..tostring(err))
        end
        return success
    else
        Log("RemoteError", "Remote '"..remoteName.."' not found!")
        return false
    end
end

--// --- ESP System ---
local ESPCache = {} -- Store {Billboard, Adornee, Type, ConfigColor, ConfigEnabled}
local ESPContainer = Instance.new("Folder", CoreGui)
ESPContainer.Name = "RedzHubESPContainer_" .. HttpService:GenerateGUID(false)

local function ClearESP()
    for objRef, espData in pairs(ESPCache) do
        if espData and espData.Billboard then espData.Billboard:Destroy() end
    end
    ESPCache = {}
    ESPContainer:ClearAllChildren()
    Log("ESP", "Cleared all ESP elements.")
end

local function UpdateSingleESP(espData)
    if not espData or not espData.Billboard or not espData.Adornee or not espData.Adornee.Parent then return false end

    local playerRoot = RootPart -- Use cached RootPart
    if not playerRoot then return false end

    local isEnabled = Config.ESP.Enabled.Value and espData.ConfigEnabled.Value
    espData.Billboard.Enabled = isEnabled

    if isEnabled then
        local playerPos = playerRoot.Position
        local objectPos = espData.Adornee.Position
        local distance = (playerPos - objectPos).Magnitude

        -- Update Visuals
        espData.Billboard.MaxDistance = Config.ESP.MaxDistance.Value
        local nameLabel = espData.Billboard:FindFirstChild("Name", true)
        local distLabel = espData.Billboard:FindFirstChild("Distance", true)
        local healthLabel = espData.Billboard:FindFirstChild("Health", true) -- Find health label

        if nameLabel then
            nameLabel.TextColor3 = espData.ConfigColor.Value
            nameLabel.TextSize = Config.ESP.TextSize.Value
            nameLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
            nameLabel.Visible = Config.ESP.ShowNames.Value
        end
        if distLabel then
            distLabel.Text = string.format("%.0fm", distance)
            distLabel.TextColor3 = espData.ConfigColor.Value
            distLabel.TextSize = Config.ESP.TextSize.Value
            distLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
            distLabel.Visible = Config.ESP.ShowDistance.Value
        end
        -- Update Health
        if healthLabel then
            local humanoid = espData.Adornee.Parent:FindFirstChildOfClass("Humanoid") or espData.Adornee.Parent.Parent:FindFirstChildOfClass("Humanoid") -- Check parent and grandparent for humanoid
            if humanoid and Config.ESP.ShowHealth.Value then
                 local health = humanoid.Health
                 local maxHealth = humanoid.MaxHealth
                 healthLabel.Text = string.format("%.0f/%.0f HP", health, maxHealth)
                 healthLabel.TextColor3 = Color3.fromHSV(math.max(0, health/maxHealth * 0.33), 1, 1) -- Green to Red based on health
                 healthLabel.TextSize = Config.ESP.TextSize.Value - 2 -- Slightly smaller
                 healthLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
                 healthLabel.Visible = true
            else
                healthLabel.Visible = false
            end
        end

        -- Team Color Check
        if espData.Type == "Player" and Config.ESP.ShowTeam.Value then
            local player = Players:GetPlayerFromCharacter(espData.Adornee.Parent)
            if player and player.TeamColor then
                 if nameLabel then nameLabel.TextColor3 = player.TeamColor.Color end
                 if distLabel then distLabel.TextColor3 = player.TeamColor.Color end
            end
        end

    end
    return true -- Indicates the ESP element is still valid
end

local function CreateESPElement(object)
    if not object or not object.Parent or ESPCache[object] then return end -- Already exists or invalid

    local objType = "Unknown"
    local adornee = nil
    local nameText = object.Name
    local configColor = Options.Colorpicker({Value = Color3.new(1,1,1)}) -- Default white
    local configEnabled = Options.Toggle({Value = true}) -- Default enabled (controlled by master toggle)
    local showHealth = false

    -- Determine Type and Settings
    if object:IsA("Player") and object ~= LocalPlayer then -- Check if it's a Player object directly
        if Config.ESP.Players.Value then
            objType = "Player"
            adornee = object.Character and object.Character:FindFirstChild("HumanoidRootPart")
            if not adornee then return end -- No rootpart yet
            nameText = object.DisplayName
            configColor = Config.ESP.PlayerColor
            configEnabled = Config.ESP.Players
            showHealth = true
        else return -- ESP for this type disabled
        end
    elseif object:IsA("Model") and object ~= Character then -- Check Models (NPCs, Bosses)
        local humanoid = object:FindFirstChildOfClass("Humanoid")
        local root = object:FindFirstChild("HumanoidRootPart") or object.PrimaryPart
        if humanoid and root then
            adornee = root
            -- Add checks for specific bosses, quest givers etc.
            local isBoss = object.Name:match("Boss") or object:FindFirstChild("IsBoss") -- Add more specific checks
            local isQuestGiver = object:FindFirstChild("QuestGiver") or object.Name:match("Quest")
            local isEnemy = true -- Assume enemy unless proven otherwise

            if isBoss and Config.ESP.Bosses.Value then
                objType, nameText = "Boss", object.Name .. " [Boss]"
                configColor, configEnabled = Config.ESP.BossColor, Config.ESP.Bosses
                isEnemy = false; showHealth = true
            elseif isQuestGiver and Config.ESP.Enemies.Value then -- Show quest givers under enemy category? Or dedicated one?
                 objType, nameText = "QuestNPC", object.Name .. " [Quest]"
                 configColor, configEnabled = Config.ESP.EnemyColor, Config.ESP.Enemies -- Use enemy color or specific quest color?
                 isEnemy = false; showHealth = false -- Don't usually need health for quest givers
            elseif isEnemy and Config.ESP.Enemies.Value then
                 objType = "Enemy"
                 local level = object:FindFirstChild("Level")
                 nameText = object.Name .. (level and " [Lv."..tostring(level.Value).."]" or "")
                 configColor, configEnabled = Config.ESP.EnemyColor, Config.ESP.Enemies
                 showHealth = true
            else return -- ESP for this type disabled or not an enemy
            end
        else return -- Not a valid model for ESP
        end
    elseif object:IsA("BasePart") then -- Check Parts (Fruits, Chests, Items)
        adornee = object
        if (object.Name == "Fruit" or object.Parent.Name == "Fruit") and Config.ESP.Fruits.Value then
            objType = "Fruit"
            local fruitName = object.Parent:FindFirstChild("FruitName") or object:FindFirstChild("FruitName")
            nameText = fruitName and fruitName.Value or object.Name
            configColor, configEnabled = Config.ESP.FruitColor, Config.ESP.Fruits
        elseif object.Name:match("Chest") and Config.ESP.Chests.Value then
            objType = "Chest"
            nameText = "Chest"
            configColor, configEnabled = Config.ESP.ChestColor, Config.ESP.Chests
        elseif object.Name:match("Flower") and Config.ESP.Flowers.Value then -- Race V4 Flowers
             objType = "Flower"
             nameText = object.Name
             configColor, configEnabled = Config.ESP.FlowerColor, Config.ESP.Flowers
        elseif (object.Name:match("Material") or object.Name:match("Drop") or object:FindFirstAncestorWhichIsA("Tool")) and Config.ESP.Items.Value then
             objType = "Item"
             nameText = object.Name
             configColor, configEnabled = Config.ESP.ItemColor, Config.ESP.Items
        else return -- ESP for this type disabled or not a target part
        end
    else return -- Not a target for ESP
    end

    -- Create Billboard
    local billboard = Instance.new("BillboardGui", ESPContainer)
    billboard.Name = objType .. "ESP_" .. object:GetDebugId()
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 150, 0, 70) -- Increased height for health
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = Config.ESP.MaxDistance.Value
    billboard.Enabled = Config.ESP.Enabled.Value and configEnabled.Value

    -- Name Label
    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansSemibold
    nameLabel.Text = nameText
    nameLabel.TextScaled = false
    nameLabel.TextSize = Config.ESP.TextSize.Value
    nameLabel.TextColor3 = configColor.Value
    nameLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Visible = Config.ESP.ShowNames.Value

    -- Distance Label
    local distLabel = Instance.new("TextLabel", billboard)
    distLabel.Name = "Distance"
    distLabel.Size = UDim2.new(1, 0, 0, 18)
    distLabel.Position = UDim2.new(0, 0, 0, 20) -- Below name
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.SourceSans
    distLabel.Text = "0m"
    distLabel.TextScaled = false
    distLabel.TextSize = Config.ESP.TextSize.Value - 1
    distLabel.TextColor3 = configColor.Value
    distLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
    distLabel.TextStrokeTransparency = 0.5
    distLabel.Visible = Config.ESP.ShowDistance.Value

     -- Health Label
    local healthLabel = Instance.new("TextLabel", billboard)
    healthLabel.Name = "Health"
    healthLabel.Size = UDim2.new(1, 0, 0, 16)
    healthLabel.Position = UDim2.new(0, 0, 0, 38) -- Below distance
    healthLabel.BackgroundTransparency = 1
    healthLabel.Font = Enum.Font.SourceSans
    healthLabel.Text = ""
    healthLabel.TextScaled = false
    healthLabel.TextSize = Config.ESP.TextSize.Value - 2
    healthLabel.TextColor3 = Color3.new(0,1,0)
    healthLabel.TextStrokeColor3 = Config.ESP.OutlineColor.Value
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Visible = showHealth and Config.ESP.ShowHealth.Value

    -- Store in cache
    ESPCache[object] = {
        Billboard = billboard, Adornee = adornee, Type = objType,
        ConfigColor = configColor, ConfigEnabled = configEnabled, ShowHealth = showHealth
    }
end

local function ESPManagementLoop()
    -- Update existing
    local itemsToRemove = {}
    for objRef, espData in pairs(ESPCache) do
        if not objRef or not objRef.Parent then -- Check if original object is gone
            if espData.Billboard then espData.Billboard:Destroy() end
            itemsToRemove[objRef] = true
        else
            local success = pcall(UpdateSingleESP, espData) -- Update visuals and enabled state
            if not success then -- Update failed (e.g., adornee destroyed)
                 if espData.Billboard then espData.Billboard:Destroy() end
                 itemsToRemove[objRef] = true
            end
        end
    end
    for objRef, _ in pairs(itemsToRemove) do
        ESPCache[objRef] = nil
    end

    -- Check for new objects (less frequently maybe?)
    local function CheckInstance(instance)
        pcall(CreateESPElement, instance)
    end

    -- Check players
    for _, player in ipairs(Players:GetPlayers()) do CheckInstance(player) end
    -- Check workspace items
    for _, item in ipairs(Workspace:GetChildren()) do CheckInstance(item) end
    -- Consider checking specific folders like Workspace.Enemies, Workspace.Fruits if they exist
end

--// --- Teleport System ---
local function Teleport(position, useTween)
    if not RootPart then Log("Teleport", "Player RootPart not found."); return false end
    if not position then Log("Teleport", "Invalid teleport position."); return false end

    local success, err = pcall(function()
        local dist = (RootPart.Position - position).Magnitude
        local targetCFrame = CFrame.new(position + Vector3.new(0, 3, 0)) -- Offset up

        if useTween == false or dist < 50 then -- Don't tween for short distances or if disabled
            RootPart.CFrame = targetCFrame
            task.wait(0.1)
        else
            local duration = math.clamp(dist / (Config.Teleport.TeleportSpeed.Value * 3), 0.2, 2.5) -- Calculate duration (factor of 3 for studs/s feel)
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            local tween = TweenService:Create(RootPart, tweenInfo, { CFrame = targetCFrame })
            tween:Play()
            -- Don't wait by default, let other things run
            -- tween.Completed:Wait()
        end
    end)
    if not success then
        Notify("Teleport Error", "Failed: " .. tostring(err), 5)
        Log("Teleport", "Error: " .. tostring(err))
    end
    return success
end

--// --- Finders ---
local function FindClosestInstance(filterFunc, maxDist)
    local closestDist = maxDist or Config.ESP.MaxDistance.Value
    local closestInstance = nil
    local playerPos = RootPart and RootPart.Position

    if not playerPos then return nil end

    local function check(instance)
         if instance == Character or (instance:IsA("Player") and instance == LocalPlayer) then return end -- Skip self

         if filterFunc(instance) then
             local pos = nil
             if instance:IsA("BasePart") then pos = instance.Position
             elseif instance:IsA("Model") and instance.PrimaryPart then pos = instance.PrimaryPart.Position
             elseif instance:IsA("Player") and instance.Character and instance.Character:FindFirstChild("HumanoidRootPart") then pos = instance.Character.HumanoidRootPart.Position
             end

             if pos then
                 local dist = (playerPos - pos).Magnitude
                 if dist < closestDist then
                     closestDist = dist
                     closestInstance = instance
                 end
             end
         end
    end

    -- Check players, workspace children, potentially other locations
    for _, p in ipairs(Players:GetPlayers()) do check(p) end
    for _, c in ipairs(Workspace:GetChildren()) do check(c) end
    -- Check inside known folders if needed (e.g., Workspace.Enemies)

    return closestInstance, closestDist
end

local function GetPlayerLevel()
    return LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level") and LocalPlayer.Data.Level.Value or 1
end

local function GetStatPoints()
    return LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Points") and LocalPlayer.Data.Points.Value or 0
end

--// --- Data Lists (Hardcoded - Needs Updates!) ---
-- Wrap in functions to potentially load dynamically later
local function GetIslandData()
    return {
        -- Sea 1
        ["Starter Island (Pirate)"] = { Position = Vector3.new(-1100, 10, 3500), Sea = 1 },
        ["Starter Island (Marine)"] = { Position = Vector3.new(-2600, 10, 2000), Sea = 1 },
        ["Jungle"] = { Position = Vector3.new(-1200, 10, 1500), Sea = 1 },
        ["Pirate Village"] = { Position = Vector3.new(-1100, 10, 3500), Sea = 1 },
        ["Desert"] = { Position = Vector3.new(1000, 10, 4000), Sea = 1 },
        ["Frozen Village"] = { Position = Vector3.new(1000, 10, 6000), Sea = 1 },
        ["Middle Town"] = { Position = Vector3.new(140, 10, 160), Sea = 1 },
        ["Colosseum"] = { Position = Vector3.new(-1500, 10, 8000), Sea = 1 },
        ["Prison"] = { Position = Vector3.new(5000, 10, 3000), Sea = 1 },
        ["Magma Village"] = { Position = Vector3.new(-5000, 10, 4000), Sea = 1 },
        ["Underwater City"] = { Position = Vector3.new(4000, -50, -2000), Sea = 1 },
        ["Skylands (Upper Yard)"] = { Position = Vector3.new(-5000, 1000, -2000), Sea = 1 },
        ["Fountain City"] = { Position = Vector3.new(5000, 10, -4000), Sea = 1 },
        -- Sea 2
        ["Kingdom of Rose"] = { Position = Vector3.new(-2000, 10, -2000), Sea = 2 },
        ["Cafe"] = { Position = Vector3.new(-380, 10, 300), Sea = 2 },
        ["Green Zone"] = { Position = Vector3.new(-2500, 10, 3000), Sea = 2 },
        ["Graveyard"] = { Position = Vector3.new(-5000, 10, 500), Sea = 2 },
        ["Snow Mountain"] = { Position = Vector3.new(2000, 10, 4000), Sea = 2 },
        ["Hot and Cold"] = { Position = Vector3.new(-6000, 10, -3000), Sea = 2 },
        ["Cursed Ship"] = { Position = Vector3.new(9000, 10, 500), Sea = 2 },
        ["Ice Castle"] = { Position = Vector3.new(5500, 10, -6000), Sea = 2 },
        ["Forgotten Island"] = { Position = Vector3.new(-3000, 10, -5000), Sea = 2 },
        ["Dark Arena"] = { Position = Vector3.new(-5000, 10, 2000), Sea = 2 },
        ["Factory"] = { Position = Vector3.new(-2000, 10, -1500), Sea = 2 },
        -- Sea 3
        ["Port Town"] = { Position = Vector3.new(-300, 10, 5000), Sea = 3 },
        ["Hydra Island"] = { Position = Vector3.new(5000, 10, 6000), Sea = 3 },
        ["Great Tree"] = { Position = Vector3.new(2000, 10, 7000), Sea = 3 },
        ["Floating Turtle"] = { Position = Vector3.new(-1000, 10, 8000), Sea = 3 },
        ["Castle on the Sea"] = { Position = Vector3.new(-5000, 10, 9000), Sea = 3 },
        ["Haunted Castle"] = { Position = Vector3.new(-9500, 10, 6000), Sea = 3 },
        ["Sea of Treats"] = { Position = Vector3.new(0, 10, 10000), Sea = 3 },
        ["Tiki Outpost"] = { Position = Vector3.new(-16000, 10, 8000), Sea = 3 },
    }
end

local function GetNPCData()
     -- Store NPC Name -> { NameMatch (for finding instance), Position (Optional, use Island + Offset?) }
     return {
        -- Generic / Important
        ["Blox Fruit Dealer (Sea 1)"] = { NameMatch = "Blox Fruit Dealer", Position = GetIslandData()["Middle Town"].Position + Vector3.new(50,0,50) },
        ["Blox Fruit Gacha (Cafe)"] = { NameMatch = "Blox Fruit Gacha", Position = GetIslandData()["Cafe"].Position + Vector3.new(30,0,-50) },
        ["Awakening Expert (Hot/Cold)"] = { NameMatch = "Awakening Expert", Position = GetIslandData()["Hot and Cold"].Position + Vector3.new(0,50,0) },
        ["Bartilo (Cafe - Quests)"] = { NameMatch = "Bartilo", Position = GetIslandData()["Cafe"].Position + Vector3.new(0,0,-20) },
        ["Elite Hunter (Cafe)"] = { NameMatch = "Elite Hunter", Position = GetIslandData()["Cafe"].Position + Vector3.new(40,0,0) },
        ["Elite Hunter (Castle Sea)"] = { NameMatch = "Elite Hunter", Position = GetIslandData()["Castle on the Sea"].Position + Vector3.new(0,0,50) },
        ["Ancient One (Race V4 - Tree)"] = { NameMatch = "Ancient One", Position = GetIslandData()["Great Tree"].Position + Vector3.new(0,100,0) }, -- Position needs refinement
        -- Sea 1 Quest Givers
        ["Quest Giver (Pirate Starter)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Pirate Village"].Position + Vector3.new(10,0,10) },
        ["Quest Giver (Marine Starter)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Starter Island (Marine)"].Position + Vector3.new(10,0,10) },
        ["Quest Giver (Jungle)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Jungle"].Position + Vector3.new(0,0,-20) },
        -- Add many more... Sea 2, Sea 3
        ["Quest Giver (Rose Kingdom)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Kingdom of Rose"].Position + Vector3.new(-50,0,0) },
        ["Quest Giver (Port Town)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Port Town"].Position + Vector3.new(0,0,50) },
        ["Quest Giver (Floating Turtle)"] = { NameMatch = "Quest Giver", Position = GetIslandData()["Floating Turtle"].Position + Vector3.new(50,0,0) },
    }
end

local function GetEnemyData()
    -- Name -> { NameMatch, Level, QuestNPC (Name from GetNPCData), Island (Name from GetIslandData) }
    return {
        -- Sea 1
        ["Bandit"] = { NameMatch = "Bandit", Level = 5, QuestNPC = "Quest Giver (Pirate Starter)", Island = "Pirate Village" },
        ["Monkey"] = { NameMatch = "Monkey", Level = 14, QuestNPC = "Quest Giver (Jungle)", Island = "Jungle" },
        ["Gorilla"] = { NameMatch = "Gorilla", Level = 20, QuestNPC = "Quest Giver (Jungle)", Island = "Jungle" },
        ["Pirate"] = { NameMatch = "Pirate", Level = 30, QuestNPC = "Quest Giver (Pirate Village)", Island = "Pirate Village" },
        -- ... Add many more
        -- Sea 2
        ["Raider"] = { NameMatch = "Raider", Level = 700, QuestNPC = "Quest Giver (Rose Kingdom)", Island = "Kingdom of Rose" },
        ["Mercenary"] = { NameMatch = "Mercenary", Level = 725, QuestNPC = "Quest Giver (Rose Kingdom)", Island = "Kingdom of Rose" },
        ["Swan Pirate"] = { NameMatch = "Swan Pirate", Level = 775, QuestNPC = "Bartilo (Cafe - Quests)", Island = "Green Zone" },
        -- ... Add many more
        -- Sea 3
        ["Marine Captain"] = { NameMatch = "Marine Captain", Level = 1525, QuestNPC = "Quest Giver (Port Town)", Island = "Port Town"},
        ["Forest Pirate"] = { NameMatch = "Forest Pirate", Level = 1700, QuestNPC = "Quest Giver (Floating Turtle)", Island = "Great Tree"},
        -- ... Add many more
    }
end

--// --- Update UI Dropdowns ---
local function UpdateUIDropdowns()
    task.spawn(function() -- Use task.spawn to avoid yielding if data loading is slow
        -- Islands
        local islandNames = {"None"}
        local islandData = GetIslandData()
        for name, _ in pairs(islandData) do table.insert(islandNames, name) end
        table.sort(islandNames)
        Config.Teleport.SelectedIsland.UpdateValues(islandNames)

        -- NPCs
        local npcNames = {"None"}
        local npcData = GetNPCData()
        for name, _ in pairs(npcData) do table.insert(npcNames, name) end
        table.sort(npcNames)
        Config.Teleport.SelectedNPC.UpdateValues(npcNames)

        -- Fruits (In Workspace)
        local fruitNames = {"None"}
        local fruitObjects = {}
        for _, obj in ipairs(Workspace:GetChildren()) do
            if (obj.Name == "Fruit" or obj.Parent.Name == "Fruit") and obj:IsA("BasePart") then
                 local fruitNameInst = obj.Parent:FindFirstChild("FruitName") or obj:FindFirstChild("FruitName")
                 if fruitNameInst then
                      local name = fruitNameInst.Value
                      if not fruitObjects[name] then
                          table.insert(fruitNames, name)
                          fruitObjects[name] = true
                      end
                 end
            end
        end
        table.sort(fruitNames)
        Config.Teleport.SelectedFruit.UpdateValues(fruitNames)
        Config.Items.SniperTarget.UpdateValues({"Any Rare", "Any Legendary+", "Any Mythical", unpack(fruitNames)}) -- Add found fruits to sniper

        -- Enemies
        local enemyNames = {"Auto Select (Level)", "Nearest Mob"}
        local enemyData = GetEnemyData()
        local sortedEnemyKeys = {}
        for name, _ in pairs(enemyData) do table.insert(sortedEnemyKeys, name) end
        table.sort(sortedEnemyKeys, function(a, b) return (enemyData[a].Level or 0) < (enemyData[b].Level or 0) end)
        for _, name in ipairs(sortedEnemyKeys) do table.insert(enemyNames, name .. " (Lv." .. (enemyData[name].Level or "?") .. ")") end
        Config.AutoFarm.SelectedEnemy.UpdateValues(enemyNames)

        -- Players
        local playerNames = {"None"}
        for _, p in ipairs(Players:GetPlayers()) do
             if p ~= LocalPlayer then table.insert(playerNames, p.DisplayName) end
        end
        Config.Combat.SelectAndKillPlayer.UpdateValues(playerNames)
    end)
end


--//=========================================================================================//
--// Feature Implementations (AutoFarm, Combat, Stats, Misc, Visuals)
--//=========================================================================================//

--// --- AutoFarm ---
local function GetBestWeapon()
    local selected = Config.AutoFarm.SelectWeapon.Value
    if selected ~= "Auto" then return selected end

    -- Auto Logic: Prioritize equipped Fruit > Sword > Gun > Melee (adjust priority as needed)
    local currentTool = Character:FindFirstChildOfClass("Tool")
    if currentTool then
        if currentTool:FindFirstChild("IsBloxFruit") then return "Blox Fruit" -- Assuming a marker exists
        elseif currentTool:FindFirstChild("IsSword") then return "Sword"
        elseif currentTool:FindFirstChild("IsGun") then return "Gun"
    end
    return "Melee" -- Default to Melee/Combat
end

local function AttackTarget(target)
    if not target or not target:FindFirstChild("HumanoidRootPart") or not target:FindFirstChildOfClass("Humanoid") or target.Humanoid.Health <= 0 then
        Config.Internal.CurrentFarmTarget = nil -- Target died or invalid
        return
    end

    local targetHRP = target.HumanoidRootPart
    local playerPos = RootPart.Position
    local targetPos = targetHRP.Position
    local dist = (playerPos - targetPos).Magnitude

    -- Move closer if needed (and not walking)
    if not Config.AutoFarm.AttackWhileWalking.Value and dist > 30 then -- Adjust attack range
        if Config.AutoFarm.WalkToTarget.Value then
             Humanoid:MoveTo(targetPos)
        else
             Teleport(targetPos - (targetPos - playerPos).Unit * 15, false) -- TP closer, no tween
             task.wait(0.1)
        end
    end

    -- Face target
    RootPart.CFrame = CFrame.new(playerPos, targetPos)

    -- Attack Logic (Replace with actual remotes)
    local weapon = GetBestWeapon()
    local now = tick()
    if now - Config.Internal.LastAttackTime > (Config.AutoFarm.AttackSpeed.Value / 1000) then
        Log("AutoFarm", "Attacking " .. target.Name .. " with " .. weapon)
        if weapon == "Melee" then
            FireRemote("Damage", target, "M1_Combat") -- FAKE REMOTE
            VirtualUser:ClickButton1(Vector2.new()) -- Simulate mouse click for some melee
        elseif weapon == "Sword" then
             -- Equip sword if needed
             FireRemote("Damage", target, "M1_Sword") -- FAKE REMOTE
        elseif weapon == "Gun" then
             -- Equip gun if needed
             FireRemote("Damage", target, "M1_Gun") -- FAKE REMOTE
         elseif weapon == "Blox Fruit" then
             -- Cycle through skills (Z, X, C, V, F?) - Needs specific logic/remotes
             FireRemote("UseSkill", target, "Z") -- FAKE REMOTE
             -- Add logic for other keys based on cooldowns
        end
        Config.Internal.LastAttackTime = now
    end
end

local function GetCurrentQuestInfo()
    -- !!! Needs game-specific logic to read quest UI/data !!!
    -- Example return: { MobName = "Bandit", Current = 5, Needed = 8, Giver = "Quest Giver (Pirate Starter)" }
    -- For now, use internal state if AutoQuest set it
    if Config.Internal.CurrentQuestObjective then
        return {
            MobName = Config.Internal.CurrentQuestObjective.MobName,
            Needed = Config.Internal.CurrentQuestObjective.Needed,
            Giver = Config.Internal.CurrentQuestGiver,
            IsComplete = function() -- Placeholder check
                -- Add logic here to check if the target mobs are actually dead
                -- Or if a "Quest Complete" message appeared
                return false -- Assume not complete
            end
        }
    end
    return nil
end

local function SelectEnemyForFarm()
    local mode = Config.AutoFarm.FarmMode.Value
    local questInfo = GetCurrentQuestInfo()

    -- Priority 1: Quest Mob
    if (mode == "Quest" or Config.AutoFarm.AutoQuest.Value) and questInfo and not questInfo.IsComplete() then
        Config.Internal.AutoFarmState = "Farming Quest Mob"
        return questInfo.MobName, true -- Return name and boolean indicating it's a quest target

    -- Priority 2: User Selected Mob
    elseif Config.AutoFarm.SelectedEnemy.Value ~= "Auto Select (Level)" and Config.AutoFarm.SelectedEnemy.Value ~= "Nearest Mob" then
        Config.Internal.AutoFarmState = "Farming Selected Mob"
        local rawName = Config.AutoFarm.SelectedEnemy.Value
        local actualName = rawName:match("^(.*)%s*%(") or rawName -- Extract name before "(Lv..."
        return actualName, false

    -- Priority 3: Nearest Mob
    elseif Config.AutoFarm.SelectedEnemy.Value == "Nearest Mob" then
         Config.Internal.AutoFarmState = "Farming Nearest Mob"
         local closest, _ = FindClosestInstance(function(inst)
              return inst:IsA("Model") and inst:FindFirstChildOfClass("Humanoid") and inst.Humanoid.Health > 0 and inst ~= Character
         end, 500) -- Find closest within 500 studs
         return closest and closest.Name or nil, false

    -- Priority 4: Auto Select by Level
    else
        Config.Internal.AutoFarmState = "Farming Level Mob"
        local playerLevel = GetPlayerLevel()
        local bestEnemy = nil
        local smallestLevelDiff = 100 -- Prioritize mobs slightly lower or equal level first

        local enemyData = GetEnemyData()
        for name, data in pairs(enemyData) do
            if data.Level then
                 local levelDiff = playerLevel - data.Level
                 -- Target mobs <= player level, find closest level below player
                 if levelDiff >= -5 and levelDiff < smallestLevelDiff then -- Allow farming mobs slightly higher level too
                     smallestLevelDiff = levelDiff
                     bestEnemy = name
                 end
            end
        end
        return bestEnemy, false
    end
end

local function GoToQuestNPC(npcName)
    local npcData = GetNPCData()[npcName]
    if not npcData then Log("AutoQuest", "NPC data not found for: "..npcName); return false end

    local npcPosition = npcData.Position
    if not npcPosition then
        Log("AutoQuest", "NPC position not found for: "..npcName)
        -- Try finding by name match if position unknown? Risky.
        return false
    end

    Log("AutoQuest", "Moving to Quest NPC: " .. npcName)
    Config.Internal.AutoFarmState = "Moving to Quest Giver"
    local success = false
    if Config.AutoFarm.WalkToTarget.Value then
         Humanoid:MoveTo(npcPosition)
         -- Need a way to check if arrived
         success = true -- Assume walking started
    else
        success = Teleport(npcPosition, true)
    end

    if success then
        task.wait(1.5) -- Wait after arriving
        -- Find NPC Instance
        local npcInstance, dist = FindClosestInstance(function(inst)
              return inst:IsA("Model") and inst.Name:match(npcData.NameMatch or npcName) -- Use NameMatch if available
          end, 50) -- Search nearby

        if npcInstance then
            Log("AutoQuest", "Interacting with " .. npcInstance.Name)
            -- Interact (Replace with actual remote)
            FireRemote("Interact", npcInstance) -- FAKE REMOTE
            Config.Internal.CurrentQuestGiver = npcName -- Remember who gave the quest
            Config.Internal.CurrentQuestObjective = nil -- Clear old objective, needs to be set by game event/UI read
            task.wait(1) -- Wait for quest dialogue/assignment
            -- !!! Add logic here to read quest UI to determine MobName and Needed count !!!
            -- Example: Config.Internal.CurrentQuestObjective = { MobName = "Bandit", Needed = 8 }
            return true
        else
            Log("AutoQuest", "Could not find NPC instance near target position.")
            return false
        end
    end
    return false
end

local function AutoFarmLoop()
    if not Config.AutoFarm.EnableAutoFarm.Value then
        Config.Internal.AutoFarmState = "Idle"
        Config.Internal.CurrentFarmTarget = nil
        return
    end

    -- Auto Quest Logic
    if Config.AutoFarm.AutoQuest.Value then
        local questInfo = GetCurrentQuestInfo() -- Check current quest status
        if not questInfo or questInfo.IsComplete() then
            Log("AutoQuest", "No quest or quest complete. Getting new one.")
            Config.Internal.AutoFarmState = "Getting Quest"
            local enemyForQuest, _ = SelectEnemyForFarm() -- Find appropriate level mob
            local enemyData = GetEnemyData()[enemyForQuest or ""]
            if enemyData and enemyData.QuestNPC then
                if not GoToQuestNPC(enemyData.QuestNPC) then
                     Log("AutoQuest", "Failed to get quest from " .. enemyData.QuestNPC)
                     task.wait(5) -- Wait before retrying quest logic
                     return -- Exit loop iteration if quest getting failed
                end
            else
                 Log("AutoQuest", "Cannot determine Quest NPC for level/selection.")
                 task.wait(5)
                 return
            end
        end
    end

    -- Mob Farming Logic
    local targetEnemyName, isQuestTarget = SelectEnemyForFarm()
    if not targetEnemyName then
        Log("AutoFarm", "No target enemy found for current settings.")
        Config.Internal.AutoFarmState = "Idle"
        task.wait(2)
        return
    end

    -- Find Target Instance
    Config.Internal.AutoFarmState = "Finding Mob ("..targetEnemyName..")"
    local targetInstance, targetDist = FindClosestInstance(function(inst)
        return inst:IsA("Model") and inst.Name == targetEnemyName and inst:FindFirstChildOfClass("Humanoid") and inst.Humanoid.Health > 0
    end, Config.ESP.MaxDistance.Value) -- Use ESP range

    if targetInstance then
        Config.Internal.CurrentFarmTarget = targetInstance
        Config.Internal.AutoFarmState = "Attacking Mob"
        AttackTarget(targetInstance)

        -- Auto Set Spawn (If close enough to mob)
        if Config.AutoFarm.AutoSetSpawn.Value and targetDist and targetDist < 50 then
             pcall(FireRemote, "SetSpawn") -- FAKE REMOTE
        end

    else -- Target not found
        Config.Internal.CurrentFarmTarget = nil
        Log("AutoFarm", "Target "..targetEnemyName.." not found nearby. Moving to spawn area.")
        Config.Internal.AutoFarmState = "Moving to Mob Area"
        local enemyData = GetEnemyData()[targetEnemyName]
        local islandData = GetIslandData()
        if enemyData and enemyData.Island and islandData[enemyData.Island] then
            local islandPos = islandData[enemyData.Island].Position
            if (RootPart.Position - islandPos).Magnitude > 100 then -- Only move if far
                 if Config.AutoFarm.WalkToTarget.Value then Humanoid:MoveTo(islandPos)
                 else Teleport(islandPos, true)
                 end
                 task.wait(1) -- Wait after moving to island
            end
        else
             Log("AutoFarm", "Cannot determine spawn island for " .. targetEnemyName)
        end
        task.wait(1) -- Wait before searching again
    end
end

local function AutoChestFarmLoop()
     if not Config.AutoFarm.FarmChest.Value then return end

     local chestInstance, chestDist = FindClosestInstance(function(inst)
         return inst:IsA("BasePart") and inst.Name:match("Chest")
     end, Config.AutoFarm.FarmRangeChest.Value)

     if chestInstance then
         Log("AutoChest", "Found chest at " .. tostring(chestInstance.Position))
         local targetPos = chestInstance.Position
         local success = false
         if Config.AutoFarm.WalkToTarget.Value then
              Humanoid:MoveTo(targetPos)
              success = true -- Assume walking starts
         else
              success = Teleport(targetPos, false) -- No tween for chests usually
         end
         if success then task.wait(0.6) end -- Wait briefly for collection/arrival
     else
         task.wait(3) -- Wait longer if no chests found
     end
end

--// --- Combat ---
local function KillAuraLoop()
    if not Config.Combat.KillAuraEnabled.Value then return end

    local range = Config.Combat.KillAuraRange.Value
    local targetPlayers = Config.Combat.KillAuraTargetPlayers.Value
    local targetNPCs = Config.Combat.KillAuraTargetNPCs.Value

    local targets = {}
    local playerPos = RootPart.Position

    for _, potentialTarget in ipairs(Workspace:GetChildren()) do
         if potentialTarget:IsA("Model") and potentialTarget ~= Character then
             local hrp = potentialTarget:FindFirstChild("HumanoidRootPart")
             local hum = potentialTarget:FindFirstChildOfClass("Humanoid")
             if hrp and hum and hum.Health > 0 then
                 local isPlayer = Players:GetPlayerFromCharacter(potentialTarget)
                 local isEnemy = not isPlayer -- Simplistic check, refine if needed
                 if (isPlayer and targetPlayers) or (isEnemy and targetNPCs) then
                      local dist = (playerPos - hrp.Position).Magnitude
                      if dist <= range then
                          table.insert(targets, potentialTarget)
                      end
                 end
             end
         end
    end

    if #targets > 0 then
        -- Optional: Sort by distance or health?
        AttackTarget(targets[1]) -- Attack the first valid target found
    end
end

local function AutoHakiLoop()
     local now = tick()
     -- Buso/Armament
     if Config.Combat.AutoHakiBuso.Value and now - Config.Internal.LastHakiBusoTime > 10 then -- Check every 10s
         -- Check if active (Needs game specific check)
         local isActive_Buso = false -- Replace with actual check
         if not isActive_Buso then
             FireRemote("ActivateHaki", "Buso") -- FAKE REMOTE
             Log("AutoHaki", "Attempted Buso Activation")
         end
         Config.Internal.LastHakiBusoTime = now
     end
     -- Ken/Observation
     if Config.Combat.AutoHakiKen.Value and now - Config.Internal.LastHakiKenTime > 15 then -- Check every 15s
          -- Check if active (Needs game specific check)
         local isActive_Ken = false -- Replace with actual check
         if not isActive_Ken then
             FireRemote("ActivateHaki", "Ken") -- FAKE REMOTE
             Log("AutoHaki", "Attempted Ken Activation")
         end
         Config.Internal.LastHakiKenTime = now
     end
end

local function AutoRaceSkillLoop()
    if Config.Combat.AutoRaceSkill.Value and tick() - Config.Internal.LastRaceSkillTime > 30 then -- Check every 30s (adjust cooldown)
        -- Check if ready (Needs game specific check)
        local isReady = true -- Replace with actual check
        if isReady then
            FireRemote("ActivateRace") -- FAKE REMOTE
            Log("AutoRace", "Attempted Race Skill Activation")
        end
        Config.Internal.LastRaceSkillTime = tick()
    end
end

--// --- Stats ---
local function UpdateStatsLabel()
     Config.Stats.PointsLabel.SetText("Points Available: " .. GetStatPoints())
end

local function AutoStatsLoop()
    if not Config.Stats.EnableAutoStats.Value then return end
    local points = GetStatPoints()
    if points <= 0 then return end

    local statToUpgrade = Config.Stats.Priority.Value
    Log("AutoStats", "Attempting to add point to " .. statToUpgrade .. ". Points left: " .. points)
    FireRemote("AddStat", statToUpgrade) -- FAKE REMOTE
    task.wait(0.2) -- Delay between adding points
    UpdateStatsLabel() -- Update UI after attempt
end

local function AllocateRemainingPoints()
    local points = GetStatPoints()
    local statToUpgrade = Config.Stats.Priority.Value
    if points > 0 then
        Notify("Stats", "Allocating " .. points .. " points to " .. statToUpgrade .. "...", 3)
        for i = 1, points do
             if not FireRemote("AddStat", statToUpgrade) then break end -- Stop if remote fails
             task.wait(0.1)
        end
        Notify("Stats", "Allocation complete.", 3)
        UpdateStatsLabel()
    else
        Notify("Stats", "No points to allocate.", 3)
    end
end

--// --- Items ---
local function FruitSniperLoop()
    if not Config.Items.EnableFruitSniper.Value then return end

    local targetFruitName = Config.Items.SniperTarget.Value
    local foundFruitData = nil

    for _, obj in ipairs(Workspace:GetChildren()) do
         if (obj.Name == "Fruit" or obj.Parent.Name == "Fruit") and obj:IsA("BasePart") then
             local fruitNameInst = obj.Parent:FindFirstChild("FruitName") or obj:FindFirstChild("FruitName")
             if fruitNameInst then
                 local fruitName = fruitNameInst.Value
                 local isRare = table.find(Config.Internal.RareFruits, fruitName)
                 local isLegendary = table.find(Config.Internal.LegendaryFruits, fruitName)
                 local isMythical = table.find(Config.Internal.MythicalFruits, fruitName)

                 local shouldSnipe = false
                 if targetFruitName == "Any Rare" and isRare then shouldSnipe = true
                 elseif targetFruitName == "Any Legendary+" and (isLegendary or isMythical) then shouldSnipe = true
                 elseif targetFruitName == "Any Mythical" and isMythical then shouldSnipe = true
                 elseif fruitName == targetFruitName then shouldSnipe = true
                 end

                 if shouldSnipe then
                     foundFruitData = { Instance = obj, Name = fruitName, Position = obj.Position }
                     Log("FruitSniper", "Sighted target fruit: " .. fruitName)
                     Notify("Fruit Sniper", "Found: " .. fruitName .. "!", 5)
                     break
                 end
             end
         end
     end

     if foundFruitData then
         if Config.Items.SniperTeleport.Value then
             Teleport(foundFruitData.Position, false)
             task.wait(0.5)
         end
         if Config.Items.SniperHop.Value then
              Log("FruitSniper", "Fruit found, initiating server hop.")
              Notify("Fruit Sniper", "Hopping server for " .. foundFruitData.Name .. "!", 5)
              task.wait(1)
              -- Disable sniper maybe? Or let it run on new server.
              -- Config.Items.EnableFruitSniper.Value = false
              pcall(function() TeleportService:Teleport(game.PlaceId) end) -- Basic hop
         else
             -- If not hopping, disable sniper after finding one? Optional.
             -- Config.Items.EnableFruitSniper.Value = false
         end
     else
         -- Log("FruitSniper", "No target fruit found.")
     end
end

local function AutoStoreFruitLoop()
    if not Config.Items.AutoStoreFruit.Value then return end
    local targetQuality = Config.Items.StoreFruitList.Value

    local fruitInInventory = nil -- Needs game-specific check for un-stored fruits in player inventory
    local fruitName = "Dough" -- Example: Assume Dough fruit is held but not stored
    local isLegendary = table.find(Config.Internal.LegendaryFruits, fruitName)
    local isMythical = table.find(Config.Internal.MythicalFruits, fruitName)

    local shouldStore = false
    if targetQuality == "Any Legendary+" and (isLegendary or isMythical) then shouldStore = true
    elseif targetQuality == "Any Mythical" and isMythical then shouldStore = true
    end

    if fruitInInventory and shouldStore then
        Log("AutoStore", "Attempting to store " .. fruitName)
        Notify("Auto Store", "Storing " .. fruitName .. "...", 3)
        FireRemote("StoreFruit", fruitInInventory) -- FAKE REMOTE
        task.wait(1)
    end
end

local function AutoBuyGachaLoop()
    if not Config.Items.AutoBuyRandomFruit.Value then return end
    local now = tick()
    if now - Config.Internal.LastGachaTime > Config.Items.GachaDelay.Value then
        Log("AutoGacha", "Attempting to buy random fruit.")
        -- Need to check if player is near Gacha NPC? Or just fire remote?
        -- Need to check if player has enough money
        local canAfford = true -- Replace with actual check
        if canAfford then
            FireRemote("BuyGacha") -- FAKE REMOTE
            Config.Internal.LastGachaTime = now
            Notify("Auto Gacha", "Attempted to buy fruit.", 3)
        else
            Log("AutoGacha", "Cannot afford fruit or requirement not met.")
            -- Disable self?
            -- Config.Items.AutoBuyRandomFruit.Value = false
        end
    end
end

--// --- Misc ---
local function UpdateWalkSpeed()
    if Config.Misc.SpeedHackEnabled.Value then
        Humanoid.WalkSpeed = Config.Misc.SpeedHackValue.Value
    else
        Humanoid.WalkSpeed = Config.Internal.DefaultWalkSpeed
    end
end
local function UpdateJumpPower()
    if Config.Misc.JumpPowerEnabled.Value then
        Humanoid.JumpPower = Config.Misc.JumpPowerValue.Value
    else
        Humanoid.JumpPower = Config.Internal.DefaultJumpPower
    end
end

local function StartNoClip()
    Config.Internal.IsNoclipping = Config.Misc.NoClipEnabled.Value
    if Config.Internal.IsNoclipping then
        Notify("Noclip", "Noclip Enabled", 2)
    else
        Notify("Noclip", "Noclip Disabled", 2)
        pcall(function() -- Restore collisions
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end)
    end
end

local function NoclipLoop() -- Needs RenderStepped
    if Config.Internal.IsNoclipping and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        --[[ Alternative simpler noclip:
        pcall(function()
            for _, part in ipairs(Character:GetDescendants()) do
                 if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end)
        --]]
    end
end

local function UpdateInfiniteStamina()
     if Config.Misc.InfStamina.Value then
         -- Find the energy script/value and max it out constantly
         -- This is very game specific, might involve hooking a function or setting a value.
         -- Example (PSEUDOCODE): LocalPlayer.Data.Energy.Changed:Connect(function() LocalPlayer.Data.Energy.Value = LocalPlayer.Data.MaxEnergy.Value end)
         Log("InfStamina", "Enabled (Placeholder - Needs specific implementation)")
     else
         -- Undo the hook/modification
         Log("InfStamina", "Disabled (Placeholder - Needs specific implementation)")
     end
end

local lastAntiAFK = 0
local function AntiAFKLoop() -- Needs Stepped/Heartbeat
    if Config.Misc.AntiAFK.Value and tick() - lastAntiAFK > 60 then
        VirtualUser:ClickButton1(Vector2.new()) -- Simulate jump/click
        Log("AntiAFK", "Performed anti-AFK action.")
        lastAntiAFK = tick()
    end
end

local function ServerHop()
    Notify("Server Hop", "Attempting to join a new server...", 3)
    local success, err = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    if not success then Notify("Server Hop", "Failed: " .. tostring(err), 5) end
end

local function RejoinServer()
    Notify("Rejoin", "Attempting to rejoin server...", 3)
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not success then Notify("Rejoin", "Failed: " .. tostring(err), 5) end
end

local function PrintRemotes() -- Debug Tool
    Log("Debug", "Printing ReplicatedStorage Remotes:")
    for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print("- ", v:GetFullName()) -- Print full path
        end
    end
    Notify("Debug", "Printed remote list to console.", 5)
end

--// --- Visuals ---
local function UpdateFOV()
    if Workspace.CurrentCamera then
        if Config.Visuals.FOVEnabled.Value then
            Workspace.CurrentCamera.FieldOfView = Config.Visuals.FOVValue.Value
        else
            Workspace.CurrentCamera.FieldOfView = 70 -- Default FOV
        end
    end
end

local function UpdateBrightness()
    if Config.Visuals.BrightnessEnabled.Value then
        Lighting.Brightness = Config.Visuals.BrightnessValue.Value
        Lighting.Ambient = Color3.new(1,1,1) * (Config.Visuals.BrightnessValue.Value * 0.6) -- Adjust ambient based on brightness
        Lighting.OutdoorAmbient = Color3.new(1,1,1) * (Config.Visuals.BrightnessValue.Value * 0.6)
    else
        -- Restore defaults (approximate)
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromHex("808080")
        Lighting.OutdoorAmbient = Color3.fromHex("808080")
        Lighting.ClockTime = 14 -- Default time
    end
end

local function UpdateFog()
    if Config.Visuals.NoFog.Value then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 999999
    else
        -- Restore defaults (game specific, these are guesses)
        Lighting.FogEnd = 5000
        Lighting.FogStart = 0 -- Or 100?
    end
end

local function UpdateFullBright()
     if Config.Visuals.FullBright.Value then
        Lighting.ClockTime = 12 -- Noon
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(0.7, 0.7, 0.7)
        Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 999999
     else
         -- Restore based on other settings
         UpdateBrightness()
         UpdateFog()
         Lighting.ClockTime = 14
     end
end

local function UpdateSky()
    if Config.Visuals.RemoveSky.Value then
        if not Config.Internal.OriginalSky then Config.Internal.OriginalSky = Lighting:FindFirstChildOfClass("Sky") end
        if Config.Internal.OriginalSky then Config.Internal.OriginalSky.Parent = nil end
    else
        if Config.Internal.OriginalSky and Config.Internal.OriginalSky.Parent == nil then
             Config.Internal.OriginalSky.Parent = Lighting
        end
    end
end

local function UpdateWater()
    -- This usually involves changing transparency/reflectance or removing the terrain water object
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        if Config.Visuals.RemoveWater.Value then
            terrain.WaterTransparency = 1
            terrain.WaterReflectance = 1
            -- Maybe change color to fully transparent?
        else
            terrain.WaterTransparency = 0.5 -- Restore default (guess)
            terrain.WaterReflectance = 0.2 -- Restore default (guess)
        end
    end
end

local function UpdateFPSCap()
    if Config.Visuals.FPSUnlock.Value then
        if settings():GetService("DebugSettings") then -- Check if DebugSettings exists
            settings():GetService("DebugSettings").RenderingFpsCap = 9999
        else
            setfpscap(9999) -- Use global if DebugSettings not available
        end
         Log("Visuals", "FPS Cap Unlocked (Attempted).")
    else
         if settings():GetService("DebugSettings") then
            settings():GetService("DebugSettings").RenderingFpsCap = 60 -- Default cap
        else
             setfpscap(60)
        end
         Log("Visuals", "FPS Cap Restored to 60 (Attempted).")
    end
end

--// --- Settings ---
local function UpdateTheme() Window:SetTheme(Config.Settings.UI_Theme.Value) end
local function UpdateToggleKey() Window.MinimizeKey = Config.Settings.UI_ToggleKey.Value end

local function SaveConfig()
    if SaveManager then
        SaveManager:SaveSaveFile("RedzHubConfig_BF_v2")
        Notify("Settings", "Configuration Saved!", 3)
    else
        Notify("Settings", "SaveManager not loaded, cannot save.", 5)
    end
end

local function LoadConfig()
    if SaveManager then
        SaveManager:LoadSaveFile("RedzHubConfig_BF_v2")
        Notify("Settings", "Configuration Loaded!", 3)
        -- Re-apply loaded settings
        task.wait(0.1)
        UpdateWalkSpeed(); UpdateJumpPower(); StartNoClip()
        UpdateFOV(); UpdateBrightness(); UpdateFog(); UpdateFullBright(); UpdateSky(); UpdateWater(); UpdateFPSCap()
        UpdateTheme(); UpdateToggleKey()
    else
        Notify("Settings", "SaveManager not loaded, cannot load.", 5)
    end
end

local function ResetConfig()
     if SaveManager then
         SaveManager:ResetSaveFile("RedzHubConfig_BF_v2") -- Resets the file, next load will be default
         Notify("Settings", "Config reset. Reloading UI or script needed for full effect.", 5)
         -- Optionally, try to reset options manually here (more complex)
     else
          Notify("Settings", "SaveManager not loaded, cannot reset.", 5)
     end
end

local function DestroyUI()
     Notify("System", "Destroying UI...", 2)
     Window:Destroy()
     if ESPContainer then ESPContainer:Destroy() end
     -- Disconnect all connections
     for _, conn in pairs(Connections) do if conn and typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end end
     Connections = {}
     -- Restore defaults
     pcall(function() if Humanoid then Humanoid.WalkSpeed = Config.Internal.DefaultWalkSpeed; Humanoid.JumpPower = Config.Internal.DefaultJumpPower end end)
     pcall(function() if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView = 70 end end)
     pcall(UpdateBrightness) pcall(UpdateFog) pcall(UpdateFullBright) pcall(UpdateSky); pcall(UpdateWater) pcall(UpdateFPSCap)
     -- Allow re-execution
     getgenv().RedzHubLoaded_v2 = false
     Log("System", "RedzHub Cleaned Up.")
     print("RedzHub Destroyed.")
end

--//=========================================================================================//
--// UI Population (Must be after function definitions)
--//=========================================================================================//
local function PopulateUI()
    Log("UI", "Populating UI...")

    --// Main Tab
    Tabs.Main:AddLabel("Welcome to RedzHub v2!"):SetColor(Color3.fromRGB(255,80,80))
    Tabs.Main:AddLabel("Player: " .. LocalPlayer.Name)
    Tabs.Main:AddLabel("Current Level: " .. GetPlayerLevel()) -- Show initial level
    local levelLabel = Tabs.Main:AddLabel("...") -- Placeholder for dynamic update
    RunService.Stepped:Connect(function() levelLabel.SetText("Current Level: " .. GetPlayerLevel()) end) -- Update level dynamically

    Tabs.Main:AddButton({ Text = "Update Dropdowns", Callback = UpdateUIDropdowns, Tooltip="Refresh Island/NPC/Enemy/Player lists"})
    Tabs.Main:AddLabel("UI Toggle Key: Right Control (Change in Settings)")
    Tabs.Main:AddLabel("REMEMBER: Update Remotes if features stop working!")

    --// AutoFarm Tab
    local afSettings = Tabs.AutoFarm:AddSection("Settings")
    afSettings:AddToggle("EnableAutoFarm", Config.AutoFarm.EnableAutoFarm)
    afSettings:AddDropdown("FarmMode", Config.AutoFarm.FarmMode)
    afSettings:AddDropdown("SelectWeapon", Config.AutoFarm.SelectWeapon)
    afSettings:AddDropdown("SelectedEnemy", Config.AutoFarm.SelectedEnemy)
    afSettings:AddToggle("BringMobs", Config.AutoFarm.BringMobs)
    afSettings:AddToggle("AttackWhileWalking", Config.AutoFarm.AttackWhileWalking)
    afSettings:AddToggle("WalkToTarget", Config.AutoFarm.WalkToTarget):SetTooltip("Disables teleporting for farming")
    afSettings:AddSlider("AttackSpeed", Config.AutoFarm.AttackSpeed)

    local afQuestChest = Tabs.AutoFarm:AddSection("Quest & Chest")
    afQuestChest:AddToggle("AutoQuest", Config.AutoFarm.AutoQuest)
    afQuestChest:AddDropdown("QuestMode", Config.AutoFarm.QuestMode)
    afQuestChest:AddToggle("AutoSetSpawn", Config.AutoFarm.AutoSetSpawn)
    afQuestChest:AddToggle("FarmChest", Config.AutoFarm.FarmChest)
    afQuestChest:AddSlider("FarmRangeChest", Config.AutoFarm.FarmRangeChest)

    local afProgression = Tabs.AutoFarm:AddSection("Progression (WIP)")
    afProgression:AddToggle("AutoSecondSea", Config.AutoFarm.AutoSecondSea)
    afProgression:AddToggle("AutoThirdSea", Config.AutoFarm.AutoThirdSea)

    --// Combat Tab
    local killAuraSec = Tabs.Combat:AddSection("Kill Aura")
    killAuraSec:AddToggle("KillAuraEnabled", Config.Combat.KillAuraEnabled)
    killAuraSec:AddSlider("KillAuraRange", Config.Combat.KillAuraRange)
    killAuraSec:AddToggle("KillAuraTargetPlayers", Config.Combat.KillAuraTargetPlayers)
    killAuraSec:AddToggle("KillAuraTargetNPCs", Config.Combat.KillAuraTargetNPCs)

    local playerCombatSec = Tabs.Combat:AddSection("Player Targeting")
    playerCombatSec:AddDropdown("SelectAndKillPlayer", Config.Combat.SelectAndKillPlayer)
    playerCombatSec:AddButton("BringPlayer", Config.Combat.BringPlayer):SetTooltip("Teleport Selected Player to You (Risky!)")
    playerCombatSec:AddButton("GoToPlayer", Config.Combat.GoToPlayer):SetTooltip("Teleport to Selected Player")

    local autoAbilitiesSec = Tabs.Combat:AddSection("Auto Abilities")
    autoAbilitiesSec:AddToggle("AutoHakiBuso", Config.Combat.AutoHakiBuso)
    autoAbilitiesSec:AddToggle("AutoHakiKen", Config.Combat.AutoHakiKen)
    autoAbilitiesSec:AddToggle("AutoRaceSkill", Config.Combat.AutoRaceSkill)

    --// ESP Tab
    local espToggles = Tabs.ESP:AddSection("ESP Targets")
    espToggles:AddToggle("MasterESP", Config.ESP.Enabled):SetTooltip("Master toggle for all ESP")
    espToggles:AddToggle("PlayersESP", Config.ESP.Players)
    espToggles:AddToggle("EnemiesESP", Config.ESP.Enemies)
    espToggles:AddToggle("BossesESP", Config.ESP.Bosses)
    espToggles:AddToggle("FruitsESP", Config.ESP.Fruits)
    espToggles:AddToggle("ChestsESP", Config.ESP.Chests)
    espToggles:AddToggle("ItemsESP", Config.ESP.Items)
    espToggles:AddToggle("FlowersESP", Config.ESP.Flowers)

    local espVisuals = Tabs.ESP:AddSection("ESP Visuals")
    espVisuals:AddToggle("ShowNames", Config.ESP.ShowNames)
    espVisuals:AddToggle("ShowDistance", Config.ESP.ShowDistance)
    espVisuals:AddToggle("ShowHealth", Config.ESP.ShowHealth)
    espVisuals:AddToggle("ShowTeamColor", Config.ESP.ShowTeam):SetTooltip("Override player color with team color")
    espVisuals:AddSlider("TextSize", Config.ESP.TextSize)
    espVisuals:AddSlider("MaxDistance", Config.ESP.MaxDistance)
    espVisuals:AddSlider("UpdateInterval", Config.ESP.UpdateInterval)
    espVisuals:AddColorpicker("OutlineColor", Config.ESP.OutlineColor)

    local espColors = Tabs.ESP:AddSection("ESP Colors")
    espColors:AddColorpicker("PlayerColor", Config.ESP.PlayerColor)
    espColors:AddColorpicker("EnemyColor", Config.ESP.EnemyColor)
    espColors:AddColorpicker("BossColor", Config.ESP.BossColor)
    espColors:AddColorpicker("FruitColor", Config.ESP.FruitColor)
    espColors:AddColorpicker("ChestColor", Config.ESP.ChestColor)
    espColors:AddColorpicker("ItemColor", Config.ESP.ItemColor)
    espColors:AddColorpicker("FlowerColor", Config.ESP.FlowerColor)

    --// Teleport Tab
    local tpIsland = Tabs.Teleport:AddSection("Island Teleport")
    tpIsland:AddDropdown("SelectedIsland", Config.Teleport.SelectedIsland)
    tpIsland:AddButton("TeleportToIsland", Config.Teleport.TeleportToIsland)

    local tpNPC = Tabs.Teleport:AddSection("NPC Teleport")
    tpNPC:AddDropdown("SelectedNPC", Config.Teleport.SelectedNPC)
    tpNPC:AddButton("TeleportToNPC", Config.Teleport.TeleportToNPC)

    local tpFruit = Tabs.Teleport:AddSection("Fruit Teleport")
    tpFruit:AddDropdown("SelectedFruit", Config.Teleport.SelectedFruit)
    tpFruit:AddButton("TeleportToFruit", Config.Teleport.TeleportToFruit)

    local tpWorld = Tabs.Teleport:AddSection("World & Spawn")
    tpWorld:AddButton("TeleportToSea1", Config.Teleport.TeleportToSea1)
    tpWorld:AddButton("TeleportToSea2", Config.Teleport.TeleportToSea2)
    tpWorld:AddButton("TeleportToSea3", Config.Teleport.TeleportToSea3)
    tpWorld:AddButton("TeleportToHome", Config.Teleport.TeleportToHome)
    tpWorld:AddSlider("TeleportSpeed", Config.Teleport.TeleportSpeed)

    --// Stats Tab
    local statsMain = Tabs.Stats:AddSection("Auto Stats")
    statsMain:AddToggle("EnableAutoStats", Config.Stats.EnableAutoStats)
    statsMain:AddDropdown("PriorityStat", Config.Stats.Priority)
    statsMain:AddLabel("PointsLabel", Config.Stats.PointsLabel) -- Add the label
    statsMain:AddButton("AllocateButton", Config.Stats.AllocateButton)

    --// Items Tab
    local itemSniper = Tabs.Items:AddSection("Fruit Sniper")
    itemSniper:AddToggle("EnableFruitSniper", Config.Items.EnableFruitSniper)
    itemSniper:AddDropdown("SniperTarget", Config.Items.SniperTarget)
    itemSniper:AddToggle("SniperTeleport", Config.Items.SniperTeleport)
    itemSniper:AddToggle("SniperHop", Config.Items.SniperHop)

    local itemAuto = Tabs.Items:AddSection("Auto Item Actions")
    itemAuto:AddToggle("AutoStoreFruit", Config.Items.AutoStoreFruit)
    itemAuto:AddDropdown("StoreFruitList", Config.Items.StoreFruitList)
    itemAuto:AddToggle("AutoBuyRandomFruit", Config.Items.AutoBuyRandomFruit)
    itemAuto:AddSlider("GachaDelay", Config.Items.GachaDelay)
    itemAuto:AddToggle("AutoUseRandomFruit", Config.Items.AutoUseRandomFruit)

    --// Misc Tab
    local miscMovement = Tabs.Misc:AddSection("Movement")
    miscMovement:AddToggle("SpeedHackEnabled", Config.Misc.SpeedHackEnabled)
    miscMovement:AddSlider("SpeedHackValue", Config.Misc.SpeedHackValue)
    miscMovement:AddToggle("JumpPowerEnabled", Config.Misc.JumpPowerEnabled)
    miscMovement:AddSlider("JumpPowerValue", Config.Misc.JumpPowerValue)
    miscMovement:AddToggle("NoClipEnabled", Config.Misc.NoClipEnabled)
    miscMovement:AddToggle("InfStamina", Config.Misc.InfStamina)

    local miscServer = Tabs.Misc:AddSection("Server")
    miscServer:AddToggle("AntiAFK", Config.Misc.AntiAFK)
    miscServer:AddButton("ServerHop", Config.Misc.ServerHop)
    miscServer:AddButton("Rejoin", Config.Misc.Rejoin)

    local miscAutomation = Tabs.Misc:AddSection("Automation (WIP)")
    miscAutomation:AddToggle("AutoFactoryFarm", Config.Misc.AutoFactoryFarm)
    miscAutomation:AddToggle("AutoSeaBeastFarm", Config.Misc.AutoSeaBeastFarm)
    miscAutomation:AddToggle("AutoRedeemCodes", Config.Misc.AutoRedeemCodes)

    local miscDebug = Tabs.Misc:AddSection("Debug")
    miscDebug:AddButton("PrintRemotes", Config.Misc.PrintRemotes)

    --// Visuals Tab
    local visSettings = Tabs.Visuals:AddSection("Visual Settings")
    visSettings:AddToggle("FOVEnabled", Config.Visuals.FOVEnabled)
    visSettings:AddSlider("FOVValue", Config.Visuals.FOVValue)
    visSettings:AddToggle("BrightnessEnabled", Config.Visuals.BrightnessEnabled)
    visSettings:AddSlider("BrightnessValue", Config.Visuals.BrightnessValue)
    visSettings:AddToggle("NoFog", Config.Visuals.NoFog)
    visSettings:AddToggle("FullBright", Config.Visuals.FullBright)
    visSettings:AddToggle("RemoveSky", Config.Visuals.RemoveSky)
    visSettings:AddToggle("RemoveWater", Config.Visuals.RemoveWater)
    visSettings:AddToggle("FPSUnlock", Config.Visuals.FPSUnlock)

    --// Settings Tab
    local setUI = Tabs.Settings:AddSection("UI")
    setUI:AddKeybind("ToggleKey", Config.Settings.UI_ToggleKey)
    setUI:AddDropdown("Theme", Config.Settings.UI_Theme)

    local setNotif = Tabs.Settings:AddSection("Notifications")
    setNotif:AddToggle("EnableNotifs", Config.Settings.NotificationsEnabled)
    setNotif:AddSlider("NotifDuration", Config.Settings.NotificationDuration)

    local setConfig = Tabs.Settings:AddSection("Configuration")
    setConfig:AddButton("SaveConfig", Config.Settings.SaveConfig)
    setConfig:AddButton("LoadConfig", Config.Settings.LoadConfig)
    setConfig:AddButton("ResetConfig", Config.Settings.ResetConfig)
    setConfig:AddButton("DestroyUI", Config.Settings.DestroyUI)

    Log("UI", "UI Population Complete.")
end

--//=========================================================================================//
--// Event Connections & Loop Setup
--//=========================================================================================//
local Connections = {}

local function SetupConnections()
    Log("System", "Setting up connections...")
    -- Configuration changes
    Config.Misc.SpeedHackEnabled.Changed:Connect(UpdateWalkSpeed)
    Config.Misc.SpeedHackValue.Changed:Connect(UpdateWalkSpeed)
    Config.Misc.JumpPowerEnabled.Changed:Connect(UpdateJumpPower)
    Config.Misc.JumpPowerValue.Changed:Connect(UpdateJumpPower)
    Config.Misc.NoClipEnabled.Changed:Connect(StartNoClip)
    Config.Misc.InfStamina.Changed:Connect(UpdateInfiniteStamina)
    Config.Visuals.FOVEnabled.Changed:Connect(UpdateFOV)
    Config.Visuals.FOVValue.Changed:Connect(UpdateFOV)
    Config.Visuals.BrightnessEnabled.Changed:Connect(UpdateBrightness)
    Config.Visuals.BrightnessValue.Changed:Connect(UpdateBrightness)
    Config.Visuals.NoFog.Changed:Connect(UpdateFog)
    Config.Visuals.FullBright.Changed:Connect(UpdateFullBright)
    Config.Visuals.RemoveSky.Changed:Connect(UpdateSky)
    Config.Visuals.RemoveWater.Changed:Connect(UpdateWater)
    Config.Visuals.FPSUnlock.Changed:Connect(UpdateFPSCap)
    Config.Settings.UI_Theme.Changed:Connect(UpdateTheme)
    Config.Settings.UI_ToggleKey.Changed:Connect(UpdateToggleKey)

    -- Button actions
    Config.Teleport.TeleportToIsland.Changed:Connect(function() Teleport(GetIslandData()[Config.Teleport.SelectedIsland.Value]?.Position, true) end)
    Config.Teleport.TeleportToNPC.Changed:Connect(function() Teleport(GetNPCData()[Config.Teleport.SelectedNPC.Value]?.Position, true) end)
    Config.Teleport.TeleportToFruit.Changed:Connect(function()
        local fruitInst, _ = FindClosestInstance(function(inst) return inst:IsA("BasePart") and (inst.Name=="Fruit" or inst.Parent.Name=="Fruit") and inst.Parent:FindFirstChild("FruitName")?.Value == Config.Teleport.SelectedFruit.Value end, 99999)
        if fruitInst then Teleport(fruitInst.Position, false) else Notify("Teleport", "Fruit not found in workspace.", 3) end
    end)
    Config.Teleport.TeleportToSea1.Changed:Connect(function() FireRemote("TeleportToSea", 1) end) -- FAKE REMOTE ARG
    Config.Teleport.TeleportToSea2.Changed:Connect(function() FireRemote("TeleportToSea", 2) end) -- FAKE REMOTE ARG
    Config.Teleport.TeleportToSea3.Changed:Connect(function() FireRemote("TeleportToSea", 3) end) -- FAKE REMOTE ARG
    Config.Teleport.TeleportToHome.Changed:Connect(function() FireRemote("SetSpawn", "GoHome") end) -- FAKE REMOTE ARG

    Config.Combat.BringPlayer.Changed:Connect(function() print("Bring Player WIP") end) -- Needs complex implementation
    Config.Combat.GoToPlayer.Changed:Connect(function()
         local targetName = Config.Combat.SelectAndKillPlayer.Value
         local targetPlayer = Players:FindFirstChild(targetName)
         if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
             Teleport(targetPlayer.Character.HumanoidRootPart.Position, true)
         else Notify("Combat", "Player not found or no character.", 3) end
    end)
    Config.Stats.AllocateButton.Changed:Connect(AllocateRemainingPoints)
    Config.Misc.ServerHop.Changed:Connect(ServerHop)
    Config.Misc.Rejoin.Changed:Connect(RejoinServer)
    Config.Misc.PrintRemotes.Changed:Connect(PrintRemotes)
    Config.Settings.SaveConfig.Changed:Connect(SaveConfig)
    Config.Settings.LoadConfig.Changed:Connect(LoadConfig)
    Config.Settings.ResetConfig.Changed:Connect(ResetConfig)
    Config.Settings.DestroyUI.Changed:Connect(DestroyUI)

    -- Main Loops (Using task.spawn to prevent errors in one loop stopping others)
    Connections.ESP = RunService.RenderStepped:Connect(function() task.spawn(ESPManagementLoop) end)
    Connections.Noclip = RunService.RenderStepped:Connect(function() task.spawn(NoclipLoop) end)

    Connections.Heartbeat = RunService.Heartbeat:Connect(function(dt)
        -- High frequency updates
        task.spawn(AutoFarmLoop)
        task.spawn(AutoChestFarmLoop)
        task.spawn(KillAuraLoop)
        task.spawn(AutoHakiLoop)
        task.spawn(AutoRaceSkillLoop)
        task.spawn(AutoStatsLoop)
        task.spawn(FruitSniperLoop)
        task.spawn(AutoStoreFruitLoop)
        task.spawn(AutoBuyGachaLoop)
        task.spawn(AntiAFKLoop)
    end)

    -- Initial UI Updates
    UpdateUIDropdowns()
    UpdateStatsLabel()

    -- Initial Settings Application
    UpdateWalkSpeed(); UpdateJumpPower(); StartNoClip()
    UpdateFOV(); UpdateBrightness(); UpdateFog(); UpdateFullBright(); UpdateSky(); UpdateWater(); UpdateFPSCap()
    UpdateInfiniteStamina()

    -- Load saved config if SaveManager exists
    if SaveManager then
        SaveManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings() -- Don't save theme
        SaveManager:SetIgnoreIndexes({}) -- Save everything by default
        LoadConfig() -- Attempt to load saved settings
    end

    Log("System", "Connections established.")
end

--//=========================================================================================//
--// Script Initialization
--//=========================================================================================//
PopulateUI()
SetupConnections()

Notify("RedzHub v2", "Script Loaded Successfully!", 7)
Log("System", "RedzHub Initialized.")

-- Handle UI destruction explicitly
Window.Destroying:Connect(DestroyUI)

--//EOF