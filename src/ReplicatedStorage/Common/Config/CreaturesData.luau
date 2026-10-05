--!strict
--[[
    CreaturesData.luau
    Registry of base species, elements, hybridization matrix, and production stats.
]]

export type ElementType = "Flora" | "Aqua" | "Pyro" | "Zephyr" | "Terra" | "Mystic" | "Astral"

export type CreatureConfig = {
    Id: string,
    DisplayName: string,
    Element: ElementType,
    BaseRarity: string,
    BaseEssenceRate: number,   -- Essence produced per pulse
    FavoriteFood: string,      -- Doubles happiness when fed
    HabitatRequired: string,   -- Id of habitat type needed
    Description: string,
    Icon: string?,
}

export type HybridRecipe = {
    ParentA: string,
    ParentB: string,
    OffspringId: string,
    RarityBonus: number,
}

local Creatures: { [string]: CreatureConfig } = {
    -- Tier 1: Meadow & Flora Creatures
    Fluffbun = {
        Id = "Fluffbun",
        DisplayName = "Lapin de Mousse",
        Element = "Flora",
        BaseRarity = "Common",
        BaseEssenceRate = 2,
        FavoriteFood = "Berry_Clover",
        HabitatRequired = "Meadow_Enclosure",
        Description = "Une petite boule de poils végétale très câline qui fait fleurir le sol.",
    },
    Sproutling = {
        Id = "Sproutling",
        DisplayName = "Pousse Étoilée",
        Element = "Flora",
        BaseRarity = "Common",
        BaseEssenceRate = 3,
        FavoriteFood = "Sun_Dew",
        HabitatRequired = "Meadow_Enclosure",
        Description = "Un esprit végétal curieux dont la petite feuille frétille de joie.",
    },

    -- Tier 1: Water & Stream Creatures
    Dropletto = {
        Id = "Dropletto",
        DisplayName = "Loutre d'Écume",
        Element = "Aqua",
        BaseRarity = "Uncommon",
        BaseEssenceRate = 5,
        FavoriteFood = "Glow_Fish",
        HabitatRequired = "Lagoon_Enclosure",
        Description = "Joueuse et vive, elle crée de petites bulles enchantées en nageant.",
    },
    Shellby = {
        Id = "Shellby",
        DisplayName = "Tortue Coralline",
        Element = "Terra",
        BaseRarity = "Uncommon",
        BaseEssenceRate = 6,
        FavoriteFood = "Kelp_Bite",
        HabitatRequired = "Lagoon_Enclosure",
        Description = "Sa carapace abrite un mini-écosystème de coraux scintillants.",
    },

    -- Tier 2: Mystic & Wind Creatures
    Whisperwing = {
        Id = "Whisperwing",
        DisplayName = "Félin Éolien",
        Element = "Zephyr",
        BaseRarity = "Rare",
        BaseEssenceRate = 12,
        FavoriteFood = "Cloud_Sugar",
        HabitatRequired = "Sky_Enclosure",
        Description = "Un félin aux ailes duveteuses qui glisse gracieusement sur les courants d'air.",
    },
    Glimmerfox = {
        Id = "Glimmerfox",
        DisplayName = "Renard Astral",
        Element = "Mystic",
        BaseRarity = "Epic",
        BaseEssenceRate = 25,
        FavoriteFood = "Star_Fruit",
        HabitatRequired = "Mystic_Enclosure",
        Description = "Ses queues laissent une traînée de poussière d'étoiles qui captive les visiteurs.",
    },

    -- Tier 3: Flame & High Tier Hybrids
    Pyrodrake = {
        Id = "Pyrodrake",
        DisplayName = "Draconet Flamboyant",
        Element = "Pyro",
        BaseRarity = "Epic",
        BaseEssenceRate = 30,
        FavoriteFood = "Magma_Pepper",
        HabitatRequired = "Volcanic_Enclosure",
        Description = "Crache de petites flammes multicolores inoffensives et réconfortantes.",
    },

    -- Hybrid Discoveries (Craftable via Incubator)
    Bloomwyrm = {
        Id = "Bloomwyrm",
        DisplayName = "Wyrm Boréal",
        Element = "Flora",
        BaseRarity = "Legendary",
        BaseEssenceRate = 65,
        FavoriteFood = "Star_Fruit",
        HabitatRequired = "Mystic_Enclosure",
        Description = "Hybride gracieux mêlant les pétales de rose et la prestance des dragons.",
    },
    Celestikitsune = {
        Id = "Celestikitsune",
        DisplayName = "Kitsune Céleste",
        Element = "Astral",
        BaseRarity = "Mythic",
        BaseEssenceRate = 160,
        FavoriteFood = "Solar_Essence",
        HabitatRequired = "Celestial_Enclosure",
        Description = "Créature légendaire aux 9 queues stellaires, phare d'harmonie du sanctuaire.",
    },
    Aetherbeast = {
        Id = "Aetherbeast",
        DisplayName = "Titan d'Éther",
        Element = "Astral",
        BaseRarity = "Divine",
        BaseEssenceRate = 500,
        FavoriteFood = "Ambrosia_Pearl",
        HabitatRequired = "Celestial_Enclosure",
        Description = "L'esprit originel du sanctuaire, rayonnant d'une pure aura divine.",
    },
}

-- Special recipes for targeted hybridization in the Incubator
local HybridRecipes: { HybridRecipe } = {
    {
        ParentA = "Fluffbun",
        ParentB = "Dropletto",
        OffspringId = "Whisperwing",
        RarityBonus = 1.2,
    },
    {
        ParentA = "Sproutling",
        ParentB = "Pyrodrake",
        OffspringId = "Bloomwyrm",
        RarityBonus = 1.5,
    },
    {
        ParentA = "Glimmerfox",
        ParentB = "Bloomwyrm",
        OffspringId = "Celestikitsune",
        RarityBonus = 2.0,
    },
}

return {
    Creatures = Creatures,
    HybridRecipes = HybridRecipes,
}
