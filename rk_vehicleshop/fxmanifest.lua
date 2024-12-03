fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Vehicle Dealership'
version '1.0.0'
author 'RK Scripts'

dependencies {
    'es_extended',
    'ox_lib',
    'mysql-async'
}

shared_scripts {
    '@es_extended/locale.lua',
    'config/config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/showroom.lua',
    'client/cardealer.lua',
    'client/carpoint.lua',
    'client/boss.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua',
    'server/boss.lua'
}
