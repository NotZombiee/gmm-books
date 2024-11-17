-- Register the client event to open the ox context menu
RegisterNetEvent('ox:openprinter')
AddEventHandler('ox:openprinter', function()
    -- Define your menu options
    local options = {
        {
            title = 'Print Document',
            description = 'Print a document from the printer',
            icon = 'fa-solid fa-print', -- icon for the menu item
            event = 'printer:printDocument' -- example event when this option is selected
        },
        {
            title = 'Check Ink Level',
            description = 'Check the ink level of the printer',
            icon = 'fa-solid fa-tint',
            event = 'printer:checkInk'
        },
        {
            title = 'Exit',
            icon = 'fa-solid fa-times',
            close = true -- closes the menu when clicked
        }
    }

    -- Open the ox context menu
    lib.registerContext({
        id = 'printer_menu',
        title = 'Printer Options',
        options = options
    })

    -- Open the registered context menu
    lib.showContext('printer_menu')
end)

exports.ox_target:addBoxZone({

    coords = vec3(),
    size = vec3(2, 2, 2),
    rotation = 45,
    options = {
        {
            name = "bookprinter",
            icon = "fa-solid fa-book",
            label = "Open Printer",
            event = "ox:openprinter",
        }
    }
})