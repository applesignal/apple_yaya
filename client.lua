-- client.lua

local display = false

RegisterNetEvent('openNiuNiuGame')
AddEventHandler('openNiuNiuGame', function()
    SetDisplay(not display)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("placeBet", function(data)
    TriggerServerEvent("niuNiu:placeBet", data.amount)
end)

RegisterNUICallback("multiplyBet", function(data)
    TriggerServerEvent("niuNiu:multiplyBet", data.multiplier)
end)

RegisterNUICallback("becomeDealer", function(data)
    TriggerServerEvent("niuNiu:becomeDealer")
end)

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        -- 禁用控制器輸入
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 322, display) -- ESC
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)
