--!strict
--[[
    DataService.luau
    Manages player persistent data, profile initialization, auto-saving, and data migration.
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(game:GetService("ReplicatedStorage").Common.Config.GameConfig)
local Signal = require(game:GetService("ReplicatedStorage").Common.Utils.Signal)

local DATASTORE_NAME = "BeastHaven_PlayerData_v1"

export type PlacedBuildingData = {
    Guid: string,
    BuildingId: string,
    GridX: number,
    GridZ: number,
    Rotation: number,
    Level: number,
}

export type CreatureInstanceData = {
    Guid: string,
    SpeciesId: string,
    Rarity: string,
    Mutation: string,
    Happiness: number, -- 0 to 100
    Level: number,
    HabitatGuid: string?,
}

export type IncubationData = {
    SlotIndex: number,
    OffspringSpecies: string,
    OffspringRarity: string,
    OffspringMutation: string,
    StartTime: number,
    Duration: number,
}

export type PlayerProfile = {
    Version: number,
    Currencies: {
        Essence: number,
        Crystals: number,
        Tickets: number,
    },
    SanctuaryLevel: number,
    UnlockedZones: { [string]: boolean },
    PlacedBuildings: { [string]: PlacedBuildingData },
    Creatures: { [string]: CreatureInstanceData },
    Incubations: { IncubationData },
    Tourism: {
        TicketPrice: number,
        TotalVisitors: number,
        Upvotes: number,
        RatingSum: number,
        RatingCount: number,
    },
    Settings: {
        MusicVolume: number,
        SfxVolume: number,
        ShowVisitorBubbles: boolean,
    },
}

local DataService = {
    ProfileLoaded = Signal.new(),
    ProfileSaved = Signal.new(),
}

local profiles: { [Player]: PlayerProfile } = {}
local dataStore = if RunService:IsStudio() then nil else DataStoreService:GetDataStore(DATASTORE_NAME)

local function createDefaultProfile(): PlayerProfile
    local vaultGuid = HttpService:GenerateGUID(false)
    local meadowGuid = HttpService:GenerateGUID(false)
    local starterCreatureGuid = HttpService:GenerateGUID(false)

    return {
        Version = 1,
        Currencies = {
            Essence = GameConfig.STARTING_VALUES.ESSENCE,
            Crystals = GameConfig.STARTING_VALUES.HARMONY_CRYSTALS,
            Tickets = GameConfig.STARTING_VALUES.PRESTIGE_TICKETS,
        },
        SanctuaryLevel = GameConfig.STARTING_VALUES.SANCTUARY_LEVEL,
        UnlockedZones = {
            Meadow_Plains = true,
        },
        PlacedBuildings = {
            [vaultGuid] = {
                Guid = vaultGuid,
                BuildingId = "Central_Vault",
                GridX = 0,
                GridZ = 0,
                Rotation = 0,
                Level = 1,
            },
            [meadowGuid] = {
                Guid = meadowGuid,
                BuildingId = "Meadow_Enclosure",
                GridX = 6,
                GridZ = 0,
                Rotation = 0,
                Level = 1,
            },
        },
        Creatures = {
            [starterCreatureGuid] = {
                Guid = starterCreatureGuid,
                SpeciesId = "Fluffbun",
                Rarity = "Common",
                Mutation = "Standard",
                Happiness = 100,
                Level = 1,
                HabitatGuid = meadowGuid,
            },
        },
        Incubations = {},
        Tourism = {
            TicketPrice = GameConfig.TOURISM.DEFAULT_TICKET_PRICE,
            TotalVisitors = 0,
            Upvotes = 0,
            RatingSum = 5,
            RatingCount = 1,
        },
        Settings = {
            MusicVolume = 0.8,
            SfxVolume = 1.0,
            ShowVisitorBubbles = true,
        },
    }
end

function DataService:Init()
    Players.PlayerAdded:Connect(function(player)
        self:LoadProfile(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:SaveProfile(player)
        profiles[player] = nil
    end)

    -- Auto-save loop
    task.spawn(function()
        while true do
            task.wait(GameConfig.AUTOMATION.AUTO_SAVE_INTERVAL)
            for player, _ in pairs(profiles) do
                if player.Parent then
                    self:SaveProfile(player)
                end
            end
        end
    end)

    -- Handle server shutdown
    game:BindToClose(function()
        for player, _ in pairs(profiles) do
            self:SaveProfile(player)
        end
    end)
end

function DataService:LoadProfile(player: Player): PlayerProfile
    local key = "Player_" .. player.UserId
    local profile: PlayerProfile

    if dataStore then
        local success, result = pcall(function()
            return dataStore:GetAsync(key)
        end)
        if success and result then
            profile = result
        end
    end

    if not profile then
        profile = createDefaultProfile()
    end

    profiles[player] = profile
    self.ProfileLoaded:Fire(player, profile)
    return profile
end

function DataService:SaveProfile(player: Player): boolean
    local profile = profiles[player]
    if not profile then return false end

    local key = "Player_" .. player.UserId
    if dataStore then
        local success, err = pcall(function()
            dataStore:SetAsync(key, profile)
        end)
        if not success then
            warn("[DataService] Failed to save profile for", player.Name, ":", err)
            return false
        end
    end

    self.ProfileSaved:Fire(player, profile)
    return true
end

function DataService:GetProfile(player: Player): PlayerProfile?
    return profiles[player]
end

function DataService:UpdateProfile(player: Player, updateFn: (profile: PlayerProfile) -> ()): boolean
    local profile = profiles[player]
    if not profile then return false end

    updateFn(profile)
    return true
end

return DataService
