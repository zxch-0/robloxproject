--!strict
--[[
    CreatureService.luau
    Core genetics, creature happiness, essence harvesting, and automated hybridization incubator.
]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage.Common.Config.GameConfig)
local CreaturesData = require(ReplicatedStorage.Common.Config.CreaturesData)
local RaritiesData = require(ReplicatedStorage.Common.Config.RaritiesData)
local MathUtil = require(ReplicatedStorage.Common.Utils.MathUtil)
local NetworkUtil = require(ReplicatedStorage.Common.Network.NetworkUtil)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)

local CreatureService = {}

function CreatureService:Init()
    -- Periodic essence generation loop
    task.spawn(function()
        while true do
            task.wait(GameConfig.AUTOMATION.RESOURCE_TICK_RATE)
            self:ProcessEssenceTick()
        end
    end)

    -- Player interactions (Feed & Pet)
    local feedRemote = NetworkUtil.getRemoteEvent("FeedCreature")
    feedRemote.OnServerEvent:Connect(function(player, creatureGuid)
        self:HandleFeed(player, creatureGuid)
    end)

    local petRemote = NetworkUtil.getRemoteEvent("PetCreature")
    petRemote.OnServerEvent:Connect(function(player, creatureGuid)
        self:HandlePet(player, creatureGuid)
    end)

    local startIncubationRemote = NetworkUtil.getRemoteEvent("StartIncubation")
    startIncubationRemote.OnServerEvent:Connect(function(player, parentAGuid, parentBGuid)
        self:HandleStartIncubation(player, parentAGuid, parentBGuid)
    end)

    local claimIncubationRemote = NetworkUtil.getRemoteEvent("ClaimIncubation")
    claimIncubationRemote.OnServerEvent:Connect(function(player, slotIndex)
        self:HandleClaimIncubation(player, slotIndex)
    end)
end

function CreatureService:ProcessEssenceTick()
    for _, player in ipairs(Players:GetPlayers()) do
        local profile = DataService:GetProfile(player)
        if not profile or not profile.Creatures then continue end

        local totalEssenceGenerated = 0

        for _, creature in pairs(profile.Creatures) do
            local cConfig = CreaturesData.Creatures[creature.SpeciesId]
            if not cConfig then continue end

            local rInfo = RaritiesData.Rarities[creature.Rarity]
            local rarityMult = if rInfo then rInfo.Multiplier else 1.0

            local mInfo = RaritiesData.Mutations[creature.Mutation]
            local mutMult = if mInfo then mInfo.Multiplier else 1.0

            local happinessFactor = math.clamp(creature.Happiness / 100, 0.5, 1.5)
            local levelMult = 1 + (creature.Level - 1) * 0.1

            local produced = cConfig.BaseEssenceRate * rarityMult * mutMult * happinessFactor * levelMult
            totalEssenceGenerated += produced

            -- Slight natural happiness decay (-0.5 per tick)
            creature.Happiness = math.max(10, creature.Happiness - 0.5)
        end

        if totalEssenceGenerated > 0 then
            local rounded = math.round(totalEssenceGenerated)
            EconomyService:AddCurrency(player, "Essence", rounded)

            local harvestRemote = NetworkUtil.getRemoteEvent("CreatureHarvested")
            harvestRemote:FireClient(player, rounded)
        end
    end
end

function CreatureService:HandleFeed(player: Player, creatureGuid: string)
    local profile = DataService:GetProfile(player)
    if not profile or not profile.Creatures[creatureGuid] then return end

    -- Restores 25 happiness
    DataService:UpdateProfile(player, function(prof)
        local creature = prof.Creatures[creatureGuid]
        creature.Happiness = math.min(100, creature.Happiness + 25)
    end)
end

function CreatureService:HandlePet(player: Player, creatureGuid: string)
    local profile = DataService:GetProfile(player)
    if not profile or not profile.Creatures[creatureGuid] then return end

    -- Restores 10 happiness and grants a tiny essence drop
    DataService:UpdateProfile(player, function(prof)
        local creature = prof.Creatures[creatureGuid]
        creature.Happiness = math.min(100, creature.Happiness + 10)
    end)
    EconomyService:AddCurrency(player, "Essence", 5)
end

function CreatureService:CalculateOffspring(speciesA: string, speciesB: string): (string, string, string)
    -- Check specific recipe
    for _, recipe in ipairs(CreaturesData.HybridRecipes) do
        if (recipe.ParentA == speciesA and recipe.ParentB == speciesB) or
           (recipe.ParentA == speciesB and recipe.ParentB == speciesA) then
            local offspringConfig = CreaturesData.Creatures[recipe.OffspringId]
            local rarity = if offspringConfig then offspringConfig.BaseRarity else "Rare"
            local mutation = self:RollMutation()
            return recipe.OffspringId, rarity, mutation
        end
    end

    -- Genetic elemental fusion fallback
    local offspringId = if math.random() > 0.5 then speciesA else speciesB

    -- Rarity roll
    local rolledRarity = MathUtil.weightedRoll(RaritiesData.Rarities) or "Common"
    local rolledMutation = self:RollMutation()

    return offspringId, rolledRarity, rolledMutation
end

function CreatureService:RollMutation(): string
    local roll = math.random()
    if roll < 0.01 then
        return "Cosmic"
    elseif roll < 0.03 then
        return "Neon"
    elseif roll < 0.08 then
        return "Shiny"
    else
        return "Standard"
    end
end

function CreatureService:HandleStartIncubation(player: Player, parentAGuid: string, parentBGuid: string)
    local profile = DataService:GetProfile(player)
    if not profile then return end

    local parentA = profile.Creatures[parentAGuid]
    local parentB = profile.Creatures[parentBGuid]
    if not parentA or not parentB then return end

    if #profile.Incubations >= GameConfig.HYBRIDIZATION.MAX_INCUBATION_SLOTS then
        return
    end

    local offspringSpecies, offspringRarity, offspringMutation = self:CalculateOffspring(
        parentA.SpeciesId,
        parentB.SpeciesId
    )

    local incubationData: DataService.IncubationData = {
        SlotIndex = #profile.Incubations + 1,
        OffspringSpecies = offspringSpecies,
        OffspringRarity = offspringRarity,
        OffspringMutation = offspringMutation,
        StartTime = os.time(),
        Duration = GameConfig.HYBRIDIZATION.BASE_INCUBATION_TIME,
    }

    DataService:UpdateProfile(player, function(prof)
        table.insert(prof.Incubations, incubationData)
    end)
end

function CreatureService:HandleClaimIncubation(player: Player, slotIndex: number)
    local profile = DataService:GetProfile(player)
    if not profile or not profile.Incubations[slotIndex] then return end

    local inc = profile.Incubations[slotIndex]
    local elapsed = os.time() - inc.StartTime
    if elapsed < inc.Duration then
        return -- Not hatched yet!
    end

    local newGuid = HttpService:GenerateGUID(false)
    local newCreature: DataService.CreatureInstanceData = {
        Guid = newGuid,
        SpeciesId = inc.OffspringSpecies,
        Rarity = inc.OffspringRarity,
        Mutation = inc.OffspringMutation,
        Happiness = 100,
        Level = 1,
        HabitatGuid = nil,
    }

    DataService:UpdateProfile(player, function(prof)
        prof.Creatures[newGuid] = newCreature
        table.remove(prof.Incubations, slotIndex)
    end)

    -- Notify client
    local spawnRemote = NetworkUtil.getRemoteEvent("CreatureSpawned")
    spawnRemote:FireClient(player, newCreature)
end

return CreatureService
