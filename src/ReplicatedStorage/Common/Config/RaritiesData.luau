--!strict
--[[
    RaritiesData.luau
    Defines all rarity tiers, multipliers, visual color schemes, and mutation types.
]]

export type RarityInfo = {
    Name: string,
    Tier: number,
    Color: Color3,
    Multiplier: number,
    Weight: number,
    ParticleEffect: string?,
}

local RaritiesData: { [string]: RarityInfo } = {
    Common = {
        Name = "Common",
        Tier = 1,
        Color = Color3.fromRGB(180, 180, 180),
        Multiplier = 1.0,
        Weight = 600, -- 60%
        ParticleEffect = nil,
    },
    Uncommon = {
        Name = "Uncommon",
        Tier = 2,
        Color = Color3.fromRGB(85, 255, 127),
        Multiplier = 1.8,
        Weight = 250, -- 25%
        ParticleEffect = "Sparkles_Green",
    },
    Rare = {
        Name = "Rare",
        Tier = 3,
        Color = Color3.fromRGB(85, 170, 255),
        Multiplier = 3.5,
        Weight = 100, -- 10%
        ParticleEffect = "Sparkles_Blue",
    },
    Epic = {
        Name = "Epic",
        Tier = 4,
        Color = Color3.fromRGB(170, 85, 255),
        Multiplier = 7.0,
        Weight = 40, -- 4%
        ParticleEffect = "Glow_Purple",
    },
    Legendary = {
        Name = "Legendary",
        Tier = 5,
        Color = Color3.fromRGB(255, 170, 0),
        Multiplier = 15.0,
        Weight = 9, -- 0.9%
        ParticleEffect = "Crown_Gold",
    },
    Mythic = {
        Name = "Mythic",
        Tier = 6,
        Color = Color3.fromRGB(255, 60, 120),
        Multiplier = 35.0,
        Weight = 1, -- 0.1%
        ParticleEffect = "Aura_Rainbow",
    },
    Divine = {
        Name = "Divine",
        Tier = 7,
        Color = Color3.fromRGB(255, 255, 255),
        Multiplier = 100.0,
        Weight = 0, -- Obtained exclusively through advanced multi-stage hybridization
        ParticleEffect = "Halo_Starlight",
    },
}

-- Special Cosmetic / Genotype Mutations
local MutationTypes = {
    Standard = { Name = "Standard", Multiplier = 1.0, Glow = false },
    Shiny = { Name = "Shiny", Multiplier = 1.5, Glow = true, ColorTint = Color3.fromRGB(255, 235, 150) },
    Neon = { Name = "Neon", Multiplier = 2.2, Glow = true, ColorTint = Color3.fromRGB(0, 255, 220) },
    Cosmic = { Name = "Cosmic", Multiplier = 3.5, Glow = true, ColorTint = Color3.fromRGB(140, 50, 255) },
}

return {
    Rarities = RaritiesData,
    Mutations = MutationTypes,
}
