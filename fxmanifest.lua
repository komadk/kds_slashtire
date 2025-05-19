fx_version 'cerulean'
game 'gta5'

author 'Komá @ Development'
description 'DK - Tire Slasher'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target'
}

lua54 'yes' 