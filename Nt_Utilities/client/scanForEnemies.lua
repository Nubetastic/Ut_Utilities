-- setup for Nt_Law
CreateThread(function()
    AddRelationshipGroup("Nt_Enemy", GetHashKey("Nt_Enemy"))
    AddRelationshipGroup("Nt_Enemy_NoBlip", GetHashKey("Nt_Enemy_NoBlip"))
    AddRelationshipGroup("Nt_Enemy_Hideout", GetHashKey("Nt_Enemy_Hideout"))
    AddRelationshipGroup("Nt_Enemy_Bounty", GetHashKey("Nt_Enemy_Bounty"))
    AddRelationshipGroup("Nt_Ally", GetHashKey("Nt_Ally"))

    local enemyGroups = {
        GetHashKey("Nt_Enemy"),
        GetHashKey("Nt_Enemy_NoBlip"),
        GetHashKey("Nt_Enemy_Hideout"),
        GetHashKey("Nt_Enemy_Bounty")
    }
    local allyGroup = GetHashKey("Nt_Ally")
    local playerGroup = GetHashKey("PLAYER")

    for i = 1, #enemyGroups do
        for j = i + 1, #enemyGroups do
            SetRelationshipBetweenGroups(1, enemyGroups[i], enemyGroups[j])
            SetRelationshipBetweenGroups(1, enemyGroups[j], enemyGroups[i])
        end
        SetRelationshipBetweenGroups(5, enemyGroups[i], playerGroup)
        SetRelationshipBetweenGroups(5, playerGroup, enemyGroups[i])
        SetRelationshipBetweenGroups(5, enemyGroups[i], allyGroup)
        SetRelationshipBetweenGroups(5, allyGroup, enemyGroups[i])
    end

    SetRelationshipBetweenGroups(1, allyGroup, playerGroup)
    SetRelationshipBetweenGroups(1, playerGroup, allyGroup)
end)




local scanSettings = Config.ScanForEnemies.Settings or {}
local scanRadius = scanSettings.scanRadius or 200.0
local scanInterval = scanSettings.scanInterval or 500
local cacheDistance = scanSettings.cacheDistance or scanRadius
local defaultBlipDespawn = scanSettings.blipDespawn or 0

local groupConfigs = {}
for groupName, data in pairs(Config.ScanForEnemies) do
    if groupName ~= 'Settings' and data.blip then
        groupConfigs[GetHashKey(groupName)] = data
    end
end

local pedBlips = {}

local function removeCachedPed(ped)
    local cached = pedBlips[ped]
    if not cached then
        return
    end
    if cached.blip and DoesBlipExist(cached.blip) then
        RemoveBlip(cached.blip)
    end
    pedBlips[ped] = nil
end

local function attachBlip(ped, data)
    local spawnDistance = data.distance or cacheDistance
    local despawnDistance = spawnDistance + (data.blipDespawn or defaultBlipDespawn)
    local blip = exports['Nt_Utilities']:CreateBlip(ped, data.Sprite, data.Color, data.Scale, data.name)
    if not blip then
        return
    end
    if data.offRadar then
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, GetHashKey('BLIP_MODIFIER_RADAR_EDGE_ALWAYS'))
    end
    pedBlips[ped] = {
        blip = blip,
        distance = spawnDistance,
        spawnDistance = spawnDistance,
        despawnDistance = despawnDistance
    }
end

CreateThread(function()
    while true do
        Wait(scanInterval)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for ped, info in pairs(pedBlips) do
            if not DoesEntityExist(ped) or IsEntityDead(ped) then
                removeCachedPed(ped)
            else
                local pedCoords = GetEntityCoords(ped)
                local maxDistance = info.despawnDistance or info.distance or cacheDistance
                if #(pedCoords - playerCoords) > maxDistance then
                    removeCachedPed(ped)
                end
            end
        end

        local peds = GetGamePool('CPed')
        for i = 1, #peds do
            local ped = peds[i]
            if ped ~= playerPed and not IsPedAPlayer(ped) and not pedBlips[ped] and DoesEntityExist(ped) and not IsEntityDead(ped) then
                local pedCoords = GetEntityCoords(ped)
                local distanceToPed = #(pedCoords - playerCoords)
                if distanceToPed <= scanRadius then
                    local hash = GetPedRelationshipGroupHash(ped)
                    local groupData = groupConfigs[hash]
                    if groupData then
                        local spawnDistance = groupData.distance or cacheDistance
                        if distanceToPed <= spawnDistance then
                            attachBlip(ped, groupData)
                        end
                    end
                end
            end
        end
    end
end)
