





--[[
local npcArgs = exports['Nt_Utilities']:SpawnCombatNPC({
    Model = 'a_c_deer_01', -- NPC Model to spawn
    Coords = vector4(0.0, 0.0, 0.0, 0.0), -- Coordinates to spawn at
    networked = true, -- Whether the NPC should be networked or not
    outfit = nil,
    DmgModifier = 1.0, -- Must have .0 on the end
    })
Returns Ped, NetID
--]]
exports('SpawnCombatNPC', function(args)
    
    local modelHash = GetHashKey(args.Model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    local npc = Citizen.InvokeNative(0xD49F9B0955C367DE, modelHash, args.Coords, args.networked, false, false, false) -- CreatePed_2

     if not DoesEntityExist(npc) then
        SetModelAsNoLongerNeeded(modelHash)
        return nil, nil
    end

    local newArgs = {
        ped = npc,
    }

    SetEntityAsMissionEntity(npc, true, true)

    -- Wait for entity to fully initialize
    Wait(50)


    -- Ensure entity is networked properly
    if args.networked then
        local networkTimeout = 0
        while not NetworkGetEntityIsNetworked(npc) and networkTimeout < 100 do
            NetworkRegisterEntityAsNetworked(npc)
            Wait(10)
            networkTimeout = networkTimeout + 1
        end
        local netId = NetworkGetNetworkIdFromEntity(npc)
        SetNetworkIdExistsOnAllMachines(netId, true)
        newArgs.netId = netId
    end

    -- setup outfit.
    if args.outfit ~= nil then
        EquipMetaPedOutfitPreset(npc, args.outfit, true)
    else
        SetRandomOutfitVariation(npc, true)
    end

    SetPedCombatAttributes(npc, 0, true) -- Can use cover
    SetPedCombatAttributes(npc, 1, true) -- Can use vehicles
    SetPedCombatAttributes(npc, 2, true) -- Can do drivebys
    SetPedCombatAttributes(npc, 3, true) -- Can leave vehicle
    SetPedCombatAttributes(npc, 16, true) -- bullet strafe
    SetPedCombatAttributes(npc, 12, true) -- cover blind fire
    SetPedCombatAttributes(npc, 58, true) -- disable flee from combat
    SetPedCombatAttributes(npc, 24, true) -- proximity fire rate
    SetPedCombatAttributes(npc, 42, true) -- can flank
    SetPedCombatAttributes(npc, 50, true) -- can charge
    SetPedCombatAttributes(npc, 91, true) -- Use range based weapon selection
    SetPedCombatAttributes(npc, 114, true) -- can execute target
    SetPedCombatRange(ped, 2)
    --Citizen.InvokeNative(0x05CE6AF4DF071D23, npc, 2) -- ladder speed modifier, seems to fix melee speed issue.
    Citizen.InvokeNative(0xD77AE48611B7B10A, npc, args.DmgModifier) 

    return newArgs

end)

-- Spawns random horse beside npc and makes npc mount it.
--[[
local horse = exports['Nt_Utilities']:GiveNPCHorse(npc)
--]]
exports('GiveNPCHorse', function(npc)

        local horseModels = {
            "A_C_Horse_AmericanPaint_Greyovero",
            "A_C_Horse_AmericanStandardbred_Black",
            "A_C_Horse_Morgan_Bay",
            "A_C_Horse_TennesseeWalker_BlackRabicano",
            "A_C_Horse_KentuckySaddle_Grey"
        }
        -- Set flag to allow NPC to use mounts
        Citizen.InvokeNative(0x1913FE4CBF41C463, npc, 24, true) -- _SET_PED_CONFIG_FLAG (24 = can mount)
        Citizen.InvokeNative(0x1913FE4CBF41C463, npc, 297, true) -- _SET_PED_CONFIG_FLAG (297 = can use horse)
        Citizen.InvokeNative(0x1913FE4CBF41C463, npc, 223, true) -- _SET_PED_CONFIG_FLAG (223 = can flee on mount)
        Citizen.InvokeNative(0x1913FE4CBF41C463, npc, 251, true) -- _SET_PED_CONFIG_FLAG (251 = can use vehicles)

        local horseModel = horseModels[math.random(1, #horseModels)]
        local modelHash = GetHashKey(horseModel)
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end

        if not HasModelLoaded(modelHash) then
        if Config.Debug then
            print("[Ambush] Failed to load horse model: " .. horseModel)
        end
        return nil
        end

        -- Create the horse slightly offset from the NPC
        local offsetX = math.random(-3, 3)
        local offsetY = math.random(-3, 3)
        local spawnCoords = GetOffsetFromEntityInWorldCoords(npc, offsetX, offsetY, 0.0)
        local horse = CreatePed(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, false, false, false)
    
        if not DoesEntityExist(horse) then
            SetModelAsNoLongerNeeded(modelHash)
            return nil
        end

        SetEntityAsMissionEntity(horse, true, true)

        -- Configure the horse
        Citizen.InvokeNative(0x283978A15512B2FE, horse, true) -- _SET_RANDOM_OUTFIT_VARIATION
        -- Add a saddle to the horse
        Citizen.InvokeNative(0xD3A7B003ED343FD9, horse, 0x20359E53, true, true, true) -- _APPLY_SHOP_ITEM_TO_PED (saddle)
        -- Make the NPC mount the horse
        Citizen.InvokeNative(0x028F76B6E78246EB, npc, horse, -1, true) -- SET_PED_ON_MOUNT
    

        return horse

end)


--[[
    exports['Nt_Utilities']:giveWeaponToNPC(npc, slotName, weaponName, random true/false)
--]]
exports('giveWeaponToNPC', function(npc, slot, weaponName, random)

    local sidearmList = {
        "WEAPON_REVOLVER_CATTLEMAN",
        "WEAPON_REVOLVER_DOUBLEACTION",
        "WEAPON_REVOLVER_SCHOFIELD",
        "WEAPON_PISTOL_SEMIAUTO",
        "WEAPON_PISTOL_MAUSER",
    }
    local longarmList = {
        "WEAPON_SNIPERRIFLE_CARCANO",
        "WEAPON_REPEATER_HENRY",
        "WEAPON_REPEATER_CARBINE",
        "WEAPON_REPEATER_WINCHESTER",
        "WEAPON_SHOTGUN_REPEATING",
        "WEAPON_SHOTGUN_SEMIAUTO",
        "WEAPON_RIFLE_BOLTACTION",
        "WEAPON_SHOTGUN_DOUBLEBARREL",
        "WEAPON_SHOTGUN_PUMP",
        "WEAPON_BOW",
    }
    local meleeList = {
        "WEAPON_MELEE_KNIFE",
        "WEAPON_MELEE_MACHETE",
    }

    -- Give melee weapon (check chance)
    if slot == "Melee" then
        local melee = weaponName or meleeList[math.random(1, #meleeList)]
        local weaponCondition = math.random(25,75)/100
        local weaponHash = type(melee) == "string" and GetHashKey(melee) or melee
        GiveWeaponToPed(npc, weaponHash, 1, true, false)
    end
    
    -- Give sidearm (check chance)
    if slot == "Sidearm" then
        local melee = weaponName or sidearmList[math.random(1, #sidearmList)]
        local weaponCondition = math.random(25,75)/100
        local weaponHash = type(melee) == "string" and GetHashKey(melee) or melee
        GiveWeaponToPed(npc, weaponHash, 1, true, true)
    end
    
    -- Give longarm (check chance)
    if slot == "Longarm" then
        local melee = weaponName or longarmList[math.random(1, #longarmList)]
        local weaponCondition = math.random(25,75)/100
        local weaponHash = type(melee) == "string" and GetHashKey(melee) or melee
        GiveWeaponToPed(npc, weaponHash, 1, true, false)
    end
    
end)