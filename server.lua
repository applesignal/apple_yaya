ESX = exports["es_extended"]:getSharedObject()
local ox_inventory = exports.ox_inventory

local gameState = {
    players = {},
    dealer = nil,
    bets = {},
    multipliers = {}
}

-- 開始新遊戲
function StartNewGame()
    gameState = {
        players = {},
        dealer = nil,
        bets = {},
        multipliers = {}
    }
    TriggerClientEvent('niuNiu:updateGameState', -1, gameState)
end

-- 加入遊戲
RegisterServerEvent('niuNiu:joinGame')
AddEventHandler('niuNiu:joinGame', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if #gameState.players < Config.MaxPlayers then
        table.insert(gameState.players, {id = source, name = xPlayer.getName()})
        TriggerClientEvent('niuNiu:updateGameState', -1, gameState)
    else
        TriggerClientEvent('esx:showNotification', source, '遊戲已滿員')
    end
end)

-- 下注
RegisterServerEvent('niuNiu:placeBet')
AddEventHandler('niuNiu:placeBet', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if amount < Config.MinBet or amount > Config.MaxBet then
        TriggerClientEvent('esx:showNotification', source, '無效的下注金額')
        return
    end
    
    local chips = ox_inventory:GetItem(source, Config.ChipItem, nil, true)
    if chips < amount then
        TriggerClientEvent('esx:showNotification', source, '籌碼不足')
        return
    end
    
    ox_inventory:RemoveItem(source, Config.ChipItem, amount)
    gameState.bets[source] = amount
    TriggerClientEvent('niuNiu:updateGameState', -1, gameState)
end)

-- 增加倍數
RegisterServerEvent('niuNiu:multiplyBet')
AddEventHandler('niuNiu:multiplyBet', function(multiplier)
    local source = source
    if not gameState.bets[source] then return end
    
    gameState.multipliers[source] = multiplier
    TriggerClientEvent('niuNiu:updateGameState', -1, gameState)
end)

-- 成為莊家
RegisterServerEvent('niuNiu:becomeDealer')
AddEventHandler('niuNiu:becomeDealer', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getAccount('bank').money < Config.MinDealerBank then
        TriggerClientEvent('esx:showNotification', source, '銀行餘額不足以成為莊家')
        return
    end
    
    gameState.dealer = {id = source, name = xPlayer.getName()}
    TriggerClientEvent('niuNiu:updateGameState', -1, gameState)
end)

-- 結算遊戲
function SettleGame()
    -- 這裡實現遊戲結算邏輯
    -- 計算每個玩家的輸贏，扣除稅金，更新籌碼等
end

-- 定時檢查是否應該開始新的一輪
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if #gameState.players >= 2 and gameState.dealer and next(gameState.bets) then
            SettleGame()
            Citizen.Wait(5000) -- 等待5秒後開始新一輪
            StartNewGame()
        end
    end
end)