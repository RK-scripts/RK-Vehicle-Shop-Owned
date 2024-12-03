ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

local Veicoli = {}
for _, v in pairs(Config.Vehicles) do
    Veicoli[v.model] = {label = v.name, price = v.price, category = v.category}
end

local VeicoloVisualizzatoAttuale = nil
local ModelloVeicoloAttuale = nil

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

local function WaitForVehicleToLoad(modelHash)
    modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)

       

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
            DisableAllControlActions(0)
        end
    end
end

local function CancellaVeicoloVisualizzato()
    if VeicoloVisualizzatoAttuale then
        if DoesEntityExist(VeicoloVisualizzatoAttuale) then
            ESX.Game.DeleteVehicle(VeicoloVisualizzatoAttuale)
        end
        VeicoloVisualizzatoAttuale = nil
        ModelloVeicoloAttuale = nil
    end
end

local function ResetStatoVendita()
    VeicoloVisualizzatoAttuale = nil
    ModelloVeicoloAttuale = nil
    CancellaVeicoloVisualizzato()
    ESX.UI.Menu.CloseAll()
end

local function ApriMenuVendita()
    local playerPed = PlayerPedId()
    local xPlayer = ESX.GetPlayerData()

  
    if xPlayer.job.name ~= Config.Job then
        ShowNotification(Config.Locale.no_job, 'error')
        return
    end


    local options = {}
    for _, category in ipairs(Config.Categories) do
        table.insert(options, {
            title = category.label,
            description = 'Visualizza veicoli ' .. category.label,
            onSelect = function()
                OpenCategoryMenu(category.name)
            end
        })
    end


    lib.registerContext({
        id = 'vehicle_categories',
        title = Config.Locale.cardealer_catalog,
        options = options,
        menu = 'main_menu' 
    })

 
    lib.showContext('vehicle_categories')
end

RegisterNetEvent('Rk_script:cardealer', function()
    ApriMenuVendita()
end)

local function LogVehicleSale(seller, buyer, vehicle, price)
    TriggerServerEvent('RK_vehicle:logSale', seller, buyer, vehicle, price)
end

local function TeleportPlayerIntoVehicle(playerId, vehicleModel, plate)
    local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    local modelHash = GetHashKey(vehicleModel)

   
    WaitForVehicleToLoad(modelHash)


    local vehicle = CreateVehicle(modelHash, Config.TeleportCoords.x, Config.TeleportCoords.y, Config.TeleportCoords.z, Config.TeleportCoords.heading, true, false)


    SetVehicleNumberPlateText(vehicle, plate)


    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
end

local function ApriMenuSelezionaPlayer(vehicle)

    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(playerCoords - targetCoords)

        if distance < 20.0 then
            local playerName = GetPlayerName(playerId)
            table.insert(players, {
                title = playerName,
                description = 'Distanza: ' .. math.floor(distance) .. 'm',
                value = GetPlayerServerId(playerId),
                onSelect = function()
                 
                    local buyerId = GetPlayerServerId(playerId)
                    local plate = "CAR" .. math.random(1000, 9999)
                    TriggerServerEvent('RK_vehicle:cardealer:vendi', buyerId, vehicle.model, vehicle, plate)
                    LogVehicleSale(GetPlayerName(PlayerId()), GetPlayerName(playerId), vehicle.name, vehicle.price)
                    TeleportPlayerIntoVehicle(buyerId, vehicle.model, plate)
                end
            })
        end
    end

  
    if #players == 0 then
        ShowNotification(Config.Locale.no_player, 'error')
        return
    end

  
    lib.registerContext({
        id = 'player_selection',
        title = Config.Locale.selected_player,
        options = players,
        menu = 'vehicle_list' 
    })

    lib.showContext('player_selection')
end


function OpenCategoryMenu(categoryName)
    local vehiclesInCategory = {}


    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == categoryName then
            table.insert(vehiclesInCategory, {
                title = vehicle.name .. ' - ' .. vehicle.price .. '$',
                description = 'Modello: ' .. vehicle.model,
                onSelect = function()
                    ApriMenuSelezionaPlayer(vehicle)
                end
            })
        end
    end

  
    if #vehiclesInCategory == 0 then
        ShowNotification(Config.Locale.no_vehicle, 'error')
        return
    end

  
    lib.registerContext({
        id = 'vehicle_list',
        title = Config.Locale.selected_vehicle,
        options = vehiclesInCategory,
        menu = 'vehicle_categories' 
    })


    lib.showContext('vehicle_list')
end



function GetPlayersInArea(coords, radius)
    local players = {}
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    local playerCoords = coords
    for _, id in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(id)
        local pedCoords = GetEntityCoords(ped)
        local dist = #(playerCoords - pedCoords)
        if dist < radius then
            table.insert(players, id)
        end
    end
    return players
end


RegisterNetEvent('RK_vehicle:cardealer:venditaCompletata')
AddEventHandler('RK_vehicle:cardealer:venditaCompletata', function()
    ResetStatoVendita()
end)

Citizen.CreateThread(function()
    if Config.InteractionType == 'ox_target' then
       
        local zoneId = exports.ox_target:addBoxZone({
            coords = vector3(Config.Cardealer.Pos.x, Config.Cardealer.Pos.y, Config.Cardealer.Pos.z),  
            name = "car_dealer_interaction",  
            size = vector3(2, 2, 2),          
            rotation = 45,                  
            debug = false,                    
            drawSprite = true,              
            options = {
                {
                    event = "Rk_script:cardealer",  
                    icon = "fas fa-car",        
                    label = Config.Locale.menu_cardealer, 
                },
            },
        })

       
        print("Zona creata con ID: " .. zoneId)

    elseif Config.InteractionType == 'ox_lib' then
       
        local zone = lib.zones.box({
            coords = vec3(Config.Cardealer.Pos.x, Config.Cardealer.Pos.y, Config.Cardealer.Pos.z),
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            inside = function()
                lib.showTextUI(Config.Locale.menu_cardealer)

                if IsControlJustReleased(0, 38) then
                    ApriMenuVendita()
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })

      
        Citizen.CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - vec3(Config.Cardealer.Pos.x, Config.Cardealer.Pos.y, Config.Cardealer.Pos.z))

                if distance < 10.0 then
                    DrawMarker(
                        Config.Marker.Type,
                        Config.Cardealer.Pos.x, Config.Cardealer.Pos.y, Config.Cardealer.Pos.z - 1.0,
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

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Cardealer.Pos.x, Config.Cardealer.Pos.y, Config.Cardealer.Pos.z)
    SetBlipSprite(blip, Config.Blip.Type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Title)
    EndTextCommandSetBlipName(blip)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
      
        if Config.InteractionType == 'ox_target' then
            exports.ox_target:removeLocalEntity(PlayerPedId(), 'vehicle_catalog')
        end
    end
end)