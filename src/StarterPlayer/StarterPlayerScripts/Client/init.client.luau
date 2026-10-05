--!strict
--[[
    init.client.luau
    Client entrypoint for Beast Haven: Sanctuary Tycoon.
    Bootstraps player controls, placement system, visual effects, and UI.
]]

local PlotController = require(script.Controllers.PlotController)
local CreatureController = require(script.Controllers.CreatureController)
local UIController = require(script.Controllers.UIController)

print("[BeastHaven Client] Initializing systems...")

PlotController:Init()
CreatureController:Init()
UIController:Init()

print("[BeastHaven Client] Beast Haven loaded! Press [B] to open Build Catalog, [H] for Hybrids, [V] for Tourism.")
