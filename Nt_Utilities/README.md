# Nt_Utilities

## Available Exports

### SpawnCombatNPC
Spawns a combat-enabled NPC with AI capabilities.
```lua
local npcArgs = exports['Nt_Utilities']:SpawnCombatNPC({
    Model = 'a_c_deer_01', -- NPC Model to spawn
    Coords = vector4(0.0, 0.0, 0.0, 0.0), -- Coordinates to spawn at
    networked = true, -- Whether the NPC should be networked or not
    outfit = nil,
    DmgModifier = 1.0, -- Must have .0 on the end
    })
-- Returns Ped, NetID
```

### GiveNPCHorse
Spawns a random horse beside an NPC and makes the NPC mount it.
```lua
local horse = exports['Nt_Utilities']:GiveNPCHorse(npc)
```

### giveWeaponToNPC
Gives a weapon to an NPC in a specified slot.
```lua
exports['Nt_Utilities']:giveWeaponToNPC(npc, slotName, weaponName, random)
-- slotName options: "Melee", "Sidearm", "Longarm"
-- random: true/false
```

### CreateBlip
Creates a blip on the map for a ped or at coordinates.
```lua
local blip = exports['Nt_Utilities']:CreateBlip(ped/coords, blipSprite, blipColor, blipScale, blipName)
```

### SpawnFriendlyNPC
Spawns a friendly NPC that cannot be damaged.
None networked.
```lua
local ped = exports['Nt_Utilities']:SpawnFriendlyNPC(model, coords)
```

### ScanForPlayersInRadius
Scans for players within a specified radius from given coordinates and returns their IDs.
```lua
local playerList = exports['Nt_Utilities']:ScanForPlayersInRadius(Coords, Radius)
```

### InitializeCombatAI
Initializes combat AI for an NPC with threat scanning and combat management.
```lua
exports['Nt_Utilities']:InitializeCombatAI(
    ped,                                    -- The NPC entity
    sightRange,                             -- How far the NPC can see (in units)
    hearingRange,                           -- How far the NPC can hear (in units)
    combatRange,                            -- Range for combat engagement (in units)
    scanInterval,                           -- Interval for scanning (in milliseconds)
    pedGroupHash,                           -- Enemy group hash to set NPC to
    pedAction                               -- Initial action ("ambient" or "guard")
)
```