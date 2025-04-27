-- BloxMobile Library
-- Biblioteca mobile-friendly para Blox Fruits
-- Inspirada em RedZHub com suporte completo para dispositivos móveis

-- Serviços e variáveis
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Teams = game:GetService("Teams")

-- Verificar se o jogo é Blox Fruits
local GameIds = {2753915549, 4442272183, 7449423635}
local IsBloxFruits = false

for _, id in pairs(GameIds) do
    if game.PlaceId == id then
        IsBloxFruits = true
        break
    end
end

if not IsBloxFruits then
    warn("⚠️ Este script foi projetado para Blox Fruits! Algumas funções podem não funcionar!")
end

-- Funções de utilitário
local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoidRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChild("Humanoid")
end

-- Módulo principal
local BloxMobile = {}
BloxMobile.Settings = {
    AutoFarm = {
        Enabled = false,
        Target = "Nearest", -- "Nearest", "Specific", "Quest"
        SpecificMob = "Bandit",
        LevelRange = {Min = 0, Max = 999999},
        Distance = 7,
        AttackMethod = "Normal", -- "Normal", "Fast", "Skill"
        UseSkills = true,
        AutoEquipWeapon = true,
        SelectedWeapon = "Combat",
        TeleportSpeed = 150
    },
    AutoQuest = {
        Enabled = false,
        QuestName = "",
        AutoFarm = true,
        CompleteQuest = true
    },
    Fruits = {
        AutoCollect = false,
        ESPEnabled = false,
        StoreFruit = false,
        TeleportToFruit = false,
        RaidBoss = false
    },
    Teleport = {
        SelectedLocation = "Starter Island",
        InstantTP = false,
        SafeMode = true
    },
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        AutoHaki = false,
        NoClip = false,
        InfiniteEnergy = false,
        InfiniteAbility = false,
        FastAttack = false,
        AutoRejoin = true
    },
    ESP = {
        Players = false,
        PlayerInfo = true,
        Fruits = false,
        Chests = false,
        FlowerESP = false,
        IslandESP = false,
        MobESP = false,
        ESPColor = {
            Players = Color3.fromRGB(0, 255, 255),
            Fruits = Color3.fromRGB(255, 255, 0),
            Chests = Color3.fromRGB(255, 170, 0),
            Flowers = Color3.fromRGB(85, 255, 127),
            Islands = Color3.fromRGB(170, 170, 255),
            Mobs = Color3.fromRGB(255, 0, 0)
        },
        DrawDistance = 2000
    },
    Raid = {
        AutoRaid = false,
        SelectedRaid = "Flame",
        AutoBuy = false,
        ChipType = "Flame",
        RaidMode = "Normal" -- "Normal", "GodMode", "Teleport"
    },
    Stats = {
        AutoStats = false,
        SelectedStat = "Melee",
        PointsPerStat = 3
    },
    Shop = {
        AutoBuySword = false,
        AutoBuyFruit = false,
        SelectedFruit = "None",
        AutoBuyEnchancement = false,
        SelectedEnchancement = "None"
    },
    Misc = {
        AutoSeaBeast = false,
        AutoChests = false,
        ServerHop = false,
        LowPlayerServer = false,
        InfiniteAbility = false
    },
    UI = {
        Scale = 1.0, -- Para dispositivos móveis
        Position = UDim2.new(0.5, -250, 0.5, -175), -- Centralizado
        Transparency = 0.1,
        MainColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        CurrentTab = "Home",
        MobileMode = true
    }
}

BloxMobile.GameData = {
    Mobs = {},
    Quests = {},
    Swords = {},
    Fruits = {},
    Islands = {
        ["Starter Island"] = CFrame.new(1071.2832, 16.3085976, 1426.86792),
        ["Marine Island"] = CFrame.new(-2566.4296875, 6.8556280136108, 2045.2561035156),
        ["Middle Town"] = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094),
        ["Jungle Island"] = CFrame.new(-1612.7957763672, 36.852081298828, 149.12843322754),
        ["Pirate Island"] = CFrame.new(-1181.3093261719, 4.7514905929565, 3803.5456542969),
        ["Desert Island"] = CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688),
        ["Frozen Island"] = CFrame.new(1131.0004882813, 15.114521026611, -5763.58984375),
        ["MarineFord"] = CFrame.new(-4914.8212890625, 50.963626861572, 4281.0278320313),
        ["Colosseum"] = CFrame.new(-1428.3499755859, 7.3890161514282, -3014.5783691406),
        ["Sky Island"] = CFrame.new(-4869.1025390625, 733.46051025391, -2667.0180664063),
        ["Prison"] = CFrame.new(4857.6982421875, 5.6780304908752, 732.75396728516),
        ["Magma Island"] = CFrame.new(-5328.8740234375, 8.6164665222168, 8427.3994140625),
        ["Underwater City"] = CFrame.new(61163.8515625, 11.7796783447266, 1819.7841796875),
        ["Fountain City"] = CFrame.new(5132.7124023438, 4.1253061294556, 4037.8706054688),
        ["Haunted Castle"] = CFrame.new(-9530.6153, 142.130661, 5537.8335),
        ["Ice Castle"] = CFrame.new(5432.1665, 28.7117558, -6131.4189),
        ["Great Tree"] = CFrame.new(2276.0356, 25.8906536, -6493.06396)
    }
}

-- Variáveis de funcionamento
local Connections = {}
local ESPObjects = {}
local ActiveMobs = {}
local CurrentQuest = nil
local ScriptLoaded = false
local TargetMob = nil
local IsAttacking = false
local IsNoClipping = false

-- Sistema de ESP
function BloxMobile:CreateESP(object, text, color)
    if ESPObjects[object] then return ESPObjects[object] end
    
    local esp = Drawing.new("Text")
    esp.Visible = false
    esp.Center = true
    esp.Outline = true
    esp.Font = 2
    esp.Size = 16 -- Maior para mobile
    esp.Color = color or self.Settings.ESP.ESPColor.Players
    esp.Text = text or "ESP"
    
    ESPObjects[object] = esp
    return esp
end

function BloxMobile:UpdateESP()
    local camera = workspace.CurrentCamera
    
    for object, esp in pairs(ESPObjects) do
        if object and object.Parent ~= nil then
            local pos, onScreen = camera:WorldToViewportPoint(object.Position)
            
            if onScreen and pos.Z < self.Settings.ESP.DrawDistance then
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Visible = true
                
                -- Atualiza informações do ESP
                if self.Settings.ESP.PlayerInfo and Players:GetPlayerFromCharacter(object.Parent) then
                    local player = Players:GetPlayerFromCharacter(object.Parent)
                    local health = object.Parent:FindFirstChild("Humanoid") and object.Parent.Humanoid.Health or 0
                    local maxHealth = object.Parent:FindFirstChild("Humanoid") and object.Parent.Humanoid.MaxHealth or 0
                    esp.Text = player.Name .. " [" .. math.floor(health) .. "/" .. math.floor(maxHealth) .. "]"
                elseif object.Parent:FindFirstChild("Humanoid") then
                    local health = object.Parent.Humanoid.Health
                    local maxHealth = object.Parent.Humanoid.MaxHealth
                    esp.Text = object.Parent.Name .. " [" .. math.floor(health) .. "/" .. math.floor(maxHealth) .. "]"
                end
                
            else
                esp.Visible = false
            end
        else
            esp.Visible = false
            ESPObjects[object] = nil
            esp:Remove()
        end
    end
end

-- Configurações de ESP
function BloxMobile:TogglePlayerESP(enabled)
    self.Settings.ESP.Players = enabled
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                self:CreateESP(player.Character.HumanoidRootPart, player.Name, self.Settings.ESP.ESPColor.Players)
            end
        end
        
        table.insert(Connections, Players.PlayerAdded:Connect(function(player)
            if player.Character then
                self:CreateESP(player.Character.HumanoidRootPart, player.Name, self.Settings.ESP.ESPColor.Players)
            end
            player.CharacterAdded:Connect(function(char)
                wait(1)
                if char:FindFirstChild("HumanoidRootPart") then
                    self:CreateESP(char.HumanoidRootPart, player.Name, self.Settings.ESP.ESPColor.Players)
                end
            end)
        end))
    else
        for object, esp in pairs(ESPObjects) do
            if object.Parent and Players:GetPlayerFromCharacter(object.Parent) then
                esp.Visible = false
                ESPObjects[object] = nil
                esp:Remove()
            end
        end
    end
end

function BloxMobile:ToggleFruitESP(enabled)
    self.Settings.ESP.Fruits = enabled
    
    if enabled then
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name:find("Fruit") or v.Name:lower():find("fruta") then
                local part = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
                if part then
                    self:CreateESP(part, "FRUTA: " .. v.Name, self.Settings.ESP.ESPColor.Fruits)
                end
            end
        end
        
        table.insert(Connections, workspace.ChildAdded:Connect(function(child)
            wait(1)
            if child.Name:find("Fruit") or child.Name:lower():find("fruta") then
                local part = child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")
                if part then
                    self:CreateESP(part, "FRUTA: " .. child.Name, self.Settings.ESP.ESPColor.Fruits)
                end
            end
        end))
    else
        for object, esp in pairs(ESPObjects) do
            if object.Parent and (object.Parent.Name:find("Fruit") or object.Parent.Name:lower():find("fruta")) then
                esp.Visible = false
                ESPObjects[object] = nil
                esp:Remove()
            end
        end
    end
end

function BloxMobile:ToggleChestESP(enabled)
    self.Settings.ESP.Chests = enabled
    
    if enabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:find("Chest") or v.Name:lower():find("bau") then
                local part = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart") or v
                if part:IsA("BasePart") then
                    self:CreateESP(part, "BAÚ: " .. v.Name, self.Settings.ESP.ESPColor.Chests)
                end
            end
        end
    else
        for object, esp in pairs(ESPObjects) do
            if object.Parent and (object.Parent.Name:find("Chest") or object.Parent.Name:lower():find("bau")) then
                esp.Visible = false
                ESPObjects[object] = nil
                esp:Remove()
            end
        end
    end
end

function BloxMobile:ToggleMobESP(enabled)
    self.Settings.ESP.MobESP = enabled
    
    if enabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
               and not Players:GetPlayerFromCharacter(v) then
                self:CreateESP(v.HumanoidRootPart, "MOB: " .. v.Name, self.Settings.ESP.ESPColor.Mobs)
                table.insert(ActiveMobs, v)
            end
        end
        
        table.insert(Connections, workspace.DescendantAdded:Connect(function(descendant)
            wait(1)
            if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") and 
               descendant:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(descendant) then
                self:CreateESP(descendant.HumanoidRootPart, "MOB: " .. descendant.Name, self.Settings.ESP.ESPColor.Mobs)
                table.insert(ActiveMobs, descendant)
            end
        end))
    else
        for object, esp in pairs(ESPObjects) do
            if object.Parent and object.Parent:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(object.Parent) then
                esp.Visible = false
                ESPObjects[object] = nil
                esp:Remove()
            end
        end
    end
end

-- Sistema de Auto Farm
function BloxMobile:GetMob()
    local target = nil
    local shortestDistance = math.huge
    
    if self.Settings.AutoFarm.Target == "Nearest" then
        for _, mob in pairs(ActiveMobs) do
            if mob and mob.Parent and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and 
               mob.Humanoid.Health > 0 then
                local distance = GetDistance(GetHumanoidRootPart().Position, mob.HumanoidRootPart.Position)
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    target = mob
                end
            end
        end
    elseif self.Settings.AutoFarm.Target == "Specific" then
        for _, mob in pairs(ActiveMobs) do
            if mob and mob.Parent and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and 
               mob.Humanoid.Health > 0 and mob.Name:find(self.Settings.AutoFarm.SpecificMob) then
                local distance = GetDistance(GetHumanoidRootPart().Position, mob.HumanoidRootPart.Position)
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    target = mob
                end
            end
        end
    elseif self.Settings.AutoFarm.Target == "Quest" and CurrentQuest then
        for _, mob in pairs(ActiveMobs) do
            if mob and mob.Parent and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and 
               mob.Humanoid.Health > 0 and CurrentQuest.Mob == mob.Name then
                local distance = GetDistance(GetHumanoidRootPart().Position, mob.HumanoidRootPart.Position)
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    target = mob
                end
            end
        end
    end
    
    return target, shortestDistance
end

function BloxMobile:EquipWeapon(weaponName)
    if not weaponName then return end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find(weaponName) then
            GetHumanoid():EquipTool(tool)
            return tool
        end
    end
    
    -- Verifica se já está equipado
    for _, tool in pairs(GetCharacter():GetChildren()) do
        if tool:IsA("Tool") and tool.Name:find(weaponName) then
            return tool
        end
    end
    
    return nil
end

function BloxMobile:StartAttack()
    if IsAttacking then return end
    IsAttacking = true
    
    -- Equipar arma se necessário
    if self.Settings.AutoFarm.AutoEquipWeapon then
        self:EquipWeapon(self.Settings.AutoFarm.SelectedWeapon)
    end
    
    -- Loop de ataque
    spawn(function()
        while IsAttacking and self.Settings.AutoFarm.Enabled do
            -- Simulação de clique para ataque básico
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
            
            -- Simular uso de habilidades se ativado
            if self.Settings.AutoFarm.UseSkills then
                -- Pressionar teclas de habilidade
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown("Z")
                wait(0.1)
                VirtualUser:SetKeyUp("Z")
                
                wait(0.5)
                
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown("X")
                wait(0.1)
                VirtualUser:SetKeyUp("X")
                
                wait(0.5)
                
                VirtualUser:CaptureController()
                VirtualUser:SetKeyDown("C")
                wait(0.1)
                VirtualUser:SetKeyUp("C")
            end
            
            -- Diferentes métodos de ataque
            if self.Settings.AutoFarm.AttackMethod == "Fast" then
                wait(0.1)
            elseif self.Settings.AutoFarm.AttackMethod == "Skill" then
                wait(0.5)
            else
                wait(0.3)
            end
        end
    end)
end

function BloxMobile:StopAttack()
    IsAttacking = false
end

function BloxMobile:MoveToTarget(target, distance)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local targetPos = target.HumanoidRootPart.Position
    local humanoidRootPart = GetHumanoidRootPart()
    
    -- Calcular posição relativa acima do alvo
    local offset = Vector3.new(0, distance or self.Settings.AutoFarm.Distance, 0)
    local targetCFrame = CFrame.new(targetPos + offset)
    
    -- Usar TweenService para movimento mais suave
    local tweenInfo = TweenInfo.new(
        GetDistance(humanoidRootPart.Position, targetPos + offset) / (self.Settings.AutoFarm.TeleportSpeed or 150),
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = targetCFrame}
    )
    
    tween:Play()
    return tween
end

function BloxMobile:StartAutoFarm()
    self.Settings.AutoFarm.Enabled = true
    
    -- Iniciar loop de farm
    spawn(function()
        while self.Settings.AutoFarm.Enabled do
            local mob, distance = self:GetMob()
            TargetMob = mob
            
            if mob then
                -- Mover para o alvo
                local tween = self:MoveToTarget(mob)
                if tween then
                    tween.Completed:Wait()
                end
                
                -- Iniciar ataque
                self:StartAttack()
                
                -- Esperar até que o mob morra ou desapareça
                while mob and mob.Parent and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and 
                      self.Settings.AutoFarm.Enabled do
                    self:MoveToTarget(mob) -- Ficar seguindo o mob
                    wait(0.1)
                end
                
            else
                wait(1)
            end
        end
    end)
end

function BloxMobile:StopAutoFarm()
    self.Settings.AutoFarm.Enabled = false
    self:StopAttack()
    TargetMob = nil
end

-- Sistema de Teleporte
function BloxMobile:Teleport(location)
    if type(location) == "string" then
        if self.GameData.Islands[location] then
            location = self.GameData.Islands[location]
        else
            warn("Local não encontrado: " .. tostring(location))
            return false
        end
    end
    
    if self.Settings.Teleport.InstantTP then
        -- Teleporte instantâneo (mais arriscado)
        GetHumanoidRootPart().CFrame = location
    else
        -- Teleporte gradual (mais seguro)
        local distance = GetDistance(GetHumanoidRootPart().Position, location.Position)
        local time = distance / 500 -- Velocidade de teleporte
        
        local tweenInfo = TweenInfo.new(
            time,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(
            GetHumanoidRootPart(),
            tweenInfo,
            {CFrame = location}
        )
        
        tween:Play()
        return tween
    end
    
    return true
end

-- Sistema de AutoQuest
function BloxMobile:GetQuestNPC(questName)
    -- Implementação básica (deve ser adaptada ao jogo)
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:find("Quest") and npc:FindFirstChild("HumanoidRootPart") then
            return npc
        end
    end
    return nil
end

function BloxMobile:AcceptQuest(questName)
    local questNPC = self:GetQuestNPC(questName)
    
    if questNPC then
        -- Teleportar para o NPC de quest
        local originalPosition = GetHumanoidRootPart().CFrame
        self:Teleport(questNPC.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        
        -- Tentar interagir com o NPC
        wait(1)
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        
        -- Clicar no botão de aceitar quest (simplificado)
        wait(1)
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:find("Accept") then
                -- Simular clique no botão
                firesignal(gui.MouseButton1Click)
                wait(0.5)
                
                -- Definir current quest
                CurrentQuest = {Name = questName, Mob = "Unknown"} -- Mob deve ser configurado adequadamente
                return true
            end
        end
        
        -- Voltar à posição original
        wait(1)
        self:Teleport(originalPosition)
    end
    
    return false
end

function BloxMobile:StartAutoQuest()
    self.Settings.AutoQuest.Enabled = true
    
    spawn(function()
        while self.Settings.AutoQuest.Enabled do
            -- Verificar se temos uma quest ativa
            if not CurrentQuest then
                self:AcceptQuest(self.Settings.AutoQuest.QuestName)
                wait(2)
            end
            
            -- Iniciar autofarm se configurado
            if self.Settings.AutoQuest.AutoFarm and not self.Settings.AutoFarm.Enabled then
                self.Settings.AutoFarm.Target = "Quest"
                self:StartAutoFarm()
            end
            
            wait(5)
        end
    end)
end

function BloxMobile:StopAutoQuest()
    self.Settings.AutoQuest.Enabled = false
    if self.Settings.AutoQuest.AutoFarm and self.Settings.AutoFarm.Target == "Quest" then
        self:StopAutoFarm()
    end
    CurrentQuest = nil
end

-- Sistema de Auto Fruits
function BloxMobile:GetNearestFruit()
    local nearestFruit = nil
    local shortestDistance = math.huge
    
    for _, v in pairs(workspace:GetChildren()) do
        if (v.Name:find("Fruit") or v.Name:lower():find("fruta")) and 
           (v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")) then
            local part = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
            local distance = GetDistance(GetHumanoidRootPart().Position, part.Position)
            
            if distance < shortestDistance then
                shortestDistance = distance
                nearestFruit = part
            end
        end
    end
    
    return nearestFruit, shortestDistance
end

function BloxMobile:StartAutoCollectFruits()
    self.Settings.Fruits.AutoCollect = true
    
    spawn(function()
        while self.Settings.Fruits.AutoCollect do
            local fruit, distance = self:GetNearestFruit()
            
            if fruit and distance < 2000 then
                -- Salvar posição atual
                local originalPosition = GetHumanoidRootPart().CFrame
                
                -- Teleportar para a fruta
                self:Teleport(CFrame.new(fruit.Position))
                
                -- Esperar um momento para coletar
                wait(1)
                
                -- Tentar voltar à posição original se necessário
                if not self.Settings.Fruits.TeleportToFruit then
                    self:Teleport(originalPosition)
                end
            end
            
            wait(1)
        end
    end)
end

function BloxMobile:StopAutoCollectFruits()
    self.Settings.Fruits.AutoCollect = false
end

-- Sistema de AutoStats
function BloxMobile:GetAvailableStatPoints()
    local statsFrame = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if statsFrame and statsFrame:FindFirstChild("Points") then
        local pointsText = statsFrame.Points.Text
        local points = tonumber(string.match(pointsText, "%d+"))
        return points or 0
    end
    return 0
end

function BloxMobile:UpgradeStat(statName)
    local stats = {
        ["Melee"] = "Melee",
        ["Defense"] = "Defense",
        ["Sword"] = "Sword",
        ["Gun"] = "Gun",
        ["Fruit"] = "Fruit" or "Blox Fruit" or "Demon Fruit"
    }
    
    local statPath = stats[statName]
    if not statPath then return false end
    
    -- Tentar encontrar o botão de upgrade no GUI
    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and gui.Name:find(statPath) then
            -- Simular clique no botão
            for i = 1, self.Settings.Stats.PointsPerStat do
                firesignal(gui.MouseButton1Click)
                wait(0.1)
            end
            return true
        end
    end
    
    return false
end

function BloxMobile:StartAutoStats()
    self.Settings.Stats.AutoStats = true
    
    spawn(function()
        while self.Settings.Stats.AutoStats do
            local points = self:GetAvailableStatPoints()
            
            if points >= self.Settings.Stats.PointsPerStat then
                self:UpgradeStat(self.Settings.Stats.SelectedStat)
            end
            
            wait(3)
        end
    end)
end

function BloxMobile:StopAutoStats()
    self.Settings.Stats.AutoStats = false
end

-- Sistema de NoClip
function BloxMobile:StartNoClip()
    if IsNoClipping then return end
    
    IsNoClipping = true
    self.Settings.Player.NoClip = true
    
    -- Salvar conexão para removê-la depois
    table.insert(Connections, RunService.Stepped:Connect(function()
        if not IsNoClipping then return end
        
        for _, part in pairs(GetCharacter():GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end))
end

function BloxMobile:StopNoClip()
    IsNoClipping = false
    self.Settings.Player.NoClip = false
    
    -- Restaurar colisão
    for _, part in pairs(GetCharacter():GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- Sistema de Auto Haki
function BloxMobile:AutoHaki()
    if not self.Settings.Player.AutoHaki then return end
    
    -- Verifica se o jogador tem Haki
    local hasHaki = false
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool.Name:find("Haki") then
            hasHaki = true
            break
        end
    end
    
    if not hasHaki then return end
    
    -- Ativa Haki automaticamente
    local success, err = pcall(function()
        local args = {
            [1] = "Buso"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end)
end

-- Auto Raid
function BloxMobile:AutoRaid()
    if not self.Settings.Raid.AutoRaid then return end
    
    spawn(function()
        while self.Settings.Raid.AutoRaid do
            -- Comprar chip se necessário
            if self.Settings.Raid.AutoBuy then
                local args = {
                    [1] = "RaidsNpc",
                    [2] = "Select",
                    [3] = self.Settings.Raid.ChipType
                }
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            end
            
            -- Entrar na raid
            local args = {
                [1] = "Raid",
                [2] = "Start"
            }
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            
            -- Teleportar para o centro da raid
            if workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("RaidIsland") then
                self:Teleport(workspace._WorldOrigin.RaidIsland.Position)
            end
            
            wait(5)
        end
    end)
end

-- Auto Boss
function BloxMobile:GetBoss()
    for _, v in pairs(workspace:GetChildren()) do
        if string.find(v.Name, "Boss") and v:FindFirstChild("Humanoid") and 
           v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
            return v
        end
    end
    return nil
end

function BloxMobile:AutoBoss(bossName)
    local boss = nil
    
    spawn(function()
        while self.Settings.Boss.AutoFarm do
            boss = self:GetBoss()
            
            if boss then
                self:MoveToTarget(boss)
                self:StartAttack()
                
                -- Esperar até que o boss morra
                while boss and boss.Parent and boss:FindFirstChild("Humanoid") and 
                      boss.Humanoid.Health > 0 and self.Settings.Boss.AutoFarm do
                    self:MoveToTarget(boss)
                    wait(0.1)
                end
                
                -- Coletar drops se habilitado
                if self.Settings.Boss.CollectDrops then
                    wait(1)
                    for _, drop in pairs(workspace:GetChildren()) do
                        if drop:IsA("Model") and drop:FindFirstChild("Handle") then
                            self:Teleport(drop.Handle.CFrame)
                            wait(1)
                        end
                    end
                end
            else
                wait(3)
            end
        end
    end)
end

-- Auto Chest
function BloxMobile:GetNearestChest()
    local nearestChest = nil
    local shortestDistance = math.huge
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:find("Chest") and (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("Model")) then
            local part = v:IsA("Model") and (v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")) or v
            local distance = GetDistance(GetHumanoidRootPart().Position, part.Position)
            
            if distance < shortestDistance then
                shortestDistance = distance
                nearestChest = part
            end
        end
    end
    
    return nearestChest, shortestDistance
end

function BloxMobile:StartAutoChest()
    self.Settings.Misc.AutoChests = true
    
    spawn(function()
        while self.Settings.Misc.AutoChests do
            local chest, distance = self:GetNearestChest()
            
            if chest and distance < 2000 then
                -- Salvar posição original
                local originalPosition = GetHumanoidRootPart().CFrame
                
                -- Teleportar para o baú
                self:Teleport(CFrame.new(chest.Position))
                
                -- Esperar um momento para coletar
                wait(1)
                
                -- Voltar à posição original
                self:Teleport(originalPosition)
            else
                wait(1)
            end
        end
    end)
end

-- Server Hop
function BloxMobile:ServerHop()
    local Servers = {}
    local Response = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local Data = HttpService:JSONDecode(Response)
    
    if Data and Data.data then
        for _, v in pairs(Data.data) do
            if v.playing ~= nil and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(Servers, v.id)
            end
        end
    end
    
    if #Servers > 0 then
        local randomServer = Servers[math.random(1, #Servers)]
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, randomServer)
    else
        warn("Não foi possível encontrar um servidor!")
    end
end

function BloxMobile:LowPlayerServer()
    local Servers = {}
    local Response = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local Data = HttpService:JSONDecode(Response)
    
    if Data and Data.data then
        local lowestPlayers = math.huge
        local bestServer = nil
        
        for _, v in pairs(Data.data) do
            if v.playing ~= nil and v.playing < lowestPlayers and v.id ~= game.JobId then
                lowestPlayers = v.playing
                bestServer = v.id
            end
        end
        
        if bestServer then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, bestServer)
        end
    end
end

-- Sistema de FastAttack
function BloxMobile:EnableFastAttack()
    self.Settings.Player.FastAttack = true
    
    spawn(function()
        while self.Settings.Player.FastAttack do
            for i = 1, 3 do
                -- Modifica a velocidade de ataque (simplificado)
                -- Em um script real, isso requer identificação específica dos módulos de combate do Blox Fruits
                local args = {
                    [1] = "ComboChange",
                    [2] = "Fast"
                }
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
            end
            wait(1)
        end
    end)
end

function BloxMobile:DisableFastAttack()
    self.Settings.Player.FastAttack = false
end

-- Infinite Energy/Stamina
function BloxMobile:EnableInfiniteEnergy()
    self.Settings.Player.InfiniteEnergy = true
    
    spawn(function()
        while self.Settings.Player.InfiniteEnergy do
            -- Tenta repor energia/stamina (simplificado)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Energy") then
                LocalPlayer.Character.Energy.Value = 100
            end
            wait(0.1)
        end
    end)
end

-- Auto Rejoin
function BloxMobile:SetupAutoRejoin()
    if self.Settings.Player.AutoRejoin then
        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and 
               child.MessageArea:FindFirstChild("ErrorFrame") then
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end
        end)
    end
end

-- Auto Race V4
function BloxMobile:AutoRaceV4()
    self.Settings.Race.AutoV4 = true
    
    spawn(function()
        while self.Settings.Race.AutoV4 do
            -- Verificar se já tem V4
            local hasV4 = false
            -- Lógica de verificação...
            
            if not hasV4 then
                -- Sequência de ações para obter V4
                -- Isso depende muito da mecânica específica de Blox Fruits
            end
            
            wait(5)
        end
    end)
end

-- Auto Sea Beast
function BloxMobile:AutoSeaBeast()
    self.Settings.Misc.AutoSeaBeast = true
    
    spawn(function()
        while self.Settings.Misc.AutoSeaBeast do
            -- Procurar Sea Beast
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name:find("Sea Beast") and v:FindFirstChild("HumanoidRootPart") then
                    local originalPosition = GetHumanoidRootPart().CFrame
                    
                    -- Teleportar para o Sea Beast
                    self:Teleport(v.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
                    
                    -- Atacar
                    self:StartAttack()
                    
                    -- Continuar atacando até derrotar
                    while v and v.Parent and v:FindFirstChild("Humanoid") and 
                          v.Humanoid.Health > 0 and self.Settings.Misc.AutoSeaBeast do
                        self:Teleport(v.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0))
                        wait(0.1)
                    end
                    
                    self:StopAttack()
                    
                    -- Voltar para posição original
                    self:Teleport(originalPosition)
                    break
                end
            end
            
            wait(5)
        end
    end)
end

-- Miscelâneas
function BloxMobile:EnableInfiniteAbility()
    self.Settings.Misc.InfiniteAbility = true
    
    spawn(function()
        while self.Settings.Misc.InfiniteAbility do
            -- Tenta repor energia das habilidades (simplificado)
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") and v:FindFirstChild("Cooldown") then
                        v.Cooldown.Value = 0
                    end
                end
            end
            wait(0.1)
        end
    end)
end

-- Interface do Usuário (UI) Mobile-Friendly
function BloxMobile:CreateUI()
    -- Remover UIs anteriores se existirem
    if game:GetService("CoreGui"):FindFirstChild("BloxMobileUI") then
        game:GetService("CoreGui"):FindFirstChild("BloxMobileUI"):Destroy()
    end
    
    -- Criar UI principal
    local BloxMobileUI = Instance.new("ScreenGui")
    BloxMobileUI.Name = "BloxMobileUI"
    BloxMobileUI.Parent = game:GetService("CoreGui")
    BloxMobileUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = BloxMobileUI
    MainFrame.BackgroundColor3 = self.Settings.UI.MainColor
    MainFrame.Position = self.Settings.UI.Position
    MainFrame.Size = UDim2.new(0, 300 * self.Settings.UI.Scale, 0, 350 * self.Settings.UI.Scale)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = self.Settings.UI.AccentColor
    TitleBar.Size = UDim2.new(1, 0, 0, 30 * self.Settings.UI.Scale)
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Font = self.Settings.UI.Font
    Title.TextColor3 = self.Settings.UI.TextColor
    Title.TextSize = 18 * self.Settings.UI.Scale
    Title.Text = "BloxMobile v1.0"
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botão de fechar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Size = UDim2.new(0, 20 * self.Settings.UI.Scale, 0, 20 * self.Settings.UI.Scale)
    CloseButton.Position = UDim2.new(1, -25 * self.Settings.UI.Scale, 0.5, -10 * self.Settings.UI.Scale)
    CloseButton.Font = self.Settings.UI.Font
    CloseButton.TextColor3 = self.Settings.UI.TextColor
    CloseButton.TextSize = 14 * self.Settings.UI.Scale
    CloseButton.Text = "X"
    
    CloseButton.MouseButton1Click:Connect(function()
        BloxMobileUI:Destroy()
    end)
    
    -- Container de abas
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 30 * self.Settings.UI.Scale)
    TabContainer.Size = UDim2.new(1, 0, 0, 35 * self.Settings.UI.Scale)
    
    -- Container de conteúdo
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = self.Settings.UI.MainColor
    ContentContainer.Position = UDim2.new(0, 0, 0, 65 * self.Settings.UI.Scale)
    ContentContainer.Size = UDim2.new(1, 0, 1, -65 * self.Settings.UI.Scale)
    
    -- UICorner para cantos arredondados
    local MainCorner = Instance.new("UICorner")
    MainCorner.Parent = MainFrame
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.Parent = TitleBar
    TitleCorner.CornerRadius = UDim.new(0, 8)
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.Parent = CloseButton
    CloseCorner.CornerRadius = UDim.new(0, 4)
    
    -- Criar abas
    local Tabs = {
        "Home",
        "Auto Farm",
        "Teleport",
        "ESP",
        "Player",
        "Fruits",
        "Raid",
        "Boss",
        "Misc"
    }
    
    local TabButtons = {}
    local TabFrames = {}
    
    -- Criar botões de abas
    local TabButtonWidth = 1 / #Tabs
    
    for i, tabName in ipairs(Tabs) do
        -- Botão da aba
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Button"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = self.Settings.UI.MainColor
        TabButton.BackgroundTransparency = 0.5
        TabButton.Position = UDim2.new(TabButtonWidth * (i-1), 0, 0, 0)
        TabButton.Size = UDim2.new(TabButtonWidth, 0, 1, 0)
        TabButton.Font = self.Settings.UI.Font
        TabButton.TextColor3 = self.Settings.UI.TextColor
        TabButton.TextSize = 14 * self.Settings.UI.Scale
        TabButton.Text = tabName
        
        -- Frame de conteúdo da aba
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = tabName .. "Tab"
        TabFrame.Parent = ContentContainer
        TabFrame.BackgroundTransparency = 1
        TabFrame.Position = UDim2.new(0, 0, 0, 0)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.ScrollBarThickness = 4
        TabFrame.Visible = false
        TabFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        TabFrame.CanvasSize = UDim2.new(0, 0, 4, 0) -- Ajuste conforme o conteúdo
        
        -- UIListLayout para organizar os elementos
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = TabFrame
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        
        -- Adicionar à tabela
        TabButtons[tabName] = TabButton
        TabFrames[tabName] = TabFrame
        
        -- Conectar evento de clique
        TabButton.MouseButton1Click:Connect(function()
            -- Esconder todas as abas
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            
            -- Resetar cor de todos os botões
            for _, button in pairs(TabButtons) do
                button.BackgroundTransparency = 0.5
                button.TextColor3 = self.Settings.UI.TextColor
            end
            
            -- Mostrar aba selecionada
            TabFrame.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = self.Settings.UI.AccentColor
            
            self.Settings.UI.CurrentTab = tabName
        end)
    end
    
    -- Mostrar a aba Home por padrão
    TabFrames["Home"].Visible = true
    TabButtons["Home"].BackgroundTransparency = 0
    TabButtons["Home"].TextColor3 = self.Settings.UI.AccentColor
    
    -- Função para criar seção
    local function CreateSection(parent, title)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = title .. "Section"
        SectionFrame.Parent = parent
        SectionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SectionFrame.Size = UDim2.new(1, -20, 0, 30 * self.Settings.UI.Scale)
        SectionFrame.Position = UDim2.new(0, 10, 0, 0)
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Title"
        SectionTitle.Parent = SectionFrame
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Size = UDim2.new(1, 0, 1, 0)
        SectionTitle.Font = self.Settings.UI.Font
        SectionTitle.TextColor3 = self.Settings.UI.TextColor
        SectionTitle.TextSize = 16 * self.Settings.UI.Scale
        SectionTitle.Text = title
        
        local UICorner = Instance.new("UICorner")
        UICorner.Parent = SectionFrame
        UICorner.CornerRadius = UDim.new(0, 5)
        
        return SectionFrame
    end
    
    -- Função para criar toggle (interruptor)
    local function CreateToggle(parent, title, initialValue, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = title .. "Toggle"
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ToggleFrame.Size = UDim2.new(1, -20, 0, 40 * self.Settings.UI.Scale)
        ToggleFrame.Position = UDim2.new(0, 10, 0, 0)
        
        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Name = "Title"
        ToggleTitle.Parent = ToggleFrame
        ToggleTitle.BackgroundTransparency = 1
        ToggleTitle.Size = UDim2.new(0.7, 0, 1, 0)
        ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
        ToggleTitle.Font = self.Settings.UI.Font
        ToggleTitle.TextColor3 = self.Settings.UI.TextColor
        ToggleTitle.TextSize = 14 * self.Settings.UI.Scale
        ToggleTitle.Text = title
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "Button"
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = initialValue and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        ToggleButton.Size = UDim2.new(0, 50 * self.Settings.UI.Scale, 0, 25 * self.Settings.UI.Scale)
        ToggleButton.Position = UDim2.new(1, -60 * self.Settings.UI.Scale, 0.5, -12.5 * self.Settings.UI.Scale)
        ToggleButton.Font = self.Settings.UI.Font
        ToggleButton.TextColor3 = self.Settings.UI.TextColor
        ToggleButton.TextSize = 14 * self.Settings.UI.Scale
        ToggleButton.Text = initialValue and "ON" or "OFF"
        
        local UICorner = Instance.new("UICorner")
        UICorner.Parent = ToggleFrame
        UICorner.CornerRadius = UDim.new(0, 5)
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.Parent = ToggleButton
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        
        local isEnabled = initialValue
        
        ToggleButton.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            ToggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
            ToggleButton.Text = isEnabled and "ON" or "OFF"
            callback(isEnabled)
        end)
        
        return ToggleFrame, ToggleButton
    end
    
    -- Função para criar dropdown (seleção)
    local function CreateDropdown(parent, title, options, initialValue, callback)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = title .. "Dropdown"
        DropdownFrame.Parent = parent
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        DropdownFrame.Size = UDim2.new(1, -20, 0, 40 * self.Settings.UI.Scale)
        DropdownFrame.Position = UDim2.new(0, 10, 0, 0)
        
        local DropdownTitle = Instance.new("TextLabel")
        DropdownTitle.Name = "Title"
        DropdownTitle.Parent = DropdownFrame
        DropdownTitle.BackgroundTransparency = 1
        DropdownTitle.Size = UDim2.new(0.4, 0, 1, 0)
        DropdownTitle.Position = UDim2.new(0, 10, 0, 0)
        DropdownTitle.Font = self.Settings.UI.Font
        DropdownTitle.TextColor3 = self.Settings.UI.TextColor
        DropdownTitle.TextSize = 14 * self.Settings.UI.Scale
        DropdownTitle.Text = title
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Name = "Button"
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        DropdownButton.Size = UDim2.new(0.5, 0, 0, 25 * self.Settings.UI.Scale)
        DropdownButton.Position = UDim2.new(0.45, 0, 0.5, -12.5 * self.Settings.UI.Scale)
        DropdownButton.Font = self.Settings.UI.Font
        DropdownButton.TextColor3 = self.Settings.UI.TextColor
        DropdownButton.TextSize = 14 * self.Settings.UI.Scale
        DropdownButton.Text = initialValue or options[1]
        
        local UICorner = Instance.new("UICorner")
        UICorner.Parent = DropdownFrame
        UICorner.CornerRadius = UDim.new(0, 5)
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.Parent = DropdownButton
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        
        -- Container para opções
        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Name = "Options"
        OptionsFrame.Parent = DropdownFrame
        OptionsFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        OptionsFrame.Size = UDim2.new(0.5, 0, 0, 0) -- Será expandido
        OptionsFrame.Position = UDim2.new(0.45, 0, 1, 5)
        OptionsFrame.Visible = false
        OptionsFrame.ZIndex = 10
        
        local OptionsCorner = Instance.new("UICorner")
        OptionsCorner.Parent = OptionsFrame
        OptionsCorner.CornerRadius = UDim.new(0, 5)
        
        -- Criar opções
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = option
            OptionButton.Parent = OptionsFrame
            OptionButton.BackgroundTransparency = 0.5
            OptionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            OptionButton.Size = UDim2.new(1, 0, 0, 25 * self.Settings.UI.Scale)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25 * self.Settings.UI.Scale)
            OptionButton.Font = self.Settings.UI.Font
            OptionButton.TextColor3 = self.Settings.UI.TextColor
            OptionButton.TextSize = 14 * self.Settings.UI.Scale
            OptionButton.Text = option
            OptionButton.ZIndex = 11
            
            -- Ajustar tamanho do OptionsFrame
            OptionsFrame.Size = UDim2.new(0.5, 0, 0, i * 25 * self.Settings.UI.Scale)
            
            OptionButton.MouseButton1Click:Connect(function()
                DropdownButton.Text = option
                OptionsFrame.Visible = false
                callback(option)
            end)
        end
        
        -- Abrir/fechar dropdown
        DropdownButton.MouseButton1Click:Connect(function()
            OptionsFrame.Visible = not OptionsFrame.Visible
        end)
        
        return DropdownFrame, DropdownButton
    end
    
    -- Função para criar botão
    local function CreateButton(parent, title, callback)
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Name = title .. "Button"
        ButtonFrame.Parent = parent
        ButtonFrame.BackgroundColor3 = self.Settings.UI.AccentColor
        ButtonFrame.Size = UDim2.new(1, -20, 0, 35 * self.Settings.UI.Scale)
        ButtonFrame.Position = UDim2.new(0, 10, 0, 0)
        ButtonFrame.Font = self.Settings.UI.Font
        ButtonFrame.TextColor3 = self.Settings.UI.TextColor
        ButtonFrame.TextSize = 16 * self.Settings.UI.Scale
        ButtonFrame.Text = title
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.Parent = ButtonFrame
        ButtonCorner.CornerRadius = UDim.new(0, 5)
        
        ButtonFrame.MouseButton1Click:Connect(callback)
        
        return ButtonFrame
    end
    
    -- Função para criar slider (continuação)
local function CreateSlider(parent, title, min, max, initialValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = title .. "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderFrame.Size = UDim2.new(1, -20, 0, 50 * self.Settings.UI.Scale)
    SliderFrame.Position = UDim2.new(0, 10, 0, 0)
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Name = "Title"
    SliderTitle.Parent = SliderFrame
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Size = UDim2.new(1, 0, 0, 20 * self.Settings.UI.Scale)
    SliderTitle.Position = UDim2.new(0, 10, 0, 0)
    SliderTitle.Font = self.Settings.UI.Font
    SliderTitle.TextColor3 = self.Settings.UI.TextColor
    SliderTitle.TextSize = 14 * self.Settings.UI.Scale
    SliderTitle.Text = title
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Name = "Background"
    SliderBackground.Parent = SliderFrame
    SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBackground.Size = UDim2.new(1, -20, 0, 10 * self.Settings.UI.Scale)
    SliderBackground.Position = UDim2.new(0, 10, 0.5, 0)
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Parent = SliderBackground
    SliderFill.BackgroundColor3 = self.Settings.UI.AccentColor
    SliderFill.Size = UDim2.new((initialValue - min) / (max - min), 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Name = "Knob"
    SliderKnob.Parent = SliderBackground
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.Size = UDim2.new(0, 15 * self.Settings.UI.Scale, 0, 15 * self.Settings.UI.Scale)
    SliderKnob.Position = UDim2.new((initialValue - min) / (max - min), -7.5 * self.Settings.UI.Scale, 0.5, -7.5 * self.Settings.UI.Scale)
    SliderKnob.AnchorPoint = Vector2.new(0, 0.5)
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Size = UDim2.new(0, 50 * self.Settings.UI.Scale, 0, 20 * self.Settings.UI.Scale)
    ValueLabel.Position = UDim2.new(1, -60 * self.Settings.UI.Scale, 0, 0)
    ValueLabel.Font = self.Settings.UI.Font
    ValueLabel.TextColor3 = self.Settings.UI.TextColor
    ValueLabel.TextSize = 14 * self.Settings.UI.Scale
    ValueLabel.Text = tostring(initialValue)
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = SliderFrame
    UICorner.CornerRadius = UDim.new(0, 5)
    
    local BackgroundCorner = Instance.new("UICorner")
    BackgroundCorner.Parent = SliderBackground
    BackgroundCorner.CornerRadius = UDim.new(0, 5)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.Parent = SliderFill
    FillCorner.CornerRadius = UDim.new(0, 5)
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.Parent = SliderKnob
    KnobCorner.CornerRadius = UDim.new(0, 7.5 * self.Settings.UI.Scale)
    
    -- Dragging functionality
    local isDragging = false
    local currentValue = initialValue
    
    SliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)
    
    SliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            
            -- Calculate position and value
            local relativePos = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
            currentValue = min + (max - min) * relativePos
            currentValue = math.floor(currentValue + 0.5) -- Round to nearest integer
            
            -- Update UI
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(relativePos, -7.5 * self.Settings.UI.Scale, 0.5, -7.5 * self.Settings.UI.Scale)
            ValueLabel.Text = tostring(currentValue)
            
            callback(currentValue)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            -- Calculate position and value
            local relativePos = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
            currentValue = min + (max - min) * relativePos
            currentValue = math.floor(currentValue + 0.5) -- Round to nearest integer
            
            -- Update UI
            SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(relativePos, -7.5 * self.Settings.UI.Scale, 0.5, -7.5 * self.Settings.UI.Scale)
            ValueLabel.Text = tostring(currentValue)
            
            callback(currentValue)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    return SliderFrame
end

-- Função para criar caixa de texto
local function CreateTextbox(parent, title, placeholderText, callback)
    local TextboxFrame = Instance.new("Frame")
    TextboxFrame.Name = title .. "Textbox"
    TextboxFrame.Parent = parent
    TextboxFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TextboxFrame.Size = UDim2.new(1, -20, 0, 40 * self.Settings.UI.Scale)
    TextboxFrame.Position = UDim2.new(0, 10, 0, 0)
    
    local TextboxTitle = Instance.new("TextLabel")
    TextboxTitle.Name = "Title"
    TextboxTitle.Parent = TextboxFrame
    TextboxTitle.BackgroundTransparency = 1
    TextboxTitle.Size = UDim2.new(0.4, 0, 1, 0)
    TextboxTitle.Position = UDim2.new(0, 10, 0, 0)
    TextboxTitle.Font = self.Settings.UI.Font
    TextboxTitle.TextColor3 = self.Settings.UI.TextColor
    TextboxTitle.TextSize = 14 * self.Settings.UI.Scale
    TextboxTitle.Text = title
    TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local Textbox = Instance.new("TextBox")
    Textbox.Name = "Input"
    Textbox.Parent = TextboxFrame
    Textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Textbox.Size = UDim2.new(0.5, 0, 0, 25 * self.Settings.UI.Scale)
    Textbox.Position = UDim2.new(0.45, 0, 0.5, -12.5 * self.Settings.UI.Scale)
    Textbox.Font = self.Settings.UI.Font
    Textbox.TextColor3 = self.Settings.UI.TextColor
    Textbox.TextSize = 14 * self.Settings.UI.Scale
    Textbox.PlaceholderText = placeholderText
    Textbox.Text = ""
    Textbox.ClearTextOnFocus = false
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = TextboxFrame
    UICorner.CornerRadius = UDim.new(0, 5)
    
    local TextboxCorner = Instance.new("UICorner")
    TextboxCorner.Parent = Textbox
    TextboxCorner.CornerRadius = UDim.new(0, 4)
    
    Textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(Textbox.Text)
        end
    end)
    
    return TextboxFrame, Textbox
end

-- Função para criar separador
local function CreateDivider(parent)
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Parent = parent
    Divider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Divider.Size = UDim2.new(1, -20, 0, 1)
    Divider.Position = UDim2.new(0, 10, 0, 0)
    
    return Divider
end

-- Função para criar rótulo
local function CreateLabel(parent, text)
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Name = "Label"
    LabelFrame.Parent = parent
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.Size = UDim2.new(1, -20, 0, 30 * self.Settings.UI.Scale)
    LabelFrame.Position = UDim2.new(0, 10, 0, 0)
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Text"
    Label.Parent = LabelFrame
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = self.Settings.UI.Font
    Label.TextColor3 = self.Settings.UI.TextColor
    Label.TextSize = 14 * self.Settings.UI.Scale
    Label.Text = text
    Label.TextWrapped = true
    
    return LabelFrame, Label
end

-- Função para criar imagem
local function CreateImage(parent, imageId, size)
    local ImageFrame = Instance.new("Frame")
    ImageFrame.Name = "ImageFrame"
    ImageFrame.Parent = parent
    ImageFrame.BackgroundTransparency = 1
    ImageFrame.Size = UDim2.new(0, size * self.Settings.UI.Scale, 0, size * self.Settings.UI.Scale)
    ImageFrame.Position = UDim2.new(0.5, -size/2 * self.Settings.UI.Scale, 0, 0)
    
    local Image = Instance.new("ImageLabel")
    Image.Name = "Image"
    Image.Parent = ImageFrame
    Image.BackgroundTransparency = 1
    Image.Size = UDim2.new(1, 0, 1, 0)
    Image.Image = "rbxassetid://" .. imageId
    Image.ScaleType = Enum.ScaleType.Fit
    
    return ImageFrame, Image
end

-- Função para criar indicador de progresso circular
local function CreateCircularProgress(parent, size)
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Name = "ProgressFrame"
    ProgressFrame.Parent = parent
    ProgressFrame.BackgroundTransparency = 1
    ProgressFrame.Size = UDim2.new(0, size * self.Settings.UI.Scale, 0, size * self.Settings.UI.Scale)
    ProgressFrame.Position = UDim2.new(0.5, -size/2 * self.Settings.UI.Scale, 0, 0)
    
    -- Círculo de fundo
    local Background = Instance.new("ImageLabel")
    Background.Name = "Background"
    Background.Parent = ProgressFrame
    Background.BackgroundTransparency = 1
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Image = "rbxassetid://3570695787" -- Círculo
    Background.ImageColor3 = Color3.fromRGB(50, 50, 50)
    Background.ScaleType = Enum.ScaleType.Slice
    Background.SliceCenter = Rect.new(100, 100, 100, 100)
    
    -- Círculo de progresso
    local Progress = Instance.new("ImageLabel")
    Progress.Name = "Progress"
    Progress.Parent = ProgressFrame
    Progress.BackgroundTransparency = 1
    Progress.Size = UDim2.new(1, 0, 1, 0)
    Progress.Image = "rbxassetid://3570695787" -- Círculo
    Progress.ImageColor3 = self.Settings.UI.AccentColor
    Progress.ScaleType = Enum.ScaleType.Slice
    Progress.SliceCenter = Rect.new(100, 100, 100, 100)
    Progress.ImageTransparency = 0.5
    
    -- Texto de porcentagem
    local Percentage = Instance.new("TextLabel")
    Percentage.Name = "Percentage"
    Percentage.Parent = ProgressFrame
    Percentage.BackgroundTransparency = 1
    Percentage.Size = UDim2.new(1, 0, 1, 0)
    Percentage.Font = self.Settings.UI.Font
    Percentage.TextColor3 = self.Settings.UI.TextColor
    Percentage.TextSize = size/3 * self.Settings.UI.Scale
    Percentage.Text = "0%"
    
    -- Função para atualizar progresso
    local function UpdateProgress(percent)
        Progress.ImageTransparency = 1 - (percent / 100)
        Percentage.Text = tostring(math.floor(percent)) .. "%"
    end
    
    return ProgressFrame, UpdateProgress
end

-- Função para notificações
function BloxMobile:CreateNotification(title, message, duration)
    duration = duration or 3
    
    -- Container para notificações
    if not game.CoreGui:FindFirstChild("BloxMobileNotifications") then
        local NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "BloxMobileNotifications"
        NotifGui.Parent = game.CoreGui
        NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local NotifContainer = Instance.new("Frame")
        NotifContainer.Name = "NotifContainer"
        NotifContainer.Parent = NotifGui
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.Size = UDim2.new(0, 300 * self.Settings.UI.Scale, 1, 0)
        NotifContainer.Position = UDim2.new(1, -310 * self.Settings.UI.Scale, 0, 0)
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Parent = NotifContainer
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end
    
    local NotifContainer = game.CoreGui.BloxMobileNotifications.NotifContainer
    
    -- Criar notificação
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Parent = NotifContainer
    Notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Notification.Size = UDim2.new(1, 0, 0, 80 * self.Settings.UI.Scale)
    Notification.BackgroundTransparency = 0.1
    Notification.Position = UDim2.new(1, 0, 0, 0) -- Começa fora da tela
    
    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Notification
    UICorner.CornerRadius = UDim.new(0, 10)
    
    -- Barra superior colorida
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Notification
    TopBar.BackgroundColor3 = self.Settings.UI.AccentColor
    TopBar.Size = UDim2.new(1, 0, 0, 5 * self.Settings.UI.Scale)
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.Parent = TopBar
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Notification
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -20, 0, 25 * self.Settings.UI.Scale)
    Title.Position = UDim2.new(0, 10, 0, 10 * self.Settings.UI.Scale)
    Title.Font = self.Settings.UI.Font
    Title.TextColor3 = self.Settings.UI.AccentColor
    Title.TextSize = 18 * self.Settings.UI.Scale
    Title.Text = title
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Mensagem
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Parent = Notification
    Message.BackgroundTransparency = 1
    Message.Size = UDim2.new(1, -20, 0, 40 * self.Settings.UI.Scale)
    Message.Position = UDim2.new(0, 10, 0, 35 * self.Settings.UI.Scale)
    Message.Font = self.Settings.UI.Font
    Message.TextColor3 = self.Settings.UI.TextColor
    Message.TextSize = 14 * self.Settings.UI.Scale
    Message.Text = message
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animação de entrada
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)})
    tween:Play()
    
    -- Animação de saída após a duração
    spawn(function()
        wait(duration)
        local tweenOut = TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(1, 0, 0, 0)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        Notification:Destroy()
    end)
    
    return Notification
end

-- Sistema de detecção de Sea (Mar)
function BloxMobile:DetectCurrentSea()
    -- Detectar baseado na localização ou PlaceId
    if game.PlaceId == 2753915549 then
        return "First Sea"
    elseif game.PlaceId == 4442272183 then
        return "Second Sea"
    elseif game.PlaceId == 7449423635 then
        return "Third Sea"
    else
        -- Tenta detectar pela existência de landmarks específicos
        if workspace:FindFirstChild("MarineBase") or workspace:FindFirstChild("PirateSuperBase") then
            return "First Sea"
        elseif workspace:FindFirstChild("IceCastle") or workspace:FindFirstChild("ForgottenIsland") then
            return "Second Sea"
        elseif workspace:FindFirstChild("Turtle Island") or workspace:FindFirstChild("Hydra Island") then
            return "Third Sea"
        end
    end
    
    return "Unknown Sea"
end

-- Sistema avançado de ESP para Frutas
function BloxMobile:EnhancedFruitESP()
    self.Settings.ESP.Fruits = true
    
    spawn(function()
        while self.Settings.ESP.Fruits do
            -- Limpar ESPs antigos
            for object, esp in pairs(ESPObjects) do
                if object.Parent and (object.Parent.Name:find("Fruit") or object.Parent.Name:lower():find("fruta")) then
                    esp.Visible = false
                    ESPObjects[object] = nil
                    esp:Remove()
                end
            end
            
            -- Criar novos ESPs
            for _, v in pairs(workspace:GetChildren()) do
                if v.Name:find("Fruit") or v.Name:lower():find("fruta") then
                    local part = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
                    if part then
                        local distance = GetDistance(GetHumanoidRootPart().Position, part.Position)
                        local distanceStr = string.format("%.1f", distance)
                        local fruitName = string.gsub(v.Name, "Fruit", "")
                        fruitName = string.gsub(fruitName, "%-", " ")
                        
                        local esp = self:CreateESP(part, "🍎 " .. fruitName .. " (" .. distanceStr .. "m)", self.Settings.ESP.ESPColor.Fruits)
                        esp.Size = 18 * self.Settings.UI.Scale -- Tamanho maior para melhor visibilidade
                    end
                end
            end
            
            wait(1)
        end
    end)
end

-- Teleporte instantâneo para fruta mais próxima
function BloxMobile:TeleportToNearestFruit()
    local fruit, distance = self:GetNearestFruit()
    
    if fruit then
        -- Salvar posição atual
        local originalPosition = GetHumanoidRootPart().CFrame
        self.LastPosition = originalPosition
        
        -- Notificar usuário
        self:CreateNotification("Teleporte", "Teleportando para fruta a " .. string.format("%.1f", distance) .. "m", 2)
        
        -- Teleportar para a fruta
        self:Teleport(CFrame.new(fruit.Position))
        
        return true
    else
        self:CreateNotification("Aviso", "Nenhuma fruta encontrada no mapa", 3)
        return false
    end
end

-- Voltar para última posição
function BloxMobile:ReturnToLastPosition()
    if self.LastPosition then
        self:CreateNotification("Teleporte", "Retornando à posição anterior", 2)
        self:Teleport(self.LastPosition)
        return true
    else
        self:CreateNotification("Aviso", "Nenhuma posição anterior salva", 3)
        return false
    end
end

-- Sistema de ESP avançado para mobs
function BloxMobile:EnhancedMobESP()
    self.Settings.ESP.MobESP = true
    
    spawn(function()
        while self.Settings.ESP.MobESP do
            -- Limpar ESPs antigos
            for object, esp in pairs(ESPObjects) do
                if object.Parent and object.Parent:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(object.Parent) then
                    esp.Visible = false
                    ESPObjects[object] = nil
                    esp:Remove()
                end
            end
            
            -- Criar novos ESPs
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") 
                   and not Players:GetPlayerFromCharacter(v) then
                    local distance = GetDistance(GetHumanoidRootPart().Position, v.HumanoidRootPart.Position)
                    if distance <= self.Settings.ESP.DrawDistance then
                        local health = v.Humanoid.Health
                        local maxHealth = v.Humanoid.MaxHealth
                        local healthPercentage = math.floor((health / maxHealth) * 100)
                        local level = v:FindFirstChild("Level") and v.Level.Va