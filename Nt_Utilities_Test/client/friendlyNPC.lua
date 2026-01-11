local spawnedNPCs = {}
local npcBehavior = {}


-- Distance based NPC spawner, animator.

local function ManageNPC()
    while true do
        Wait(1000)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for npcName, npcData in pairs(ConfigFriendlyNPC.NPCs) do
            local distance = #(playerCoords - npcData.coords.xyz)
            
            if distance < ConfigFriendlyNPC.NPCSettings.spawnDistance then
                if not spawnedNPCs[npcName] then
                    local ped = exports['Nt_Utilities']:SpawnFriendlyNPC(npcData.model, npcData.coords)
                    if ped then
                        local loadedTimerout = 10
                        while loadedTimerout > 0 do
                            if DoesEntityExist(ped) then
                                loadedTimerout = 0
                            end
                            loadedTimerout = loadedTimerout - 1
                            Wait(200)
                        end

                        spawnedNPCs[npcName] = ped
                        npcBehavior[npcName] = {
                            resumeScenarioPending = true,
                            lastScenario = nil,
                            scenarioTimer = ConfigFriendlyNPC.NPCSettings.scenarioSwapInterval,
                        }
                    end
                end
                
                if spawnedNPCs[npcName] then
                    local ped = spawnedNPCs[npcName]
                    local beh = npcBehavior[npcName]
                    
                    if DoesEntityExist(ped) and beh then
                        if not IsEntityDead(ped) then
                            local pedCoords = GetEntityCoords(ped)
                            local dx = pedCoords.x - npcData.coords.x
                            local dy = pedCoords.y - npcData.coords.y
                            local dz = pedCoords.z - npcData.coords.z
                            local distFromSpawn = math.sqrt(dx*dx + dy*dy + dz*dz)
                            if distFromSpawn >= 10.0 then
                                ClearPedTasksImmediately(ped)
                                Wait(100)
                                TaskGoToCoordAnyMeans(ped, npcData.coords.x, npcData.coords.y, npcData.coords.z, 1.0, 0, false, 0, 0.0)
                                while distFromSpawn > 2 do
                                    Wait(500)
                                    pedCoords = GetEntityCoords(ped)
                                    dx = pedCoords.x - npcData.coords.x
                                    dy = pedCoords.y - npcData.coords.y
                                    dz = pedCoords.z - npcData.coords.z
                                    distFromSpawn = math.sqrt(dx*dx + dy*dy + dz*dz)
                                end
                                Wait(500)
                                ClearPedTasksImmediately(ped)
                                beh.scenarioTimer = ConfigFriendlyNPC.NPCSettings.scenarioSwapInterval
                                beh.resumeScenarioPending = true
                            end
                            
                            if beh.resumeScenarioPending and distFromSpawn <= 2 then
                                if IsPedStill(ped) then
                                    local scenario = ConfigFriendlyNPC.Scenarios[npcData.scenario]
                                    if scenario and #scenario > 0 then
                                        local randomScenario = scenario[math.random(1, #scenario)]
                                        ClearPedTasks(ped)
                                        if npcData.coords.w then
                                            SetEntityHeading(ped, npcData.coords.w)
                                        end
                                        if randomScenario == "Ambient" then
                                            TaskUseNearestScenarioToCoord(ped, npcData.coords.x, npcData.coords.y, npcData.coords.z, ConfigFriendlyNPC.NPCSettings.scenarioRadius, -1, false, false, false, false)
                                        elseif npcData.scenarioCoords ~= false then
                                            TaskStartScenarioAtPosition(ped, randomScenario, npcData.scenarioCoords.x, npcData.scenarioCoords.y, npcData.scenarioCoords.z, npcData.scenarioCoords.w, -1, true, true)
                                        else
                                            TaskStartScenarioInPlace(ped, randomScenario, -1, true)
                                        end
                                        beh.lastScenario = randomScenario
                                    end
                                    beh.resumeScenarioPending = false
                                end
                            elseif not beh.resumeScenarioPending then
                                beh.scenarioTimer = beh.scenarioTimer - 1
                                if beh.scenarioTimer <= 0 then
                                    beh.scenarioTimer = ConfigFriendlyNPC.NPCSettings.scenarioSwapInterval
                                    local scenario = ConfigFriendlyNPC.Scenarios[npcData.scenario]
                                    if scenario and #scenario > 0 then
                                        local randomScenario = scenario[math.random(1, #scenario)]
                                        if randomScenario ~= beh.lastScenario then
                                            ClearPedTasks(ped)
                                            if npcData.coords.w then
                                                SetEntityHeading(ped, npcData.coords.w)
                                            end
                                            if randomScenario == "Ambient" then
                                                TaskUseNearestScenarioToCoord(ped, npcData.coords.x, npcData.coords.y, npcData.coords.z, ConfigFriendlyNPC.NPCSettings.scenarioRadius, -1, false, false, false, false)
                                            elseif npcData.scenarioCoords ~= false then
                                                TaskStartScenarioAtPosition(ped, randomScenario, npcData.scenarioCoords.x, npcData.scenarioCoords.y, npcData.scenarioCoords.z, npcData.scenarioCoords.w, -1, true, true)
                                            else
                                                TaskStartScenarioInPlace(ped, randomScenario, -1, true)
                                            end
                                            beh.lastScenario = randomScenario
                                        end
                                    end
                                end
                            end
                        else
                            DeletePed(ped)
                            spawnedNPCs[npcName] = nil
                            npcBehavior[npcName] = nil
                        end
                    end
                end
            else
                if spawnedNPCs[npcName] then
                    local ped = spawnedNPCs[npcName]
                    if DoesEntityExist(ped) then
                        DeletePed(ped)
                    end
                    spawnedNPCs[npcName] = nil
                    npcBehavior[npcName] = nil
                end
            end
        end
    end
end


RegisterCommand('FriendlyNPC', function()
    ManageNPC()
end, false)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for location, ped in pairs(spawnedNPCs) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
        spawnedNPCs[ped] = nil
    end
end)
