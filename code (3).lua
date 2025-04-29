--// RedzHub-Inspired Blox Fruits Script with Fluent UI - Enhanced Version
--// Inspirado no estilo RedzHub, com funcionalidades expandidas e correções.
--// Desenvolvido para demonstrar capacidades de scripting em Lua para Blox Fruits.
--// Inclui: ESP (Player, Fruta, Baú, NPC, etc.), Teleport (Ilhas, NPCs, Frutas), Auto Farm (Nível, Maestria, Boss, Eventos), Combate (Kill Aura, Auto Skills), Stats, Misc (Server Hop, Anti-AFK, Noclip), Eventos (Factory, Darkbeard, Sea Events Stubs), Visuais, e mais.
--// Otimizado para Mobile e PC.

--// Serviços Roblox Essenciais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui") -- Para notificações e outras interações UI

--// Variáveis Locais do Jogador
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

--// Função Segura para Carregar Bibliotecas Externas
local function SafeLoadString(url, name, fallbackUrl)
    local success, result
    local function fetch(fetchUrl)
        local fetchSuccess, fetchResult = pcall(function() return game:HttpGet(fetchUrl) end)
        if fetchSuccess then return loadstring(fetchResult)() else warn("Falha ao buscar " .. name .. " de " .. fetchUrl .. ": " .. tostring(fetchResult)) return nil end
    end

    result = fetch(url)
    if not result and fallbackUrl then
        warn("Falha ao carregar " .. name .. " de " .. url .. ". Tentando URL alternativa...")
        result = fetch(fallbackUrl)
    end

    if not result then
        warn("ERRO CRÍTICO: Não foi possível carregar a biblioteca " .. name .. ". O script pode não funcionar.")
        StarterGui:SetCore("SendNotification", { Title = "RedzHub Error", Text = "Falha ao carregar Lib: " .. name, Duration = 15 })
        return nil
    end
    print(name .. " carregado com sucesso.")
    return result
end

--// Carregar Bibliotecas Essenciais (Fluent UI)
local Fluent = SafeLoadString("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", "Fluent", "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua")
local SaveManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", "SaveManager", nil)
local InterfaceManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", "InterfaceManager", nil)

if not Fluent then
    error("Biblioteca Fluent não pôde ser carregada. Script encerrado.")
end
if not SaveManager then warn("SaveManager não carregado. As configurações não serão salvas.") end
if not InterfaceManager then warn("InterfaceManager não carregado.") end

--// Configurações Iniciais da Janela Fluent
local Window = Fluent:CreateWindow({
    Title = "RedzHub Blox Fruits (v2 Enhanced)",
    SubTitle = "Inspired by the best",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500), -- Aumentado ligeiramente para mais opções
    Acrylic = true,
    Theme = "Dark", -- Opções: Dark, Light, Darker, Amoled, Midnight
    MinimizeKey = Enum.KeyCode.RightControl
})

--// Gerenciador de Salvamento (se carregado)
local ConfigIdentifier = "RedzHubBF_Config_v2"
if SaveManager then
    SaveManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ ConfigIdentifier }) -- Ignora salvar a própria config table
    SaveManager:BuildConfigSection(Window) -- Cria a seção de salvar/carregar na aba Settings
end

--// Abas Principais da UI
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10749538488" }), -- Exemplo de Icon ID
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "rbxassetid://10749537896" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "rbxassetid://10749540888" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10749540096" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "rbxassetid://10749537186" }),
    Items = Window:AddTab({ Title = "Items/Fruits", Icon = "rbxassetid://10749539072" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "rbxassetid://10749542117" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://10749541679" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://10749537537" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10749541348" })
}

--// Módulo de Configuração Padrão (Será sobrescrito pelo SaveManager se houver save)
local Config = {
    -- ESP Configs
    ESP = {
        Enabled = false,
        Fruits = false, FruitColor = Color3.fromRGB(255, 80, 80),
        Chests = false, ChestColor = Color3.fromRGB(255, 255, 0),
        Players = false, PlayerColor = Color3.fromRGB(0, 255, 255), PlayerTeamColor = true,
        Enemies = false, EnemyColor = Color3.fromRGB(0, 255, 0),
        Bosses = false, BossColor = Color3.fromRGB(255, 0, 255),
        SeaBeasts = false, SeaBeastColor = Color3.fromRGB(0, 191, 255),
        QuestNPCs = false, QuestNPCColor = Color3.fromRGB(255, 165, 0),
        Items = false, ItemColor = Color3.fromRGB(255, 255, 255),
        Flowers = false, FlowerColor = Color3.fromRGB(255, 105, 180),
        TextSize = 14, Outline = true, MaxDistance = 5000, UpdateInterval = 0.25
    },
    -- AutoFarm Configs
    AutoFarm = {
        LevelEnabled = false,
        MasteryEnabled = false,
        SelectedWeapon = "Melee", -- Melee, Sword, Gun, Fruit
        SelectedMob = "Auto Detect", -- Auto Detect or specific mob name
        BringMobs = false, BringDistance = 50,
        FastAttack = true,
        AutoSkills = false,
        AutoFarmBosses = false, SelectedBoss = "Auto Detect",
        AutoFarmChests = false,
        AutoFarmBones = false, -- Example Material Farm
        AutoFactory = false,
        AutoDarkbeard = false,
        AutoSeaEvents = false, -- Placeholder
        AutoMirageIsland = false, -- Placeholder
        AutoLeviathanHunt = false, -- Placeholder
        AutoRaceV4Trial = false, -- Placeholder
        FarmRange = 5000, MinDistance = 10, TweenSpeed = 150
    },
    -- Combat Configs
    Combat = {
        KillAuraEnabled = false, KillAuraRange = 30, KillAuraTargetPlayers = false, KillAuraTargetBosses = true,
        AutoHaki = false, HakiInterval = 10, BusoHaki = true, KenHaki = false, -- Ken Haki auto is often risky/annoying
        AutoGear = false, TargetGear = "Gear 4", GearInterval = 30, -- Example for specific fruits
        AutoObservationHaki = false -- Placeholder
    },
    -- Teleport Configs (Positions below)
    Teleport = { SafeMode = false }, -- SafeMode might walk instead of instant TP if detected
    -- Items/Fruits Configs
    Items = {
        AutoStoreFruit = false, StoreThreshold = 1000000, -- Store if fruit value > threshold
        FruitSniper = false, SniperWebhookURL = "", SniperMinRarity = "Legendary", -- Legendary, Mythical
        AutoBuyItem = "", -- Item name or "Random Surprise"
        AutoRedeemCodes = false
    },
    -- Stats Configs
    Stats = {
        AutoStats = false,
        Priority = { Melee = 1, Defense = 1, Sword = 0, Gun = 0, Fruit = 0 } -- Priorities add up, points distributed proportionally
    },
    -- Misc Configs
    Misc = {
        ServerHop = false, HopOnFruitSnipe = false, HopIfPlayerNearby = false,
        AntiAFK = true,
        NoClip = false,
        WalkSpeedEnabled = false, WalkSpeedValue = 50,
        JumpPowerEnabled = false, JumpPowerValue = 100,
        RedeemCodes = "", -- Comma-separated list
        AutoSecondSea = false,
        AutoThirdSea = false
    },
    -- Visuals Configs
    Visuals = {
        FOVEnabled = false, FOVValue = 90,
        BrightnessEnabled = false, BrightnessValue = 0.2, -- 0 is default, higher is brighter
        RemoveFog = false,
        FullBright = false,
        NoWater = false
    },
    -- Settings
    Settings = {
        NotificationDuration = 5,
        ExecutorMode = "Standard", -- Standard, Synapse, ScriptWare (might affect specific functions)
        PerformanceMode = false -- Reduces visual fidelity, disables some effects for FPS
    }
}

--// Módulo de Estado Interno (Não salvo, reflete estado de execução)
local State = {
    CurrentTarget = nil,
    CurrentQuest = nil,
    IsTeleporting = false,
    IsNoclipping = false,
    LastHakiCheck = 0,
    LastGearCheck = 0,
    LastAntiAFK = 0,
    ESPObjects = {}, -- {Billboard, Type, ObjectRef, DistanceLabel}
    Connections = {} -- Stores active RunService connections
}

--// Funções Utilitárias
local function Notify(title, text, duration)
    if Fluent and Config.Settings.NotificationDuration > 0 then
        Fluent:Notify({
            Title = title or "RedzHub",
            Content = text or "",
            Duration = duration or Config.Settings.NotificationDuration
        })
    else -- Fallback basic notification
        StarterGui:SetCore("SendNotification", { Title = title or "RedzHub", Text = text or "", Duration = duration or Config.Settings.NotificationDuration })
    end
    print(title .. ": " .. text)
end

local function SafeRun(func, errorHandler)
    local success, err = pcall(func)
    if not success and errorHandler then
        errorHandler(err)
    elseif not success then
        warn("Erro não tratado: " .. tostring(err))
    end
    return success
end

local function GetHumanoidRootPart(player)
    player = player or LocalPlayer
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerLevel()
    -- Tenta múltiplos caminhos comuns para obter o nível
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then return data.Level.Value end
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if stats and stats:FindFirstChild("Level") then return stats.Level.Value end
    -- Adicione mais caminhos se necessário
    return 1 -- Default fallback
end

--// Remote Event Handler (PLACEHOLDER - NEEDS ACTUAL RE NAMES/PATHS)
--// WARNING: These are guesses and WILL likely need updating!
local Remotes = {
    CommF_ = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_"),
    Combat = ReplicatedStorage:FindFirstChild("CombatRemotes") and ReplicatedStorage.CombatRemotes:FindFirstChild("Damage"),
    Stats = ReplicatedStorage:FindFirstChild("StatsRemotes") and ReplicatedStorage.StatsRemotes:FindFirstChild("AddPoint"),
    Quest = ReplicatedStorage:FindFirstChild("QuestRemotes") and ReplicatedStorage.QuestRemotes:FindFirstChild("Quest"),
    Haki = ReplicatedStorage:FindFirstChild("HakiRemotes") and ReplicatedStorage.HakiRemotes:FindFirstChild("ToggleHaki"),
    Store = ReplicatedStorage:FindFirstChild("InventoryRemotes") and ReplicatedStorage.InventoryRemotes:FindFirstChild("StoreFruit"),
    Redeem = ReplicatedStorage:FindFirstChild("SystemRemotes") and ReplicatedStorage.SystemRemotes:FindFirstChild("RedeemCode")
    -- Add more known/discovered remotes here
}

local function InvokeServer(remoteName, ...)
    if Remotes[remoteName] then
        local success, result = pcall(Remotes[remoteName].InvokeServer, Remotes[remoteName], ...)
        if not success then Notify("Remote Error", "Falha ao invocar " .. remoteName .. ": " .. tostring(result), 10) return nil end
        return result
    else
        Notify("Remote Error", "Remote não encontrado: " .. remoteName, 10)
        return nil
    end
end

local function FireServer(remoteName, ...)
     if Remotes[remoteName] then
        local success, result = pcall(Remotes[remoteName].FireServer, Remotes[remoteName], ...)
        if not success then Notify("Remote Error", "Falha ao disparar " .. remoteName .. ": " .. tostring(result), 10) end
    else
        Notify("Remote Error", "Remote não encontrado: " .. remoteName, 10)
    end
end

--// Funções de Teleporte Aprimoradas
local function Teleport(targetPosition)
    if State.IsTeleporting then return end
    local hrp = GetHumanoidRootPart()
    if not hrp then Notify("Teleport Error", "HumanoidRootPart não encontrado.", 5); return end

    State.IsTeleporting = true
    local success = SafeRun(function()
        local startPos = hrp.Position
        local distance = (startPos - targetPosition).Magnitude
        local duration = distance / math.max(1, Config.AutoFarm.TweenSpeed) -- Evitar divisão por zero

        if Config.Teleport.SafeMode and distance > 500 then -- Exemplo de modo seguro para longas distâncias
             Notify("Teleport Info", "Modo seguro ativo, caminhando para o destino...", 3)
             Humanoid:MoveTo(targetPosition)
             Humanoid.MoveToFinished:Wait(duration + 5) -- Adiciona um timeout
        else
             local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
             local tween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0)) }) -- Pequeno offset Y
             tween:Play()
             tween.Completed:Wait(duration + 2) -- Timeout ligeiramente maior que a duração
        end
         -- Verificação final de posição
         task.wait(0.2)
         if (hrp.Position - targetPosition).Magnitude > 50 then -- Se ainda estiver longe após o tween/walk
              hrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0)) -- Força a posição
              Notify("Teleport Info", "Teleporte forçado após falha inicial.", 3)
         end
    end, function(err)
        Notify("Teleport Error", "Falha no teleporte: " .. tostring(err), 8)
    end)
    State.IsTeleporting = false
end

--// Listas de Locais (Expandidas e Corrigidas)
--// Idealmente, carregar de uma fonte externa ou usar métodos in-game para obter posições se possível
local Locations = {
    Islands = {
        ["Starter Pirate"] = Vector3.new(-1100, 20, 3500), ["Starter Marine"] = Vector3.new(-2600, 20, 2000),
        ["Middle Town"] = Vector3.new(-130, 20, 130),
        ["Jungle"] = Vector3.new(-1200, 20, 1500), ["Desert"] = Vector3.new(1000, 20, 4000),
        ["Frozen Village"] = Vector3.new(1000, 20, 6000), ["Colosseum"] = Vector3.new(-1500, 20, 8000),
        ["Prison"] = Vector3.new(5000, 20, 3000), ["Magma Village"] = Vector3.new(-5000, 20, 4000),
        ["Underwater City"] = Vector3.new(4000, -100, -2000), ["Fountain City"] = Vector3.new(5000, 20, -4000),
        ["Skylands (Lower)"] = Vector3.new(-5000, 1000, -2000), ["Skylands (Upper)"] = Vector3.new(-3000, 1200, -1000),
        -- Sea 2
        ["Kingdom of Rose"] = Vector3.new(-2000, 20, -2000), ["Cafe"] = Vector3.new(-380, 20, 300),
        ["Green Zone"] = Vector3.new(-2500, 20, 3000), ["Graveyard"] = Vector3.new(-5000, 20, 500),
        ["Snow Mountain"] = Vector3.new(2000, 20, 4000), ["Hot and Cold"] = Vector3.new(-6000, 20, -3000),
        ["Cursed Ship"] = Vector3.new(9000, 20, 500), ["Ice Castle"] = Vector3.new(5500, 20, -6000),
        ["Dark Arena"] = Vector3.new(-5000, 20, 2000), ["Factory"] = Vector3.new(-2000, 20, -1500),
        -- Sea 3
        ["Port Town"] = Vector3.new(-300, 20, 5000), ["Hydra Island"] = Vector3.new(5000, 20, 6000),
        ["Great Tree"] = Vector3.new(2000, 20, 7000), ["Floating Turtle"] = Vector3.new(-1000, 20, 8000),
        ["Castle on the Sea"] = Vector3.new(-5000, 20, 9000), ["Haunted Castle"] = Vector3.new(-9500, 20, 6000),
        ["Sea of Treats"] = Vector3.new(0, 20, 10000), ["Tiki Outpost"] = Vector3.new(-16000, 20, 8000),
        -- Adicionar mais ilhas aqui...
    },
    NPCs = {
        ["Blox Fruit Dealer (Middle)"] = Vector3.new(-100, 20, 100), ["Gacha (Cafe)"] = Vector3.new(-350, 20, 350),
        ["Awakening Expert (Hot/Cold)"] = Vector3.new(-6000, 20, -2900),
        ["Quest Giver (Starter)"] = Vector3.new(-1050, 20, 3600), -- Exemplo
        ["Quest Giver (Rose)"] = Vector3.new(-2100, 20, -1900),
        ["Quest Giver (Turtle)"] = Vector3.new(-1000, 20, 8100), -- Exemplo
        ["Elite Hunter (Castle Sea)"] = Vector3.new(-5000, 20, 9100),
        ["Haki Trainer (Snow Mtn)"] = Vector3.new(2100, 20, 4100),
        ["Observation Trainer (Upper Sky)"] = Vector3.new(-3000, 1300, -900),
        ["Race V4 Temple (Tree)"] = Vector3.new(2000, 100, 7000), -- Aproximado
        ["Code Redeemer (Rose)"] = Vector3.new(-2050, 20, -1950),
        -- Adicionar mais NPCs...
    },
    Bosses = { -- Adicionar posições específicas de spawn se conhecidas
        ["Bobby (Starter)"] = Locations.Islands["Starter Pirate"], ["Gorilla King (Jungle)"] = Locations.Islands["Jungle"],
        ["Vice Admiral (Prison)"] = Locations.Islands["Prison"], ["Magma Admiral (Magma)"] = Locations.Islands["Magma Village"],
        ["Thunder God (Upper Sky)"] = Locations.Islands["Skylands (Upper)"],
        ["Don Swan (Rose)"] = Locations.Islands["Kingdom of Rose"], ["Fajita (Green Zone)"] = Locations.Islands["Green Zone"],
        ["Darkbeard (Dark Arena)"] = Locations.Islands["Dark Arena"], ["Tide Keeper (Forgotten)"] = Vector3.new(-3000, 20, -5000), -- Aproximado
        ["Rip_Indra (Castle Sea)"] = Locations.Islands["Castle on the Sea"], ["Dough King (Cake Land)"] = Vector3.new(0, 20, 11000), -- Aproximado
        ["Cake Queen (Cake Land)"] = Vector3.new(0, 20, 11000), -- Aproximado
        -- Adicionar mais Bosses...
    }
    -- Adicionar listas para Materiais, Spawns de Frutas específicos, etc., se necessário
}

--// Módulo ESP Aprimorado
local ESPService = { Running = false }
function ESPService:CreateLabel(object, text, color, size, outline, type)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = type .. "ESP_Label"
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 150, 0, 20) -- Ajustado
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = Config.ESP.MaxDistance
    billboard.Enabled = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextSize = size
    textLabel.Font = Enum.Font.SourceSansSemibold
    if outline then
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.5
    end
    textLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.Size = UDim2.new(1, 0, 1, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 15) -- Posição abaixo do nome
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = color
    distanceLabel.TextSize = size - 2 -- Ligeiramente menor
    distanceLabel.Font = Enum.Font.SourceSans
     if outline then
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.TextStrokeTransparency = 0.5
    end
    distanceLabel.Parent = billboard

    billboard.Parent = CoreGui -- Adiciona ao CoreGui para melhor gerenciamento

    return { Billboard = billboard, TextLabel = textLabel, DistanceLabel = distanceLabel, Object = object, Type = type }
end

function ESPService:Update()
    if not Config.ESP.Enabled then return end
    local playerPos = GetHumanoidRootPart() and GetHumanoidRootPart().Position
    if not playerPos then return end

    local newESPObjects = {}

    -- Limpa ESPs antigos ou inválidos
    for obj, espData in pairs(State.ESPObjects) do
        if not obj or not obj.Parent or not espData.Billboard or not espData.Billboard.Parent then
            if espData.Billboard then espData.Billboard:Destroy() end
            State.ESPObjects[obj] = nil
        else
             -- Atualiza distância e visibilidade
             local objPos = (espData.Object:IsA("Model") and espData.Object:FindFirstChild("HumanoidRootPart") and espData.Object.HumanoidRootPart.Position) or (espData.Object:IsA("BasePart") and espData.Object.Position)
             if objPos then
                local distance = math.floor((playerPos - objPos).Magnitude)
                espData.DistanceLabel.Text = distance .. "m"
                espData.Billboard.Enabled = distance <= Config.ESP.MaxDistance
                espData.Billboard.Adornee = (espData.Object:IsA("Model") and espData.Object:FindFirstChild("HumanoidRootPart")) or espData.Object -- Re-adorna se necessário
                newESPObjects[obj] = espData -- Mantém o objeto ESP
            else
                if espData.Billboard then espData.Billboard:Destroy() end -- Remove se não tiver posição
                State.ESPObjects[obj] = nil
            end
        end
    end
    State.ESPObjects = newESPObjects -- Atualiza a tabela principal

    -- Encontra e cria novos ESPs
    for _, entity in pairs(Workspace:GetDescendants()) do
        local hrp = GetHumanoidRootPart()
        if not hrp then continue end -- Skip if player HRP is gone

        local espType = nil
        local espColor = Color3.new(1, 1, 1)
        local espText = entity.Name
        local targetObject = nil

        if Config.ESP.Fruits and entity.Name == "Fruit" and entity:IsA("BasePart") and not State.ESPObjects[entity] then
            espType = "Fruit"
            espColor = Config.ESP.FruitColor
            espText = entity.Parent and entity.Parent:FindFirstChild("FruitName") and entity.Parent.FruitName.Value or "Fruit"
            targetObject = entity
        elseif Config.ESP.Chests and entity.Name:match("Chest") and entity:IsA("BasePart") and not State.ESPObjects[entity] then
            espType = "Chest"
            espColor = Config.ESP.ChestColor
            espText = "Chest"
            targetObject = entity
        elseif Config.ESP.Flowers and entity.Name:match("Flower") and entity:IsA("BasePart") and not State.ESPObjects[entity] then
             espType = "Flower"
             espColor = Config.ESP.FlowerColor
             espText = "Flower"
             targetObject = entity
        elseif Config.ESP.Items and (entity.Name:match("Material") or entity.Name:match("Drop")) and entity:IsA("BasePart") and not State.ESPObjects[entity] then
            espType = "Item"
            espColor = Config.ESP.ItemColor
            espText = entity.Name
            targetObject = entity
        elseif entity:IsA("Model") and entity ~= Character and entity:FindFirstChild("Humanoid") and entity:FindFirstChild("HumanoidRootPart") and not State.ESPObjects[entity] then
            local humanoid = entity.Humanoid
            if humanoid.Health <= 0 then continue end -- Ignora mortos

            local isPlayer = Players:GetPlayerFromCharacter(entity)
            local isBoss = entity:FindFirstChild("IsBoss") or entity.Name:match("Boss") or table.find({"Rip_Indra", "Dough King", "Cake Queen", "Darkbeard", "Tide Keeper"}, entity.Name) -- Adicionar mais bosses
            local isSeaBeast = entity.Name:match("SeaBeast") or entity.Name:match("Leviathan") or entity.Name:match("Terrorshark")
            local isQuestNPC = entity:FindFirstChild("QuestGiver") or (entity.Parent and entity.Parent.Name == "NPCs" and entity.Name:match("Quest"))

            if Config.ESP.Players and isPlayer then
                espType = "Player"
                espColor = Config.ESP.PlayerColor
                espText = entity.Name .. " [Player]"
                targetObject = entity.HumanoidRootPart
                if Config.ESP.PlayerTeamColor and isPlayer.TeamColor then espColor = isPlayer.TeamColor.Color end
            elseif Config.ESP.Bosses and isBoss then
                espType = "Boss"
                espColor = Config.ESP.BossColor
                espText = entity.Name .. " [Boss]"
                targetObject = entity.HumanoidRootPart
            elseif Config.ESP.SeaBeasts and isSeaBeast then
                 espType = "SeaBeast"
                 espColor = Config.ESP.SeaBeastColor
                 espText = entity.Name .. " [Sea Event]"
                 targetObject = entity.HumanoidRootPart
            elseif Config.ESP.QuestNPCs and isQuestNPC then
                espType = "QuestNPC"
                espColor = Config.ESP.QuestNPCColor
                espText = entity.Name .. " [Quest]"
                targetObject = entity.HumanoidRootPart
            elseif Config.ESP.Enemies and not isPlayer and not isBoss and not isSeaBeast and not isQuestNPC then
                espType = "Enemy"
                espColor = Config.ESP.EnemyColor
                local level = entity:FindFirstChild("Level") and entity.Level.Value
                espText = entity.Name .. (level and (" [Lv. " .. level .. "]") or "")
                targetObject = entity.HumanoidRootPart
            end
        end

        if espType and targetObject and not State.ESPObjects[entity] then
            local espData = ESPService:CreateLabel(targetObject, espText, espColor, Config.ESP.TextSize, Config.ESP.Outline, espType)
            if espData then
                 State.ESPObjects[entity] = espData -- Usa o Model como chave para entidades, BasePart para outros
            end
        end
    end
end

function ESPService:Toggle(enabled)
    Config.ESP.Enabled = enabled
    if enabled and not ESPService.Running then
        ESPService.Running = true
        State.Connections.ESPUpdate = RunService.Heartbeat:Connect(function() SafeRun(ESPService.Update) end)
        Notify("ESP", "ESP Global Ativado.", 3)
    elseif not enabled and ESPService.Running then
        ESPService.Running = false
        if State.Connections.ESPUpdate then State.Connections.ESPUpdate:Disconnect() State.Connections.ESPUpdate = nil end
        -- Limpa todos os ESPs existentes
        for obj, espData in pairs(State.ESPObjects) do
            if espData.Billboard then espData.Billboard:Destroy() end
        end
        State.ESPObjects = {}
        Notify("ESP", "ESP Global Desativado.", 3)
    end
end

--// Módulo Auto Farm Aprimorado
local AutoFarmService = { Running = false }
function AutoFarmService:GetBestTarget()
    local playerPos = GetHumanoidRootPart() and GetHumanoidRootPart().Position
    local playerLevel = GetPlayerLevel()
    if not playerPos then return nil end

    local bestTarget = nil
    local minDistance = Config.AutoFarm.FarmRange
    local targetMobName = Config.AutoFarm.SelectedMob == "Auto Detect" and nil or Config.AutoFarm.SelectedMob
    local targetLevel = -1

    -- Auto Detect Mob Logic (Simple: Find highest level mob lower than player level)
    if not targetMobName and Config.AutoFarm.LevelEnabled then
        for name, data in pairs(Locations.Enemies or {}) do -- Assume Locations.Enemies exists
            if data.Level <= playerLevel and data.Level > targetLevel then
                targetLevel = data.Level
                targetMobName = name
            end
        end
         Notify("AutoFarm", "Mob alvo automático: " .. (targetMobName or "Nenhum"), 2)
    end
    if Config.AutoFarm.SelectedMob ~= "Auto Detect" then targetMobName = Config.AutoFarm.SelectedMob end -- Override if specific mob is selected

    if not targetMobName and not Config.AutoFarm.AutoFarmBosses then
         Notify("AutoFarm", "Nenhum mob alvo encontrado.", 3)
         return nil -- No mob to farm
     end

    -- Find nearest instance of the target mob/boss
    for _, entity in pairs(Workspace:GetChildren()) do
        if entity:IsA("Model") and entity ~= Character and entity:FindFirstChild("Humanoid") and entity:FindFirstChild("HumanoidRootPart") then
            local humanoid = entity.Humanoid
            if humanoid.Health > 0 then
                local isCorrectMob = targetMobName and entity.Name == targetMobName
                local isFarmableBoss = Config.AutoFarm.AutoFarmBosses and (Config.AutoFarm.SelectedBoss == "Auto Detect" or entity.Name == Config.AutoFarm.SelectedBoss) and (entity:FindFirstChild("IsBoss") or table.find(Locations.Bosses or {}, entity.Name)) -- Needs Locations.Bosses check

                 if isCorrectMob or isFarmableBoss then
                      local distance = (playerPos - entity.HumanoidRootPart.Position).Magnitude
                      if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                          minDistance = distance
                          bestTarget = entity
                      end
                 end
            end
        end
    end

    return bestTarget
end

function AutoFarmService:AttackTarget(target)
    if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then return end

    local targetHRP = target.HumanoidRootPart
    local playerHRP = GetHumanoidRootPart()
    if not targetHRP or not playerHRP then return end

    -- Teleport/Bring Mobs Logic
    local distance = (playerHRP.Position - targetHRP.Position).Magnitude
    if Config.AutoFarm.BringMobs and distance > Config.AutoFarm.BringDistance then
         SafeRun(function() targetHRP.CFrame = playerHRP.CFrame * CFrame.new(0, 0, -5) end) -- Bring mob in front
         task.wait(0.1)
    elseif distance > 50 then -- Se estiver longe, teleporta para perto
        Teleport(targetHRP.Position + Vector3.new(0, 5, 5)) -- TP ligeiramente acima e à frente
        task.wait(0.5) -- Espera TP
    end

    -- Attack Logic (NEEDS ACTUAL REMOTE INFO)
    local weapon = Config.AutoFarm.SelectedWeapon
    local skillToUse = "Combat" -- Default
    if weapon == "Fruit" then skillToUse = LocalPlayer.Data.DevilFruit.Value or "Combat" -- Needs correct path
    elseif weapon == "Sword" then skillToUse = "SwordSkill" -- Placeholder
    elseif weapon == "Gun" then skillToUse = "GunSkill" -- Placeholder
    end

     -- Simple attack loop (can be improved with skill cycling)
     EquipWeapon(weapon) -- Needs implementation
     if Config.AutoFarm.FastAttack then
          -- Fire remote rapidly (adjust delay as needed, might be detected)
           FireServer("Combat", target, 100) -- Placeholder damage value
           task.wait(0.05)
     else
          InvokeServer("CommF_", "UseAbility", skillToUse, target) -- Placeholder ability usage
          task.wait(0.5) -- Normal delay
     end

     if Config.AutoFarm.AutoSkills then
        -- Cycle through other available skills (Needs logic to get skills and cooldowns)
     end
end

function AutoFarmService:EquipWeapon(weaponType)
     -- Needs logic to find the tool in backpack/hotbar and equip it
     -- Example:
     local tool = nil
     if weaponType == "Melee" then tool = Character:FindFirstChild("Combat") -- Built-in
     elseif weaponType == "Sword" then tool = Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool") -- Simple search
     elseif weaponType == "Gun" then -- Similar search logic
     elseif weaponType == "Fruit" then -- No tool, uses abilities
     end
     if tool and tool:IsA("Tool") and Character.Humanoid then
         Character.Humanoid:EquipTool(tool)
         task.wait(0.2)
     end
 end

function AutoFarmService:Run()
    if not AutoFarmService.Running then return end
    SafeRun(function()
        local target = AutoFarmService:GetBestTarget()
        if target then
            State.CurrentTarget = target
            AutoFarmService:AttackTarget(target)
        else
            State.CurrentTarget = nil
            -- Maybe add logic to move to farm area if no targets found nearby
             task.wait(1) -- Wait longer if no target
        end
    end, function(err)
        Notify("AutoFarm Error", "Erro no loop: " .. tostring(err), 8)
        AutoFarmService:Toggle(false) -- Stop on error
    end)
end

function AutoFarmService:Toggle(enabled)
    local wasRunning = AutoFarmService.Running
    AutoFarmService.Running = enabled

    if enabled and not wasRunning then
        Notify("AutoFarm", "Auto Farm Iniciado.", 3)
        State.Connections.AutoFarmRun = RunService.Heartbeat:Connect(AutoFarmService.Run)
    elseif not enabled and wasRunning then
        Notify("AutoFarm", "Auto Farm Parado.", 3)
        if State.Connections.AutoFarmRun then State.Connections.AutoFarmRun:Disconnect(); State.Connections.AutoFarmRun = nil end
        State.CurrentTarget = nil
    end
    -- Update relevant config toggles
    Config.AutoFarm.LevelEnabled = enabled -- Assume general toggle controls level farm for now
end

--// Outros Módulos (Kill Aura, Auto Stats, NoClip, etc. - Basic Implementations)

-- Kill Aura
local KillAuraService = { Running = false }
function KillAuraService:Run()
    if not Config.Combat.KillAuraEnabled then return end
    local playerPos = GetHumanoidRootPart() and GetHumanoidRootPart().Position
    if not playerPos then return end

    SafeRun(function()
        for _, entity in pairs(Workspace:GetChildren()) do
            if entity:IsA("Model") and entity ~= Character and entity:FindFirstChild("Humanoid") and entity:FindFirstChild("HumanoidRootPart") then
                local humanoid = entity.Humanoid
                local hrp = entity.HumanoidRootPart
                if humanoid.Health > 0 then
                     local distance = (playerPos - hrp.Position).Magnitude
                     if distance <= Config.Combat.KillAuraRange then
                         local isPlayer = Players:GetPlayerFromCharacter(entity)
                         local isBoss = entity:FindFirstChild("IsBoss") or table.find(Locations.Bosses or {}, entity.Name)

                         if (Config.Combat.KillAuraTargetPlayers and isPlayer) or (Config.Combat.KillAuraTargetBosses and isBoss) or (not isPlayer and not isBoss) then
                             -- Prioritize target or just attack nearest in range
                             AutoFarmService:AttackTarget(entity) -- Reuse attack logic
                              task.wait(0.1) -- Small delay between targets
                         end
                     end
                end
            end
        end
    end, function(err)
         Notify("KillAura Error", "Erro: " .. tostring(err), 5)
         KillAuraService:Toggle(false)
    end)
end
function KillAuraService:Toggle(enabled)
     Config.Combat.KillAuraEnabled = enabled
     if enabled and not State.Connections.KillAuraRun then
          Notify("Combat", "Kill Aura Ativado.", 3)
          State.Connections.KillAuraRun = RunService.Heartbeat:Connect(KillAuraService.Run)
     elseif not enabled and State.Connections.KillAuraRun then
          Notify("Combat", "Kill Aura Desativado.", 3)
          State.Connections.KillAuraRun:Disconnect()
          State.Connections.KillAuraRun = nil
     end
end

-- Auto Stats
local AutoStatsService = { Running = false }
function AutoStatsService:AllocatePoints()
    if not Config.Stats.AutoStats then return end
    -- Needs path to available stat points, e.g., LocalPlayer.Data.StatPoints.Value
    local availablePoints = LocalPlayer.Data.StatPoints.Value -- Placeholder path
    if availablePoints > 0 then
         Notify("Stats", "Alocando " .. availablePoints .. " pontos...", 2)
         local totalPriority = 0
         for _, priority in pairs(Config.Stats.Priority) do totalPriority = totalPriority + priority end
         if totalPriority == 0 then return end -- Avoid division by zero

         local pointsAllocated = 0
         for stat, priority in pairs(Config.Stats.Priority) do
             if pointsAllocated >= availablePoints then break end
             local pointsToAllocate = math.floor((priority / totalPriority) * availablePoints)
             if pointsToAllocate > 0 then
                  local success = SafeRun(function()
                      FireServer("Stats", stat, pointsToAllocate) -- Placeholder remote
                  end)
                  if success then pointsAllocated = pointsAllocated + pointsToAllocate; task.wait(0.1) end
             end
         end
         -- Allocate remaining points if any due to rounding
         local remainingPoints = availablePoints - pointsAllocated
          if remainingPoints > 0 then
             -- Allocate to highest priority stat
             local highestPrio = 0; local statToBoost = nil
             for stat, prio in pairs(Config.Stats.Priority) do if prio > highestPrio then highestPrio = prio; statToBoost = stat end end
             if statToBoost then SafeRun(function() FireServer("Stats", statToBoost, remainingPoints) end) end
          end
         Notify("Stats", "Pontos alocados.", 3)
    end
end
function AutoStatsService:Toggle(enabled)
    Config.Stats.AutoStats = enabled
    if enabled and not State.Connections.AutoStatsRun then
        Notify("Stats", "Auto Stats Ativado.", 3)
        -- Check periodically or on level up event if available
        State.Connections.AutoStatsRun = RunService.Heartbeat:Connect(function()
             -- Check every second maybe? Or find a level up event
             if math.floor(os.clock()) % 2 == 0 then -- Simple periodic check
                   SafeRun(AutoStatsService.AllocatePoints)
             end
        end)
    elseif not enabled and State.Connections.AutoStatsRun then
        Notify("Stats", "Auto Stats Desativado.", 3)
        State.Connections.AutoStatsRun:Disconnect()
        State.Connections.AutoStatsRun = nil
    end
end

-- NoClip
function ToggleNoClip(enabled)
    Config.Misc.NoClip = enabled
    State.IsNoclipping = enabled
    if enabled then Notify("Misc", "Noclip Ativado.", 2) else Notify("Misc", "Noclip Desativado.", 2) end
    -- Noclip Loop (Standard method)
    if enabled and not State.Connections.NoClipRun then
        State.Connections.NoClipRun = RunService.Stepped:Connect(function()
            if not State.IsNoclipping then State.Connections.NoClipRun:Disconnect(); State.Connections.NoClipRun = nil; return end
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif not enabled and State.Connections.NoClipRun then
        State.Connections.NoClipRun:Disconnect()
        State.Connections.NoClipRun = nil
        -- Restore collision (might not be perfect)
         for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then -- Keep HRP non-collidable usually
                part.CanCollide = true
            end
        end
    end
end

-- Anti-AFK
function AntiAFK()
    if Config.Misc.AntiAFK and os.clock() - State.LastAntiAFK > 120 then -- Every 2 minutes
         SafeRun(function() VirtualUser:ClickButton1(Vector2.new()) end) -- Simple virtual input
         State.LastAntiAFK = os.clock()
         print("Anti-AFK triggered.")
    end
end
if Config.Misc.AntiAFK then State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK) end -- Start automatically if enabled

-- Server Hop
function ServerHop()
    Notify("Misc", "Iniciando Server Hop...", 5)
    local success = SafeRun(function()
        local servers = TeleportService:GetPlayerInstanceAsync(LocalPlayer.UserId) -- Placeholder, might need different API
        -- Logic to find a suitable server (less players, specific region, etc.) - Complex
        -- Basic: Just join a new server
        TeleportService:Teleport(game.PlaceId) -- Simple rejoin
    end, function(err)
        Notify("Misc", "Falha no Server Hop: " .. tostring(err), 8)
    end)
end

-- Auto Haki
function AutoHaki()
     if Config.Combat.AutoHaki and os.clock() - State.LastHakiCheck > Config.Combat.HakiInterval then
          SafeRun(function()
               if Config.Combat.BusoHaki then FireServer("Haki", "Buso", true) end -- Placeholder remote usage
               task.wait(0.1)
               if Config.Combat.KenHaki then FireServer("Haki", "Ken", true) end -- Placeholder remote usage
          end)
          State.LastHakiCheck = os.clock()
     end
end
if Config.Combat.AutoHaki then State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki) end

--// População da UI (Exemplos - Adicionar todos os toggles e opções)

-- Aba Main
local MainSection = Tabs.Main:AddSection("Informações Gerais")
MainSection:AddLabel("Bem-vindo ao RedzHub Inspired!"):SetFont(Enum.Font.SourceSansBold)
MainSection:AddLabel("Player: " .. LocalPlayer.Name)
MainSection:AddLabel("Level: " .. GetPlayerLevel()):SetFont(Enum.Font.SourceSansItalic)
-- Adicionar mais informações úteis (Beli, Frags, Fruta atual, etc.)

-- Aba AutoFarm
local AF_General = Tabs.AutoFarm:AddSection("Configurações Gerais")
AF_General:AddToggle("AutoFarmToggle", { Text = "Ativar Auto Farm (Geral)", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(value)
    AutoFarmService:Toggle(value) -- Toggle principal controla o serviço
    -- Sincronizar outros toggles se necessário
    Fluent:GetOption("AutoFarm", "LevelFarmToggle").Value = value
    Fluent:GetOption("AutoFarm", "MasteryFarmToggle").Value = value -- Exemplo: Toggle geral ativa ambos
end)
AF_General:AddDropdown("WeaponSelect", { Text = "Arma Preferencial", Default = Config.AutoFarm.SelectedWeapon, Values = {"Melee", "Sword", "Gun", "Fruit"} }):OnChanged(function(value) Config.AutoFarm.SelectedWeapon = value end)
AF_General:AddToggle("BringMobsToggle", { Text = "Trazer Mobs", Default = Config.AutoFarm.BringMobs}):OnChanged(function(value) Config.AutoFarm.BringMobs = value end)
AF_General:AddSlider("BringDistanceSlider", { Text = "Distância Trazer Mobs", Default = Config.AutoFarm.BringDistance, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(value) Config.AutoFarm.BringDistance = value end)
AF_General:AddToggle("FastAttackToggle", { Text = "Ataque Rápido", Default = Config.AutoFarm.FastAttack}):OnChanged(function(value) Config.AutoFarm.FastAttack = value end)
AF_General:AddToggle("AutoSkillsToggle", { Text = "Usar Skills Auto", Default = Config.AutoFarm.AutoSkills}):OnChanged(function(value) Config.AutoFarm.AutoSkills = value end)

local AF_Leveling = Tabs.AutoFarm:AddSection("Farm de Nível/Maestria")
AF_Leveling:AddToggle("LevelFarmToggle", { Text = "Farmar Nível", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(value) Config.AutoFarm.LevelEnabled = value end)
AF_Leveling:AddToggle("MasteryFarmToggle", { Text = "Farmar Maestria", Default = Config.AutoFarm.MasteryEnabled }):OnChanged(function(value) Config.AutoFarm.MasteryEnabled = value end)
-- Popular dropdown com nomes de inimigos (pode ficar longo)
local enemyNames = {"Auto Detect"}
for name, _ in pairs(Locations.Enemies or {}) do table.insert(enemyNames, name) end
AF_Leveling:AddDropdown("MobSelect", { Text = "Mob Específico", Default = Config.AutoFarm.SelectedMob, Values = enemyNames }):OnChanged(function(value) Config.AutoFarm.SelectedMob = value end)

local AF_Bosses = Tabs.AutoFarm:AddSection("Farm de Bosses")
AF_Bosses:AddToggle("BossFarmToggle", { Text = "Farmar Bosses", Default = Config.AutoFarm.AutoFarmBosses}):OnChanged(function(value) Config.AutoFarm.AutoFarmBosses = value end)
local bossNames = {"Auto Detect"}
for name, _ in pairs(Locations.Bosses or {}) do table.insert(bossNames, name) end
AF_Bosses:AddDropdown("BossSelect", { Text = "Boss Específico", Default = Config.AutoFarm.SelectedBoss, Values = bossNames }):OnChanged(function(value) Config.AutoFarm.SelectedBoss = value end)

local AF_Items = Tabs.AutoFarm:AddSection("Farm de Itens/Eventos")
AF_Items:AddToggle("ChestFarmToggle", { Text = "Farmar Baús", Default = Config.AutoFarm.AutoFarmChests}):OnChanged(function(value) Config.AutoFarm.AutoFarmChests = value end)
AF_Items:AddToggle("BoneFarmToggle", { Text = "Farmar Ossos", Default = Config.AutoFarm.AutoFarmBones}):OnChanged(function(value) Config.AutoFarm.AutoFarmBones = value end)
AF_Items:AddToggle("FactoryFarmToggle", { Text = "Farmar Fábrica", Default = Config.AutoFarm.AutoFactory}):OnChanged(function(value) Config.AutoFarm.AutoFactory = value end)
AF_Items:AddToggle("DarkbeardFarmToggle", { Text = "Farmar Darkbeard", Default = Config.AutoFarm.AutoDarkbeard}):OnChanged(function(value) Config.AutoFarm.AutoDarkbeard = value end)
-- Add placeholders for Sea Events, Mirage, Leviathan, Race V4

-- Aba Combat
local Combat_Aura = Tabs.Combat:AddSection("Kill Aura")
Combat_Aura:AddToggle("KillAuraToggle", {Text = "Ativar Kill Aura", Default = Config.Combat.KillAuraEnabled}):OnChanged(KillAuraService.Toggle)
Combat_Aura:AddSlider("KillAuraRangeSlider", { Text = "Alcance", Default = Config.Combat.KillAuraRange, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(value) Config.Combat.KillAuraRange = value end)
Combat_Aura:AddToggle("KillAuraPlayers", { Text = "Atacar Players", Default = Config.Combat.KillAuraTargetPlayers}):OnChanged(function(value) Config.Combat.KillAuraTargetPlayers = value end)
Combat_Aura:AddToggle("KillAuraBosses", { Text = "Atacar Bosses", Default = Config.Combat.KillAuraTargetBosses}):OnChanged(function(value) Config.Combat.KillAuraTargetBosses = value end)

local Combat_Haki = Tabs.Combat:AddSection("Auto Haki/Gear")
Combat_Haki:AddToggle("AutoHakiToggle", { Text = "Auto Haki", Default = Config.Combat.AutoHaki}):OnChanged(function(value) Config.Combat.AutoHaki = value; if value and not State.Connections.AutoHakiRun then State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki) elseif not value and State.Connections.AutoHakiRun then State.Connections.AutoHakiRun:Disconnect(); State.Connections.AutoHakiRun = nil end end)
-- Add toggles for Buso/Ken
Combat_Haki:AddToggle("AutoGearToggle", { Text = "Auto Gear (Experimental)", Default = Config.Combat.AutoGear}):OnChanged(function(value) Config.Combat.AutoGear = value end) -- Needs implementation

-- Aba Teleport
local TP_Islands = Tabs.Teleport:AddSection("Ilhas")
local islandNames = {}
for name, _ in pairs(Locations.Islands) do table.insert(islandNames, name) end
table.sort(islandNames)
TP_Islands:AddDropdown("IslandDropdown", { Text = "Selecionar Ilha", Values = islandNames }):OnChanged(function(value) Teleport(Locations.Islands[value]) end)
TP_Islands:AddButton("Ir para Ilha Selecionada", function() local island = Fluent:GetOption("Teleport", "IslandDropdown").Value; if island and Locations.Islands[island] then Teleport(Locations.Islands[island]) end end)

local TP_NPCs = Tabs.Teleport:AddSection("NPCs")
local npcNames = {}
for name, _ in pairs(Locations.NPCs) do table.insert(npcNames, name) end
table.sort(npcNames)
TP_NPCs:AddDropdown("NPCDropdown", { Text = "Selecionar NPC", Values = npcNames }):OnChanged(function(value) Teleport(Locations.NPCs[value]) end)

local TP_Bosses = Tabs.Teleport:AddSection("Bosses")
local bossTPNames = {}
for name, pos in pairs(Locations.Bosses) do table.insert(bossTPNames, name) end
table.sort(bossTPNames)
TP_Bosses:AddDropdown("BossTPDropdown", { Text = "Selecionar Boss", Values = bossTPNames }):OnChanged(function(value) Teleport(Locations.Bosses[value]) end)

Tabs.Teleport:AddToggle("SafeModeToggle", { Text = "Modo Seguro (Caminhar >500m)", Default = Config.Teleport.SafeMode }):OnChanged(function(value) Config.Teleport.SafeMode = value end)

-- Aba ESP
local ESP_Main = Tabs.ESP:AddSection("Controles Globais")
ESP_Main:AddToggle("ESPToggle", { Text = "Ativar ESP Global", Default = Config.ESP.Enabled }):OnChanged(ESPService.Toggle)
ESP_Main:AddSlider("ESPDistance", { Text = "Distância Máx.", Default = Config.ESP.MaxDistance, Min = 500, Max = 10000, Rounding = 0}):OnChanged(function(value) Config.ESP.MaxDistance = value end)
ESP_Main:AddSlider("ESPTextSize", { Text = "Tam. Texto", Default = Config.ESP.TextSize, Min = 8, Max = 24, Rounding = 0}):OnChanged(function(value) Config.ESP.TextSize = value end)
ESP_Main:AddToggle("ESPOutline", { Text = "Contorno Texto", Default = Config.ESP.Outline}):OnChanged(function(value) Config.ESP.Outline = value end)

local ESP_Filters = Tabs.ESP:AddSection("Filtros ESP")
ESP_Filters:AddToggle("FruitsESP", { Text = "Frutas", Default = Config.ESP.Fruits }):OnChanged(function(value) Config.ESP.Fruits = value end)
ESP_Filters:AddColorpicker("FruitColor", { Title = "Cor Fruta", Default = Config.ESP.FruitColor }):OnChanged(function(value) Config.ESP.FruitColor = value end)
ESP_Filters:AddToggle("ChestsESP", { Text = "Baús", Default = Config.ESP.Chests }):OnChanged(function(value) Config.ESP.Chests = value end)
ESP_Filters:AddColorpicker("ChestColor", { Title = "Cor Baú", Default = Config.ESP.ChestColor }):OnChanged(function(value) Config.ESP.ChestColor = value end)
ESP_Filters:AddToggle("PlayersESP", { Text = "Players", Default = Config.ESP.Players }):OnChanged(function(value) Config.ESP.Players = value end)
ESP_Filters:AddColorpicker("PlayerColor", { Title = "Cor Player", Default = Config.ESP.PlayerColor }):OnChanged(function(value) Config.ESP.PlayerColor = value end)
ESP_Filters:AddToggle("EnemiesESP", { Text = "Inimigos", Default = Config.ESP.Enemies }):OnChanged(function(value) Config.ESP.Enemies = value end)
ESP_Filters:AddColorpicker("EnemyColor", { Title = "Cor Inimigo", Default = Config.ESP.EnemyColor }):OnChanged(function(value) Config.ESP.EnemyColor = value end)
ESP_Filters:AddToggle("BossesESP", { Text = "Bosses", Default = Config.ESP.Bosses }):OnChanged(function(value) Config.ESP.Bosses = value end)
ESP_Filters:AddColorpicker("BossColor", { Title = "Cor Boss", Default = Config.ESP.BossColor }):OnChanged(function(value) Config.ESP.BossColor = value end)
-- Add toggles/color pickers for SeaBeasts, QuestNPCs, Items, Flowers

-- Aba Items/Fruits
local IF_Auto = Tabs.Items:AddSection("Automação")
IF_Auto:AddToggle("AutoStoreFruitToggle", { Text = "Auto Guardar Fruta Rara", Default = Config.Items.AutoStoreFruit}):OnChanged(function(value) Config.Items.AutoStoreFruit = value end) -- Needs implementation loop
IF_Auto:AddInput("StoreThresholdInput", { Text = "Valor Mínimo Guardar", Default = tostring(Config.Items.StoreThreshold), Numeric = true}):OnChanged(function(value) Config.Items.StoreThreshold = tonumber(value) or 1000000 end)

local IF_Sniper = Tabs.Items:AddSection("Fruit Sniper")
IF_Sniper:AddToggle("FruitSniperToggle", { Text = "Ativar Fruit Sniper", Default = Config.Items.FruitSniper}):OnChanged(function(value) Config.Items.FruitSniper = value end) -- Needs implementation loop
IF_Sniper:AddDropdown("SniperRarity", { Text = "Raridade Mínima", Default = Config.Items.SniperMinRarity, Values = {"Common", "Uncommon", "Rare", "Legendary", "Mythical"}}):OnChanged(function(value) Config.Items.SniperMinRarity = value end)
IF_Sniper:AddInput("SniperWebhook", { Text = "Discord Webhook URL", Default = Config.Items.SniperWebhookURL, Placeholder = "Opcional"}):OnChanged(function(value) Config.Items.SniperWebhookURL = value end)

-- Aba Stats
local Stats_Auto = Tabs.Stats:AddSection("Auto Distribuição")
Stats_Auto:AddToggle("AutoStatsToggle", { Text = "Ativar Auto Stats", Default = Config.Stats.AutoStats }):OnChanged(AutoStatsService.Toggle)
Stats_Auto:AddLabel("Prioridades (Soma total é usada para proporção):")
Stats_Auto:AddSlider("PrioMelee", { Text = "Melee", Default = Config.Stats.Priority.Melee, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Melee = v end)
Stats_Auto:AddSlider("PrioDefense", { Text = "Defense", Default = Config.Stats.Priority.Defense, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Defense = v end)
Stats_Auto:AddSlider("PrioSword", { Text = "Sword", Default = Config.Stats.Priority.Sword, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Sword = v end)
Stats_Auto:AddSlider("PrioGun", { Text = "Gun", Default = Config.Stats.Priority.Gun, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Gun = v end)
Stats_Auto:AddSlider("PrioFruit", { Text = "Blox Fruit", Default = Config.Stats.Priority.Fruit, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Fruit = v end)

-- Aba Misc
local Misc_Movement = Tabs.Misc:AddSection("Movimento")
Misc_Movement:AddToggle("NoclipToggle", { Text = "Noclip", Default = Config.Misc.NoClip }):OnChanged(ToggleNoClip)
Misc_Movement:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed", Default = Config.Misc.WalkSpeedEnabled }):OnChanged(function(value) Config.Misc.WalkSpeedEnabled = value; Humanoid.WalkSpeed = value and Config.Misc.WalkSpeedValue or 16 end)
Misc_Movement:AddSlider("WalkSpeedValue", { Text = "Valor WalkSpeed", Default = Config.Misc.WalkSpeedValue, Min = 16, Max = 200, Rounding = 0}):OnChanged(function(value) Config.Misc.WalkSpeedValue = value; if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = value end end)
-- Add JumpPower toggle/slider similarly

local Misc_Server = Tabs.Misc:AddSection("Servidor")
Misc_Server:AddButton("Server Hop", ServerHop)
Misc_Server:AddToggle("HopOnSnipe", { Text = "Hop ao Snipar Fruta", Default = Config.Misc.HopOnFruitSnipe }):OnChanged(function(v) Config.Misc.HopOnFruitSnipe = v end)
Misc_Server:AddToggle("HopOnPlayer", { Text = "Hop se Player Próximo", Default = Config.Misc.HopIfPlayerNearby }):OnChanged(function(v) Config.Misc.HopIfPlayerNearby = v end) -- Needs check loop

local Misc_Other = Tabs.Misc:AddSection("Outros")
Misc_Other:AddToggle("AntiAFKToggle", { Text = "Anti-AFK", Default = Config.Misc.AntiAFK }):OnChanged(function(value) Config.Misc.AntiAFK = value; if value and not State.Connections.AntiAFKRun then State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK) elseif not value and State.Connections.AntiAFKRun then State.Connections.AntiAFKRun:Disconnect(); State.Connections.AntiAFKRun = nil end end)
Misc_Other:AddInput("RedeemCodesInput", { Text = "Códigos (separados por vírgula)", Default = Config.Misc.RedeemCodes, Placeholder = "CODE1,CODE2"}):OnChanged(function(value) Config.Misc.RedeemCodes = value end)
Misc_Other:AddButton("Resgatar Códigos", function()
     local codes = Config.Misc.RedeemCodes:split(",")
     for _, code in pairs(codes) do
          local trimmedCode = code:match("^%s*(.-)%s*$") -- Trim whitespace
          if trimmedCode and #trimmedCode > 0 then
              Notify("Misc", "Tentando resgatar: " .. trimmedCode, 3)
              FireServer("Redeem", trimmedCode) -- Placeholder remote
              task.wait(1.5) -- Delay between redemptions
          end
     end
      Notify("Misc", "Resgate de códigos concluído.", 4)
 end)

-- Aba Visuals
local Vis_Env = Tabs.Visuals:AddSection("Ambiente")
Vis_Env:AddToggle("FovToggle", { Text = "FOV Personalizado", Default = Config.Visuals.FOVEnabled }):OnChanged(function(v) Config.Visuals.FOVEnabled = v; Camera.FieldOfView = v and Config.Visuals.FOVValue or 70 end)
Vis_Env:AddSlider("FovSlider", { Text = "Valor FOV", Default = Config.Visuals.FOVValue, Min = 70, Max = 120, Rounding = 0}):OnChanged(function(v) Config.Visuals.FOVValue = v; if Config.Visuals.FOVEnabled then Camera.FieldOfView = v end end)
Vis_Env:AddToggle("BrightToggle", { Text = "Brilho Personalizado", Default = Config.Visuals.BrightnessEnabled}):OnChanged(function(v) Config.Visuals.BrightnessEnabled = v; Lighting.Brightness = v and Config.Visuals.BrightnessValue or 2; Lighting.Ambient = v and Color3.new(0.5,0.5,0.5) or Color3.new(0,0,0) end) -- Simple brightness adjust
Vis_Env:AddSlider("BrightSlider", {Text="Valor Brilho", Default = Config.Visuals.BrightnessValue, Min = 0, Max = 5, Increment = 0.1}):OnChanged(function(v) Config.Visuals.BrightnessValue = v; if Config.Visuals.BrightnessEnabled then Lighting.Brightness = v end end)
Vis_Env:AddToggle("NoFogToggle", { Text = "Remover Névoa", Default = Config.Visuals.RemoveFog}):OnChanged(function(v) Config.Visuals.RemoveFog = v; Lighting.FogEnd = v and 100000 or 1000; Lighting.FogStart = v and 90000 or 0 end) -- Basic fog removal

-- Aba Settings (Save/Load já adicionado pelo SaveManager se disponível)
local Set_Perf = Tabs.Settings:AddSection("Desempenho e Notificações")
Set_Perf:AddSlider("NotifyDuration", { Text = "Duração Notificação (s)", Default = Config.Settings.NotificationDuration, Min = 0, Max = 15, Rounding = 0}):OnChanged(function(v) Config.Settings.NotificationDuration = v end)
Set_Perf:AddToggle("PerfMode", { Text = "Modo Performance (Gráficos Baixos)", Default = Config.Settings.PerformanceMode}):OnChanged(function(v) Config.Settings.PerformanceMode = v; settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end) -- Basic graphics toggle

-- Carregar Configurações Salvas (se SaveManager estiver ativo)
if SaveManager then
     SaveManager:LoadSave(ConfigIdentifier)
     Notify("Settings", "Configurações carregadas.", 3)
     -- Reaplicar algumas configurações que precisam de ação pós-carregamento
     if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = Config.Misc.WalkSpeedValue end
     if Config.Misc.JumpPowerEnabled then Humanoid.JumpPower = Config.Misc.JumpPowerValue end
     if Config.Visuals.FOVEnabled then Camera.FieldOfView = Config.Visuals.FOVValue end
     -- Add more reapplications if needed
 end

-- Inicializar a UI
Fluent:Notify({ Title = "RedzHub Loaded", Content = "Script inicializado com sucesso!", Duration = 5 })
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BindInput(LocalPlayer:GetMouse()) -- Permite arrastar a janela

-- Adiciona um botão para destruir a UI completamente (para emergências)
Tabs.Settings:AddButton("UNLOAD SCRIPT (DESTROY UI)", function()
    Notify("System", "Descarregando script e UI...", 5)
    -- Desconectar todas as conexões
    for name, conn in pairs(State.Connections) do
        if type(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    State.Connections = {}
    -- Limpar ESP
    ESPService:Toggle(false)
    -- Parar outros serviços
    AutoFarmService:Toggle(false)
    KillAuraService:Toggle(false)
    AutoStatsService:Toggle(false)
    ToggleNoClip(false)
    -- Destruir a janela Fluent
    Window:Destroy()
    -- Limpar referências (ajuda o garbage collector)
    Fluent = nil
    SaveManager = nil
    InterfaceManager = nil
    Window = nil
    Tabs = nil
    Config = nil
    State = nil
    Locations = nil
    -- etc.
    print("RedzHub Script Unloaded.")
end):SetTextColor(Color3.fromRGB(255, 80, 80))

print("RedzHub Inspired Script Loaded.")

--// FIM DO SCRIPT
