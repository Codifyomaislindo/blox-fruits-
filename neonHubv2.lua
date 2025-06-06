-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Variáveis Locais
local LocalPlayer = Players.LocalPlayer
local lastServerHop = tick()
local randomDelay = math.random(0.1, 0.5)
local fakeInputInterval = math.random(0.5, 1)
local serverHopInterval = 300
local currentSea = 1
local mirageSpawnTimer = 0
local kitsuneSpawnTimer = 0
local raidSpawnTimer = 0
local nearbyMobs = {}
local nearbyBosses = {}

-- Configurações Padrão
local Config = {
    General = {
        StealthMode = false,
        AntiCheatBypass = true,
        PerformanceMode = false,
        AutoSaveSettings = true,
        NotificationEnabled = true,
        Team = "Pirates",
        WebhookURL = "",
        CustomTheme = "Dark",
        AutoSaveInterval = 300,
        FakeStatsEnabled = false,
        FakeLevel = 1,
        FakeBeli = 1000,
        FakeFragments = 1000,
        HideNickname = false
    },
    Farm = {
        AutoFarmLevel = false,
        AutoFarmBoss = false,
        AutoFarmMobs = false,
        SelectedBoss = "",
        SelectedMob = "",
        SafeDistance = 10,
        MaxDistance = 1000,
        AutoFarmMaterials = false,
        SelectedMaterial = "Wood",
        AutoFarmSeaBeasts = false,
        AutoFarmMasteryMelee = false,
        AutoFarmMasterySword = false,
        AutoFarmMasteryGun = false,
        AutoFarmMasteryFruit = false,
        FarmAboveEnemy = true
    },
    Combat = {
        ESPEnabled = false,
        ESPColor = Color3.fromRGB(255, 0, 0),
        ESPDistance = 1000,
        AimBotEnabled = false,
        AimBotFOV = 100,
        KillAura = false,
        AutoSkill = false,
        AutoClick = false,
        AutoGodMode = false,
        InfiniteStamina = false,
        AutoDodge = false,
        DodgeDistance = 20,
        AutoBlock = false,
        AutoParry = false
    },
    Quests = {
        AutoQuest = false,
        SelectedNPC = "Quest Giver",
        AutoEliteHunter = false,
        AutoLegendarySwordQuest = false,
        AutoRaceV4 = false,
        AutoDarkbeard = false,
        AutoRipIndra = false,
        AutoTushitaQuest = false,
        AutoYamaQuest = false
    },
    Fruits = {
        AutoCollectFruits = false,
        AutoStoreFruits = false,
        AutoEatFruit = false,
        AutoSnipeFruit = false,
        SnipeFruitName = "Dragon",
        AutoFarmFruitMastery = false,
        AutoFindLegendaryFruit = false,
        AutoAwakenFruit = false,
        AutoTradeLegendaryFruit = false,
        AutoStoreAllFruits = false,
        AutoDropFruit = false
    },
    Raids = {
        AutoRaid = false,
        SelectedRaid = "Law Raid",
        AutoAwaken = false,
        AutoBuyChip = false,
        AutoFarmRaidTokens = false,
        AutoCompleteRaidChallenges = false,
        AutoFarmAwakeningMaterials = false,
        AutoFarmRaidEnemies = false,
        AutoSkipRaidWave = false,
        AutoFarmRaidBoss = false
    },
    Teleport = {
        NoClip = false,
        TeleportToIsland = false,
        SelectedIsland = "Windmill",
        TeleportToPlayer = false,
        SelectedPlayer = "",
        SafeTeleport = false,
        TeleportToChest = false,
        TeleportToFruit = false,
        TeleportToBoss = false,
        TeleportToNPC = false,
        TeleportToMaterial = false,
        TeleportToSafeZone = false,
        TeleportToEvent = false,
        TeleportToSeaBeast = false
    },
    Visuals = {
        RemoveFog = false,
        FullBright = false,
        FPSBoost = false,
        RemoveTextures = false,
        ShowHitbox = false,
        ESPPlayers = false,
        ESPChests = false,
        ESPFruits = false,
        ESPBosses = false,
        ESPMobs = false,
        ESPNPCs = false,
        ESPMaterials = false,
        ESPColorPlayers = Color3.fromRGB(0, 255, 0),
        ESPColorChests = Color3.fromRGB(255, 215, 0),
        ESPColorFruits = Color3.fromRGB(255, 0, 0),
        ESPColorBosses = Color3.fromRGB(255, 0, 255),
        ESPColorMobs = Color3.fromRGB(0, 255, 255),
        ESPColorNPCs = Color3.fromRGB(255, 255, 0),
        ESPColorMaterials = Color3.fromRGB(0, 255, 255),
        ESPDistanceVisuals = 1000
    },
    Stats = {
        AutoStats = false,
        SpeedHack = false,
        JumpPowerHack = false,
        AutoHaki = false,
        AutoDefense = false,
        DefenseThreshold = 30,
        SpeedValue = 50,
        JumpPowerValue = 50,
        AutoMastery = false,
        MasteryType = "Melee",
        AutoUpgradeBusoshoku = false,
        AutoUpgradeKen = false,
        AutoUpgradeGeppo = false,
        AutoUpgradeSoru = false,
        AutoUpgradeTekkai = false,
        AutoUpgradeShigan = false
    },
    Shop = {
        AutoBuyWeapons = false,
        AutoBuyAccessories = false,
        AutoBuyFruits = false,
        AutoBuyHakiColors = false,
        SelectedWeapon = "Saber",
        AutoBuyRandom = false,
        AutoRollBones = false,
        AutoBuyGamepasses = false,
        SelectedGamepass = "2x Mastery",
        AutoBuyFragments = false,
        AutoBuyBeli = false,
        AutoBuyLegendarySword = false,
        AutoBuyFightingStyle = false,
        SelectedFightingStyle = "Dragon Talon",
        AutoBuyRareItems = false,
        AutoBuyBoats = false
    },
    Misc = {
        ServerHop = false,
        ServerHopInterval = 300,
        SafeMode = false,
        PanicMode = false,
        AntiAFK = false,
        AutoRejoin = false,
        AutoDisconnect = false,
        DisconnectThreshold = 20,
        AutoRedeemCodes = false,
        WebhookEnabled = false,
        AutoJoinCrew = false,
        CrewID = "",
        AutoDonate = false,
        DonateAmount = 1000,
        AutoKickSuspiciousPlayers = false,
        AutoReportPlayers = false,
        AutoFakeDisconnect = false,
        AutoSpoofStats = false,
        AutoHideIdentity = false
    },
    Automation = {
        AutoEquipBestWeapon = false,
        AutoEquipBestFruit = false,
        AutoTradeFruits = false,
        AutoDropItems = false,
        AutoFarmChests = false,
        AutoFarmMirage = false,
        AutoFarmMirageGear = false,
        AutoFarmKitsuneItems = false,
        AutoFarmLeviathanHeart = false,
        AutoFarmSeaEvents = false,
        AutoFarmEliteBosses = false,
        AutoFarmRareMaterials = false,
        AutoFarmAllQuests = false,
        AutoFarmAllBosses = false,
        AutoFarmAllMobs = false,
        AutoFarmAllSeaBeasts = false
    },
    Events = {
        PredictMirageSpawn = false,
        PredictKitsuneSpawn = false,
        PredictRaidSpawn = false,
        AutoMirageIsland = false,
        AutoKitsune = false,
        AutoLeviathan = false,
        AutoSeaBeast = false,
        AutoPirateRaid = false,
        AutoSharkAttack = false,
        AutoDarkbeardEvent = false,
        AutoRipIndraEvent = false,
        AutoMirageGearCollect = false,
        AutoKitsuneShrine = false,
        MirageSpawnInterval = 3600,
        KitsuneSpawnInterval = 7200,
        RaidSpawnInterval = 1800
    },
    Keybinds = {
        ToggleUI = Enum.KeyCode.LeftControl,
        PanicKey = Enum.KeyCode.P,
        TeleportKey = Enum.KeyCode.T,
        AutoFarmKey = Enum.KeyCode.F,
        KillAuraKey = Enum.KeyCode.K,
        ESPToggleKey = Enum.KeyCode.E,
        NoClipKey = Enum.KeyCode.N
    }
}

-- Dados de Seas
local SeaData = {
    [1] = {
        Mobs = {"Bandit", "Monkey", "Gorilla", "Pirate", "Royal Soldier"},
        Bosses = {"Saber Expert", "The Saw", "Greybeard", "Vice Admiral"},
        NPCs = {"Quest Giver", "Blox Fruit Dealer", "Sick Man", "Weapon Dealer"},
        Islands = {"Windmill", "Marine Starter", "Jungle", "Pirate Village"},
        Materials = {"Wood", "Fish Tail", "Leather", "Scrap Metal"}
    },
    [2] = {
        Mobs = {"Fishman Warrior", "Fishman Commando", "Shark Hunter", "Tide Keeper Guard"},
        Bosses = {"Ice Admiral", "Tide Keeper", "Don Swan", "Diamond"},
        NPCs = {"Elite Hunter", "Bounty Hunter", "Fruit Seller", "Haki Master"},
        Islands = {"Fountain City", "Cafe", "Colosseum", "Green Zone"},
        Materials = {"Magma Ore", "Angel Wings", "Yeti Fur", "Fish Tail"}
    },
    [3] = {
        Mobs = {"Sea Soldier", "Leviathan Guard", "Ghost Shark", "Terror Shark"},
        Bosses = {"Hydra Boss", "Terrorshark", "Leviathan", "Dragon Boss"},
        NPCs = {"Mysterious Man", "Ancient Quest Giver", "Mirage Hunter", "Sea Master"},
        Islands = {"Haunted Castle", "Sea of Treats", "Tiki Outpost", "Floating Turtle"},
        Materials = {"Vampire Fang", "Dragon Scale", "Mystic Droplet", "Ectoplasm"}
    }
}

local ValuableFruits = {"Dragon", "Leopard", "Venom", "Dough", "Buddha", "Kitsune"}
local Gamepasses = {"2x Mastery", "2x Money", "Fast Boats", "Extra Fruits", "VIP"}
local FightingStyles = {"Dragon Talon", "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw"}

-- Aguarda o carregamento inicial do jogo
wait(5)

-- Funções Auxiliares
local function notify(title, content, duration)
    if Config.General.NotificationEnabled then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = content,
                Duration = duration or 5
            })
        end)
    end
end

local function sendWebhook(message)
    if Config.Misc.WebhookEnabled and Config.General.WebhookURL ~= "" then
        pcall(function()
            local data = {
                ["content"] = message
            }
            local encoded = HttpService:JSONEncode(data)
            HttpService:PostAsync(Config.General.WebhookURL, encoded, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

local function safeInvoke(remoteName, ...)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local remote = remotes and remotes:FindFirstChild(remoteName)
    if remote then
        return remote:InvokeServer(...)
    else
        notify("Hyper Neon Hub", "Erro: Remoto " .. remoteName .. " não encontrado!", 5)
        return nil
    end
end

local function checkCrowdedServer()
    return #Players:GetPlayers() > 15
end

local function checkStaffPresence()
    for _, player in pairs(Players:GetPlayers()) do
        if player:GetRankInGroup(game.CreatorId) > 1 then
            return true
        end
    end
    return false
end

local function checkProximity()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and LocalPlayer.Character then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < 50 then
                return true
            end
        end
    end
    return false
end

local function panicModeCheck()
    return Config.Misc.PanicMode
end

local function updatePerformance()
    if Config.General.PerformanceMode then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CastShadow = false
                    v.Material = Enum.Material.Plastic
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        end)
    end
end

local function mimicBehavior()
    if Config.General.StealthMode then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(math.random(0, 100), math.random(0, 100)))
        end)
    end
end

local function detectPlayerSea()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return 1
    end

    local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local seaRegions = {
        [1] = { Min = Vector3.new(-5000, 0, -5000), Max = Vector3.new(5000, 1000, 5000) },
        [2] = { Min = Vector3.new(5000, 0, -15000), Max = Vector3.new(15000, 1000, -5000) },
        [3] = { Min = Vector3.new(15000, 0, -25000), Max = Vector3.new(25000, 1000, -15000) }
    }

    for sea, region in pairs(seaRegions) do
        if playerPos.X >= region.Min.X and playerPos.X <= region.Max.X and
           playerPos.Z >= region.Min.Z and playerPos.Z <= region.Max.Z then
            return sea
        end
    end

    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc and npc.Parent then
            for sea, data in pairs(SeaData) do
                if table.find(data.NPCs, npc.Name) then
                    return sea
                end
            end
        end
    end

    local playerLevel = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
    if playerLevel >= 1500 then
        return 3
    elseif playerLevel >= 700 then
        return 2
    else
        return 1
    end
end

local function attackEnemy(enemy)
    if not enemy or not enemy:IsA("Model") then return end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            safeInvoke("CommF_", "SetAttack", enemy)
            humanoid:TakeDamage(10) -- Dano direto para evitar dependência de efeitos
        end
    end)
end

local function safeTeleport(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        notify("Hyper Neon Hub", "Erro: Personagem não encontrado para teleporte!", 5)
        return
    end
    if Config.Teleport.SafeTeleport then
        pcall(function()
            local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
        end)
    else
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
    end
end

local function positionAboveEnemy(enemy)
    if not enemy or not enemy:IsA("Model") then return end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local enemyHRP = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
    if not enemyHRP then return end

    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local enemyPos = enemyHRP.Position
            local abovePos = enemyPos + Vector3.new(0, Config.Farm.SafeDistance, 0)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(abovePos, enemyPos)
        end
    end)
end

local function updateNearbyEnemies()
    nearbyMobs = {}
    nearbyBosses = {}

    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= Config.Farm.MaxDistance then
                    if table.find(SeaData[currentSea].Mobs, enemy.Name) then
                        table.insert(nearbyMobs, enemy.Name .. " (" .. math.floor(distance) .. " studs)")
                    elseif table.find(SeaData[currentSea].Bosses, enemy.Name) then
                        table.insert(nearbyBosses, enemy.Name .. " (" .. math.floor(distance) .. " studs)")
                    end
                end
            end
        end
    end

    if Tabs.Farm then
        Tabs.Farm:UpdateDropdown("NearbyMobs", nearbyMobs)
        Tabs.Farm:UpdateDropdown("NearbyBosses", nearbyBosses)
    end
end

local function getMobQuest(mobName)
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        if npc and npc.Parent and npc:IsA("Model") then
            for _, questMob in pairs(SeaData[currentSea].Mobs) do
                if questMob == mobName then
                    pcall(function()
                        local npcPos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or npc.Position
                        if npcPos then
                            safeTeleport(CFrame.new(npcPos + Vector3.new(0, 5, 0)))
                            safeInvoke("CommF_", "StartQuest", npc.Name)
                        end
                    end)
                    break
                end
            end
        end
    end
end

-- Carregar Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Hyper Neon Hub | Blox Fruits",
    SubTitle = "by xAI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "wheat" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Quests = Window:AddTab({ Title = "Quests", Icon = "scroll" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "apple" }),
    Raids = Window:AddTab({ Title = "Raids", Icon = "zap" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart-2" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Automation = Window:AddTab({ Title = "Automation", Icon = "bot" }),
    Events = Window:AddTab({ Title = "Events", Icon = "calendar" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
}

Tabs.Main:AddParagraph({
    Title = "Bem-vindo ao Hyper Neon Hub!",
    Content = "Este script oferece diversas funcionalidades para o Blox Fruits. Use as abas para configurar as opções."
})

spawn(function()
    while true do
        currentSea = detectPlayerSea()
        wait(10)
    end
end)

spawn(function()
    while true do
        updateNearbyEnemies()
        wait(5)
    end
end)

Tabs.Farm:AddParagraph({
    Title = "Opções de Farm",
    Content = "Configure as opções de farm automático. Selecione mobs e bosses próximos para farmar."
})

Tabs.Farm:AddToggle("AutoFarmMobs", {
    Title = "Auto Farm Mobs",
    Default = Config.Farm.AutoFarmMobs,
    Callback = function(state)
        Config.Farm.AutoFarmMobs = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMobs and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Farm.SelectedMob == "" then wait(1) continue end
                    local mobName = Config.Farm.SelectedMob:match("^(.-) %(")
                    getMobQuest(mobName)
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and enemy.Name == mobName then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddDropdown("NearbyMobs", {
    Title = "Selecionar Mob Próximo",
    Values = nearbyMobs,
    Multi = false,
    Default = Config.Farm.SelectedMob,
    Callback = function(value)
        Config.Farm.SelectedMob = value
    end
})

Tabs.Farm:AddToggle("AutoFarmBoss", {
    Title = "Auto Farm Boss",
    Default = Config.Farm.AutoFarmBoss,
    Callback = function(state)
        Config.Farm.AutoFarmBoss = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmBoss and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Farm.SelectedBoss == "" then wait(1) continue end
                    local bossName = Config.Farm.SelectedBoss:match("^(.-) %(")
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and enemy.Name == bossName then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddDropdown("NearbyBosses", {
    Title = "Selecionar Boss Próximo",
    Values = nearbyBosses,
    Multi = false,
    Default = Config.Farm.SelectedBoss,
    Callback = function(value)
        Config.Farm.SelectedBoss = value
    end
})

Tabs.Farm:AddSlider("SafeDistance", {
    Title = "Distância Segura",
    Description = "Distância acima do inimigo",
    Min = 5,
    Max = 20,
    Default = Config.Farm.SafeDistance,
    Callback = function(value)
        Config.Farm.SafeDistance = value
    end
})

Tabs.Farm:AddSlider("MaxDistance", {
    Title = "Distância Máxima",
    Description = "Distância máxima para farmar",
    Min = 100,
    Max = 2000,
    Default = Config.Farm.MaxDistance,
    Callback = function(value)
        Config.Farm.MaxDistance = value
    end
})

Tabs.Farm:AddToggle("FarmAboveEnemy", {
    Title = "Farmar Acima do Inimigo",
    Default = Config.Farm.FarmAboveEnemy,
    Callback = function(state)
        Config.Farm.FarmAboveEnemy = state
    end
})

Tabs.Farm:AddToggle("AutoFarmMaterials", {
    Title = "Auto Farm Materiais",
    Default = Config.Farm.AutoFarmMaterials,
    Callback = function(state)
        Config.Farm.AutoFarmMaterials = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMaterials and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, material in pairs(workspace:GetDescendants()) do
                        if material.Name:find(Config.Farm.SelectedMaterial) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (material.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                pcall(function()
                                    safeTeleport(CFrame.new(material.Position + Vector3.new(0, 5, 0)))
                                    safeInvoke("CommF_", "CollectMaterial", material)
                                end)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    end
})

Tabs.Farm:AddDropdown("SelectedMaterial", {
    Title = "Selecionar Material",
    Values = SeaData[currentSea].Materials,
    Multi = false,
    Default = Config.Farm.SelectedMaterial,
    Callback = function(value)
        Config.Farm.SelectedMaterial = value
    end
})

Tabs.Farm:AddToggle("AutoFarmSeaBeasts", {
    Title = "Auto Farm Sea Beasts",
    Default = Config.Farm.AutoFarmSeaBeasts,
    Callback = function(state)
        Config.Farm.AutoFarmSeaBeasts = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmSeaBeasts and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, seaBeast in pairs(workspace.SeaBeasts:GetChildren()) do
                        if seaBeast:IsA("Model") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (seaBeast.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(seaBeast)
                                end
                                attackEnemy(seaBeast)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmMasteryMelee", {
    Title = "Auto Farm Mastery (Melee)",
    Default = Config.Farm.AutoFarmMasteryMelee,
    Callback = function(state)
        Config.Farm.AutoFarmMasteryMelee = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMasteryMelee and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                pcall(function()
                                    safeInvoke("CommF_", "IncreaseMastery", "Melee", enemy)
                                end)
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmMasterySword", {
    Title = "Auto Farm Mastery (Sword)",
    Default = Config.Farm.AutoFarmMasterySword,
    Callback = function(state)
        Config.Farm.AutoFarmMasterySword = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMasterySword and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                pcall(function()
                                    safeInvoke("CommF_", "IncreaseMastery", "Sword", enemy)
                                end)
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmMasteryGun", {
    Title = "Auto Farm Mastery (Gun)",
    Default = Config.Farm.AutoFarmMasteryGun,
    Callback = function(state)
        Config.Farm.AutoFarmMasteryGun = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMasteryGun and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                pcall(function()
                                    safeInvoke("CommF_", "IncreaseMastery", "Gun", enemy)
                                end)
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmMasteryFruit", {
    Title = "Auto Farm Mastery (Fruit)",
    Default = Config.Farm.AutoFarmMasteryFruit,
    Callback = function(state)
        Config.Farm.AutoFarmMasteryFruit = state
        if state then
            spawn(function()
                while Config.Farm.AutoFarmMasteryFruit and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                pcall(function()
                                    safeInvoke("CommF_", "IncreaseMastery", "Fruit", enemy)
                                end)
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Combat:AddParagraph({
    Title = "Opções de Combate",
    Content = "Configure as opções de combate. Apenas inimigos e frutas do seu Sea atual serão exibidos."
})

Tabs.Combat:AddToggle("ESPEnabled", {
    Title = "ESP de Frutas",
    Default = Config.Combat.ESPEnabled,
    Callback = function(state)
        Config.Combat.ESPEnabled = state
        if not state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild("ESP_HyperNeon") then
                    v.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Combat.ESPEnabled do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (v.Name:find("Fruit") or v.Name:find("DevilFruit")) and not v.Name:find("sail_boat2") and not v:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Combat.ESPDistance then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", v)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = v.Name
                                    textLabel.TextColor3 = Config.Combat.ESPColor
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Combat.ESPEnabled and v and v.Parent and LocalPlayer.Character do
                                            local distance = (v.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = v.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})


Tabs.Combat:AddColorPicker("ESPColor", {
    Title = "Cor do ESP",
    Default = Config.Combat.ESPColor,
    Callback = function(value)
        Config.Combat.ESPColor = value
    end
})

Tabs.Combat:AddSlider("ESPDistance", {
    Title = "Distância Máxima do ESP",
    Description = "Distância máxima para exibir o ESP",
    Min = 100,
    Max = 5000,
    Default = Config.Combat.ESPDistance,
    Callback = function(value)
        Config.Combat.ESPDistance = value
    end
})

Tabs.Combat:AddToggle("AimBotEnabled", {
    Title = "AimBot",
    Default = Config.Combat.AimBotEnabled,
    Callback = function(state)
        Config.Combat.AimBotEnabled = state
        if state then
            spawn(function()
                while Config.Combat.AimBotEnabled and LocalPlayer.Character do
                    local closestEnemy = nil
                    local closestDistance = Config.Combat.AimBotFOV
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 and LocalPlayer.Character and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if distance <= closestDistance then
                                closestDistance = distance
                                closestEnemy = enemy
                            end
                        end
                    end
                    if closestEnemy then
                        pcall(function()
                            local camera = workspace.CurrentCamera
                            camera.CFrame = CFrame.new(camera.CFrame.Position, closestEnemy.HumanoidRootPart.Position)
                        end)
                    end
                    wait(0.05)
                end
            end)
        end
    end
})

Tabs.Combat:AddSlider("AimBotFOV", {
    Title = "FOV do AimBot",
    Description = "Campo de visão do AimBot",
    Min = 50,
    Max = 500,
    Default = Config.Combat.AimBotFOV,
    Callback = function(value)
        Config.Combat.AimBotFOV = value
    end
})

Tabs.Combat:AddToggle("KillAura", {
    Title = "Kill Aura",
    Default = Config.Combat.KillAura,
    Callback = function(state)
        Config.Combat.KillAura = state
        if state then
            spawn(function()
                while Config.Combat.KillAura and LocalPlayer.Character do
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= 30 then
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})


Tabs.Combat:AddToggle("AutoSkill", {
    Title = "Auto Usar Habilidades",
    Default = Config.Combat.AutoSkill,
    Callback = function(state)
        Config.Combat.AutoSkill = state
        if state then
            spawn(function()
                while Config.Combat.AutoSkill and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UseSkill", "All")
                    end)
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Combat:AddToggle("AutoClick", {
    Title = "Auto Click",
    Default = Config.Combat.AutoClick,
    Callback = function(state)
        Config.Combat.AutoClick = state
        if state then
            spawn(function()
                while Config.Combat.AutoClick and LocalPlayer.Character do
                    pcall(function()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end)
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Combat:AddToggle("AutoGodMode", {
    Title = "Auto God Mode",
    Default = Config.Combat.AutoGodMode,
    Callback = function(state)
        Config.Combat.AutoGodMode = state
        if state then
            spawn(function()
                while Config.Combat.AutoGodMode and LocalPlayer.Character do
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.MaxHealth = math.huge
                            LocalPlayer.Character.Humanoid.Health = math.huge
                        end
                    end)
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Combat:AddToggle("InfiniteStamina", {
    Title = "Stamina Infinita",
    Default = Config.Combat.InfiniteStamina,
    Callback = function(state)
        Config.Combat.InfiniteStamina = state
        if state then
            spawn(function()
                while Config.Combat.InfiniteStamina and LocalPlayer.Character do
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.Stamina = math.huge
                        end
                    end)
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Combat:AddToggle("AutoDodge", {
    Title = "Auto Dodge",
    Default = Config.Combat.AutoDodge,
    Callback = function(state)
        Config.Combat.AutoDodge = state
        passo adicional para garantir que todas as funcionalidades sejam robustas e funcionem bem em diferentes dispositivos (mobile e PC).

---

### **Extensão do Script até 5.000 Linhas**

Para atingir 5.000 linhas, vou expandir o script adicionando mais funcionalidades, abas e opções. Vou incluir:

1. **Mais Opções de Teleporte**:
   - Teleporte para eventos específicos, NPCs, bosses e ilhas com base no Sea atual.
   - Opções de teleporte seguro com verificações adicionais.

2. **Funcionalidades Avançadas de Automação**:
   - Automação para eventos como Mirage Island, Kitsune Shrine e Leviathan.
   - Auto-farm de materiais raros e baús.

3. **Melhorias Visuais**:
   - ESP para todos os tipos de objetos (jogadores, NPCs, baús, frutas, etc.).
   - Opções de personalização de cores e distâncias.

4. **Sistema de Keybinds**:
   - Keybinds personalizáveis para ativar/desativar funções rapidamente.

5. **Configurações Avançadas**:
   - Opções para ajustar delays, temas da UI, e notificações.

---

#### **Aba Teleport (Continuação e Expansão)**

Vamos continuar de onde o script parou, na aba `Teleport`, e adicionar mais opções.

```lua
Tabs.Teleport:AddToggle("TeleportToPlayer", {
    Title = "Teleportar para Jogador",
    Default = Config.Teleport.TeleportToPlayer,
    Callback = function(state)
        Config.Teleport.TeleportToPlayer = state
        if state then
spawn(function()
                while Config.Teleport.TeleportToPlayer and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Teleport.SelectedPlayer == "" then wait(1) continue end
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Name == Config.Teleport.SelectedPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            pcall(function()
                                safeTeleport(player.Character.HumanoidRootPart.CFrame)
                                notify("Hyper Neon Hub", "Teleportado para " .. player.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddDropdown("SelectedPlayer", {
    Title = "Selecionar Jogador",
    Values = (function()
        local playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end)(),
    Multi = false,
    Default = Config.Teleport.SelectedPlayer,
    Callback = function(value)
        Config.Teleport.SelectedPlayer = value
    end
})

Tabs.Teleport:AddToggle("TeleportToIsland", {
    Title = "Teleportar para Ilha",
    Default = Config.Teleport.TeleportToIsland,
    Callback = function(state)
        Config.Teleport.TeleportToIsland = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToIsland and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Teleport.SelectedIsland == "" then wait(1) continue end
                    for _, island in pairs(workspace:Islands:GetChildren()) do
                        if island.Name == Config.Teleport.SelectedIsland then
                            pcall(function()
                                local islandPos = island:FindFirstChild("SpawnPoint") and island.SpawnPoint.Position or island.Position
                                safeTeleport(CFrame.new(islandPos + Vector3.new(0, 10, 0)))
                                notify("Hyper Neon Hub", "Teleportado para " .. island.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddDropdown("SelectedIsland", {
    Title = "Selecionar Ilha",
    Values = SeaData[currentSea].Islands,
    Multi = false,
    Default = Config.Teleport.SelectedIsland,
    Callback = function(value)
        Config.Teleport.SelectedIsland = value
    end
})

Tabs.Teleport:AddToggle("TeleportToBoss", {
    Title = "Teleportar para Boss",
    Default = Config.Teleport.TeleportToBoss,
    Callback = function(state)
        Config.Teleport.TeleportToBoss = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToBoss and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Farm.SelectedBoss == "" then wait(1) continue end
                    local bossName = Config.Farm.SelectedBoss:match("^(.-) %(")
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and enemy.Name == bossName then
                            pcall(function()
                                safeTeleport(enemy.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0))
                                notify("Hyper Neon Hub", "Teleportado para " .. enemy.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})



Tabs.Teleport:AddToggle("TeleportToNPC", {
    Title = "Teleportar para NPC",
    Default = Config.Teleport.TeleportToNPC,
    Callback = function(state)
        Config.Teleport.TeleportToNPC = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToNPC and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Quests.SelectedNPC == "" then wait(1) continue end
                    for _, npc in pairs(workspace.NPCs:GetChildren()) do
                        if npc:IsA("Model") and npc.Name == Config.Quests.SelectedNPC then
                            pcall(function()
                                local npcPos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or npc.Position
                                safeTeleport(CFrame.new(npcPos + Vector3.new(0, 10, 0)))
                                notify("Hyper Neon Hub", "Teleportado para " .. npc.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToFruit", {
    Title = "Teleportar para Fruta",
    Default = Config.Teleport.TeleportToFruit,
    Callback = function(state)
        Config.Teleport.TeleportToFruit = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToFruit and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, fruit in pairs(workspace:GetDescendants()) do
                        if (fruit.Name:find("Fruit") or fruit.Name:find("DevilFruit")) and not fruit.Name:find("sail_boat2") then
                            pcall(function()
                                safeTeleport(CFrame.new(fruit.Position + Vector3.new(0, 5, 0)))
                                notify("Hyper Neon Hub", "Teleportado para fruta: " .. fruit.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToChest", {
    Title = "Teleportar para Baú",
    Default = Config.Teleport.TeleportToChest,
    Callback = function(state)
        Config.Teleport.TeleportToChest = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToChest and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, chest in pairs(workspace:GetDescendants()) do
                        if chest.Name:find("Chest") then
                            pcall(function()
                                safeTeleport(CFrame.new(chest.Position + Vector3.new(0, 5, 0)))
                                notify("Hyper Neon Hub", "Teleportado para baú", 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToMaterial", {
    Title = "Teleportar para Material",
    Default = Config.Teleport.TeleportToMaterial,
    Callback = function(state)
        Config.Teleport.TeleportToMaterial = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToMaterial and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, material in pairs(workspace:GetDescendants()) do
                        if material.Name:find(Config.Farm.SelectedMaterial) then
                            pcall(function()
                                safeTeleport(CFrame.new(material.Position + Vector3.new(0, 5, 0)))
                                notify("Hyper Neon Hub", "Teleportado para material: " .. material.Name, 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToSafeZone", {
    Title = "Teleportar para Zona Segura",
    Default = Config.Teleport.TeleportToSafeZone,
    Callback = function(state)
        Config.Teleport.TeleportToSafeZone = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToSafeZone and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        local safeZones = {
                            [1] = CFrame.new(0, 100, 0), -- Sea 1 safe zone
                            [2] = CFrame.new(10000, 100, -10000), -- Sea 2 safe zone
                            [3] = CFrame.new(20000, 100, -20000) -- Sea 3 safe zone
                        }
                        safeTeleport(safeZones[currentSea])
                        notify("Hyper Neon Hub", "Teleportado para zona segura do Sea " .. currentSea, 5)
                    end)
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToEvent", {
    Title = "Teleportar para Evento",
    Default = Config.Teleport.TeleportToEvent,
    Callback = function(state)
        Config.Teleport.TeleportToEvent = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToEvent and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if Config.Events.AutoMirageIsland and workspace:FindFirstChild("MirageIsland") then
                        pcall(function()
                            safeTeleport(workspace.MirageIsland.Position + Vector3.new(0, 10, 0))
                            notify("Hyper Neon Hub", "Teleportado para Mirage Island", 5)
                        end)
                    elseif Config.Events.AutoKitsune and workspace:FindFirstChild("KitsuneShrine") then
                        pcall(function()
                            safeTeleport(workspace.KitsuneShrine.Position + Vector3.new(0, 10, 0))
                            notify("Hyper Neon Hub", "Teleportado para Kitsune Shrine", 5)
                        end)
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("TeleportToSeaBeast", {
    Title = "Teleportar para Sea Beast",
    Default = Config.Teleport.TeleportToSeaBeast,
    Callback = function(state)
        Config.Teleport.TeleportToSeaBeast = state
        if state then
            spawn(function()
                while Config.Teleport.TeleportToSeaBeast and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, seaBeast in pairs(workspace.SeaBeasts:GetChildren()) do
                        if seaBeast:IsA("Model") then
                            pcall(function()
                                safeTeleport(seaBeast.Position + Vector3.new(0, 10, 0))
                                notify("Hyper Neon Hub", "Teleportado para Sea Beast", 5)
                            end)
                            break
                        end
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("NoClip", {
    Title = "NoClip (Passar por Paredes)",
    Default = Config.Teleport.NoClip,
    Callback = function(state)
        Config.Teleport.NoClip = state
        if state then
            spawn(function()
                while Config.Teleport.NoClip and LocalPlayer.Character do
                    pcall(function()
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Teleport:AddToggle("SafeTeleport", {
    Title = "Teleport Seguro (Com Animação)",
    Default = Config.Teleport.SafeTeleport,
    Callback = function(state)
        Config.Teleport.SafeTeleport = state
    end
})

-- Aba Visuals
Tabs.Visuals:AddParagraph({
    Title = "Opções Visuais",
    Content = "Configure as opções visuais como ESP, remoção de efeitos e melhorias de desempenho."
})

Tabs.Visuals:AddToggle("RemoveFog", {
    Title = "Remover Nevoeiro",
    Default = Config.Visuals.RemoveFog,
    Callback = function(state)
        Config.Visuals.RemoveFog = state
        if state then
            pcall(function()
                Lighting.FogEnd = 100000
                Lighting.FogStart = 100000
            end)
        else
            pcall(function()
                Lighting.FogEnd = 500
                Lighting.FogStart = 0
            end)
        end
    end
})

Tabs.Visuals:AddToggle("FullBright", {
    Title = "Full Bright",
    Default = Config.Visuals.FullBright,
    Callback = function(state)
        Config.Visuals.FullBright = state
        if state then
            pcall(function()
                Lighting.Brightness = 1
                Lighting.GlobalShadows = false
                Lighting.ClockTime = 12
            end)
        else
            pcall(function()
                Lighting.Brightness = 0.5
                Lighting.GlobalShadows = true
                Lighting.ClockTime = 6
            end)
        end
    end
})

Tabs.Visuals:AddToggle("FPSBoost", {
    Title = "FPS Boost",
    Default = Config.Visuals.FPSBoost,
    Callback = function(state)
        Config.Visuals.FPSBoost = state
        if state then
            pcall(function()
                updatePerformance()
            end)
        end
    end
})

Tabs.Visuals:AddToggle("RemoveTextures", {
    Title = "Remover Texturas",
    Default = Config.Visuals.RemoveTextures,
    Callback = function(state)
        Config.Visuals.RemoveTextures = state
        if state then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.TextureID = ""
                    end
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ShowHitbox", {
    Title = "Mostrar Hitbox",
    Default = Config.Visuals.ShowHitbox,
    Callback = function(state)
        Config.Visuals.ShowHitbox = state
        if state then
            spawn(function()
                while Config.Visuals.ShowHitbox do
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and not enemy:FindFirstChild("HitboxVisual") then
                            pcall(function()
                                local hitbox = Instance.new("SelectionBox", enemy)
                                hitbox.Name = "HitboxVisual"
                                hitbox.Adornee = enemy
                                hitbox.LineThickness = 0.05
                                hitbox.Color3 = Color3.fromRGB(255, 0, 0)
                            end)
                        end
                    end
                    wait(1)
                end
            end)
        else
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HitboxVisual") then
                    enemy.HitboxVisual:Destroy()
                end
            end
        end
    end
})

Tabs.Visuals:AddToggle("ESPPlayers", {
    Title = "ESP Jogadores",
    Default = Config.Visuals.ESPPlayers,
    Callback = function(state)
        Config.Visuals.ESPPlayers = state
        if not state then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESP_HyperNeon") then
                    player.Character.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPPlayers do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character:FindFirstChild("ESP_HyperNeon") then
                            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", player.Character)
                                    billboard.Name = "ESP_HyperNeon"
                                                                        billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = player.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorPlayers
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPPlayers and player.Character and player.Character.Parent and LocalPlayer.Character do
                                            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = player.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPChests", {
    Title = "ESP Baús",
    Default = Config.Visuals.ESPChests,
    Callback = function(state)
        Config.Visuals.ESPChests = state
        if not state then
            for _, chest in pairs(workspace:GetDescendants()) do
                if chest:FindFirstChild("ESP_HyperNeon") then
                    chest.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPChests do
                    for _, chest in pairs(workspace:GetDescendants()) do
                        if chest.Name:find("Chest") and not chest:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (chest.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", chest)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = chest.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorChests
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPChests and chest and chest.Parent and LocalPlayer.Character do
                                            local distance = (chest.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = chest.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPFruits", {
    Title = "ESP Frutas",
    Default = Config.Visuals.ESPFruits,
    Callback = function(state)
        Config.Visuals.ESPFruits = state
        if not state then
            for _, fruit in pairs(workspace:GetDescendants()) do
                if fruit:FindFirstChild("ESP_HyperNeon") then
                    fruit.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPFruits do
                    for _, fruit in pairs(workspace:GetDescendants()) do
                        if (fruit.Name:find("Fruit") or fruit.Name:find("DevilFruit")) and not fruit.Name:find("sail_boat2") and not fruit:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (fruit.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", fruit)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = fruit.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorFruits
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPFruits and fruit and fruit.Parent and LocalPlayer.Character do
                                            local distance = (fruit.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = fruit.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPBosses", {
    Title = "ESP Bosses",
    Default = Config.Visuals.ESPBosses,
    Callback = function(state)
        Config.Visuals.ESPBosses = state
        if not state then
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("ESP_HyperNeon") then
                    enemy.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPBosses do
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and table.find(SeaData[currentSea].Bosses, enemy.Name) and not enemy:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", enemy)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = enemy.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorBosses
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPBosses and enemy and enemy.Parent and LocalPlayer.Character do
                                            local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = enemy.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPMobs", {
    Title = "ESP Mobs",
    Default = Config.Visuals.ESPMobs,
    Callback = function(state)
        Config.Visuals.ESPMobs = state
        if not state then
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("ESP_HyperNeon") then
                    enemy.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPMobs do
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and table.find(SeaData[currentSea].Mobs, enemy.Name) and not enemy:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", enemy)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = enemy.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorMobs
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPMobs and enemy and enemy.Parent and LocalPlayer.Character do
                                            local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = enemy.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPNPCs", {
    Title = "ESP NPCs",
    Default = Config.Visuals.ESPNPCs,
    Callback = function(state)
        Config.Visuals.ESPNPCs = state
        if not state then
            for _, npc in pairs(workspace.NPCs:GetChildren()) do
                if npc:FindFirstChild("ESP_HyperNeon") then
                    npc.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPNPCs do
                    for _, npc in pairs(workspace.NPCs:GetChildren()) do
                        if npc:IsA("Model") and table.find(SeaData[currentSea].NPCs, npc.Name) and not npc:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", npc)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = npc.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorNPCs
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPNPCs and npc and npc.Parent and LocalPlayer.Character do
                                            local distance = (npc.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = npc.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddToggle("ESPMaterials", {
    Title = "ESP Materiais",
    Default = Config.Visuals.ESPMaterials,
    Callback = function(state)
        Config.Visuals.ESPMaterials = state
        if not state then
            for _, material in pairs(workspace:GetDescendants()) do
                if material:FindFirstChild("ESP_HyperNeon") then
                    material.ESP_HyperNeon:Destroy()
                end
            end
        else
            spawn(function()
                while Config.Visuals.ESPMaterials do
                    for _, material in pairs(workspace:GetDescendants()) do
                        if table.find(SeaData[currentSea].Materials, material.Name) and not material:FindFirstChild("ESP_HyperNeon") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (material.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Visuals.ESPDistanceVisuals then
                                pcall(function()
                                    local billboard = Instance.new("BillboardGui", material)
                                    billboard.Name = "ESP_HyperNeon"
                                    billboard.Size = UDim2.new(0, 100, 0, 30)
                                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel", billboard)
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Text = material.Name
                                    textLabel.TextColor3 = Config.Visuals.ESPColorMaterials
                                    textLabel.TextScaled = true

                                    spawn(function()
                                        while Config.Visuals.ESPMaterials and material and material.Parent and LocalPlayer.Character do
                                            local distance = (material.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            textLabel.Text = material.Name .. " (" .. math.floor(distance) .. " studs)"
                                            wait(0.1)
                                        end
                                        if billboard then billboard:Destroy() end
                                    end)
                                end)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Visuals:AddColorPicker("ESPColorPlayers", {
    Title = "Cor ESP Jogadores",
    Default = Config.Visuals.ESPColorPlayers,
    Callback = function(value)
        Config.Visuals.ESPColorPlayers = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorChests", {
    Title = "Cor ESP Baús",
    Default = Config.Visuals.ESPColorChests,
    Callback = function(value)
        Config.Visuals.ESPColorChests = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorFruits", {
    Title = "Cor ESP Frutas",
    Default = Config.Visuals.ESPColorFruits,
    Callback = function(value)
        Config.Visuals.ESPColorFruits = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorBosses", {
    Title = "Cor ESP Bosses",
    Default = Config.Visuals.ESPColorBosses,
    Callback = function(value)
        Config.Visuals.ESPColorBosses = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorMobs", {
    Title = "Cor ESP Mobs",
    Default = Config.Visuals.ESPColorMobs,
    Callback = function(value)
        Config.Visuals.ESPColorMobs = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorNPCs", {
    Title = "Cor ESP NPCs",
    Default = Config.Visuals.ESPColorNPCs,
    Callback = function(value)
        Config.Visuals.ESPColorNPCs = value
    end
})

Tabs.Visuals:AddColorPicker("ESPColorMaterials", {
    Title = "Cor ESP Materiais",
    Default = Config.Visuals.ESPColorMaterials,
    Callback = function(value)
        Config.Visuals.ESPColorMaterials = value
    end
})

Tabs.Visuals:AddSlider("ESPDistanceVisuals", {
    Title = "Distância Máxima ESP",

Description = "Distância máxima para exibir o ESP",
    Min = 100,
    Max = 5000,
    Default = Config.Visuals.ESPDistanceVisuals,
    Callback = function(value)
        Config.Visuals.ESPDistanceVisuals = value
    end
})

-- Aba Stats
Tabs.Stats:AddParagraph({
    Title = "Opções de Stats",
    Content = "Configure opções para melhorar seus stats e habilidades automaticamente."
})

Tabs.Stats:AddToggle("AutoStats", {
    Title = "Auto Stats",
    Default = Config.Stats.AutoStats,
    Callback = function(state)
        Config.Stats.AutoStats = state
        if state then
            spawn(function()
                while Config.Stats.AutoStats and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "AddPoint", "Melee", 1)
                        safeInvoke("CommF_", "AddPoint", "Defense", 1)
                        safeInvoke("CommF_", "AddPoint", "Sword", 1)
                        safeInvoke("CommF_", "AddPoint", "Gun", 1)
                        safeInvoke("CommF_", "AddPoint", "Fruit", 1)
                    end)
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Default = Config.Stats.SpeedHack,
    Callback = function(state)
        Config.Stats.SpeedHack = state
        if state then
            spawn(function()
                while Config.Stats.SpeedHack and LocalPlayer.Character do
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.WalkSpeed = Config.Stats.SpeedValue
                        end
                    end)
                    wait(0.1)
                end
            end)
        else
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Velocidade padrão do Roblox
                end
            end)
        end
    end
})

Tabs.Stats:AddSlider("SpeedValue", {
    Title = "Valor de Velocidade",
    Description = "Ajuste a velocidade do personagem",
    Min = 16,
    Max = 200,
    Default = Config.Stats.SpeedValue,
    Callback = function(value)
        Config.Stats.SpeedValue = value
    end
})

Tabs.Stats:AddToggle("JumpPowerHack", {
    Title = "Jump Power Hack",
    Default = Config.Stats.JumpPowerHack,
    Callback = function(state)
        Config.Stats.JumpPowerHack = state
        if state then
            spawn(function()
                while Config.Stats.JumpPowerHack and LocalPlayer.Character do
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.JumpPower = Config.Stats.JumpPowerValue
                        end
                    end)
                    wait(0.1)
                end
            end)
        else
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = 50 -- JumpPower padrão do Roblox
                end
            end)
        end
    end
})

Tabs.Stats:AddSlider("JumpPowerValue", {
    Title = "Valor de Jump Power",
    Description = "Ajuste a força do pulo",
    Min = 50,
    Max = 200,
    Default = Config.Stats.JumpPowerValue,
    Callback = function(value)
        Config.Stats.JumpPowerValue = value
    end
})

Tabs.Stats:AddToggle("AutoHaki", {
    Title = "Auto Haki",
    Default = Config.Stats.AutoHaki,
    Callback = function(state)
        Config.Stats.AutoHaki = state
        if state then
            spawn(function()
                while Config.Stats.AutoHaki and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "ActivateHaki")
                    end)
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoDefense", {
    Title = "Auto Defense",
    Default = Config.Stats.AutoDefense,
    Callback = function(state)
        Config.Stats.AutoDefense = state
        if state then
            spawn(function()
                while Config.Stats.AutoDefense and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            if LocalPlayer.Character.Humanoid.Health < Config.Stats.DefenseThreshold then
                                safeInvoke("CommF_", "AddPoint", "Defense", 10)
                            end
                        end
                    end)
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Stats:AddSlider("DefenseThreshold", {
    Title = "Limite de Defesa",
    Description = "Vida mínima para aumentar defesa",
    Min = 10,
    Max = 100,
    Default = Config.Stats.DefenseThreshold,
    Callback = function(value)
        Config.Stats.DefenseThreshold = value
    end
})

Tabs.Stats:AddToggle("AutoMastery", {
    Title = "Auto Mastery",
    Default = Config.Stats.AutoMastery,
    Callback = function(state)
        Config.Stats.AutoMastery = state
        if state then
            spawn(function()
                while Config.Stats.AutoMastery and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy:IsA("Model") and (table.find(SeaData[currentSea].Mobs, enemy.Name) or table.find(SeaData[currentSea].Bosses, enemy.Name)) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                pcall(function()
                                    safeInvoke("CommF_", "IncreaseMastery", Config.Stats.MasteryType, enemy)
                                end)
                                attackEnemy(enemy)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Stats:AddDropdown("MasteryType", {
    Title = "Tipo de Mastery",
    Values = {"Melee", "Sword", "Gun", "Fruit"},
    Multi = false,
    Default = Config.Stats.MasteryType,
    Callback = function(value)
        Config.Stats.MasteryType = value
    end
})

Tabs.Stats:AddToggle("AutoUpgradeBusoshoku", {
    Title = "Auto Upgrade Busoshoku",
    Default = Config.Stats.AutoUpgradeBusoshoku,
    Callback = function(state)
        Config.Stats.AutoUpgradeBusoshoku = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeBusoshoku and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeHaki", "Busoshoku")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoUpgradeKen", {
    Title = "Auto Upgrade Ken",
    Default = Config.Stats.AutoUpgradeKen,
    Callback = function(state)
        Config.Stats.AutoUpgradeKen = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeKen and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeHaki", "Ken")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoUpgradeGeppo", {
    Title = "Auto Upgrade Geppo",
    Default = Config.Stats.AutoUpgradeGeppo,
    Callback = function(state)
        Config.Stats.AutoUpgradeGeppo = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeGeppo and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeAbility", "Geppo")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoUpgradeSoru", {
    Title = "Auto Upgrade Soru",
    Default = Config.Stats.AutoUpgradeSoru,
    Callback = function(state)
        Config.Stats.AutoUpgradeSoru = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeSoru and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeAbility", "Soru")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoUpgradeTekkai", {
    Title = "Auto Upgrade Tekkai",
    Default = Config.Stats.AutoUpgradeTekkai,
    Callback = function(state)
        Config.Stats.AutoUpgradeTekkai = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeTekkai and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeAbility", "Tekkai")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Stats:AddToggle("AutoUpgradeShigan", {
    Title = "Auto Upgrade Shigan",
    Default = Config.Stats.AutoUpgradeShigan,
    Callback = function(state)
        Config.Stats.AutoUpgradeShigan = state
        if state then
            spawn(function()
                while Config.Stats.AutoUpgradeShigan and LocalPlayer.Character do
                    pcall(function()
                        safeInvoke("CommF_", "UpgradeAbility", "Shigan")
                    end)
                    wait(10)
                end
            end)
        end
    end
})

-- Aba Shop
Tabs.Shop:AddParagraph({
    Title = "Opções de Loja",
    Content = "Configure opções para comprar itens, frutas e gamepasses automaticamente."
})

Tabs.Shop:AddToggle("AutoBuyWeapons", {
    Title = "Auto Comprar Armas",
    Default = Config.Shop.AutoBuyWeapons,
    Callback = function(state)
        Config.Shop.AutoBuyWeapons = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyWeapons and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyItem", "Weapon", Config.Shop.SelectedWeapon)
                        notify("Hyper Neon Hub", "Tentou comprar arma: " .. Config.Shop.SelectedWeapon, 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddDropdown("SelectedWeapon", {
    Title = "Selecionar Arma",
    Values = {"Saber", "Katana", "Cutlass", "Pole", "Dual Katana"},
    Multi = false,
    Default = Config.Shop.SelectedWeapon,
    Callback = function(value)
        Config.Shop.SelectedWeapon = value
    end
})

Tabs.Shop:AddToggle("AutoBuyAccessories", {
    Title = "Auto Comprar Acessórios",
    Default = Config.Shop.AutoBuyAccessories,
    Callback = function(state)
        Config.Shop.AutoBuyAccessories = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyAccessories and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyItem", "Accessory", "Tomoe Ring")
                        notify("Hyper Neon Hub", "Tentou comprar acessório: Tomoe Ring", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyFruits", {
    Title = "Auto Comprar Frutas",
    Default = Config.Shop.AutoBuyFruits,
    Callback = function(state)
        Config.Shop.AutoBuyFruits = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyFruits and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyItem", "Fruit", "Random")
                        notify("Hyper Neon Hub", "Tentou comprar uma fruta aleatória", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})


Tabs.Shop:AddToggle("AutoBuyHakiColors", {
    Title = "Auto Comprar Cores Haki",
    Default = Config.Shop.AutoBuyHakiColors,
    Callback = function(state)
        Config.Shop.AutoBuyHakiColors = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyHakiColors and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyItem", "HakiColor", "Random")
                        notify("Hyper Neon Hub", "Tentou comprar uma cor de Haki aleatória", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyRandom", {
    Title = "Auto Comprar Item Aleatório",
    Default = Config.Shop.AutoBuyRandom,
    Callback = function(state)
        Config.Shop.AutoBuyRandom = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyRandom and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyRandomItem")
                        notify("Hyper Neon Hub", "Tentou comprar um item aleatório", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoRollBones", {
    Title = "Auto Rolar Ossos",
    Default = Config.Shop.AutoRollBones,
    Callback = function(state)
        Config.Shop.AutoRollBones = state
        if state then
            spawn(function()
                while Config.Shop.AutoRollBones and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "RollBones")
                        notify("Hyper Neon Hub", "Tentou rolar ossos", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyGamepasses", {
    Title = "Auto Comprar Gamepasses",
    Default = Config.Shop.AutoBuyGamepasses,
    Callback = function(state)
        Config.Shop.AutoBuyGamepasses = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyGamepasses and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        MarketplaceService:PromptGamePassPurchase(LocalPlayer, Config.Shop.SelectedGamepass)
                        notify("Hyper Neon Hub", "Tentou comprar gamepass: " .. Config.Shop.SelectedGamepass, 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddDropdown("SelectedGamepass", {
    Title = "Selecionar Gamepass",
    Values = Gamepasses,
    Multi = false,
    Default = Config.Shop.SelectedGamepass,
    Callback = function(value)
        Config.Shop.SelectedGamepass = value
    end
})

Tabs.Shop:AddToggle("AutoBuyFragments", {
    Title = "Auto Comprar Fragments",
    Default = Config.Shop.AutoBuyFragments,
    Callback = function(state)
        Config.Shop.AutoBuyFragments = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyFragments and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyFragments", 5000)
                        notify("Hyper Neon Hub", "Tentou comprar 5000 fragments", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyBeli", {
    Title = "Auto Comprar Beli",
    Default = Config.Shop.AutoBuyBeli,
    Callback = function(state)
        Config.Shop.AutoBuyBeli = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyBeli and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyBeli", 1000000)
                        notify("Hyper Neon Hub", "Tentou comprar 1M de Beli", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyLegendarySword", {
    Title = "Auto Comprar Espada Lendária",
    Default = Config.Shop.AutoBuyLegendarySword,
    Callback = function(state)
        Config.Shop.AutoBuyLegendarySword = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyLegendarySword and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyLegendarySword")
                        notify("Hyper Neon Hub", "Tentou comprar uma espada lendária", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyFightingStyle", {
    Title = "Auto Comprar Estilo de Luta",
    Default = Config.Shop.AutoBuyFightingStyle,
    Callback = function(state)
        Config.Shop.AutoBuyFightingStyle = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyFightingStyle and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyFightingStyle", Config.Shop.SelectedFightingStyle)
                        notify("Hyper Neon Hub", "Tentou comprar estilo de luta: " .. Config.Shop.SelectedFightingStyle, 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddDropdown("SelectedFightingStyle", {
    Title = "Selecionar Estilo de Luta",
    Values = FightingStyles,
    Multi = false,
    Default = Config.Shop.SelectedFightingStyle,
    Callback = function(value)
        Config.Shop.SelectedFightingStyle = value
    end
})

Tabs.Shop:AddToggle("AutoBuyRareItems", {
    Title = "Auto Comprar Itens Raros",
    Default = Config.Shop.AutoBuyRareItems,
    Callback = function(state)
        Config.Shop.AutoBuyRareItems = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyRareItems and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyRareItem")
                        notify("Hyper Neon Hub", "Tentou comprar um item raro", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Shop:AddToggle("AutoBuyBoats", {
    Title = "Auto Comprar Barcos",
    Default = Config.Shop.AutoBuyBoats,
    Callback = function(state)
        Config.Shop.AutoBuyBoats = state
        if state then
            spawn(function()
                while Config.Shop.AutoBuyBoats and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "BuyBoat", "Guardian")
                        notify("Hyper Neon Hub", "Tentou comprar um barco: Guardian", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Misc:AddParagraph({
    Title = "Opções Diversas",
    Content = "Configure opções gerais, como server hop, anti-AFK e mais."
})

Tabs.Misc:AddToggle("ServerHop", {
    Title = "Server Hop",
    Default = Config.Misc.ServerHop,
    Callback = function(state)
        Config.Misc.ServerHop = state
        if state then
            spawn(function()
                while Config.Misc.ServerHop do
                    if tick() - lastServerHop >= Config.Misc.ServerHopInterval then
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                            lastServerHop = tick()
                        end)
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Misc:AddSlider("ServerHopInterval", {
    Title = "Intervalo de Server Hop",
    Description = "Tempo em segundos entre server hops",
    Min = 60,
    Max = 600,
    Default = Config.Misc.ServerHopInterval,
    Callback = function(value)
        Config.Misc.ServerHopInterval = value
    end
})

Tabs.Misc:AddToggle("SafeMode", {
    Title = "Modo Seguro",
    Default = Config.Misc.SafeMode,
    Callback = function(state)
        Config.Misc.SafeMode = state
    end
})

Tabs.Misc:AddToggle("PanicMode", {
    Title = "Modo Pânico",
    Default = Config.Misc.PanicMode,
    Callback = function(state)
        Config.Misc.PanicMode = state
        if state then
            notify("Hyper Neon Hub", "Modo Pânico Ativado! Todas as automações pausadas.", 5)
        else
            notify("Hyper Neon Hub", "Modo Pânico Desativado!", 5)
        end
    end
})

Tabs.Misc:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = Config.Misc.AntiAFK,
    Callback = function(state)
        Config.Misc.AntiAFK = state
        if state then
            spawn(function()
                while Config.Misc.AntiAFK do
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(math.random(0, 100), math.random(0, 100)))
                    end)
                    wait(60)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("AutoRejoin", {
    Title = "Auto Rejoin",
    Default = Config.Misc.AutoRejoin,
    Callback = function(state)
        Config.Misc.AutoRejoin = state
        if state then
            spawn(function()
                while Config.Misc.AutoRejoin do
                    if not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        end)
                    end
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("AutoDisconnect", {
    Title = "Auto Desconectar",
    Default = Config.Misc.AutoDisconnect,
    Callback = function(state)
        Config.Misc.AutoDisconnect = state
        if state then
            spawn(function()
                while Config.Misc.AutoDisconnect do
                    if LocalPlayer.Character and LocalPlayer.Character.Humanoid.Health <= Config.Misc.DisconnectThreshold then
                        pcall(function()
                            game:Shutdown()
                        end)
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Misc:AddSlider("DisconnectThreshold", {
    Title = "Limite de Desconexão",
    Description = "Vida mínima para desconectar",
    Min = 0,
    Max = 100,
    Default = Config.Misc.DisconnectThreshold,
    Callback = function(value)
        Config.Misc.DisconnectThreshold = value
    end
})

Tabs.Misc:AddToggle("AutoRedeemCodes", {
    Title = "Auto Resgatar Códigos",
    Default = Config.Misc.AutoRedeemCodes,
    Callback = function(state)
        Config.Misc.AutoRedeemCodes = state
        if state then
            spawn(function()
                while Config.Misc.AutoRedeemCodes do
                    pcall(function()
                        safeInvoke("CommF_", "RedeemCode", "SUB2GAMERROBOT_EXP1")
                        safeInvoke("CommF_", "RedeemCode", "SUB2GAMERROBOT_RESET1")
                        safeInvoke("CommF_", "RedeemCode", "SUB2UNCLEKIZARU")
                        notify("Hyper Neon Hub", "Tentou resgatar códigos promocionais", 5)
                    end)
                    wait(300)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("WebhookEnabled", {
    Title = "Habilitar Webhook",
    Default = Config.Misc.WebhookEnabled,
    Callback = function(state)
        Config.Misc.WebhookEnabled = state
    end
})

Tabs.Misc:AddInput("WebhookURL", {
    Title = "URL do Webhook",
    Default = Config.General.WebhookURL,
    Placeholder = "Insira a URL do Webhook",
    Callback = function(value)
        Config.General.WebhookURL = value
    end
})

Tabs.Misc:AddToggle("AutoJoinCrew", {
    Title = "Auto Entrar em Crew",
    Default = Config.Misc.AutoJoinCrew,
    Callback = function(state)
        Config.Misc.AutoJoinCrew = state
        if state then
            spawn(function()
                while Config.Misc.AutoJoinCrew do
                    pcall(function()
                        safeInvoke("CommF_", "JoinCrew", Config.Misc.CrewID)
                        notify("Hyper Neon Hub", "Tentou entrar na crew: " .. Config.Misc.CrewID, 5)
                    end)
                    wait(60)
                end
            end)
        end
    end
})

Tabs.Misc:AddInput("CrewID", {
    Title = "ID da Crew",
    Default = Config.Misc.CrewID,
    Placeholder = "Insira o ID da Crew",
    Callback = function(value)
        Config.Misc.CrewID = value
    end
})

Tabs.Misc:AddToggle("AutoDonate", {
    Title = "Auto Doar",
    Default = Config.Misc.AutoDonate,
    Callback = function(state)
        Config.Misc.AutoDonate = state
        if state then
            spawn(function()
                while Config.Misc.AutoDonate do
                    pcall(function()
                        safeInvoke("CommF_", "Donate", Config.Misc.DonateAmount)
                        notify("Hyper Neon Hub", "Tentou doar " .. Config.Misc.DonateAmount .. " Beli", 5)
                    end)
                    wait(300)
                end
            end)
        end
    end
})

Tabs.Misc:AddSlider("DonateAmount", {
    Title = "Quantidade de Doação",
    Description = "Quantidade de Beli para doar",
    Min = 100,
    Max = 10000,
    Default = Config.Misc.DonateAmount,
    Callback = function(value)
        Config.Misc.DonateAmount = value
    end
})

Tabs.Misc:AddToggle("AutoKickSuspiciousPlayers", {
    Title = "Auto Kickar Jogadores Suspeitos",
    Default = Config.Misc.AutoKickSuspiciousPlayers,
    Callback = function(state)
        Config.Misc.AutoKickSuspiciousPlayers = state
        if state then
            spawn(function()
                while Config.Misc.AutoKickSuspiciousPlayers do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player:GetRankInGroup(game.CreatorId) > 1 then
                            pcall(function()
                                safeInvoke("CommF_", "KickPlayer", player)
                                notify("Hyper Neon Hub", "Tentou kickar jogador suspeito: " .. player.Name, 5)
                            end)
                        end
                    end
                    wait(60)
                end
            end)
        end
    end
})


Tabs.Misc:AddToggle("AutoReportPlayers", {
    Title = "Auto Reportar Jogadores",
    Default = Config.Misc.AutoReportPlayers,
    Callback = function(state)
        Config.Misc.AutoReportPlayers = state
        if state then
            spawn(function()
                while Config.Misc.AutoReportPlayers do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and checkProximity() then
                            pcall(function()
                                safeInvoke("CommF_", "ReportPlayer", player, "Suspeito")
                                notify("Hyper Neon Hub", "Reportou jogador: " .. player.Name, 5)
                            end)
                        end
                    end
                    wait(300)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("AutoFakeDisconnect", {
    Title = "Auto Fake Disconnect",
    Default = Config.Misc.AutoFakeDisconnect,
    Callback = function(state)
        Config.Misc.AutoFakeDisconnect = state
        if state then
            spawn(function()
                while Config.Misc.AutoFakeDisconnect do
                    if checkProximity() then
                        pcall(function()
                            safeInvoke("CommF_", "FakeDisconnect")
                            notify("Hyper Neon Hub", "Simulou desconexão", 5)
                        end)
                    end
                    wait(60)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("AutoSpoofStats", {
    Title = "Auto Spoof Stats",
    Default = Config.Misc.AutoSpoofStats,
    Callback = function(state)
        Config.Misc.AutoSpoofStats = state
        if state then
            spawn(function()
                while Config.Misc.AutoSpoofStats do
                    pcall(function()
                        LocalPlayer.Data.Level.Value = Config.General.FakeLevel
                        LocalPlayer.Data.Beli.Value = Config.General.FakeBeli
                        LocalPlayer.Data.Fragments.Value = Config.General.FakeFragments
                        notify("Hyper Neon Hub", "Stats falsificados", 5)
                    end)
                    wait(60)
                end
            end)
        end
    end
})

Tabs.Misc:AddToggle("AutoHideIdentity", {
    Title = "Auto Esconder Identidade",
    Default = Config.Misc.AutoHideIdentity,
    Callback = function(state)
        Config.Misc.AutoHideIdentity = state
        if state then
            spawn(function()
                while Config.Misc.AutoHideIdentity do
                    pcall(function()
                        LocalPlayer.DisplayName = "Anonymous"
                        notify("Hyper Neon Hub", "Identidade escondida", 5)
                    end)
                    wait(60)
                end
            end)
        end
    end
})

-- Aba Automation
Tabs.Automation:AddParagraph({
    Title = "Opções de Automação",
    Content = "Configure automações avançadas para farm, frutas, raids e mais."
})

Tabs.Automation:AddToggle("AutoEquipBestWeapon", {
    Title = "Auto Equipar Melhor Arma",
    Default = Config.Automation.AutoEquipBestWeapon,
    Callback = function(state)
        Config.Automation.AutoEquipBestWeapon = state
        if state then
            spawn(function()
                while Config.Automation.AutoEquipBestWeapon and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "EquipBestWeapon")
                        notify("Hyper Neon Hub", "Equipou a melhor arma", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoEquipBestFruit", {
    Title = "Auto Equipar Melhor Fruta",
    Default = Config.Automation.AutoEquipBestFruit,
    Callback = function(state)
        Config.Automation.AutoEquipBestFruit = state
        if state then
            spawn(function()
                while Config.Automation.AutoEquipBestFruit and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "EquipBestFruit")
                        notify("Hyper Neon Hub", "Equipou a melhor fruta", 5)
                    end)
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoTradeFruits", {
    Title = "Auto Trocar Frutas",
    Default = Config.Automation.AutoTradeFruits,
    Callback = function(state)
        Config.Automation.AutoTradeFruits = state
        if state then
            spawn(function()
                while Config.Automation.AutoTradeFruits and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "TradeFruit", "Random")
                        notify("Hyper Neon Hub", "Tentou trocar uma fruta", 5)
                    end)
                    wait(30)
                end
            end)
        end
    end
})


Tabs.Automation:AddToggle("AutoDropItems", {
    Title = "Auto Dropar Itens",
    Default = Config.Automation.AutoDropItems,
    Callback = function(state)
        Config.Automation.AutoDropItems = state
        if state then
            spawn(function()
                while Config.Automation.AutoDropItems and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "DropItem", "Random")
                        notify("Hyper Neon Hub", "Dropou um item", 5)
                    end)
                    wait(30)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmChests", {
    Title = "Auto Farm Baús",
    Default = Config.Automation.AutoFarmChests,
    Callback = function(state)
        Config.Automation.AutoFarmChests = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmChests and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, chest in pairs(workspace:GetDescendants()) do
                        if chest.Name:find("Chest") then
                            pcall(function()
                                safeTeleport(CFrame.new(chest.Position + Vector3.new(0, 5, 0)))
                                safeInvoke("CommF_", "CollectChest", chest)
                                notify("Hyper Neon Hub", "Coletou um baú", 5)
                            end)
                            wait(randomDelay)
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmMirage", {
    Title = "Auto Farm Mirage Island",
    Default = Config.Automation.AutoFarmMirage,
    Callback = function(state)
        Config.Automation.AutoFarmMirage = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmMirage and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if workspace:FindFirstChild("MirageIsland") then
                        pcall(function()
                            safeTeleport(workspace.MirageIsland.Position + Vector3.new(0, 10, 0))
                            for _, item in pairs(workspace.MirageIsland:GetDescendants()) do
                                if item.Name:find("Gear") then
                                    safeInvoke("CommF_", "CollectMirageGear", item)
                                    notify("Hyper Neon Hub", "Coletou um gear da Mirage Island", 5)
                                end
                            end
                        end)
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmMirageGear", {
    Title = "Auto Farm Mirage Gear",
    Default = Config.Automation.AutoFarmMirageGear,
    Callback = function(state)
        Config.Automation.AutoFarmMirageGear = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmMirageGear and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if workspace:FindFirstChild("MirageIsland") then
                        pcall(function()
                            for _, gear in pairs(workspace.MirageIsland:GetDescendants()) do
                                if gear.Name:find("Gear") then
                                    safeTeleport(CFrame.new(gear.Position + Vector3.new(0, 5, 0)))
                                    safeInvoke("CommF_", "CollectMirageGear", gear)
                                    notify("Hyper Neon Hub", "Coletou um gear da Mirage Island", 5)
                                end
                            end
                        end)
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmKitsuneItems", {
    Title = "Auto Farm Kitsune Items",
    Default = Config.Automation.AutoFarmKitsuneItems,
    Callback = function(state)
        Config.Automation.AutoFarmKitsuneItems = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmKitsuneItems and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if workspace:FindFirstChild("KitsuneShrine") then
                        pcall(function()
                            safeTeleport(workspace.KitsuneShrine.Position + Vector3.new(0, 10, 0))
                            for _, item in pairs(workspace.KitsuneShrine:GetDescendants()) do
                                if item.Name:find("Kitsune") then
                                    safeInvoke("CommF_", "CollectKitsuneItem", item)
                                    notify("Hyper Neon Hub", "Coletou um item do Kitsune Shrine", 5)
                                end
                            end
                        end)
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmLeviathanHeart", {
    Title = "Auto Farm Leviathan Heart",
    Default = Config.Automation.AutoFarmLeviathanHeart,
    Callback = function(state)
        Config.Automation.AutoFarmLeviathanHeart = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmLeviathanHeart and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, leviathan in pairs(workspace.SeaBeasts:GetChildren()) do
                        if leviathan.Name:find("Leviathan") then
                            pcall(function()
                                safeTeleport(leviathan.Position + Vector3.new(0, 10, 0))
                                attackEnemy(leviathan)
                                safeInvoke("CommF_", "CollectLeviathanHeart", leviathan)
                                notify("Hyper Neon Hub", "Tentou coletar Leviathan Heart", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmSeaEvents", {
    Title = "Auto Farm Sea Events",
    Default = Config.Automation.AutoFarmSeaEvents,
    Callback = function(state)
        Config.Automation.AutoFarmSeaEvents = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmSeaEvents and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, event in pairs(workspace:GetChildren()) do
                        if event.Name:find("SeaEvent") then
                            pcall(function()
                                safeTeleport(event.Position + Vector3.new(0, 10, 0))
                                safeInvoke("CommF_", "ParticipateSeaEvent", event)
                                notify("Hyper Neon Hub", "Participou de um Sea Event", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmEliteBosses", {
    Title = "Auto Farm Elite Bosses",
    Default = Config.Automation.AutoFarmEliteBosses,
    Callback = function(state)
        Config.Automation.AutoFarmEliteBosses = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmEliteBosses and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if enemy.Name:find("Elite") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                attackEnemy(enemy)
                                notify("Hyper Neon Hub", "Farmando Elite Boss: " .. enemy.Name, 5)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmRareMaterials", {
    Title = "Auto Farm Materiais Raros",
    Default = Config.Automation.AutoFarmRareMaterials,
    Callback = function(state)
        Config.Automation.AutoFarmRareMaterials = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmRareMaterials and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, material in pairs(workspace:GetDescendants()) do
                        if material.Name:find("Rare") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (material.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                pcall(function()
                                    safeTeleport(CFrame.new(material.Position + Vector3.new(0, 5, 0)))
                                    safeInvoke("CommF_", "CollectMaterial", material)
                                    notify("Hyper Neon Hub", "Coletou material raro: " .. material.Name, 5)
                                end)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.5)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmAllQuests", {
    Title = "Auto Farm Todas as Quests",
    Default = Config.Automation.AutoFarmAllQuests,
    Callback = function(state)
        Config.Automation.AutoFarmAllQuests = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmAllQuests and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, npc in pairs(workspace.NPCs:GetChildren()) do
                        if table.find(SeaData[currentSea].NPCs, npc.Name) then
                            pcall(function()
                                local npcPos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or npc.Position
                                safeTeleport(CFrame.new(npcPos + Vector3.new(0, 5, 0)))
                                safeInvoke("CommF_", "StartQuest", npc.Name)
                                notify("Hyper Neon Hub", "Iniciou quest com: " .. npc.Name, 5)
                            end)
                            wait(2)
                        end
                    end
                    wait(10)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmAllBosses", {
    Title = "Auto Farm Todos os Bosses",
    Default = Config.Automation.AutoFarmAllBosses,
    Callback = function(state)
        Config.Automation.AutoFarmAllBosses = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmAllBosses and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if table.find(SeaData[currentSea].Bosses, enemy.Name) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                attackEnemy(enemy)
                                notify("Hyper Neon Hub", "Farmando boss: " .. enemy.Name, 5)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmAllMobs", {
    Title = "Auto Farm Todos os Mobs",
    Default = Config.Automation.AutoFarmAllMobs,
    Callback = function(state)
        Config.Automation.AutoFarmAllMobs = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmAllMobs and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                        if table.find(SeaData[currentSea].Mobs, enemy.Name) then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(enemy)
                                end
                                attackEnemy(enemy)
                                notify("Hyper Neon Hub", "Farmando mob: " .. enemy.Name, 5)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

Tabs.Automation:AddToggle("AutoFarmAllSeaBeasts", {
    Title = "Auto Farm Todos os Sea Beasts",
    Default = Config.Automation.AutoFarmAllSeaBeasts,
    Callback = function(state)
        Config.Automation.AutoFarmAllSeaBeasts = state
        if state then
            spawn(function()
                while Config.Automation.AutoFarmAllSeaBeasts and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, seaBeast in pairs(workspace.SeaBeasts:GetChildren()) do
                        if seaBeast:IsA("Model") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (seaBeast.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance <= Config.Farm.MaxDistance then
                                if Config.Farm.FarmAboveEnemy then
                                    positionAboveEnemy(seaBeast)
                                end
                                attackEnemy(seaBeast)
                                notify("Hyper Neon Hub", "Farmando Sea Beast", 5)
                                wait(randomDelay)
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

-- Aba Events
Tabs.Events:AddParagraph({
    Title = "Opções de Eventos",
    Content = "Configure automações para eventos como Mirage Island, Kitsune, Leviathan e mais."
})

Tabs.Events:AddToggle("PredictMirageSpawn", {
    Title = "Prever Spawn da Mirage Island",
    Default = Config.Events.PredictMirageSpawn,
    Callback = function(state)
        Config.Events.PredictMirageSpawn = state
        if state then
            spawn(function()
                while Config.Events.PredictMirageSpawn do
                    mirageSpawnTimer = mirageSpawnTimer + 1
                    if mirageSpawnTimer >= Config.Events.MirageSpawnInterval then
                        notify("Hyper Neon Hub", "Mirage Island pode spawnar em breve!", 5)
                        mirageSpawnTimer = 0
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Events:AddSlider("KitsuneSpawnInterval", {
    Title = "Intervalo de Spawn Kitsune",
    Description = "Tempo em segundos para prever spawn",
    Min = 3600,
    Max = 10800,
    Default = Config.Events.KitsuneSpawnInterval,
    Callback = function(value)
        Config.Events.KitsuneSpawnInterval = value
    end
})

Tabs.Events:AddToggle("PredictRaidSpawn", {
    Title = "Prever Spawn de Raid",
    Default = Config.Events.PredictRaidSpawn,
    Callback = function(state)
        Config.Events.PredictRaidSpawn = state
        if state then
            spawn(function()
                while Config.Events.PredictRaidSpawn do
                    raidSpawnTimer = raidSpawnTimer + 1
                    if raidSpawnTimer >= Config.Events.RaidSpawnInterval then
                        notify("Hyper Neon Hub", "Raid pode spawnar em breve!", 5)
                        raidSpawnTimer = 0
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Events:AddSlider("RaidSpawnInterval", {
    Title = "Intervalo de Spawn Raid",
    Description = "Tempo em segundos para prever spawn",
    Min = 900,
    Max = 3600,
    Default = Config.Events.RaidSpawnInterval,
    Callback = function(value)
        Config.Events.RaidSpawnInterval = value
    end
})

Tabs.Events:AddToggle("AutoMirageIsland", {
    Title = "Auto Mirage Island",
    Default = Config.Events.AutoMirageIsland,
    Callback = function(state)
        Config.Events.AutoMirageIsland = state
        if state then
            spawn(function()
                while Config.Events.AutoMirageIsland and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if workspace:FindFirstChild("MirageIsland") then
                        pcall(function()
                            safeTeleport(workspace.MirageIsland.Position + Vector3.new(0, 10, 0))
                            notify("Hyper Neon Hub", "Teleportado para Mirage Island", 5)
                        end)
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoKitsune", {
    Title = "Auto Kitsune Shrine",
    Default = Config.Events.AutoKitsune,
    Callback = function(state)
        Config.Events.AutoKitsune = state
        if state then
            spawn(function()
                while Config.Events.AutoKitsune and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    if workspace:FindFirstChild("KitsuneShrine") then
                        pcall(function()
                            safeTeleport(workspace.KitsuneShrine.Position + Vector3.new(0, 10, 0))
                            notify("Hyper Neon Hub", "Teleportado para Kitsune Shrine", 5)
                        end)
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoLeviathan", {
    Title = "Auto Leviathan",
    Default = Config.Events.AutoLeviathan,
    Callback = function(state)
        Config.Events.AutoLeviathan = state
        if state then
            spawn(function()
                while Config.Events.AutoLeviathan and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, leviathan in pairs(workspace.SeaBeasts:GetChildren()) do
                        if leviathan.Name:find("Leviathan") then
                            pcall(function()
                                safeTeleport(leviathan.Position + Vector3.new(0, 10, 0))
                                attackEnemy(leviathan)
                                notify("Hyper Neon Hub", "Farmando Leviathan", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoSeaBeast", {
    Title = "Auto Sea Beast",
    Default = Config.Events.AutoSeaBeast,
    Callback = function(state)
        Config.Events.AutoSeaBeast = state
        if state then
            spawn(function()
                while Config.Events.AutoSeaBeast and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, seaBeast in pairs(workspace.SeaBeasts:GetChildren()) do
                        if seaBeast:IsA("Model") then
                            pcall(function()
                                safeTeleport(seaBeast.Position + Vector3.new(0, 10, 0))
                                attackEnemy(seaBeast)
                                notify("Hyper Neon Hub", "Farmando Sea Beast", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoRaid", {
    Title = "Auto Raid",
    Default = Config.Events.AutoRaid,
    Callback = function(state)
        Config.Events.AutoRaid = state
        if state then
            spawn(function()
                while Config.Events.AutoRaid and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "StartRaid", Config.Events.SelectedRaid)
                        notify("Hyper Neon Hub", "Participando de Raid: " .. Config.Events.SelectedRaid, 5)
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                                local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= Config.Farm.MaxDistance then
                                    safeTeleport(enemy.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                                    attackEnemy(enemy)
                                end
                            end
                        end
                    end)
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddDropdown("SelectedRaid", {
    Title = "Selecionar Raid",
    Values = {"Flame", "Ice", "Quake", "Buddha", "Dark", "Light", "Magma", "Rumble", "String", "Sand"},
    Multi = false,
    Default = Config.Events.SelectedRaid,
    Callback = function(value)
        Config.Events.SelectedRaid = value
    end
})

Tabs.Events:AddToggle("AutoLawRaid", {
    Title = "Auto Law Raid",
    Default = Config.Events.AutoLawRaid,
    Callback = function(state)
        Config.Events.AutoLawRaid = state
        if state then
            spawn(function()
                while Config.Events.AutoLawRaid and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    pcall(function()
                        safeInvoke("CommF_", "StartLawRaid")
                        notify("Hyper Neon Hub", "Participando de Law Raid", 5)
                        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                            if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
                                local distance = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if distance <= Config.Farm.MaxDistance then
                                    safeTeleport(enemy.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
                                    attackEnemy(enemy)
                                end
                            end
                        end
                    end)
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoTerrorshark", {
    Title = "Auto Terrorshark",
    Default = Config.Events.AutoTerrorshark,
    Callback = function(state)
        Config.Events.AutoTerrorshark = state
        if state then
            spawn(function()
                while Config.Events.AutoTerrorshark and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, terrorshark in pairs(workspace.SeaBeasts:GetChildren()) do
                        if terrorshark.Name:find("Terrorshark") then
                            pcall(function()
                                safeTeleport(terrorshark.Position + Vector3.new(0, 10, 0))
                                attackEnemy(terrorshark)
                                notify("Hyper Neon Hub", "Farmando Terrorshark", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoSharkAnchor", {
    Title = "Auto Shark Anchor",
    Default = Config.Events.AutoSharkAnchor,
    Callback = function(state)
        Config.Events.AutoSharkAnchor = state
        if state then
            spawn(function()
                while Config.Events.AutoSharkAnchor and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, seaBeast in pairs(workspace.SeaBeasts:GetChildren()) do
                        if seaBeast.Name:find("Shark") then
                            pcall(function()
                                safeTeleport(seaBeast.Position + Vector3.new(0, 10, 0))
                                attackEnemy(seaBeast)
                                safeInvoke("CommF_", "CollectSharkAnchor", seaBeast)
                                notify("Hyper Neon Hub", "Tentando coletar Shark Anchor", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

Tabs.Events:AddToggle("AutoPirateRaid", {
    Title = "Auto Pirate Raid",
    Default = Config.Events.AutoPirateRaid,
    Callback = function(state)
        Config.Events.AutoPirateRaid = state
        if state then
            spawn(function()
                while Config.Events.AutoPirateRaid and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    for _, raid in pairs(workspace:GetChildren()) do
                        if raid.Name:find("PirateRaid") then
                            pcall(function()
                                safeTeleport(raid.Position + Vector3.new(0, 10, 0))
                                safeInvoke("CommF_", "ParticipatePirateRaid", raid)
                                notify("Hyper Neon Hub", "Participando de Pirate Raid", 5)
                            end)
                        end
                    end
                    wait(5)
                end
            end)
        end
    end
})

-- Aba Teleport
Tabs.Teleport:AddParagraph({
    Title = "Opções de Teleporte",
    Content = "Configure teleportes para ilhas, NPCs e eventos."
})

Tabs.Teleport:AddDropdown("TeleportIsland", {
    Title = "Teleportar para Ilha",
    Values = SeaData[currentSea].Islands,
    Multi = false,
    Default = Config.Teleport.SelectedIsland,
    Callback = function(value)
        Config.Teleport.SelectedIsland = value
        pcall(function()
            local islandPos = workspace.Islands:FindFirstChild(value) and workspace.Islands[value].Position or Vector3.new(0, 0, 0)
            safeTeleport(CFrame.new(islandPos + Vector3.new(0, 50, 0)))
            notify("Hyper Neon Hub", "Teleportado para a ilha: " .. value, 5)
        end)
    end
})

Tabs.Teleport:AddDropdown("TeleportNPC", {
    Title = "Teleportar para NPC",
    Values = SeaData[currentSea].NPCs,
    Multi = false,
    Default = Config.Teleport.SelectedNPC,
    Callback = function(value)
        Config.Teleport.SelectedNPC = value
        pcall(function()
            for _, npc in pairs(workspace.NPCs:GetChildren()) do
                if npc.Name == value then
                    local npcPos = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or npc.Position
                    safeTeleport(CFrame.new(npcPos + Vector3.new(0, 5, 0)))
                    notify("Hyper Neon Hub", "Teleportado para o NPC: " .. value, 5)
                    break
                end
            end
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleportar para Mirage Island",
    Callback = function()
        pcall(function()
            if workspace:FindFirstChild("MirageIsland") then
                safeTeleport(workspace.MirageIsland.Position + Vector3.new(0, 50, 0))
                notify("Hyper Neon Hub", "Teleportado para Mirage Island", 5)
            else
                notify("Hyper Neon Hub", "Mirage Island não encontrada!", 5)
            end
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleportar para Kitsune Shrine",
    Callback = function()
        pcall(function()
            if workspace:FindFirstChild("KitsuneShrine") then
                safeTeleport(workspace.KitsuneShrine.Position + Vector3.new(0, 50, 0))
                notify("Hyper Neon Hub", "Teleportado para Kitsune Shrine", 5)
            else
                notify("Hyper Neon Hub", "Kitsune Shrine não encontrada!", 5)
            end
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleportar para Leviathan",
    Callback = function()
        pcall(function()
            for _, leviathan in pairs(workspace.SeaBeasts:GetChildren()) do
                if leviathan.Name:find("Leviathan") then
                    safeTeleport(leviathan.Position + Vector3.new(0, 50, 0))
                    notify("Hyper Neon Hub", "Teleportado para Leviathan", 5)
                    return
                end
            end
            notify("Hyper Neon Hub", "Leviathan não encontrado!", 5)
        end)
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleportar para Terrorshark",
    Callback = function()
        pcall(function()
            for _, terrorshark in pairs(workspace.SeaBeasts:GetChildren()) do
                if terrorshark.Name:find("Terrorshark") then
                    safeTeleport(terrorshark.Position + Vector3.new(0, 50, 0))
                    notify("Hyper Neon Hub", "Teleportado para Terrorshark", 5)
                    return
                end
            end
            notify("Hyper Neon Hub", "Terrorshark não encontrado!", 5)
        end)
    end
})

Tabs.Teleport:AddToggle("AutoTeleportNearestFruit", {
    Title = "Auto Teleportar para Fruta Mais Próxima",
    Default = Config.Teleport.AutoTeleportNearestFruit,
    Callback = function(state)
        Config.Teleport.AutoTeleportNearestFruit = state
        if state then
            spawn(function()
                while Config.Teleport.AutoTeleportNearestFruit and LocalPlayer.Character do
                    if panicModeCheck() or (checkCrowdedServer() and Config.Misc.SafeMode) or (Config.General.StealthMode and checkStaffPresence()) or checkProximity() then wait(1) continue end
                    local closestFruit, closestDistance = nil, math.huge
                    for _, fruit in pairs(workspace:GetDescendants()) do
                        if (fruit.Name:find("Fruit") or fruit.Name:find("DevilFruit")) and not fruit.Name:find("sail_boat2") then
                            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (fruit.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or math.huge
                            if distance < closestDistance then
                                closestDistance = distance
                                closestFruit = fruit
                            end
                        end
                    end
                    if closestFruit and closestDistance <= Config.Teleport.FruitDistance then
                        pcall(function()
                            safeTeleport(CFrame.new(closestFruit.Position + Vector3.new(0, 5, 0)))
                            notify("Hyper Neon Hub", "Teleportado para fruta: " .. closestFruit.Name, 5)
                        end)
                    end
                    wait(2)
                end
            end)
        end
    end
})

Tabs.Teleport:AddSlider("FruitDistance", {
    Title = "Distância Máxima para Fruta",
    Description = "Distância máxima para teleporte até frutas",
    Min = 100,
    Max = 5000,
    Default = Config.Teleport.FruitDistance,
    Callback = function(value)
        Config.Teleport.FruitDistance = value
    end
})

-- Aba Settings
Tabs.Settings:AddParagraph({
    Title = "Configurações Gerais",
    Content = "Ajuste configurações gerais do script."
})

Tabs.Settings:AddToggle("StealthMode", {
    Title = "Modo Stealth",
    Default = Config.General.StealthMode,
    Callback = function(state)
        Config.General.StealthMode = state
        notify("Hyper Neon Hub", "Modo Stealth " .. (state and "Ativado" or "Desativado"), 5)
    end
})

Tabs.Settings:AddToggle("AutoSaveConfig", {
    Title = "Auto Salvar Configuração",
    Default = Config.General.AutoSaveConfig,
    Callback = function(state)
        Config.General.AutoSaveConfig = state
        if state then
            spawn(function()
                while Config.General.AutoSaveConfig do
                    pcall(function()
                        saveConfig()
                        notify("Hyper Neon Hub", "Configuração salva automaticamente", 5)
                    end)
                    wait(300)
                end
            end)
        end
    end
})

Tabs.Settings:AddButton({
    Title = "Salvar Configuração",
    Callback = function()
        pcall(function()
            saveConfig()
            notify("Hyper Neon Hub", "Configuração salva com sucesso", 5)
        end)
    end
})

Tabs.Settings:AddButton({
    Title = "Carregar Configuração",
    Callback = function()
        pcall(function()
            loadConfig()
            notify("Hyper Neon Hub", "Configuração carregada com sucesso", 5)
        end)
    end
})

Tabs.Settings:AddButton({
    Title = "Resetar Configuração",
    Callback = function()
        pcall(function()
            Config = defaultConfig
            saveConfig()
            notify("Hyper Neon Hub", "Configuração resetada para o padrão", 5)
        end)
    end
})

Tabs.Settings:AddToggle("ShowFPS", {
    Title = "Exibir FPS",
    Default = Config.General.ShowFPS,
    Callback = function(state)
        Config.General.ShowFPS = state
        if state then
            spawn(function()
                while Config.General.ShowFPS do
                    pcall(function()
                        local fps = workspace:GetRealPhysicsFPS()
                        notify("Hyper Neon Hub", "FPS: " .. math.floor(fps), 1)
                    end)
                    wait(1)
                end
            end)
        end
    end
})

Tabs.Settings:AddToggle("LowRender", {
    Title = "Renderização Baixa",
    Default = Config.General.LowRender,
    Callback = function(state)
        Config.General.LowRender = state
        if state then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                        v.Transparency = 0
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end
                notify("Hyper Neon Hub", "Renderização baixa ativada", 5)
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                notify("Hyper Neon Hub", "Renderização restaurada", 5)
            end)
        end
    end
})

-- Finalizando a UI
Window:SelectTab(1)

-- Notificação de inicialização
notify("Hyper Neon Hub", "Script carregado com sucesso! Versão: " .. scriptVersion, 5)

-- Loop principal para monitoramento
spawn(function()
    while true do
        pcall(function()
            if Config.General.WebhookEnabled and Config.General.WebhookURL ~= "" then
                local data = {
                    ["content"] = "",
                    ["embeds"] = {{
                        ["title"] = "Hyper Neon Hub - Status",
                        ["description"] = "Player: " .. LocalPlayer.Name .. "\nLevel: " .. LocalPlayer.Data.Level.Value .. "\nBeli: " .. LocalPlayer.Data.Beli.Value .. "\nFragments: " .. LocalPlayer.Data.Fragments.Value,
                        ["color"] = 0x00FF00,
                        ["footer"] = {
                            ["text"] = "Hyper Neon Hub | " .. os.date("%Y-%m-%d %H:%M:%S")
                        }
                    }}
                }
                local success, response = pcall(function()
                    return HttpService:PostAsync(Config.General.WebhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
                end)
                if not success then
                    notify("Hyper Neon Hub", "Falha ao enviar webhook: " .. tostring(response), 5)
                end
            end
        end)
        wait(300)
    end
end)

-- Anti-cheat bypass (simulação)
spawn(function()
    while true do
        pcall(function()
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v.Name:find("AntiCheat") then
                    v:Destroy()
                end
            end
        end)
        wait(60)
    end
end)
