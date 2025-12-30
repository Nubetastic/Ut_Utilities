local spawnedNPCs = {}


-- Distance based NPC spawner, animator.

local function ManageNPC()
    local scenarioTimer = 0
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
                        local scenario = ConfigFriendlyNPC.Scenarios[npcData.scenario]
                        scenarioTimer = scenarioTimer - 1
                        if scenario and #scenario > 0 and scenarioTimer <= 0 then
                            scenarioTimer = ConfigFriendlyNPC.NPCSettings.scenarioTime
                            local randomScenario = scenario[math.random(1, #scenario)]
                            if randomScenario == "Ambient" then
                                TaskUseNearestScenarioToCoord(ped, ConfigFriendlyNPC.NPCs[npcName].coords.x, ConfigFriendlyNPC.NPCs[npcName].coords.y, ConfigFriendlyNPC.NPCs[npcName].coords.z, ConfigFriendlyNPC.NPCSettings.scenarioRadius, -1, false, false, false, false)
                            elseif ConfigFriendlyNPC.NPCs[npcName].scenarioCoords ~= false then
                                TaskStartScenarioAtPosition(ped, randomScenario, ConfigFriendlyNPC.NPCs[npcName].scenarioCoords.x, ConfigFriendlyNPC.NPCs[npcName].scenarioCoords.y, ConfigFriendlyNPC.NPCs[npcName].scenarioCoords.z, ConfigFriendlyNPC.NPCs[npcName].scenarioCoords.w, -1, true, true)
                            else
                                TaskStartScenarioInPlace(ped, randomScenario, -1, true)
                            end
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
                end
            end
        end
    end
end


RegisterCommand('FriendlyNPC', function()
    ManageNPC()
end, false)

AddEventHandler("onResourceStop", function()
    for location, ped in pairs(spawnedNPCs) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
        spawnedNPCs[ped] = nil
    end
end)