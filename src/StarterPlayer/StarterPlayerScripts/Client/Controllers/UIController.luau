--!strict
--[[
    UIController.luau
    Manages PC-centric rich interface: Top currency bar, hotbar shortcuts,
    Build Catalog, Hybridization Lab modal, and Tourism & Visitor Ledger.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuildingsData = require(ReplicatedStorage.Common.Config.BuildingsData)
local CreaturesData = require(ReplicatedStorage.Common.Config.CreaturesData)
local FormatUtil = require(ReplicatedStorage.Common.Utils.FormatUtil)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)

local PlotController = require(script.Parent.PlotController)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UIController = {
    ScreenGui = nil :: ScreenGui?,
    ActiveModal = nil :: Frame?,
    Labels = {} :: { [string]: TextLabel },
}

local function createRoundedFrame(name: string, size: UDim2, pos: UDim2, color: Color3): Frame
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    return frame
end

function UIController:Init()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BeastHavenUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    self.ScreenGui = screenGui

    self:CreateTopBar()
    self:CreateHotbar()
    self:CreateBuildCatalog()
    self:CreateHybridModal()
    self:CreateTourismModal()
    self:SetupKeybinds()
    self:ListenToNetwork()
end

function UIController:CreateTopBar()
    local topBar = createRoundedFrame("TopBar", UDim2.new(0, 520, 0, 50), UDim2.new(0.5, -260, 0, 15), Color3.fromRGB(30, 32, 40))
    topBar.BackgroundTransparency = 0.15
    topBar.Parent = self.ScreenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 20)
    layout.Parent = topBar

    local function makeCounter(name: string, icon: string, defaultText: string, color: Color3)
        local container = Instance.new("Frame")
        container.Name = name .. "Container"
        container.Size = UDim2.new(0, 140, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = topBar

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = icon .. " " .. defaultText
        label.TextColor3 = color
        label.Font = Enum.Font.FredokaOne
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = container

        self.Labels[name] = label
    end

    makeCounter("Essence", "🍃", "250", Color3.fromRGB(120, 255, 140))
    makeCounter("Crystals", "💎", "10", Color3.fromRGB(120, 220, 255))
    makeCounter("Tickets", "🎟️", "0", Color3.fromRGB(255, 210, 100))
end

function UIController:CreateHotbar()
    local hotbar = createRoundedFrame("Hotbar", UDim2.new(0, 480, 0, 55), UDim2.new(0.5, -240, 1, -70), Color3.fromRGB(24, 26, 34))
    hotbar.BackgroundTransparency = 0.1
    hotbar.Parent = self.ScreenGui

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 12)
    layout.Parent = hotbar

    local buttons = {
        { Id = "Build", Icon = "🔨", Text = "Construire [B]", Color = Color3.fromRGB(80, 170, 240) },
        { Id = "Hybrids", Icon = "🧪", Text = "Hybrides [H]", Color = Color3.fromRGB(180, 90, 240) },
        { Id = "Tourism", Icon = "⭐", Text = "Tourisme [V]", Color = Color3.fromRGB(240, 170, 70) },
        { Id = "Zones", Icon = "🗺️", Text = "Biomes [Z]", Color = Color3.fromRGB(100, 220, 130) },
    }

    for _, btnData in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = btnData.Id .. "Button"
        btn.Size = UDim2.new(0, 105, 0, 40)
        btn.BackgroundColor3 = btnData.Color
        btn.Text = btnData.Icon .. " " .. btnData.Text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.FredokaOne
        btn.TextSize = 13
        btn.AutoButtonColor = true

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            self:ToggleModal(btnData.Id)
        end)

        btn.Parent = hotbar
    end
end

function UIController:CreateBuildCatalog()
    local modal = createRoundedFrame("BuildCatalogModal", UDim2.new(0, 600, 0, 420), UDim2.new(0.5, -300, 0.5, -210), Color3.fromRGB(32, 35, 45))
    modal.Visible = false
    modal.Parent = self.ScreenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🔨 Catalogue de Construction du Sanctuaire"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = modal

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 16
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        modal.Visible = false
    end)
    closeBtn.Parent = modal

    -- Item Scrolling Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -40, 1, -70)
    scroll.Position = UDim2.new(0, 20, 0, 55)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
    scroll.Parent = modal

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 175, 0, 140)
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.Parent = scroll

    for bId, bConfig in pairs(BuildingsData) do
        if bId == "Central_Vault" then continue end

        local card = createRoundedFrame("Card_" .. bId, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(45, 48, 62))
        card.Parent = scroll

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -10, 0, 24)
        nameLabel.Position = UDim2.new(0, 5, 0, 6)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = bConfig.DisplayName
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.FredokaOne
        nameLabel.TextSize = 13
        nameLabel.TextWrapped = true
        nameLabel.Parent = card

        local costLabel = Instance.new("TextLabel")
        costLabel.Size = UDim2.new(1, -10, 0, 20)
        costLabel.Position = UDim2.new(0, 5, 0, 32)
        costLabel.BackgroundTransparency = 1
        local icon = if bConfig.CostCurrency == "Essence" then "🍃" else "💎"
        costLabel.Text = icon .. " " .. FormatUtil.formatNumber(bConfig.CostAmount)
        costLabel.TextColor3 = if bConfig.CostCurrency == "Essence" then Color3.fromRGB(120, 255, 140) else Color3.fromRGB(120, 220, 255)
        costLabel.Font = Enum.Font.FredokaOne
        costLabel.TextSize = 14
        costLabel.Parent = card

        local placeBtn = Instance.new("TextButton")
        placeBtn.Size = UDim2.new(1, -20, 0, 32)
        placeBtn.Position = UDim2.new(0, 10, 1, -40)
        placeBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 230)
        placeBtn.Text = "Placer"
        placeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        placeBtn.Font = Enum.Font.FredokaOne
        placeBtn.TextSize = 14
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 6)
        pCorner.Parent = placeBtn

        placeBtn.MouseButton1Click:Connect(function()
            modal.Visible = false
            PlotController:StartPlacement(bId)
        end)
        placeBtn.Parent = card
    end
end

function UIController:CreateHybridModal()
    local modal = createRoundedFrame("HybridModal", UDim2.new(0, 560, 0, 380), UDim2.new(0.5, -280, 0.5, -190), Color3.fromRGB(34, 30, 48))
    modal.Visible = false
    modal.Parent = self.ScreenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🧪 Laboratoire d'Incubation & Génétique"
    title.TextColor3 = Color3.fromRGB(240, 180, 255)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = modal

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 16
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        modal.Visible = false
    end)
    closeBtn.Parent = modal

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 50)
    desc.Position = UDim2.new(0, 20, 0, 50)
    desc.BackgroundTransparency = 1
    desc.Text = "Combinez deux créatures pour fusionner leurs gènes et obtenir une espèce hybride inédite aux mutations rares (Shiny, Neon, Cosmique) !"
    desc.TextColor3 = Color3.fromRGB(210, 200, 230)
    desc.Font = Enum.Font.FredokaOne
    desc.TextSize = 14
    desc.TextWrapped = true
    desc.Parent = modal
end

function UIController:CreateTourismModal()
    local modal = createRoundedFrame("TourismModal", UDim2.new(0, 560, 0, 360), UDim2.new(0.5, -280, 0.5, -180), Color3.fromRGB(42, 36, 30))
    modal.Visible = false
    modal.Parent = self.ScreenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "⭐ Tourisme & Billetterie du Sanctuaire"
    title.TextColor3 = Color3.fromRGB(255, 220, 130)
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = modal

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.FredokaOne
    closeBtn.TextSize = 16
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function()
        modal.Visible = false
    end)
    closeBtn.Parent = modal

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 60)
    desc.Position = UDim2.new(0, 20, 0, 55)
    desc.BackgroundTransparency = 1
    desc.Text = "Fixez le prix d'entrée pour les touristes et les joueurs du serveur. Aménagez de beaux enclos pour recevoir 5 étoiles et collecter des Tickets de Prestige !"
    desc.TextColor3 = Color3.fromRGB(240, 230, 210)
    desc.Font = Enum.Font.FredokaOne
    desc.TextSize = 14
    desc.TextWrapped = true
    desc.Parent = modal
end

function UIController:ToggleModal(modalId: string)
    local targetModalName = modalId .. "CatalogModal"
    if modalId == "Hybrids" then targetModalName = "HybridModal" end
    if modalId == "Tourism" then targetModalName = "TourismModal" end

    local modal = self.ScreenGui:FindFirstChild(targetModalName) :: Frame?
    if modal then
        modal.Visible = not modal.Visible
    end
end

function UIController:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.B then
            self:ToggleModal("Build")
        elseif input.KeyCode == Enum.KeyCode.H then
            self:ToggleModal("Hybrids")
        elseif input.KeyCode == Enum.KeyCode.V then
            self:ToggleModal("Tourism")
        end
    end)
end

function UIController:ListenToNetwork()
    local balanceRemote = NetworkUtil.getRemoteEvent("BalanceChanged")
    balanceRemote.OnClientEvent:Connect(function(currency, newBalance)
        local label = self.Labels[currency]
        if label then
            local icon = "🍃"
            if currency == "Crystals" then icon = "💎" end
            if currency == "Tickets" then icon = "🎟️" end
            label.Text = icon .. " " .. FormatUtil.formatNumber(newBalance)
        end
    end)
end

return UIController
