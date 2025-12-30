local pedsAlive = {}
local hostileTargets = {}
local activeCombatAreas = {}
local deadBodies = { new = {}, old = {} }
local inspectQueue = {}

local threatScanningThread = nil
local deadBodyScanningThread = nil
local cleanupThread = nil

local function GetBodyFromCache(bodyPed)
    if deadBodies.new[bodyPed] then
        return deadBodies.new[bodyPed]
    end
    if deadBodies.old[bodyPed] then
        return deadBodies.old[bodyPed]
    end
    return nil
end

local function AddNpcToNearbyBodies(ped, bodyPed, scanRadius)
    if not deadBodies.new[bodyPed] then
        return
    end
    
    local bodyCoords = deadBodies.new[bodyPed].coords
    
    for otherBodyPed, otherBodyData in pairs(deadBodies.new) do
        if otherBodyPed ~= bodyPed then
            local distance = #(bodyCoords - otherBodyData.coords)
            if distance <= scanRadius then
                if not otherBodyData.investigatingNpcs then
                    otherBodyData.investigatingNpcs = {}
                end
                if not otherBodyData.investigatingNpcs[ped] then
                    otherBodyData.investigatingNpcs[ped] = GetGameTimer()
                    debugPrint("[EnemyAI] Added NPC to nearby body at distance " .. string.format("%.2f", distance))
                end
            end
        end
    end
end

local function FindNearbyBodyInCache(ped, radius)
    local pedCoords = GetEntityCoords(ped)
    local closestFound = nil
    local closestBodyDis = radius + 1
    
    for bodyPed, bodyData in pairs(deadBodies.new) do
        if DoesEntityExist(bodyPed) and IsEntityDead(bodyPed) then
            local deadCoords = bodyData.coords
            local distance = #(pedCoords - deadCoords)
            if distance <= radius and distance < closestBodyDis then
                closestFound = bodyPed
                closestBodyDis = distance
            end
        end
    end
    
    if closestFound then
        return closestFound, deadBodies.new[closestFound].coords
    end
    return nil
end

local function CleanupDeadBodiesList()
    for listType, list in pairs(deadBodies) do
        for bodyPed, _ in pairs(list) do
            if not DoesEntityExist(bodyPed) or not IsEntityDead(bodyPed) then
                list[bodyPed] = nil
            end
        end
    end
end

local function IsBodyValid(bodyPed)
    return bodyPed and DoesEntityExist(bodyPed) and IsEntityDead(bodyPed)
end

local function GetBodyCoords(pedData)
    if not pedData then return nil end
    if pedData.deadBodyData and pedData.deadBodyData.coords then
        return pedData.deadBodyData.coords
    elseif pedData.investigatingBody then
        return pedData.investigatingBody
    end
    return nil
end

local function CancelInvestigation(ped, pedData)
    ClearPedTasks(ped)
    pedData.state = "reset"
    pedData.phase = 0
    pedData.nextActionTime = GetGameTimer()
    pedData.investigatingBodyPed = nil
    pedData.investigatingBody = nil
    pedData.deadBodyData = nil
    pedData.investigateCounter = 0
    pedData.wanderStartTime = nil
    pedData.lastNearbyBodyCheck = nil
end

local function MoveBodyToOld(bodyPed)
    if deadBodies.new[bodyPed] then
        deadBodies.old[bodyPed] = deadBodies.new[bodyPed]
        deadBodies.new[bodyPed] = nil
        debugPrint("[EnemyAI] Moved body to old list")
    end
end

local function CanInvestigate(ped, bodyPed, scanRadius)
    if not deadBodies.new[bodyPed] then
        return false
    end
    
    local npcGroup = GetPedRelationshipGroupHash(ped)
    local bodyGroup = GetPedRelationshipGroupHash(bodyPed)
    local isSameGroup = bodyGroup == npcGroup
    local relationship = GetRelationshipBetweenGroups(npcGroup, bodyGroup)
    
    if not isSameGroup and relationship ~= 1 then
        if not deadBodies.new[bodyPed].relationshipCheckTime then
            deadBodies.new[bodyPed].relationshipCheckTime = GetGameTimer()
            debugPrint("[EnemyAI] Body rejected for NPC - not an ally or same group, marking with timestamp")
        end
        return false
    end
    
    -- Check if body already has enough active investigators
    if deadBodies.new[bodyPed].investigatingNpcs then
        local activeInvestigators = 0
        
        for investigatorPed, assignTime in pairs(deadBodies.new[bodyPed].investigatingNpcs) do
            if DoesEntityExist(investigatorPed) and not IsEntityDead(investigatorPed) then
                if pedsAlive[investigatorPed] and pedsAlive[investigatorPed].state == "investigate" then
                    activeInvestigators = activeInvestigators + 1
                end
            end
        end
        
        if activeInvestigators >= Config.CombatAI.DeadBodyDetection.MaxInvestigatorsPerGroup then
            debugPrint("[EnemyAI] Body already has " .. activeInvestigators .. " investigators")
            return false
        end
    end
    
    return true
end

local function AssignNpcToBodyGroup(ped, bodyPed)
    if deadBodies.new[bodyPed] then
        if not deadBodies.new[bodyPed].investigatingNpcs then
            deadBodies.new[bodyPed].investigatingNpcs = {}
        end
        if not deadBodies.new[bodyPed].investigatingNpcs[ped] then
            deadBodies.new[bodyPed].investigatingNpcs[ped] = GetGameTimer()
            debugPrint("[EnemyAI] Assigned NPC to body")
        end
    end
end

local function StartDeadBodyScanning()
    if deadBodyScanningThread then
        return
    end
    
    debugPrint("[EnemyAI] Starting dead body scanning thread")
    deadBodyScanningThread = CreateThread(function()
        while next(pedsAlive) do
            CleanupDeadBodiesList()
            local currentTime = GetGameTimer()
            
            for ped, pedData in pairs(pedsAlive) do
                if DoesEntityExist(ped) and not IsEntityDead(ped) and pedData.state ~= "combat" then
                    local pedCoords = GetEntityCoords(ped)
                    local scanRadius = Config.CombatAI.DeadBodyDetection.ScanRadius
                    local nearbyPeds = GetGamePool('CPed')
                    
                    for _, checkPed in ipairs(nearbyPeds) do
                        if DoesEntityExist(checkPed) and IsEntityDead(checkPed) then
                            local distance = #(pedCoords - GetEntityCoords(checkPed))
                            
                            if distance <= scanRadius then
                                if not GetBodyFromCache(checkPed) then
                                    local bodyGroup = GetPedRelationshipGroupHash(checkPed)
                                    local npcGroup = GetPedRelationshipGroupHash(ped)
                                    local isSameGroup = bodyGroup == npcGroup
                                    local relationship = GetRelationshipBetweenGroups(npcGroup, bodyGroup)
                                    
                                    if isSameGroup or relationship == 1 then
                                        deadBodies.new[checkPed] = {
                                            coords = GetEntityCoords(checkPed),
                                            addedTime = nil,
                                            investigationCount = 0,
                                            investigatingNpcs = {}
                                        }
                                        debugPrint("[EnemyAI] Added new dead body to cache at distance " .. string.format("%.2f", distance))
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            for bodyPed, bodyData in pairs(deadBodies.new) do
                -- Clean up stale investigator assignments
                if bodyData.investigatingNpcs then
                    for investigatorPed, assignTime in pairs(bodyData.investigatingNpcs) do
                        if not DoesEntityExist(investigatorPed) or IsEntityDead(investigatorPed) then
                            bodyData.investigatingNpcs[investigatorPed] = nil
                        elseif pedsAlive[investigatorPed] and pedsAlive[investigatorPed].state ~= "investigate" then
                            bodyData.investigatingNpcs[investigatorPed] = nil
                        end
                    end
                end
                
                if bodyData.investigationCount >= Config.CombatAI.DeadBodyDetection.MaxInvestigationsPerBody then
                    MoveBodyToOld(bodyPed)
                elseif bodyData.addedTime and (currentTime - bodyData.addedTime) > Config.CombatAI.DeadBodyDetection.BodyExpirationTime then
                    debugPrint("[EnemyAI] Body expired (15s timeout), moving to old list")
                    MoveBodyToOld(bodyPed)
                end
            end
            
            Wait(Config.CombatAI.DeadBodyDetection.ScanInterval)
        end
        deadBodyScanningThread = nil
        debugPrint("[EnemyAI] Dead body scanning thread ended")
    end)
end

local function StartDeadBodyMonitoring()
    StartDeadBodyScanning()
end

local function StartThreatScanning()
    if threatScanningThread then
        return
    end
    if Config.CombatAI.DisableCombat then
        return
    end
    
    debugPrint("[EnemyAI] Starting global threat scanning thread")
    threatScanningThread = CreateThread(function()
        while next(pedsAlive) do
            for ped, _ in pairs(pedsAlive) do
                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                    local npcGroup = GetPedRelationshipGroupHash(ped)
                    
                    local nearbyPeds = GetGamePool('CPed')
                    for _, targetPed in ipairs(nearbyPeds) do
                        if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                            local targetGroup = GetPedRelationshipGroupHash(targetPed)
                            
                            if targetGroup ~= npcGroup then
                                local relationship = GetRelationshipBetweenGroups(npcGroup, targetGroup)
                                
                                if relationship == 5 then
                                    if not hostileTargets[npcGroup] then
                                        hostileTargets[npcGroup] = {}
                                    end
                                    hostileTargets[npcGroup][targetPed] = GetGameTimer()
                                end
                            end
                        end
                    end
                    
                    if hostileTargets[npcGroup] then
                        local currentTime = GetGameTimer()
                        for targetPed, lastSeenTime in pairs(hostileTargets[npcGroup]) do
                            if not DoesEntityExist(targetPed) or IsEntityDead(targetPed) then
                                hostileTargets[npcGroup][targetPed] = nil
                            elseif (currentTime - lastSeenTime) > Config.CombatAI.ThreatScanning.TargetTimeoutMs then
                                hostileTargets[npcGroup][targetPed] = nil
                            end
                        end
                    end
                end
            end
            
            Wait(Config.CombatAI.ThreatScanning.Interval)
        end
        threatScanningThread = nil
        debugPrint("[EnemyAI] Threat scanning thread ended")
    end)
end

local function StartCleanupThread()
    if cleanupThread then
        return
    end
    
    debugPrint("[EnemyAI] Starting cleanup thread")
    cleanupThread = CreateThread(function()
        Wait(60000)
        
        while next(pedsAlive) do
            -- Cleanup combat areas
            for i = #activeCombatAreas, 1, -1 do
                local area = activeCombatAreas[i]
                if area.activePeds then
                    -- Remove inactive or dead peds from combat area
                    for pedInArea, _ in pairs(area.activePeds) do
                        if not DoesEntityExist(pedInArea) or IsEntityDead(pedInArea) or not pedsAlive[pedInArea] or pedsAlive[pedInArea].state ~= "combat" then
                            area.activePeds[pedInArea] = nil
                        end
                    end
                    
                    -- Check if combat area still has active peds
                    local hasActivePeds = false
                    for _, _ in pairs(area.activePeds) do
                        hasActivePeds = true
                        break
                    end
                    
                    -- Remove combat area if empty
                    if not hasActivePeds then
                        table.remove(activeCombatAreas, i)
                        debugPrint("[EnemyAI] Cleanup: Removed empty combat area")
                    end
                end
            end
            
            Wait(60000)
        end
        
        debugPrint("[EnemyAI] Cleanup: All NPCs removed, resetting caches")
        hostileTargets = {}
        activeCombatAreas = {}
        deadBodies = { new = {}, old = {} }
        inspectQueue = {}
        threatScanningThread = nil
        deadBodyScanningThread = nil
        
        cleanupThread = nil
        debugPrint("[EnemyAI] Cleanup thread ended")
    end)
end

local function ManageNPC(ped, sightRange, hearingRange, combatRange, groupHash, action, spawnCoords)
    debugPrint("[EnemyAI] NPC Management Thread Started")
    
    while DoesEntityExist(ped) and not IsEntityDead(ped) and pedsAlive[ped] ~= nil do
        local currentTime = GetGameTimer()
        local pedCoords = GetEntityCoords(ped)
        local pedData = pedsAlive[ped]
        local myGroupHash = GetPedRelationshipGroupHash(ped)
        local targets = hostileTargets[myGroupHash] or {}
        
        if pedData.shouldBeMoving then
            if not pedData.lastMovementCoords then
                pedData.lastMovementCoords = pedCoords
                pedData.lastMovementCheckTime = currentTime
            elseif (currentTime - pedData.lastMovementCheckTime) >= 30000 then
                local movementDistance = #(pedCoords - pedData.lastMovementCoords)
                if movementDistance < 5.0 then
                    debugPrint("[EnemyAI] NPC stuck for 30 seconds, teleporting to spawn")
                    ClearPedTasks(ped)
                    SetEntityCoords(ped, spawnCoords, false, false, false, false)
                    pedData.state = "reset"
                    pedData.phase = 0
                    pedData.shouldBeMoving = false
                    pedData.lastMovementCoords = nil
                    pedData.nextActionTime = currentTime
                    pedData.investigatingBodyPed = nil
                    pedData.investigatingBody = nil
                    pedData.deadBodyData = nil
                    pedData.investigateCounter = 0
                    pedData.wanderStartTime = nil
                    pedData.lastNearbyBodyCheck = nil
                else
                    pedData.lastMovementCoords = pedCoords
                    pedData.lastMovementCheckTime = currentTime
                end
            end
        end
        
        if pedData.state == "combat" then
            -- Only check combat range every 30 seconds to prevent race conditions
            if currentTime >= pedData.nextActionTime then
                local inCombatRange = false
                
                for targetPed, _ in pairs(targets) do
                    if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local distance = #(pedCoords - targetCoords)
                        
                        if distance <= combatRange then
                            inCombatRange = true
                            break
                        end
                    end
                end
                
                if inCombatRange then
                    -- Still in combat, set next check for 30 seconds
                    pedData.nextActionTime = currentTime + 30000
                    debugPrint("[EnemyAI] Still in combat, next range check in 30 seconds")
                else
                    debugPrint("[EnemyAI] No targets in combat range, exiting combat and returning to " .. action)
                    ClearPedTasks(ped)
                    pedData.state = "reset"
                    pedData.phase = 0
                    pedData.nextActionTime = currentTime
                    
                    -- Remove from combat areas when exiting combat
                    for i = #activeCombatAreas, 1, -1 do
                        local area = activeCombatAreas[i]
                        if area.activePeds and area.activePeds[ped] then
                            area.activePeds[ped] = nil
                            debugPrint("[EnemyAI] Removed ped from combat area (exiting combat)")
                            
                            -- Check if combat area still has active peds
                            local hasActivePeds = false
                            for activePed, _ in pairs(area.activePeds) do
                                if DoesEntityExist(activePed) and not IsEntityDead(activePed) and pedsAlive[activePed] and pedsAlive[activePed].state == "combat" then
                                    hasActivePeds = true
                                    break
                                end
                            end
                            
                            if not hasActivePeds then
                                table.remove(activeCombatAreas, i)
                                debugPrint("[EnemyAI] Removed empty combat area (last ped exited)")
                            end
                            break
                        end
                    end
                    
                    pedData.investigatingBody = nil
                    pedData.investigatingBodyPed = nil
                    pedData.deadBodyData = nil
                    pedData.investigateCounter = 0
                    pedData.wanderStartTime = nil
                    pedData.lastNearbyBodyCheck = nil
                end
            end
            
        elseif pedData.state == "reset" then
            if pedData.phase == 0 then
                debugPrint("[EnemyAI] Walking NPC back to spawn")
                ClearPedTasks(ped)
                pedData.shouldBeMoving = true
                pedData.lastMovementCoords = nil
                TaskGoToCoordAnyMeans(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, Config.CombatAI.NpcMovement.TaskGoToCoordSpeed, 0, 0, Config.CombatAI.NpcMovement.TaskGoToCoordFlags, Config.CombatAI.NpcMovement.TaskGoToCoordFlag2)
                pedData.phase = 1
                pedData.nextActionTime = currentTime + Config.CombatAI.Reset.WalkbackTimeout
            elseif pedData.phase == 1 then
                local distance = #(GetEntityCoords(ped) - spawnCoords)
                if distance <= Config.CombatAI.Reset.TargetDistance then
                    debugPrint("[EnemyAI] NPC reached spawn, resuming " .. action)
                    ClearPedTasks(ped)
                    pedData.shouldBeMoving = false
                    pedData.state = action
                    pedData.phase = 0
                    pedData.nextActionTime = currentTime
                elseif currentTime >= pedData.nextActionTime then
                    debugPrint("[EnemyAI] Reset timeout, tasking NPC to return to spawn")
                    ClearPedTasks(ped)
                    pedData.shouldBeMoving = true
                    pedData.lastMovementCoords = nil
                    TaskGoToCoordAnyMeans(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, 1.0, 0, 0, 786603)
                    pedData.state = action
                    pedData.phase = 0
                    pedData.nextActionTime = currentTime
                end
            end
            
        elseif pedData.state == "ambient" then
            if currentTime >= pedData.nextActionTime then
                
                if pedData.phase == 0 then
                    debugPrint("[EnemyAI] Ambient Phase 0: Starting scenario")
                    local pedCoords = GetEntityCoords(ped)
                    TaskUseNearestScenarioToCoord(ped, pedCoords.x, pedCoords.y, pedCoords.z, Config.CombatAI.NpcMovement.ScenarioSearchRadius, -1)
                    pedData.phase = 1
                    pedData.nextActionTime = currentTime + Config.CombatAI.Ambient.PhaseScenarioDuration
                    
                elseif pedData.phase == 1 then
                    debugPrint("[EnemyAI] Ambient Phase 1: Wandering in area")
                    ClearPedTasks(ped)
                    TaskWanderInArea(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, Config.CombatAI.NpcMovement.TaskWanderRadius, 0, 0)
                    pedData.phase = 2
                    pedData.nextActionTime = currentTime + Config.CombatAI.Ambient.PhaseWanderDuration
                    
                elseif pedData.phase == 2 then
                    debugPrint("[EnemyAI] Ambient Phase 2: Idle scenario")
                    ClearPedTasks(ped)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_IDLE_A", 0, true)
                    pedData.phase = 3
                    pedData.nextActionTime = currentTime + Config.CombatAI.Ambient.PhaseIdleDuration
                    
                elseif pedData.phase == 3 then
                    debugPrint("[EnemyAI] Ambient Phase 3: Look around")
                    pedData.phase = 4
                    pedData.nextActionTime = currentTime + Config.CombatAI.Ambient.PhaseLookAroundDuration
                    
                elseif pedData.phase == 4 then
                    debugPrint("[EnemyAI] Ambient Phase 4: Standing still")
                    SetPedDesiredHeading(ped, math.random(0, 360))
                    TaskStandStill(ped, Config.CombatAI.Ambient.PhaseStandStillDuration)
                    pedData.phase = 0
                    pedData.nextActionTime = currentTime + Config.CombatAI.Ambient.PhaseStandStillDuration
                    
                end
            end
            
        elseif pedData.state == "guard" then
            if pedData.phase == 0 then
                pedData.guardHeading = GetEntityHeading(ped)
                TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND", 0, true)
                pedData.phase = 1
                pedData.nextActionTime = currentTime + Config.CombatAI.Guard.PositionCheckInterval
            elseif currentTime >= pedData.nextActionTime then
                local distance = #(GetEntityCoords(ped) - spawnCoords)
                if distance > Config.CombatAI.Reset.TargetDistance then
                    pedData.shouldBeMoving = true
                    pedData.lastMovementCoords = nil
                    TaskGoToCoordAnyMeans(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, 1.0, 0, 0, 786603)
                end
                pedData.nextActionTime = currentTime + Config.CombatAI.Guard.PositionCheckInterval
            end
            
        elseif pedData.state == "investigate" then
            if currentTime >= pedData.nextActionTime then
                debugPrint("[EnemyAI] Investigation Phase: " .. pedData.phase)
                
                if pedData.phase == 0 then
                    if not IsBodyValid(pedData.investigatingBodyPed) then
                        debugPrint("[EnemyAI] Phase 0: Body invalid, canceling investigation")
                        CancelInvestigation(ped, pedData)
                    else
                        local bodyCoords = GetBodyCoords(pedData)
                        if not bodyCoords then
                            debugPrint("[EnemyAI] Phase 0: No body coordinates, canceling investigation")
                            CancelInvestigation(ped, pedData)
                        else
                            debugPrint("[EnemyAI] Phase 0: Approaching body")
                            ClearPedTasks(ped)
                            pedData.shouldBeMoving = true
                            pedData.lastMovementCoords = nil
                            TaskGoToCoordAnyMeans(ped, bodyCoords.x, bodyCoords.y, bodyCoords.z, Config.CombatAI.NpcMovement.TaskGoToCoordSpeed, 0, 0, Config.CombatAI.NpcMovement.TaskGoToCoordFlags, Config.CombatAI.NpcMovement.TaskGoToCoordFlag2)
                            pedData.phase = 1
                            pedData.nextActionTime = currentTime + Config.CombatAI.Investigation.ApproachBodyTimeout
                        end
                    end
                    
                elseif pedData.phase == 1 then
                    if not IsBodyValid(pedData.investigatingBodyPed) then
                        debugPrint("[EnemyAI] Phase 1: Body invalid, canceling investigation")
                        CancelInvestigation(ped, pedData)
                    else
                        local bodyCoords = GetBodyCoords(pedData)
                        if not bodyCoords then
                            debugPrint("[EnemyAI] Phase 1: No body coordinates, canceling investigation")
                            CancelInvestigation(ped, pedData)
                        elseif #(GetEntityCoords(ped) - bodyCoords) <= Config.CombatAI.Reset.TargetDistance then
                            debugPrint("[EnemyAI] Phase 1: Arrived at body, turning to face")
                            ClearPedTasks(ped)
                            pedData.shouldBeMoving = false
                            TaskTurnPedToFaceCoord(ped, bodyCoords.x, bodyCoords.y, bodyCoords.z, Config.CombatAI.Investigation.ExamineBodyTimeout)
                            pedData.phase = 2
                            pedData.investigateCounter = 0
                            pedData.nextActionTime = currentTime + Config.CombatAI.Investigation.ExamineBodyTimeout
                        else
                            pedData.nextActionTime = currentTime + 250
                        end
                    end
                    
                elseif pedData.phase == 2 then
                    if not IsBodyValid(pedData.investigatingBodyPed) then
                        debugPrint("[EnemyAI] Phase 2: Body invalid, canceling investigation")
                        CancelInvestigation(ped, pedData)
                    else
                        debugPrint("[EnemyAI] Phase 2: Examining and looking around")
                        ClearPedTasks(ped)
                        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CROUCH_INSPECT", 0, true)
                        pedData.phase = 2.5
                        pedData.nextActionTime = currentTime + Config.CombatAI.Investigation.InspectionDuration
                    end
                    
                elseif pedData.phase == 2.5 then
                    if not IsBodyValid(pedData.investigatingBodyPed) then
                        debugPrint("[EnemyAI] Phase 2.5: Body invalid, canceling investigation")
                        CancelInvestigation(ped, pedData)
                    else
                        if pedData.investigateCounter < Config.CombatAI.Investigation.SuspiciousLookRepetitions then
                            ClearPedTasks(ped)
                            SetPedDesiredHeading(ped, math.random(0, 360))
                            TaskStandStill(ped, Config.CombatAI.Investigation.SuspiciousLookDuration)
                            pedData.investigateCounter = pedData.investigateCounter + 1
                            pedData.nextActionTime = currentTime + Config.CombatAI.Investigation.SuspiciousLookDuration + 500
                        else
                            debugPrint("[EnemyAI] Phase 3: Starting search area wander")
                            local bodyCoords = GetBodyCoords(pedData)
                            if not bodyCoords then
                                debugPrint("[EnemyAI] Phase 3: No body coordinates, canceling investigation")
                                CancelInvestigation(ped, pedData)
                            else
                                ClearPedTasks(ped)
                                TaskWanderInArea(ped, bodyCoords.x, bodyCoords.y, bodyCoords.z, Config.CombatAI.Investigation.SearchPointRadius, 0, 0)
                                pedData.wanderStartTime = currentTime
                                pedData.lastNearbyBodyCheck = currentTime
                                pedData.phase = 3
                                pedData.nextActionTime = currentTime + 5000
                            end
                        end
                    end
                    
                elseif pedData.phase == 3 then
                    if not IsBodyValid(pedData.investigatingBodyPed) then
                        debugPrint("[EnemyAI] Phase 3: Body invalid, canceling investigation")
                        CancelInvestigation(ped, pedData)
                    else
                        local bodyCoords = GetBodyCoords(pedData)
                        if not bodyCoords then
                            debugPrint("[EnemyAI] Phase 3: No body coordinates, canceling investigation")
                            CancelInvestigation(ped, pedData)
                        elseif (currentTime - pedData.lastNearbyBodyCheck) >= 5000 then
                            AddNpcToNearbyBodies(ped, pedData.investigatingBodyPed, Config.CombatAI.Investigation.SearchPointRadius)
                            pedData.lastNearbyBodyCheck = currentTime
                            pedData.nextActionTime = currentTime + 5000
                        end
                        
                        if (currentTime - pedData.wanderStartTime) >= 60000 then
                            debugPrint("[EnemyAI] Phase 4: Wander complete, finishing investigation")
                            pedData.phase = 4
                            pedData.nextActionTime = currentTime
                        end
                    end
                    
                elseif pedData.phase == 4 then
                    debugPrint("[EnemyAI] Phase 4: Investigation complete")
                    local bodyPed = pedData.investigatingBodyPed
                    if IsBodyValid(bodyPed) and pedData.deadBodyData then
                        pedData.deadBodyData.investigationCount = pedData.deadBodyData.investigationCount + 1
                        debugPrint("[EnemyAI] Body investigation count: " .. pedData.deadBodyData.investigationCount)
                        if deadBodies.new[bodyPed] then
                            deadBodies.new[bodyPed].investigationCount = pedData.deadBodyData.investigationCount
                            if deadBodies.new[bodyPed].investigationCount >= Config.CombatAI.DeadBodyDetection.MaxInvestigationsPerBody then
                                MoveBodyToOld(bodyPed)
                            end
                        end
                    end
                    CancelInvestigation(ped, pedData)
                    
                end
            end
        end
        
        if pedData.state ~= "combat" and pedData.state ~= "reset" then
            local targetDetected = false
            
            for targetPed, _ in pairs(targets) do
                if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local distance = #(pedCoords - targetCoords)
                    
                    local detected = false
                    
                    if HasEntityClearLosToEntityInFront(ped, targetPed, Config.CombatAI.Detection.SightRangeCheck) and distance <= sightRange then
                        detected = true
                    end
                    
                    if not detected then
                        local targetSpeed = GetEntitySpeed(targetPed)
                        if HasEntityClearLosToEntity(ped, targetPed, Config.CombatAI.Detection.HearingRangeCheck) and distance <= hearingRange then
                            if distance <= (hearingRange * Config.CombatAI.Detection.CloseProximityMultiplier) and targetSpeed > Config.CombatAI.Detection.CloseProximitySpeedThreshold then
                                detected = true
                            elseif targetSpeed > Config.CombatAI.Detection.StandardSpeedThreshold and distance <= hearingRange then
                                detected = true
                            end
                        end
                    end
                    
                    if detected then
                        debugPrint("[EnemyAI] Target detected at distance " .. string.format("%.2f", distance))
                        ClearPedTasks(ped)
                        pedData.state = "combat"
                        pedData.phase = 0
                        pedData.nextActionTime = currentTime + 30000  -- 30 second combat timer
                        
                        pedData.investigatingBody = nil
                        pedData.investigatingBodyPed = nil
                        pedData.deadBodyData = nil
                        pedData.searchPoints = {}
                        pedData.searchIndex = 0
                        pedData.investigateCounter = 0
                        pedData.searchSubPhase = nil
                        
                        TaskCombatHatedTargets(ped)
                        
                        -- Check if there's already an active combat area for this group nearby
                        local existingCombatArea = false
                        for i, area in ipairs(activeCombatAreas) do
                            if area.groupHash == myGroupHash then
                                local areaDistance = #(pedCoords - area.coords)
                                if areaDistance <= combatRange then
                                    -- Add this ped to existing combat area
                                    area.activePeds[ped] = GetGameTimer()
                                    existingCombatArea = true
                                    debugPrint("[EnemyAI] Joining existing combat area at distance " .. string.format("%.2f", areaDistance))
                                    break
                                end
                            end
                        end
                        
                        -- Create new combat area if none exists nearby
                        if not existingCombatArea then
                            local combatArea = {
                                groupHash = myGroupHash,
                                coords = pedCoords, -- Cache initial combat coordinates
                                activePeds = { [ped] = GetGameTimer() },
                                createdTime = GetGameTimer()
                            }
                            table.insert(activeCombatAreas, combatArea)
                            debugPrint("[EnemyAI] Created new combat area at coords: " .. tostring(pedCoords))
                        end
                        
                        targetDetected = true
                        break
                    end
                end
            end
            
            -- Check if this NPC should join an active combat area
            if not targetDetected and pedData.state ~= "combat" and pedData.state ~= "investigate" then
                for i, area in ipairs(activeCombatAreas) do
                    if area.groupHash == myGroupHash then
                        local areaDistance = #(pedCoords - area.coords)
                        if areaDistance <= combatRange then
                            debugPrint("[EnemyAI] NPC entering combat due to proximity to combat area at distance " .. string.format("%.2f", areaDistance))
                            ClearPedTasks(ped)
                            pedData.state = "combat"
                            pedData.phase = 0
                            pedData.nextActionTime = currentTime + 30000  -- 30 second combat timer
                            
                            pedData.investigatingBody = nil
                            pedData.investigatingBodyPed = nil
                            pedData.deadBodyData = nil
                            pedData.searchPoints = {}
                            pedData.searchIndex = 0
                            pedData.investigateCounter = 0
                            pedData.searchSubPhase = nil
                            
                            TaskCombatHatedTargets(ped)
                            area.activePeds[ped] = GetGameTimer()
                            targetDetected = true
                            break
                        end
                    end
                end
            end
            
            if not targetDetected and pedData.state ~= "investigate" and (pedData.state == "ambient" or pedData.state == "guard") then
                local foundBodyPed, foundBodyCoords = FindNearbyBodyInCache(ped, Config.CombatAI.Investigation.NearbyBodyCheckRadius)
                if foundBodyPed then
                    local canInvestigate = CanInvestigate(ped, foundBodyPed, Config.CombatAI.Investigation.NearbyBodyCheckRadius)
                    if canInvestigate then
                        debugPrint("[EnemyAI] Dead body found nearby, switching to investigate")
                        if deadBodies.new[foundBodyPed] then
                            if not deadBodies.new[foundBodyPed].addedTime then
                                deadBodies.new[foundBodyPed].addedTime = currentTime
                            end
                            pedData.deadBodyData = {
                                coords = deadBodies.new[foundBodyPed].coords,
                                addedTime = deadBodies.new[foundBodyPed].addedTime,
                                investigationCount = 0
                            }
                        end
                        AssignNpcToBodyGroup(ped, foundBodyPed)
                        pedData.state = "investigate"
                        pedData.phase = 0
                        pedData.nextActionTime = currentTime
                        pedData.investigatingBodyPed = foundBodyPed
                        pedData.investigatingBody = foundBodyCoords
                    else
                        debugPrint("[EnemyAI] NPC rejected from investigating body - not an ally")
                    end
                end
            end
        end
        
        Wait(250)
    end
    
    debugPrint("[EnemyAI] NPC Management Thread ended")
    if DoesEntityExist(ped) then
        ClearPedTasks(ped)
    end
    
    -- Remove this ped from any combat areas and cleanup empty areas
    for i = #activeCombatAreas, 1, -1 do
        local area = activeCombatAreas[i]
        if area.activePeds and area.activePeds[ped] then
            area.activePeds[ped] = nil
            debugPrint("[EnemyAI] Removed ped from combat area")
            
            -- Check if combat area still has active peds
            local hasActivePeds = false
            for activePed, _ in pairs(area.activePeds) do
                if DoesEntityExist(activePed) and not IsEntityDead(activePed) and pedsAlive[activePed] and pedsAlive[activePed].state == "combat" then
                    hasActivePeds = true
                    break
                end
            end
            
            -- Remove combat area if no active peds remain
            if not hasActivePeds then
                table.remove(activeCombatAreas, i)
                debugPrint("[EnemyAI] Removed empty combat area")
            end
        end
    end
    
    pedsAlive[ped] = nil
end

exports('InitializeCombatAI', function(ped, sightRange, hearingRange, combatRange, scanInterval, enemyGroupHash, action)
    if not DoesEntityExist(ped) then
        return
    end
    
    action = action or "ambient"
    debugPrint("[EnemyAI] Initializing NPC with Combat AI - Action: " .. action .. ", Sight: " .. sightRange .. ", Hearing: " .. hearingRange)
    
    local wasEmpty = not next(pedsAlive)
    if wasEmpty then
        StartCleanupThread()
    end
    
    local spawnCoords = GetEntityCoords(ped)
    
    pedsAlive[ped] = {
        state = action,
        phase = 0,
        nextActionTime = GetGameTimer(),
        initialAction = action,
        groupHash = enemyGroupHash,
        investigateCounter = 0,
        investigatingBody = nil,
        investigatingBodyPed = nil,
        deadBodyData = nil,
        wanderStartTime = nil,
        lastNearbyBodyCheck = nil,
        shouldBeMoving = false,
        lastMovementCoords = nil,
        lastMovementCheckTime = nil
    }
    
    StartThreatScanning()
    StartDeadBodyMonitoring()
    
    CreateThread(function()
        ManageNPC(ped, sightRange, hearingRange, combatRange, enemyGroupHash, action, spawnCoords)
    end)
end)

function StopCombatAI(ped)
    debugPrint("[EnemyAI] Stopping Combat AI for NPC")
    if DoesEntityExist(ped) then
        ClearPedTasks(ped)
    end
    pedsAlive[ped] = nil
end

function IsActive(ped)
    return pedsAlive[ped] ~= nil
end

function Cleanup()
    debugPrint("[EnemyAI] Cleaning up all NPCs with Combat AI")
    
    for ped, _ in pairs(pedsAlive) do
        if DoesEntityExist(ped) then
            ClearPedTasks(ped)
        end
        pedsAlive[ped] = nil
    end
    
    hostileTargets = {}
    activeCombatAreas = {}
    deadBodies = { new = {}, old = {} }
    inspectQueue = {}
    threatScanningThread = nil
    deadBodyScanningThread = nil
    cleanupThread = nil
end

AddEventHandler("onResourceStop", function()
    Cleanup()
end)
