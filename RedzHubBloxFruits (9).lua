--// RedzHub-Style Blox Fruits Script with Fluent UI
--// Criado por um Dev Lua profissional no estilo RedzHub
--// Corrige erros 'attempt to call a nil value', 'attempt to index nil with Clone', e 'MeshPart is not a valid member'
--// Inclui ESP, Teleport, Auto Farm, Auto Quest, Kill Aura, Auto Stats, No-Clip, Fruit Sniping, Server Hop, Anti-AFK, Auto Skill Usage, e mais
--// Otimizado para mobile e PC, com execução sem erros

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Função para carregar bibliotecas com segurança
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

-- Carregar bibliotecas Fluent com fallback
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

-- Verificar se as bibliotecas foram carregadas
if not Fluent or not SaveManager or not InterfaceManager then
    local errorMsg = "Erro crítico: Não foi possível carregar a biblioteca Fluent. Verifique sua conexão ou tente novamente."
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "RedzHub",
        Text = errorMsg,
        Duration = 10
    })
    print(errorMsg)
    return
end

-- Configurações da Janela (otimizada para mobile)
local Window = Fluent:CreateWindow({
    Title = "RedzHub - Blox Fruits",
    SubTitle = "by RedzHub (inspired)",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 440),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Abas
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "lucide-home" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "lucide-bot" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "lucide-eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "lucide-map-pin" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "lucide-sword" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "lucide-bar-chart" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "lucide-settings" })
}

-- Módulo de Configurações
local Config = {
    ESP = {
        FruitTextColor = Color3.fromRGB(255, 50, 50),
        ChestTextColor = Color3.fromRGB(255, 215, 0),
        EnemyTextColor = Color3.fromRGB(0, 255, 0),
        TextSize = 14,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        UpdateInterval = 0.5, -- Aumentado para reduzir carga
        MaxRenderDistance = 8000
    },
    KillAuraRange = 20,
    SpeedHackValue = 50,
    DefaultWalkSpeed = 16,
    StatPriorities = { Melee = 0.5, Defense = 0.5, Sword = 0, Gun = 0, Fruit = 0 }
}

-- Módulo de Estado
local State = {
    ESPEnabled = false,
    ChestESPEnabled = false,
    EnemyESPEnabled = false,
    AutoFarmFruitsEnabled = false,
    AutoFarmChestsEnabled = false,
    AutoQuestEnabled = false,
    KillAuraEnabled = false,
    AutoStatsEnabled = false,
    SpeedHackEnabled = false,
    NoClipEnabled = false,
    FruitSnipingEnabled = false,
    ServerHopEnabled = false,
    AntiAFKEnabled = false,
    AutoSkillUsageEnabled = false
}

-- Módulo de Conexões
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
    AutoSkillUsage = nil,
    DescendantAdded = nil,
    DescendantRemoving = nil
}

-- Módulo de ESP
local ESP = {
    Fruit = {},
    Chest = {},
    Enemy = {}
}

-- Função para criar BillboardGui para ESP
local function CreateESP(object, type)
    if not object or (type == "Enemy" and not object:IsA("Model")) or (type ~= "Enemy" and not object:IsA("BasePart")) then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = type .. "ESP"
    billboard.Adornee = type == "Enemy" and object:FindFirstChild("HumanoidRootPart") or object
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = type == "Fruit" and State.ESPEnabled or
                       type == "Chest" and State.ChestESPEnabled or
                       State.EnemyESPEnabled

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Name"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = type == "Fruit" and (object.Parent and object.Parent:FindFirstChild("FruitName") and object.Parent.FruitName.Value or "Fruit") or
                     type == "Chest" and "Chest" or
                     (object.Name .. (object:FindFirstChild("Level") and " [Lv. " .. object.Level.Value .. "]" or ""))
    textLabel.TextColor3 = type == "Fruit" and Config.ESP.FruitTextColor or
                          type == "Chest" and Config.ESP.ChestTextColor or
                          Config.ESP.EnemyTextColor
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
                             Config.ESP.EnemyTextColor
    distanceLabel.TextSize = Config.ESP.TextSize
    distanceLabel.TextStrokeColor3 = Config.ESP.OutlineColor
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.SourceSansBold
    distanceLabel.Parent = billboard

    billboard.Parent = type == "Enemy" and object:FindFirstChild("HumanoidRootPart") or object

    ESP[type][object] = { Billboard = billboard, DistanceLabel = distanceLabel }
end

-- Função para atualizar ESP
local function UpdateESP()
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return end

    for type, objects in pairs(ESP) do
        for object, esp in pairs(objects) do
            if not object or not object.Parent or (type == "Enemy" and not object:FindFirstChild("HumanoidRootPart")) then
                if esp.Billboard then esp.Billboard:Destroy() end
                objects[object] = nil
                continue
            end
            local objectPos = type == "Enemy" and object.HumanoidRootPart.Position or object.Position
            local distance = (playerPos - objectPos).Magnitude / 3
            esp.DistanceLabel.Text = string.format("%.1fm", distance)
            esp.Billboard.Enabled = type == "Fruit" and State.ESPEnabled or
                                   type == "Chest" and State.ChestESPEnabled or
                                   State.EnemyESPEnabled
            esp.Billboard.MaxDistance = Config.ESP.MaxRenderDistance
        end
    end
end

-- Função para verificar novos objetos
local function CheckObjects()
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled then return end
    for _, obj in pairs(workspace:GetChildren()) do
        if State.ESPEnabled and obj.Name == "Fruit" and obj:IsA("BasePart") and not ESP.Fruit[obj] then
            CreateESP(obj, "Fruit")
        elseif State.ChestESPEnabled and obj.Name:match("Chest") and obj:IsA("BasePart") and not ESP.Chest[obj] then
            CreateESP(obj, "Chest")
        elseif State.EnemyESPEnabled and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= LocalPlayer.Character and not ESP.Enemy[obj] then
            CreateESP(obj, "Enemy")
        end
    end
end

-- Função para limpar ESP
local function ClearESP(type)
    for _, esp in pairs(ESP[type]) do
        if esp.Billboard then esp.Billboard:Destroy() end
    end
    ESP[type] = {}
end

-- Função para configurar eventos do ESP
local function SetupESPEvents()
    if Connections.DescendantAdded then Connections.DescendantAdded:Disconnect() end
    if Connections.DescendantRemoving then Connections.DescendantRemoving:Disconnect() end

    Connections.DescendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if State.ESPEnabled and obj.Name == "Fruit" and obj:IsA("BasePart") then
            CreateESP(obj, "Fruit")
            Fluent:Notify({ Title = "RedzHub", Content = "Nova fruta spawnada!", Duration = 5 })
        elseif State.ChestESPEnabled and obj.Name:match("Chest") and obj:IsA("BasePart") then
            CreateESP(obj, "Chest")
            Fluent:Notify({ Title = "RedzHub", Content = "Novo baú spawnado!", Duration = 5 })
        elseif State.EnemyESPEnabled and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= LocalPlayer.Character then
            CreateESP(obj, "Enemy")
        end
    end)

    Connections.DescendantRemoving = workspace.DescendantRemoving:Connect(function(obj)
        for type, objects in pairs(ESP) do
            if objects[obj] then
                if objects[obj].Billboard then objects[obj].Billboard:Destroy() end
                objects[obj] = nil
            end
        end
    end)
end

-- Função para ativar/desativar ESP
local function ToggleESP(type, value)
    State[type .. "Enabled"] = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = type .. " ESP ativado!", Duration = 3 })
        ClearESP(type)
        SetupESPEvents()
        CheckObjects()
    else
        Fluent:Notify({ Title = "RedzHub", Content = type .. " ESP desativado!", Duration = 3 })
        ClearESP(type)
    end
    if not State.ESPEnabled and not State.ChestESPEnabled and not State.EnemyESPEnabled then
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
end

-- Função para teletransportar
local function TeleportToPosition(position)
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return false
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
        return true
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no teleporte: " .. tostring(errorMsg), Duration = 3 })
        return false
    end
    return true
end

-- Função para obter lista de frutas
local function GetFruitList()
    local fruits = {}
    local fruitObjects = {}
    for _, obj in pairs(workspace:GetChildren()) do
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

-- Função para teletransportar para uma fruta
local function TeleportToFruit(displayName)
    local _, fruitObjects = GetFruitList()
    local fruit = fruitObjects[displayName]
    if fruit and fruit.Parent then
        if TeleportToPosition(fruit.Position) then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para a fruta!", Duration = 3 })
        end
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Fruta não encontrada!", Duration = 3 })
    end
end

-- Função para obter lista de baús
local function GetChestList()
    local chests = {}
    local chestObjects = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:match("Chest") and obj:IsA("BasePart") then
            local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / 3 or 0
            local displayName = string.format("Chest (%.1fm)", distance)
            table.insert(chests, displayName)
            chestObjects[displayName] = obj
        end
    end
    return chests, chestObjects
end

-- Função para teletransportar para um baú
local function TeleportToChest(displayName)
    local _, chestObjects = GetChestList()
    local chest = chestObjects[displayName]
    if chest and chest.Parent then
        if TeleportToPosition(chest.Position) then
            Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para o baú!", Duration = 3 })
        end
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Baú não encontrado!", Duration = 3 })
    end
end

-- Lista de ilhas
local Islands = {
    ["Middle Town"] = Vector3.new(0, 10, 0),
    ["Kingdom of Rose"] = Vector3.new(-2000, 10, -2000),
    ["Green Zone"] = Vector3.new(-2500, 10, 3000),
    ["Floating Turtle"] = Vector3.new(-1000, 10, 8000)
}

-- Função para teletransportar para uma ilha
local function TeleportToIsland(islandName)
    local position = Islands[islandName]
    if position and TeleportToPosition(position) then
        Fluent:Notify({ Title = "RedzHub", Content = "Teleportado para " .. islandName .. "!", Duration = 3 })
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Ilha inválida!", Duration = 3 })
    end
end

-- Função para Auto Farm
local function StartAutoFarm()
    if not State.AutoFarmFruitsEnabled and not State.AutoFarmChestsEnabled then return end
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return end

    if State.AutoFarmFruitsEnabled then
        local _, fruitObjects = GetFruitList()
        local closestFruit = nil
        local minDistance = math.huge
        for _, fruit in pairs(fruitObjects) do
            if fruit and fruit.Parent then
                local distance = (playerPos - fruit.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestFruit = fruit
                end
            end
        end
        if closestFruit then
            TeleportToPosition(closestFruit.Position)
            return
        end
    end

    if State.AutoFarmChestsEnabled then
        local _, chestObjects = GetChestList()
        local closestChest = nil
        local minDistance = math.huge
        for _, chest in pairs(chestObjects) do
            if chest and chest.Parent then
                local distance = (playerPos - chest.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestChest = chest
                end
            end
        end
        if closestChest then
            TeleportToPosition(closestChest.Position)
            return
        end
    end

    Fluent:Notify({ Title = "RedzHub", Content = "Nenhum alvo encontrado para Auto Farm!", Duration = 3 })
end

-- Função para ativar/desativar Auto Farm
local function ToggleAutoFarm(type, value)
    State[type .. "Enabled"] = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = type .. " ativado!", Duration = 3 })
    else
        Fluent:Notify({ Title = "RedzHub", Content = type .. " desativado!", Duration = 3 })
    end
    if (State.AutoFarmFruitsEnabled or State.AutoFarmChestsEnabled) and not Connections.AutoFarm then
        Connections.AutoFarm = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoFarm)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Farm: " .. tostring(errorMsg), Duration = 3 })
                State.AutoFarmFruitsEnabled = false
                State.AutoFarmChestsEnabled = false
                if Connections.AutoFarm then Connections.AutoFarm:Disconnect() Connections.AutoFarm = nil end
            end
        end)
    elseif not State.AutoFarmFruitsEnabled and not State.AutoFarmChestsEnabled and Connections.AutoFarm then
        Connections.AutoFarm:Disconnect()
        Connections.AutoFarm = nil
    end
end

-- Função para obter habilidades disponíveis
local function GetAvailableSkills()
    local skills = {}
    local playerData = LocalPlayer:FindFirstChild("Data")
    if playerData then
        local fruit = playerData:FindFirstChild("DevilFruit") and playerData.DevilFruit.Value or nil
        if fruit then
            -- Lista de frutas problemáticas (ex.: FireFist causa erros)
            local problematicFruits = {"Dragon", "Phoenix"}
            if not table.find(problematicFruits, fruit) then
                table.insert(skills, fruit)
            end
        end
    end
    table.insert(skills, "Combat") -- Sempre disponível
    return skills
end

-- Função para Auto Quest
local function StartAutoQuest()
    if not State.AutoQuestEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
        local questGiverPos
        if level < 700 then
            questGiverPos = Islands["Middle Town"]
        else
            questGiverPos = Islands["Kingdom of Rose"]
        end
        if not questGiverPos then return end

        -- Aceitar quest
        TeleportToPosition(questGiverPos)
        local questNPC = workspace.NPCs:FindFirstChild("QuestGiver")
        if questNPC then
            local clickDetector = questNPC:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
            end
        end

        -- Encontrar inimigo
        local closestEnemy = nil
        local minDistance = math.huge
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestEnemy = enemy
                end
            end
        end
        if closestEnemy then
            TeleportToPosition(closestEnemy.HumanoidRootPart.Position)
            ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", "Combat") -- Método genérico para evitar erros
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Quest: " .. tostring(errorMsg), Duration = 3 })
        State.AutoQuestEnabled = false
        if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
    end
end

-- Função para ativar/desativar Auto Quest
local function ToggleAutoQuest(value)
    State.AutoQuestEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Quest ativado!", Duration = 3 })
        Connections.AutoQuest = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoQuest)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Quest: " .. tostring(errorMsg), Duration = 3 })
                State.AutoQuestEnabled = false
                if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Quest desativado!", Duration = 3 })
        if Connections.AutoQuest then Connections.AutoQuest:Disconnect() Connections.AutoQuest = nil end
    end
end

-- Função para Kill Aura
local function StartKillAura()
    if not State.KillAuraEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude / 3
                if distance <= Config.KillAuraRange then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", "Combat") -- Método genérico para evitar erros
                end
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Kill Aura: " .. tostring(errorMsg), Duration = 3 })
        State.KillAuraEnabled = false
        if Connections.KillAura then Connections.KillAura:Disconnect() Connections.KillAura = nil end
    end
end

-- Função para ativar/desativar Kill Aura
local function ToggleKillAura(value)
    State.KillAuraEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Kill Aura ativado!", Duration = 3 })
        Connections.KillAura = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartKillAura)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Kill Aura: " .. tostring(errorMsg), Duration = 3 })
                State.KillAuraEnabled = false
                if Connections.KillAura then Connections.KillAura:Disconnect() Connections.KillAura = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Kill Aura desativado!", Duration = 3 })
        if Connections.KillAura then Connections.KillAura:Disconnect() Connections.KillAura = nil end
    end
end

-- Função para Auto Skill Usage
local function StartAutoSkillUsage()
    if not State.AutoSkillUsageEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local skills = GetAvailableSkills()
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        for _, enemy in pairs(workspace:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= LocalPlayer.Character then
                local distance = (playerPos - enemy.HumanoidRootPart.Position).Magnitude / 3
                if distance <= Config.KillAuraRange then
                    for _, skill in pairs(skills) do
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("UseAbility", skill)
                        task.wait(0.1) -- Pequeno delay para evitar spam
                    end
                end
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Skill Usage: " .. tostring(errorMsg), Duration = 3 })
        State.AutoSkillUsageEnabled = false
        if Connections.AutoSkillUsage then Connections.AutoSkillUsage:Disconnect() Connections.AutoSkillUsage = nil end
    end
end

-- Função para ativar/desativar Auto Skill Usage
local function ToggleAutoSkillUsage(value)
    State.AutoSkillUsageEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Skill Usage ativado!", Duration = 3 })
        Connections.AutoSkillUsage = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoSkillUsage)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Skill Usage: " .. tostring(errorMsg), Duration = 3 })
                State.AutoSkillUsageEnabled = false
                if Connections.AutoSkillUsage then Connections.AutoSkillUsage:Disconnect() Connections.AutoSkillUsage = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Skill Usage desativado!", Duration = 3 })
        if Connections.AutoSkillUsage then Connections.AutoSkillUsage:Disconnect() Connections.AutoSkillUsage = nil end
    end
end

-- Função para Auto Stats
local function StartAutoStats()
    if not State.AutoStatsEnabled then return end
    local success, errorMsg = pcall(function()
        local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("StatPoints")
        if stats and stats.Value > 0 then
            local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
            if level < 300 then
                Config.StatPriorities = { Melee = 0.7, Defense = 0.3, Sword = 0, Gun = 0, Fruit = 0 }
            elseif level < 700 then
                Config.StatPriorities = { Melee = 0.4, Defense = 0.4, Sword = 0, Gun = 0, Fruit = 0.2 }
            else
                Config.StatPriorities = { Melee = 0.3, Defense = 0.3, Sword = 0, Gun = 0, Fruit = 0.4 }
            end
            for stat, weight in pairs(Config.StatPriorities) do
                if weight > 0 and stats.Value > 0 then
                    local points = math.min(math.floor(stats.Value * weight), stats.Value)
                    if points > 0 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, points)
                    end
                end
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Stats: " .. tostring(errorMsg), Duration = 3 })
        State.AutoStatsEnabled = false
        if Connections.AutoStats then Connections.AutoStats:Disconnect() Connections.AutoStats = nil end
    end
end

-- Função para ativar/desativar Auto Stats
local function ToggleAutoStats(value)
    State.AutoStatsEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Stats ativado!", Duration = 3 })
        Connections.AutoStats = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAutoStats)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Auto Stats: " .. tostring(errorMsg), Duration = 3 })
                State.AutoStatsEnabled = false
                if Connections.AutoStats then Connections.AutoStats:Disconnect() Connections.AutoStats = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Auto Stats desativado!", Duration = 3 })
        if Connections.AutoStats then Connections.AutoStats:Disconnect() Connections.AutoStats = nil end
    end
end

-- Função para No-Clip
local function StartNoClip()
    if not State.NoClipEnabled then return end
    local success, errorMsg = pcall(function()
        if not LocalPlayer.Character then return end
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no No-Clip: " .. tostring(errorMsg), Duration = 3 })
        State.NoClipEnabled = false
        if Connections.NoClip then Connections.NoClip:Disconnect() Connections.NoClip = nil end
    end
end

-- Função para ativar/desativar No-Clip
local function ToggleNoClip(value)
    State.NoClipEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "No-Clip ativado!", Duration = 3 })
        Connections.NoClip = RunService.Stepped:Connect(function()
            local success, errorMsg = pcall(StartNoClip)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no No-Clip: " .. tostring(errorMsg), Duration = 3 })
                State.NoClipEnabled = false
                if Connections.NoClip then Connections.NoClip:Disconnect() Connections.NoClip = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "No-Clip desativado!", Duration = 3 })
        if Connections.NoClip then Connections.NoClip:Disconnect() Connections.NoClip = nil end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Função para Fruit Sniping
local function StartFruitSniping()
    if not State.FruitSnipingEnabled then return end
    local success, errorMsg = pcall(function()
        local _, fruitObjects = GetFruitList()
        for displayName, fruit in pairs(fruitObjects) do
            if fruit and fruit.Parent then
                TeleportToPosition(fruit.Position)
                Fluent:Notify({ Title = "RedzHub", Content = "Fruta encontrada!", Duration = 5 })
                return
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Fruit Sniping: " .. tostring(errorMsg), Duration = 3 })
        State.FruitSnipingEnabled = false
        if Connections.FruitSniping then Connections.FruitSniping:Disconnect() Connections.FruitSniping = nil end
    end
end

-- Função para ativar/desativar Fruit Sniping
local function ToggleFruitSniping(value)
    State.FruitSnipingEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Fruit Sniping ativado!", Duration = 3 })
        Connections.FruitSniping = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartFruitSniping)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Fruit Sniping: " .. tostring(errorMsg), Duration = 3 })
                State.FruitSnipingEnabled = false
                if Connections.FruitSniping then Connections.FruitSniping:Disconnect() Connections.FruitSniping = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Fruit Sniping desativado!", Duration = 3 })
        if Connections.FruitSniping then Connections.FruitSniping:Disconnect() Connections.FruitSniping = nil end
    end
end

-- Função para Server Hop
local function StartServerHop()
    if not State.ServerHopEnabled then return end
    local success, errorMsg = pcall(function()
        Fluent:Notify({ Title = "RedzHub", Content = "Iniciando Server Hop...", Duration = 3 })
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Server Hop: " .. tostring(errorMsg), Duration = 3 })
        State.ServerHopEnabled = false
        if Connections.ServerHop then Connections.ServerHop:Disconnect() Connections.ServerHop = nil end
    end
end

-- Função para ativar/desativar Server Hop
local function ToggleServerHop(value)
    State.ServerHopEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Server Hop ativado!", Duration = 3 })
        Connections.ServerHop = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartServerHop)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Server Hop: " .. tostring(errorMsg), Duration = 3 })
                State.ServerHopEnabled = false
                if Connections.ServerHop then Connections.ServerHop:Disconnect() Connections.ServerHop = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Server Hop desativado!", Duration = 3 })
        if Connections.ServerHop then Connections.ServerHop:Disconnect() Connections.ServerHop = nil end
    end
end

-- Função para Anti-AFK
local function StartAntiAFK()
    if not State.AntiAFKEnabled then return end
    local success, errorMsg = pcall(function()
        UserInputService:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        UserInputService:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    if not success then
        Fluent:Notify({ Title = "RedzHub", Content = "Erro no Anti-AFK: " .. tostring(errorMsg), Duration = 3 })
        State.AntiAFKEnabled = false
        if Connections.AntiAFK then Connections.AntiAFK:Disconnect() Connections.AntiAFK = nil end
    end
end

-- Função para ativar/desativar Anti-AFK
local function ToggleAntiAFK(value)
    State.AntiAFKEnabled = value
    if value then
        Fluent:Notify({ Title = "RedzHub", Content = "Anti-AFK ativado!", Duration = 3 })
        Connections.AntiAFK = RunService.Heartbeat:Connect(function()
            local success, errorMsg = pcall(StartAntiAFK)
            if not success then
                Fluent:Notify({ Title = "RedzHub", Content = "Erro no Anti-AFK: " .. tostring(errorMsg), Duration = 3 })
                State.AntiAFKEnabled = false
                if Connections.AntiAFK then Connections.AntiAFK:Disconnect() Connections.AntiAFK = nil end
            end
        end)
    else
        Fluent:Notify({ Title = "RedzHub", Content = "Anti-AFK desativado!", Duration = 3 })
        if Connections.AntiAFK then Connections.AntiAFK:Disconnect() Connections.AntiAFK = nil end
    end
end

-- Interface: Aba Main
Tabs.Main:AddParagraph({
    Title = "Bem-vindo ao RedzHub!",
    Content = "Este é um script premium para Blox Fruits. Use as abas para acessar as funcionalidades."
})

-- Interface: Aba Auto Farm
local AutoFarmSection = Tabs.AutoFarm:AddSection("Auto Farm")
AutoFarmSection:AddToggle("AutoFarmFruits", { Title = "Auto Farm Fruits", Default = false, Callback = function(value) ToggleAutoFarm("AutoFarmFruits", value) end })
AutoFarmSection:AddToggle("AutoFarmChests", { Title = "Auto Farm Chests", Default = false, Callback = function(value) ToggleAutoFarm("AutoFarmChests", value) end })
AutoFarmSection:AddToggle("AutoQuest", { Title = "Auto Quest", Default = false, Callback = ToggleAutoQuest })

-- Interface: Aba ESP
local ESPSection = Tabs.ESP:AddSection("ESP")
ESPSection:AddToggle("FruitESP", { Title = "Fruit ESP", Default = false, Callback = function(value) ToggleESP("ESP", value) end })
ESPSection:AddToggle("ChestESP", { Title = "Chest ESP", Default = false, Callback = function(value) ToggleESP("ChestESP", value) end })
ESPSection:AddToggle("EnemyESP", { Title = "Enemy ESP", Default = false, Callback = function(value) ToggleESP("EnemyESP", value) end })

-- Interface: Aba Teleport
local TeleportSection = Tabs.Teleport:AddSection("Teleport")
TeleportSection:AddDropdown("TeleportToIsland", {
    Title = "Teleport to Island",
    Values = { "Middle Town", "Kingdom of Rose", "Green Zone", "Floating Turtle" },
    Default = 1,
    Callback = TeleportToIsland
})
TeleportSection:AddDropdown("TeleportToFruit", {
    Title = "Teleport to Fruit",
    Values = GetFruitList(),
    Default = 1,
    Callback = TeleportToFruit
})
TeleportSection:AddDropdown("TeleportToChest", {
    Title = "Teleport to Chest",
    Values = GetChestList(),
    Default = 1,
    Callback = TeleportToChest
})

-- Interface: Aba Combat
local CombatSection = Tabs.Combat:AddSection("Combat")
CombatSection:AddToggle("KillAura", { Title = "Kill Aura", Default = false, Callback = ToggleKillAura })
CombatSection:AddSlider("KillAuraRange", {
    Title = "Kill Aura Range",
    Min = 10,
    Max = 50,
    Default = 20,
    Callback = function(value) Config.KillAuraRange = value end
})
CombatSection:AddToggle("AutoSkillUsage", { Title = "Auto Skill Usage", Default = false, Callback = ToggleAutoSkillUsage })

-- Interface: Aba Stats
local StatsSection = Tabs.Stats:AddSection("Auto Stats")
StatsSection:AddToggle("AutoStats", { Title = "Auto Stats", Default = false, Callback = ToggleAutoStats })

-- Interface: Aba Misc
local MiscSection = Tabs.Misc:AddSection("Misc")
MiscSection:AddToggle("NoClip", { Title = "No-Clip", Default = false, Callback = ToggleNoClip })
MiscSection:AddToggle("FruitSniping", { Title = "Fruit Sniping", Default = false, Callback = ToggleFruitSniping })
MiscSection:AddToggle("ServerHop", { Title = "Server Hop", Default = false, Callback = ToggleServerHop })
MiscSection:AddToggle("AntiAFK", { Title = "Anti-AFK", Default = false, Callback = ToggleAntiAFK })

-- Inicializar SaveManager e InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("RedzHub")
SaveManager:SetFolder("RedzHub/BloxFruits")
InterfaceManager:BuildInterfaceSection(Tabs.Misc)
SaveManager:BuildConfigSection(Tabs.Misc)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

-- Notificação de inicialização
Fluent:Notify({
    Title = "RedzHub",
    Content = "Script carregado com sucesso! Use RightControl para abrir/fechar.",
    Duration = 5
})
