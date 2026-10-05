--!strict
--[[
    AutomationService.luau
    Simulates conveyor item flow, auto-harvesters, and Wisp Keeper NPC routines.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Common.Config.GameConfig)
local BuildingsData = require(ReplicatedStorage.Common.Config.BuildingsData)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)

local AutomationService = {}

function AutomationService:Init()
    -- Wisp Keeper routine loop (every 10s)
    task.spawn(function()
        while true do
            task.wait(10)
            self:ProcessWispKeepers()
        end
    end)
end

function AutomationService:ProcessWispKeepers()
    for _, player in ipairs(Players:GetPlayers()) do
        local profile = DataService:GetProfile(player)
        if not profile then continue end

        -- Count active Wisp Cottages
        local wispCount = 0
        for _, building in pairs(profile.PlacedBuildings) do
            if building.BuildingId == "Wisp_Cottage" then
                wispCount += 1
            end
        end

        if wispCount > 0 and profile.Creatures then
            -- Each wisp feeds up to 2 needy creatures
            local tended = 0
            local maxTended = wispCount * 2

            for _, creature in pairs(profile.Creatures) do
                if creature.Happiness < 75 and tended < maxTended then
                    creature.Happiness = math.min(100, creature.Happiness + 20)
                    tended += 1
                end
            end
        end
    end
end

return AutomationService
