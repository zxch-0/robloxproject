--!strict
--[[
    init.server.luau
    Server entrypoint for Beast Haven: Sanctuary Tycoon.
    Bootstraps all server services and network remotes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)

-- Initialize Network Remotes
NetworkUtil.initServer()
print("[BeastHaven Server] Remotes successfully initialized.")

-- Require and start services
local DataService = require(script.Services.DataService)
local EconomyService = require(script.Services.EconomyService)
local TycoonService = require(script.Services.TycoonService)
local CreatureService = require(script.Services.CreatureService)
local AutomationService = require(script.Services.AutomationService)
local TourismService = require(script.Services.TourismService)

DataService:Init()
EconomyService:Init()
TycoonService:Init()
CreatureService:Init()
AutomationService:Init()
TourismService:Init()

print("[BeastHaven Server] All services booted and operational. Ready for players!")
