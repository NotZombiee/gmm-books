fx_version 'cerulean'
game 'gta5'

lua54 'yes'

ui_page 'html/index.html'

shared_scripts {
	'config.lua',
    '@ox_lib/init.lua',
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/cl_printer.lua',
    'client/cl_target.lua',
    'client/main.lua',
}

files {
    "html/*.html",
    "html/*.css",
    "html/*.js",
    'html/img/**/*.png',
}

escrow_ignore {
    'config.lua',
}