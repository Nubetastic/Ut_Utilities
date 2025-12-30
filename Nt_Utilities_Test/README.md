# Nt_Utilities_Test

## Commands

1. **`/SpawnCamp`**
   - Spawns a camp with a boss and underlings
   - Optional argument: camp name (default: "Fort_Brennand")
   - Usage: `/SpawnCamp [campName]` or `/SpawnCamp`

2. **`/DespawnCamp`**
   - Despawns all NPCs in the active camp
   - Usage: `/DespawnCamp`

3. **`/SpawnEnemy`**
   - Spawns a single enemy NPC at specified coordinates
   - Argument: coordinates as a Lua table string
   - Usage: `/SpawnEnemy vector4(x, y, z, w)`
   - Suggest using bs-coords to get vector4 easily. https://github.com/Blaze-Scripts/bs-coords

4. **`/FriendlyNPC`**
   - Starts the distance-based friendly NPC manager
   - Spawns/despawns NPCs based on player proximity
   - Usage: `/FriendlyNPC`
