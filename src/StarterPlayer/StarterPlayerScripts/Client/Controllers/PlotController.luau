--!strict
--[[
    PlotController.luau
    Handles client-side grid building placement preview, PC mouse raycasting,
    rotation (R), validation feedback (Green/Red holographic box), and server requests.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Common.Config.GameConfig)
local BuildingsData = require(ReplicatedStorage.Common.Config.BuildingsData)
local MathUtil = require(ReplicatedStorage.Common.Utils.MathUtil)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

local PlotController = {
    IsBuilding = false,
    SelectedBuildingId = nil :: string?,
    CurrentRotation = 0,
    PreviewModel = nil :: Model?,
}

local function getMouseTargetPosition(): Vector3?
    local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local excludeList = { player.Character }
    if PlotController.PreviewModel then
        table.insert(excludeList, PlotController.PreviewModel)
    end
    raycastParams.FilterDescendantsInstances = excludeList

    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)
    if result then
        return result.Position
    end
    return nil
end

function PlotController:Init()
    -- Key bindings: R for rotate, Esc or X for cancel
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Enum.KeyCode.R and self.IsBuilding then
            self:RotatePreview()
        elseif (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Q) and self.IsBuilding then
            self:CancelPlacement()
        end
    end)

    -- Mouse click to place
    mouse.Button1Down:Connect(function()
        if self.IsBuilding and self.SelectedBuildingId then
            self:ConfirmPlacement()
        end
    end)

    mouse.Button2Down:Connect(function()
        if self.IsBuilding then
            self:CancelPlacement()
        end
    end)

    -- Update preview position on render step
    RunService.RenderStepped:Connect(function()
        if self.IsBuilding and self.PreviewModel then
            self:UpdatePreviewPosition()
        end
    end)
end

function PlotController:StartPlacement(buildingId: string)
    local bConfig = BuildingsData[buildingId]
    if not bConfig then return end

    self:CancelPlacement()

    self.SelectedBuildingId = buildingId
    self.CurrentRotation = 0
    self.IsBuilding = true

    -- Create translucent preview model
    local model = Instance.new("Model")
    model.Name = "PlacementPreview"

    local ghostPart = Instance.new("Part")
    ghostPart.Name = "GhostBox"
    ghostPart.Size = Vector3.new(
        bConfig.GridSize.X * GameConfig.GRID_CELL_SIZE,
        1.5,
        bConfig.GridSize.Y * GameConfig.GRID_CELL_SIZE
    )
    ghostPart.Transparency = 0.4
    ghostPart.Material = Enum.Material.ForceField
    ghostPart.Color = Color3.fromRGB(0, 255, 127)
    ghostPart.Anchored = true
    ghostPart.CanCollide = false
    ghostPart.CastShadow = false
    ghostPart.Parent = model

    -- Selection box outline
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Color3 = Color3.fromRGB(255, 255, 255)
    selectionBox.Adornee = ghostPart
    selectionBox.Parent = ghostPart

    model.PrimaryPart = ghostPart
    model.Parent = Workspace
    self.PreviewModel = model
end

function PlotController:RotatePreview()
    self.CurrentRotation = (self.CurrentRotation + 90) % 360
end

function PlotController:UpdatePreviewPosition()
    if not self.PreviewModel or not self.SelectedBuildingId then return end

    local hitPos = getMouseTargetPosition()
    if not hitPos then return end

    local snapped = MathUtil.snapToGrid(hitPos, GameConfig.GRID_CELL_SIZE)
    local cframe = CFrame.new(snapped.X, 0.75, snapped.Z) * CFrame.Angles(0, math.rad(self.CurrentRotation), 0)

    self.PreviewModel:SetPrimaryPartCFrame(cframe)
end

function PlotController:ConfirmPlacement()
    if not self.PreviewModel or not self.SelectedBuildingId then return end

    local primary = self.PreviewModel.PrimaryPart
    if not primary then return end

    local currentPos = primary.Position
    local gridX = math.round(currentPos.X / GameConfig.GRID_CELL_SIZE)
    local gridZ = math.round(currentPos.Z / GameConfig.GRID_CELL_SIZE)

    local remote = NetworkUtil.getRemoteEvent("PlaceBuilding")
    remote:FireServer(self.SelectedBuildingId, gridX, gridZ, self.CurrentRotation)

    -- Play placement sound effect or visual confirmation
    self:CancelPlacement()
end

function PlotController:CancelPlacement()
    self.IsBuilding = false
    self.SelectedBuildingId = nil
    if self.PreviewModel then
        self.PreviewModel:Destroy()
        self.PreviewModel = nil
    end
end

return PlotController
