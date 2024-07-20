local ESX = exports["es_extended"]:getSharedObject()
local ox_inventory = exports.ox_inventory

local currentTable = nil
local isBanker = false
local players = {}
local bets = {}
local cards = {}
local gameState = 'waiting' -- 'waiting', 'betting', 'playing'

function OpenPokerMenu()
    lib.registerContext({
        id = 'poker_menu',
        title = '妞妞撲克',
        options = {
            {
                title = '加入遊戲',
                description = '坐下來玩妞妞',
                onSelect = function()
                    JoinGame()
                end
            },
            {
                title = '成為莊家',
                description = '成為莊家 (需要足夠資金)',
                onSelect = function()
                    BecomeBanker()
                end
            }
        }
    })
    lib.showContext('poker_menu')
end

function JoinGame()
    if #players >= Config.MaxPlayers then
        ESX.ShowNotification('桌子已滿')
        return
    end
    
    local chipCount = ox_inventory:GetItemCount(Config.ChipItem)
    if chipCount == 0 then
        ESX.ShowNotification('你沒有籌碼')
        return
    end

    table.insert(players, GetPlayerServerId(PlayerId()))
    TriggerServerEvent('apple_yaya:joinGame', currentTable)
    ESX.ShowNotification('你已加入遊戲')
end

function BecomeBanker()
    ESX.TriggerServerCallback('apple_yaya:checkBankBalance', function(canBeBanker)
        if canBeBanker then
            isBanker = true
            TriggerServerEvent('apple_yaya:becomeBanker', currentTable)
            ESX.ShowNotification('你現在是莊家')
        else
            ESX.ShowNotification('你的資金不足以成為莊家')
        end
    end)
end

function PlaceBet()
    if isBanker or gameState ~= 'betting' then return end

    local input = lib.inputDialog('下注', {
        {type = 'number', label = '下注金額', min = 1, max = Config.MaxBet}
    })

    if input then
        local betAmount = input[1]
        TriggerServerEvent('apple_yaya:placeBet', currentTable, betAmount)
    end
end

function SetMultiplier()
    if isBanker or gameState ~= 'playing' then return end

    local input = lib.inputDialog('設置倍數', {
        {type = 'number', label = '倍數', min = 1, max = 5}
    })

    if input then
        local multiplier = input[1]
        TriggerServerEvent('apple_yaya:setMultiplier', currentTable, multiplier)
    end
end

RegisterNetEvent('apple_yaya:updateGameState')
AddEventHandler('apple_yaya:updateGameState', function(state)
    gameState = state
    if state == 'betting' then
        ESX.ShowNotification('請下注')
    elseif state == 'playing' then
        ESX.ShowNotification('請選擇倍數')
    end
end)

RegisterNetEvent('apple_yaya:receiveCards')
AddEventHandler('apple_yaya:receiveCards', function(playerCards)
    cards = playerCards
    -- 在UI上顯示卡牌
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, tablePos in ipairs(Config.TablePositions) do
            local distance = #(playerCoords - vector3(tablePos.x, tablePos.y, tablePos.z))
            if distance < 2.0 then
                currentTable = i
                ESX.ShowHelpNotification('按 ~INPUT_CONTEXT~ 打開妞妞菜單')
                if IsControlJustReleased(0, 38) then -- E key
                    OpenPokerMenu()
                end
                break
            end
        end

        Wait(0)
    end
end)