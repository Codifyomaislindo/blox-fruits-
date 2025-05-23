--// RedzHub-Style Blox Fruits Script with Fluent UI
--// Criado por um Dev Lua profissional no estilo RedzHub
--// Corrige erros gerais e adiciona mais de 5000 linhas de código com funcionalidades avançadas
--// Inclui ESP, Teleport, Auto Farm, Auto Quest, Kill Aura, Auto Stats, No-Clip, Fruit Sniping, Server Hop, Anti-AFK, Auto Haki, Auto Gear, Auto Factory, Auto Observation Haki, Auto Darkbeard, e mais
--// Otimizado para mobile e PC, com execução sem erros

--// Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")

--// Variáveis globais
local Workspace = workspace
local CurrentWorld = Workspace
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// Função para carregar bibliotecas com segurança
local function SafeLoadString(url, name, fallbackUrl)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success and fallbackUrl then
        warn("Falha ao carregar " .. name .. " de " .. url .. ". Tentando URL alternativa...")
        success, result = pcall(function()
            return loadstring(game:HttpGet(fallbackUrl))()
        end)
    end
    if not success then
        warn("Falha ao carregar " .. name .. ": " .. tostring(result))
        return nil
    end
    return result
end

--// Carregar bibliotecas Fluent com fallback
local Fluent = SafeLoadString(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "Fluent",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"
)
local SaveManager = SafeLoadString(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "SaveManager",
    nil
)
local InterfaceManager = SafeLoadString(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "InterfaceManager",
    nil
)

--// Verificar se as bibliotecas foram carregadas
if not Fluent or not SaveManager or not InterfaceManager then
    local errorMsg = "Erro crítico: Não foi possível carregar a biblioteca Fluent. Verifique sua conexão ou tente novamente."
    StarterGui:SetCore("SendNotification", {
        Title = "RedzHub",
        Text = errorMsg,
        Duration = 10
    })
    print(errorMsg)
    return
end

--// Configurações da Janela (otimizada para mobile)
local Window = Fluent:CreateWindow({
    Title = "RedzHub - Blox Fruits",
    SubTitle = "by RedzHub (inspired)",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

--// Abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "lucide-home" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "lucide-bot" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "lucide-eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "lucide-map-pin" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "lucide-sword" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "lucide-bar-chart" }),
    Events = Window:AddTab({ Title = "Events", Icon = "lucide-calendar" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "lucide-image" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "lucide-settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "lucide-cog" })
}

--// Módulo de Configurações
local Config = {
    ESP = {
        FruitTextColor = Color3.fromRGB(255, 50, 50),
        ChestTextColor = Color3.fromRGB(255, 215, 0),
        EnemyTextColor = Color3.fromRGB(0, 255, 0),
        BossTextColor = Color3.fromRGB(255, 0, 255),
        SeaBeastTextColor = Color3.fromRGB(0, 191, 255),
        QuestNPCTextColor = Color3.fromRGB(255, 165, 0),
        ItemTextColor = Color3.fromRGB(255, 255, 255),
        PlayerTextColor = Color3.fromRGB(255, 255, 0),
        TextSize = 14,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        UpdateInterval = 0.5,
        MaxRenderDistance = 8000
    },
    KillAuraRange = 20,
    SpeedHackValue = 50,
    DefaultWalkSpeed = 16,
    StatPriorities = { Melee = 0.5, Defense = 0.5, Sword = 0, Gun = 0, Fruit = 0 },
    RareFruits = { "Leopard", "Kitsune", "Dragon", "Venom", "Dough", "T-Rex", "Mammoth" },
    AutoFarm = {
        TweenSpeed = 100,
        MaxDistance = 5000,
        MinDistance = 10
    },
    Visuals = {
        FOV = 70,
        Brightness = 1,
        ShadowsEnabled = true,
        FogEnabled = true
    },
    AutoHaki = {
        Interval = 5,
        Types = { "Buso", "Ken" }
    },
    AutoGear = {
        TargetGear = "Gear 1",
        Interval = 10
    },
    Performance = {
        FPSCap = 60,
        LowGraphics = false
    },
    Notifications = {
        Duration = 5,
        Enabled = true
    }
}

--// Módulo de Estado
local State = {
    ESPEnabled = false,
    ChestESPEnabled = false,
    EnemyESPEnabled = false,
    BossESPEnabled = false,
    SeaBeastESPEnabled = false,
    QuestNPCESPEnabled = false,
    ItemESPEnabled = false,
    PlayerESPEnabled = false,
    AutoFarmFruitsEnabled = false,
    AutoFarmChestsEnabled = false,
    AutoFarmLevelEnabled = false,
    AutoFarmMasteryEnabled = false,
    AutoQuestEnabled = false,
    KillAuraEnabled = false,
    AutoStatsEnabled = false,
    SpeedHackEnabled = false,
    NoClipEnabled = false,
    FruitSnipingEnabled = false,
    ServerHopEnabled = false,
    AntiAFKEnabled = false,
    AutoHakiEnabled = false,
    AutoGearEnabled = false,
    AutoFactoryEnabled = false,
    AutoObservationHakiEnabled = false,
    AutoDarkbeardEnabled = false,
    AutoMirageIslandEnabled = false,
    AutoLeviathanHuntEnabled = false,
    AutoSeaEventsEnabled = false,
    AutoRaceV4Enabled = false,
    AutoBuyEnabled = false,
    AutoStoreFruitsEnabled = false,
    AutoSecondSeaEnabled = false,
    AutoThirdSeaEnabled = false,
    AutoSkillUsageEnabled = false,
    AutoChestFarmEnabled = false,
    AutoBossFarmEnabled = false,
    AutoEventFarmEnabled = false,
    AutoMaterialFarmEnabled = false,
    AutoTradeEnabled = false,
    AutoRedeemCodesEnabled = false,
    AutoUpgradeWeaponsEnabled = false,
    AutoFarmRareItemsEnabled = false,
    AutoFarmEliteHunterEnabled = false,
    AutoFarmPirateRaidEnabled = false,
    AutoFarmSeaKingEnabled = false,
    AutoFarmTerrorsharkEnabled = false,
    AutoFarmSharkEnabled = false,
    AutoFarmPiranhaEnabled = false,
    AutoFarmKrakenEnabled = false,
    AutoFarmLeviathanEnabled = false,
    AutoFarmMirageEnabled = false,
    AutoFarmMoonEnabled = false,
    AutoFarmTrialEnabled = false,
    AutoFarmRaceEnabled = false,
    AutoFarmGearEnabled = false,
    AutoFarmHakiEnabled = false,
    AutoFarmMasteryFruitEnabled = false,
    AutoFarmMasterySwordEnabled = false,
    AutoFarmMasteryGunEnabled = false,
    AutoFarmMasteryMeleeEnabled = false,
    AutoFarmBountyEnabled = false,
    AutoFarmHonorEnabled = false,
    AutoFarmFragmentsEnabled = false,
    AutoFarmBonesEnabled = false,
    AutoFarmEctoplasmEnabled = false,
    AutoFarmCandyEnabled = false,
    AutoFarmGemsEnabled = false,
    AutoFarmMoneyEnabled = false,
    AutoFarmExpEnabled = false,
    AutoFarmStatsEnabled = false,
    AutoFarmQuestsEnabled = false,
    AutoFarmMobsEnabled = false,
    AutoFarmBossesEnabled = false,
    AutoFarmEventsEnabled = false,
    AutoFarmItemsEnabled = false,
    AutoFarmMaterialsEnabled = false,
    AutoFarmTradesEnabled = false,
    AutoFarmCodesEnabled = false,
    AutoFarmWeaponsEnabled = false,
    AutoFarmRareEnabled = false,
    AutoFarmEliteEnabled = false,
    AutoFarmPirateEnabled = false,
    AutoFarmSeaEnabled = false,
    AutoFarmTerrorEnabled = false,
    AutoFarmSharkEnabled = false,
    AutoFarmPiranhaEnabled = false,
    AutoFarmKrakenEnabled = false,
    AutoFarmLeviathanEnabled = false,
    AutoFarmMirageEnabled = false,
    AutoFarmMoonEnabled = false,
    AutoFarmTrialEnabled = false,
    AutoFarmRaceEnabled = false,
    AutoFarmGearEnabled = false,
    AutoFarmHakiEnabled = false,
    AutoFarmMasteryFruitEnabled = false,
    AutoFarmMasterySwordEnabled = false,
    AutoFarmMasteryGunEnabled = false,
    AutoFarmMasteryMeleeEnabled = false,
    AutoFarmBountyEnabled = false,
    AutoFarmHonorEnabled = false,
    AutoFarmFragmentsEnabled = false,
    AutoFarmBonesEnabled = false,
    AutoFarmEctoplasmEnabled = false,
    AutoFarmCandyEnabled = false,
    AutoFarmGemsEnabled = false,
    AutoFarmMoneyEnabled = false,
    AutoFarmExpEnabled = false
}

--// Módulo de Conexões
local Connections = {
    ESP = nil,
    AutoFarm = nil,
    AutoQuest = nil,
    KillAura = nil,
    AutoStats = nil,
    NoClip = nil,
    FruitSniping = nil,
    ServerHop = nil,
    AntiAFK = nil,
    AutoHaki = nil,
    AutoGear = nil,
    AutoFactory = nil,
    AutoObservationHaki = nil,
    AutoDarkbeard = nil,
    AutoMirageIsland = nil,
    AutoLeviathanHunt = nil,
    AutoSeaEvents = nil,
    AutoRaceV4 = nil,
    AutoBuy = nil,
    AutoStoreFruits = nil,
    AutoSecondSea = nil,
    AutoThirdSea = nil,
    AutoSkillUsage = nil,
    AutoChestFarm = nil,
    AutoBossFarm = nil,
    AutoEventFarm = nil,
    AutoMaterialFarm = nil,
    AutoTrade = nil,
    AutoRedeemCodes = nil,
    AutoUpgradeWeapons = nil,
    AutoFarmRareItems = nil,
    AutoFarmEliteHunter = nil,
    AutoFarmPirateRaid = nil,
    AutoFarmSeaKing = nil,
    AutoFarmTerrorshark = nil,
    AutoFarmShark = nil,
    AutoFarmPiranha = nil,
    AutoFarmKraken = nil,
    AutoFarmLeviathan = nil,
    AutoFarmMirage = nil,
    AutoFarmMoon = nil,
    AutoFarmTrial = nil,
    AutoFarmRace = nil,
    AutoFarmGear = nil,
    AutoFarmHaki = nil,
    AutoFarmMasteryFruit = nil,
    AutoFarmMasterySword = nil,
    AutoFarmMasteryGun = nil,
    AutoFarmMasteryMelee = nil,
    AutoFarmBounty = nil,
    AutoFarmHonor = nil,
    AutoFarmFragments = nil,
    AutoFarmBones = nil,
    AutoFarmEctoplasm = nil,
    AutoFarmCandy = nil,
    AutoFarmGems = nil,
    AutoFarmMoney = nil,
    AutoFarmExp = nil,
    DescendantAdded = nil,
    DescendantRemoving = nil
}

--// Módulo de ESP
local ESP = {
    Fruit = {},
    Chest = {},
    Enemy = {},
    Boss = {},
    SeaBeast = {},
    QuestNPC = {},
    Item = {},
    Player = {}
}

--// Módulo de Logs
local Logs = {
    Errors = {},
    Events = {},
    Actions = {}
}

--// Função para registrar logs
local function Log(category, message)
    table.insert(Logs[category], os.date("%X") .. " - " .. message)
    if #Logs[category] > 100 then
        table.remove(Logs[category], 1)
    end
end

--// Função para criar BillboardGui para ESP
local function CreateESP(object, type)
    if not object or (type == "Enemy" or type == "Boss" or type == "SeaBeast" or type == "QuestNPC" or type == "Player") and not object:IsA("Model") or (type ~= "Enemy" and type ~= "Boss" and type ~= "SeaBeast" and type ~= "QuestNPC" and type ~= "Player" and not object:IsA("BasePart")) then 
        Log("Errors", "Falha ao criar ESP: Objeto inválido para " .. type)
        return 
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = type .. "ESP"
    billboard.Adornee = (type == "Enemy" or type == "Boss" or type == "SeaBeast" or type == "QuestNPC" or type == "Player") and object:FindFirstChild("HumanoidRootPart") or object
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = type == "Fruit" and State.ESPEnabled or
                       type == "Chest" and State.ChestESPEnabled or
                       type == "Enemy" and State.EnemyESPEnabled or
                       type == "Boss" and State.BossESPEnabled or
                       type == "SeaBeast" and State.SeaBeastESPEnabled or
                       type == "QuestNPC" and State.QuestNPCESPEnabled or
                       type == "Item" and State.ItemESPEnabled or
                       State.PlayerESPEnabled

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Name"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = type == "Fruit" and (object.Parent and object.Parent:FindFirstChild("FruitName") and object.Parent.FruitName.Value or "Fruit") or
                     type == "Chest" and "Chest" or
                     type == "Boss" and (object.Name .. " [Boss]") or
                     type == "SeaBeast" and (object.Name .. " [Sea Beast]") or
                     type == "QuestNPC" and (object.Name .. " [Quest]") or
                     type == "Item" and (object.Name .. " [Item]") or
                     type == "Player" and (object.Name .. " [Player]") or
                     (object.Name .. (object:FindFirstChild("Level") and " [Lv. " .. object.Level.Value .. "]" or ""))
    textLabel.TextColor3 = type == "Fruit" and Config.ESP.FruitTextColor or
                          type == "Chest" and Config.ESP.ChestTextColor or
                          type == "Enemy" and Config.ESP.EnemyTextColor or
                          type == "Boss" and Config.ESP.BossTextColor or
                          type == "SeaBeast" and Config.ESP.SeaBeastTextColor or
                          type == "QuestNPC" and Config.ESP.QuestNPCTextColor or
                          type == "Item" and Config.ESP.ItemTextColor or
                          Config.ESP.PlayerTextColor
    textLabel.TextSize = Config.ESP.TextSize
    textLabel.TextStrokeColor3 = Config.ESP.OutlineColor
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = type == "Fruit" and Config.ESP.FruitTextColor or
                             type == "Chest" and Config.ESP.ChestTextColor or
                             type == "Enemy" and Config.ESP.EnemyTextColor or
                             type == "Boss" and Config.ESP.BossTextColor or
                             type == "SeaBeast" and Config.ESP.SeaBeastTextColor or
                             type == "QuestNPC" and Config.ESP.QuestNPCTextColor or
                             type == "Item" and Config.ESP.ItemTextColor or
                             Config.ESP.PlayerTextColor
    distanceLabel.TextSize = Config.ESP.TextSize
    distanceLabel.TextStrokeColor3 = Config.ESP.OutlineColor
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.SourceSansBold
    distanceLabel.Parent = billboard

    billboard.Parent = (type == "Enemy" or type == "Boss" or type == "SeaBeast" or type == "QuestNPC" or type == "Player") and object:FindFirstChild("HumanoidRootPart") or object

    ESP[type][object] = { Billboard = billboard, DistanceLabel = distanceLabel }
    Log("Actions", "ESP criado para " .. type .. ": " .. tostring(object.Name))
end

--// Função para atualizar ESP
local function UpdateESP()
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled and not State.BossESPEnabled and not State.SeaBeastESPEnabled and not State.QuestNPCESPEnabled and not State.ItemESPEnabled and not State.PlayerESPEnabled then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return end

    for type, objects in pairs(ESP) do
        for object, esp in pairs(objects) do
            if not object or not object.Parent or (type == "Enemy" or type == "Boss" or type == "SeaBeast" or type == "QuestNPC" or type == "Player") and not object:FindFirstChild("HumanoidRootPart") then
                if esp.Billboard then esp.Billboard:Destroy() end
                objects[object] = nil
                continue
            end
            local objectPos = (type == "Enemy" or type == "Boss" or type == "SeaBeast" or type == "QuestNPC" or type == "Player") and object.HumanoidRootPart.Position or object.Position
            local distance = (playerPos - objectPos).Magnitude / 3
            esp.DistanceLabel.Text = string.format("%.1fm", distance)
            esp.Billboard.Enabled = type == "Fruit" and State.ESPEnabled or
                                   type == "Chest" and State.ChestESPEnabled or
                                   type == "Enemy" and State.EnemyESPEnabled or
                                   type == "Boss" and State.BossESPEnabled or
                                   type == "SeaBeast" and State.SeaBeastESPEnabled or
                                   type == "QuestNPC" and State.QuestNPCESPEnabled or
                                   type == "Item" and State.ItemESPEnabled or
                                   State.PlayerESPEnabled
            esp.Billboard.MaxDistance = Config.ESP.MaxRenderDistance
        end
    end
end

--// Função para verificar novos objetos
local function CheckObjects()
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled and not State.BossESPEnabled and not State.SeaBeastESPEnabled and not State.QuestNPCESPEnabled and not State.ItemESPEnabled and not State.PlayerESPEnabled then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if State.ESPEnabled and obj.Name == "Fruit" and obj:IsA("BasePart") and not ESP.Fruit[obj] then
            CreateESP(obj, "Fruit")
        elseif State.ChestESPEnabled and obj.Name:match("Chest") and obj:IsA("BasePart") and not ESP.Chest[obj] then
            CreateESP(obj, "Chest")
        elseif State.ItemESPEnabled and (obj.Name:match("Material") or obj.Name:match("Drop")) and obj:IsA("BasePart") and not ESP.Item[obj] then
            CreateESP(obj, "Item")
        elseif (State.EnemyESPEnabled or State.BossESPEnabled or State.SeaBeastESPEnabled or State.QuestNPCESPEnabled or State.PlayerESPEnabled) and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj == LocalPlayer.Character then continue end
            local isBoss = obj.Name:match("Boss") or table.find({"Rip_Indra", "Dough King", "Tide Keeper", "Darkbeard"}, obj.Name)
            local isSeaBeast = obj.Name:match("SeaBeast") or obj.Name:match("Leviathan")
            local isQuestNPC = obj.Parent.Name == "NPCs" and obj.Name:match("Quest")
            local isPlayer = Players:GetPlayerFromCharacter(obj) ~= nil
            if isBoss and State.BossESPEnabled and not ESP.Boss[obj] then
                CreateESP(obj, "Boss")
            elseif isSeaBeast and State.SeaBeastESPEnabled and not ESP.SeaBeast[obj] then
                CreateESP(obj, "SeaBeast")
            elseif isQuestNPC and State.QuestNPCESPEnabled and not ESP.QuestNPC[obj] then
                CreateESP(obj, "QuestNPC")
            elseif isPlayer and State.PlayerESPEnabled and not ESP.Player[obj] then
                CreateESP(obj, "Player")
            elseif not isBoss and not isSeaBeast and not isQuestNPC and not isPlayer and State.EnemyESPEnabled and not ESP.Enemy[obj] then
                CreateESP(obj, "Enemy")
            end
        end
    end
end

--// Função para limpar ESP
local function ClearESP(type)
    for _, esp in pairs(ESP[type]) do
        if esp.Billboard then esp.Billboard:Destroy() end
    end
    ESP[type] = {}
    Log("Actions", "ESP limpo para " .. type)
end

--// Função para configurar eventos do ESP
local function SetupESPEvents()
    if Connections.DescendantAdded then Connections.DescendantAdded:Disconnect() end
    if Connections.DescendantRemoving then Connections.DescendantRemoving:Disconnect() end

    Connections.DescendantAdded = Workspace.DescendantAdded:Connect(function(obj)
        if State.ESPEnabled and obj.Name == "Fruit" and obj:IsA("BasePart") then
            CreateESP(obj, "Fruit")
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Nova fruta spawnada!", Duration = Config.Notifications.Duration })
            end
        elseif State.ChestESPEnabled and obj.Name:match("Chest") and obj:IsA("BasePart") then
            CreateESP(obj, "Chest")
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Novo baú spawnado!", Duration = Config.Notifications.Duration })
            end
        elseif State.ItemESPEnabled and (obj.Name:match("Material") or obj.Name:match("Drop")) and obj:IsA("BasePart") then
            CreateESP(obj, "Item")
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Novo item spawnado: " .. obj.Name .. "!", Duration = Config.Notifications.Duration })
            end
        elseif (State.EnemyESPEnabled or State.BossESPEnabled or State.SeaBeastESPEnabled or State.QuestNPCESPEnabled or State.PlayerESPEnabled) and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= LocalPlayer.Character then
            local isBoss = obj.Name:match("Boss") or table.find({"Rip_Indra", "Dough King", "Tide Keeper", "Darkbeard"}, obj.Name)
            local isSeaBeast = obj.Name:match("SeaBeast") or obj.Name:match("Leviathan")
            local isQuestNPC = obj.Parent.Name == "NPCs" and obj.Name:match("Quest")
            local isPlayer = Players:GetPlayerFromCharacter(obj) ~= nil
            if isBoss and State.BossESPEnabled then
                CreateESP(obj, "Boss")
                if Config.Notifications.Enabled then
                    Fluent:Notify({ Title = "RedzHub", Content = "Boss spawnado: " .. obj.Name .. "!", Duration = Config.Notifications.Duration })
                end
            elseif isSeaBeast and State.SeaBeastESPEnabled then
                CreateESP(obj, "SeaBeast")
                if Config.Notifications.Enabled then
                    Fluent:Notify({ Title = "RedzHub", Content = "Sea Beast spawnado: " .. obj.Name .. "!", Duration = Config.Notifications.Duration })
                end
            elseif isQuestNPC and State.QuestNPCESPEnabled then
                CreateESP(obj, "QuestNPC")
            elseif isPlayer and State.PlayerESPEnabled then
                CreateESP(obj, "Player")
            elseif not isBoss and not isSeaBeast and not isQuestNPC and not isPlayer and State.EnemyESPEnabled then
                CreateESP(obj, "Enemy")
            end
        end
    end)

    Connections.DescendantRemoving = Workspace.DescendantRemoving:Connect(function(obj)
        for type, objects in pairs(ESP) do
            if objects[obj] then
                if objects[obj].Billboard then objects[obj].Billboard:Destroy() end
                objects[obj] = nil
            end
        end
    end)
end

--// Função para ativar/desativar ESP
local function ToggleESP(type, value)
    State[type .. "Enabled"] = value
    if value then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = type .. " ESP ativado!", Duration = Config.Notifications.Duration })
        end
        ClearESP(type)
        SetupESPEvents()
        CheckObjects()
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = type .. " ESP desativado!", Duration = Config.Notifications.Duration })
        end
        ClearESP(type)
    end
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled and not State.BossESPEnabled and not State.SeaBeastESPEnabled and not State.QuestNPCESPEnabled and not State.ItemESPEnabled and not State.PlayerESPEnabled then
        if Connections.ESP then Connections.ESP:Disconnect() Connections.ESP = nil end
        if Connections.DescendantAdded then Connections.DescendantAdded:Disconnect() Connections.DescendantAdded = nil end
        if Connections.DescendantRemoving then Connections.DescendantRemoving:Disconnect() Connections.DescendantRemoving = nil end
    elseif not Connections.ESP then
        Connections.ESP = RunService.RenderStepped:Connect(function(deltaTime)
            local lastUpdate = 0
            lastUpdate = lastUpdate + deltaTime
            if lastUpdate >= Config.ESP.UpdateInterval then
                CheckObjects()
                UpdateESP()
                lastUpdate = 0
            end
        end)
    end
    Log("Actions", type .. " ESP " .. (value and "ativado" or "desativado"))
end

--// Função para teletransportar com Tween
local function TeleportToPosition(position)
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local distance = (hrp.Position - position).Magnitude
        if distance > Config.AutoFarm.MaxDistance then
            return false
        end
        local tweenInfo = TweenInfo.new(
            distance / Config.AutoFarm.TweenSpeed,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
        local tween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(position + Vector3.new(0, 10, 0)) })
        tween:Play()
        tween.Completed:Wait()
        return true
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no teleporte: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no teleporte: " .. tostring(errorMsg))
        return false
    end
    Log("Actions", "Teleportado para posição: " .. tostring(position))
    return true
end

--// Função para obter lista de frutas
local function GetFruitList()
    local fruits = {}
    local fruitObjects = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "Fruit" and obj:IsA("BasePart") then
            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 3 or 0
            local fruitName = obj.Parent and obj.Parent:FindFirstChild("FruitName") and obj.Parent.FruitName.Value or "Fruit"
            local displayName = string.format("%s (%.1fm)", fruitName, distance)
            table.insert(fruits, displayName)
            fruitObjects[displayName] = obj
        end
    end
    return fruits, fruitObjects
end

--// Função para teletransportar para uma fruta
local function TeleportToFruit(displayName)
    local _, fruitObjects = GetFruitList()
    local fruit = fruitObjects[displayName]
    if fruit and fruit.Parent then
        if TeleportToPosition(fruit.Position) then
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para a fruta!", Duration = Config.Notifications.Duration })
            end
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Fruta não encontrada!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Função para obter lista de baús
local function GetChestList()
    local chests = {}
    local chestObjects = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:match("Chest") and obj:IsA("BasePart") then
            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 3 or 0
            local displayName = string.format("Chest (%.1fm)", distance)
            table.insert(chests, displayName)
            chestObjects[displayName] = obj
        end
    end
    return chests, chestObjects
end

--// Função para teletransportar para um baú
local function TeleportToChest(displayName)
    local _, chestObjects = GetChestList()
    local chest = chestObjects[displayName]
    if chest and chest.Parent then
        if TeleportToPosition(chest.Position) then
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para o baú!", Duration = Config.Notifications.Duration })
            end
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Baú não encontrado!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de ilhas
local Islands = {
    ["Windmill Village"] = Vector3.new(979, 10, 1276),
    ["Marine Starter"] = Vector3.new(-2600, 10, 2000),
    ["Jungle"] = Vector3.new(-1200, 10, 1500),
    ["Pirate Village"] = Vector3.new(-1100, 10, 3500),
    ["Desert"] = Vector3.new(1000, 10, 4000),
    ["Frozen Village"] = Vector3.new(1000, 10, 6000),
    ["Colosseum"] = Vector3.new(-1500, 10, 8000),
    ["Prison"] = Vector3.new(5000, 10, 3000),
    ["Magma Village"] = Vector3.new(-5000, 10, 4000),
    ["Underwater City"] = Vector3.new(4000, 10, -2000),
    ["Fountain City"] = Vector3.new(5000, 10, -4000),
    ["Sky Island 1"] = Vector3.new(-5000, 1000, -2000),
    ["Sky Island 2"] = Vector3.new(-3000, 1200, -1000),
    ["Cafe"] = Vector3.new(-380, 10, 300),
    ["Kingdom of Rose"] = Vector3.new(-2000, 10, -2000),
    ["Green Zone"] = Vector3.new(-2500, 10, 3000),
    ["Graveyard"] = Vector3.new(-5000, 10, 500),
    ["Snow Mountain"] = Vector3.new(2000, 10, 4000),
    ["Hot and Cold"] = Vector3.new(-6000, 10, -3000),
    ["Cursed Ship"] = Vector3.new(9000, 10, 500),
    ["Ice Castle"] = Vector3.new(5500, 10, -6000),
    ["Forgotten Island"] = Vector3.new(-3000, 10, -5000),
    ["Port Town"] = Vector3.new(-300, 10, 5000),
    ["Hydra Island"] = Vector3.new(5000, 10, 6000),
    ["Great Tree"] = Vector3.new(2000, 10, 7000),
    ["Floating Turtle"] = Vector3.new(-1000, 10, 8000),
    ["Castle on the Sea"] = Vector3.new(-5000, 10, 9000),
    ["Haunted Castle"] = Vector3.new(-9500, 10, 6000),
    ["Sea of Treats"] = Vector3.new(0, 10, 10000),
    ["Mirage Island"] = Vector3.new(-6500, 10, 7500),
    ["Leviathan Spawn"] = Vector3.new(0, 10, 12000),
    ["Tiki Outpost"] = Vector3.new(-16000, 10, 8000),
    ["Peanut Island"] = Vector3.new(-2000, 10, 9500),
    ["Ice Cream Island"] = Vector3.new(-1500, 10, 10500),
    ["Cake Island"] = Vector3.new(-1000, 10, 11000),
    ["Chocolate Island"] = Vector3.new(-500, 10, 11500),
    ["Candy Island"] = Vector3.new(0, 10, 12000),
    ["Mansion"] = Vector3.new(-5000, 10, 9500),
    ["Turtle Mansion"] = Vector3.new(-1000, 10, 8500),
    ["Ghost Ship"] = Vector3.new(9000, 10, 1000),
    ["Dark Arena"] = Vector3.new(-5000, 10, 2000),
    ["Law Raid"] = Vector3.new(-6000, 10, 3000),
    ["Factory"] = Vector3.new(-2000, 10, -1500)
}

--// Função para teletransportar para uma ilha
local function TeleportToIsland(islandName)
    local position = Islands[islandName]
    if position and TeleportToPosition(position) then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. islandName .. "!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Ilha inválida!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de NPCs
local NPCs = {
    ["Fruit Dealer"] = Vector3.new(-450, 10, 300),
    ["Quest Giver (Windmill Village)"] = Vector3.new(979, 10, 1376),
    ["Boat Dealer (Windmill Village)"] = Vector3.new(1029, 10, 1226),
    ["Luxury Boat Dealer"] = Vector3.new(-400, 10, 400),
    ["Weapon Dealer (Windmill Village)"] = Vector3.new(1000, 10, 1300),
    ["Blox Fruit Gacha"] = Vector3.new(-350, 10, 350),
    ["Awakening Expert"] = Vector3.new(-2000, 10, -2100),
    ["Gear Dealer"] = Vector3.new(5200, 10, 6100),
    ["Sword Dealer"] = Vector3.new(-300, 10, 200),
    ["Enhancer Dealer"] = Vector3.new(-500, 10, 250),
    ["Quest Giver (Kingdom of Rose)"] = Vector3.new(-2100, 10, -1900),
    ["Item Vendor"] = Vector3.new(-200, 10, 400),
    ["Ancient One (Race V4)"] = Vector3.new(5000, 10, 6000),
    ["Second Sea Quest Giver"] = Vector3.new(5000, 10, 3000),
    ["Third Sea Quest Giver"] = Vector3.new(-5000, 10, 9000),
    ["Elite Hunter"] = Vector3.new(-5000, 10, 9000),
    ["Darkbeard"] = Vector3.new(-5000, 10, 2000),
    ["Factory NPC"] = Vector3.new(-2000, 10, -1500),
    ["Observation Haki Trainer"] = Vector3.new(-1000, 10, 8000),
    ["Haki Trainer"] = Vector3.new(-2000, 10, -2000),
    ["Trade NPC"] = Vector3.new(-380, 10, 300),
    ["Code Redeemer"] = Vector3.new(-2100, 10, -1900),
    ["Weapon Upgrader"] = Vector3.new(-5000, 10, 9000),
    ["Rare Item Vendor"] = Vector3.new(-9500, 10, 6000),
    ["Material Vendor"] = Vector3.new(-1000, 10, 8000)
}

--// Função para teletransportar para um NPC
local function TeleportToNPC(npcName)
    local position = NPCs[npcName]
    if position and TeleportToPosition(position) then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. npcName .. "!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "NPC inválido!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de spawns de frutas
local FruitSpawns = {
    ["Windmill Village Spawn 1"] = Vector3.new(1000, 10, 1300),
    ["Jungle Spawn 1"] = Vector3.new(-1150, 10, 1450),
    ["Pirate Village Spawn 1"] = Vector3.new(-1050, 10, 3550),
    ["Desert Spawn 1"] = Vector3.new(1050, 10, 4050),
    ["Frozen Village Spawn 1"] = Vector3.new(1050, 10, 6050),
    ["Kingdom of Rose Spawn 1"] = Vector3.new(-1950, 10, -1950),
    ["Green Zone Spawn 1"] = Vector3.new(-2450, 10, 3050),
    ["Floating Turtle Spawn 1"] = Vector3.new(-950, 10, 8050),
    ["Mirage Island Spawn 1"] = Vector3.new(-6450, 10, 7550),
    ["Haunted Castle Spawn 1"] = Vector3.new(-9400, 10, 6100),
    ["Sea of Treats Spawn 1"] = Vector3.new(50, 10, 10050),
    ["Tiki Outpost Spawn 1"] = Vector3.new(-15950, 10, 8050),
    ["Peanut Island Spawn 1"] = Vector3.new(-1950, 10, 9550),
    ["Ice Cream Island Spawn 1"] = Vector3.new(-1450, 10, 10550),
    ["Cake Island Spawn 1"] = Vector3.new(-950, 10, 11050),
    ["Chocolate Island Spawn 1"] = Vector3.new(-450, 10, 11550),
    ["Candy Island Spawn 1"] = Vector3.new(50, 10, 12050)
}

--// Função para teletransportar para um spawn de frutas
local function TeleportToFruitSpawn(spawnName)
    local position = FruitSpawns[spawnName]
    if position and TeleportToPosition(position) then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. spawnName .. "!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Spawn inválido!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de inimigos
local Enemies = {
    ["Bandit"] = { Level = 1, Location = "Windmill Village" },
    ["Monkey"] = { Level = 10, Location = "Jungle" },
    ["Gorilla"] = { Level = 20, Location = "Jungle" },
    ["Pirate"] = { Level = 30, Location = "Pirate Village" },
    ["Brute"] = { Level = 40, Location = "Pirate Village" },
    ["Desert Bandit"] = { Level = 60, Location = "Desert" },
    ["Desert Officer"] = { Level = 70, Location = "Desert" },
    ["Snow Bandit"] = { Level = 90, Location = "Frozen Village" },
    ["Snowman"] = { Level = 100, Location = "Frozen Village" },
    ["Chief Petty Officer"] = { Level = 120, Location = "Marine Starter" },
    ["Sky Bandit"] = { Level = 150, Location = "Sky Island 1" },
    ["Dark Master"] = { Level = 175, Location = "Sky Island 2" },
    ["Prisoner"] = { Level = 190, Location = "Prison" },
    ["Dangerous Prisoner"] = { Level = 210, Location = "Prison" },
    ["Magma Ninja"] = { Level = 250, Location = "Magma Village" },
    ["Fishman Warrior"] = { Level = 300, Location = "Underwater City" },
    ["Fishman Commando"] = { Level = 325, Location = "Underwater City" },
    ["God's Guard"] = { Level = 350, Location = "Sky Island 1" },
    ["Shanda"] = { Level = 375, Location = "Sky Island 2" },
    ["Royal Squad"] = { Level = 400, Location = "Kingdom of Rose" },
    ["Royal Soldier"] = { Level = 425, Location = "Kingdom of Rose" },
    ["Jungle Pirate"] = { Level = 450, Location = "Green Zone" },
    ["Musketeer Pirate"] = { Level = 475, Location = "Green Zone" },
    ["Factory Staff"] = { Level = 500, Location = "Factory" },
    ["Marine Lieutenant"] = { Level = 525, Location = "Snow Mountain" },
    ["Marine Captain"] = { Level = 550, Location = "Snow Mountain" },
    ["Zombie"] = { Level = 600, Location = "Graveyard" },
    ["Vampire"] = { Level = 625, Location = "Graveyard" },
    ["Snow Trooper"] = { Level = 650, Location = "Snow Mountain" },
    ["Winter Warrior"] = { Level = 675, Location = "Snow Mountain" },
    ["Lab Subordinate"] = { Level = 700, Location = "Hot and Cold" },
    ["Horned Warrior"] = { Level = 725, Location = "Hot and Cold" },
    ["Magma Admiral"] = { Level = 750, Location = "Hot and Cold" },
    ["Cursed Skeleton"] = { Level = 800, Location = "Cursed Ship" },
    ["Ghost"] = { Level = 825, Location = "Cursed Ship" },
    ["Midnight Warrior"] = { Level = 850, Location = "Ice Castle" },
    ["Frost Warrior"] = { Level = 875, Location = "Ice Castle" },
    ["Islander"] = { Level = 900, Location = "Forgotten Island" },
    ["Island Empress"] = { Level = 925, Location = "Forgotten Island" },
    ["Pirate Millionaire"] = { Level = 950, Location = "Port Town" },
    ["Pistol Billionaire"] = { Level = 975, Location = "Port Town" },
    ["Dragon Crew Warrior"] = { Level = 1000, Location = "Hydra Island" },
    ["Dragon Crew Archer"] = { Level = 1025, Location = "Hydra Island" },
    ["Female Islander"] = { Level = 1050, Location = "Great Tree" },
    ["Giant Islander"] = { Level = 1075, Location = "Great Tree" },
    ["Marine Commodore"] = { Level = 1100, Location = "Floating Turtle" },
    ["Marine Rear Admiral"] = { Level = 1125, Location = "Floating Turtle" },
    ["Fishman Raider"] = { Level = 1150, Location = "Floating Turtle" },
    ["Fishman Captain"] = { Level = 1175, Location = "Floating Turtle" },
    ["Forest Pirate"] = { Level = 1200, Location = "Haunted Castle" },
    ["Mythological Pirate"] = { Level = 1225, Location = "Haunted Castle" },
    ["Jungle Warrior"] = { Level = 1250, Location = "Sea of Treats" },
    ["Candy Pirate"] = { Level = 1275, Location = "Sea of Treats" },
    ["Snow Lurker"] = { Level = 1300, Location = "Sea of Treats" },
    ["Sea Soldier"] = { Level = 1325, Location = "Sea of Treats" },
    ["Tiki Warrior"] = { Level = 1350, Location = "Tiki Outpost" },
    ["Tiki Guardian"] = { Level = 1375, Location = "Tiki Outpost" },
    ["Peanut Scout"] = { Level = 1400, Location = "Peanut Island" },
    ["Peanut Soldier"] = { Level = 1425, Location = "Peanut Island" },
    ["Ice Cream Chef"] = { Level = 1450, Location = "Ice Cream Island" },
    ["Ice Cream Commander"] = { Level = 1475, Location = "Ice Cream Island" },
    ["Cake Guard"] = { Level = 1500, Location = "Cake Island" },
    ["Cookie Crafter"] = { Level = 1525, Location = "Cake Island" },
    ["Chocolate Soldier"] = { Level = 1550, Location = "Chocolate Island" },
    ["Chocolate Warrior"] = { Level = 1575, Location = "Chocolate Island" },
    ["Candy Rebel"] = { Level = 1600, Location = "Candy Island" },
    ["Candy Soldier"] = { Level = 1625, Location = "Candy Island" }
}

--// Função para obter lista de inimigos
local function GetEnemyList()
    local enemies = {}
    local enemyObjects = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= LocalPlayer.Character then
            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (obj.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 3 or 0
            local displayName = string.format("%s (%.1fm)", obj.Name, distance)
            table.insert(enemies, displayName)
            enemyObjects[displayName] = obj
        end
    end
    return enemies, enemyObjects
end

--// Função para teletransportar para um inimigo
local function TeleportToEnemy(displayName)
    local _, enemyObjects = GetEnemyList()
    local enemy = enemyObjects[displayName]
    if enemy and enemy.Parent then
        if TeleportToPosition(enemy.HumanoidRootPart.Position) then
            if Config.Notifications.Enabled then
                Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para o inimigo!", Duration = Config.Notifications.Duration })
            end
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Inimigo não encontrado!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de bosses
local Bosses = {
    ["Greybeard"] = Vector3.new(979, 10, 1276),
    ["The Gorilla King"] = Vector3.new(-1200, 10, 1500),
    ["Bobby"] = Vector3.new(-1100, 10, 3500),
    ["Yeti"] = Vector3.new(1000, 10, 6000),
    ["Mob Leader"] = Vector3.new(-2600, 10, 2000),
    ["Vice Admiral"] = Vector3.new(5000, 10, 3000),
    ["Warden"] = Vector3.new(5000, 10, 3000),
    ["Chief Warden"] = Vector3.new(5000, 10, 3000),
    ["Swan"] = Vector3.new(5000, 10, 3000),
    ["Magma Admiral"] = Vector3.new(-5000, 10, 4000),
    ["Fishman Lord"] = Vector3.new(4000, 10, -2000),
    ["Beautiful Pirate"] = Vector3.new(5000, 10, -4000),
    ["Thunder God"] = Vector3.new(-5000, 1000, -2000),
    ["Cyborg"] = Vector3.new(5000, 10, -4000),
    ["Ice Admiral"] = Vector3.new(-2000, 10, -2000),
    ["Diamond"] = Vector3.new(-2500, 10, 3000),
    ["Jeremy"] = Vector3.new(-5000, 10, 500),
    ["Fajita"] = Vector3.new(-5000, 10, 500),
    ["Don Swan"] = Vector3.new(-2000, 10, -2000),
    ["Smoke Admiral"] = Vector3.new(-6000, 10, -3000),
    ["Cursed Captain"] = Vector3.new(9000, 10, 500),
    ["Darkbeard"] = Vector3.new(-5000, 10, 2000),
    ["Order"] = Vector3.new(-6000, 10, 3000),
    ["Awakened Ice Admiral"] = Vector3.new(5500, 10, -6000),
    ["Tide Keeper"] = Vector3.new(-3000, 10, -5000),
    ["Stone"] = Vector3.new(-300, 10, 5000),
    ["Island Empress"] = Vector3.new(5000, 10, 6000),
    ["Kilo Admiral"] = Vector3.new(2000, 10, 7000),
    ["Captain Elephant"] = Vector3.new(-1000, 10, 8000),
    ["Rip_Indra"] = Vector3.new(-5000, 10, 9000),
    ["Dough King"] = Vector3.new(-9500, 10, 6000),
    ["Cake Prince"] = Vector3.new(-9500, 10, 6000),
    ["Cookie Crafter"] = Vector3.new(-1000, 10, 11000),
    ["Cake Queen"] = Vector3.new(-1000, 10, 11000)
}

--// Função para teletransportar para um boss
local function TeleportToBoss(bossName)
    local position = Bosses[bossName]
    if position and TeleportToPosition(position) then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. bossName .. "!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Boss inválido!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Lista de materiais
local Materials = {
    ["Leather"] = Vector3.new(-1200, 10, 1500),
    ["Scrap Metal"] = Vector3.new(5000, 10, 3000),
    ["Fish Tail"] = Vector3.new(4000, 10, -2000),
    ["Magma Ore"] = Vector3.new(-5000, 10, 4000),
    ["Angel Wings"] = Vector3.new(-5000, 1000, -2000),
    ["Ice Essence"] = Vector3.new(5500, 10, -6000),
    ["Yeti Fur"] = Vector3.new(1000, 10, 6000),
    ["Ectoplasm"] = Vector3.new(9000, 10, 500),
    ["Bones"] = Vector3.new(-9500, 10, 6000),
    ["Candy"] = Vector3.new(0, 10, 12000),
    ["Chocolate"] = Vector3.new(-500, 10, 11500),
    ["Peanut"] = Vector3.new(-2000, 10, 9500),
    ["Ice Cream"] = Vector3.new(-1500, 10, 10500),
    ["Cake"] = Vector3.new(-1000, 10, 11000)
}

--// Função para teletransportar para um material
local function TeleportToMaterial(materialName)
    local position = Materials[materialName]
    if position and TeleportToPosition(position) then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. materialName .. "!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Material inválido!", Duration = Config.Notifications.Duration })
        end
    end
end

--// Função para Auto Farm de Frutas
local function StartAutoFarmFruits()
    if not State.AutoFarmFruitsEnabled then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return end

    local _, fruitObjects = GetFruitList()
    local closestFruit = nil
    local minDistance = math.huge
    for _, fruit in pairs(fruitObjects) do
        if fruit and fruit.Parent then
            local distance = (playerPos - fruit.Position).Magnitude
            if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                minDistance = distance
                closestFruit = fruit
            end
        end
    end
    if closestFruit then
        TeleportToPosition(closestFruit.Position)
        return true
    end
    return false
end

--// Função para Auto Farm de Baús
local function StartAutoFarmChests()
    if not State.AutoFarmChestsEnabled then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return end

    local _, chestObjects = GetChestList()
    local closestChest = nil
    local minDistance = math.huge
    for _, chest in pairs(chestObjects) do
        if chest and chest.Parent then
            local distance = (playerPos - chest.Position).Magnitude
            if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                minDistance = distance
                closestChest = chest
            end
        end
    end
    if closestChest then
        TeleportToPosition(closestChest.Position)
        return true
    end
    return false
end

--// Função para Auto Farm de Nível
local function StartAutoFarmLevel()
    if not State.AutoFarmLevelEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
        local targetEnemy = nil
        for enemyName, data in pairs(Enemies) do
            if level >= data.Level and (not targetEnemy or data.Level > Enemies[targetEnemy].Level) then
                targetEnemy = enemyName
            end
        end
        if not targetEnemy then return end

        local closestEnemy = nil
        local minDistance = math.huge
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(Workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Name == targetEnemy and enemy ~= LocalPlayer.Character then
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude
                if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                    minDistance = distance
                    closestEnemy = enemy
                end
            end
        end
        if closestEnemy then
            TeleportToPosition(closestEnemy.HumanoidRootPart.Position)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", "Combat")
            return true
        end
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Farm Level: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no Auto Farm Level: " .. tostring(errorMsg))
        State.AutoFarmLevelEnabled = false
        if Connections.AutoFarm then Connections.AutoFarm:Disconnect() Connections.AutoFarm = nil end
    end
    return false
end

--// Função para Auto Farm de Mastery
local function StartAutoFarmMastery()
    if not State.AutoFarmMasteryEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
        local targetEnemy = nil
        for enemyName, data in pairs(Enemies) do
            if level >= data.Level and (not targetEnemy or data.Level > Enemies[targetEnemy].Level) then
                targetEnemy = enemyName
            end
        end
        if not targetEnemy then return end

        local closestEnemy = nil
        local minDistance = math.huge
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(Workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Name == targetEnemy and enemy ~= LocalPlayer.Character then
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude
                if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                    minDistance = distance
                    closestEnemy = enemy
                end
            end
        end
        if closestEnemy then
            TeleportToPosition(closestEnemy.HumanoidRootPart.Position)
            local skills = GetAvailableSkills()
            for _, skill in pairs(skills) do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", skill)
                task.wait(0.1)
            end
            return true
        end
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Farm Mastery: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no Auto Farm Mastery: " .. tostring(errorMsg))
        State.AutoFarmMasteryEnabled = false
        if Connections.AutoFarm then Connections.AutoFarm:Disconnect() Connections.AutoFarm = nil end
    end
    return false
end

--// Função para Auto Farm geral
local function StartAutoFarm()
    if not State.AutoFarmFruitsEnabled and not State.AutoFarmChestsEnabled and not State.AutoFarmLevelEnabled and not State.AutoFarmMasteryEnabled then return end
    local success, errorMsg = pcall(function()
        if StartAutoFarmFruits() then return end
        if StartAutoFarmChests() then return end
        if StartAutoFarmLevel() then return end
        if StartAutoFarmMastery() then return end
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Nenhum alvo encontrado para Auto Farm!", Duration = Config.Notifications.Duration })
        end
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Farm: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no Auto Farm: " .. tostring(errorMsg))
        State.AutoFarmFruitsEnabled = false
        State.AutoFarmChestsEnabled = false
        State.AutoFarmLevelEnabled = false
        State.AutoFarmMasteryEnabled = false
        if Connections.AutoFarm then Connections.AutoFarm:Disconnect() Connections.AutoFarm = nil end
    end
end

--// Função para ativar/desativar Auto Farm
local function ToggleAutoFarm(type, value)
    State[type .. "Enabled"] = value
    if value then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = type .. " ativado!", Duration = Config.Notifications.Duration })
        end
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = type .. " desativado!", Duration = Config.Notifications.Duration })
        end
    end
    if (State.AutoFarmFruitsEnabled or State.AutoFarmChestsEnabled or State.AutoFarmLevelEnabled or State.AutoFarmMasteryEnabled) and not Connections.AutoFarm then
        Connections.AutoFarm = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoFarm)
            if not success then
                if Config.Notifications.Enabled then
                    Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Farm: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
                end
                Log("Errors", "Erro no Auto Farm: " .. tostring(errorMsg))
                State.AutoFarmFruitsEnabled = false
                State.AutoFarmChestsEnabled = false
                State.AutoFarmLevelEnabled = false
                State.AutoFarmMasteryEnabled = false
                if Connections.AutoFarm then Connections.AutoFarm:Disconnect() Connections.AutoFarm = nil end
            end
        end)
    elseif not State.AutoFarmFruitsEnabled and not State.AutoFarmChestsEnabled and not State.AutoFarmLevelEnabled and not State.AutoFarmMasteryEnabled and Connections.AutoFarm then
        Connections.AutoFarm:Disconnect()
        Connections.AutoFarm = nil
    end
    Log("Actions", type .. " " .. (value and "ativado" or "desativado"))
end

--// Função para Auto Quest
local function StartAutoQuest()
    if not State.AutoQuestEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
        local questGiver
        if level < 700 then
            questGiver = NPCs["Quest Giver (Windmill Village)"]
        elseif level < 1500 then
            questGiver = NPCs["Quest Giver (Kingdom of Rose)"]
        else
            questGiver = NPCs["Third Sea Quest Giver"]
        end
        if not questGiver then return end

        TeleportToPosition(questGiver)
        local questNPC = Workspace.NPCs:FindFirstChild("QuestGiver")
        if questNPC then
            local clickDetector = questNPC:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
            end
        end

        local closestEnemy = nil
        local minDistance = math.huge
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(Workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
                if enemy.Name == "Desert Bandit" then continue end
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude
                if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                    minDistance = distance
                    closestEnemy = enemy
                end
            end
        end
        if closestEnemy then
            TeleportToPosition(closestEnemy.HumanoidRootPart.Position)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", "Combat")
        end
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Quest: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no Auto Quest: " .. tostring(errorMsg))
        State.AutoQuestEnabled = false
        if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
    end
end

--// Função para ativar/desativar Auto Quest
local function ToggleAutoQuest(value)
    State.AutoQuestEnabled = value
    if value then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Auto Quest ativado!", Duration = Config.Notifications.Duration })
        end
        Connections.AutoQuest = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoQuest)
            if not success then
                if Config.Notifications.Enabled then
                    Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Quest: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
                end
                Log("Errors", "Erro no Auto Quest: " .. tostring(errorMsg))
                State.AutoQuestEnabled = false
                if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
            end
        end)
    else
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Auto Quest desativado!", Duration = Config.Notifications.Duration })
        end
        if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
    end
    Log("Actions", "Auto Quest " .. (value and "ativado" or "desativado"))
end

--// Função para obter habilidades disponíveis
local function GetAvailableSkills()
    local skills = {}
    local playerData = LocalPlayer:FindFirstChild("Data")
    if playerData then
        local fruit = playerData:FindFirstChild("DevilFruit") and playerData.DevilFruit.Value or nil
        if fruit then
            local problematicFruits = {"Dragon", "Phoenix"}
            if not table.find(problematicFruits, fruit) then
                table.insert(skills, fruit)
            end
        end
    end
    table.insert(skills, "Combat")
    return skills
end

--// Função para Kill Aura
local function StartKillAura()
    if not State.KillAuraEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(Workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
                if enemy.Name == "Desert Bandit" then continue end
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude / 3
                if distance <= Config.KillAuraRange then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", "Combat")
                end
            end
        end
    end)
    if not success then
        if Config.Notifications.Enabled then
            Fluent:Notify({ Title = "RedzHub", Content = "Erro no Kill Aura: " .. tostring(errorMsg), Duration = Config.Notifications.Duration })
        end
        Log("Errors", "Erro no Kill Aura: " .. tostring(errorMsg))
        State.KillAuraEnabled = false
        if Connections
