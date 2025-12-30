
--[[
local blip = exports['Nt_Utilities']:CreateBlip(ped/coords, blipSprite, blipColor, blipScale, blipName)
--]]

exports('CreateBlip', function(data, blipSprite, blipColor, blipScale, blipName)
    if not data then
        return nil
    end

    local blip
    local isEntity = type(data) == 'number' and DoesEntityExist(data)

    if isEntity then
        blip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, 1664425300, data)
        Citizen.InvokeNative(0xE37287EE358939C3, data)
    else
        local coordsType = type(data)
        local x, y, z

        if coordsType == 'vector4' then
            data = vector3(data.x, data.y, data.z)
            coordsType = 'vector3'
        end

        if coordsType == 'vector3' then
            x, y, z = data.x, data.y, data.z
        elseif coordsType == 'table' then
            x = data.x or data[1]
            y = data.y or data[2]
            z = data.z or data[3]
        end

        if not (x and y and z) then
            return nil
        end

        blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x + 0.0, y + 0.0, z + 0.0)
    end
    local spriteHash = GetHashKey(blipSprite)
    SetBlipSprite(blip, spriteHash)

    Citizen.InvokeNative(0x9CB1A1623062F402, blip, blipName)

    local colorHash = GetHashKey(blipColor)
    Citizen.InvokeNative(0x662D364ABF16DE2F, blip, colorHash)

    Citizen.InvokeNative(0xD38744167B2FA257, blip, blipScale)

    return blip
end)
