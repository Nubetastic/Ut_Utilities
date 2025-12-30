
-- Scans for players within a specified radius from given coordinates and returns Id's
--[[
local playerList = exports['Nt_Utilities']:ScanForPlayersInRadius(Coords, Radius)
--]]
exports('ScanForPlayersInRadius', function(Coords, Radius)
    local players = GetActivePlayers()
    local playersFound = {}
    
    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)

        if #(playerCoords - Coords) <= Radius then
            table.insert(playersFound, {
                id = playerId,
                serverId = GetPlayerServerId(playerId),
                ped = playerPed,
            })
        end
    end
    return playersFound
end)

