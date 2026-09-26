fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '2.0.0'

dependency 'ox_lib'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua'
}

client_script 'client.lua'
