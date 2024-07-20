ESX = exports["es_extended"]:getSharedObject()
local display = false

-- 打開遊戲UI
RegisterNetEvent('niuNiu:openGame')
AddEventHandler('niuNiu:openGame', function()
    SetDisplay(true)
end)

-- 更新遊戲狀態
RegisterNetEvent('niuNiu:updateGameState')
AddEventHandler('niuNiu:updateGameState', function(newState)
    SendNUIMessage({
        type = "updateGameState",
        gameState = newState
    })
end)

-- 設置NUI顯示
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "setVisible",
        status = bool,
    })
end

-- NUI回調
RegisterNUICallback("exit", function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback("joinGame", function(data, cb)
    TriggerServerEvent("niuNiu:joinGame")
    cb('ok')
end)

RegisterNUICallback("placeBet", function(data, cb)
    TriggerServerEvent("niuNiu:placeBet", data.amount)
    cb('ok')
end)

RegisterNUICallback("multiplyBet", function(data, cb)
    TriggerServerEvent("niuNiu:multiplyBet", data.multiplier)
    cb('ok')
end)

RegisterNUICallback("becomeDealer", function(data, cb)
    TriggerServerEvent("niuNiu:becomeDealer")
    cb('ok')
end)

-- 創建賭桌標記
Citizen.CreateThread(function()
    for _, location in ipairs(Config.GameLocations) do
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("妞妞賭桌")
        EndTextCommandSetBlipName(blip)
    end
end)

-- 檢查玩家是否在賭桌附近
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, location in ipairs(Config.GameLocations) do
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))
            if distance < 2.0 then
                ESX.ShowHelpNotification('按 ~INPUT_CONTEXT~ 開始遊戲')
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('niuNiu:openGame')
                end
            end
        end
    end
end)