local ESX = nil
local IsInShopMenu = false
local LastVehicle = nil
local CurrentVehicleData = nil
local cam = nil
local angleY = 0.0
local isInTestDrive = false
local testDriveVehicle = nil

local function HandleMenuClose()
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        ExitShopMenu()
        EnableAllControlActions(0)
        SetNuiFocus(false, false)
    end)
end

local function HandleMenuExit()
    Citizen.CreateThread(function()
        ExitShopMenu()
        EnableAllControlActions(0)
        SetNuiFocus(false, false)
    end)
end

local function HandleMenuBack()
    return
end

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

local function ShowNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

local function CreateShowroomVehicle(model)
    if LastVehicle then
        DeleteVehicle(LastVehicle)
    end
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    
    LastVehicle = CreateVehicle(model, Config.SpawnCatalog.Pos.x, Config.SpawnCatalog.Pos.y, Config.SpawnCatalog.Pos.z, Config.SpawnCatalog.Heading, false, false)
    SetEntityAsMissionEntity(LastVehicle, true, true)
    SetVehicleOnGroundProperly(LastVehicle)
    FreezeEntityPosition(LastVehicle, true)
    SetModelAsNoLongerNeeded(model)
    
    SetVehicleEngineOn(LastVehicle, true, true, false)
    
    return LastVehicle
end

local function CreateShowroomCamera()
    if not LastVehicle then return end

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end

    local vehPos = GetEntityCoords(LastVehicle)
    local offset = GetOffsetFromEntityInWorldCoords(LastVehicle, -2.0, 5.0, 1.0)
    
    SetCamCoord(cam, offset.x, offset.y, offset.z)
    PointCamAtCoord(cam, vehPos.x, vehPos.y, vehPos.z)
    
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

local function RotateShowroomCamera()
    if not DoesCamExist(cam) or not LastVehicle then return end

    local mouseX = GetDisabledControlNormal(1, 1) * 1.0
    local mouseY = GetDisabledControlNormal(1, 2) * 1.0

    angleY = angleY - mouseX
    local angleZ = -mouseY

    local vehPos = GetEntityCoords(LastVehicle)
    local radius = 5.0
    local offsetX = radius * math.cos(angleY)
    local offsetY = radius * math.sin(angleY)

    local camPos = vector3(
        vehPos.x + offsetX,
        vehPos.y + offsetY,
        vehPos.z + 1.0 + angleZ
    )

    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(cam, vehPos.x, vehPos.y, vehPos.z)
end

local function EndTestDrive()
    if isInTestDrive then
        isInTestDrive = false
        local playerPed = PlayerPedId()
        if DoesEntityExist(testDriveVehicle) then
            DeleteVehicle(testDriveVehicle)
        end
        testDriveVehicle = nil
        
        SetEntityCoords(playerPed, Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z)
        SetEntityHeading(playerPed, Config.Katalog.Heading)
        ShowNotification("Il test drive è terminato.")
    end
end

local function StartTestDrive(vehicleData)
    if isInTestDrive then return end
    
    if DoesCamExist(cam) then
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 0, true, true)
        cam = nil
    end

    if LastVehicle then
        DeleteVehicle(LastVehicle)
        LastVehicle = nil
    end
    
    lib.hideContext()
    IsInShopMenu = false
    isInTestDrive = true
    
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true)
    
    RequestModel(vehicleData.model)
    while not HasModelLoaded(vehicleData.model) do
        Citizen.Wait(0)
    end
    
    testDriveVehicle = CreateVehicle(vehicleData.model, Config.TestDrive.Pos.x, Config.TestDrive.Pos.y, Config.TestDrive.Pos.z, Config.TestDrive.Heading, true, false)
    SetVehicleNumberPlateText(testDriveVehicle, "TESTDRIVE")
    TaskWarpPedIntoVehicle(playerPed, testDriveVehicle, -1)
    SetVehicleEngineOn(testDriveVehicle, true, true, false)
    SetModelAsNoLongerNeeded(vehicleData.model)
    
    local remainingTime = Config.TestDrive.Duration
    
    Citizen.CreateThread(function()
        while remainingTime > 0 and isInTestDrive do
            Citizen.Wait(1000)
            remainingTime = remainingTime - 1
        end
        if isInTestDrive then
            EndTestDrive()
        end
    end)

    Citizen.CreateThread(function()
        while isInTestDrive do
            Citizen.Wait(0)
            SetTextScale(0.7, 0.7)
            SetTextFont(4)
            SetTextOutline()
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(remainingTime .. " secondi - Premi [E] per terminare")
            DrawText(0.5, 0.05)
            
            if IsControlJustPressed(0, 38) then
                EndTestDrive()
                break
            end
        end
    end)
end

local function OpenVehicleMenu(vehicleData)
    lib.registerContext({
        id = 'vehicle_info',
        title = vehicleData.name,
        menu = 'vehicle_list',
        options = {
            {
                title = Config.Locale.money .. vehicleData.price,
                description = Config.Locale.description_3
            },
            {
                title = Config.Locale.test_drive,
                description = Config.Locale.test_drive_desc,
                onSelect = function()
                    StartTestDrive(vehicleData)
                end
            },
            {
                title = Config.Locale.esc,
                description = Config.Locale.description_1,
                onSelect = function()
                    ExitShopMenu()
                end
            }
        },
        onExit = HandleMenuExit,
        onBack = HandleMenuBack
    })

    lib.showContext('vehicle_info')
end

local function OpenCategoryMenu(category)
    local options = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == category then
            table.insert(options, {
                title = vehicle.name,
                description = 'Prezzo: $' .. vehicle.price,
                onSelect = function()
                    CurrentVehicleData = vehicle
                    CreateShowroomVehicle(vehicle.model)
                    CreateShowroomCamera()
                    OpenVehicleMenu(vehicle)
                end
            })
        end
    end

    lib.registerContext({
        id = 'vehicle_list',
        title = Config.Locale.vehicle_model .. category,
        menu = 'vehicle_categories',
        options = options,
        onExit = HandleMenuExit,
        onBack = HandleMenuBack
    })

    lib.showContext('vehicle_list')
end

local function OpenShopMenu()
    IsInShopMenu = true
    local playerPed = PlayerPedId()

    SetEntityCoords(playerPed, Config.SpawnCatalog.Pos.x, Config.SpawnCatalog.Pos.y, Config.SpawnCatalog.Pos.z)
    SetEntityHeading(playerPed, Config.SpawnCatalog.Heading)
    FreezeEntityPosition(playerPed, true)
    SetEntityVisible(playerPed, false)

    local options = {}
    for _, category in ipairs(Config.Categories) do
        table.insert(options, {
            title = category.label,
            description = Config.Locale.description .. category.label,
            onSelect = function()
                OpenCategoryMenu(category.name)
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_categories', 
        title = Config.Locale.show_category,
        options = options,
        onExit = HandleMenuExit,
        onBack = HandleMenuBack
    })

    lib.showContext('vehicle_categories')

    Citizen.CreateThread(function()
        while IsInShopMenu do
            Citizen.Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            
            if IsDisabledControlPressed(0, 24) or IsDisabledControlPressed(0, 69) then
                RotateShowroomCamera()
            end

            if IsDisabledControlJustPressed(0, 177) then
                ExitShopMenu()
            end
        end
    end)
end

RegisterNetEvent('Rk_script:openshop', function()
    OpenShopMenu()
end)

function ExitShopMenu()
    IsInShopMenu = false
    local playerPed = PlayerPedId()

    if DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        cam = nil
    end

    if LastVehicle then
        DeleteVehicle(LastVehicle)
        LastVehicle = nil
    end

    SetEntityVisible(playerPed, true)
    FreezeEntityPosition(playerPed, false)
    
    SetEntityCoordsNoOffset(playerPed, Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z, true, true, true)
    SetEntityHeading(playerPed, Config.Katalog.Heading)
    SetGameplayCamRelativeHeading(0.0)

    CurrentVehicleData = nil
    angleY = 0.0

    lib.hideContext()
    SetNuiFocus(false, false)
end

local function CleanupResource()
    local playerPed = PlayerPedId()
    
    if DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, true, true)
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        cam = nil
    end

    if LastVehicle then
        DeleteVehicle(LastVehicle)
        LastVehicle = nil
    end

    if testDriveVehicle then
        DeleteVehicle(testDriveVehicle)
        testDriveVehicle = nil
    end

    IsInShopMenu = false
    isInTestDrive = false
    CurrentVehicleData = nil
    angleY = 0.0

    lib.hideContext()
    SetNuiFocus(false, false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CleanupResource()
        if Config.InteractionType == 'ox_target' then
            exports.ox_target:removeLocalEntity(PlayerPedId(), 'vehicle_catalog')
        end
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    if Config.InteractionType == 'ox_target' then
        local zoneId = exports.ox_target:addBoxZone({
            coords = vector3(Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z),
            name = "shop_interaction",
            size = vector3(2, 2, 2),
            rotation = 45,
            debug = false,
            drawSprite = true,
            options = {
                {
                    event = "Rk_script:openshop",
                    icon = "fas fa-shopping-cart",
                    label = Config.Locale.menu_showroom,
                },
            },
        })

        print("Zona creata con ID: " .. zoneId)

    elseif Config.InteractionType == 'ox_lib' then
        local zone = lib.zones.box({
            coords = vec3(Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z),
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            inside = function()
                lib.showTextUI(Config.Locale.menu_showroom)

                if IsControlJustReleased(0, 38) then
                    OpenShopMenu()
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })

        Citizen.CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - vec3(Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z))

                if distance < 10.0 then
                    DrawMarker(
                        Config.Marker.Type,
                        Config.Katalog.Pos.x, Config.Katalog.Pos.y, Config.Katalog.Pos.z - 1.0,
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

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if Config.InteractionType == 'ox_target' then
            exports.ox_target:removeLocalEntity(PlayerPedId(), 'vehicle_catalog')
        end
    end
end)