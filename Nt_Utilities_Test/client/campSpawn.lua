local campPeds = {}
local usedGuardCoords = {}

local function getRandomModel(modelList)
    local models = configCampSpawn.Models[modelList]
    return models[math.random(#models)].hash
end

local function getRandomWeapon(weaponList)
    local weapons = configCampSpawn.WeaponLists[weaponList]
    return weapons[math.random(#weapons)]
end

local function spawnBoss(campName)
    local camp = configCampSpawn.Camps[campName]
    local bossConfig = camp.Boss
    local spawnCoord = bossConfig.Spawns[math.random(#bossConfig.Spawns)]

    local args = exports['Nt_Utilities']:SpawnCombatNPC({
        Model = getRandomModel(bossConfig.BossModels),
        Coords = spawnCoord,
        networked = true,
        DmgModifier = configCampSpawn.Settings.DamageModifier,
    })
    Wait(100)
    local ped = args.ped

    local pedGroupHash = GetHashKey(bossConfig.BossGroup)
    SetPedRelationshipGroupHash(ped, pedGroupHash)
    local giveSidearm = getRandomWeapon(bossConfig.Sidearms)
    local giveLongarm = getRandomWeapon(bossConfig.Longarms)
    exports['Nt_Utilities']:giveWeaponToNPC(ped, 'Sidearm', giveSidearm, false)
    exports['Nt_Utilities']:giveWeaponToNPC(ped, 'Longarm', giveLongarm, false)

    exports['Nt_Utilities']:InitializeCombatAI(
        ped,
        configCampSpawn.Settings.SightRange,
        configCampSpawn.Settings.HearingRange,
        configCampSpawn.Settings.CombatRange,
        configCampSpawn.Settings.ScanInterval,
        pedGroupHash,
        "ambient"
    )

    table.insert(campPeds, ped)
end

local function spawnUnderlings(campName)
    local camp = configCampSpawn.Camps[campName]
    local underlingConfig = camp.Underlings
    local allSpawns = {}

    for i = 1, #underlingConfig.Spawns.Guard do
        table.insert(allSpawns, { coord = underlingConfig.Spawns.Guard[i], action = "guard" })
    end
    for i = 1, #underlingConfig.Spawns.Ambient do
        table.insert(allSpawns, { coord = underlingConfig.Spawns.Ambient[i], action = "ambient" })
    end

    for i = 1, camp.MaxAlive do
        local availableSpawns = {}
        for _, spawnData in ipairs(allSpawns) do
            if spawnData.action == "ambient" or not usedGuardCoords[spawnData.coord] then
                table.insert(availableSpawns, spawnData)
            end
        end

        if #availableSpawns == 0 then break end

        local spawnData = availableSpawns[math.random(#availableSpawns)]

        local args = exports['Nt_Utilities']:SpawnCombatNPC({
            Model = getRandomModel(underlingConfig.UnderlingModels),
            Coords = spawnData.coord,
            networked = true,
            DmgModifier = configCampSpawn.Settings.DamageModifier,
        })
        Wait(100)
        local ped = args.ped

        local pedGroupHash = GetHashKey(underlingConfig.UnderlingGroup)
        SetPedRelationshipGroupHash(ped, pedGroupHash)
        local giveSidearm = getRandomWeapon(underlingConfig.Sidearms)
        local giveLongarm = getRandomWeapon(underlingConfig.Longarms)
        exports['Nt_Utilities']:giveWeaponToNPC(ped, 'Sidearm', giveSidearm, false)
        exports['Nt_Utilities']:giveWeaponToNPC(ped, 'Longarm', giveLongarm, false)

        exports['Nt_Utilities']:InitializeCombatAI(
            ped,
            configCampSpawn.Settings.SightRange,
            configCampSpawn.Settings.HearingRange,
            configCampSpawn.Settings.CombatRange,
            configCampSpawn.Settings.ScanInterval,
            pedGroupHash,
            spawnData.action
        )

        if spawnData.action == "guard" then
            usedGuardCoords[spawnData.coord] = true
        end

        table.insert(campPeds, ped)
    end
end

local function cleanupCamp()
    for _, ped in ipairs(campPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    campPeds = {}
    usedGuardCoords = {}
end

RegisterCommand('SpawnCamp', function(source, args, rawCommand)
    local campName = args[1] or "Fort_Brennand"
    
    if not configCampSpawn.Camps[campName] then
        return
    end

    cleanupCamp()
    spawnBoss(campName)
    spawnUnderlings(campName)
end, false)

RegisterCommand('DespawnCamp', function(source, args, rawCommand)
    cleanupCamp()
end, false)
