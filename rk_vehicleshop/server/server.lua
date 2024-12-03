ESX = nil
ESX = exports["es_extended"]:getSharedObject()

local Veicoli = {}
for _, v in pairs(Config.Vehicles) do
    Veicoli[v.model] = {label = v.name, price = v.price, category = v.category}
end

local NumberCharset = {}
local Charset = {}
for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

local function GetRandomNumber(length)
    Citizen.Wait(1)
    math.randomseed(GetGameTimer())
    if length > 0 then
        return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
    else
        return ''
    end
end

local function GetRandomLetter(length)
    Citizen.Wait(1)
    math.randomseed(GetGameTimer())
    if length > 0 then
        return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    else
        return ''
    end
end

local CreaTarga = function()
    local PlateFormat = '%s %s'
    local generatedPlate = PlateFormat:format(string.upper(GetRandomLetter(3)), string.upper(GetRandomNumber(3)))
    local TargaUtilizzabile = false
    repeat
        local exist = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ?', {generatedPlate})
        if exist then
            TargaUtilizzabile = false
        else
            TargaUtilizzabile = true
        end
    until TargaUtilizzabile
    return generatedPlate
end

-- ...existing code...

local function ShowNotification(playerId, message)
    if Config.NotificationType == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', playerId, {type = 'success', description = message})
    elseif Config.NotificationType == 'Custom' then
        TriggerClientEvent(Config.CustomNotificationTrigger, playerId, message)
    elseif Config.NotificationType == 'es_extended' then
        TriggerClientEvent('esx:showNotification', playerId, message)
    end
end

RegisterServerEvent('RK_vehicle:cardealer:vendi')
AddEventHandler('RK_vehicle:cardealer:vendi', function(trg, model, vehProps, plate)
    local src = source
    print("Evento di vendita ricevuto")
    print("Modello ricevuto:", model)
    print("Proprietà del veicolo:", json.encode(vehProps))
    
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.job.name == Config.Job then
        local xTarget = ESX.GetPlayerFromId(trg)
        
        if not Veicoli[model] then
            ShowNotification(src, Config.Locale.model_vehicle)
            return
        end

        MySQL.Async.fetchScalar('SELECT money FROM addon_account_data WHERE account_name = @account_name', {
            ['@account_name'] = Config.Society
        }, function(accountMoney)
            local discountedPrice = Veicoli[model].price * (1 - Config.SocietyDiscount / 100)
            if accountMoney >= discountedPrice then
                MySQL.Async.execute('UPDATE addon_account_data SET money = money - @price WHERE account_name = @account_name', {
                    ['@price'] = discountedPrice,
                    ['@account_name'] = Config.Society
                })

                vehProps.plate = plate
                vehProps.model = GetHashKey(model) 

                MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
                    ['@owner']   = xTarget.identifier,
                    ['@plate']   = vehProps.plate,
                    ['@vehicle'] = json.encode(vehProps)
                }, function (rowsChanged)
                    if rowsChanged > 0 then
                        print("Veicolo venduto con successo:", model)
                        ShowNotification(src, Config.Locale.vending_vehicle .. Veicoli[model].label .. Config.Locale.targato .. vehProps.plate)
                        ShowNotification(trg, Config.Locale.receveid_vehicle .. Veicoli[model].label .. Config.Locale.targato .. vehProps.plate)
                        
                    
                        TriggerClientEvent('RK_vehicle:cardealer:venditaCompletata', src)
                    else
                        print("Errore durante la vendita del veicolo:", model)
                        ShowNotification(src, 'Errore durante il salvataggio del veicolo nel database!')
                        MySQL.Async.execute('UPDATE addon_account_data SET money = money + @price WHERE account_name = @account_name', {
                            ['@price'] = discountedPrice,
                            ['@account_name'] = Config.Society
                        })  
                    end
                end)
            else
                ShowNotification(src, Config.Locale.no_money_society)
            end
        end)
    else
        ShowNotification(src, Config.Locale.no_permission)
    end
end)



RegisterServerEvent('RK_vehicle:logSale')
AddEventHandler('RK_vehicle:logSale', function(seller, buyer, vehicle, price)
    local date = os.date('%d/%m/%Y %H:%M:%S')
    local message = string.format([[
**Vendita Veicolo**

**Venditore:** %s
**Acquirente:** %s
**Veicolo:** %s
**Prezzo:** $%s
**Data:** %s

RK Scripts]], seller, buyer, vehicle, price, date)
    
    PerformHttpRequest(Config.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = "RK Scripts - Vehicle Shop",
        content = message
    }), { ['Content-Type'] = 'application/json' })
end)
