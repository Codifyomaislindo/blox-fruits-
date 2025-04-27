-- Fluenty Library for Blox Fruits
-- Enhanced with ESP for Fruits and UI with Tabs and Buttons

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Teams = game:GetService("Teams")
local TeleportService = game:GetService("TeleportService")

-- Verify if the game is Blox Fruits
local GameIds = {2753915549, 4442272183, 7449423635}
local IsBloxFruits = false

for _, id in pairs(GameIds) do
    if game.PlaceId == id then
        IsBloxFruits = true
        break
    end
end

if not IsBloxFruits then
    warn("⚠️ This script is designed for Blox Fruits! Some functions may not work!")
end

-- Utility Functions
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

local function SafeInvoke(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in SafeInvoke: " .. tostring(result))
    end
    return success, result
end

-- Fluenty Library Setup
local Fluenty = {}
local BloxFruits = Fluenty:CreateLibrary("BloxFruits")
BloxFruits.Settings = {
    AutoFarm = {
        Enabled = false,
        Target = "Nearest",
        SpecificMob = "Bandit",
        LevelRange = {Min = 0, Max = 999999},
        Distance = 7,
        AttackMethod = "Normal",
        UseSkills = true,
        AutoEquipWeapon = true,
        SelectedWeapon = "Combat",
        TeleportSpeed = 150,
        IgnorePlayers = true,
        AntiAFK = true,
        MobPriority = "Health"
    },
    AutoQuest = {
        Enabled = false,
        QuestName = "",
        AutoFarm = true,
        CompleteQuest = true,
        AutoTurnIn = true,
        QuestPriority = "Nearest"
    },
    Fruits = {
        AutoCollect = false,
        ESPEnabled = false,
        StoreFruit = false,
        TeleportToFruit = false,
        RaidBoss = false,
        AutoAwaken = false,
        FruitSnipe = false,
        SnipeDistance = 5000,
        NotifyFruit = true
    },
    Teleport = {
        SelectedLocation = "Starter Island",
        InstantTP = false,
        SafeMode = true,
        AntiStuck = true,
        CustomLocations = {}
    },
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        AutoHaki = false,
        NoClip = false,
        InfiniteEnergy = false,
        InfiniteAbility = false,
        FastAttack = false,
        AutoRejoin = true,
        AntiBan = true,
        GodMode = false,
        AutoDash = false
    },
    ESP = {
        Players = false,
        PlayerInfo = true,
        Fruits = false,
        Chests = false,
        FlowerESP = false,
        IslandESP = false,
        MobESP = false,
        NPCESP = false,
        ESPColor = {
            Players = Color3.fromRGB(0, 255, 255),
            Fruits = Color3.fromRGB(255, 255, 0),
            Chests = Color3.fromRGB(255, 170, 0),
            Flowers = Color3.fromRGB(85, 255, 127),
            Islands = Color3.fromRGB(170, 170, 255),
            Mobs = Color3.fromRGB(255, 0, 0),
            NPCs = Color3.fromRGB(255, 215, 0)
        },
        DrawDistance = 2000,
        ShowDistance = true,
        ShowHealth = true,
        ShowLevel = true
    },
    Raid = {
        AutoRaid = false,
        SelectedRaid = "Flame",
        AutoBuy = false,
        ChipType = "Flame",
        RaidMode = "Normal",
        AutoAwaken = false,
        KillAura = false
    },
    Stats = {
        AutoStats = false,
        SelectedStat = "Melee",
        PointsPerStat = 3,
        StatPriority = {"Melee", "Defense", "Fruit"}
    },
    Shop = {
        AutoBuySword = false,
        AutoBuyFruit = false,
        SelectedFruit = "None",
        AutoBuyEnchancement = false,
        SelectedEnchancement = "None",
        AutoRollBone = false,
        AutoBuyLegendary = false
    },
    Misc = {
        AutoSeaBeast = false,
        AutoChests = false,
        ServerHop = false,
        LowPlayerServer = false,
        InfiniteAbility = false,
        AutoFarmMaterials = false,
        MaterialType = "Leather",
        AutoMirageIsland = false,
        AutoKitsune = false,
        AutoDarkbeard = false
    },
    UI = {
        Scale = 1.0,
        Position = UDim2.new(0.5, -250, 0.5, -175),
        Transparency = 0.1,
        MainColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        CurrentTab = "Main",
        MobileMode = true,
        Minimize = true,
        Keybind = Enum.KeyCode.F2
    }
}

BloxFruits.GameData = {
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
    },
    Materials = {
        ["Leather"] = {Mob = "Pirate", Location = "Pirate Island"},
        ["Magma Ore"] = {Mob = "Magma Ninja", Location = "Magma Island"},
        ["Fish Tail"] = {Mob = "Fishman Warrior", Location = "Underwater City"}
    }
}

-- Variables
local Connections = {}
local ESPObjects = {}
local ActiveMobs = {}
local CurrentQuest = nil
local TargetMob = nil
local IsAttacking = false
local IsNoClipping = false
local LastPosition = nil

-- ESP System
function BloxFruits:CreateESP(object, text, color)
    if ESPObjects[object] then return ESPObjects[object] end
    
    local esp = Drawing.new("Text")
    esp.Visible = false
    esp.Center = true
    esp.Outline = true
    esp.Font = 2
    esp.Size = 16 * self.Settings.UI.Scale
    esp.Color = color or self.Settings.ESP.ESPColor.Players
    esp.Text = text or "ESP"
    
    ESPObjects[object] = esp
    return esp
end

function BloxFruits:UpdateESP()
    local camera = workspace.CurrentCamera
    
    for object, esp in pairs(ESPObjects) do
        if object and object.Parent then
            local pos, onScreen = camera:WorldToViewportPoint(object.Position)
            
            if onScreen and pos.Z < self.Settings.ESP.DrawDistance then
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Visible = true
                
                local distance = GetDistance(GetHumanoidRootPart().Position, object.Position)
                local distanceStr = string.format("%.1f", distance * 0.28) -- Convert studs to meters
                
                if self.Settings.ESP.PlayerInfo and Players:GetPlayerFromCharacter(object.Parent) then
                    local player = Players:GetPlayerFromCharacter(object.Parent)
                    local health = object.Parent:FindFirstChild("Humanoid") and object.Parent.Humanoid.Health or 0
                    local maxHealth = object.Parent:FindFirstChild("Humanoid") and object.Parent.Humanoid.MaxHealth or 0
                    esp.Text = player.Name .. " [" .. math.floor(health) .. "/" .. math.floor(maxHealth) .. "]"
                    if self.Settings.ESP.ShowDistance then
                        esp.Text = esp.Text .. " (" .. distanceStr .. "m)"
                    end
                elseif object.Parent:FindFirstChild("Humanoid") then
                    local health = object.Parent.Humanoid.Health
                    local maxHealth = object.Parent.Humanoid.MaxHealth
                    local healthPercent = math.floor((health / maxHealth) * 100)
                    esp.Text = object.Parent.Name .. " [" .. healthPercent .. "%]"
                    if self.Settings.ESP.ShowDistance then
                        esp.Text = esp.Text .. " (" .. distanceStr .. "m)"
                    end
                    if self.Settings.ESP.ShowLevel and object.Parent:FindFirstChild("Level") then
                        esp.Text = esp.Text .. " [Lv. " .. object.Parent.Level.Value .. "]"
                    end
                elseif object.Parent.Name:find("Fruit") then
                    local fruitName = string.gsub(object.Parent.Name, "Fruit", "")
                    esp.Text = "🍎 " .. fruitName .. " (" .. distanceStr .. "m)"
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

-- ESP Functions
function BloxFruits:TogglePlayerESP(enabled)
    self.Settings.ESP.Players = enabled
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                self:CreateESP(player.Character.HumanoidRootPart, player.Name, self.Settings.ESP.ESPColor.Players)
            end
        end
        
        table.insert(Connections, Players.PlayerAdded:Connect(function(player)
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
                esp:Remove()
                ESPObjects[object] = nil
            end
        end
    end
    
    return self
end

function BloxFruits:ToggleFruitESP(enabled)
    self.Settings.ESP.Fruits = enabled
    
    if enabled then
        spawn(function()
            while self.Settings.ESP.Fruits do
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name:find("Fruit") or v.Name:lower():find("fruta") then
                        local part = v:FindFirstChildOfClass("Part") or v:FindFirstChildOfClass("MeshPart")
                        if part then
                            self:CreateESP(part, "FRUTA: " .. v.Name, self.Settings.ESP.ESPColor.Fruits)
                        end
                    end
                end
                wait(1)
            end
        end)
    else
        for object, esp in pairs(ESPObjects) do
            if object.Parent and (object.Parent.Name:find("Fruit") or object.Parent.Name:lower():find("fruta")) then
                esp:Remove()
                ESPObjects[object] = nil
            end
        end
    end
    
    return self
end

-- Notification System
function BloxFruits:CreateNotification(title, text, duration)
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(1, -210, 1, -60)
    frame.BackgroundColor3 = self.Settings.UI.MainColor
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = self.Settings.UI.AccentColor
    titleLabel.Text = title
    titleLabel.Font = self.Settings.UI.Font
    titleLabel.TextSize = 14
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 30)
    textLabel.Position = UDim2.new(0, 0, 0, 20)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = self.Settings.UI.TextColor
    textLabel.Text = text
    textLabel.Font = self.Settings.UI.Font
    textLabel.TextSize = 12
    textLabel.Parent = frame
    
    spawn(function()
        wait(duration or 3)
        notification:Destroy()
    end)
end

-- UI System with Tabs and Buttons
function BloxFruits:CreateUI()
    if game:GetService("CoreGui"):FindFirstChild("BloxFruitsUI") then
        game:GetService("CoreGui"):FindFirstChild("BloxFruitsUI"):Destroy()
    end
    
    local BloxFruitsUI = Instance.new("ScreenGui")
    BloxFruitsUI.Name = "BloxFruitsUI"
    BloxFruitsUI.Parent = game:GetService("CoreGui")
    BloxFruitsUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = BloxFruitsUI
    MainFrame.BackgroundColor3 = self.Settings.UI.MainColor
    MainFrame.Position = self.Settings.UI.Position
    MainFrame.Size = UDim2.new(0, 300 * self.Settings.UI.Scale, 0, 350 * self.Settings.UI.Scale)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
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
    Title.Text = "BloxFruits v2.0"
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
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
        BloxFruitsUI:Destroy()
    end)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 30 * self.Settings.UI.Scale)
    TabContainer.Size = UDim2.new(1, 0, 0, 35 * self.Settings.UI.Scale)
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = self.Settings.UI.MainColor
    ContentContainer.Position = UDim2.new(0, 0, 0, 65 * self.Settings.UI.Scale)
    ContentContainer.Size = UDim2.new(1, 0, 1, -65 * self.Settings.UI.Scale)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.Parent = MainFrame
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.Parent = TitleBar
    TitleCorner.CornerRadius = UDim.new(0, 8)
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.Parent = CloseButton
    CloseCorner.CornerRadius = UDim.new(0, 4)
    
    local Tabs = {
        "Main",
        "Auto Farm",
        "Teleport",
        "ESP",
        "Player",
        "Fruits",
        "Raid",
        "Boss",
        "Materials",
        "Misc"
    }
    
    local TabButtons = {}
    local TabFrames = {}
    
    local TabButtonWidth = 1 / #Tabs
    
    for i, tabName in ipairs(Tabs) do
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
        
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = tabName .. "Tab"
        TabFrame.Parent = ContentContainer
        TabFrame.BackgroundTransparency = 1
        TabFrame.Position = UDim2.new(0, 0, 0, 0)
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.ScrollBarThickness = 4
        TabFrame.Visible = false
        TabFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        TabFrame.CanvasSize = UDim2.new(0, 0, 4, 0)
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = TabFrame
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 5)
        
        TabButtons[tabName] = TabButton
        TabFrames[tabName] = TabFrame
        
        TabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            
            for _, button in pairs(TabButtons) do
                button.BackgroundTransparency = 0.5
                button.TextColor3 = self.Settings.UI.TextColor
            end
            
            TabFrame.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = self.Settings.UI.AccentColor
            
            self.Settings.UI.CurrentTab = tabName
        end)
    end
    
    TabFrames["Main"].Visible = true
    TabButtons["Main"].BackgroundTransparency = 0
    TabButtons["Main"].TextColor3 = self.Settings.UI.AccentColor
    
    -- UI Helper Functions
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
    
    -- Main Tab Content
    local MainTab = TabFrames["Main"]
    local WelcomeSection = CreateSection(MainTab, "Welcome")
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = MainTab
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Size = UDim2.new(1, -20, 0, 60 * self.Settings.UI.Scale)
    InfoLabel.Position = UDim2.new(0, 10, 0, 0)
    InfoLabel.Font = self.Settings.UI.Font
    InfoLabel.TextColor3 = self.Settings.UI.TextColor
    InfoLabel.TextSize = 14 * self.Settings.UI.Scale
    InfoLabel.Text = "Welcome to BloxFruits v2.0!\nSelect a tab to access features.\nToggle options below to start."
    InfoLabel.TextWrapped = true
    
    local FruitESPSection = CreateSection(MainTab, "Quick Toggles")
    
    CreateToggle(MainTab, "Fruit ESP", self.Settings.ESP.Fruits, function(value)
        self:ToggleFruitESP(value)
        self:CreateNotification("ESP", value and "Fruit ESP Enabled" or "Fruit ESP Disabled", 2)
    end)
    
    CreateButton(MainTab, "Check Fruits Now", function()
        local fruit, distance = self:GetNearestFruit()
        if fruit then
            local fruitName = string.gsub(fruit.Parent.Name, "Fruit", "")
            self:CreateNotification("Fruit Found", fruitName .. " at " .. string.format("%.1f", distance * 0.28) .. "m", 3)
        else
            self:CreateNotification("Fruit Search", "No fruits found nearby!", 3)
        end
    end)
    
    -- Fruits Tab Content
    local FruitsTab = TabFrames["Fruits"]
    local FruitsSection = CreateSection(FruitsTab, "Fruit Settings")
    
    CreateToggle(FruitsTab, "Auto Collect Fruits", self.Settings.Fruits.AutoCollect, function(value)
        if value then
            self:StartAutoCollectFruits()
        else
            self:StopAutoCollectFruits()
        end
    end)
    
    CreateToggle(FruitsTab, "Fruit Snipe", self.Settings.Fruits.FruitSnipe, function(value)
        if value then
            self:StartFruitSnipe()
        else
            self:StopAutoCollectFruits()
        end
    end)
    
    -- ESP Tab Content
    local ESPTab = TabFrames["ESP"]
    local ESPSection = CreateSection(ESPTab, "ESP Settings")
    
    CreateToggle(ESPTab, "Player ESP", self.Settings.ESP.Players, function(value)
        self:TogglePlayerESP(value)
    end)
    
    CreateToggle(ESPTab, "Fruit ESP", self.Settings.ESP.Fruits, function(value)
        self:ToggleFruitESP(value)
    end)
    
    -- Connect UI Keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Settings.UI.Keybind then
            BloxFruitsUI.Enabled = not BloxFruitsUI.Enabled
        end
    end)
end

-- Auto Fruits System
function BloxFruits:GetNearestFruit()
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

function BloxFruits:StartAutoCollectFruits()
    self.Settings.Fruits.AutoCollect = true
    
    spawn(function()
        while self.Settings.Fruits.AutoCollect do
            local fruit, distance = self:GetNearestFruit()
            
            if fruit and distance < 2000 then
                local originalPosition = GetHumanoidRootPart().CFrame
                LastPosition = originalPosition
                
                self:Teleport(CFrame.new(fruit.Position))
                wait(1)
                
                if self.Settings.Fruits.StoreFruit then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fruit.Name)
                end
                
                if not self.Settings.Fruits.TeleportToFruit then
                    self:Teleport(originalPosition)
                end
                
                if self.Settings.Fruits.NotifyFruit then
                    self:CreateNotification("Fruit", "Collected " .. fruit.Parent.Name, 2)
                end
            end
            
            wait(0.5)
        end
    end)
    
    return self
end

function BloxFruits:StartFruitSnipe()
    self.Settings.Fruits.FruitSnipe = true
    
    spawn(function()
        while self.Settings.Fruits.FruitSnipe do
            local fruit, distance = self:GetNearestFruit()
            
            if fruit and distance <= self.Settings.Fruits.SnipeDistance then
                local originalPosition = GetHumanoidRootPart().CFrame
                self:Teleport(CFrame.new(fruit.Position))
                wait(1)
                self:Teleport(originalPosition)
                
                if self.Settings.Fruits.NotifyFruit then
                    self:CreateNotification("Fruit Snipe", "Sniped " .. fruit.Parent.Name .. " at " .. string.format("%.1f", distance * 0.28) .. "m", 3)
                end
            end
            
            wait(0.3)
        end
    end)
    
    return self
end

function BloxFruits:StopAutoCollectFruits()
    self.Settings.Fruits.AutoCollect = false
    self.Settings.Fruits.FruitSnipe = false
    return self
end

-- Teleport System
function BloxFruits:Teleport(location)
    if type(location) == "string" then
        if self.GameData.Islands[location] then
            location = self.GameData.Islands[location]
        elseif self.Settings.Teleport.CustomLocations[location] then
            location = self.Settings.Teleport.CustomLocations[location]
        else
            self:CreateNotification("Error", "Location not found: " .. tostring(location), 3)
            return false
        end
    end
    
    if self.Settings.Teleport.InstantTP then
        GetHumanoidRootPart().CFrame = location
    else
        local distance = GetDistance(GetHumanoidRootPart().Position, location.Position)
        local time = distance / 500
        
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
        
        if self.Settings.Teleport.AntiStuck then
            spawn(function()
                local startPos = GetHumanoidRootPart().Position
                wait(5)
                if GetDistance(startPos, GetHumanoidRootPart().Position) < 10 then
                    self:CreateNotification("Warning", "Stuck detected! Attempting instant TP", 3)
                    GetHumanoidRootPart().CFrame = location
                end
            end)
        end
        
        return tween
    end
    
    return true
end

-- Initialize UI and ESP Update Loop
BloxFruits:CreateUI()

spawn(function()
    while true do
        BloxFruits:UpdateESP()
        wait()
    end
end)

return BloxFruits
