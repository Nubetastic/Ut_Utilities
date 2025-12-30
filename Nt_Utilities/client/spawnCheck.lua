
-- checks if player is in create character area and moves to valentine
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local badSpawn = vector3(-550.2263, -3777.9907, 238.5975)
    local moveTo = vector3(-171.6132, 625.8906, 114.0321)
    print("Checking spawn: " .. tostring(playerCoords))
    if #(playerCoords - badSpawn) < 200 then
        SetEntityCoords(playerPed, moveTo.x, moveTo.y, moveTo.z, 0, 0, 0, false)
    end
end)