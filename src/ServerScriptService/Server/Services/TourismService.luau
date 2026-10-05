--!strict
--[[
    TourismService.luau
    Handles visitor admission ticketing, tourist NPC pathing/tips,
    sanctuary ratings (stars/upvotes), and cross-player park exploration.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Common.Config.GameConfig)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local TycoonService = require(script.Parent.TycoonService)

local TourismService = {}

function TourismService:Init()
    -- Ticket price modification
    local ticketRemote = NetworkUtil.getRemoteEvent("SetTicketPrice")
    ticketRemote.OnServerEvent:Connect(function(player, price)
        self:SetTicketPrice(player, price)
    end)

    -- Rating submission
    local rateRemote = NetworkUtil.getRemoteEvent("RateSanctuary")
    rateRemote.OnServerEvent:Connect(function(player, targetPlayerId, stars)
        self:SubmitRating(player, targetPlayerId, stars)
    end)

    -- Visit request
    local visitRemote = NetworkUtil.getRemoteEvent("VisitSanctuary")
    visitRemote.OnServerEvent:Connect(function(player, targetPlayerId)
        self:TeleportToSanctuary(player, targetPlayerId)
    end)

    -- NPC Visitor spawning loop
    task.spawn(function()
        while true do
            task.wait(GameConfig.TOURISM.VISITOR_NPC_SPAWN_INTERVAL)
            self:ProcessNpcVisitors()
        end
    end)
end

function TourismService:SetTicketPrice(player: Player, newPrice: number)
    local clamped = math.clamp(math.floor(newPrice), 0, GameConfig.TOURISM.MAX_TICKET_PRICE)
    DataService:UpdateProfile(player, function(profile)
        profile.Tourism.TicketPrice = clamped
    end)

    local prestigeRemote = NetworkUtil.getRemoteEvent("PrestigeUpdated")
    prestigeRemote:FireClient(player, "TicketPrice", clamped)
end

function TourismService:TeleportToSanctuary(visitor: Player, targetPlayerId: number)
    local host = Players:GetPlayerByUserId(targetPlayerId)
    if not host or host == visitor then return end

    local hostProfile = DataService:GetProfile(host)
    if not hostProfile then return end

    local price = hostProfile.Tourism.TicketPrice or 0
    if price > 0 then
        if not EconomyService:HasEnough(visitor, "Essence", price) then
            return
        end
        EconomyService:SpendCurrency(visitor, "Essence", price)
        EconomyService:AddCurrency(host, "Essence", price)
        -- Give host a prestige ticket as social bonus
        EconomyService:AddCurrency(host, "Tickets", 1)
    end

    local hostPlot = TycoonService:GetPlayerPlot(host)
    if hostPlot then
        local char = visitor.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart") :: BasePart
        if rootPart then
            rootPart.CFrame = hostPlot.CFrame + Vector3.new(0, 5, -GameConfig.PLOT_SIZE.Y / 2 + 8)
        end
    end

    -- Update host visit stats
    DataService:UpdateProfile(host, function(prof)
        prof.Tourism.TotalVisitors += 1
    end)

    local visitorArrived = NetworkUtil.getRemoteEvent("VisitorArrived")
    visitorArrived:FireClient(host, visitor.DisplayName)
end

function TourismService:SubmitRating(reviewer: Player, targetPlayerId: number, stars: number)
    local target = Players:GetPlayerByUserId(targetPlayerId)
    if not target or target == reviewer then return end

    local clampedStars = math.clamp(math.floor(stars), 1, 5)

    DataService:UpdateProfile(target, function(profile)
        profile.Tourism.RatingSum += clampedStars
        profile.Tourism.RatingCount += 1
        if clampedStars >= 4 then
            profile.Tourism.Upvotes += 1
        end
    end)

    -- Reward target with Prestige Tickets
    EconomyService:AddCurrency(target, "Tickets", clampedStars)

    local prestigeRemote = NetworkUtil.getRemoteEvent("PrestigeUpdated")
    prestigeRemote:FireClient(target, "NewRating", clampedStars)
end

function TourismService:ProcessNpcVisitors()
    for _, player in ipairs(Players:GetPlayers()) do
        local profile = DataService:GetProfile(player)
        if not profile then continue end

        -- Check if player has built a Ticket Booth
        local hasTicketBooth = false
        for _, b in pairs(profile.PlacedBuildings) do
            if b.BuildingId == "Ticket_Booth" then
                hasTicketBooth = true
                break
            end
        end

        if hasTicketBooth then
            -- NPC pays ticket price + gives random rating
            local revenue = profile.Tourism.TicketPrice
            EconomyService:AddCurrency(player, "Essence", revenue)
            EconomyService:AddCurrency(player, "Tickets", 1)

            DataService:UpdateProfile(player, function(prof)
                prof.Tourism.TotalVisitors += 1
                prof.Tourism.RatingSum += 5
                prof.Tourism.RatingCount += 1
            end)

            local visitorArrived = NetworkUtil.getRemoteEvent("VisitorArrived")
            visitorArrived:FireClient(player, "Touriste Curieux")
        end
    end
end

return TourismService
