local cachedEnemyPed = nil

local function SpawnEnemyNPC(coords)
    if cachedEnemyPed and DoesEntityExist(cachedEnemyPed) then
        StopCombatAI(cachedEnemyPed)
        DeleteEntity(cachedEnemyPed)
    end

    local args = exports['Nt_Utilities']:SpawnCombatNPC({
        Model = ConfigEnemySpawn.Settings.Model,
        Coords = coords,
        networked = true,
        DmgModifier = ConfigEnemySpawn.Settings.DamageModifier,
    })
    Wait(100)
    local ped = args.ped

    cachedEnemyPed = ped
    local pedGroupHash = GetHashKey(ConfigEnemySpawn.Settings.Group)
    SetPedRelationshipGroupHash(ped, pedGroupHash)
    exports['Nt_Utilities']:giveWeaponToNPC(ped, 'Sidearm', ConfigEnemySpawn.Settings.Sidearm, true)

    TaskCombatHatedTargets(ped)
end


RegisterCommand('SpawnEnemy', function(source, args, rawCommand)
    local coordsStr = table.concat(args, ' ')
    local success, coords = pcall(load, 'return ' .. coordsStr)
    if success then
        SpawnEnemyNPC(coords())
    end
end, false)
