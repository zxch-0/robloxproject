--!strict
--[[
    GameConfig.luau
    Central game settings, tuning constants, and plot configuration.
]]

local GameConfig = {
    GAME_NAME = "Beast Haven: Sanctuary Tycoon",
    VERSION = "0.1.0",

    -- Grid & Placement Settings
    GRID_CELL_SIZE = 4, -- 4 studs grid snap
    PLOT_SIZE = Vector2.new(128, 128), -- 128x128 studs plot
    MAX_PLOTS_PER_SERVER = 6,

    -- Economy & Currency
    CURRENCIES = {
        ESSENCE = "Essence",            -- Main soft currency from creatures
        HARMONY_CRYSTALS = "Crystals",  -- Premium/Rare currency from hybrids & tourism
        PRESTIGE_TICKETS = "Tickets",   -- Social currency earned from visitors
    },

    STARTING_VALUES = {
        ESSENCE = 250,
        HARMONY_CRYSTALS = 10,
        PRESTIGE_TICKETS = 0,
        SANCTUARY_LEVEL = 1,
    },

    -- Automation & Ticks
    AUTOMATION = {
        RESOURCE_TICK_RATE = 2.0, -- Seconds between creature production pulses
        CONVEYOR_SPEED = 12.0,     -- Studs per second for carried essence orbs
        AUTO_SAVE_INTERVAL = 60,   -- Seconds between DataStore auto-saves
    },

    -- Tourism & Park Visiting
    TOURISM = {
        DEFAULT_TICKET_PRICE = 5,
        MAX_TICKET_PRICE = 50,
        VISITOR_NPC_SPAWN_INTERVAL = 30, -- Seconds between tourist arrivals
        MAX_NPC_VISITORS_PER_PLOT = 8,
        POPULARITY_EXPIRY_HOURS = 24,
    },

    -- Breeding & Hybridization
    HYBRIDIZATION = {
        BASE_INCUBATION_TIME = 20, -- Seconds for common egg incubation
        MAX_INCUBATION_SLOTS = 3,
        MUTATION_CHANCE = 0.08, -- 8% base chance of rare mutation (Shiny/Neon)
    },
}

return GameConfig
