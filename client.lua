local ESX = nil
local isBusy = false
local cooldown = false

-- Framework initialization
CreateThread(function()
    if Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
    
    InitializeTargetZones()
end)

-- Debug function
local function Debug(msg)
    if Config.Debug then
        print('[koma_slashtire] ' .. msg)
    end
end

-- Initialize the target zones for vehicle tires
function InitializeTargetZones()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'koma_slashtire:frontLeft',
            icon = 'fas fa-circle-xmark',
            label = 'Slash Front Left Tire',
            canInteract = function(entity, distance, coords, name)
                return CanSlashTire(entity, 0) -- 0 = front left tire
            end,
            onSelect = function(data)
                SlashTire(data.entity, 0) -- 0 = front left tire
            end,
            distance = Config.SlashSettings.Range,
            bones = {'wheel_lf'},
        },
        {
            name = 'koma_slashtire:frontRight',
            icon = 'fas fa-circle-xmark',
            label = 'Slash Front Right Tire',
            canInteract = function(entity, distance, coords, name)
                return CanSlashTire(entity, 1) -- 1 = front right tire
            end,
            onSelect = function(data)
                SlashTire(data.entity, 1) -- 1 = front right tire
            end,
            distance = Config.SlashSettings.Range,
            bones = {'wheel_rf'},
        },
        {
            name = 'koma_slashtire:backLeft',
            icon = 'fas fa-circle-xmark',
            label = 'Slash Back Left Tire',
            canInteract = function(entity, distance, coords, name)
                return CanSlashTire(entity, 4) -- 4 = back left tire
            end,
            onSelect = function(data)
                SlashTire(data.entity, 4) -- 4 = back left tire
            end,
            distance = Config.SlashSettings.Range,
            bones = {'wheel_lr'},
        },
        {
            name = 'koma_slashtire:backRight',
            icon = 'fas fa-circle-xmark',
            label = 'Slash Back Right Tire',
            canInteract = function(entity, distance, coords, name)
                return CanSlashTire(entity, 5) -- 5 = back right tire
            end,
            onSelect = function(data)
                SlashTire(data.entity, 5) -- 5 = back right tire
            end,
            distance = Config.SlashSettings.Range,
            bones = {'wheel_rr'},
        }
    })
    
    Debug('Target zones initialized')
end

-- Check if player can slash the specified tire
function CanSlashTire(vehicle, tireIndex)
    -- Check if player has the right weapon
    if not HasValidWeapon() then
        return false
    end
    
    -- Check if player is busy
    if isBusy or cooldown then
        return false
    end
    
    -- Check if vehicle is moving too fast
    local speed = GetEntitySpeed(vehicle)
    if speed > Config.VehicleRestrictions.MaxSpeed then
        return false
    end
    
    -- Check if vehicle is emergency and restricted
    if Config.VehicleRestrictions.IgnoreEmergencyVehicles then
        local vehicleClass = GetVehicleClass(vehicle)
        -- Vehicle class 18 is emergency vehicles (police, ambulance, etc.)
        if vehicleClass == 18 then
            return false
        end
    end
    
    -- Check if tire is already burst
    if IsVehicleTyreBurst(vehicle, tireIndex, true) then
        return false
    end
    
    return true
end

-- Check if player has a valid weapon equipped
function HasValidWeapon()
    local playerPed = PlayerPedId()
    local weapon = GetSelectedPedWeapon(playerPed)
    
    -- Convert weapon hash to string for comparison
    for _, validWeapon in ipairs(Config.AllowedWeapons) do
        if weapon == GetHashKey(validWeapon) then
            return true
        end
    end
    
    return false
end

-- Slash a specific tire on the vehicle
function SlashTire(vehicle, tireIndex)
    -- Double check can slash tire
    if not CanSlashTire(vehicle, tireIndex) then
        return
    end
    
    -- Check if tire is already burst
    if IsVehicleTyreBurst(vehicle, tireIndex, true) then
        lib.notify(Config.Notifications.AlreadySlashed)
        return
    end
    
    -- Set busy flag
    isBusy = true
    
    -- Get tire position for animation
    local boneIndex = -1
    if tireIndex == 0 then boneIndex = GetEntityBoneIndexByName(vehicle, 'wheel_lf') -- Front Left
    elseif tireIndex == 1 then boneIndex = GetEntityBoneIndexByName(vehicle, 'wheel_rf') -- Front Right
    elseif tireIndex == 4 then boneIndex = GetEntityBoneIndexByName(vehicle, 'wheel_lr') -- Back Left
    elseif tireIndex == 5 then boneIndex = GetEntityBoneIndexByName(vehicle, 'wheel_rr') -- Back Right
    end
    
    -- Get tire position
    local tirePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    
    -- Play slash animation
    local animDict = Config.Animation.Dict
    local animName = Config.Animation.Name
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
    
    -- Get the animation duration
    local duration = Config.SlashSettings.Duration
    
    -- Use progress circle instead of progress bar
    local success = lib.progressCircle({
        duration = duration,
        position = 'bottom',
        label = 'Slashing tire...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = animDict,
            clip = animName,
            flag = Config.Animation.Flag
        }
    })
    
    if success then
        -- Burst the tire
        SetVehicleTyreBurst(vehicle, tireIndex, true, Config.SlashSettings.ForceNeeded)
        
        -- Play audio
        if Config.SoundEffects.Enabled then
            PlaySoundFromEntity(-1, Config.SoundEffects.Name, vehicle, Config.SoundEffects.SetName, false, Config.SoundEffects.Distance)
        end
        
        -- Apply vehicle damage if enabled
        if Config.SlashSettings.ApplyDamage then
            local currentHealth = GetVehicleBodyHealth(vehicle)
            SetVehicleBodyHealth(vehicle, currentHealth - Config.SlashSettings.DamageAmount)
        end
        
        -- Notify player of success
        lib.notify(Config.Notifications.TireSlashed)
        
        -- Only notify nearby players if enabled in config
        if Config.SlashSettings.NotifyNearbyPlayers then
            TriggerServerEvent('koma_slashtire:notifyNearbyPlayers', GetEntityCoords(PlayerPedId()))
        end
        
        -- Only alert police if chance is greater than 0
        if Config.SlashSettings.PoliceAlertChance > 0 and math.random(100) <= Config.SlashSettings.PoliceAlertChance then
            AlertPolice(vehicle)
        end
    end
    
    -- Reset animation dictionary
    RemoveAnimDict(animDict)
    
    -- Reset busy flag
    isBusy = false
    
    -- Set cooldown
    cooldown = true
    SetTimeout(Config.SlashSettings.Cooldown, function()
        cooldown = false
    end)
end

-- Alert police about tire slashing
function AlertPolice(vehicle)
    local coords = GetEntityCoords(vehicle or PlayerPedId())
    TriggerServerEvent('koma_slashtire:alertPolice', coords)
end

-- Event to display notification about nearby tire slashing
RegisterNetEvent('koma_slashtire:notifyNearby')
AddEventHandler('koma_slashtire:notifyNearby', function()
    lib.notify(Config.Notifications.NearbySlash)
end)

-- Event to receive police alert and create blip
RegisterNetEvent('koma_slashtire:policeAlert')
AddEventHandler('koma_slashtire:policeAlert', function(coords)
    -- Create a blip at the location
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 40.0)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, 1) -- Red
    SetBlipAlpha(blip, 128)
    
    -- Create a marker blip in the center
    local centerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(centerBlip, 229) -- Vandalism icon
    SetBlipColour(centerBlip, 1) -- Red
    SetBlipAsShortRange(centerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Reported Vandalism")
    EndTextCommandSetBlipName(centerBlip)
    
    -- Remove blips after 60 seconds
    SetTimeout(60000, function()
        RemoveBlip(blip)
        RemoveBlip(centerBlip)
    end)
end) 