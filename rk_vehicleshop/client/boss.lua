ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
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

local function openBossMenu()
    local xPlayer = ESX.GetPlayerData()
    if xPlayer.job.name ~= Config.Job or xPlayer.job.grade < Config.Grade then
        ShowNotification(Config.NoPermissionMessage, 'error')
        return
    end

    ESX.TriggerServerCallback('esx_bossmenu:getSocietyMoney', function(money)
        local elements = {
            {label = Config.Locale.saldo_boss .. money, value = 'balance'},
            {label = Config.Locale.add_dipendent, value = 'recruit'},
            {label = Config.Locale.manage_employees, value = 'manage_employees'},
            {label = Config.Locale.deposit, value = 'deposit'},
            {label = Config.Locale.withdraw, value = 'withdraw'}
        }

        local options = {}
        for _, element in ipairs(elements) do
            table.insert(options, {
                title = element.label,
                description = '',
                event = 'esx_bossmenu:handleOption',
                args = element.value
            })
        end

        lib.registerContext({
            id = 'boss_menu',
            title = Config.Locale.title_boss,
            options = options,
            menu = 'main_menu' 
        })

        lib.showContext('boss_menu')
    end, Config.Job)
end

RegisterNetEvent('Rk_script:bossmenu', function()
    openBossMenu()
end)

RegisterNetEvent('esx_bossmenu:handleOption')
AddEventHandler('esx_bossmenu:handleOption', function(option)
    if option == 'recruit' then
        local playerId = lib.inputDialog(Config.Locale.add_dipendent, {Config.Locale.id_player})
        if playerId then
            TriggerServerEvent('esx_bossmenu:recruit', tonumber(playerId[1]))
        end
    elseif option == 'manage_employees' then
        ESX.TriggerServerCallback('esx_bossmenu:getEmployees', function(employees)
            local employeeOptions = {}
            for _, employee in ipairs(employees) do
                table.insert(employeeOptions, {
                    title = employee.name,
                    description = '',
                    event = 'esx_bossmenu:manageEmployee',
                    args = employee.identifier
                })
            end

            lib.registerContext({
                id = 'employee_menu',
                title = Config.Locale.manage_employees,
                options = employeeOptions,
                menu = 'boss_menu' 
            })

            lib.showContext('employee_menu')
        end, Config.Job)
    elseif option == 'deposit' then
        local amount = lib.inputDialog(Config.Locale.deposit, {Config.Locale.amount})
        if amount then
            TriggerServerEvent('esx_bossmenu:deposit', tonumber(amount[1]))
        end
    elseif option == 'withdraw' then
        local amount = lib.inputDialog(Config.Locale.withdraw, {Config.Locale.amount})
        if amount then
            TriggerServerEvent('esx_bossmenu:withdraw', tonumber(amount[1]))
        end
    end
end)

RegisterNetEvent('esx_bossmenu:manageEmployee')
AddEventHandler('esx_bossmenu:manageEmployee', function(employeeId)
    local elements = {
        {label = Config.Locale.promote, value = 'promote'},
        {label = Config.Locale.demote, value = 'demote'},
        {label = Config.Locale.fire, value = 'fire'}
    }

    local options = {}
    for _, element in ipairs(elements) do
        table.insert(options, {
            title = element.label,
            description = '',
            event = 'esx_bossmenu:handleEmployeeAction',
            args = {action = element.value, employeeId = employeeId}
        })
    end

    lib.registerContext({
        id = 'employee_action_menu',
        title = Config.Locale.action_dipe,
        options = options,
        menu = 'employee_menu'
    })

    lib.showContext('employee_action_menu')
end)

RegisterNetEvent('esx_bossmenu:handleEmployeeAction')
AddEventHandler('esx_bossmenu:handleEmployeeAction', function(data)
    local action = data.action
    local employeeId = data.employeeId

    if action == 'promote' or action == 'demote' then
        ESX.TriggerServerCallback('esx_bossmenu:getJobGrades', function(grades)
            local gradeOptions = {}
            for _, grade in ipairs(grades) do
                table.insert(gradeOptions, {
                    title = grade.label,
                    description = '',
                    event = 'esx_bossmenu:selectGrade',
                    args = {action = action, employeeId = employeeId, grade = grade.grade}
                })
            end

            lib.registerContext({
                id = 'grade_menu',
                title = Config.Locale.select_grade,
                options = gradeOptions,
                menu = 'employee_action_menu' 
            })

            lib.showContext('grade_menu')
        end, Config.Job)
    elseif action == 'fire' then
        TriggerServerEvent('esx_bossmenu:fire', employeeId)
    end
end)

RegisterNetEvent('esx_bossmenu:selectGrade')
AddEventHandler('esx_bossmenu:selectGrade', function(data)
    local action = data.action
    local employeeId = data.employeeId
    local grade = data.grade

    if action == 'promote' then
        TriggerServerEvent('esx_bossmenu:promote', employeeId, grade)
    elseif action == 'demote' then
        TriggerServerEvent('esx_bossmenu:demote', employeeId, grade)
    end
end)

Citizen.CreateThread(function()
    if Config.InteractionType == 'ox_target' then
      
        local zoneId = exports.ox_target:addBoxZone({
            coords = vector3(Config.BossMenuCoords.x, Config.BossMenuCoords.y, Config.BossMenuCoords.z),
            name = "boss_menu_interaction",  
            size = vector3(2, 2, 2),         
            rotation = 45,                   
            debug = false,                    
            drawSprite = true,                
            options = {
                {
                    event = "Rk_script:bossmenu",  
                    icon = "fas fa-user-tie",     
                    label = Config.Locale.menu_boss,  
                },
            },
        })

      
        print("Zona creata con ID: " .. zoneId)

    elseif Config.InteractionType == 'ox_lib' then
    
        local zone = lib.zones.box({
            coords = vec3(Config.BossMenuCoords.x, Config.BossMenuCoords.y, Config.BossMenuCoords.z),
            size = vec3(2, 2, 2),
            rotation = 45,
            debug = false,
            inside = function()
                lib.showTextUI(Config.Locale.menu_boss)

                if IsControlJustReleased(0, 38) then
                    local xPlayer = ESX.GetPlayerData()
                    if xPlayer.job.name == Config.Job and xPlayer.job.grade >= Config.Grade then
                        openBossMenu()
                    else
                        ShowNotification(Config.NoPermissionMessage, 'error')
                    end
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end
        })

   
        Citizen.CreateThread(function()
            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - vec3(Config.BossMenuCoords.x, Config.BossMenuCoords.y, Config.BossMenuCoords.z))

                if distance < 10.0 then 
                    DrawMarker(
                        Config.Marker.Type,
                        Config.BossMenuCoords.x, Config.BossMenuCoords.y, Config.BossMenuCoords.z - 1.0,
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