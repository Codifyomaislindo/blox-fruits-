-- Blox Fruits Ultimate Script (Update 24, April 2025)
-- Redz Hub-inspired, all functions, anti-cheat bypass, mobile-friendly GUI
-- Use on alt account to avoid bans

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- Configuration
local Settings = {
    Team = "Pirates", -- "Pirates" or "Marines"
    AutoFarmLevel = false,
    AutoFarmBoss = false,
    AutoFarmMobs = false,
    AutoCollectChests = false,
    AutoCollectFruits = false,
    AutoStoreFruits = false,
    AutoRandomFruit = false,
    AutoRaid = false,
    AutoSeaEvent = false,
    AutoTerrorshark = false,
    AutoMirageIsland = false,
    AutoPrehistoricIsland = false,
    AutoRaceV4 = false,
    AutoDojoQuest = false,
    AutoDracoRace = false,
    AutoBelt = false,
    AutoKitsuneEvent = false,
    AutoMastery = false,
    AutoStats = false,
    AutoHaki = false,
    FastAttack = false,
    AutoSaber = false,
    AutoPole = false,
    AutoSawSword = false,
    SpeedHack = false,
    FruitSniper = false,
    ESPEnabled = false,
    AimbotEnabled = false,
    AutoQuest = false,
    AutoTeleport = false,
    ServerHop = false,
    SafeMode = true,
    PanicMode = false,
    AntiCheatBypass = true,
    WalkSpeed = 100,
    MasteryMethod = "Half", -- "Half" (300) or "Full" (600)
    StatAllocation = "Melee", -- "Melee", "Defense", "Sword", "Gun", "Fruit"
}

-- Anti-Cheat Bypass Variables
local randomizedDelay = math.random(0.1, 0.5)
local humanizedMovement = true
local lastTeleport = tick()
local teleportCooldown = 1.5 -- Seconds
local fakeInputInterval = math.random(5, 10)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxFruitsUltimateHub"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 600)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.5
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame
Shadow.ZIndex = -1

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.15, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Ultimate Hub - Blox Fruits 2025"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.Gotham
CloseButton.Parent = TitleBar

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 8)
CloseButtonCorner.Parent = CloseButton

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Tab System
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

local Tabs = {Farm = {}, Combat = {}, Teleport = {}, Misc = {}}
local CurrentTab = "Farm"

local function createTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 90, 1, 0)
    TabButton.BackgroundColor3 = CurrentTab == name and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.TextScaled = true
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabContainer

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, -20, 1, -140)
    TabFrame.Position = UDim2.new(0, 10, 0, 100)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = CurrentTab == name
    TabFrame.Parent = MainFrame
    TabFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    TabFrame.ScrollBarThickness = 4

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.Parent = TabFrame

    TabButton.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, tab in pairs(Tabs) do
            tab.Frame.Visible = tab.Name == name
            tab.Button.BackgroundColor3 = tab.Name == name and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
        end
    end)

    Tabs[name] = {Name = name, Frame = TabFrame, Button = TabButton}
end

createTab("Farm")
createTab("Combat")
createTab("Teleport")
createTab("Misc")

-- Draggable Functionality
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    if tick() - lastTeleport < teleportCooldown then return end
    local delta = input.Position - dragStart
    local newPos = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = newPos})
    tween:Play()
    lastTeleport = tick()
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- Utility Functions
local function safeTeleport(cframe)
    if not LocalPlayer.Character or not LocalPlayer.Character.HumanoidRootPart or Settings.SafeMode then return end
    if tick() - lastTeleport < teleportCooldown then return end
    if humanizedMovement then
        local tween = TweenService:Create(
            LocalPlayer.Character.HumanoidRootPart,
            TweenInfo.new(0.5, Enum.EasingStyle.Linear),
            {CFrame = cframe}
        )
        tween:Play()
        tween.Completed:Wait()
    else
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
    lastTeleport = tick()
end

local function getNearestEnemy()
    local closest, distance = nil, math.huge
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local dist = (enemy.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < distance then
                closest = enemy
                distance = dist
            end
        end
    end
    return closest
end

local function attackEnemy(enemy)
    if not enemy or not enemy.Humanoid or enemy.Humanoid.Health <= 0 then return end
    safeTeleport(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0, 0))
    wait(randomizedDelay)
end

local function panicModeCheck()
    if Settings.PanicMode and LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        if LocalPlayer.Character.Humanoid.Health <= LocalPlayer.Character.Humanoid.MaxHealth * 0.3 then
            safeTeleport(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 100, 0))
            wait(5)
            return true
        end
    end
    return false
end

-- Button Creation Function
local function createButton(name, toggleVar, callback, tab)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.BackgroundColor3 = Settings[name] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 50)
    Button.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.Gotham
    Button.Parent = Tabs[tab].Frame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        Button.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
        Button.BackgroundColor3 = Settings[name] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "Status: " .. name .. " " .. (Settings[name] and "Enabled" or "Disabled")
        callback(Settings[name])
    end)
end

-- Feature Implementations
local function toggleAutoFarmLevel(state)
    Settings.AutoFarmLevel = state
    if state then
        spawn(function()
            while Settings.AutoFarmLevel and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                local enemy = getNearestEnemy()
                if enemy then
                    attackEnemy(enemy)
                else
                    StatusLabel.Text = "Status: Searching for enemies..."
                    wait(randomizedDelay)
                end
                wait()
            end
        end)
    end
end

local function toggleAutoFarmBoss(state)
    Settings.AutoFarmBoss = state
    if state then
        spawn(function()
            while Settings.AutoFarmBoss and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, boss in pairs(workspace.Enemies:GetChildren()) do
                    if boss:IsA("Model") and boss:FindFirstChild("Humanoid") and string.find(boss.Name, "Boss") then
                        attackEnemy(boss)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Searching for bosses..."
                wait()
            end
        end)
    end
end

local function toggleAutoFarmMobs(state)
    Settings.AutoFarmMobs = state
    if state then
        spawn(function()
            while Settings.AutoFarmMobs and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and not string.find(mob.Name, "Boss") then
                        attackEnemy(mob)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Farming mobs..."
                wait()
            end
        end)
    end
end

local function toggleAutoCollectChests(state)
    Settings.AutoCollectChests = state
    if state then
        spawn(function()
            while Settings.AutoCollectChests and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, chest in pairs(workspace:GetChildren()) do
                    if chest:IsA("Model") and string.find(chest.Name, "Chest") then
                        safeTeleport(chest:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Collecting chests..."
                wait()
            end
        end)
    end
end

local function toggleAutoCollectFruits(state)
    Settings.AutoCollectFruits = state
    if state then
        spawn(function()
            while Settings.AutoCollectFruits and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, fruit in pairs(workspace:GetChildren()) do
                    if fruit:IsA("Tool") and (string.find(fruit.Name, "Fruit") or string.find(fruit.Name, "DevilFruit")) and not string.find(fruit.Name, "sail_boat") then
                        safeTeleport(fruit.Handle.CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Collecting fruits..."
                wait()
            end
        end)
    end
end

local function toggleAutoStoreFruits(state)
    Settings.AutoStoreFruits = state
    if state then
        spawn(function()
            while Settings.AutoStoreFruits and LocalPlayer.Character do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit")
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoRandomFruit(state)
    Settings.AutoRandomFruit = state
    if state then
        spawn(function()
            while Settings.AutoRandomFruit and LocalPlayer.Character do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoRaid(state)
    Settings.AutoRaid = state
    if state then
        spawn(function()
            while Settings.AutoRaid and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, raid in pairs(workspace:GetChildren()) do
                    if raid:IsA("Model") and string.find(raid.Name, "Raid") then
                        safeTeleport(raid:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Participating in raid..."
                wait()
            end
        end)
    end
end

local function toggleAutoSeaEvent(state)
    Settings.AutoSeaEvent = state
    if state then
        spawn(function()
            while Settings.AutoSeaEvent and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, event in pairs(workspace:GetChildren()) do
                    if event:IsA("Model") and string.find(event.Name, "SeaEvent") then
                        safeTeleport(event:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Engaging in sea event..."
                wait()
            end
        end)
    end
end

local function toggleAutoTerrorshark(state)
    Settings.AutoTerrorshark = state
    if state then
        spawn(function()
            while Settings.AutoTerrorshark and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, shark in pairs(workspace.Enemies:GetChildren()) do
                    if shark:IsA("Model") and string.find(shark.Name, "Terrorshark") then
                        attackEnemy(shark)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Hunting Terrorshark..."
                wait()
            end
        end)
    end
end

local function toggleAutoMirageIsland(state)
    Settings.AutoMirageIsland = state
    if state then
        spawn(function()
            while Settings.AutoMirageIsland and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, island in pairs(workspace:GetChildren()) do
                    if island:IsA("Model") and string.find(island.Name, "Mirage") then
                        safeTeleport(island:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Searching for Mirage Island..."
                wait()
            end
        end)
    end
end

local function toggleAutoPrehistoricIsland(state)
    Settings.AutoPrehistoricIsland = state
    if state then
        spawn(function()
            while Settings.AutoPrehistoricIsland and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, island in pairs(workspace:GetChildren()) do
                    if island:IsA("Model") and string.find(island.Name, "Prehistoric") then
                        safeTeleport(island:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Searching for Prehistoric Island..."
                wait()
            end
        end)
    end
end

local function toggleAutoRaceV4(state)
    Settings.AutoRaceV4 = state
    if state then
        spawn(function()
            while Settings.AutoRaceV4 and LocalPlayer.Character do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("RaceV4Progress")
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoDojoQuest(state)
    Settings.AutoDojoQuest = state
    if state then
        spawn(function()
            while Settings.AutoDojoQuest and LocalPlayer.Character do
                if panicModeCheck() then wait(1) continue end
                for _, npc in pairs(workspace.NPCs:GetChildren()) do
                    if npc:IsA("Model") and string.find(npc.Name, "Dojo") then
                        safeTeleport(npc.HumanoidRootPart.CFrame)
                        wait(randomizedDelay)
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                end
                StatusLabel.Text = "Status: Completing Dojo Quest..."
                wait()
            end
        end)
    end
end

local function toggleAutoDracoRace(state)
    Settings.AutoDracoRace = state
    if state then
        spawn(function()
            while Settings.AutoDracoRace and LocalPlayer.Character do
                ReplicatedStorage.Remotes.CommF_:InvokeServer("DracoRace")
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoBelt(state)
    Settings.AutoBelt = state
      if state then
        spawn(function()
            while Settings.AutoBelt and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBelt", math.random(1, 1000))
                end)
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoKitsuneEvent(state)
    Settings.AutoKitsuneEvent = state
    if state then
        spawn(function()
            while Settings.AutoKitsuneEvent and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, event in pairs(workspace:GetChildren()) do
                    if event:IsA("Model") and string.find(event.Name, "Kitsune") then
                        safeTeleport(event:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Engaging in Kitsune Event..."
                wait()
            end
        end)
    end
end

local function toggleAutoDragonTokens(state)
    Settings.AutoDragonTokens = state
    if state then
        spawn(function()
            while Settings.AutoDragonTokens and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, token in pairs(workspace:GetChildren()) do
                    if token:IsA("Model") and string.find(token.Name, "DragonToken") then
                        safeTeleport(token:GetPrimaryPart().CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Collecting Dragon Tokens..."
                wait()
            end
        end)
    end
end

local function toggleAutoGasFruit(state)
    Settings.AutoGasFruit = state
    if state then
        spawn(function()
            while Settings.AutoGasFruit and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, fruit in pairs(workspace:GetChildren()) do
                    if fruit:IsA("Tool") and string.find(fruit.Name, "GasFruit") then
                        safeTeleport(fruit.Handle.CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Sniping Gas Fruit..."
                wait()
            end
        end)
    end
end

local function toggleAutoMastery(state)
    Settings.AutoMastery = state
    if state then
        spawn(function()
            while Settings.AutoMastery and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        attackEnemy(enemy)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Farming mastery..."
                wait()
            end
        end)
    end
end

local function toggleAutoStats(state)
    Settings.AutoStats = state
    if state then
        spawn(function()
            while Settings.AutoStats and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", Settings.StatAllocation, 3, math.random(1, 1000))
                end)
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoHaki(state)
    Settings.AutoHaki = state
    if state then
        spawn(function()
            while Settings.AutoHaki and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso", math.random(1, 1000))
                end)
                wait(5)
            end
        end)
    end
end

local function toggleFastAttack(state)
    Settings.FastAttack = state
    if state then
        spawn(function()
            while Settings.FastAttack and LocalPlayer.Character do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(math.random(0, 100), math.random(0, 100)))
                wait(0.05)
            end
        end)
    end
end

local function toggleAutoSaber(state)
    Settings.AutoSaber = state
    if state then
        spawn(function()
            while Settings.AutoSaber and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySaber", math.random(1, 1000))
                end)
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoPole(state)
    Settings.AutoPole = state
    if state then
        spawn(function()
            while Settings.AutoPole and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyPole", math.random(1, 1000))
                end)
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleAutoSawSword(state)
    Settings.AutoSawSword = state
    if state then
        spawn(function()
            while Settings.AutoSawSword and LocalPlayer.Character do
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySaw", math.random(1, 1000))
                end)
                wait(randomizedDelay)
            end
        end)
    end
end

local function toggleSpeedHack(state)
    Settings.SpeedHack = state
    if state then
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end

local function toggleFruitSniper(state)
    Settings.FruitSniper = state
    if state then
        spawn(function()
            while Settings.FruitSniper and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, fruit in pairs(workspace:GetChildren()) do
                    if fruit:IsA("Tool") and (string.find(fruit.Name, "Fruit") or string.find(fruit.Name, "DevilFruit")) and not string.find(fruit.Name, "sail_boat") then
                        safeTeleport(fruit.Handle.CFrame)
                        wait(randomizedDelay)
                    end
                end
                StatusLabel.Text = "Status: Sniping fruits..."
                wait()
            end
        end)
    end
end

local function toggleESP(state)
    Settings.ESPEnabled = state
    if state then
        spawn(function()
            while Settings.ESPEnabled do
                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.Adornee = enemy.HumanoidRootPart
                        billboard.AlwaysOnTop = true
                        billboard.Parent = enemy

                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.Text = enemy.Name
                        text.TextColor3 = Color3.fromRGB(255, 0, 0)
                        text.TextScaled = true
                        text.Parent = billboard
                    end
                end
                wait(1)
            end
        end)
    else
        for _, enemy in pairs(workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("BillboardGui") then
                enemy.BillboardGui:Destroy()
            end
        end
    end
end

local function toggleAimbot(state)
    Settings.AimbotEnabled = state
    if state then
        spawn(function()
            while Settings.AimbotEnabled and LocalPlayer.Character do
                local closest = getNearestEnemy()
                if closest and closest.HumanoidRootPart then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, closest.HumanoidRootPart.Position)
                end
                wait()
            end
        end)
    end
end

local function toggleAutoQuest(state)
    Settings.AutoQuest = state
    if state then
        spawn(function()
            while Settings.AutoQuest and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, npc in pairs(workspace.NPCs:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                        safeTeleport(npc.HumanoidRootPart.CFrame)
                        wait(randomizedDelay)
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0, 0))
                    end
                end
                StatusLabel.Text = "Status: Completing quests..."
                wait()
            end
        end)
    end
end

local function toggleAutoTeleport(state)
    Settings.AutoTeleport = state
    if state then
        spawn(function()
            while Settings.AutoTeleport and LocalPlayer.Character do
                if panicModeCheck() or (checkCrowdedServer() and Settings.SafeMode) then wait(1) continue end
                for _, island in pairs(workspace:GetChildren()) do
                    if island:IsA("Model") and string.find(island.Name, "Island") then
                        safeTeleport(island:GetPrimaryPart().CFrame)
                        wait(randomizedDelay * 10)
                    end
                end
                StatusLabel.Text = "Status: Teleporting to islands..."
                wait()
            end
        end)
    end
end

local function toggleServerHop(state)
    Settings.ServerHop = state
    if state then
        spawn(function()
            while Settings.ServerHop do
                if tick() - lastServerHop >= serverHopInterval then
                    pcall(function()
                        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                        for _, server in pairs(servers.data) do
                            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                                break
                            end
                        end
                        StatusLabel.Text = "Status: Hopping servers..."
                    end)
                    lastServerHop = tick()
                end
                wait(60)
            end
        end)
    end
end

local function toggleSafeMode(state)
    Settings.SafeMode = state
    StatusLabel.Text = "Status: Safe Mode " .. (state and "Enabled" or "Disabled")
end

local function togglePanicMode(state)
    Settings.PanicMode = state
    StatusLabel.Text = "Status: Panic Mode " .. (state and "Enabled" or "Disabled")
end

-- Anti-Cheat Bypass
if Settings.AntiCheatBypass then
    spawn(function()
        while Settings.AntiCheatBypass do
            pcall(function()
                -- Randomize inputs
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(math.random(0, 100), math.random(0, 100)))
                VirtualUser:Button1Down(Vector2.new(math.random(0, 100), math.random(0, 100)))
                VirtualUser:Button1Up(Vector2.new(math.random(0, 100), math.random(0, 100)))
                wait(fakeInputInterval)
                
                -- Clamp stats
                if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
                    LocalPlayer.Character.Humanoid.WalkSpeed = math.clamp(LocalPlayer.Character.Humanoid.WalkSpeed, 16, Settings.WalkSpeed)
                    LocalPlayer.Character.Humanoid.JumpPower = math.clamp(LocalPlayer.Character.Humanoid.JumpPower, 50, 50)
                end
            end)
            fakeInputInterval = math.random(5, 10)
            wait()
        end
    end)
end

-- Create Buttons
createButton("AutoFarmLevel", Settings.AutoFarmLevel, toggleAutoFarmLevel, "Farm")
createButton("AutoFarmBoss", Settings.AutoFarmBoss, toggleAutoFarmBoss, "Farm")
createButton("AutoFarmMobs", Settings.AutoFarmMobs, toggleAutoFarmMobs, "Farm")
createButton("AutoCollectChests", Settings.AutoCollectChests, toggleAutoCollectChests, "Farm")
createButton("AutoCollectFruits", Settings.AutoCollectFruits, toggleAutoCollectFruits, "Farm")
createButton("AutoStoreFruits", Settings.AutoStoreFruits, toggleAutoStoreFruits, "Farm")
createButton("AutoRandomFruit", Settings.AutoRandomFruit, toggleAutoRandomFruit, "Farm")
createButton("AutoRaid", Settings.AutoRaid, toggleAutoRaid, "Farm")
createButton("AutoSeaEvent", Settings.AutoSeaEvent, toggleAutoSeaEvent, "Farm")
createButton("AutoTerrorshark", Settings.AutoTerrorshark, toggleAutoTerrorshark, "Farm")
createButton("AutoMirageIsland", Settings.AutoMirageIsland, toggleAutoMirageIsland, "Farm")
createButton("AutoPrehistoricIsland", Settings.AutoPrehistoricIsland, toggleAutoPrehistoricIsland, "Farm")
createButton("AutoRaceV4", Settings.AutoRaceV4, toggleAutoRaceV4, "Farm")
createButton("AutoDojoQuest", Settings.AutoDojoQuest, toggleAutoDojoQuest, "Farm")
createButton("AutoDracoRace", Settings.AutoDracoRace, toggleAutoDracoRace, "Farm")
createButton("AutoBelt", Settings.AutoBelt, toggleAutoBelt, "Farm")
createButton("AutoKitsuneEvent", Settings.AutoKitsuneEvent, toggleAutoKitsuneEvent, "Farm")
createButton("AutoDragonTokens", Settings.AutoDragonTokens, toggleAutoDragonTokens, "Farm")
createButton("AutoGasFruit", Settings.AutoGasFruit, toggleAutoGasFruit, "Farm")
createButton("AutoMastery", Settings.AutoMastery, toggleAutoMastery, "Combat")
createButton("AutoStats", Settings.AutoStats, toggleAutoStats, "Combat")
createButton("AutoHaki", Settings.AutoHaki, toggleAutoHaki, "Combat")
createButton("FastAttack", Settings.FastAttack, toggleFastAttack, "Combat")
createButton("AutoSaber", Settings.AutoSaber, toggleAutoSaber, "Combat")
createButton("AutoPole", Settings.AutoPole, toggleAutoPole, "Combat")
createButton("AutoSawSword", Settings.AutoSawSword, toggleAutoSawSword, "Combat")
createButton("SpeedHack", Settings.SpeedHack, toggleSpeedHack, "Combat")
createButton("FruitSniper", Settings.FruitSniper, toggleFruitSniper, "Farm")
createButton("ESPEnabled", Settings.ESPEnabled, toggleESP, "Combat")
createButton("AimbotEnabled", Settings.AimbotEnabled, toggleAimbot, "Combat")
createButton("AutoQuest", Settings.AutoQuest, toggleAutoQuest, "Farm")
createButton("AutoTeleport", Settings.AutoTeleport, toggleAutoTeleport, "Teleport")
createButton("ServerHop", Settings.ServerHop, toggleServerHop, "Misc")
createButton("SafeMode", Settings.SafeMode, toggleSafeMode, "Misc")
createButton("PanicMode", Settings.PanicMode, togglePanicMode, "Misc")

-- Close Button Functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Mobile Optimization
MainFrame.Size = UDim2.new(0, math.min(400, game:GetService("GuiService"):GetScreenResolution().X - 20), 0, 600)

-- Heartbeat Loop for Safety
RunService.Heartbeat:Connect(function()
    if Settings.AntiCheatBypass and LocalPlayer.Character and LocalPlayer.Character.Humanoid then
        -- Prevent AFK kicks
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(math.random(0, 100), math.random(0, 100)))
        
        -- Clamp suspicious values
        LocalPlayer.Character.Humanoid.JumpPower = math.clamp(LocalPlayer.Character.Humanoid.JumpPower, 50, 50)
        LocalPlayer.Character.Humanoid.WalkSpeed = math.clamp(LocalPlayer.Character.Humanoid.WalkSpeed, 16, Settings.WalkSpeed)
    end
end)

-- Initialize GUI
ScreenGui.Enabled = true

-- Notify User
print("Redz Hub Blox Fruits Script Loaded! Use responsibly.")
