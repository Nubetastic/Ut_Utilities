-- setup for relationship groups
CreateThread(function()
    local allRelationshipGroups = {}
    local groupToRelationships = {}
    
    for groupName, groupData in pairs(Config.ScanForEnemies) do
        if groupName ~= 'Settings' then
            groupToRelationships[groupName] = {}
            
            for relationshipName, relData in pairs(groupData) do
                if relationshipName ~= 'Settings' then
                    if not allRelationshipGroups[relationshipName] then
                        allRelationshipGroups[relationshipName] = true
                        if not relData.Native then
                            local hash = relData.isHash and tonumber(relationshipName) or GetHashKey(relationshipName)
                            AddRelationshipGroup(relationshipName, hash)
                        end
                    end
                    table.insert(groupToRelationships[groupName], relationshipName)
                end
            end
        end
    end
    
    for groupName, groupData in pairs(Config.ScanForEnemies) do
        if groupName ~= 'Settings' then
            local groupSettings = groupData.Settings or {}
            local enemyGroups = groupSettings.EnemyGroups or {}
            local myRelationships = groupToRelationships[groupName] or {}
            
            for _, myRelName in ipairs(myRelationships) do
                local myRelData = groupData[myRelName]
                local myHash = myRelData and myRelData.isHash and tonumber(myRelName) or GetHashKey(myRelName)
                
                for _, otherRelName in ipairs(myRelationships) do
                    if myRelName ~= otherRelName then
                        local otherRelData = groupData[otherRelName]
                        local otherHash = otherRelData and otherRelData.isHash and tonumber(otherRelName) or GetHashKey(otherRelName)
                        SetRelationshipBetweenGroups(1, myHash, otherHash)
                        SetRelationshipBetweenGroups(1, otherHash, myHash)
                    end
                end
                
                for _, enemyGroupName in ipairs(enemyGroups) do
                    local enemyGroupData = Config.ScanForEnemies[enemyGroupName]
                    local enemyRelationships = groupToRelationships[enemyGroupName] or {}
                    for _, enemyRelName in ipairs(enemyRelationships) do
                        local enemyRelData = enemyGroupData and enemyGroupData[enemyRelName]
                        local enemyHash = enemyRelData and enemyRelData.isHash and tonumber(enemyRelName) or GetHashKey(enemyRelName)
                        SetRelationshipBetweenGroups(5, myHash, enemyHash)
                        SetRelationshipBetweenGroups(5, enemyHash, myHash)
                    end
                end
            end
        end
    end
end)




local scanSettings = Config.ScanForEnemies.Settings or {}
local scanRadius = scanSettings.scanRadius or 200.0
local scanInterval = scanSettings.scanInterval or 500
local cacheDistance = scanSettings.cacheDistance or scanRadius
local defaultBlipDespawn = scanSettings.blipDespawn or 0

local groupHashCache = {}
local groupConfigs = {}
local playerGroupID = nil

for groupName, groupData in pairs(Config.ScanForEnemies) do
    if groupName ~= 'Settings' then
        local groupSettings = groupData.Settings or {}
        for relationshipName, relData in pairs(groupData) do
            if relationshipName ~= 'Settings' then
                local hash = relData.isHash and tonumber(relationshipName) or GetHashKey(relationshipName)
                groupHashCache[hash] = {
                    groupID = groupName,
                    relationshipName = relationshipName,
                    enemyGroups = groupSettings.EnemyGroups or {},
                    blipDisplayRelation = groupSettings.BlipDisplayRelation
                }
                if relData.blip then
                    groupConfigs[hash] = relData
                end
            end
        end
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

local function attachBlip(ped, data, targetGroupInfo, pedHash)
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
        despawnDistance = despawnDistance,
        targetGroupInfo = targetGroupInfo,
        pedHash = pedHash,
        blipData = data
    }
end

CreateThread(function()
    while true do
        Wait(scanInterval)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local playerGroupHash = GetPedRelationshipGroupHash(playerPed)
        local playerGroupInfo = groupHashCache[playerGroupHash]
        if playerGroupInfo then
            playerGroupID = playerGroupInfo.groupID
        end

        for ped, info in pairs(pedBlips) do
            if not DoesEntityExist(ped) or IsEntityDead(ped) then
                removeCachedPed(ped)
            else
                local pedCoords = GetEntityCoords(ped)
                local maxDistance = info.despawnDistance or info.distance or cacheDistance
                if #(pedCoords - playerCoords) > maxDistance then
                    removeCachedPed(ped)
                else
                    if info.targetGroupInfo and info.targetGroupInfo.blipDisplayRelation then
                        local playerGroupHash = GetPedRelationshipGroupHash(playerPed)
                        local pedGroupHash = GetPedRelationshipGroupHash(ped)
                        local relationLevel = GetRelationshipBetweenGroups(playerGroupHash, pedGroupHash)
                        
                        if relationLevel < info.targetGroupInfo.blipDisplayRelation then
                            removeCachedPed(ped)
                        elseif not info.blip or not DoesBlipExist(info.blip) then
                            local blip = exports['Nt_Utilities']:CreateBlip(ped, info.blipData.Sprite, info.blipData.Color, info.blipData.Scale, info.blipData.name)
                            if blip then
                                if info.blipData.offRadar then
                                    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, GetHashKey('BLIP_MODIFIER_RADAR_EDGE_ALWAYS'))
                                end
                                info.blip = blip
                            end
                        end
                    end
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
                    local pedHash = GetPedRelationshipGroupHash(ped)
                    local targetGroupInfo = groupHashCache[pedHash]
                    
                    if targetGroupInfo and targetGroupInfo.blipDisplayRelation then
                        local playerGroupHash = GetPedRelationshipGroupHash(playerPed)
                        local pedGroupHash = GetPedRelationshipGroupHash(ped)
                        local relationLevel = GetRelationshipBetweenGroups(playerGroupHash, pedGroupHash)
                        
                        if relationLevel >= targetGroupInfo.blipDisplayRelation then
                            local blipData = groupConfigs[pedHash]
                            if blipData then
                                local spawnDistance = blipData.distance or cacheDistance
                                if distanceToPed <= spawnDistance then
                                    attachBlip(ped, blipData, targetGroupInfo, pedHash)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
