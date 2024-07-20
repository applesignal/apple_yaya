Config = {}

Config.TablePositions = {
    {x = 1000.0, y = 2000.0, z = 30.0},
    {x = 1010.0, y = 2010.0, z = 30.0},
    -- 添加更多賭桌位置
}

Config.MaxPlayers = 9
Config.MinBankBalance = 1000000 -- 上莊最低資產要求
Config.HouseEdgePercentage = 5 -- 每局抽取的公款百分比

Config.Multipliers = {
    [7] = 2,
    [8] = 2,
    [9] = 3,
    [10] = 5 -- 牛牛
}

Config.ChipItem = 'casino_chip' -- 籌碼道具名稱
Config.MaxBet = 1000000 -- 最大下注金額