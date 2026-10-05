--!strict
--[[
    BuildingsData.luau
    Catalog of all structures placeable on the sanctuary grid:
    Habitats, Conveyors, Automation Harvesters, Incubators, and Tourism facilities.
]]

export type BuildingCategory = "Habitat" | "Automation" | "Facility" | "Decoration"

export type BuildingConfig = {
    Id: string,
    DisplayName: string,
    Category: BuildingCategory,
    GridSize: Vector2,        -- Dimensions in grid units (e.g. 2x2 = 8x8 studs)
    CostCurrency: string,     -- "Essence" or "Crystals"
    CostAmount: number,
    MaxCapacity: number?,     -- For habitats: max creatures
    Description: string,
    LevelRequired: number,
    ModelName: string,
}

local Buildings: { [string]: BuildingConfig } = {
    -- HABITATS
    Meadow_Enclosure = {
        Id = "Meadow_Enclosure",
        DisplayName = "Enclos Prairie Fleurie",
        Category = "Habitat",
        GridSize = Vector2.new(4, 4),
        CostCurrency = "Essence",
        CostAmount = 50,
        MaxCapacity = 3,
        Description = "Un habitat doux et verdoyant pour les créatures de type Plante et Terre.",
        LevelRequired = 1,
        ModelName = "Habitat_Meadow",
    },
    Lagoon_Enclosure = {
        Id = "Lagoon_Enclosure",
        DisplayName = "Lagon de Cristal",
        Category = "Habitat",
        GridSize = Vector2.new(4, 4),
        CostCurrency = "Essence",
        CostAmount = 250,
        MaxCapacity = 3,
        Description = "Bassin d'eau claire et fraîche pour les espèces aquatiques.",
        LevelRequired = 2,
        ModelName = "Habitat_Lagoon",
    },
    Sky_Enclosure = {
        Id = "Sky_Enclosure",
        DisplayName = "Perchoir des Brises",
        Category = "Habitat",
        GridSize = Vector2.new(4, 4),
        CostCurrency = "Essence",
        CostAmount = 750,
        MaxCapacity = 4,
        Description = "Plateforme aérienne suspendue par des cristaux de lévitation.",
        LevelRequired = 3,
        ModelName = "Habitat_Sky",
    },
    Mystic_Enclosure = {
        Id = "Mystic_Enclosure",
        DisplayName = "Bosquet Mystique",
        Category = "Habitat",
        GridSize = Vector2.new(5, 5),
        CostCurrency = "Essence",
        CostAmount = 2500,
        MaxCapacity = 4,
        Description = "Arbres bioluminescents et brume magique pour espèces arcaniques.",
        LevelRequired = 4,
        ModelName = "Habitat_Mystic",
    },
    Celestial_Enclosure = {
        Id = "Celestial_Enclosure",
        DisplayName = "Sanctuaire Astral",
        Category = "Habitat",
        GridSize = Vector2.new(6, 6),
        CostCurrency = "Crystals",
        CostAmount = 150,
        MaxCapacity = 5,
        Description = "Le pinacle du sanctuaire, baigné dans l'énergie des comètes.",
        LevelRequired = 6,
        ModelName = "Habitat_Celestial",
    },

    -- AUTOMATION & CONVEYORS
    Conveyor_Belt = {
        Id = "Conveyor_Belt",
        DisplayName = "Tapis Roulant Féerique",
        Category = "Automation",
        GridSize = Vector2.new(1, 1),
        CostCurrency = "Essence",
        CostAmount = 10,
        Description = "Achemine automatiquement les orbes d'essence et les œufs pondus.",
        LevelRequired = 1,
        ModelName = "Belt_Straight",
    },
    Auto_Harvester = {
        Id = "Auto_Harvester",
        DisplayName = "Collecteur d'Essence Auto",
        Category = "Automation",
        GridSize = Vector2.new(2, 2),
        CostCurrency = "Essence",
        CostAmount = 120,
        Description = "Aspire l'essence produite dans les enclos voisins et la déverse sur le tapis.",
        LevelRequired = 2,
        ModelName = "Collector_Unit",
    },
    Hybrid_Incubator = {
        Id = "Hybrid_Incubator",
        DisplayName = "Incubateur d'Hybridation",
        Category = "Automation",
        GridSize = Vector2.new(3, 3),
        CostCurrency = "Essence",
        CostAmount = 400,
        Description = "Reçoit les essences de deux espèces, fusionne leurs gènes et fait éclore un œuf rare !",
        LevelRequired = 2,
        ModelName = "Incubator_Core",
    },
    Wisp_Cottage = {
        Id = "Wisp_Cottage",
        DisplayName = "Cabane du Gardien Follet",
        Category = "Automation",
        GridSize = Vector2.new(3, 3),
        CostCurrency = "Essence",
        CostAmount = 800,
        Description = "Invoque un petit ouvrier PNJ qui nourrit les créatures et augmente leur bonheur.",
        LevelRequired = 3,
        ModelName = "Wisp_Hut",
    },
    Central_Vault = {
        Id = "Central_Vault",
        DisplayName = "Coffre d'Éther Central",
        Category = "Automation",
        GridSize = Vector2.new(3, 3),
        CostCurrency = "Essence",
        CostAmount = 0, -- Placed by default at plot generation
        Description = "Point d'arrivée des convoyeurs. Convertit l'essence recueillie en solde joueur.",
        LevelRequired = 1,
        ModelName = "Vault_Structure",
    },

    -- TOURISM & PRESTIGE FACILITIES
    Ticket_Booth = {
        Id = "Ticket_Booth",
        DisplayName = "Guichet de Billetterie",
        Category = "Facility",
        GridSize = Vector2.new(2, 2),
        CostCurrency = "Essence",
        CostAmount = 150,
        Description = "Permet aux touristes et aux autres joueurs de payer leur entrée dans le parc.",
        LevelRequired = 1,
        ModelName = "Booth_Gate",
    },
    Souvenir_Stand = {
        Id = "Souvenir_Stand",
        DisplayName = "Kiosque de Souvenirs",
        Category = "Facility",
        GridSize = Vector2.new(2, 2),
        CostCurrency = "Essence",
        CostAmount = 600,
        Description = "Les touristes y achètent des peluches de vos créatures, rapportant des bonus de prestige.",
        LevelRequired = 3,
        ModelName = "Shop_Souvenir",
    },
    Starlight_Fountain = {
        Id = "Starlight_Fountain",
        DisplayName = "Fontaine Stellaire",
        Category = "Decoration",
        GridSize = Vector2.new(3, 3),
        CostCurrency = "Crystals",
        CostAmount = 30,
        Description = "Attire +25% de visiteurs PNJ et augmente la note globale du parc.",
        LevelRequired = 2,
        ModelName = "Deco_Fountain",
    },
}

return Buildings
