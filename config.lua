Config = {}

-- 遊戲設置
Config.MaxPlayers = 9
Config.MinBankForDealer = 10000
Config.TaxPercentage = 5

-- 倍數設置
Config.Multipliers = {
    bull7 = 2,
    bull8 = 2,
    bull9 = 3,
    bullbull = 5
}

-- 籌碼道具
Config.ChipItem = 'casino_chip'

-- 賭桌位置
Config.GameLocations = {
    {x = 1111.11, y = 2222.22, z = 33.33},
    {x = 4444.44, y = 5555.55, z = 66.66}
}

-- 下注限制
Config.MinBet = 100
Config.MaxBet = 10000

-- 莊家最小銀行金額
Config.MinDealerBank = 100000