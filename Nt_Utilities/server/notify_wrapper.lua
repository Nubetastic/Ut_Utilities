-- Server-side wrapper for client notifications
-- This replaces the old server-side queue system with a simple event trigger to the client

-- Simple function to trigger client notification
-- @param playerId: player ID to send notification to
-- @param itemName: string with item name
-- @param amount: number of items
-- @param type: string, type of notification ('add', 'remove', 'use') - MUST be specified
local function ItemNotify(playerId, itemName, amount, type)
    -- Validate parameters
    if not playerId or not itemName then return end
    if not type then
        print('Error: ItemNotify called without type parameter. Type must be specified (add, remove, or use).')
        return
    end
    
    -- Trigger client event to handle the notification
    TriggerClientEvent('rsg-inventory:client:ItemNotify', playerId, itemName, amount, type)
end

-- Export the function so it can be used from other server resources
exports('ItemNotify', ItemNotify)