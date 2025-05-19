Config = {}

-- Debug mode
Config.Debug = false

-- Framework (only ESX supported for now)
Config.Framework = 'esx'

-- Weapons that can be used to slash tires
Config.AllowedWeapons = {
    'WEAPON_KNIFE',
    'WEAPON_SWITCHBLADE',
    'WEAPON_DAGGER',
    'WEAPON_BOTTLE',
    'WEAPON_MACHETE'
}

-- Tire slash settings
Config.SlashSettings = {
    Range = 1.5,        -- Distance at which player can target tires
    ForceNeeded = 0.5,  -- Force of the slash (0.0 - 1.0) - higher value = more noticeable deflation
    Duration = 1000,    -- Duration of slashing animation in milliseconds (changed to 1.5 seconds)
    Cooldown = 2000,    -- Cooldown between slashes in milliseconds
    
    -- Chance for slash to alert police (percentage)
    PoliceAlertChance = 0, -- Set to 0 to disable police alerts
    
    -- Damage settings (use damage with durability or health system)
    ApplyDamage = true,
    DamageAmount = 50,  -- Vehicle damage applied per tire slash
    
    -- Allow slash detection by others
    NotifyNearbyPlayers = false, -- Disabled nearby player notifications
    NotifyRadius = 20.0 -- Radius to notify nearby players of slashing
}

-- Animation and effects
Config.Animation = {
    Dict = "melee@knife@streamed_core",
    Name = "ground_attack_on_spot",
    Flag = 48,        -- Animation flag
    BlendInSpeed = 8.0,
    BlendOutSpeed = 8.0,
    PlaybackRate = 1.0,
    LoopDuration = 2.0 -- How long to loop animation
}

-- Vehicle restriction settings
Config.VehicleRestrictions = {
    IgnoreEmergencyVehicles = true,  -- Don't allow slashing police/ambulance/fire tires
    IgnoreOwnedVehicles = false,     -- Set to true to prevent slashing your own vehicle
    MaxSpeed = 5.0                   -- Maximum speed a vehicle can be moving to slash tires
}

-- Sound effects
Config.SoundEffects = {
    Enabled = true,
    Name = "weapons_player_knife_hit", -- Default slash sound
    SetName = 0,            -- Sound set name, 0 for default
    Volume = 1.0,           -- Sound volume
    Distance = 5.0          -- How far the sound can be heard
}

-- Notifications
Config.Notifications = {
    TireSlashed = {
        title = "Tire Slashed",
        description = "You've slashed the vehicle's tire",
        type = "success"
    },
    AlreadySlashed = {
        title = "Already Slashed",
        description = "This tire is already slashed",
        type = "error"
    },
    WrongWeapon = {
        title = "Wrong Weapon",
        description = "You need a knife to slash tires",
        type = "error"
    },
    VehicleRestricted = {
        title = "Vehicle Protected",
        description = "You cannot slash this vehicle's tires",
        type = "error"
    },
    VehicleMoving = {
        title = "Vehicle Moving",
        description = "The vehicle is moving too fast",
        type = "error"
    },
    NearbySlash = {
        title = "Suspicious Activity",
        description = "Someone is slashing tires nearby",
        type = "inform"
    }
} 