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