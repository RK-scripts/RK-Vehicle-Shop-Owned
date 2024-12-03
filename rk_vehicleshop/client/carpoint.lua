local ESX = nil
local selectedSpotCoords = nil
local selectedSpotHeading = nil
local spawnedVehicles = {}

local vehicles = Config.Vehicles
local spots = Config.Spots
local SpotsCar = Config.SpotsCar

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
    print("ESX loaded successfully")
end)

Citizen.CreateThread(function()
    if Config.InteractionType == 'ox_target' then
        local zoneId = exports.ox_target:addBoxZone({
            coords = vector3(Config.SpotsCar.x, Config.SpotsCar.y, Config.SpotsCar.z),
            name = "carpoint_interaction",
            size = vector3(2, 2, 2),
            rotation = 45,
            debug = false,
            drawSprite = true,
            options = {
                {
                    event = "Rk_script:openspot",
                    icon = "fas fa-car",
                    label = Config.Locale.carpoint_catalog,
                },
            },
        })

        print("Zona creata con ID: " .. zoneId)

    elseif Config.InteractionType == 'ox_lib' then
        local zone = lib.zones.box({
            coords = vec3(Config.SpotsCar.x, Config.SpotsCar.y, Config.SpotsCar.z),
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            inside = function()
                lib.showTextUI(Config.Locale.carpoint_catalog)

                if IsControlJustReleased(0, 38) then
                    OpenSpotMenu()
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })

        Citizen.CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - vec3(Config.SpotsCar.x, Config.SpotsCar.y, Config.SpotsCar.z))

                if distance < 10.0 then
                    DrawMarker(
                        Config.Marker.Type,
                        Config.SpotsCar.x, Config.SpotsCar.y, Config.SpotsCar.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.Marker.Size.x, Config.Marker.Size.y, Config.Marker.Size.z,
                        Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, Config.Marker.Color.a,
                        false,
                        false,
                        2,
                        nil, nil, false
                    )
                end

                Citizen.Wait(0)
            end
        end)
    end
end)

local function ShowNotification(msg, type)
    if Config.NotificationType == 'ox_lib' then
        lib.notify({type = type, description = msg})
    elseif Config.NotificationType == 'Custom' then
        TriggerEvent(Config.CustomNotificationTrigger, msg)
    elseif Config.NotificationType == 'es_extended' then
        ESX.ShowNotification(msg)
    else
        ESX.ShowNotification(msg)
    end
end

function OpenSpotMenu()
    local playerPed = PlayerPedId()
    local xPlayer = ESX.GetPlayerData()
    print("Opening Spot Menu")
    local options = {}

    if xPlayer.job.name ~= Config.Job then
        ShowNotification(Config.Locale.no_job, 'error')
        return
    end

    for i, spot in ipairs(spots) do
        local label = spot.name
        if spawnedVehicles[spot.name] then
            label = label .. " - Rimuovi Veicolo"
        end
        table.insert(options, {
            title = label,
            args = { index = i, spot = spot },
            onSelect = function(args)
                HandleSpotSelection(args.index, args.spot)
            end
        })
    end

    lib.registerContext({
        id = 'spot_menu',
        title = Config.Locale.spot_vehicle,
        options = options,
        menu = 'main_menu'
    })

    lib.showContext('spot_menu')
end

RegisterNetEvent('Rk_script:openspot', function()
    OpenSpotMenu()
end)

local function RotateVehicle(vehicle)
    Citizen.CreateThread(function()
        while DoesEntityExist(vehicle) do
            local heading = GetEntityHeading(vehicle)
            SetEntityHeading(vehicle, heading + 1.0)
            Citizen.Wait(10)
        end
    end)
end

function HandleSpotSelection(selectedIndex, selectedSpot)
    if spawnedVehicles[selectedSpot.name] then
        DeleteVehicle(spawnedVehicles[selectedSpot.name])
        spawnedVehicles[selectedSpot.name] = nil
        ShowNotification(Config.Locale.remove_spot .. selectedSpot.name, 'success')
    else
        selectedSpotCoords = selectedSpot.coords
        selectedSpotHeading = selectedSpot.heading
        OpenSpotTypeMenu()
    end
end

function OpenSpotTypeMenu()
    local options = {
        {
            title = Config.Locale.fixed_spot,
            args = 'fixed',
            onSelect = function(type)
                OpenCategoryMenuSpot(type)
            end
        },
        {
            title = Config.Locale.moving_spot,
            args = 'moving',
            onSelect = function(type)
                OpenCategoryMenuSpot(type)
            end
        }
    }

    lib.registerContext({
        id = 'spot_type_menu',
        title = Config.Locale.select_spot_type,
        options = options,
        menu = 'spot_menu'
    })

    lib.showContext('spot_type_menu')
end

function OpenCategoryMenuSpot(spotType)
    local options = {}

    for _, category in ipairs(Config.Categories) do
        table.insert(options, {
            title = category.label,
            args = { category = category.name, spotType = spotType },
            onSelect = function(args)
                OpenVehicleMenuSpot(args.category, args.spotType)
            end
        })
    end

    lib.registerContext({
        id = 'category_menu',
        title = Config.Locale.category_spot,
        options = options,
        menu = 'spot_type_menu'
    })

    lib.showContext('category_menu')
end

function OpenVehicleMenuSpot(categoryName, spotType)
    print("Opening Vehicle Menu for category: " .. categoryName)
    local options = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == categoryName then
            table.insert(options, {
                title = vehicle.name,
                args = { model = vehicle.model, spotType = spotType },
                onSelect = function(args)
                    SpawnShowroomVehicle(args.model, selectedSpotCoords, selectedSpotHeading, args.spotType)
                end
            })
        end
    end

    if #options == 0 then
        ShowNotification(Config.Locale.novehicle_spot, 'error')
        return
    end

    lib.registerContext({
        id = 'vehicle_menu',
        title = Config.Locale.select_vehicle,
        options = options,
        menu = 'category_menu'
    })

    lib.showContext('vehicle_menu')
end

function SpawnShowroomVehicle(model, coords, heading, spotType)

    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        ShowNotification(Config.Locale.no_model, 'error')
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleEngineOn(vehicle, false, true, true)

        for _, spot in ipairs(spots) do
            if spot.coords == coords then
                spawnedVehicles[spot.name] = vehicle
                break
            end
        end

        if spotType == 'moving' then
            RotateVehicle(vehicle)
        end

        ShowNotification(Config.Locale.spawn_vehicle, 'success')
    else
        ShowNotification(Config.Locale.no_spawn, 'error')
    end

    SetModelAsNoLongerNeeded(model)
end
