ConfigFriendlyNPC = {}

ConfigFriendlyNPC.NPCSettings = {
    spawnDistance = 20,
    stayDistance = 12.0,           -- while within this, random scenario swaps are active
    scenarioSwapInterval  = math.random(30, 120),-- random range (seconds) between optional scenario changes
    scenarioRadius = 2.0,          -- radius for nearest scenario search if used by client
}

ConfigFriendlyNPC.NPCs = {
    ["Butcher_Valentine"] ={
        model = 'U_M_M_VALBUTCHER_01',
        coords = vector4(-339.26, 767.7, 116.57, 103.16),
        scenario = "Table",
        scenarioCoords = false,
    },
    ["Valentine_Sheriff"] ={
        model = 'cs_valsheriff',
        coords = vector4(-277.0944, 804.0055, 119.3801, 328.9383),
        scenario = "Sit",
        scenarioCoords = vector4(-277.687958, 804.210876, 118.881432, 307.23),
    },
}



ConfigFriendlyNPC.Scenarios = {
        ["General"] = {
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_STAND_WAITING",
            "WORLD_HUMAN_STAND_WAITING",
            "WORLD_HUMAN_STAND_WAITING",
            "WORLD_HUMAN_SMOKE_INTERACTION",
            "WORLD_HUMAN_DRINK_FLASK",
        },
        ["Table"] = {
            "WORLD_HUMAN_CLEAN_TABLE",
            "WORLD_HUMAN_CLEAN_TABLE",
            "WORLD_HUMAN_CLEAN_TABLE",
            "WORLD_HUMAN_CLEAN_TABLE",
            "WORLD_HUMAN_CLIPBOARD",
            "WORLD_HUMAN_STAND_WAITING",
            "WORLD_HUMAN_COFFEE_DRINK",
            "WORLD_HUMAN_DRINK_FLASK",

        },
        ["AmbientGeneral"] = {
            "WORLD_HUMAN_STAND_WAITING",
            "WORLD_HUMAN_COFFEE_DRINK",
            "WORLD_HUMAN_SMOKE_INTERACTION",
            "WORLD_HUMAN_SMOKE_INTERACTION",
            "WORLD_HUMAN_WRITE_NOTEBOOK",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_SHOP_BROWSE_COUNTER",
            "WORLD_HUMAN_DRINKING_INTERACTION",
            "WORLD_HUMAN_DRINKING_INTERACTION",
            "WORLD_HUMAN_DRINKING_INTERACTION",
            "WORLD_HUMAN_DRINK_FLASK",
            "WORLD_HUMAN_DRINK_FLASK",
            "Ambient",
            "Ambient",
            "Ambient",
            "Ambient", -- not a real scenario
        },
        ["Sit"] = {
            "PROP_HUMAN_SEAT_CHAIR",
        }
}
