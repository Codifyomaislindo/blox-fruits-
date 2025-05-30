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
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

-- // ============================================================
-- // FUNÇÃO SafeLoadString REFORÇADA
-- // ============================================================
local function SafeLoadString(url, name, fallbackUrl)
    local compiledCode = nil
    local source = nil

    -- Função interna para tentar buscar e compilar
    local function tryFetchAndCompile(fetchUrl)
        local fetchSuccess, fetchResult = pcall(game.HttpGet, game, fetchUrl) -- Usa pcall para HttpGet
        if not fetchSuccess then
            warn("Falha ao buscar " .. name .. " de " .. fetchUrl .. ": " .. tostring(fetchResult))
            return nil, nil
        end
        if type(fetchResult) ~= "string" then
             warn("Resultado inválido ao buscar " .. name .. " de " .. fetchUrl .. " (Tipo: " .. type(fetchResult) .. ")")
             return nil, nil
        end
        source = fetchResult -- Guarda o código fonte para debug se necessário

        local compileSuccess, compiledFunc = pcall(loadstring(fetchResult))
        if not compileSuccess or type(compiledFunc) ~= "function" then
            warn("Falha ao compilar " .. name .. " de " .. fetchUrl .. ": " .. tostring(compiledFunc))
            return nil, fetchResult -- Retorna nil e o source em caso de falha na compilação
        end
        -- print(name .. " compilado com sucesso de " .. fetchUrl)
        return compiledFunc, fetchResult
    end

    -- Tenta a URL primária (invertida para tentar raw primeiro)
    -- compiledCode, source = tryFetchAndCompile(fallbackUrl or url) -- Tenta fallback primeiro
    -- Fallback URL pode ser nil, então usa a URL original se fallback falhar ou não existir
    -- if not compiledCode then
    --     warn("Falha ao compilar " .. name .. " de " .. (fallbackUrl or url) .. ". Tentando URL principal...")
    --     compiledCode, source = tryFetchAndCompile(url)
    -- end

     -- Tenta a URL primária
     compiledCode, source = tryFetchAndCompile(url)
     -- Tenta o fallback se a primária falhar e o fallback existir
     if not compiledCode and fallbackUrl then
         warn("Falha ao compilar " .. name .. " de " .. url .. ". Tentando URL alternativa...")
         compiledCode, source = tryFetchAndCompile(fallbackUrl)
     end


    -- Se falhou em compilar de ambas as fontes
    if not compiledCode then
        warn("ERRO CRÍTICO: Não foi possível compilar a biblioteca " .. name .. " de nenhuma fonte.")
        -- Opcional: Mostrar o código fonte baixado se houve falha só na compilação
        -- if source then warn("Código fonte baixado:\n", source) end
        return nil -- Falha total
    end

    -- Tenta executar o código compilado e verificar se é o Fluent correto
    local executeSuccess, loadedResult = pcall(compiledCode)
    if not executeSuccess then
        warn("ERRO CRÍTICO: Falha ao EXECUTAR o código compilado de " .. name .. ": " .. tostring(loadedResult))
        -- O erro "[string "AwLV5dCd"]:32: attempt to call a table value" acontece aqui DENTRO do pcall
        warn("-> Isso geralmente indica um erro INTERNO na biblioteca " .. name .. " durante sua inicialização.")
        return nil
    end

    -- VERIFICAÇÃO ESSENCIAL: O resultado é uma tabela E contém CreateWindow?
    if type(loadedResult) ~= "table" or type(loadedResult.CreateWindow) ~= "function" then
        warn("ERRO CRÍTICO: A biblioteca " .. name .. " carregou, mas não retornou a API esperada (tipo: " .. type(loadedResult) .. ").")
        if type(loadedResult) == "table" then
            warn("-> Funções encontradas na tabela retornada:")
            for k, v in pairs(loadedResult) do warn("  - " .. tostring(k) .. ": " .. type(v)) end
        end
        return nil
    end

    print(name .. " carregado e verificado com sucesso.")
    return loadedResult -- Retorna a API da biblioteca (ex: a tabela Fluent)
end


-- // Carregar Bibliotecas Essenciais (Fluent UI)
-- // Tenta carregar a versão Raw primeiro, fallback para Releases
local Fluent = SafeLoadString(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua", -- URL Raw primeiro
    "Fluent",
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua" -- Fallback Releases
)
-- Mantém o carregamento dos addons como antes, mas o script principal depende do Fluent
local SaveManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua", "SaveManager", nil)
local InterfaceManager = SafeLoadString("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua", "InterfaceManager", nil)

-- // VERIFICAÇÃO CRÍTICA DO FLUENT (Mantida, mas agora após SafeLoadString melhorado)
if not Fluent then
    local errorMsg = "ERRO FATAL: A biblioteca principal 'Fluent' não pôde ser carregada ou verificada. O script não pode continuar. Verifique o console para detalhes."
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub Load Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"})
    return -- Interrompe a execução do script aqui
end

-- Aviso se addons falharem
if not SaveManager then warn("SaveManager não carregado. As configurações não serão salvas.") end
if not InterfaceManager then warn("InterfaceManager não carregado. A janela pode não ser arrastável.") end


-- // Configurações Iniciais da Janela Fluent (Mantido como antes)
local Window
local successCreateWindow, windowResult = pcall(function()
    return Fluent:CreateWindow({
        Title = "RedzHub Blox Fruits (v2.2 Fix Attempt)",
        SubTitle = "Inspired by the best",
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 500),
        Acrylic = true,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl
    })
end)

if not successCreateWindow or not windowResult then
    local errorMsg = "ERRO FATAL: Falha ao criar a janela Fluent: " .. tostring(windowResult)
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub UI Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"})
    return
end
Window = windowResult
print("Janela Fluent criada com sucesso.")


-- // Gerenciador de Salvamento (Mantido como antes)
local ConfigIdentifier = "RedzHubBF_Config_v2"
if Fluent and SaveManager then
    local successSM, errorSM = pcall(function()
        SaveManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "FluentSettings" })
    end)
    if not successSM then warn("Erro ao configurar SaveManager: "..tostring(errorSM)); SaveManager = nil end
else SaveManager = nil end


-- // Abas Principais da UI (Mantido como antes com ícones Lucide)
local Tabs = {}
local successTabs, errorTabs = pcall(function()
    Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "bot" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
        Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
        ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
        Items = Window:AddTab({ Title = "Items/Fruits", Icon = "gem" }),
        Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart-2" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings-2" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "image" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }
end)

if not successTabs then
     local errorMsg = "ERRO FATAL: Falha ao criar as abas da UI: " .. tostring(errorTabs) .. ". Verifique os nomes dos ícones ou parâmetros das abas."
    warn(errorMsg)
    StarterGui:SetCore("SendNotification", { Title = "RedzHub UI Error", Text = errorMsg, Duration = 20, Icon = "rbxassetid://281289478"})
    Window:Destroy()
    return
end
print("Abas da UI criadas com sucesso.")


-- // ============================================================
-- // RESTANTE DO CÓDIGO (CONFIG, STATE, FUNÇÕES, ELEMENTOS UI)
-- // ============================================================

-- // Módulo de Configuração Padrão (Como antes)
local Config = {
    -- ESP Configs
    ESP = {
        Enabled = false, Fruits = false, FruitColor = Color3.fromRGB(255, 80, 80),
        Chests = false, ChestColor = Color3.fromRGB(255, 255, 0), Players = false, PlayerColor = Color3.fromRGB(0, 255, 255),
        PlayerTeamColor = true, Enemies = false, EnemyColor = Color3.fromRGB(0, 255, 0), Bosses = false, BossColor = Color3.fromRGB(255, 0, 255),
        SeaBeasts = false, SeaBeastColor = Color3.fromRGB(0, 191, 255), QuestNPCs = false, QuestNPCColor = Color3.fromRGB(255, 165, 0),
        Items = false, ItemColor = Color3.fromRGB(255, 255, 255), Flowers = false, FlowerColor = Color3.fromRGB(255, 105, 180),
        TextSize = 14, Outline = true, MaxDistance = 5000, UpdateInterval = 0.25
    },
    -- AutoFarm Configs
    AutoFarm = {
        LevelEnabled = false, MasteryEnabled = false, SelectedWeapon = "Melee", SelectedMob = "Auto Detect",
        BringMobs = false, BringDistance = 50,
        FastAttack = false, -- <<< ALTERADO PARA FALSE POR PADRÃO DEVIDO AO ERRO DE CLONE
        AutoSkills = false, AutoFarmBosses = false, SelectedBoss = "Auto Detect", AutoFarmChests = false,
        AutoFarmBones = false, AutoFactory = false, AutoDarkbeard = false, AutoSeaEvents = false, AutoMirageIsland = false,
        AutoLeviathanHunt = false, AutoRaceV4Trial = false, FarmRange = 5000, MinDistance = 10, TweenSpeed = 150,
        AttackDelay = 0.4 -- <<< NOVO: Delay base entre ataques (segundos)
    },
    -- Combat Configs
    Combat = {
        KillAuraEnabled = false, KillAuraRange = 30, KillAuraTargetPlayers = false, KillAuraTargetBosses = true,
        AutoHaki = false, HakiInterval = 10, BusoHaki = true, KenHaki = false, AutoGear = false, TargetGear = "Gear 4",
        GearInterval = 30, AutoObservationHaki = false
    },
    -- Teleport Configs
    Teleport = { SafeMode = false },
    -- Items/Fruits Configs
    Items = {
        AutoStoreFruit = false, StoreThreshold = 1000000, FruitSniper = false, SniperWebhookURL = "",
        SniperMinRarity = "Legendary", AutoBuyItem = "", AutoRedeemCodes = false
    },
    -- Stats Configs
    Stats = { AutoStats = false, Priority = { Melee = 1, Defense = 1, Sword = 0, Gun = 0, Fruit = 0 } },
    -- Misc Configs
    Misc = {
        ServerHop = false, HopOnFruitSnipe = false, HopIfPlayerNearby = false, AntiAFK = true, NoClip = false,
        WalkSpeedEnabled = false, WalkSpeedValue = 50, JumpPowerEnabled = false, JumpPowerValue = 100,
        RedeemCodes = "", AutoSecondSea = false, AutoThirdSea = false
    },
    -- Visuals Configs
    Visuals = { FOVEnabled = false, FOVValue = 90, BrightnessEnabled = false, BrightnessValue = 0.2, RemoveFog = false, FullBright = false, NoWater = false },
    -- Settings
    Settings = { NotificationDuration = 5, ExecutorMode = "Standard", PerformanceMode = false }
}

-- // Módulo de Estado Interno (Como antes)
local State = { CurrentTarget = nil, CurrentQuest = nil, IsTeleporting = false, IsNoclipping = false, LastHakiCheck = 0, LastGearCheck = 0, LastAntiAFK = 0, ESPObjects = {}, Connections = {} }

-- // Funções Utilitárias (Notify, SafeRun, Getters - Como antes)
local function Notify(title, text, duration)
    if Fluent and Config.Settings.NotificationDuration > 0 then
         local success, err = pcall(Fluent.Notify, Fluent, { Title = title or "RedzHub", Content = text or "", Duration = duration or Config.Settings.NotificationDuration })
         if not success then warn("Falha ao enviar notificação Fluent:", err) end
    else StarterGui:SetCore("SendNotification", { Title = title or "RedzHub", Text = text or "", Duration = duration or Config.Settings.NotificationDuration }) end
    print(title .. ": " .. text)
end
local function SafeRun(func, errorHandler)
    local success, err = pcall(func)
    if not success and errorHandler then errorHandler(err) elseif not success then warn("Erro não tratado: " .. tostring(err)) end
    return success
end
local function GetHumanoidRootPart(player)
    player = player or LocalPlayer; local char = player.Character or player.CharacterAdded:Wait(); return char and char:FindFirstChild("HumanoidRootPart")
end
local function GetPlayerLevel()
    local data = LocalPlayer:FindFirstChild("Data"); if data and data:FindFirstChild("Level") then return data.Level.Value end
    local stats = LocalPlayer:FindFirstChild("PlayerStats"); if stats and stats:FindFirstChild("Level") then return stats.Level.Value end
    local levelVal = LocalPlayer:FindFirstChild("Level"); if levelVal then return levelVal.Value end; return 1
end

-- // Remote Event Handler (PLACEHOLDER - Como antes)
local Remotes = { CommF_ = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_"), Combat = ReplicatedStorage:FindFirstChild("CombatRemotes") and ReplicatedStorage.CombatRemotes:FindFirstChild("Damage"), Stats = ReplicatedStorage:FindFirstChild("StatsRemotes") and ReplicatedStorage.StatsRemotes:FindFirstChild("AddPoint"), Quest = ReplicatedStorage:FindFirstChild("QuestRemotes") and ReplicatedStorage.QuestRemotes:FindFirstChild("Quest"), Haki = ReplicatedStorage:FindFirstChild("HakiRemotes") and ReplicatedStorage.HakiRemotes:FindFirstChild("ToggleHaki"), Store = ReplicatedStorage:FindFirstChild("InventoryRemotes") and ReplicatedStorage.InventoryRemotes:FindFirstChild("StoreFruit"), Redeem = ReplicatedStorage:FindFirstChild("SystemRemotes") and ReplicatedStorage.SystemRemotes:FindFirstChild("RedeemCode") }
local function InvokeServer(remoteName, ...) if Remotes[remoteName] then local s, r = pcall(Remotes[remoteName].InvokeServer, Remotes[remoteName], ...); if not s then Notify("Remote Error", "Invoke " .. remoteName .. ": " .. tostring(r), 10) return nil end; return r else Notify("Remote Error", "Remote não encontrado: " .. remoteName, 10); return nil end end
local function FireServer(remoteName, ...) if Remotes[remoteName] then local s, r = pcall(Remotes[remoteName].FireServer, Remotes[remoteName], ...); if not s then Notify("Remote Error", "Fire " .. remoteName .. ": " .. tostring(r), 10) end else Notify("Remote Error", "Remote não encontrado: " .. remoteName, 10) end end

-- // Funções de Teleporte Aprimoradas (Como antes)
local function Teleport(targetPosition)
    if State.IsTeleporting then return end; local hrp = GetHumanoidRootPart(); if not hrp then Notify("Teleport Error", "HRP não encontrado.", 5); return end
    State.IsTeleporting = true
    SafeRun(function()
        local startPos = hrp.Position; local distance = (startPos - targetPosition).Magnitude; local duration = distance / math.max(1, Config.AutoFarm.TweenSpeed)
        if Config.Teleport.SafeMode and distance > 500 then Humanoid:MoveTo(targetPosition); local fin = Humanoid.MoveToFinished:Wait(duration + 5); if not fin then Notify("Teleport Warning", "MoveTo timeout.", 3) end
        else local tw = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0)) }); tw:Play(); tw.Completed:Wait(duration + 2) end
        task.wait(0.2); if (hrp.Position - targetPosition).Magnitude > 75 then hrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0)); Notify("Teleport Info", "TP forçado.", 3) end
    end, function(err) Notify("Teleport Error", "Falha: " .. tostring(err), 8) end)
    State.IsTeleporting = false
end

-- // Listas de Locais (Como antes)
local Locations = { Islands = { ["Starter Pirate"] = Vector3.new(-1100, 20, 3500), ["Starter Marine"] = Vector3.new(-2600, 20, 2000), ["Middle Town"] = Vector3.new(-130, 20, 130), ["Jungle"] = Vector3.new(-1200, 20, 1500), ["Desert"] = Vector3.new(1000, 20, 4000), ["Frozen Village"] = Vector3.new(1000, 20, 6000), ["Colosseum"] = Vector3.new(-1500, 20, 8000), ["Prison"] = Vector3.new(5000, 20, 3000), ["Magma Village"] = Vector3.new(-5000, 20, 4000), ["Underwater City"] = Vector3.new(4000, -100, -2000), ["Fountain City"] = Vector3.new(5000, 20, -4000), ["Skylands (Lower)"] = Vector3.new(-5000, 1000, -2000), ["Skylands (Upper)"] = Vector3.new(-3000, 1200, -1000), ["Kingdom of Rose"] = Vector3.new(-2000, 20, -2000), ["Cafe"] = Vector3.new(-380, 20, 300), ["Green Zone"] = Vector3.new(-2500, 20, 3000), ["Graveyard"] = Vector3.new(-5000, 20, 500), ["Snow Mountain"] = Vector3.new(2000, 20, 4000), ["Hot and Cold"] = Vector3.new(-6000, 20, -3000), ["Cursed Ship"] = Vector3.new(9000, 20, 500), ["Ice Castle"] = Vector3.new(5500, 20, -6000), ["Dark Arena"] = Vector3.new(-5000, 20, 2000), ["Factory"] = Vector3.new(-2000, 20, -1500), ["Port Town"] = Vector3.new(-300, 20, 5000), ["Hydra Island"] = Vector3.new(5000, 20, 6000), ["Great Tree"] = Vector3.new(2000, 20, 7000), ["Floating Turtle"] = Vector3.new(-1000, 20, 8000), ["Castle on the Sea"] = Vector3.new(-5000, 20, 9000), ["Haunted Castle"] = Vector3.new(-9500, 20, 6000), ["Sea of Treats"] = Vector3.new(0, 20, 10000), ["Tiki Outpost"] = Vector3.new(-16000, 20, 8000), }, Enemies = { }, NPCs = { ["Blox Fruit Dealer (Middle)"] = Vector3.new(-100, 20, 100), ["Gacha (Cafe)"] = Vector3.new(-350, 20, 350), ["Awakening Expert (Hot/Cold)"] = Vector3.new(-6000, 20, -2900), ["Quest Giver (Starter)"] = Vector3.new(-1050, 20, 3600), ["Quest Giver (Rose)"] = Vector3.new(-2100, 20, -1900), ["Quest Giver (Turtle)"] = Vector3.new(-1000, 20, 8100), ["Elite Hunter (Castle Sea)"] = Vector3.new(-5000, 20, 9100), ["Haki Trainer (Snow Mtn)"] = Vector3.new(2100, 20, 4100), ["Observation Trainer (Upper Sky)"] = Vector3.new(-3000, 1300, -900), ["Race V4 Temple (Tree)"] = Vector3.new(2000, 100, 7000), ["Code Redeemer (Rose)"] = Vector3.new(-2050, 20, -1950), }, Bosses = { ["Bobby (Starter)"] = Locations.Islands["Starter Pirate"], ["Gorilla King (Jungle)"] = Locations.Islands["Jungle"], ["Vice Admiral (Prison)"] = Locations.Islands["Prison"], ["Magma Admiral (Magma)"] = Locations.Islands["Magma Village"], ["Thunder God (Upper Sky)"] = Locations.Islands["Skylands (Upper)"], ["Don Swan (Rose)"] = Locations.Islands["Kingdom of Rose"], ["Fajita (Green Zone)"] = Locations.Islands["Green Zone"], ["Darkbeard (Dark Arena)"] = Locations.Islands["Dark Arena"], ["Tide Keeper (Forgotten)"] = Vector3.new(-3000, 20, -5000), ["Rip_Indra (Castle Sea)"] = Locations.Islands["Castle on the Sea"], ["Dough King (Cake Land)"] = Vector3.new(0, 20, 11000), ["Cake Queen (Cake Land)"] = Vector3.new(0, 20, 11000), } }

-- // Módulo ESP Aprimorado (Como antes)
local ESPService = { Running = false }
function ESPService:CreateLabel(object, text, color, size, outline, type) if not object or not object.Parent then return nil end; local b = Instance.new("BillboardGui"); b.Name = type .. "ESP_Label"; b.Adornee = object; b.Size = UDim2.new(0, 150, 0, 20); b.StudsOffset = Vector3.new(0, 2, 0); b.AlwaysOnTop = true; b.MaxDistance = Config.ESP.MaxDistance; b.Enabled = true; local t = Instance.new("TextLabel"); t.Name = "Text"; t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = text; t.TextColor3 = color; t.TextSize = size; t.Font = Enum.Font.SourceSansSemibold; if outline then t.TextStrokeColor3 = Color3.new(0,0,0); t.TextStrokeTransparency = 0.5 end; t.Parent = b; local d = Instance.new("TextLabel"); d.Name = "Distance"; d.Size = UDim2.new(1, 0, 1, 0); d.Position = UDim2.new(0, 0, 0, 15); d.BackgroundTransparency = 1; d.Text = "0m"; d.TextColor3 = color; d.TextSize = size - 2; d.Font = Enum.Font.SourceSans; if outline then d.TextStrokeColor3 = Color3.new(0,0,0); d.TextStrokeTransparency = 0.5 end; d.Parent = b; b.Parent = CoreGui; return { Billboard = b, TextLabel = t, DistanceLabel = d, Object = object, Type = type } end
function ESPService:Update() if not Config.ESP.Enabled or not ESPService.Running then return end; local playerHRP = GetHumanoidRootPart(); if not playerHRP then return end; local playerPos = playerHRP.Position; local currentESPKeys = {}; for k, espData in pairs(State.ESPObjects) do local obj = espData.Object; if not obj or not obj.Parent or not espData.Billboard or not espData.Billboard.Parent or (obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health <= 0) then if espData.Billboard then espData.Billboard:Destroy() end; State.ESPObjects[k] = nil else local targetPart = espData.Billboard.Adornee; if targetPart and targetPart.Parent then local objPos = targetPart.Position; local dist = math.floor((playerPos - objPos).Magnitude); espData.DistanceLabel.Text = dist .. "m"; espData.Billboard.Enabled = dist <= Config.ESP.MaxDistance; currentESPKeys[k] = true else if espData.Billboard then espData.Billboard:Destroy() end; State.ESPObjects[k] = nil end end end; for _, entity in pairs(Workspace:GetDescendants()) do local entityKey = entity; if currentESPKeys[entityKey] or State.ESPObjects[entityKey] then continue end; local espType, espColor, espText, targetObject, originalObject = nil, Color3.new(1,1,1), entity.Name, nil, entity; if Config.ESP.Fruits and entity.Name == "Fruit" and entity:IsA("BasePart") then espType, espColor, targetObject = "Fruit", Config.ESP.FruitColor, entity; espText = entity.Parent and entity.Parent:FindFirstChild("FruitName") and entity.Parent.FruitName.Value or "Fruit" elseif Config.ESP.Chests and entity.Name:match("Chest") and entity:IsA("BasePart") then espType, espColor, targetObject, espText = "Chest", Config.ESP.ChestColor, entity, "Chest" elseif Config.ESP.Flowers and entity.Name:match("Flower") and entity:IsA("BasePart") then espType, espColor, targetObject, espText = "Flower", Config.ESP.FlowerColor, entity, "Flower" elseif Config.ESP.Items and (entity.Name:match("Material") or entity.Name:match("Drop")) and entity:IsA("BasePart") then espType, espColor, targetObject, espText = "Item", Config.ESP.ItemColor, entity, entity.Name elseif entity:IsA("Model") and entity ~= Character then local hum, hrp = entity:FindFirstChildOfClass("Humanoid"), entity:FindFirstChild("HumanoidRootPart"); if hum and hrp and hum.Health > 0 then local isPlayer, isBoss, isSeaBeast, isQuestNPC = Players:GetPlayerFromCharacter(entity), entity:FindFirstChild("IsBoss") or entity.Name:match("Boss") or table.find({"Rip_Indra", "Dough King", "Cake Queen", "Darkbeard", "Tide Keeper"}, entity.Name), entity.Name:match("SeaBeast") or entity.Name:match("Leviathan") or entity.Name:match("Terrorshark"), entity:FindFirstChild("QuestGiver") or (entity.Parent and entity.Parent.Name == "NPCs" and entity.Name:match("Quest")); if Config.ESP.Players and isPlayer then espType, espColor, targetObject, espText = "Player", Config.ESP.PlayerColor, hrp, entity.Name .. " [Player]"; if Config.ESP.PlayerTeamColor and isPlayer.TeamColor then espColor = isPlayer.TeamColor.Color end elseif Config.ESP.Bosses and isBoss then espType, espColor, targetObject, espText = "Boss", Config.ESP.BossColor, hrp, entity.Name .. " [Boss]" elseif Config.ESP.SeaBeasts and isSeaBeast then espType, espColor, targetObject, espText = "SeaBeast", Config.ESP.SeaBeastColor, hrp, entity.Name .. " [Sea Event]" elseif Config.ESP.QuestNPCs and isQuestNPC then espType, espColor, targetObject, espText = "QuestNPC", Config.ESP.QuestNPCColor, hrp, entity.Name .. " [Quest]" elseif Config.ESP.Enemies and not isPlayer and not isBoss and not isSeaBeast and not isQuestNPC then espType, espColor, targetObject = "Enemy", Config.ESP.EnemyColor, hrp; local level = entity:FindFirstChild("Level") and entity.Level.Value; espText = entity.Name .. (level and (" [Lv. " .. level .. "]") or "") end end end; if espType and targetObject then if not State.ESPObjects[originalObject] then local espData = ESPService:CreateLabel(targetObject, espText, espColor, Config.ESP.TextSize, Config.ESP.Outline, espType); if espData then State.ESPObjects[originalObject] = espData end end end end end
function ESPService:Toggle(enabled) Config.ESP.Enabled = enabled; if enabled and not ESPService.Running then ESPService.Running = true; State.Connections.ESPUpdate = RunService.Heartbeat:Connect(function() SafeRun(ESPService.Update) end); Notify("ESP", "ESP Global Ativado.", 3) elseif not enabled and ESPService.Running then ESPService.Running = false; if State.Connections.ESPUpdate then State.Connections.ESPUpdate:Disconnect() State.Connections.ESPUpdate = nil end; for k, espData in pairs(State.ESPObjects) do if espData.Billboard and espData.Billboard.Parent then SafeRun(function() espData.Billboard:Destroy() end) end end; State.ESPObjects = {}; Notify("ESP", "ESP Global Desativado.", 3) end end
function ESPService:ClearType(type) local typeKey = type:match("^(%u%l*)"); if not typeKey then return end; for k, espData in pairs(State.ESPObjects) do if espData.Type == typeKey then if espData.Billboard and espData.Billboard.Parent then espData.Billboard:Destroy() end; State.ESPObjects[k] = nil end end end

-- // Módulo Auto Farm Aprimorado (Adicionado Delay de Ataque)
local AutoFarmService = { Running = false }
function AutoFarmService:GetBestTarget() local playerPos = GetHumanoidRootPart() and GetHumanoidRootPart().Position; local playerLevel = GetPlayerLevel(); if not playerPos then return nil end; local bestTarget, minDistance, targetMobName, targetLevel = nil, Config.AutoFarm.FarmRange, Config.AutoFarm.SelectedMob == "Auto Detect" and nil or Config.AutoFarm.SelectedMob, -1; if not targetMobName and Config.AutoFarm.LevelEnabled and Locations.Enemies then local highestLvl, detectedMob = -1, nil; for name, data in pairs(Locations.Enemies) do if data and type(data.Level) == "number" and data.Level <= playerLevel and data.Level > highestLvl then highestLvl, detectedMob = data.Level, name end end; if detectedMob then targetMobName = detectedMob end end; if Config.AutoFarm.SelectedMob ~= "Auto Detect" then targetMobName = Config.AutoFarm.SelectedMob end; if not targetMobName and not Config.AutoFarm.AutoFarmBosses then return nil end; for _, entity in pairs(Workspace:GetChildren()) do if not entity:IsA("Model") or entity == Character then continue end; local hum, hrp = entity:FindFirstChildOfClass("Humanoid"), entity:FindFirstChild("HumanoidRootPart"); if hum and hrp and hum.Health > 0 then local isCorrectMob = targetMobName and entity.Name == targetMobName; local isFarmableBoss = Config.AutoFarm.AutoFarmBosses and (entity:FindFirstChild("IsBoss") or (Locations.Bosses and Locations.Bosses[entity.Name])) and (Config.AutoFarm.SelectedBoss == "Auto Detect" or entity.Name == Config.AutoFarm.SelectedBoss); if isCorrectMob or isFarmableBoss then local dist = (playerPos - hrp.Position).Magnitude; if dist < minDistance and dist > Config.AutoFarm.MinDistance then minDistance, bestTarget = dist, entity end end end end; return bestTarget end
function AutoFarmService:EquipWeapon(weaponType) local tool, humanoid = nil, Character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end; local function findTool(nameOrClass) local f = Backpack:FindFirstChild(nameOrClass) or Character:FindFirstChild(nameOrClass); if not f and nameOrClass:match("Class") then local c = nameOrClass:gsub("Class", ""); f = Backpack:FindFirstChildOfClass(c) or Character:FindFirstChildOfClass(c) end; return f end; if weaponType == "Melee" then local current = Character:FindFirstChild("Combat") or Character:FindFirstChildWhichIsA("Tool"); if current and current.Name ~= "Combat" and current:IsA("Tool") then humanoid:UnequipTools(); task.wait(0.1) end; return elseif weaponType == "Sword" then tool = findTool("Sword") or findTool("ClassTool") elseif weaponType == "Gun" then tool = findTool("Gun") or findTool("ClassTool") elseif weaponType == "Fruit" then local ct = Character:FindFirstChildOfClass("Tool"); if ct then humanoid:UnequipTools() end; return end; if tool and tool:IsA("Tool") and tool.Parent ~= Character then humanoid:EquipTool(tool); task.wait(0.2) end end
function AutoFarmService:AttackTarget(target) if not target or not target.Parent then return end; local targetHum, targetHRP, playerHRP = target:FindFirstChildOfClass("Humanoid"), target:FindFirstChild("HumanoidRootPart"), GetHumanoidRootPart(); if not targetHum or targetHum.Health <= 0 or not targetHRP or not playerHRP then return end; local distance = (playerHRP.Position - targetHRP.Position).Magnitude; if Config.AutoFarm.BringMobs and distance > Config.AutoFarm.BringDistance then SafeRun(function() targetHRP.CFrame = playerHRP.CFrame * CFrame.new(0, 0, -5) end); task.wait(0.1); distance = (playerHRP.Position - targetHRP.Position).Magnitude end; if distance > 60 then Teleport(targetHRP.Position + Vector3.new(math.random(-3,3), 5, math.random(-3,3))); task.wait(0.5); if (playerHRP.Position - targetHRP.Position).Magnitude > 80 then Notify("AutoFarm Warn", "Falha ao aproximar.", 3); return end end; AutoFarmService:EquipWeapon(Config.AutoFarm.SelectedWeapon); local weapon, skillToUse, fruitName = Config.AutoFarm.SelectedWeapon, "Combat", LocalPlayer.Data and LocalPlayer.Data:FindFirstChild("DevilFruit") and LocalPlayer.Data.DevilFruit.Value; if weapon == "Fruit" and fruitName then skillToUse = fruitName elseif weapon == "Sword" then skillToUse = "SwordSkill" elseif weapon == "Gun" then skillToUse = "GunSkill" end; SafeRun(function() if Config.AutoFarm.FastAttack then FireServer("Combat", target, 100) else InvokeServer("CommF_", "UseAbility", skillToUse, target) end; task.wait(Config.AutoFarm.AttackDelay) end, function(err) Notify("Attack Error", "Falha: "..tostring(err), 4) end); if Config.AutoFarm.AutoSkills then local skills = {"Z", "X", "C", "V"}; for _, key in pairs(skills) do SafeRun(function() InvokeServer("CommF_", "UseSkill", key); task.wait(0.1) end) end end end
function AutoFarmService:Run() if not AutoFarmService.Running then return end; local s, e = pcall(function() local target = AutoFarmService:GetBestTarget(); if target and target.Parent and target:FindFirstChildOfClass("Humanoid") and target.Humanoid.Health > 0 then State.CurrentTarget = target; AutoFarmService:AttackTarget(target) else State.CurrentTarget = nil; task.wait(0.5) end end); if not s then Notify("AutoFarm Error", "Loop: " .. tostring(e), 8); AutoFarmService:Toggle(false) end end
function AutoFarmService:Toggle(enabled) if AutoFarmService.Running == enabled then return end; AutoFarmService.Running = enabled; if enabled then Notify("AutoFarm", "Iniciado.", 3); if not State.Connections.AutoFarmRun or not State.Connections.AutoFarmRun.Connected then State.Connections.AutoFarmRun = RunService.Heartbeat:Connect(AutoFarmService.Run) end else Notify("AutoFarm", "Parado.", 3); if State.Connections.AutoFarmRun and State.Connections.AutoFarmRun.Connected then State.Connections.AutoFarmRun:Disconnect() end; State.Connections.AutoFarmRun = nil; State.CurrentTarget = nil end; Config.AutoFarm.LevelEnabled = enabled end

-- // Outros Módulos (Kill Aura, Auto Stats, NoClip, AntiAFK, ServerHop, AutoHaki - Como antes com pequenos delays)
local KillAuraService = { Running = false }
function KillAuraService:Run() if not Config.Combat.KillAuraEnabled or not KillAuraService.Running then return end; local playerHRP = GetHumanoidRootPart(); if not playerHRP then return end; local playerPos = playerHRP.Position; SafeRun(function() for _, entity in pairs(Workspace:GetChildren()) do if not entity:IsA("Model") or entity == Character then continue end; local hum, hrp = entity:FindFirstChildOfClass("Humanoid"), entity:FindFirstChild("HumanoidRootPart"); if hum and hrp and hum.Health > 0 then local dist = (playerPos - hrp.Position).Magnitude; if dist <= Config.Combat.KillAuraRange then local isPlayer, isBoss, shouldTarget = Players:GetPlayerFromCharacter(entity), entity:FindFirstChild("IsBoss") or (Locations.Bosses and Locations.Bosses[entity.Name]), false; if Config.Combat.KillAuraTargetPlayers and isPlayer then shouldTarget=true elseif Config.Combat.KillAuraTargetBosses and isBoss then shouldTarget=true elseif not isPlayer and not isBoss then shouldTarget=true end; if shouldTarget then AutoFarmService:AttackTarget(entity); task.wait(0.1 + Config.AutoFarm.AttackDelay) end end end end end, function(err) Notify("KillAura Error", "Erro: "..tostring(err), 5); KillAuraService:Toggle(false) end) end
function KillAuraService:Toggle(enabled) if KillAuraService.Running == enabled then return end; KillAuraService.Running = enabled; Config.Combat.KillAuraEnabled = enabled; if enabled then Notify("Combat", "Kill Aura Ativado.", 3); if not State.Connections.KillAuraRun or not State.Connections.KillAuraRun.Connected then State.Connections.KillAuraRun = RunService.Heartbeat:Connect(KillAuraService.Run) end else Notify("Combat", "Kill Aura Desativado.", 3); if State.Connections.KillAuraRun and State.Connections.KillAuraRun.Connected then State.Connections.KillAuraRun:Disconnect() end; State.Connections.KillAuraRun = nil end end
local AutoStatsService = { Running = false, Checking = false }
function AutoStatsService:AllocatePoints() if AutoStatsService.Checking then return end; AutoStatsService.Checking = true; local pts = 0; local data = LocalPlayer:FindFirstChild("Data"); if data and data:FindFirstChild("Points") then pts = data.Points.Value elseif LocalPlayer:FindFirstChild("PlayerStats") and LocalPlayer.PlayerStats:FindFirstChild("StatPoints") then pts = LocalPlayer.PlayerStats.StatPoints.Value end; if pts > 0 then Notify("Stats", "Alocando " .. pts .. " pts...", 2); local totalPrio = 0; for _, p in pairs(Config.Stats.Priority) do totalPrio = totalPrio + p end; if totalPrio > 0 then local allocated = 0; for stat, prio in pairs(Config.Stats.Priority) do if prio > 0 then local toAlloc = math.min(math.floor((prio/totalPrio)*pts), pts-allocated); if toAlloc > 0 then local s = SafeRun(function() FireServer("Stats", stat, toAlloc) end); if s then allocated = allocated + toAlloc; task.wait(0.1) else break end end end; if allocated >= pts then break end end; local remain = pts - allocated; if remain > 0 then local hp, sb = 0, nil; for s, p in pairs(Config.Stats.Priority) do if p > hp then hp, sb = p, s end end; if sb then SafeRun(function() FireServer("Stats", sb, remain) end) end end; Notify("Stats", "Pontos alocados.", 3) end end; AutoStatsService.Checking = false end
function AutoStatsService:Toggle(enabled) if AutoStatsService.Running == enabled then return end; AutoStatsService.Running = enabled; Config.Stats.AutoStats = enabled; if enabled then Notify("Stats", "Auto Stats Ativado.", 3); if not State.Connections.AutoStatsRun or not State.Connections.AutoStatsRun.Connected then AutoStatsService:AllocatePoints(); State.Connections.AutoStatsRun = RunService.Heartbeat:Connect(function() if math.floor(os.clock()) % 5 == 0 then AutoStatsService:AllocatePoints() end end) end else Notify("Stats", "Auto Stats Desativado.", 3); if State.Connections.AutoStatsRun and State.Connections.AutoStatsRun.Connected then State.Connections.AutoStatsRun:Disconnect() end; State.Connections.AutoStatsRun = nil end end
function ToggleNoClip(enabled) if State.IsNoclipping == enabled then return end; State.IsNoclipping = enabled; Config.Misc.NoClip = enabled; if enabled then Notify("Misc", "Noclip Ativado.", 2); if not State.Connections.NoClipRun or not State.Connections.NoClipRun.Connected then State.Connections.NoClipRun = RunService.Heartbeat:Connect(function() if not State.IsNoclipping then if State.Connections.NoClipRun then State.Connections.NoClipRun:Disconnect(); State.Connections.NoClipRun = nil end; return end; for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end) end else Notify("Misc", "Noclip Desativado.", 2); if State.Connections.NoClipRun and State.Connections.NoClipRun.Connected then State.Connections.NoClipRun:Disconnect() end; State.Connections.NoClipRun = nil; SafeRun(function() for _, p in pairs(Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end) end end
function AntiAFK() if Config.Misc.AntiAFK and os.clock() - State.LastAntiAFK > 120 then SafeRun(function() VirtualUser:ClickButton1(Vector2.new()) end); State.LastAntiAFK = os.clock(); print("Anti-AFK.") end end
if Config.Misc.AntiAFK then if not State.Connections.AntiAFKRun or not State.Connections.AntiAFKRun.Connected then State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK) end end
function ServerHop() Notify("Misc", "Server Hop...", 5); if not game:IsLoaded() then Notify("Server Hop", "Aguarde carregar.", 4); return end; SafeRun(function() local TS = game:GetService("TeleportService"); TS:LeaveServer(); task.wait(1); TS:Teleport(game.PlaceId) end, function(err) Notify("Misc", "Falha Hop: " .. tostring(err), 8) end) end
function AutoHaki() if Config.Combat.AutoHaki and os.clock() - State.LastHakiCheck > Config.Combat.HakiInterval then SafeRun(function() if Config.Combat.BusoHaki then FireServer("Haki", "Buso", true) end; task.wait(0.1); if Config.Combat.KenHaki then FireServer("Haki", "Ken", true) end end); State.LastHakiCheck = os.clock() end end
if Config.Combat.AutoHaki then if not State.Connections.AutoHakiRun or not State.Connections.AutoHakiRun.Connected then State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki) end end

-- // ============================================================
-- // POPULAÇÃO DA UI (Adicionado AttackDelay Slider, FastAttack como Aviso)
-- // ============================================================
if Tabs and Tabs.Main then
    -- Aba Main (Como antes)
    local MainSection = Tabs.Main:AddSection("Informações Gerais"); MainSection:AddLabel("Bem-vindo ao RedzHub Inspired!"):SetFont(Enum.Font.SourceSansBold); MainSection:AddLabel("Player: " .. (LocalPlayer and LocalPlayer.Name or "N/A")); local levelLabel = MainSection:AddLabel("Level: " .. GetPlayerLevel()); if State and State.Connections then State.Connections.LevelUpdater = RunService.Heartbeat:Connect(function() if math.floor(os.clock()) % 10 == 0 then levelLabel:SetText("Level: ".. GetPlayerLevel()) end end) end

    -- Aba AutoFarm
    local AF_General = Tabs.AutoFarm:AddSection("Configurações Gerais")
    AF_General:AddToggle("AutoFarmToggle", { Text = "Ativar Auto Farm (Geral)", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(v) AutoFarmService:Toggle(v); pcall(function() Fluent:GetOption("AutoFarm", "LevelFarmToggle").Value = v end); pcall(function() Fluent:GetOption("AutoFarm", "MasteryFarmToggle").Value = v end) end)
    AF_General:AddDropdown("WeaponSelect", { Text = "Arma Preferencial", Default = Config.AutoFarm.SelectedWeapon, Values = {"Melee", "Sword", "Gun", "Fruit"} }):OnChanged(function(v) Config.AutoFarm.SelectedWeapon = v end)
    AF_General:AddToggle("BringMobsToggle", { Text = "Trazer Mobs", Default = Config.AutoFarm.BringMobs}):OnChanged(function(v) Config.AutoFarm.BringMobs = v end)
    AF_General:AddSlider("BringDistanceSlider", { Text = "Distância Trazer Mobs", Default = Config.AutoFarm.BringDistance, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(v) Config.AutoFarm.BringDistance = v end)
    AF_General:AddToggle("FastAttackToggle", { Text = "Ataque Rápido (INSTÁVEL!)", Default = Config.AutoFarm.FastAttack}):OnChanged(function(v) Config.AutoFarm.FastAttack = v; Notify("Aviso", "FastAttack pode causar erros/lag!", 5) end):SetToolTip("Usar com cuidado, pode causar o erro 'index nil with Clone' ou outros problemas.") -- Aviso!
    AF_General:AddSlider("AttackDelaySlider", { Text = "Delay Ataque (s)", Default = Config.AutoFarm.AttackDelay, Min = 0.1, Max = 2.0, Increment = 0.05}):OnChanged(function(v) Config.AutoFarm.AttackDelay = v end):SetToolTip("Tempo entre os ataques. Aumentar pode reduzir lag/erros.") -- Novo Slider
    AF_General:AddToggle("AutoSkillsToggle", { Text = "Usar Skills Auto (WIP)", Default = Config.AutoFarm.AutoSkills}):OnChanged(function(v) Config.AutoFarm.AutoSkills = v end)

    local AF_Leveling = Tabs.AutoFarm:AddSection("Farm de Nível/Maestria"); AF_Leveling:AddToggle("LevelFarmToggle", { Text = "Farmar Nível", Default = Config.AutoFarm.LevelEnabled }):OnChanged(function(v) Config.AutoFarm.LevelEnabled = v; if not v and not Config.AutoFarm.MasteryEnabled then AutoFarmService:Toggle(false) elseif v then AutoFarmService:Toggle(true) end end); AF_Leveling:AddToggle("MasteryFarmToggle", { Text = "Farmar Maestria", Default = Config.AutoFarm.MasteryEnabled }):OnChanged(function(v) Config.AutoFarm.MasteryEnabled = v; if not v and not Config.AutoFarm.LevelEnabled then AutoFarmService:Toggle(false) elseif v then AutoFarmService:Toggle(true) end end); local enemyNames = {"Auto Detect"}; if Locations.Enemies then for n,_ in pairs(Locations.Enemies) do table.insert(enemyNames, n) end end; table.sort(enemyNames); AF_Leveling:AddDropdown("MobSelect", { Text = "Mob Específico", Default = Config.AutoFarm.SelectedMob, Values = enemyNames }):OnChanged(function(v) Config.AutoFarm.SelectedMob = v end)
    local AF_Bosses = Tabs.AutoFarm:AddSection("Farm de Bosses"); AF_Bosses:AddToggle("BossFarmToggle", { Text = "Farmar Bosses", Default = Config.AutoFarm.AutoFarmBosses}):OnChanged(function(v) Config.AutoFarm.AutoFarmBosses = v end); local bossNames = {"Auto Detect"}; if Locations.Bosses then for n,_ in pairs(Locations.Bosses) do table.insert(bossNames, n) end end; table.sort(bossNames); AF_Bosses:AddDropdown("BossSelect", { Text = "Boss Específico", Default = Config.AutoFarm.SelectedBoss, Values = bossNames }):OnChanged(function(v) Config.AutoFarm.SelectedBoss = v end)
    local AF_Items = Tabs.AutoFarm:AddSection("Farm de Itens/Eventos"); AF_Items:AddToggle("ChestFarmToggle", { Text = "Farmar Baús", Default = Config.AutoFarm.AutoFarmChests}):OnChanged(function(v) Config.AutoFarm.AutoFarmChests = v end); AF_Items:AddToggle("BoneFarmToggle", { Text = "Farmar Ossos", Default = Config.AutoFarm.AutoFarmBones}):OnChanged(function(v) Config.AutoFarm.AutoFarmBones = v end); AF_Items:AddToggle("FactoryFarmToggle", { Text = "Farmar Fábrica", Default = Config.AutoFarm.AutoFactory}):OnChanged(function(v) Config.AutoFarm.AutoFactory = v end); AF_Items:AddToggle("DarkbeardFarmToggle", { Text = "Farmar Darkbeard", Default = Config.AutoFarm.AutoDarkbeard}):OnChanged(function(v) Config.AutoFarm.AutoDarkbeard = v end)

    -- Aba Combat (Como antes)
    local Combat_Aura = Tabs.Combat:AddSection("Kill Aura"); Combat_Aura:AddToggle("KillAuraToggle", {Text = "Ativar Kill Aura", Default = Config.Combat.KillAuraEnabled}):OnChanged(KillAuraService.Toggle); Combat_Aura:AddSlider("KillAuraRangeSlider", { Text = "Alcance", Default = Config.Combat.KillAuraRange, Min = 10, Max = 100, Rounding = 0}):OnChanged(function(v) Config.Combat.KillAuraRange = v end); Combat_Aura:AddToggle("KillAuraPlayers", { Text = "Atacar Players", Default = Config.Combat.KillAuraTargetPlayers}):OnChanged(function(v) Config.Combat.KillAuraTargetPlayers = v end); Combat_Aura:AddToggle("KillAuraBosses", { Text = "Atacar Bosses", Default = Config.Combat.KillAuraTargetBosses}):OnChanged(function(v) Config.Combat.KillAuraTargetBosses = v end)
    local Combat_Haki = Tabs.Combat:AddSection("Auto Haki/Gear"); Combat_Haki:AddToggle("AutoHakiToggle", { Text = "Auto Haki", Default = Config.Combat.AutoHaki}):OnChanged(function(v) Config.Combat.AutoHaki = v; if v and (not State.Connections.AutoHakiRun or not State.Connections.AutoHakiRun.Connected) then State.Connections.AutoHakiRun = RunService.Heartbeat:Connect(AutoHaki) elseif not v and State.Connections.AutoHakiRun and State.Connections.AutoHakiRun.Connected then State.Connections.AutoHakiRun:Disconnect(); State.Connections.AutoHakiRun = nil end end); Combat_Haki:AddToggle("BusoHaki", {Text="Buso Haki Auto", Default = Config.Combat.BusoHaki}):OnChanged(function(v) Config.Combat.BusoHaki = v end); Combat_Haki:AddToggle("KenHaki", {Text="Ken Haki Auto", Default = Config.Combat.KenHaki}):OnChanged(function(v) Config.Combat.KenHaki = v end); Combat_Haki:AddToggle("AutoGearToggle", { Text = "Auto Gear (WIP)", Default = Config.Combat.AutoGear}):OnChanged(function(v) Config.Combat.AutoGear = v end)

    -- Aba Teleport (Como antes)
    local TP_Islands = Tabs.Teleport:AddSection("Ilhas"); local islandNames = {}; if Locations.Islands then for n,_ in pairs(Locations.Islands) do table.insert(islandNames, n) end end; table.sort(islandNames); local islandDropdown = TP_Islands:AddDropdown("IslandDropdown", { Text = "Selecionar Ilha", Values = islandNames }); TP_Islands:AddButton("Ir para Ilha Selecionada", function() local n=islandDropdown.Value; if n and Locations.Islands[n] then Teleport(Locations.Islands[n]) end end)
    local TP_NPCs = Tabs.Teleport:AddSection("NPCs"); local npcNames = {}; if Locations.NPCs then for n,_ in pairs(Locations.NPCs) do table.insert(npcNames, n) end end; table.sort(npcNames); local npcDropdown = TP_NPCs:AddDropdown("NPCDropdown", { Text = "Selecionar NPC", Values = npcNames }); TP_NPCs:AddButton("Ir para NPC Selecionado", function() local n=npcDropdown.Value; if n and Locations.NPCs[n] then Teleport(Locations.NPCs[n]) end end)
    local TP_Bosses = Tabs.Teleport:AddSection("Bosses"); local bossTPNames = {}; if Locations.Bosses then for n,_ in pairs(Locations.Bosses) do table.insert(bossTPNames, n) end end; table.sort(bossTPNames); local bossTPDropdown = TP_Bosses:AddDropdown("BossTPDropdown", { Text = "Selecionar Boss", Values = bossTPNames }); TP_Bosses:AddButton("Ir para Boss Selecionado", function() local n=bossTPDropdown.Value; if n and Locations.Bosses[n] then Teleport(Locations.Bosses[n]) end end)
    Tabs.Teleport:AddToggle("SafeModeToggle", { Text = "Modo Seguro (Caminhar >500 studs)", Default = Config.Teleport.SafeMode }):OnChanged(function(v) Config.Teleport.SafeMode = v end)

    -- Aba ESP (Como antes)
    local ESP_Main = Tabs.ESP:AddSection("Controles Globais"); ESP_Main:AddToggle("ESPToggle", { Text = "Ativar ESP Global", Default = Config.ESP.Enabled }):OnChanged(ESPService.Toggle); ESP_Main:AddSlider("ESPDistance", { Text = "Distância Máx.", Default = Config.ESP.MaxDistance, Min = 500, Max = 10000, Rounding = 0}):OnChanged(function(v) Config.ESP.MaxDistance = v end); ESP_Main:AddSlider("ESPTextSize", { Text = "Tam. Texto", Default = Config.ESP.TextSize, Min = 8, Max = 24, Rounding = 0}):OnChanged(function(v) Config.ESP.TextSize = v end); ESP_Main:AddToggle("ESPOutline", { Text = "Contorno Texto", Default = Config.ESP.Outline}):OnChanged(function(v) Config.ESP.Outline = v end)
    local ESP_Filters = Tabs.ESP:AddSection("Filtros ESP"); local function addEspFilter(id,text,cfgK,clrK) ESP_Filters:AddToggle(id,{Text=text,Default=Config.ESP[cfgK]}):OnChanged(function(v)Config.ESP[cfgK]=v;if not v then ESPService:ClearType(text)end end); ESP_Filters:AddColorpicker(id.."Color",{Title="Cor "..text,Default=Config.ESP[clrK]}):OnChanged(function(v)Config.ESP[clrK]=v end) end; addEspFilter("FruitsESP","Fruits","Fruits","FruitColor"); addEspFilter("ChestsESP","Chests","Chests","ChestColor"); addEspFilter("PlayersESP","Players","Players","PlayerColor"); addEspFilter("EnemiesESP","Enemies","Enemies","EnemyColor"); addEspFilter("BossesESP","Bosses","Bosses","BossColor"); addEspFilter("SeaBeastsESP","SeaBeasts","SeaBeasts","SeaBeastColor"); addEspFilter("QuestNPCsESP","QuestNPCs","QuestNPCs","QuestNPCColor"); addEspFilter("ItemsESP","Items","Items","ItemColor"); addEspFilter("FlowersESP","Flowers","Flowers","FlowerColor")

    -- Aba Items/Fruits (Como antes)
    local IF_Auto = Tabs.Items:AddSection("Automação"); IF_Auto:AddToggle("AutoStoreFruitToggle", { Text = "Auto Guardar Fruta Rara (WIP)", Default = Config.Items.AutoStoreFruit}):OnChanged(function(v) Config.Items.AutoStoreFruit = v end); IF_Auto:AddInput("StoreThresholdInput", { Text = "Valor Mínimo Guardar", Default = tostring(Config.Items.StoreThreshold), Numeric = true}):OnChanged(function(v) Config.Items.StoreThreshold = tonumber(v) or 1000000 end)
    local IF_Sniper = Tabs.Items:AddSection("Fruit Sniper (WIP)"); IF_Sniper:AddToggle("FruitSniperToggle", { Text = "Ativar Fruit Sniper", Default = Config.Items.FruitSniper}):OnChanged(function(v) Config.Items.FruitSniper = v end); IF_Sniper:AddDropdown("SniperRarity", { Text = "Raridade Mínima", Default = Config.Items.SniperMinRarity, Values = {"Common","Uncommon","Rare","Legendary","Mythical"}}):OnChanged(function(v) Config.Items.SniperMinRarity = v end); IF_Sniper:AddInput("SniperWebhook", { Text = "Discord Webhook URL", Default = Config.Items.SniperWebhookURL, Placeholder = "Opcional"}):OnChanged(function(v) Config.Items.SniperWebhookURL = v end)

    -- Aba Stats (Como antes)
    local Stats_Auto = Tabs.Stats:AddSection("Auto Distribuição"); Stats_Auto:AddToggle("AutoStatsToggle", { Text = "Ativar Auto Stats", Default = Config.Stats.AutoStats }):OnChanged(AutoStatsService.Toggle); Stats_Auto:AddLabel("Prioridades (Soma usada para proporção):"); Stats_Auto:AddSlider("PrioMelee", { Text = "Melee", Default = Config.Stats.Priority.Melee, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Melee = v end); Stats_Auto:AddSlider("PrioDefense", { Text = "Defense", Default = Config.Stats.Priority.Defense, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Defense = v end); Stats_Auto:AddSlider("PrioSword", { Text = "Sword", Default = Config.Stats.Priority.Sword, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Sword = v end); Stats_Auto:AddSlider("PrioGun", { Text = "Gun", Default = Config.Stats.Priority.Gun, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Gun = v end); Stats_Auto:AddSlider("PrioFruit", { Text = "Blox Fruit", Default = Config.Stats.Priority.Fruit, Min = 0, Max = 10, Rounding = 0 }):OnChanged(function(v) Config.Stats.Priority.Fruit = v end); Stats_Auto:AddButton("Alocar Pontos Agora", AutoStatsService.AllocatePoints)

    -- Aba Misc (Como antes)
    local Misc_Movement = Tabs.Misc:AddSection("Movimento"); Misc_Movement:AddToggle("NoclipToggle", { Text = "Noclip", Default = Config.Misc.NoClip }):OnChanged(ToggleNoClip); Misc_Movement:AddToggle("WalkSpeedToggle", { Text = "WalkSpeed", Default = Config.Misc.WalkSpeedEnabled }):OnChanged(function(v) Config.Misc.WalkSpeedEnabled = v; Humanoid.WalkSpeed = v and Config.Misc.WalkSpeedValue or 16 end); Misc_Movement:AddSlider("WalkSpeedValue", { Text = "Valor WalkSpeed", Default = Config.Misc.WalkSpeedValue, Min = 16, Max = 200, Rounding = 0}):OnChanged(function(v) Config.Misc.WalkSpeedValue = v; if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = v end end); Misc_Movement:AddToggle("JumpPowerToggle", { Text = "JumpPower", Default = Config.Misc.JumpPowerEnabled}):OnChanged(function(v) Config.Misc.JumpPowerEnabled = v; Humanoid.JumpPower = v and Config.Misc.JumpPowerValue or 50 end); Misc_Movement:AddSlider("JumpPowerValue", { Text = "Valor JumpPower", Default = Config.Misc.JumpPowerValue, Min = 50, Max = 300, Rounding = 0}):OnChanged(function(v) Config.Misc.JumpPowerValue = v; if Config.Misc.JumpPowerEnabled then Humanoid.JumpPower = v end end)
    local Misc_Server = Tabs.Misc:AddSection("Servidor"); Misc_Server:AddButton("Server Hop", ServerHop); Misc_Server:AddToggle("HopOnSnipe", { Text = "Hop ao Snipar Fruta (WIP)", Default = Config.Misc.HopOnFruitSnipe }):OnChanged(function(v) Config.Misc.HopOnFruitSnipe = v end); Misc_Server:AddToggle("HopOnPlayer", { Text = "Hop se Player Próximo (WIP)", Default = Config.Misc.HopIfPlayerNearby }):OnChanged(function(v) Config.Misc.HopIfPlayerNearby = v end)
    local Misc_Other = Tabs.Misc:AddSection("Outros"); Misc_Other:AddToggle("AntiAFKToggle", { Text = "Anti-AFK", Default = Config.Misc.AntiAFK }):OnChanged(function(v) Config.Misc.AntiAFK = v; if v and (not State.Connections.AntiAFKRun or not State.Connections.AntiAFKRun.Connected) then State.Connections.AntiAFKRun = RunService.Heartbeat:Connect(AntiAFK) elseif not v and State.Connections.AntiAFKRun and State.Connections.AntiAFKRun.Connected then State.Connections.AntiAFKRun:Disconnect(); State.Connections.AntiAFKRun = nil end end); local redeemInput = Misc_Other:AddInput("RedeemCodesInput", { Text = "Códigos (vírgula)", Default = Config.Misc.RedeemCodes, Placeholder = "CODE1,CODE2"}); Misc_Other:AddButton("Resgatar Códigos", function() local codesRaw=redeemInput.Value; if not codesRaw or codesRaw=="" then Notify("Redeem","Nenhum código.",3); return end; local codes=codesRaw:split(","); Notify("Redeem","Resgatando "..#codes.." códigos...",3); for i,c in ipairs(codes) do local t=c:match("^%s*(.-)%s*$"); if t and #t>0 then Notify("Redeem","Código: "..t.." ("..i.."/"..#codes..")",3); FireServer("Redeem", t); task.wait(1.5) end end; Notify("Redeem","Resgate concluído.",4) end)

    -- Aba Visuals (Como antes)
    local Vis_Env = Tabs.Visuals:AddSection("Ambiente"); Vis_Env:AddToggle("FovToggle", { Text = "FOV", Default = Config.Visuals.FOVEnabled }):OnChanged(function(v) Config.Visuals.FOVEnabled = v; Camera.FieldOfView = v and Config.Visuals.FOVValue or 70 end); Vis_Env:AddSlider("FovSlider", { Text = "Valor FOV", Default = Config.Visuals.FOVValue, Min = 70, Max = 120, Rounding = 0}):OnChanged(function(v) Config.Visuals.FOVValue = v; if Config.Visuals.FOVEnabled then Camera.FieldOfView = v end end); Vis_Env:AddToggle("BrightToggle", { Text = "Brilho", Default = Config.Visuals.BrightnessEnabled}):OnChanged(function(v) Config.Visuals.BrightnessEnabled = v; Lighting.Brightness = v and Config.Visuals.BrightnessValue or 2; Lighting.Ambient = v and Color3.new(0.3,0.3,0.3) or Color3.new(0,0,0); Lighting.OutdoorAmbient = v and Color3.new(0.4,0.4,0.4) or Color3.new(0.5,0.5,0.5) end); Vis_Env:AddSlider("BrightSlider", {Text="Valor Brilho", Default = Config.Visuals.BrightnessValue, Min = 0, Max = 5, Increment = 0.1}):OnChanged(function(v) Config.Visuals.BrightnessValue = v; if Config.Visuals.BrightnessEnabled then Lighting.Brightness = v end end); Vis_Env:AddToggle("NoFogToggle", { Text = "Remover Névoa", Default = Config.Visuals.RemoveFog}):OnChanged(function(v) Config.Visuals.RemoveFog = v; Lighting.FogEnd = v and 100000 or 1000; Lighting.FogStart = v and 90000 or 0 end)

    -- Aba Settings (Como antes)
    local Set_SaveLoad = Tabs.Settings:AddSection("Configurações Salvas"); if SaveManager then Set_SaveLoad:AddButton("Salvar Configs", function() SaveManager:Save(ConfigIdentifier, Config) Notify("Settings", "Salvo!", 3) end); Set_SaveLoad:AddButton("Carregar Configs", function() local loadedConfig = SaveManager:Load(ConfigIdentifier); if loadedConfig then Config = loadedConfig; Notify("Settings", "Carregado!", 3); Window:SetTheme(Config.FluentSettings and Config.FluentSettings.Theme or "Dark"); if Config.Misc.WalkSpeedEnabled then Humanoid.WalkSpeed = Config.Misc.WalkSpeedValue end; if Config.Misc.JumpPowerEnabled then Humanoid.JumpPower = Config.Misc.JumpPowerValue end; if Config.Visuals.FOVEnabled then Camera.FieldOfView = Config.Visuals.FOVValue end; -- TODO: Atualizar UI else Notify("Settings", "Nenhum save.", 4) end end) else Set_SaveLoad:AddLabel("SaveManager falhou."):SetColor(Color3.fromRGB(255,100,100)) end
    local Set_Perf = Tabs.Settings:AddSection("Desempenho e Notificações"); Set_Perf:AddSlider("NotifyDuration", { Text = "Duração Notif (s)", Default = Config.Settings.NotificationDuration, Min = 0, Max = 15, Rounding = 0}):OnChanged(function(v) Config.Settings.NotificationDuration = v end); Set_Perf:AddToggle("PerfMode", { Text = "Modo Performance", Default = Config.Settings.PerformanceMode}):OnChanged(function(v) Config.Settings.PerformanceMode = v; settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
    local Set_Unload = Tabs.Settings:AddSection("Descarregar"); Set_Unload:AddButton("UNLOAD SCRIPT", function() Notify("System","Descarregando...",5); if State and State.Connections then for n,c in pairs(State.Connections) do if type(c)=="RBXScriptConnection" and c.Connected then pcall(c.Disconnect,c) end end; State.Connections={} end; pcall(ESPService.Toggle,false); pcall(AutoFarmService.Toggle,false); pcall(KillAuraService.Toggle,false); pcall(AutoStatsService.Toggle,false); pcall(ToggleNoClip,false); pcall(Window.Destroy,Window); Fluent,SaveManager,InterfaceManager,Window,Tabs,Config,State,Locations=nil,nil,nil,nil,nil,nil,nil,nil; print("RedzHub Unloaded.") end):SetTextColor(Color3.fromRGB(255,80,80))

    -- Interface Manager (Como antes)
    if InterfaceManager and Fluent then pcall(InterfaceManager.SetLibrary, InterfaceManager, Fluent); pcall(InterfaceManager.BindInput, InterfaceManager, Mouse) end

    -- Notificação Final
    Notify("RedzHub Loaded", "Script inicializado. UI Pronta!", 5)
    print("RedzHub Inspired Script Loaded and UI Populated.")

else warn("ERRO: Falha ao criar as Tabs. A UI não pode ser populada.") if Window then pcall(Window.Destroy, Window) end end

-- // FIM DO SCRIPT --
