-- // Serviços Roblox Essenciais (Mantidos como antes)
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
local CoreGui = game:GetService("CoreGui")

-- // Variáveis Locais do Jogador (Mantidas como antes)
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
-- Adicionado Wait para Humanoid e HRP para garantir que existam
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

-- // Função Segura para Carregar Bibliotecas Externas (Mantida como antes)
local function SafeLoadString(url, name, fallbackUrl)
    local success, result
    local function fetch(fetchUrl)
        local fetchSuccess, fetchResult = pcall(function() return game:HttpGet(fetchUrl) end)
        if fetchSuccess and type(fetchResult) == "string" then -- Verifica se o resultado é uma string
            local loadSuccess, loadResult = pcall(loadstring(fetchResult))
            if loadSuccess then
                 return loadResult()
            else
                 warn("Falha ao executar loadstring para " .. name .. " de " .. fetchUrl .. ": " .. tostring(loadResult))
                 return nil
            end
        else
            warn("Falha ao buscar " .. name .. " de " .. fetchUrl .. ": " .. tostring(fetchResult))
            return nil
        end
    end

    result = fetch(url)
    if not result and fallbackUrl then
        warn("Falha ao carregar " .. name .. " de " .. url .. ". Tentando URL alternativa...")
        result = fetch(fallbackUrl)
    end

    if not result then
        warn("ERRO CRÍTICO: Não foi possível carregar a biblioteca " .. name .. ". O script pode não funcionar.")
        StarterGui:SetCore("SendNotification", { Title = "RedzHub Error", Text = "Falha ao carregar Lib: " .. name, Duration = 15 })
        return nil -- Retorna nil explicitamente
    end
    print(name .. " carregado com sucesso.")
    return result
end


-- // Carregar Bibliotecas Essenciais (Fluent UI)
local Fluent = SafeLoadString("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", "Fluent", "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua")
local SaveManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", "SaveManager", nil)
local InterfaceManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", "InterfaceManager", nil)

-- // VERIFICAÇÃO CRÍTICA DO FLUENT
if not Fluent then
    local errorMsg = "ERRO FATAL: A biblioteca principal 'Fluent' não pôde ser carregada. O script não pode continuar. Verifique a conexão ou a URL da biblioteca."
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub Load Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"}) -- Warning icon
    return -- Interrompe a execução do script aqui
end

-- Aviso se addons falharem, mas continua se Fluent carregou
if not SaveManager then warn("SaveManager não carregado. As configurações não serão salvas.") end
if not InterfaceManager then warn("InterfaceManager não carregado. A janela pode não ser arrastável.") end

-- // Configurações Iniciais da Janela Fluent
local Window
local successCreateWindow, windowResult = pcall(function()
    return Fluent:CreateWindow({
        Title = "RedzHub Blox Fruits (v2.1 Fixed)",
        SubTitle = "Inspired by the best",
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 500),
        Acrylic = true, -- Tente false se tiver problemas gráficos
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl
    })
end)

if not successCreateWindow or not windowResult then
    local errorMsg = "ERRO FATAL: Falha ao criar a janela Fluent: " .. tostring(windowResult)
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub UI Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"})
    return -- Interrompe se a janela não puder ser criada
end

Window = windowResult
print("Janela Fluent criada com sucesso.")

-- // Gerenciador de Salvamento (Aplicado apenas se ambos existirem)
local ConfigIdentifier = "RedzHubBF_Config_v2"
if Fluent and SaveManager then
    local successSM, errorSM = pcall(function()
        SaveManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "FluentSettings" }) -- Ignora salvar a própria config table
        -- A seção de save/load será adicionada na aba Settings mais tarde
    end)
    if not successSM then
        warn("Erro ao configurar SaveManager: "..tostring(errorSM))
        SaveManager = nil -- Desabilita se falhar na configuração
    end
else
    SaveManager = nil -- Garante que está nil se não foi carregado
end

-- // Abas Principais da UI (Usando Ícones Lucide)
local Tabs = {}
local successTabs, errorTabs = pcall(function()
    Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "bot" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }), -- Alterado para 'swords'
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
        ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
        Items = Window:AddTab({ Title = "Items/Fruits", Icon = "gem" }), -- Alterado para 'gem'
        Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart-2" }), -- Alterado para 'bar-chart-2'
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings-2" }), -- Alterado para 'settings-2'
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "image" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
end)

if not successTabs then
     local errorMsg = "ERRO FATAL: Falha ao criar as abas da UI: " .. tostring(errorTabs) .. ". Verifique os nomes dos ícones ou parâmetros das abas."
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub UI Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"})
    Window:Destroy() -- Destroi a janela se as tabs falharam
    return
end

print("Abas da UI criadas com sucesso.")


-- // ============================================================
-- // A PARTIR DAQUI, O RESTANTE DO CÓDIGO (CONFIG, STATE, FUNÇÕES, CRIAÇÃO DE ELEMENTOS UI)
-- // DEVE SER INSERIDO EXATAMENTE COMO NO SCRIPT ANTERIOR.
-- // A ESTRUTURA PRINCIPAL (SERVIÇOS, LOADERS, CRIAÇÃO JANELA/TABS) FOI AJUSTADA ACIMA.
-- // ============================================================

-- // Módulo de Configuração Padrão (Como antes)
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

-- // Módulo de Estado Interno (Como antes)
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

-- // Funções Utilitárias (Notify, SafeRun, Getters - Como antes)
local function Notify(title, text, duration)
    -- Adicionado check se Fluent existe antes de usar
    if Fluent and Config.Settings.NotificationDuration > 0 then
         local success, err = pcall(function()
               Fluent:Notify({
                    Title = title or "RedzHub",
                    Content = text or "",
                    Duration = duration or Config.Settings.NotificationDuration
               })
         end)
          if not success then warn("Falha ao enviar notificação Fluent:", err) end
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
    -- Adicionado check para CharacterAdded:Wait() para garantir que o personagem exista
    local char = player.Character or player.CharacterAdded:Wait()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerLevel()
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then return data.Level.Value end
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if stats and stats:FindFirstChild("Level") then return stats.Level.Value end
    -- Fallback caso os caminhos comuns mudem
    local levelVal = LocalPlayer:FindFirstChild("Level")
    if levelVal then return levelVal.Value end
    return 1 -- Default fallback
end


-- // Remote Event Handler (PLACEHOLDER - NEEDS ACTUAL RE NAMES/PATHS - Como antes)
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


-- // Funções de Teleporte Aprimoradas (Como antes)
local function Teleport(targetPosition)
    if State.IsTeleporting then return end
    local hrp = GetHumanoidRootPart() -- Já usa o getter atualizado
    if not hrp then Notify("Teleport Error", "HumanoidRootPart não encontrado.", 5); return end

    State.IsTeleporting = true
    local success = SafeRun(function()
        local startPos = hrp.Position
        local distance = (startPos - targetPosition).Magnitude
        local duration = distance / math.max(1, Config.AutoFarm.TweenSpeed)

        if Config.Teleport.SafeMode and distance > 500 then
             Notify("Teleport Info", "Modo seguro ativo, caminhando para o destino...", 3)
             Humanoid:MoveTo(targetPosition)
             local finished = Humanoid.MoveToFinished:Wait(duration + 5) -- Adiciona um timeout
             if not finished then
                Notify("Teleport Warning", "MoveTo não finalizou a tempo.", 3)
             end
        else
             local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
             local tween = TweenService:Create(hrp, tweenInfo, { CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0)) })
             tween:Play()
             tween.Completed:Wait(duration + 2)
        end
         task.wait(0.2)
         -- Verifica posição final com tolerância maior
         if (hrp.Position - targetPosition).Magnitude > 75 then
             hrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
             Notify("Teleport Info", "Teleporte forçado após falha inicial/MoveTo.", 3)
         end
    end, function(err)
        Notify("Teleport Error", "Falha no teleporte: " .. tostring(err), 8)
    end)
    State.IsTeleporting = false
end


-- // Listas de Locais (Expandidas e Corrigidas - Como antes)
-- // Idealmente, carregar de uma fonte externa ou usar métodos in-game para obter posições se possível
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
     -- Adicionado: Lista de Inimigos (necessária para Auto Detect Mob)
    Enemies = {
        -- Preencher com dados Nível/Localização como no script original se necessário
        -- Exemplo: ["Bandit"] = { Level = 5, Location = "Starter Pirate"},
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
}

-- // Módulo ESP Aprimorado (Como antes)
local ESPService = { Running = false }
function ESPService:CreateLabel(object, text, color, size, outline, type)
    -- Verifica se o objeto é válido antes de criar
    if not object or not object.Parent then return nil end
    local billboard = Instance.new("BillboardGui")
    -- ... (resto da função CreateLabel como antes) ...
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
    if not Config.ESP.Enabled or not ESPService.Running then return end
    local playerHRP = GetHumanoidRootPart()
    if not playerHRP then return end
    local playerPos = playerHRP.Position

    local currentESPKeys = {} -- Para rastrear objetos atualmente com ESP

    -- Limpa ESPs antigos ou inválidos e atualiza os existentes
    for objKey, espData in pairs(State.ESPObjects) do
        local obj = espData.Object -- Objeto original (Model ou BasePart)
        if not obj or not obj.Parent or not espData.Billboard or not espData.Billboard.Parent or (obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health <= 0) then
            -- Remove se o objeto sumiu, foi destruído, ou o humanoid morreu
            if espData.Billboard then espData.Billboard:Destroy() end
            State.ESPObjects[objKey] = nil
        else
             -- Atualiza distância e visibilidade
             local targetPart = espData.Billboard.Adornee -- O Adornee (HRP ou a própria parte)
             if targetPart and targetPart.Parent then
                 local objPos = targetPart.Position
                 local distance = math.floor((playerPos - objPos).Magnitude)
                 espData.DistanceLabel.Text = distance .. "m"
                 espData.Billboard.Enabled = distance <= Config.ESP.MaxDistance
                 currentESPKeys[objKey] = true -- Marca como ainda ativo
             else -- Se o Adornee sumiu (raro, mas possível)
                 if espData.Billboard then espData.Billboard:Destroy() end
                 State.ESPObjects[objKey] = nil
             end
        end
    end

    -- Encontra e cria novos ESPs
    for _, entity in pairs(Workspace:GetDescendants()) do
        local entityKey = entity -- A chave será o próprio objeto (Model ou BasePart)
        if currentESPKeys[entityKey] or State.ESPObjects[entityKey] then continue end -- Já tem ESP ou foi processado

        local espType = nil
        local espColor = Color3.new(1, 1, 1)
        local espText = entity.Name
        local targetObject = nil -- O objeto que será o Adornee (HRP ou a parte)
        local originalObject = entity -- O objeto original para a chave do State

        -- Lógica de identificação (como antes, mas garantindo que targetObject seja definido)
        if Config.ESP.Fruits and entity.Name == "Fruit" and entity:IsA("BasePart") then
            espType = "Fruit"; espColor = Config.ESP.FruitColor; targetObject = entity
            espText = entity.Parent and entity.Parent:FindFirstChild("FruitName") and entity.Parent.FruitName.Value or "Fruit"
        elseif Config.ESP.Chests and entity.Name:match("Chest") and entity:IsA("BasePart") then
            espType = "Chest"; espColor = Config.ESP.ChestColor; targetObject = entity; espText = "Chest"
        elseif Config.ESP.Flowers and entity.Name:match("Flower") and entity:IsA("BasePart") then
             espType = "Flower"; espColor = Config.ESP.FlowerColor; targetObject = entity; espText = "Flower"
        elseif Config.ESP.Items and (entity.Name:match("Material") or entity.Name:match("Drop")) and entity:IsA("BasePart") then
            espType = "Item"; espColor = Config.ESP.ItemColor; targetObject = entity; espText = entity.Name
        elseif entity:IsA("Model") and entity ~= Character then
            local hum = entity:FindFirstChildOfClass("Humanoid")
            local hrp = entity:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                 local isPlayer = Players:GetPlayerFromCharacter(entity)
                 local isBoss = entity:FindFirstChild("IsBoss") or entity.Name:match("Boss") or table.find({"Rip_Indra", "Dough King", "Cake Queen", "Darkbeard", "Tide Keeper"}, entity.Name)
                 local isSeaBeast = entity.Name:match("SeaBeast") or entity.Name:match("Leviathan") or entity.Name:match("Terrorshark")
                 local isQuestNPC = entity:FindFirstChild("QuestGiver") or (entity.Parent and entity.Parent.Name == "NPCs" and entity.Name:match("Quest"))

                 if Config.ESP.Players and isPlayer then
                      espType = "Player"; espColor = Config.ESP.PlayerColor; targetObject = hrp; espText = entity.Name .. " [Player]"
                      if Config.ESP.PlayerTeamColor and isPlayer.TeamColor then espColor = isPlayer.TeamColor.Color end
                 elseif Config.ESP.Bosses and isBoss then
                      espType = "Boss"; espColor = Config.ESP.BossColor; targetObject = hrp; espText = entity.Name .. " [Boss]"
                 elseif Config.ESP.SeaBeasts and isSeaBeast then
                      espType = "SeaBeast"; espColor = Config.ESP.SeaBeastColor; targetObject = hrp; espText = entity.Name .. " [Sea Event]"
                 elseif Config.ESP.QuestNPCs and isQuestNPC then
                      espType = "QuestNPC"; espColor = Config.ESP.QuestNPCColor; targetObject = hrp; espText = entity.Name .. " [Quest]"
                 elseif Config.ESP.Enemies and not isPlayer and not isBoss and not isSeaBeast and not isQuestNPC then
                      espType = "Enemy"; espColor = Config.ESP.EnemyColor; targetObject = hrp
                      local level = entity:FindFirstChild("Level") and entity.Level.Value
                      espText = entity.Name .. (level and (" [Lv. " .. level .. "]") or "")
                 end
            end
        end

        -- Cria o label se um tipo foi definido e o objeto alvo (adornee) existe
        if espType and targetObject then
             -- Verifica novamente se já não foi criado em outra iteração (embora improvável com a lógica acima)
             if not State.ESPObjects[originalObject] then
                  local espData = ESPService:CreateLabel(targetObject, espText, espColor, Config.ESP.TextSize, Config.ESP.Outline, espType)
                  if espData then
                       State.ESPObjects[originalObject] = espData -- Usa o objeto original como chave
                  end
             end
        end
    end
end

function ESPService:Toggle(enabled)
    Config.ESP.Enabled = enabled
    if enabled and not ESPService.Running then
        ESPService.Running = true
        -- Usar pcall dentro da conexão para evitar que um erro no Update pare o loop
        State.Connections.ESPUpdate = RunService.Heartbeat:Connect(function() SafeRun(ESPService.Update) end)
        Notify("ESP", "ESP Global Ativado.", 3)
    elseif not enabled and ESPService.Running then
        ESPService.Running = false
        if State.Connections.ESPUpdate then State.Connections.ESPUpdate:Disconnect() State.Connections.ESPUpdate = nil end
        -- Limpa todos os ESPs existentes de forma segura
        for objKey, espData in pairs(State.ESPObjects) do
            if espData.Billboard and espData.Billboard.Parent then
                 SafeRun(function() espData.Billboard:Destroy() end)
            end
        end
        State.ESPObjects = {}
        Notify("ESP", "ESP Global Desativado.", 3)
    end
end


-- // Módulo Auto Farm Aprimorado (Como antes)
local AutoFarmService = { Running = false }

-- Adicionada verificação de existência de Locations.Enemies
function AutoFarmService:GetBestTarget()
    local playerPos = GetHumanoidRootPart() and GetHumanoidRootPart().Position
    local playerLevel = GetPlayerLevel()
    if not playerPos then return nil end

    local bestTarget = nil
    local minDistance = Config.AutoFarm.FarmRange
    local targetMobName = Config.AutoFarm.SelectedMob == "Auto Detect" and nil or Config.AutoFarm.SelectedMob
    local targetLevel = -1

    -- Auto Detect Mob Logic
    if not targetMobName and Config.AutoFarm.LevelEnabled and Locations.Enemies then -- Verifica se Locations.Enemies existe
        local highestLevelFound = -1
        local detectedMob = nil
        for name, data in pairs(Locations.Enemies) do
             if data and type(data.Level) == "number" and data.Level <= playerLevel and data.Level > highestLevelFound then
                  highestLevelFound = data.Level
                  detectedMob = name
             end
        end
        if detectedMob then
            targetMobName = detectedMob
            -- Notify("AutoFarm", "Mob alvo automático: " .. targetMobName, 2)
        end
    end
    if Config.AutoFarm.SelectedMob ~= "Auto Detect" then targetMobName = Config.AutoFarm.SelectedMob end

    if not targetMobName and not Config.AutoFarm.AutoFarmBosses then
         -- Notify("AutoFarm", "Nenhum mob alvo encontrado para farmar.", 3) -- Comentado para reduzir spam
         return nil
     end

    -- Find nearest instance
    for _, entity in pairs(Workspace:GetChildren()) do
         -- Otimização: Ignorar entidades não-Modelo ou o próprio jogador rapidamente
        if not entity:IsA("Model") or entity == Character then continue end

        local humanoid = entity:FindFirstChildOfClass("Humanoid")
        local hrp = entity:FindFirstChild("HumanoidRootPart")

        if humanoid and hrp and humanoid.Health > 0 then
            local isCorrectMob = targetMobName and entity.Name == targetMobName
            local isFarmableBoss = Config.AutoFarm.AutoFarmBosses and (entity:FindFirstChild("IsBoss") or (Locations.Bosses and Locations.Bosses[entity.Name])) and (Config.AutoFarm.SelectedBoss == "Auto Detect" or entity.Name == Config.AutoFarm.SelectedBoss)

             if isCorrectMob or isFarmableBoss then
                  local distance = (playerPos - hrp.Position).Magnitude
                  if distance < minDistance and distance > Config.AutoFarm.MinDistance then
                      minDistance = distance
                      bestTarget = entity
                  end
             end
        end
    end

    return bestTarget
end

function AutoFarmService:EquipWeapon(weaponType)
     local tool = nil
     local humanoid = Character:FindFirstChildOfClass("Humanoid")
     if not humanoid then return end -- Precisa do humanoid para equipar

     -- Função auxiliar para procurar no inventário
     local function findTool(nameOrClass)
         local found = Backpack:FindFirstChild(nameOrClass)
         if not found then found = Character:FindFirstChild(nameOrClass) end
         if not found and nameOrClass:match("Class") then -- Se for classe, tenta de novo
             found = Backpack:FindFirstChildOfClass(nameOrClass:gsub("Class", "")) or Character:FindFirstChildOfClass(nameOrClass:gsub("Class", ""))
         end
         return found
     end

     if weaponType == "Melee" then
         -- Verifica se já está equipado ou se existe "Combat" no personagem (pode não ser Tool)
         local currentMelee = Character:FindFirstChild("Combat") or Character:FindFirstChildWhichIsA("Tool", true) -- Verifica se tem alguma tool equipada
         if not currentMelee or currentMelee.Name ~= "Combat" then
             -- Tenta desequipar a tool atual se houver uma
              if currentMelee and currentMelee:IsA("Tool") then humanoid:UnequipTools() task.wait(0.1) end
              -- Melee geralmente não é um 'Tool', então não há o que equipar explicitamente.
              -- Garantir que nenhuma outra arma esteja equipada pode ser o suficiente.
         end
         return -- Melee não precisa equipar item geralmente
     elseif weaponType == "Sword" then
         tool = findTool("Sword") or findTool("ClassTool") -- Tenta achar uma espada ou qualquer tool
     elseif weaponType == "Gun" then
          tool = findTool("Gun") or findTool("ClassTool") -- Tenta achar uma arma ou qualquer tool
     elseif weaponType == "Fruit" then
         -- Desequipar arma atual se houver
          local currentTool = Character:FindFirstChildOfClass("Tool")
          if currentTool then humanoid:UnequipTools() end
         return -- Fruta não equipa item
     end

     if tool and tool:IsA("Tool") and humanoid then
         -- Verifica se já não está equipado
         if tool.Parent ~= Character then
             humanoid:EquipTool(tool)
             task.wait(0.2)
         end
     -- else warn("Não foi possível encontrar/equipar a arma: " .. weaponType) -- Comentado para reduzir spam
     end
 end

function AutoFarmService:AttackTarget(target)
    if not target or not target.Parent then return end -- Verifica se o alvo ainda existe
    local targetHum = target:FindFirstChildOfClass("Humanoid")
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    local playerHRP = GetHumanoidRootPart()

    if not targetHum or targetHum.Health <= 0 or not targetHRP or not playerHRP then return end

    -- Teleport/Bring Mobs Logic
    local distance = (playerHRP.Position - targetHRP.Position).Magnitude
    if Config.AutoFarm.BringMobs and distance > Config.AutoFarm.BringDistance then
         SafeRun(function() targetHRP.CFrame = playerHRP.CFrame * CFrame.new(0, 0, -5) end)
         task.wait(0.1)
         distance = (playerHRP.Position - targetHRP.Position).Magnitude -- Recalcula distância
    end

    -- Teleporta se ainda estiver muito longe após trazer (ou se não trouxe)
    if distance > 60 then -- Aumenta a tolerância antes de teleportar
        Teleport(targetHRP.Position + Vector3.new(math.random(-3,3), 5, math.random(-3,3))) -- TP com pequeno offset aleatório
        task.wait(0.5)
        -- Verifica se o teleporte funcionou razoavelmente
        if (playerHRP.Position - targetHRP.Position).Magnitude > 80 then
             Notify("AutoFarm Warning", "Falha ao se aproximar do alvo.", 3)
             return -- Aborta ataque se não conseguiu chegar perto
        end
    end

    -- Equipar Arma Selecionada
    AutoFarmService:EquipWeapon(Config.AutoFarm.SelectedWeapon)

    -- Attack Logic (PLACEHOLDER REMOTES)
    local weapon = Config.AutoFarm.SelectedWeapon
    local skillToUse = "Combat" -- Default Melee
    local fruitName = LocalPlayer.Data and LocalPlayer.Data:FindFirstChild("DevilFruit") and LocalPlayer.Data.DevilFruit.Value

    if weapon == "Fruit" and fruitName then
        skillToUse = fruitName -- Tenta usar a fruta (precisa de remote correto)
    elseif weapon == "Sword" then
        skillToUse = "SwordSkill" -- Placeholder para ataque de espada
    elseif weapon == "Gun" then
        skillToUse = "GunSkill" -- Placeholder para ataque de arma
    end

    -- Tenta atacar
     SafeRun(function()
         if Config.AutoFarm.FastAttack then
              -- Dispara remote de dano diretamente (MUITO arriscado para detecção)
               FireServer("Combat", target, 100) -- Placeholder damage value
               task.wait(0.05)
         else
              -- Usa a habilidade/ataque via remote padrão (mais seguro)
              InvokeServer("CommF_", "UseAbility", skillToUse, target) -- Placeholder ability usage
              task.wait(0.3) -- Delay normal
         end
     end, function(err)
         Notify("Attack Error", "Falha ao atacar: "..tostring(err), 4)
     end)

     -- Usar outras skills se habilitado
     if Config.AutoFarm.AutoSkills then
        -- Implementar lógica para obter skills (Z, X, C, V, etc.) da arma/fruta atual
        -- e usá-las com cooldowns apropriados. Exemplo básico:
        local skills = {"Z", "X", "C", "V"} -- Placeholder
        for _, key in pairs(skills) do
            SafeRun(function()
                InvokeServer("CommF_", "UseSkill", key) -- Placeholder remote
                task.wait(0.2)
            end)
        end
     end
end

function AutoFarmService:Run()
    if not AutoFarmService.Running then return end
    -- Envolvido em pcall para capturar erros inesperados no loop principal
    local success, err = pcall(function()
        local target = AutoFarmService:GetBestTarget()
        if target and target.Parent and target:FindFirstChildOfClass("Humanoid") and target.Humanoid.Health > 0 then
            State.CurrentTarget = target
            AutoFarmService:AttackTarget(target)
        else
            State.CurrentTarget = nil
            task.wait(0.5) -- Espera um pouco mais se não houver alvo
        end
    end)
    if not success then
        Notify("AutoFarm Error", "Erro crítico no loop: " .. tostring(err), 8)
        AutoFarmService:Toggle(false) -- Desativa em caso de erro sério
    end
end

function AutoFarmService:Toggle(enabled)
    -- Garante que só altere se o estado for diferente
    if AutoFarmService.Running == enabled then return end

    AutoFarmService.Running = enabled

    if enabled then
        Notify("AutoFarm", "Auto Farm Iniciado.", 3)
        -- Garante que a conexão não seja duplicada
        if not State.Connections.AutoFarmRun or not State.Connections.AutoFarmRun.Connected then
             State.Connections.AutoFarmRun = RunService.Heartbeat:Connect(AutoFarmService.Run)
        end
    else
        Notify("AutoFarm", "Auto Farm Parado.", 3)
        if State.Connections.AutoFarmRun and State.Connections.AutoFarmRun.Connected then
             State.Connections.AutoFarmRun:Disconnect()
        end
        State.Connections.AutoFarmRun = nil
        State.CurrentTarget = nil
    end
    -- Atualiza o estado da config para refletir o toggle principal
    Config.AutoFarm.LevelEnabled = enabled
end


-- // Outros Módulos (Kill Aura, Auto Stats, NoClip, etc. - Como antes, com pequenas melhorias)

-- Kill Aura
local KillAuraService = { Running = false }
function KillAuraService:Run()
    if not Config.Combat.KillAuraEnabled or not KillAuraService.Running then return end
    local playerHRP = GetHumanoidRootPart()
    if not playerHRP then return end
    local playerPos = playerHRP.Position

    SafeRun(function()
        for _, entity in pairs(Workspace:GetChildren()) do
             if not entity:IsA("Model") or entity == Character then continue end
             local humanoid = entity:FindFirstChildOfClass("Humanoid")
             local hrp = entity:FindFirstChild("HumanoidRootPart")

            if humanoid and hrp and humanoid.Health > 0 then
                 local distance = (playerPos - hrp.Position).Magnitude
                 if distance <= Config.Combat.KillAuraRange then
                     local isPlayer = Players:GetPlayerFromCharacter(entity)
                     local isBoss = entity:FindFirstChild("IsBoss") or (Locations.Bosses and Locations.Bosses[entity.Name])

                     local shouldTarget = false
                     if Config.Combat.KillAuraTargetPlayers and isPlayer then shouldTarget = true
                     elseif Config.Combat.KillAuraTargetBosses and isBoss then shouldTarget = true
                     elseif not isPlayer and not isBoss then shouldTarget = true -- Target mobs comuns
                     end

                     if shouldTarget then
                         AutoFarmService:AttackTarget(entity) -- Reusa lógica de ataque
                          task.wait(0.1) -- Pequeno delay para não sobrecarregar
                          -- Pode adicionar um 'break' aqui se quiser atacar apenas um por vez
                     end
                 end
            end
        end
    end, function(err)
         Notify("KillAura Error", "Erro: " .. tostring(err), 5)
         KillAuraService:Toggle(false) -- Desativa em erro
    end)
end
function KillAuraService:Toggle(enabled)
     if KillAuraService.Running == enabled then return end
     KillAuraService.Running = enabled
     Config.Combat.KillAuraEnabled = enabled -- Sincroniza config

     if enabled then
          Notify("Combat", "Kill Aura Ativado.", 3)
          if not State.Connections.KillAuraRun or not State.Connections.KillAuraRun.Connected then
              State.Connections.KillAuraRun = RunService.Heartbeat:Connect(KillAuraService.Run)
          end
     else
          Notify("Combat", "Kill Aura Desativado.", 3)
          if State.Connections.KillAuraRun and State.Connections.KillAuraRun.Connected then
              State.Connections.KillAuraRun:Disconnect()
          end
          State.Connections.KillAuraRun = nil
     end
end

-- Auto Stats
local AutoStatsService = { Running = false, Checking = false }
function AutoStatsService:AllocatePoints()
    if AutoStatsService.Checking then return end -- Evita execução simultânea
    AutoStatsService.Checking = true

    local availablePoints = 0
    -- Tenta encontrar pontos de status (caminhos podem variar)
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Points") then availablePoints = data.Points.Value
    elseif LocalPlayer:FindFirstChild("PlayerStats") and LocalPlayer.PlayerStats:FindFirstChild("StatPoints") then availablePoints = LocalPlayer.PlayerStats.StatPoints.Value
    end

    if availablePoints > 0 then
         Notify("Stats", "Alocando " .. availablePoints .. " pontos...", 2)
         local totalPriority = 0
         for _, priority in pairs(Config.Stats.Priority) do totalPriority = totalPriority + priority end

         if totalPriority > 0 then
             local pointsAllocatedTotal = 0
             -- Aloca proporcionalmente
             for stat, priority in pairs(Config.Stats.Priority) do
                 if priority > 0 then
                      local pointsToAllocate = math.floor((priority / totalPriority) * availablePoints)
                      pointsToAllocate = math.min(pointsToAllocate, availablePoints - pointsAllocatedTotal) -- Não aloca mais do que tem

                      if pointsToAllocate > 0 then
                           local success = SafeRun(function() FireServer("Stats", stat, pointsToAllocate) end) -- Placeholder remote
                           if success then pointsAllocatedTotal = pointsAllocatedTotal + pointsToAllocate; task.wait(0.1) else break end -- Para se falhar
                      end
                 end
                  if pointsAllocatedTotal >= availablePoints then break end -- Para se já alocou tudo
             end

             -- Aloca restante (se houver) para a maior prioridade
             local remainingPoints = availablePoints - pointsAllocatedTotal
              if remainingPoints > 0 then
                 local highestPrio = 0; local statToBoost = nil
                 for stat, prio in pairs(Config.Stats.Priority) do if prio > highestPrio then highestPrio = prio; statToBoost = stat end end
                 if statToBoost then SafeRun(function() FireServer("Stats", statToBoost, remainingPoints) end) end
              end
             Notify("Stats", "Pontos alocados.", 3)
         end
    end
    AutoStatsService.Checking = false
end
function AutoStatsService:Toggle(enabled)
    if AutoStatsService.Running == enabled then return end
    AutoStatsService.Running = enabled
    Config.Stats.AutoStats = enabled -- Sincroniza config

    if enabled then
        Notify("Stats", "Auto Stats Ativado.", 3)
        if not State.Connections.AutoStatsRun or not State.Connections.AutoStatsRun.Connected then
             -- Verifica pontos a cada X segundos E tenta alocar uma vez imediatamente
             AutoStatsService:AllocatePoints()
             State.Connections.AutoStatsRun = RunService.Heartbeat:Connect(function()
                  if math.floor(os.clock()) % 5 == 0 then -- Verifica a cada 5 segundos
                        AutoStatsService:AllocatePoints()
                  end
             end)
        end
    else
        Notify("Stats", "Auto Stats Desativado.", 3)
        if State.Connections.AutoStatsRun and State.Connections.AutoStatsRun.Connected then
            State.Connections.AutoStatsRun:Disconnect()
        end
        State.Connections.AutoStatsRun = nil
    end
end

-- NoClip (Melhoria: Usar loop Heartbeat para consistência)
function ToggleNoClip(enabled)
    if State.IsNoclipping == enabled then return end -- Já no estado desejado
    State.IsNoclipping = enabled
    Config.Misc.NoClip = enabled -- Sincroniza config

    if enabled then
        Notify("Misc", "Noclip Ativado.", 2)
        if not State.Connections.NoClipRun or not State.Connections.NoClipRun.Connected then
             State.Connections.NoClipRun = RunService.Heartbeat:Connect(function()
                 -- Re-aplica constantemente enquanto ativo
                 if not State.IsNoclipping then -- Verifica dentro do loop também
                      if State.Connections.NoClipRun then State.Connections.NoClipRun:Disconnect(); State.Connections.NoClipRun = nil end
                      return
                 end
                 for _, part in pairs(Character:GetDescendants()) do
                     if part:IsA("BasePart") and part.CanCollide then
                         part.CanCollide = false
                     end
                 end
             end)
        end
    else
        Notify("Misc", "Noclip Desativado.", 2)
        if State.Connections.NoClipRun and State.Connections.NoClipRun.Connected then
            State.Connections.NoClipRun:Disconnect()
        end
        State.Connections.NoClipRun = nil
        -- Tenta restaurar colisão (pode ser imperfeito)
         SafeRun(function()
             for _, part in pairs(Character:GetDescendants()) do
                 if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                     part.CanCollide = true
                 end
             end
         end)
    end
end

-- Anti-AFK (Como antes)
function AntiAFK()
    if Config.Misc.AntiAFK and os.clock() - State.LastAntiAFK > 120 then
         SafeRun(function() VirtualUser:ClickButton1(Vector2.new()) end)
         State.LastAntiAFK = os.clock()
         print("Anti-AFK triggered.")
    end
end
if Config.Misc.AntiAFK then
     if not State.Connections.AntiAFKRun or not State.Connections.AntiAFKRun.Connected then
          State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK)
     end
end

-- Server Hop (Como antes, mas com verificação de serviço)
function ServerHop()
    Notify("Misc", "Iniciando Server Hop...", 5)
    if not game:IsLoaded() then Notify("Server Hop", "Aguarde o jogo carregar completamente.", 4); return end

    local success = SafeRun(function()
        local TS = game:GetService("TeleportService") -- Obtem o serviço aqui
        -- Limpa lista de servidores antigos antes de tentar ir para um novo
        TS:LeaveServer()
        task.wait(1) -- Pequena espera
        -- Tenta ir para um servidor público qualquer do mesmo jogo
        TS:Teleport(game.PlaceId)
    end, function(err)
        Notify("Misc", "Falha no Server Hop: " .. tostring(err), 8)
    end)
end

-- Auto Haki (Como antes, com pequena melhoria)
function AutoHaki()
     if Config.Combat.AutoHaki and os.clock() - State.LastHakiCheck > Config.Combat.HakiInterval then
          SafeRun(function()
               if Config.Combat.BusoHaki then FireServer("Haki", "Buso", true) end
               task.wait(0.1)
               if Config.Combat.KenHaki then FireServer("Haki", "Ken", true) end
          end)
          State.LastHakiCheck = os.clock()
     end
end
if Config.Combat.AutoHaki then
    if not State.Connections.AutoHakiRun or not State.Connections.AutoHakiRun.Connected then
        State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki)
    end
end


-- // ============================================================
-- // POPULAÇÃO DA UI (Como antes, mas verificando se Tabs existe)
-- // ============================================================
if Tabs and Tabs.Main then -- Verifica se as tabs foram criadas com sucesso
    -- Aba Main
    local MainSection = Tabs.Main:AddSection("Informações Gerais")
    MainSection:AddLabel("Bem-vindo ao RedzHub Inspired!"):SetFont(Enum.Font.SourceSansBold)
    MainSection:AddLabel("Player: " .. (LocalPlayer and LocalPlayer.Name or "N/A"))
    -- Adiciona função para atualizar label do level dinamicamente
    local levelLabel = MainSection:AddLabel("Level: " .. GetPlayerLevel())
    if State and State.Connections then -- Adiciona conexão para atualizar level
        State.Connections.LevelUpdater = RunService.Heartbeat:Connect(function()
            if math.floor(os.clock()) % 10 == 0 then -- Atualiza a cada 10s
                levelLabel:SetText("Level: ".. GetPlayerLevel())
            end
        end)
    end

    -- Aba AutoFarm
    local AF_General = Tabs.AutoFarm:AddSection("Configurações Gerais")
    AF_General:AddToggle("AutoFarmToggle", { Text = "Ativar Auto Farm (Geral)", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(value)
        AutoFarmService:Toggle(value)
        -- Tenta atualizar outros toggles se eles existirem
        pcall(function() Fluent:GetOption("AutoFarm", "LevelFarmToggle").Value = value end)
        pcall(function() Fluent:GetOption("AutoFarm", "MasteryFarmToggle").Value = value end)
    end)
    AF_General:AddDropdown("WeaponSelect", { Text = "Arma Preferencial", Default = Config.AutoFarm.SelectedWeapon, Values = {"Melee", "Sword", "Gun", "Fruit"} }):OnChanged(function(value) Config.AutoFarm.SelectedWeapon = value end)
    AF_General:AddToggle("BringMobsToggle", { Text = "Trazer Mobs", Default = Config.AutoFarm.BringMobs}):OnChanged(function(value) Config.AutoFarm.BringMobs = value end)
    AF_General:AddSlider("BringDistanceSlider", { Text = "Distância Trazer Mobs", Default = Config.AutoFarm.BringDistance, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(value) Config.AutoFarm.BringDistance = value end)
    AF_General:AddToggle("FastAttackToggle", { Text = "Ataque Rápido (RISCADO)", Default = Config.AutoFarm.FastAttack}):OnChanged(function(value) Config.AutoFarm.FastAttack = value end)
    AF_General:AddToggle("AutoSkillsToggle", { Text = "Usar Skills Auto (WIP)", Default = Config.AutoFarm.AutoSkills}):OnChanged(function(value) Config.AutoFarm.AutoSkills = value end)

    local AF_Leveling = Tabs.AutoFarm:AddSection("Farm de Nível/Maestria")
    AF_Leveling:AddToggle("LevelFarmToggle", { Text = "Farmar Nível", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(value) Config.AutoFarm.LevelEnabled = value; if not value and not Config.AutoFarm.MasteryEnabled then AutoFarmService:Toggle(false) elseif value then AutoFarmService:Toggle(true) end end) -- Controla o toggle principal
    AF_Leveling:AddToggle("MasteryFarmToggle", { Text = "Farmar Maestria", Default = Config.AutoFarm.MasteryEnabled }):OnChanged(function(value) Config.AutoFarm.MasteryEnabled = value; if not value and not Config.AutoFarm.LevelEnabled then AutoFarmService:Toggle(false) elseif value then AutoFarmService:Toggle(true) end end) -- Controla o toggle principal
    local enemyNames = {"Auto Detect"}
    if Locations.Enemies then for name, _ in pairs(Locations.Enemies) do table.insert(enemyNames, name) end end
    table.sort(enemyNames)
    AF_Leveling:AddDropdown("MobSelect", { Text = "Mob Específico", Default = Config.AutoFarm.SelectedMob, Values = enemyNames }):OnChanged(function(value) Config.AutoFarm.SelectedMob = value end)

    local AF_Bosses = Tabs.AutoFarm:AddSection("Farm de Bosses")
    AF_Bosses:AddToggle("BossFarmToggle", { Text = "Farmar Bosses", Default = Config.AutoFarm.AutoFarmBosses}):OnChanged(function(value) Config.AutoFarm.AutoFarmBosses = value end)
    local bossNames = {"Auto Detect"}
    if Locations.Bosses then for name, _ in pairs(Locations.Bosses) do table.insert(bossNames, name) end end
    table.sort(bossNames)
    AF_Bosses:AddDropdown("BossSelect", { Text = "Boss Específico", Default = Config.AutoFarm.SelectedBoss, Values = bossNames }):OnChanged(function(value) Config.AutoFarm.SelectedBoss = value end)

    local AF_Items = Tabs.AutoFarm:AddSection("Farm de Itens/Eventos")
    AF_Items:AddToggle("ChestFarmToggle", { Text = "Farmar Baús", Default = Config.AutoFarm.AutoFarmChests}):OnChanged(function(value) Config.AutoFarm.AutoFarmChests = value end)
    AF_Items:AddToggle("BoneFarmToggle", { Text = "Farmar Ossos", Default = Config.AutoFarm.AutoFarmBones}):OnChanged(function(value) Config.AutoFarm.AutoFarmBones = value end)
    AF_Items:AddToggle("FactoryFarmToggle", { Text = "Farmar Fábrica", Default = Config.AutoFarm.AutoFactory}):OnChanged(function(value) Config.AutoFarm.AutoFactory = value end)
    AF_Items:AddToggle("DarkbeardFarmToggle", { Text = "Farmar Darkbeard", Default = Config.AutoFarm.AutoDarkbeard}):OnChanged(function(value) Config.AutoFarm.AutoDarkbeard = value end)

    -- Aba Combat
    local Combat_Aura = Tabs.Combat:AddSection("Kill Aura")
    Combat_Aura:AddToggle("KillAuraToggle", {Text = "Ativar Kill Aura", Default = Config.Combat.KillAuraEnabled}):OnChanged(KillAuraService.Toggle)
    Combat_Aura:AddSlider("KillAuraRangeSlider", { Text = "Alcance", Default = Config.Combat.KillAuraRange, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(value) Config.Combat.KillAuraRange = value end)
    Combat_Aura:AddToggle("KillAuraPlayers", { Text = "Atacar Players", Default = Config.Combat.KillAuraTargetPlayers}):OnChanged(function(value) Config.Combat.KillAuraTargetPlayers = value end)
    Combat_Aura:AddToggle("KillAuraBosses", { Text = "Atacar Bosses", Default = Config.Combat.KillAuraTargetBosses}):OnChanged(function(value) Config.Combat.KillAuraTargetBosses = value end)

    local Combat_Haki = Tabs.Combat:AddSection("Auto Haki/Gear")
    Combat_Haki:AddToggle("AutoHakiToggle", { Text = "Auto Haki", Default = Config.Combat.AutoHaki}):OnChanged(function(value) Config.Combat.AutoHaki = value; if value and (not State.Connections.AutoHakiRun or not State.Connections.AutoHakiRun.Connected) then State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki) elseif not value and State.Connections.AutoHakiRun and State.Connections.AutoHakiRun.Connected then State.Connections.AutoHakiRun:Disconnect(); State.Connections.AutoHakiRun = nil end end)
    Combat_Haki:AddToggle("BusoHaki", {Text="Buso Haki Auto", Default = Config.Combat.BusoHaki}):OnChanged(function(v) Config.Combat.BusoHaki = v end)
    Combat_Haki:AddToggle("KenHaki", {Text="Ken Haki Auto", Default = Config.Combat.KenHaki}):OnChanged(function(v) Config.Combat.KenHaki = v end)
    Combat_Haki:AddToggle("AutoGearToggle", { Text = "Auto Gear (WIP)", Default = Config.Combat.AutoGear}):OnChanged(function(value) Config.Combat.AutoGear = value end) -- Needs implementation

    -- Aba Teleport
    local TP_Islands = Tabs.Teleport:AddSection("Ilhas")
    local islandNames = {}
    if Locations.Islands then for name, _ in pairs(Locations.Islands) do table.insert(islandNames, name) end end
    table.sort(islandNames)
    local islandDropdown = TP_Islands:AddDropdown("IslandDropdown", { Text = "Selecionar Ilha", Values = islandNames })
    TP_Islands:AddButton("Ir para Ilha Selecionada", function()
        local islandName = islandDropdown.Value
        if islandName and Locations.Islands[islandName] then Teleport(Locations.Islands[islandName]) end
    end)

    local TP_NPCs = Tabs.Teleport:AddSection("NPCs")
    local npcNames = {}
    if Locations.NPCs then for name, _ in pairs(Locations.NPCs) do table.insert(npcNames, name) end end
    table.sort(npcNames)
    local npcDropdown = TP_NPCs:AddDropdown("NPCDropdown", { Text = "Selecionar NPC", Values = npcNames })
    TP_NPCs:AddButton("Ir para NPC Selecionado", function()
        local npcName = npcDropdown.Value
        if npcName and Locations.NPCs[npcName] then Teleport(Locations.NPCs[npcName]) end
    end)

    local TP_Bosses = Tabs.Teleport:AddSection("Bosses")
    local bossTPNames = {}
    if Locations.Bosses then for name, pos in pairs(Locations.Bosses) do table.insert(bossTPNames, name) end end
    table.sort(bossTPNames)
    local bossTPDropdown = TP_Bosses:AddDropdown("BossTPDropdown", { Text = "Selecionar Boss", Values = bossTPNames })
    TP_Bosses:AddButton("Ir para Boss Selecionado", function()
         local bossName = bossTPDropdown.Value
         if bossName and Locations.Bosses[bossName] then Teleport(Locations.Bosses[bossName]) end
    end)

    Tabs.Teleport:AddToggle("SafeModeToggle", { Text = "Modo Seguro (Caminhar >500 studs)", Default = Config.Teleport.SafeMode }):OnChanged(function(value) Config.Teleport.SafeMode = value end)

    -- Aba ESP
    local ESP_Main = Tabs.ESP:AddSection("Controles Globais")
    ESP_Main:AddToggle("ESPToggle", { Text = "Ativar ESP Global", Default = Config.ESP.Enabled }):OnChanged(ESPService.Toggle)
    ESP_Main:AddSlider("ESPDistance", { Text = "Distância Máx.", Default = Config.ESP.MaxDistance, Min = 500, Max = 10000, Rounding = 0}):OnChanged(function(value) Config.ESP.MaxDistance = value end)
    ESP_Main:AddSlider("ESPTextSize", { Text = "Tam. Texto", Default = Config.ESP.TextSize, Min = 8, Max = 24, Rounding = 0}):OnChanged(function(value) Config.ESP.TextSize = value end)
    ESP_Main:AddToggle("ESPOutline", { Text = "Contorno Texto", Default = Config.ESP.Outline}):OnChanged(function(value) Config.ESP.Outline = value end)

    local ESP_Filters = Tabs.ESP:AddSection("Filtros ESP")
    local function addEspFilter(id, text, configKey, colorConfigKey)
         ESP_Filters:AddToggle(id, { Text = text, Default = Config.ESP[configKey] }):OnChanged(function(value) Config.ESP[configKey] = value; if not value then ESPService:ClearType(text) end end) -- Passa o 'text' como tipo
         ESP_Filters:AddColorpicker(id.."Color", { Title = "Cor "..text, Default = Config.ESP[colorConfigKey] }):OnChanged(function(value) Config.ESP[colorConfigKey] = value end)
    end

    addEspFilter("FruitsESP", "Fruits", "Fruits", "FruitColor")
    addEspFilter("ChestsESP", "Chests", "Chests", "ChestColor")
    addEspFilter("PlayersESP", "Players", "Players", "PlayerColor")
    addEspFilter("EnemiesESP", "Enemies", "Enemies", "EnemyColor")
    addEspFilter("BossesESP", "Bosses", "Bosses", "BossColor")
    addEspFilter("SeaBeastsESP", "SeaBeasts", "SeaBeasts", "SeaBeastColor")
    addEspFilter("QuestNPCsESP", "QuestNPCs", "QuestNPCs", "QuestNPCColor")
    addEspFilter("ItemsESP", "Items", "Items", "ItemColor")
    addEspFilter("FlowersESP", "Flowers", "Flowers", "FlowerColor")

    -- Adiciona função para limpar ESP de um tipo específico
    function ESPService:ClearType(type)
        local typeKey = type:match("^(%u%l*)") -- Extrai o tipo (ex: "Fruits" de "FruitsESP")
        if not typeKey then return end
        for objKey, espData in pairs(State.ESPObjects) do
            if espData.Type == typeKey then
                if espData.Billboard and espData.Billboard.Parent then espData.Billboard:Destroy() end
                State.ESPObjects[objKey] = nil
            end
        end
    end


    -- Aba Items/Fruits
    local IF_Auto = Tabs.Items:AddSection("Automação")
    IF_Auto:AddToggle("AutoStoreFruitToggle", { Text = "Auto Guardar Fruta Rara (WIP)", Default = Config.Items.AutoStoreFruit}):OnChanged(function(value) Config.Items.AutoStoreFruit = value end) -- Needs implementation
    IF_Auto:AddInput("StoreThresholdInput", { Text = "Valor Mínimo Guardar", Default = tostring(Config.Items.StoreThreshold), Numeric = true}):OnChanged(function(value) Config.Items.StoreThreshold = tonumber(value) or 1000000 end)

    local IF_Sniper = Tabs.Items:AddSection("Fruit Sniper (WIP)")
    IF_Sniper:AddToggle("FruitSniperToggle", { Text = "Ativar Fruit Sniper", Default = Config.Items.FruitSniper}):OnChanged(function(value) Config.Items.FruitSniper = value end) -- Needs implementation
    IF_Sniper:AddDropdown("SniperRarity", { Text = "Raridade Mínima", Default = Config.Items.SniperMinRarity, Values = {"Common", "Uncommon", "Rare", "Legendary", "Mythical"}}):OnChanged(function(value) Config.Items.SniperMinRarity = value end)
    IF_Sniper:AddInput("SniperWebhook", { Text = "Discord Webhook URL", Default = Config.Items.SniperWebhookURL, Placeholder = "Opcional"}):OnChanged(function(value) Config.Items.SniperWebhookURL = value end)

    -- Aba Stats
    local Stats_Auto = Tabs.Stats:AddSection("Auto Distribuição")
    Stats_Auto:AddToggle("AutoStatsToggle", { Text = "Ativar Auto Stats", Default = Config.Stats.AutoStats }):OnChanged(AutoStatsService.Toggle)
    Stats_Auto:AddLabel("Prioridades (Soma usada para proporção):")
    Stats_Auto:AddSlider("PrioMelee", { Text = "Melee", Default = Config.Stats.Priority.Melee, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Melee = v end)
    Stats_Auto:AddSlider("PrioDefense", { Text = "Defense", Default = Config.Stats.Priority.Defense, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Defense = v end)
    Stats_Auto:AddSlider("PrioSword", { Text = "Sword", Default = Config.Stats.Priority.Sword, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Sword = v end)
    Stats_Auto:AddSlider("PrioGun", { Text = "Gun", Default = Config.Stats.Priority.Gun, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Gun = v end)
    Stats_Auto:AddSlider("PrioFruit", { Text = "Blox Fruit", Default = Config.Stats.Priority.Fruit, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Fruit = v end)
    Stats_Auto:AddButton("Alocar Pontos Agora", AutoStatsService.AllocatePoints)

    -- Aba Misc
    local Misc_Movement = Tabs.Misc:AddSection("Movimento")
    Misc_Movement:AddToggle("NoclipToggle", { Text = "Noclip", Default = Config.Misc.NoClip }):OnChanged(ToggleNoClip)
    Misc_Movement:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed", Default = Config.Misc.WalkSpeedEnabled }):OnChanged(function(value) Config.Misc.WalkSpeedEnabled = value; Humanoid.WalkSpeed = value and Config.Misc.WalkSpeedValue or 16 end)
    Misc_Movement:AddSlider("WalkSpeedValue", { Text = "Valor WalkSpeed", Default = Config.Misc.WalkSpeedValue, Min = 16, Max = 200, Rounding = 0}):OnChanged(function(value) Config.Misc.WalkSpeedValue = value; if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = value end end)
    -- Adicionar JumpPower similarmente
    Misc_Movement:AddToggle("JumpPowerToggle", { Text = "JumpPower", Default = Config.Misc.JumpPowerEnabled}):OnChanged(function(value) Config.Misc.JumpPowerEnabled = value; Humanoid.JumpPower = value and Config.Misc.JumpPowerValue or 50 end)
    Misc_Movement:AddSlider("JumpPowerValue", { Text = "Valor JumpPower", Default = Config.Misc.JumpPowerValue, Min = 50, Max = 300, Rounding = 0}):OnChanged(function(value) Config.Misc.JumpPowerValue = value; if Config.Misc.JumpPowerEnabled then Humanoid.JumpPower = value end end)


    local Misc_Server = Tabs.Misc:AddSection("Servidor")
    Misc_Server:AddButton("Server Hop", ServerHop)
    Misc_Server:AddToggle("HopOnSnipe", { Text = "Hop ao Snipar Fruta (WIP)", Default = Config.Misc.HopOnFruitSnipe }):OnChanged(function(v) Config.Misc.HopOnFruitSnipe = v end)
    Misc_Server:AddToggle("HopOnPlayer", { Text = "Hop se Player Próximo (WIP)", Default = Config.Misc.HopIfPlayerNearby }):OnChanged(function(v) Config.Misc.HopIfPlayerNearby = v end)

    local Misc_Other = Tabs.Misc:AddSection("Outros")
    Misc_Other:AddToggle("AntiAFKToggle", { Text = "Anti-AFK", Default = Config.Misc.AntiAFK }):OnChanged(function(value) Config.Misc.AntiAFK = value; if value and (not State.Connections.AntiAFKRun or not State.Connections.AntiAFKRun.Connected) then State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK) elseif not value and State.Connections.AntiAFKRun and State.Connections.AntiAFKRun.Connected then State.Connections.AntiAFKRun:Disconnect(); State.Connections.AntiAFKRun = nil end end)
    local redeemInput = Misc_Other:AddInput("RedeemCodesInput", { Text = "Códigos (separados por vírgula)", Default = Config.Misc.RedeemCodes, Placeholder = "CODE1,CODE2"})
    Misc_Other:AddButton("Resgatar Códigos", function()
         local codesRaw = redeemInput.Value
         if not codesRaw or codesRaw == "" then Notify("Redeem", "Nenhum código inserido.", 3); return end
         local codes = codesRaw:split(",")
         Notify("Redeem", "Iniciando resgate de " .. #codes .. " códigos...", 3)
         for i, code in ipairs(codes) do
              local trimmedCode = code:match("^%s*(.-)%s*$")
              if trimmedCode and #trimmedCode > 0 then
                  Notify("Redeem", "Tentando resgatar: " .. trimmedCode .. " ("..i.."/"..#codes..")", 3)
                  FireServer("Redeem", trimmedCode) -- Placeholder remote
                  task.wait(1.5) -- Delay
              end
         end
          Notify("Redeem", "Resgate de códigos concluído.", 4)
     end)

    -- Aba Visuals
    local Vis_Env = Tabs.Visuals:AddSection("Ambiente")
    Vis_Env:AddToggle("FovToggle", { Text = "FOV Personalizado", Default = Config.Visuals.FOVEnabled }):OnChanged(function(v) Config.Visuals.FOVEnabled = v; Camera.FieldOfView = v and Config.Visuals.FOVValue or 70 end)
    Vis_Env:AddSlider("FovSlider", { Text = "Valor FOV", Default = Config.Visuals.FOVValue, Min = 70, Max = 120, Rounding = 0}):OnChanged(function(v) Config.Visuals.FOVValue = v; if Config.Visuals.FOVEnabled then Camera.FieldOfView = v end end)
    Vis_Env:AddToggle("BrightToggle", { Text = "Brilho Personalizado", Default = Config.Visuals.BrightnessEnabled}):OnChanged(function(v) Config.Visuals.BrightnessEnabled = v; Lighting.Brightness = v and Config.Visuals.BrightnessValue or 2; Lighting.Ambient = v and Color3.new(0.3,0.3,0.3) or Color3.new(0,0,0); Lighting.OutdoorAmbient = v and Color3.new(0.4,0.4,0.4) or Color3.new(0.5,0.5,0.5) end)
    Vis_Env:AddSlider("BrightSlider", {Text="Valor Brilho", Default = Config.Visuals.BrightnessValue, Min = 0, Max = 5, Increment = 0.1}):OnChanged(function(v) Config.Visuals.BrightnessValue = v; if Config.Visuals.BrightnessEnabled then Lighting.Brightness = v end end)
    Vis_Env:AddToggle("NoFogToggle", { Text = "Remover Névoa", Default = Config.Visuals.RemoveFog}):OnChanged(function(v) Config.Visuals.RemoveFog = v; Lighting.FogEnd = v and 100000 or 1000; Lighting.FogStart = v and 90000 or 0 end)

    -- Aba Settings
    local Set_SaveLoad = Tabs.Settings:AddSection("Configurações Salvas")
    if SaveManager then -- Adiciona botões de salvar/carregar apenas se o SaveManager carregou
        Set_SaveLoad:AddButton("Salvar Configurações", function() SaveManager:Save(ConfigIdentifier, Config) Notify("Settings", "Configurações salvas!", 3) end)
        Set_SaveLoad:AddButton("Carregar Configurações", function()
            local loadedConfig = SaveManager:Load(ConfigIdentifier)
            if loadedConfig then
                 Config = loadedConfig -- Sobrescreve a config atual
                 Notify("Settings", "Configurações carregadas!", 3)
                 -- Reaplica configurações que precisam de ação
                 Window:SetTheme(Config.FluentSettings and Config.FluentSettings.Theme or "Dark") -- Exemplo: Recarregar tema salvo
                 -- Adicionar reaplicação de WalkSpeed, FOV, etc.
                 if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = Config.Misc.WalkSpeedValue end
                 if Config.Misc.JumpPowerEnabled then Humanoid.JumpPower = Config.Misc.JumpPowerValue end
                 if Config.Visuals.FOVEnabled then Camera.FieldOfView = Config.Visuals.FOVValue end
                 -- TODO: Atualizar valores dos Toggles/Sliders na UI para refletir o carregado
            else
                 Notify("Settings", "Nenhuma configuração salva encontrada.", 4)
            end
        end)
    else
        Set_SaveLoad:AddLabel("SaveManager não carregado."):SetColor(Color3.fromRGB(255,100,100))
    end

    local Set_Perf = Tabs.Settings:AddSection("Desempenho e Notificações")
    Set_Perf:AddSlider("NotifyDuration", { Text = "Duração Notificação (s)", Default = Config.Settings.NotificationDuration, Min = 0, Max = 15, Rounding = 0}):OnChanged(function(v) Config.Settings.NotificationDuration = v end)
    Set_Perf:AddToggle("PerfMode", { Text = "Modo Performance", Default = Config.Settings.PerformanceMode}):OnChanged(function(v) Config.Settings.PerformanceMode = v; settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)

    local Set_Unload = Tabs.Settings:AddSection("Descarregar")
    Set_Unload:AddButton("UNLOAD SCRIPT (DESTROY UI)", function()
        Notify("System", "Descarregando script e UI...", 5)
        -- Desconectar todas as conexões de forma segura
        if State and State.Connections then
             for name, conn in pairs(State.Connections) do
                  if type(conn) == "RBXScriptConnection" and conn.Connected then
                       pcall(function() conn:Disconnect() end)
                  end
             end
             State.Connections = {}
        end
         -- Limpar ESP e parar serviços
         pcall(ESPService.Toggle, false)
         pcall(AutoFarmService.Toggle, false)
         pcall(KillAuraService.Toggle, false)
         pcall(AutoStatsService.Toggle, false)
         pcall(ToggleNoClip, false)
         -- Destruir a janela Fluent
         pcall(Window.Destroy, Window)
         -- Limpar referências (ajuda o garbage collector)
         Fluent, SaveManager, InterfaceManager, Window, Tabs, Config, State, Locations = nil, nil, nil, nil, nil, nil, nil, nil
         print("RedzHub Script Unloaded.")
         -- Opcional: remover o próprio script da CoreGui se ele foi adicionado lá
         -- script:Destroy() -- Use com cuidado, só se souber onde o script está
    end):SetTextColor(Color3.fromRGB(255, 80, 80))


    -- Carregar Configurações Salvas (se SaveManager estiver ativo) - Movido para botão
    -- if SaveManager then
    --      local loadedConfig = SaveManager:Load(ConfigIdentifier)
    --      if loadedConfig then Config = loadedConfig; Notify("Settings", "Configurações carregadas.", 3) end
    --      -- Reaplicar configurações aqui...
    --  end

    -- Interface Manager (Apenas se carregado)
    if InterfaceManager and Fluent then
        pcall(InterfaceManager.SetLibrary, InterfaceManager, Fluent)
        pcall(InterfaceManager.BindInput, InterfaceManager, Mouse)
    end

    -- Notificação Final
    Notify("RedzHub Loaded", "Script inicializado. UI Pronta!", 5)
    print("RedzHub Inspired Script Loaded and UI Populated.")

else
    warn("ERRO: Falha ao criar as Tabs. A UI não pode ser populada.")
    if Window then pcall(Window.Destroy, Window) end -- Destroi janela se tabs falharam
end

-- // FIM DO SCRIPT --
