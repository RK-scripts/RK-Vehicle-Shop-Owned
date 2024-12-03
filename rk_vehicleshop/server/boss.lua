ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local function ShowNotification(playerId, message)
    if Config.NotificationType == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', playerId, {type = 'success', description = message})
    elseif Config.NotificationType == 'Custom' then
        TriggerClientEvent(Config.CustomNotificationTrigger, playerId, message)
    elseif Config.NotificationType == 'es_extended' then
        TriggerClientEvent('esx:showNotification', playerId, message)
    end
end

local function getPlayerFromId(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        ShowNotification(source, Config.Locale.no_player_boss)
    end
    return xPlayer
end

ESX.RegisterServerCallback('esx_bossmenu:getSocietyMoney', function(source, cb, jobName)
    MySQL.Async.fetchScalar('SELECT money FROM addon_account_data WHERE account_name = @account_name', {
        ['@account_name'] = 'society_' .. jobName
    }, function(money)
        cb(money)
    end)
end)

ESX.RegisterServerCallback('esx_bossmenu:getEmployees', function(source, cb, jobName)
    local xPlayers = ESX.GetPlayers()
    local employees = {}

    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job.name == jobName then
            table.insert(employees, {
                name = xPlayer.getName(),
                identifier = xPlayer.identifier
            })
        end
    end

    cb(employees)
end)

ESX.RegisterServerCallback('esx_bossmenu:getJobGrades', function(source, cb, jobName)
    MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name ORDER BY grade ASC', {
        ['@job_name'] = jobName
    }, function(grades)
        cb(grades)
    end)
end)

RegisterServerEvent('esx_bossmenu:recruit')
AddEventHandler('esx_bossmenu:recruit', function(targetId)
    local xPlayer = getPlayerFromId(source)
    local xTarget = getPlayerFromId(targetId)
    if xPlayer and xTarget then
        xTarget.setJob(xPlayer.job.name, 0)
        ShowNotification(source, Config.Locale.hired .. xTarget.name)
        ShowNotification(targetId, Config.Locale.hired_player .. xPlayer.name)
    end
end)

RegisterServerEvent('esx_bossmenu:fire')
AddEventHandler('esx_bossmenu:fire', function(targetId)
    local xPlayer = getPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromIdentifier(targetId)
    if xPlayer and xTarget then
        xTarget.setJob('unemployed', 0)
        ShowNotification(source, Config.Locale.fired .. xTarget.name)
        ShowNotification(xTarget.source, Config.Locale.fired_player .. xPlayer.name)
    end
end)

RegisterServerEvent('esx_bossmenu:promote')
AddEventHandler('esx_bossmenu:promote', function(targetId, grade)
    local xPlayer = getPlayerFromId(source)
    local xTarget = getPlayerFromId(targetId)
    if xPlayer and xTarget then
        xTarget.setJob(xPlayer.job.name, grade)
        ShowNotification(source, Config.Locale.promoted .. xTarget.name)
        ShowNotification(targetId, Config.Locale.promoted_player .. xPlayer.name)
    end
end)

RegisterServerEvent('esx_bossmenu:demote')
AddEventHandler('esx_bossmenu:demote', function(targetId, grade)
    local xPlayer = getPlayerFromId(source)
    local xTarget = getPlayerFromId(targetId)
    if xPlayer and xTarget then
        xTarget.setJob(xPlayer.job.name, grade)
        ShowNotification(source, Config.Locale.demoted .. xTarget.name)
        ShowNotification(targetId, Config.Locale.demoted_player .. xPlayer.name)
    end
end)

RegisterServerEvent('esx_bossmenu:deposit')
AddEventHandler('esx_bossmenu:deposit', function(amount)
    local xPlayer = getPlayerFromId(source)
    if xPlayer and amount > 0 then
        local societyAccount = nil
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. xPlayer.job.name, function(account)
            societyAccount = account
        end)
        if societyAccount then
            if xPlayer.getMoney() >= amount then
                xPlayer.removeMoney(amount)
                societyAccount.addMoney(amount)
                ShowNotification(source, Config.Locale.deposit_money .. amount)
            else
                ShowNotification(source, Config.Locale.no_money)
            end
        end
    end
end)

RegisterServerEvent('esx_bossmenu:withdraw')
AddEventHandler('esx_bossmenu:withdraw', function(amount)
    local xPlayer = getPlayerFromId(source)
    if xPlayer and amount > 0 then
        local societyAccount = nil
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. xPlayer.job.name, function(account)
            societyAccount = account
        end)
        if societyAccount then
            if societyAccount.money >= amount then
                societyAccount.removeMoney(amount)
                xPlayer.addMoney(amount)
                ShowNotification(source, Config.Locale.withdraw_money .. amount)
            else
                ShowNotification(source, Config.Locale.no_money_society)
            end
        end
    end
end)