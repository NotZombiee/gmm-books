local bookProp = nil

local function PlayAnimation(dict, name, duration)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
    TaskPlayAnim(PlayerPedId(), dict, name, 1.0, -1.0, duration, 49, 1, false, false, false)
    RemoveAnimDict(dict)
end

local function HandleProp(action, ped, ped_coords, bookName, prop)
    if action == 'add' then
        local propName = nil
        if Config.Books[bookName]["prop"] == 'book' then
            propName = "prop_novel_01"
            bookProp = CreateObject(propName, ped_coords.x, ped_coords.y, ped_coords.z,  true,  true, true) 
            AttachEntityToEntity(bookProp, ped, GetPedBoneIndex(ped, 6286), 0.15, 0.03, -0.065, 0.0, 180.0, 90.0, true, true, false, true, 1, true)
        elseif Config.Books[bookName]["prop"] == 'map' then
            propName = "prop_tourist_map_01"
            bookProp = CreateObject(propName, ped_coords.x, ped_coords.y, ped_coords.z,  true,  true, true) 
            AttachEntityToEntity(bookProp, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        end
        SetModelAsNoLongerNeeded(propName)
        PlayAnimation('cellphone@', 'cellphone_text_read_base', 10000)
    elseif action == 'remove' then
        ClearPedSecondaryTask(ped)
        Wait(1000)
        SetEntityAsMissionEntity(prop)
        DeleteObject(prop)
        bookProp = nil
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        SetNuiFocus(false,false)
        SendNUIMessage({
            show = false
        })
        ClearPedSecondaryTask(PlayerPedId())
        SetEntityAsMissionEntity(bookProp)
        DeleteObject(bookProp)
    end
end)

-- Open book stuff 

RegisterNetEvent('gmm-books:client:OpenBook', function(bookName)
    local ped = PlayerPedId()
    local ped_coords = GetEntityCoords(ped)
    HandleProp('add', ped, ped_coords, bookName)
    SetNuiFocus(true,true)
    SendNUIMessage({
        show = true,
        book = bookName,
        pages = Config.Books[bookName]["pages"],
        size = Config.Books[bookName]["size"],
    })
end)

-- NUI Stuff 
RegisterNUICallback('escape', function(data, cb)
    local ped = PlayerPedId()
    HandleProp('remove', ped, false, nil, bookProp)
    SetNuiFocus(false, false)
    cb('ok')
end)


local hasInk = false

RegisterNetEvent('ox:openprinter')
AddEventHandler('ox:openprinter', function()
    
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
        }
    }

    lib.registerContext({
        id = 'printer_menu',
        title = 'Printer Options',
        options = options
    })


    lib.showContext('printer_menu')
end)


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
        lib.notify({ title = 'Printer', description = 'The printer is out of ink!', type = 'error' })
        return false
    end
    return true
end

-- Event to handle the input for printing a book
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
        -- After book title and pages, ask for image URLs for each page
        local pageInputs = {}
        for i = 1, numberOfPages do
            local pageInput = lib.inputDialog('Page ' .. i .. ' of ' .. bookTitle, {
                { type = 'input', label = 'Image URL for Page ' .. i, placeholder = 'Enter a PNG Image URL', pattern = 'https?://.*%.jpeg' }
            })
            
            -- If user cancels or enters invalid data
            if not pageInput or not pageInput[1] then
                lib.notify({ title = 'Printer', description = 'Image URL for Page ' .. i .. ' is required!', type = 'error' })
                return
            end

            local imageUrl = pageInput[1]

            -- Check if URL is a valid PNG image URL
            if not imageUrl:match('https?://.*%.jpeg') then
                lib.notify({ title = 'Printer', description = 'Invalid PNG URL for Page ' .. i, type = 'error' })
                return
            end

            -- Store the image URL for this page
            table.insert(pageInputs, imageUrl)
        end

        -- Proceed to "print" the book with all pages
        lib.notify({ title = 'Printer', description = 'Printing book: ' .. bookTitle, type = 'info' })
        -- Here you would normally trigger the printing logic with `bookTitle` and `pageInputs`
        -- For now, we just log the inputs
        print("Book Title: " .. bookTitle)
        for i, url in ipairs(pageInputs) do
            print("Page " .. i .. " Image URL: " .. url)
        end
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
            { type = 'input', label = 'PNG Image URL', placeholder = 'Enter a link to a image', pattern = 'https?://.*%.jpeg' }
        }
    elseif itemType == 'business_card' then
        dialogTitle = 'Business Card Printing'
        inputFields = {
            { type = 'input', label = 'Business Card Title', placeholder = 'Enter the card title' },
            { type = 'input', label = 'PNG Image URL', placeholder = 'Enter a link to a image', pattern = 'https?://.*%.jpeg' }
        }
    end

    local input = lib.inputDialog(dialogTitle, inputFields)

    if not input or not input[1] or not input[2] then
        return
    end

    local title = input[1]
    local pngUrl = input[2]

    if not pngUrl:match('https?://.*%.jpeg') then
        lib.notify({ title = 'Printer', description = 'Invalid URL! Please provide a valid link to a image.', type = 'error' })
        return
    end

    lib.notify({ title = 'Printer', description = 'Printing ' .. itemType .. ': ' .. title, type = 'info' })
end)