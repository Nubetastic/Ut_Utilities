local RSGCore = exports['rsg-core']:GetCoreObject()

-- Client-side notification queue system
local notificationQueue = {}
local isProcessingQueue = false
local notificationDelay = 500 -- milliseconds between notifications (adjust as needed)

-- Process the notification queue
local function ProcessNotificationQueue()
    if #notificationQueue == 0 then
        isProcessingQueue = false
        return
    end
    
    isProcessingQueue = true
    
    -- Get the next notification in the queue
    local nextNotification = table.remove(notificationQueue, 1)
    local itemName, amount, type = nextNotification.itemName, nextNotification.amount, nextNotification.type
    
    -- Get item data from shared items
    local itemData = RSGCore.Shared.Items[itemName:lower()]
    if not itemData then
        print('Error: Item not found: ' .. itemName)
    else
        -- Trigger the existing ItemBox event to show the notification
        TriggerEvent('rsg-inventory:client:ItemBox', itemData, type, amount)
    end
    
    -- Schedule the next notification after delay
    SetTimeout(notificationDelay, ProcessNotificationQueue)
end

-- Add an item notification to the queue
-- @param itemName: string with item name
-- @param amount: number of items
-- @param type: string, type of notification ('add', 'remove', 'use') - MUST be specified
local function ItemNotify(itemName, amount, type)
    -- Validate parameters
    if not itemName then return end
    if not type then
        print('Error: ItemNotify called without type parameter. Type must be specified (add, remove, or use).')
        return
    end
    
    -- Add notification to the queue
    table.insert(notificationQueue, {
        itemName = itemName,
        amount = amount,
        type = type
    })
    
    -- Start processing the queue if not already processing
    if not isProcessingQueue then
        ProcessNotificationQueue()
    end
end

-- Register event for server to trigger client notification
RegisterNetEvent('rsg-inventory:client:ItemNotify')
AddEventHandler('rsg-inventory:client:ItemNotify', function(itemName, amount, type)
    ItemNotify(itemName, amount, type)
end)

-- Export the function so it can be used from other client resources
exports('ItemNotify', ItemNotify)