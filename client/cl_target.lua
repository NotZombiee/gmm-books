-- Track ink status (true if ink is available, false if not)
local hasInk = false

-- Register the client event to open the ox context menu
RegisterNetEvent('ox:openprinter')
AddEventHandler('ox:openprinter', function()
    -- Define your main printer menu options
    local options = {
        {
            title = 'Print Document',
            description = 'Print a document from the printer',
            icon = 'fa-solid fa-print',
            event = 'printer:openPrintMenu'
        },
        {
            title = 'Check Ink Level',
            description = 'Check the ink level of the printer',
            icon = 'fa-solid fa-tint',
            event = 'printer:checkInk'
        },
        {
            title = 'Add Ink',
            description = 'Insert an ink cartridge into the printer',
            icon = 'fa-solid fa-fill-drip',
            event = 'printer:addInk'
        },
        {
            title = 'Exit',
            icon = 'fa-solid fa-times',
            close = true
        }
    }

    -- Register the main printer menu context
    lib.registerContext({
        id = 'printer_menu',
        title = 'Printer Options',
        options = options
    })

    -- Open the registered context menu
    lib.showContext('printer_menu')
end)

-- Register a second event to handle the print document submenu
RegisterNetEvent('printer:openPrintMenu')
AddEventHandler('printer:openPrintMenu', function()
    -- Define your print document options
    local printOptions = {
        {
            title = 'Books',
            description = 'Print a book',
            icon = 'fa-solid fa-book',
            event = 'printer:printBook'
        },
        {
            title = 'Flyers',
            description = 'Print flyers',
            icon = 'fa-solid fa-file-alt',
            event = 'printer:printItem',
            args = 'flyer'
        },
        {
            title = 'Business Cards',
            description = 'Print business cards',
            icon = 'fa-solid fa-id-card',
            event = 'printer:printItem',
            args = 'business_card'
        },
        {
            title = 'Back',
            icon = 'fa-solid fa-arrow-left',
            event = 'ox:openprinter'
        }
    }

    -- Register the print document menu context
    lib.registerContext({
        id = 'print_document_menu',
        title = 'Choose Document Type',
        options = printOptions
    })

    -- Open the registered print document context menu
    lib.showContext('print_document_menu')
end)

-- Event to check the ink level of the printer
RegisterNetEvent('printer:checkInk')
AddEventHandler('printer:checkInk', function()
    if hasInk then
        lib.notify({ title = 'Printer', description = 'Ink level is sufficient.', type = 'success' })
    else
        lib.notify({ title = 'Printer', description = 'The printer is out of ink!', type = 'error' })
    end
end)

-- Event to add ink to the printer
RegisterNetEvent('printer:addInk')
AddEventHandler('printer:addInk', function()
    -- Trigger the server event to add ink
    TriggerServerEvent('printer:addInkServer')
end)

-- Function to handle printing with ink check
local function canPrint()
    if not hasInk then
        lib.notify({ title = 'Printer', description = 'Cannot print. The printer is out of ink!', type = 'error' })
        return false
    end
    return true
end

-- Event to handle the input for printing a book
RegisterNetEvent('printer:printBook')
AddEventHandler('printer:printBook', function()
    if not canPrint() then return end -- Check ink before printing

    -- Show an input dialog for book details
    local input = lib.inputDialog('Book Printing', {
        { type = 'input', label = 'Book Title', placeholder = 'Enter the book title' },
        { type = 'number', label = 'Number of Pages', placeholder = 'Enter the number of pages' }
    })

    if not input or not input[1] or not input[2] then
        return
    end

    local bookTitle = input[1]
    local numberOfPages = tonumber(input[2])

    if numberOfPages and numberOfPages > 0 then
        lib.notify({ title = 'Printer', description = 'Printing book: ' .. bookTitle, type = 'info' })
    else
        lib.notify({ title = 'Printer', description = 'Invalid number of pages!', type = 'error' })
    end
end)

-- Event to handle input for Flyers and Business Cards
RegisterNetEvent('printer:printItem')
AddEventHandler('printer:printItem', function(itemType)
    if not canPrint() then return end -- Check ink before printing

    local dialogTitle = ''
    local inputFields = {}

    if itemType == 'flyer' then
        dialogTitle = 'Flyer Printing'
        inputFields = {
            { type = 'input', label = 'Flyer Title', placeholder = 'Enter the flyer title' },
            { type = 'input', label = 'PNG Image URL', placeholder = 'Enter a link to a PNG image', pattern = 'https?://.*%.png' }
        }
    elseif itemType == 'business_card' then
        dialogTitle = 'Business Card Printing'
        inputFields = {
            { type = 'input', label = 'Business Card Title', placeholder = 'Enter the card title' },
            { type = 'input', label = 'PNG Image URL', placeholder = 'Enter a link to a PNG image', pattern = 'https?://.*%.png' }
        }
    end

    local input = lib.inputDialog(dialogTitle, inputFields)

    if not input or not input[1] or not input[2] then
        return
    end

    local title = input[1]
    local pngUrl = input[2]

    if not pngUrl:match('https?://.*%.png') then
        lib.notify({ title = 'Printer', description = 'Invalid PNG URL! Please provide a valid link to a PNG image.', type = 'error' })
        return
    end

    lib.notify({ title = 'Printer', description = 'Printing ' .. itemType .. ': ' .. title, type = 'info' })
end)


exports.ox_target:addBoxZone({

    coords = vec3(-1052.99, -230.89, 44.5),
    size = vec3(1, 1, 1),
    rotation = 25,
    debug = true,
    options = {
        {
            name = "bookprinter",
            icon = "fa-solid fa-book",
            label = "Open Printer",
            event = "ox:openprinter",
        }
    }
})