RegisterServerEvent('Nt_Utilities:Server:ReloadPlayerBucket')
AddEventHandler('Nt_Utilities:Server:ReloadPlayerBucket', function()
    local serverId = source
    
    local originalBucket = GetPlayerRoutingBucket(serverId)
    local tempBucket = originalBucket + 9000
    
    SetPlayerRoutingBucket(serverId, tempBucket)
    
    SetTimeout(500, function()
        SetPlayerRoutingBucket(serverId, originalBucket)
    end)
end)