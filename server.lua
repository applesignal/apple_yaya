-- server.lua

local gameState = {
    players = {},
    dealer = nil,
    bets = {},
    multipliers = {}
}

RegisterServerEvent('niuNiu:placeBet')
AddEventHandler('niuNiu:placeBet', function(amount)
    local source = source
    -- 檢查玩家是否有足夠的籌碼
    -- 從玩家扣除籌碼
    -- 更新遊戲狀態
end)

RegisterServerEvent('niuNiu:multiplyBet')
AddEventHandler('niuNiu:multiplyBet', function(multiplier)
    local source = source
    -- 檢查是否允許增加倍數
    -- 更新遊戲狀態
end)

RegisterServerEvent('niuNiu:becomeDealer')
AddEventHandler('niuNiu:becomeDealer', function()
    local source = source
    -- 檢查玩家是否有足夠的資產成為莊家
    -- 更新遊戲狀態
end)

function StartNewRound()
    -- 開始新的一輪
    -- 發牌
    -- 計算結果
    -- 分發獎金
end

-- 定時檢查是否應該開始新的一輪
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        -- 檢查遊戲狀態，決定是否開始新的一輪
    end
end)
