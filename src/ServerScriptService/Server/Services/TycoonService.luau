--!strict
--[[
    TycoonService.luau
    Manages physical sanctuary plots, grid building placement, collision checks,
    and visual world representation.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage.Common.Config.GameConfig)
local BuildingsData = require(ReplicatedStorage.Common.Config.BuildingsData)
local MathUtil = require(ReplicatedStorage.Common.Utils.MathUtil)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)

local TycoonService = {}

type PlotInstance = {
    Owner: Player?,
    PlotIndex: number,
    CFrame: CFrame,
    Folder: Folder,
}

local plots: { [number]: PlotInstance } = {}
local playerPlots: { [Player]: number } = {}

local function createSanctuaryFolder(): Folder
    local folder = Workspace:FindFirstChild("SanctuaryPlots")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "SanctuaryPlots"
        folder.Parent = Workspace
    end
    return folder :: Folder
end

function TycoonService:Init()
    local sanctuaryRoot = createSanctuaryFolder()

    -- Generate static plot locations
    local plotSpacing = 160 -- studs
    for i = 1, GameConfig.MAX_PLOTS_PER_SERVER do
        local angle = (i - 1) * (2 * math.pi / GameConfig.MAX_PLOTS_PER_SERVER)
        local posX = math.cos(angle) * plotSpacing
        local posZ = math.sin(angle) * plotSpacing
        local plotCFrame = CFrame.new(posX, 0, posZ)

        local plotFolder = Instance.new("Folder")
        plotFolder.Name = "Plot_" .. i
        plotFolder.Parent = sanctuaryRoot

        -- Create visual base ground
        local ground = Instance.new("Part")
        ground.Name = "PlotGround"
        ground.Size = Vector3.new(GameConfig.PLOT_SIZE.X, 2, GameConfig.PLOT_SIZE.Y)
        ground.Position = Vector3.new(posX, -1, posZ)
        ground.Anchored = true
        ground.Material = Enum.Material.SmoothPlastic
        ground.Color = Color3.fromRGB(115, 185, 95)
        ground.TopSurface = Enum.SurfaceType.Smooth
        ground.Parent = plotFolder

        plots[i] = {
            Owner = nil,
            PlotIndex = i,
            CFrame = plotCFrame,
            Folder = plotFolder,
        }
    end

    DataService.ProfileLoaded:Connect(function(player, profile)
        self:AssignPlot(player, profile)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:ReleasePlot(player)
    end)

    -- Hook up remote events
    local placeRemote = NetworkUtil.getRemoteEvent("PlaceBuilding")
    placeRemote.OnServerEvent:Connect(function(player, buildingId, gridX, gridZ, rotation)
        self:HandlePlaceRequest(player, buildingId, gridX, gridZ, rotation)
    end)

    local removeRemote = NetworkUtil.getRemoteEvent("RemoveBuilding")
    removeRemote.OnServerEvent:Connect(function(player, buildingGuid)
        self:HandleRemoveRequest(player, buildingGuid)
    end)
end

function TycoonService:AssignPlot(player: Player, profile: any)
    for index, plot in ipairs(plots) do
        if plot.Owner == nil then
            plot.Owner = player
            playerPlots[player] = index
            plot.Folder.Name = "Plot_" .. player.Name

            -- Spawn saved buildings
            if profile.PlacedBuildings then
                for _, bData in pairs(profile.PlacedBuildings) do
                    self:SpawnPhysicalBuilding(plot, bData)
                end
            end

            -- Teleport player to their plot
            task.spawn(function()
                local character = player.Character or player.CharacterAdded:Wait()
                local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: BasePart
                if rootPart then
                    rootPart.CFrame = plot.CFrame + Vector3.new(0, 5, 0)
                end
            end)
            return
        end
    end
end

function TycoonService:ReleasePlot(player: Player)
    local plotIndex = playerPlots[player]
    if not plotIndex then return end

    local plot = plots[plotIndex]
    if plot then
        plot.Owner = nil
        plot.Folder:ClearAllChildren()
        plot.Folder.Name = "Plot_" .. plotIndex
    end
    playerPlots[player] = nil
end

function TycoonService:GetPlayerPlot(player: Player): PlotInstance?
    local idx = playerPlots[player]
    if not idx then return nil end
    return plots[idx]
end

function TycoonService:HandlePlaceRequest(
    player: Player,
    buildingId: string,
    gridX: number,
    gridZ: number,
    rotation: number
)
    local bConfig = BuildingsData[buildingId]
    if not bConfig then return end

    local plot = self:GetPlayerPlot(player)
    if not plot then return end

    local profile = DataService:GetProfile(player)
    if not profile then return end

    -- Check currency cost
    if not EconomyService:HasEnough(player, bConfig.CostCurrency, bConfig.CostAmount) then
        return
    end

    -- Verify boundary
    local halfPlot = GameConfig.PLOT_SIZE / 2
    local worldX = gridX * GameConfig.GRID_CELL_SIZE
    local worldZ = gridZ * GameConfig.GRID_CELL_SIZE
    if math.abs(worldX) > halfPlot.X - 4 or math.abs(worldZ) > halfPlot.Y - 4 then
        return
    end

    -- Verify no overlap with existing buildings
    local newSize = bConfig.GridSize
    for _, existing in pairs(profile.PlacedBuildings) do
        local exConfig = BuildingsData[existing.BuildingId]
        if exConfig then
            local overlap = MathUtil.checkAABBOverlap(
                Vector2.new(gridX, gridZ),
                newSize,
                Vector2.new(existing.GridX, existing.GridZ),
                exConfig.GridSize
            )
            if overlap then
                return -- Spot occupied!
            end
        end
    end

    -- Deduct currency
    if not EconomyService:SpendCurrency(player, bConfig.CostCurrency, bConfig.CostAmount) then
        return
    end

    -- Generate GUID and save
    local guid = HttpService:GenerateGUID(false)
    local buildingData: DataService.PlacedBuildingData = {
        Guid = guid,
        BuildingId = buildingId,
        GridX = gridX,
        GridZ = gridZ,
        Rotation = rotation,
        Level = 1,
    }

    DataService:UpdateProfile(player, function(prof)
        prof.PlacedBuildings[guid] = buildingData
    end)

    -- Spawn physical model
    self:SpawnPhysicalBuilding(plot, buildingData)

    -- Notify client
    local updateRemote = NetworkUtil.getRemoteEvent("BuildingStateUpdated")
    updateRemote:FireClient(player, "Placed", buildingData)
end

function TycoonService:HandleRemoveRequest(player: Player, buildingGuid: string)
    local plot = self:GetPlayerPlot(player)
    if not plot then return end

    local profile = DataService:GetProfile(player)
    if not profile or not profile.PlacedBuildings[buildingGuid] then return end

    local bData = profile.PlacedBuildings[buildingGuid]
    if bData.BuildingId == "Central_Vault" then
        return -- Cannot remove central vault
    end

    -- Partial refund (50%)
    local bConfig = BuildingsData[bData.BuildingId]
    if bConfig and bConfig.CostAmount > 0 then
        local refund = math.floor(bConfig.CostAmount * 0.5)
        EconomyService:AddCurrency(player, bConfig.CostCurrency, refund)
    end

    DataService:UpdateProfile(player, function(prof)
        prof.PlacedBuildings[buildingGuid] = nil
    end)

    local model = plot.Folder:FindFirstChild(buildingGuid)
    if model then
        model:Destroy()
    end

    local updateRemote = NetworkUtil.getRemoteEvent("BuildingStateUpdated")
    updateRemote:FireClient(player, "Removed", buildingGuid)
end

function TycoonService:SpawnPhysicalBuilding(plot: PlotInstance, bData: DataService.PlacedBuildingData)
    local bConfig = BuildingsData[bData.BuildingId]
    if not bConfig then return end

    local worldOffset = Vector3.new(
        bData.GridX * GameConfig.GRID_CELL_SIZE,
        0,
        bData.GridZ * GameConfig.GRID_CELL_SIZE
    )
    local worldCFrame = plot.CFrame * CFrame.new(worldOffset) * CFrame.Angles(0, math.rad(bData.Rotation), 0)

    local model = Instance.new("Model")
    model.Name = bData.Guid
    model:SetAttribute("BuildingId", bData.BuildingId)
    model:SetAttribute("Guid", bData.Guid)

    -- Construct procedural low-poly visual placeholder representation
    local primaryPart = Instance.new("Part")
    primaryPart.Name = "Base"
    primaryPart.Size = Vector3.new(
        bConfig.GridSize.X * GameConfig.GRID_CELL_SIZE,
        1.5,
        bConfig.GridSize.Y * GameConfig.GRID_CELL_SIZE
    )
    primaryPart.CFrame = worldCFrame + Vector3.new(0, 0.75, 0)
    primaryPart.Anchored = true
    primaryPart.Material = Enum.Material.SmoothPlastic

    if bConfig.Category == "Habitat" then
        primaryPart.Color = Color3.fromRGB(150, 220, 150)
    elseif bConfig.Category == "Automation" then
        primaryPart.Color = Color3.fromRGB(120, 160, 210)
    elseif bConfig.Category == "Facility" then
        primaryPart.Color = Color3.fromRGB(240, 180, 110)
    else
        primaryPart.Color = Color3.fromRGB(230, 230, 140)
    end

    primaryPart.Parent = model

    -- Add label billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 140, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = bConfig.DisplayName
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 14
    label.Parent = billboard
    billboard.Parent = primaryPart

    model.PrimaryPart = primaryPart
    model.Parent = plot.Folder
end

return TycoonService
