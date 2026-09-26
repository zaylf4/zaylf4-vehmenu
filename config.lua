Config = {}

-- Chat command that opens the menu (the 'zaylf4-vehmenu:client:openmenu' event also still works)
Config.Command = 'vehmenu'

-- Default key for the command (players can rebind it in Settings > Key Bindings > FiveM). Set to '' for none.
Config.DefaultKey = 'F5'

-- Only allow the driver to use the menu
Config.DriverOnly = true

-- Only allow the menu in emergency class vehicles (VC_EMERGENCY / class 18)
Config.EmergencyOnly = true

-- ox_lib menu position: 'top-left', 'top-right', 'bottom-left' or 'bottom-right'
Config.MenuPosition = 'top-left'

-- Door index -> label. Only doors that actually exist on the vehicle are shown.
Config.Doors = {
    [0] = 'Front Left Door',
    [1] = 'Front Right Door',
    [2] = 'Rear Left Door',
    [3] = 'Rear Right Door',
    [4] = 'Hood',
    [5] = 'Trunk',
    [6] = 'Back Door',
    [7] = 'Back Door 2',
}

-- Plate designs available in the menu (index = SetVehicleNumberPlateTextIndex value)
Config.PlateTypes = {
    { index = 0, label = 'Blue on White' },
    { index = 1, label = 'Yellow on Black' },
    { index = 2, label = 'Yellow on Blue' },
    { index = 3, label = 'Blue on White 2' },
    { index = 4, label = 'SA Exempt' },
    { index = 5, label = 'North Yankton' },
    -- The plates below require sv_enforceGameBuild 3095 or newer
    -- { index = 6,  label = 'eCola' },
    -- { index = 7,  label = 'Las Venturas' },
    -- { index = 8,  label = 'Liberty City' },
    -- { index = 9,  label = 'LS Car Meet' },
    -- { index = 10, label = 'LS Panic' },
    -- { index = 11, label = 'LS Pounders' },
    -- { index = 12, label = 'Sprunk' },
}
