--!strict
--[[
    CreatureController.luau
    Client-side visual feedback for creature harvesting, heart particles, and floating numbers.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)
local FormatUtil = require(ReplicatedStorage.Common.Utils.FormatUtil)

local player = Players.LocalPlayer
local CreatureController = {}

local function spawnFloatingText(text: string, color: Color3, worldPos: Vector3)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.Position = worldPos
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 20
    label.Parent = billboard
    billboard.Parent = part

    -- Float upwards and fade out
    local targetPos = worldPos + Vector3.new(0, 4, 0)
    local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local moveTween = TweenService:Create(part, tweenInfo, { Position = targetPos })
    local fadeTween = TweenService:Create(label, tweenInfo, { TextTransparency = 1, TextStrokeTransparency = 1 })

    moveTween:Play()
    fadeTween:Play()

    task.delay(1.3, function()
        part:Destroy()
    end)
end

function CreatureController:Init()
    local harvestRemote = NetworkUtil.getRemoteEvent("CreatureHarvested")
    harvestRemote.OnClientEvent:Connect(function(amount)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
        if root then
            local pos = root.Position + Vector3.new(math.random(-2, 2), 3, math.random(-2, 2))
            spawnFloatingText("+" .. FormatUtil.formatNumber(amount) .. " 🍃", Color3.fromRGB(120, 255, 120), pos)
        end
    end)

    local prestigeRemote = NetworkUtil.getRemoteEvent("PrestigeUpdated")
    prestigeRemote.OnClientEvent:Connect(function(eventType, data)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
        if root and eventType == "NewRating" then
            local pos = root.Position + Vector3.new(0, 5, 0)
            spawnFloatingText("⭐ +" .. tostring(data) .. " Étoiles !", Color3.fromRGB(255, 220, 60), pos)
        end
    end)
end

return CreatureController
