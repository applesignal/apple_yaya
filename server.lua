local ESX = exports["es_extended"]:getSharedObject()
local ox_inventory = exports.ox_inventory

local games = {}

ESX.RegisterServerCallback('apple_yaya:checkBankBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankBalance = xPlayer.getAccount('bank').money
    cb(bankBalance >= Config.MinBankBalance)
end)

RegisterNetEvent('apple_yaya:joinGame')
AddEventHandler('apple_yaya:joinGame', function(tableId)
    local source = source
    if not games[tableId] then
        games[tableId] = {players = {}, banker = nil, bets = {}, multipliers = {}, cards = {}}
    end
    table.insert(games[tableId].players, source)
    if #games[tableId].players == 2 then
        StartNewRound(tableId)
    end
end)

RegisterNetEvent('apple_yaya:becomeBanker')
AddEventHandler('apple_yaya:becomeBanker', function(tableId)
    local source = source
    if games[tableId] and not games[tableId].banker then
        games[tableId].banker = source
    end
end)

RegisterNetEvent('apple_yaya:placeBet')
AddEventHandler('apple_yaya:placeBet', function(tableId, betAmount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if ox_inventory:GetItemCount(source, Config.ChipItem) >= betAmount then
        ox_inventory:RemoveItem(source, Config.ChipItem, betAmount)
        games[tableId].bets[source] = betAmount
        if AllPlayersHaveBet(tableId) then
            DealCards(tableId)
        end
    else
        TriggerClientEvent('esx:showNotification', source, '籌碼不足')
    end
end)

RegisterNetEvent('apple_yaya:setMultiplier')
AddEventHandler('apple_yaya:setMultiplier', function(tableId, multiplier)
    local source = source
    games[tableId].multipliers[source] = multiplier
    if AllPlayersHaveSetMultiplier(tableId) then
        CalculateResults(tableId)
    end
end)

function StartNewRound(tableId)
    for _, playerId in ipairs(games[tableId].players) do
        TriggerClientEvent('apple_yaya:updateGameState', playerId, 'betting')
    end
end

function DealCards(tableId)
    local deck = CreateDeck()
    for _, playerId in ipairs(games[tableId].players) do
        games[tableId].cards[playerId] = {table.remove(deck), table.remove(deck), table.remove(deck), table.remove(deck), table.remove(deck)}
        TriggerClientEvent('apple_yaya:receiveCards', playerId, games[tableId].cards[playerId])
    end
    for _, playerId in ipairs(games[tableId].players) do
        TriggerClientEvent('apple_yaya:updateGameState', playerId, 'playing')
    end
end

function CalculateResults(tableId)
    local game = games[tableId]
    local bankerScore = CalculateScore(game.cards[game.banker])
    local results = {}

    for _, playerId in ipairs(game.players) do
        if playerId ~= game.banker then
            local playerScore = CalculateScore(game.cards[playerId])
            local bet = game.bets[playerId]
            local multiplier = game.multipliers[playerId]
            local result = CompareHands(bankerScore, playerScore)
            
            if result == 1 then -- Banker wins
                results[playerId] = -bet * multiplier
            elseif result == -1 then -- Player wins
                results[playerId] = bet * multiplier * Config.Multipliers[playerScore]
            else -- Tie
                results[playerId] = 0
            end
        end
    end

    DistributeWinnings(tableId, results)
end

function DistributeWinnings(tableId, results)
    local game = games[tableId]
    local bankerProfit = 0

    for playerId, amount in pairs(results) do
        if amount > 0 then
            ox_inventory:AddItem(playerId, Config.ChipItem, amount)
            bankerProfit = bankerProfit - amount
        elseif amount < 0 then
            bankerProfit = bankerProfit - amount
        end
    end

    -- Apply house edge
    local houseEdge = math.floor(bankerProfit * (Config.HouseEdgePercentage / 100))
    bankerProfit = bankerProfit - houseEdge

    -- Give profit to banker
    if bankerProfit > 0 then
        ox_inventory:AddItem(game.banker, Config.ChipItem, bankerProfit)
    elseif bankerProfit < 0 then
        ox_inventory:RemoveItem(game.banker, Config.ChipItem, -bankerProfit)
    end

    -- Reset game state
    ResetGame(tableId)
end

function ResetGame(tableId)
    games[tableId] = {players = games[tableId].players, banker = games[tableId].banker, bets = {}, multipliers = {}, cards = {}}
    StartNewRound(tableId)
end

-- Helper functions (CreateDeck, CalculateScore, CompareHands, etc.) should be implemented here

CreateThread(function()
    while true do
        for tableId, game in pairs(games) do
            if #game.players == 0 then
                games[tableId] = nil
            end
        end
        Wait(60000) -- 每分鐘檢查一次
    end
end)