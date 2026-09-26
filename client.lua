local vehicle = 0
local watching = false
local submenus = {}

local EMERGENCY_CLASS = 18

-- Returns the vehicle the menu can be used in, or nil plus the reason it can't
local function getVehicle()
    local veh = cache.vehicle
    if not veh then return nil, 'You must be in a vehicle.' end
    if Config.DriverOnly and cache.seat ~= -1 then return nil, 'You must be the driver of the vehicle.' end
    if Config.EmergencyOnly and GetVehicleClass(veh) ~= EMERGENCY_CLASS then
        return nil, 'This menu can only be used in emergency vehicles.'
    end
    return veh
end

-- Returns the translated text for a GXT label, or the fallback when it has none
local function labelOr(textKey, fallback)
    if textKey and textKey ~= '' then
        local text = GetLabelText(textKey)
        if text and text ~= 'NULL' then return text end
    end
    return fallback
end

-- Game controls that share keys with menu navigation (arrows, enter, backspace, scroll wheel):
-- phone, cellphone navigation, weapon wheel scrolling and vehicle weapon select
local blockedControls = { 14, 15, 16, 17, 27, 99, 100, 115, 116, 172, 173, 174, 175, 176, 177 }

-- While the menu is open: blocks conflicting controls, and closes the menu
-- if the player leaves the vehicle (or the driver seat)
local function watchVehicle()
    if watching then return end
    watching = true

    CreateThread(function()
        while true do
            local openId = lib.getOpenMenu()
            if not openId or not openId:find('^vi_') then break end
            if getVehicle() ~= vehicle then
                lib.hideMenu(false)
                break
            end

            for i = 1, #blockedControls do
                DisableControlAction(0, blockedControls[i], true)
            end

            Wait(0)
        end
        watching = false
    end)
end

-- ox_lib's menu UI tracks the highlighted row by the rows it has rendered, and that
-- breaks when a menu is re-shown while it is still open (the highlight gets stuck).
-- So to refresh a menu it is closed first, then reopened once the UI has cleared it.
local function reopenMenu(show, ...)
    local args = { ... }
    lib.hideMenu(false)

    CreateThread(function()
        Wait(50)
        if getVehicle() ~= vehicle then return end
        show(table.unpack(args))
        watchVehicle()
    end)
end

local function openMainMenu()
    lib.showMenu('vi_main')
end

-- Doors -----------------------------------------------------------------------

local function hasBombBay(veh)
    return IsThisModelAPlane(GetEntityModel(veh)) and GetEntityBoneIndexByName(veh, 'door_hatch_l') ~= -1
end

local function isDoorOpen(veh, door)
    return GetVehicleDoorAngleRatio(veh, door) > 0.0
end

local function setDoor(veh, door, open)
    if open then
        SetVehicleDoorOpen(veh, door, false, false)
    else
        SetVehicleDoorShut(veh, door, false)
    end
end

local function setBombBay(veh, open)
    if open then
        OpenBombBayDoors(veh)
    else
        CloseBombBayDoors(veh)
    end
end

-- forceState overrides the read-back door state, since doors that were just
-- opened/closed are still animating and report their old angle
function submenus.doors(startIndex, forceState)
    local options = {}

    for door = 0, 7 do
        if Config.Doors[door] and GetIsDoorValid(vehicle, door) then
            local open = forceState
            if open == nil then open = isDoorOpen(vehicle, door) end
            options[#options + 1] = { label = Config.Doors[door], checked = open, args = { door = door } }
        end
    end

    if hasBombBay(vehicle) then
        local open = forceState
        if open == nil then open = AreBombBayDoorsOpen(vehicle) end
        options[#options + 1] = { label = 'Bomb Bay', checked = open, args = { bombBay = true } }
    end

    if #options == 0 then
        options[1] = { label = 'No doors found', close = false }
    else
        table.insert(options, 1, {
            label = 'Toggle All Doors',
            icon = 'car-side',
            description = 'Closes every door if any is open, otherwise opens them all',
            close = false,
            args = { toggleAll = true },
        })
    end

    lib.registerMenu({
        id = 'vi_doors',
        title = 'Doors',
        position = Config.MenuPosition,
        options = options,
        onCheck = function(_, checked, args)
            if args.door then
                setDoor(vehicle, args.door, checked)
            elseif args.bombBay then
                setBombBay(vehicle, checked)
            end
        end,
        onClose = openMainMenu,
    }, function(selected, _, args)
        if not args or not args.toggleAll then return end

        -- The checkboxes hold the current state (including doors still mid-animation)
        local anyOpen = false
        for _, option in ipairs(options) do
            if option.checked then anyOpen = true break end
        end
        local open = not anyOpen

        for door = 0, 7 do
            if GetIsDoorValid(vehicle, door) then setDoor(vehicle, door, open) end
        end
        if hasBombBay(vehicle) then setBombBay(vehicle, open) end

        reopenMenu(submenus.doors, selected, open)
    end)

    lib.showMenu('vi_doors', startIndex)
end

-- Liveries --------------------------------------------------------------------

function submenus.liveries()
    local options = {}

    local liveryCount = GetVehicleLiveryCount(vehicle)
    if liveryCount > 0 then
        local values = {}
        for i = 0, liveryCount - 1 do
            values[i + 1] = labelOr(GetLiveryName(vehicle, i), ('Livery %d'):format(i + 1))
        end
        options[#options + 1] = {
            label = 'Livery',
            values = values,
            defaultIndex = math.max(GetVehicleLivery(vehicle), 0) + 1,
            close = false,
            args = { type = 'livery' },
        }
    end

    -- Many add-on vehicles use the mod kit livery slot (48) instead of native liveries
    SetVehicleModKit(vehicle, 0)
    local modCount = GetNumVehicleMods(vehicle, 48)
    if modCount > 0 then
        local values = { 'Stock' }
        for i = 0, modCount - 1 do
            values[i + 2] = labelOr(GetModTextLabel(vehicle, 48, i), ('Livery %d'):format(i + 1))
        end
        options[#options + 1] = {
            label = 'Livery (Mod Kit)',
            values = values,
            defaultIndex = GetVehicleMod(vehicle, 48) + 2,
            close = false,
            args = { type = 'mod' },
        }
    end

    local roofCount = GetVehicleRoofLiveryCount(vehicle)
    if roofCount > 0 then
        local values = {}
        for i = 0, roofCount - 1 do
            values[i + 1] = ('Roof Livery %d'):format(i + 1)
        end
        options[#options + 1] = {
            label = 'Roof Livery',
            values = values,
            defaultIndex = math.max(GetVehicleRoofLivery(vehicle), 0) + 1,
            close = false,
            args = { type = 'roof' },
        }
    end

    if #options == 0 then
        options[1] = { label = 'No liveries found', close = false }
    end

    lib.registerMenu({
        id = 'vi_liveries',
        title = 'Liveries',
        position = Config.MenuPosition,
        options = options,
        onSideScroll = function(_, scrollIndex, args)
            if args.type == 'livery' then
                SetVehicleLivery(vehicle, scrollIndex - 1)
            elseif args.type == 'mod' then
                SetVehicleModKit(vehicle, 0)
                SetVehicleMod(vehicle, 48, scrollIndex - 2, false)
            elseif args.type == 'roof' then
                SetVehicleRoofLivery(vehicle, scrollIndex - 1)
            end
        end,
        onClose = openMainMenu,
    })

    lib.showMenu('vi_liveries')
end

-- Extras ----------------------------------------------------------------------

local function isExtraOn(id)
    local on = IsVehicleExtraTurnedOn(vehicle, id)
    return on == true or on == 1
end

function submenus.extras(startIndex)
    local options = {}

    for id = 0, 20 do
        if DoesExtraExist(vehicle, id) then
            options[#options + 1] = {
                label = ('Extra %d'):format(id),
                checked = isExtraOn(id),
                args = { extra = id },
            }
        end
    end

    if #options == 0 then
        options[1] = { label = 'No extras found', close = false }
    end

    lib.registerMenu({
        id = 'vi_extras',
        title = 'Extras',
        position = Config.MenuPosition,
        options = options,
        onCheck = function(selected, checked, args)
            SetVehicleExtra(vehicle, args.extra, not checked)
            options[selected].checked = checked

            -- Some extras replace each other; only refresh the menu when another one changed
            CreateThread(function()
                Wait(100)
                if lib.getOpenMenu() ~= 'vi_extras' then return end
                for _, option in ipairs(options) do
                    if isExtraOn(option.args.extra) ~= option.checked then
                        return reopenMenu(submenus.extras, selected)
                    end
                end
            end)
        end,
        onClose = openMainMenu,
    })

    lib.showMenu('vi_extras', startIndex)
end

-- Plates ----------------------------------------------------------------------

function submenus.plates()
    local current = GetVehicleNumberPlateTextIndex(vehicle)
    local values, defaultIndex = {}, 1

    for i, plate in ipairs(Config.PlateTypes) do
        values[i] = plate.label
        if plate.index == current then defaultIndex = i end
    end

    lib.registerMenu({
        id = 'vi_plates',
        title = 'Plates',
        position = Config.MenuPosition,
        options = {
            { label = 'Plate Design', values = values, defaultIndex = defaultIndex, close = false },
        },
        onSideScroll = function(_, scrollIndex)
            SetVehicleNumberPlateTextIndex(vehicle, Config.PlateTypes[scrollIndex].index)
        end,
        onClose = openMainMenu,
    })

    lib.showMenu('vi_plates')
end

-- Main menu -------------------------------------------------------------------

lib.registerMenu({
    id = 'vi_main',
    title = 'Vehicle Interactions',
    position = Config.MenuPosition,
    options = {
        { label = 'Doors', icon = 'door-open', description = 'Open or close individual doors', args = 'doors' },
        { label = 'Liveries', icon = 'paint-roller', description = 'Change the vehicle livery', args = 'liveries' },
        { label = 'Extras', icon = 'toggle-on', description = 'Enable or disable vehicle extras', args = 'extras' },
        { label = 'Plates', icon = 'id-card', description = 'Change the plate design', args = 'plates' },
    },
}, function(_, _, args)
    submenus[args]()
end)

local function openMenu()
    local veh, reason = getVehicle()
    if not veh then
        lib.notify({ type = 'error', description = reason })
        return
    end

    vehicle = veh
    openMainMenu()
    watchVehicle()
end

RegisterNetEvent('zaylf4-vehmenu:client:openmenu', openMenu)
RegisterCommand(Config.Command, openMenu, false)

if Config.DefaultKey ~= '' then
    RegisterKeyMapping(Config.Command, 'Open vehicle interaction menu', 'keyboard', Config.DefaultKey)
end
