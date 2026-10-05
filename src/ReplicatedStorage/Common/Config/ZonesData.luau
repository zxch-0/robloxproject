--!strict
--[[
    ZonesData.luau
    Progressive tiered biomes to expand the sanctuary.
]]

export type ZoneConfig = {
    Id: string,
    Name: string,
    Tier: number,
    UnlockCost: number,
    UnlockCurrency: string,
    Description: string,
    BonusMultiplier: number,
    FeaturedSpecies: { string },
}

local ZonesData: { [string]: ZoneConfig } = {
    Meadow_Plains = {
        Id = "Meadow_Plains",
        Name = "Plaine des Brindilles",
        Tier = 1,
        UnlockCost = 0,
        UnlockCurrency = "Essence",
        Description = "La zone de départ verdoyante et paisible, berceau des premiers esprits féeriques.",
        BonusMultiplier = 1.0,
        FeaturedSpecies = { "Fluffbun", "Sproutling" },
    },
    Whispering_Cove = {
        Id = "Whispering_Cove",
        Name = "Crique des Murmures",
        Tier = 2,
        UnlockCost = 1500,
        UnlockCurrency = "Essence",
        Description = "Rivières cristallines et étangs scintillants peuplés de créatures aquatiques.",
        BonusMultiplier = 1.5,
        FeaturedSpecies = { "Dropletto", "Shellby" },
    },
    Gale_Plateau = {
        Id = "Gale_Plateau",
        Name = "Plateau des Vents Célestes",
        Tier = 3,
        UnlockCost = 10000,
        UnlockCurrency = "Essence",
        Description = "Cimes rocheuses entourées de nuages cotonneux et de créatures volantes agiles.",
        BonusMultiplier = 2.5,
        FeaturedSpecies = { "Whisperwing" },
    },
    Luminescent_Grove = {
        Id = "Luminescent_Grove",
        Name = "Bosquet Bioluminescent",
        Tier = 4,
        UnlockCost = 50000,
        UnlockCurrency = "Essence",
        Description = "Flore enchantée qui brille sous la nuit éternelle, repaire des esprits rares.",
        BonusMultiplier = 4.0,
        FeaturedSpecies = { "Glimmerfox", "Bloomwyrm" },
    },
    Celestial_Apex = {
        Id = "Celestial_Apex",
        Name = "Sommet Céleste",
        Tier = 5,
        UnlockCost = 250000,
        UnlockCurrency = "Essence",
        Description = "Flottant au-dessus des cieux, où convergent les auras mythiques et cosmiques.",
        BonusMultiplier = 8.0,
        FeaturedSpecies = { "Celestikitsune", "Aetherbeast" },
    },
}

return ZonesData
