local GetGroupEnabled = false

RegisterCommand('GetGroup', function(source, args, rawCommand)
    if not args[1] then
        print("^2Usage: /GetGroup true/false^7")
        return
    end

    local state = string.lower(args[1])
    if state == 'true' or state == '1' then
        GetGroupEnabled = true
        print("^2GetGroup enabled. Target peds to see their group hash.^7")
        addTargets()
    elseif state == 'false' or state == '0' then
        GetGroupEnabled = false
        print("^2GetGroup disabled.^7")
        removeTargets()
    else
        print("^1Invalid argument. Use true or false.^7")
    end
end, false)

RegisterCommand('setPlayerGroup', function(source, args, rawCommand)
    if not args[1] then
        print("^2Usage: /setPlayerGroup <relationship_name>^7")
        return
    end

    local relationshipName = args[1]
    local groupHash = GetHashKey(relationshipName)
    local playerPed = PlayerPedId()
    
    SetPedRelationshipGroupHash(playerPed, groupHash)
    print("^2Player group set to: " .. relationshipName .. " Hash: " .. groupHash .. "^7")
end, false)

function addTargets()
    exports.ox_target:addGlobalPed({
        label = "Show Group Hash",
        icon = "fas fa-info-circle",
        onSelect = function(data)
            local targetPed = data and data.entity
            if not targetPed or not DoesEntityExist(targetPed) or IsPedAPlayer(targetPed) then
                return
            end
            local groupHash = GetPedRelationshipGroupHash(targetPed)
            print("^2GetGroup - Group Hash: " .. groupHash .. "^7")
        end,
        distance = 2.5,
        canInteract = function(entity)
            return GetGroupEnabled and entity ~= 0 and DoesEntityExist(entity) and not IsPedAPlayer(entity)
        end
    })
end

function removeTargets()
    exports.ox_target:removeGlobalPed()
end
