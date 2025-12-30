

--[[
local ped = exports['Nt_Utilities']:SpawnFriendlyNPC(model, coords)
--]]
exports('SpawnFriendlyNPC', function(Model, Coords)
    
    local modelHash = GetHashKey(Model)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    local heading = Coords.w or 0.0

    local ped = Citizen.InvokeNative(0xD49F9B0955C367DE, modelHash, Coords.x, Coords.y, Coords.z - 1, heading, false, false, false, false)

    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetEntityCanBeDamaged(ped, false)
    SetEntityInvincible(ped, true)
    SetRandomOutfitVariation(ped, true)

    return ped

end)