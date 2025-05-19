local ESX = nil

-- Framework initialization
if Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- Debug function
local function Debug(msg)
    if Config.Debug then
        print('[koma_slashtire] ' .. msg)
    end
end

-- Register callback when script starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Debug('Server script started')
end)

-- Notify nearby players of tire slashing
RegisterNetEvent('koma_slashtire:notifyNearbyPlayers')
AddEventHandler('koma_slashtire:notifyNearbyPlayers', function(coords)
    local source = source
    local xPlayers = ESX.GetPlayers()
    local notified = 0
    
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
        if xPlayer and xPlayers[i] ~= source then
            local playerCoords = GetEntityCoords(GetPlayerPed(xPlayers[i]))
            local distance = #(vector3(coords.x, coords.y, coords.z) - playerCoords)
            
            -- Notify if within range
            if distance <= Config.SlashSettings.NotifyRadius then
                TriggerClientEvent('koma_slashtire:notifyNearby', xPlayers[i])
                notified = notified + 1
            end
        end
    end
    
    Debug('Notified ' .. notified .. ' players about tire slashing')
end)

-- Alert police
RegisterNetEvent('koma_slashtire:alertPolice')
AddEventHandler('koma_slashtire:alertPolice', function(coords)
    local source = source
    
    -- Get all police officers
    local xPlayers = ESX.GetPlayers()
    local policePlayers = {}
    
    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
        if xPlayer and xPlayer.job.name == 'police' then
            table.insert(policePlayers, xPlayers[i])
        end
    end
    
    -- Alert all police officers
    if #policePlayers > 0 then
        for i = 1, #policePlayers do
            TriggerClientEvent('ox_lib:notify', policePlayers[i], {
                title = 'Police Alert',
                description = 'Vehicle vandalism reported',
                type = 'inform'
            })
            
            -- Send the police a blip at the location
            TriggerClientEvent('koma_slashtire:policeAlert', policePlayers[i], coords)
        end
        
        Debug('Alerted ' .. #policePlayers .. ' police officers about tire slashing')
    end
end)

-- Register commands
RegisterCommand('debugslashtire', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and (xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin') then
        Config.Debug = not Config.Debug
        
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Debug Mode',
            description = Config.Debug and 'Debug mode enabled' or 'Debug mode disabled',
            type = 'inform'
        })
        
        Debug('Debug mode ' .. (Config.Debug and 'enabled' or 'disabled') .. ' by admin ' .. source)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Access Denied',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
    end
end, false) 