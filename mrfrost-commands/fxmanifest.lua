fx_version 'cerulean'
game 'gta5'

description 'MrFrost Commands'

author 'MrFrost'

version '1.0.0'

shared_scripts {
  '@qb-core/shared/locale.lua',
  'locales/en.lua',
  'locales/*.lua',
  'config.lua'
}


server_scripts {
  'server/server.lua'
}

client_scripts {
  'client/client.lua'
}

dependencies {
  'qb-core'
}

lua54 'yes'
