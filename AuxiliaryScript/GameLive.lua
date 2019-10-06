--游戏实时状态记录
--[[
    实现功能
    1、实时记录英雄死亡和击杀数量√
    2、根据实时变化获取击杀者√
    3、获取场上我方英雄等级、装备和价格总和，敌方最近看到的英雄等级、装备和价格总和√
    4、根据上一项获取的数据判断当前优势劣势
    5、根据场上装备数据判断双方物抗、魔抗、物攻、魔攻、控制、逃生、影身等能力值
    6、获取场上塔的状态、兵线的状态、敌人最后的位置、我方英雄的位置、状态（血量、魔量、tpcd、买活状态）
    7、根据场上状态获取3路危险程度、双方野区危险程度
]]


local L = {}
local C  = require(GetScriptDirectory()..'/FunLib/jmz_chat')

local isInit = false
--数据
local nArreysTeam = GetTeamPlayers(GetTeam())
local nEnemysTeam = GetTeamPlayers(GetOpposingTeam())
local nArreysData = {}
local nEnemysData = {}
local consecutivekills = 0

--计时
local killInTime = 0 --上一次击杀时间
local dieInTime = 0 --上一次死亡时间

--击杀、死亡
local evenKillStatistics = 0
local evenDeathStatistics = 0

--发言冷却

function L.init()

    if not isInit then
	for i = 1, #nArreysTeam
    do
        local botid = nArreysTeam[i]
		local member = GetTeamMember(botid);
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = 0

            --物品
            for t = 0, 5 do
                local item = member:GetItemInSlot(t)
                if item ~= nil then
                    heroItem[t] = item:GetName()
                    heroItemCost = heroItemCost + GetItemCost(heroItem[t])
                end
            end
            
            nArreysData[botid] = {
                ['hero'] = member,--指向英雄单位
                ['player'] = botid,--玩家id
                ['name'] = GetSelectedHeroName(botid),--英雄名称
                ['bot'] = IsPlayerBot(botid),--是否是电脑
                ['kill'] = GetHeroKills(botid),--击杀数
                ['death'] = GetHeroDeaths(botid),--死亡数
                ['assist'] = GetHeroAssists(botid),--助攻数
                ['level'] = GetHeroLevel(botid),--英雄等级
                ['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
                ['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
                ['location'] = member:GetLocation(),--当前位置
                ['item'] = heroItem,--当前装备
                ['itemCost'] = heroItemCost,--装备总值
                ['gold'] = member:GetGold(),--当前金钱
                ['buyback'] = member:HasBuyback(),--买活状态
                ['killhero'] = '',
                ['herokill'] = '',
            }
        end
        
    end
    for i = 1, #nEnemysTeam
    do
        local botid = nEnemysTeam[i]
        local member = GetTeamMember(i);
        
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = 0
            local info = GetHeroLastSeenInfo(botid)

            --物品,有待确认能否生效
            for t = 0, 5 do
                local item = member:GetItemInSlot(t)
                if item ~= nil then
                    heroItem[t] = item:GetName()
                    heroItemCost = heroItemCost + GetItemCost(heroItem[t])
                end
            end

            --位置
            local botLocation = member:GetLocation()
            local botSeenTime = 0
            if botLocation == nil then
                local dInfo = info[1];
                if dInfo ~= nil then
                    botLocation = dInfo.location --单位曾经的位置
                    botSeenTime = dInfo.time_since_seen --上次看到的时间
                end
            end

            nEnemysData[botid] = {
                ['hero'] = member,--指向英雄单位
                ['player'] = botid,--玩家id
                ['name'] = GetSelectedHeroName(botid),--英雄名称
                ['bot'] = IsPlayerBot(botid),--是否是电脑
                ['kill'] = GetHeroKills(botid),--击杀数
                ['death'] = GetHeroDeaths(botid),--死亡数
                ['assist'] = GetHeroAssists(botid),--助攻数
                ['level'] = GetHeroLevel(botid),--英雄等级
                ['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
                ['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
                ['location'] = botLocation,--位置
                ['seentime'] = botSeenTime,--丢失时间
                ['item'] = heroItem,--当前装备
                ['itemCost'] = heroItemCost,--装备总值
            }
        end

    end
    end

    isInit = true
end

function L.Update()
    
    local bot = GetBot()

    for i,data in pairs(nArreysData)
    do
        local heroItem = {}
        local heroItemCost = 0
        local botid = data['player']
        local member = data['hero']

        --物品
        for t = 0, 5 do
            local item = member:GetItemInSlot(t)
            if item ~= nil then
                heroItem[t] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[t])
            end
        end

        --击杀了哪个敌人
        if GetHeroKills(botid) ~= data['kill'] then
            
            for l = 1, #nEnemysTeam do
                if GetHeroDeaths(nEnemysTeam[l]) > nEnemysData[nEnemysTeam[l]]['death'] then
                    nArreysData[i]['killhero'] = nEnemysData[nEnemysTeam[l]]['name']
                    print(data['name']..'击杀了'..nEnemysData[nEnemysTeam[l]]['name'])
                    L.Chatwheel(true, nArreysData[i])
                end
            end

        end

        --被哪个敌人击杀
        if GetHeroDeaths(botid) > data['death'] then
            --被击杀后检查双方装备差距
            local situation = L.Situation()
            print('装备差:'..situation['itemDifference'])
            if situation['itemDifference'] < -0.4 then
                --data['hero']:ActionImmediate_Chat('小心了，敌人的装备比我们强大！', false)
                bot:ActionImmediate_Chat('小心了，敌人的装备比我们强大！', false)
            end
            for _,eData in pairs(nArreysData) do
                if eData['itemCost'] / (situation['enemyItemCost'] / 5) > 0.5
                    and  eData['itemCost'] > situation['arreyItemCost'] / 5 
                then
                    --data['hero']:ActionImmediate_Chat('谨慎对待 '..C.GetNormName(eData['hero'])..' ，他的装备远远强于他的队友，并且比我们的装备平均强度要高。', false)
                    bot:ActionImmediate_Chat('谨慎对待 '..C.GetNormName(eData['hero'])..' ，他的装备远远强于他的队友，并且比我们的装备平均强度要高。', false)
                end
            end

        end

        nArreysData[i]['kill'] = GetHeroKills(botid)--击杀数
        nArreysData[i]['death'] = GetHeroDeaths(botid)--死亡数
        nArreysData[i]['assist'] = GetHeroAssists(botid)--助攻数
        nArreysData[i]['level'] = GetHeroLevel(botid)--英雄等级
        nArreysData[i]['health'] = member:GetHealth()/member:GetMaxHealth()--当前血量
        nArreysData[i]['mana'] = member:GetMana()/member:GetMaxMana()--当前魔法
        nArreysData[i]['location'] = member:GetLocation()--当前位置
        nArreysData[i]['item'] = heroItem--当前装备
        nArreysData[i]['itemCost'] = heroItemCost--装备总值
        nArreysData[i]['gold'] = member:GetGold()--当前金钱
        nArreysData[i]['buyback'] = member:HasBuyback()--买活状态

        nArreysData[i]['alive'] = member:IsAlive()--是否存活
        
    end

    for i,data in pairs(nEnemysData)
    do
        local heroItem = {}
        local heroItemCost = 0
        local botid = data['player']
        local member = data['hero']

        --物品
        for t = 0, 5 do
            local item = member:GetItemInSlot(t)
            if item ~= nil then
                heroItem[t] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[t])
            end
        end

        --位置
        local botLocation = member:GetLocation()
        local botSeenTime = 0
        if botLocation == nil then
            local dInfo = info[1];
            if dInfo ~= nil then
                botLocation = dInfo.location --单位曾经的位置
                botSeenTime = dInfo.time_since_seen --上次看到的时间
            end
        end

        nEnemysData[i]['kill'] = GetHeroKills(botid)--击杀数
        nEnemysData[i]['death'] = GetHeroDeaths(botid)--死亡数
        nEnemysData[i]['assist'] = GetHeroAssists(botid)--助攻数
        nEnemysData[i]['level'] = GetHeroLevel(botid)--英雄等级
        nEnemysData[i]['health'] = member:GetHealth()/member:GetMaxHealth()--当前血量
        nEnemysData[i]['mana'] = member:GetMana()/member:GetMaxMana()--当前魔法
        nEnemysData[i]['location'] = botLocation--位置
        nEnemysData[i]['seentime'] = botSeenTime--丢失时间
        nEnemysData[i]['item'] = heroItem--当前装备
        nEnemysData[i]['itemCost'] = heroItemCost--装备总值

        nEnemysData[i]['alive'] = member:IsAlive()--是否存活
        
    end

    --清除过长时间的击杀数据
    if killInTime - DotaTime() > 15 then
        evenKillStatistics = 0
    end
    --清除过长时间的死亡数据
    if dieInTime - DotaTime() > 15 then
        evenDeathStatistics = 0
    end
end

--场上局势判断
--winRate 胜率
--itemDifference 装备差
function L.Situation()
    local itemDifference = 0

    local arreyItemCost = 0
    local enemyItemCost = 0
    
    for _,data in pairs(nArreysData)
    do
        arreyItemCost = arreyItemCost + data['itemCost']
    end
    for _,data in pairs(nEnemysData)
    do
        enemyItemCost = enemyItemCost + data['itemCost']
    end

    itemDifference = (arreyItemCost / enemyItemCost) - 1

    local data = {
        ['arreyItemCost'] = arreyItemCost,
        ['enemyItemCost'] = enemyItemCost,
        ['itemDifference'] = itemDifference,
    }
    return data
    
    
end

--我方受到伤害类型强度
--contrast 比例
--types 强类型
function L.DamageTypeStatistics()

end

--轮盘嘲讽
function L.Chatwheel(kill, bot)
    local mocking = {
        ['doublekill'] = {--连杀
            '头部撞击',
            '猢狲把戏',
        },
        ['ace'] = {--团灭
            '你气不气？',
            '头部撞击',
            'what are you cooking？boom！',
        },
        ['buyace'] = {--买活团灭
            '你气不气？',
            '头部撞击',
            '这波不亏666',
            'what are you cooking？boom！',
        },
        ['gank'] = {--单抓
            '你气不气？',
            'what are you cooking？boom！',
            '猢狲把戏',
            '好走，不送',
        }
    }
    if kill then 
        if killInTime - DotaTime() <= 5 then -- 3秒内击杀 连杀
            evenKillStatistics = evenKillStatistics + 1
        else
            evenKillStatistics = 1
        end
        speech(true, mocking['buyace'], bot)
        print('击杀者'..bot['name'])
        if evenKillStatistics >= 6 
            and evenDeathStatistics < 5 --我方没被团灭
        then --买活团灭
            speech(true, mocking['buyace'], bot)
        elseif evenKillStatistics == 5 
            and evenDeathStatistics < 5 --我方没被团灭
        then --团灭
            speech(true, mocking['ace'], bot)
        elseif evenKillStatistics >= 3 
            and evenDeathStatistics < evenKillStatistics --我方死的没对方多
        then --大规模团
            speech(true, mocking['doublekill'], bot)
        elseif evenKillStatistics > 1 
            and evenDeathStatistics < evenKillStatistics --我方死的没对方多
        then --多人死亡
            speech(true, mocking['doublekill'], bot)
        elseif evenKillStatistics == 1 
            and evenDeathStatistics == 0 --我方没死
        then --抓单击杀
            speech(true, mocking['gank'], bot)
        end

        killInTime = DotaTime()
    else
        if dieInTime - DotaTime() <= 5 then  -- 3秒内击杀 连杀
            evenDeathStatistics = evenDeathStatistics + 1
        else
            evenDeathStatistics = 1
        end

        if evenDeathStatistics == 1 
            and evenKillStatistics == 0
        then --抓单击杀
            speech(true, mocking['gank'], bot)
        end

        dieInTime = DotaTime()
    end
end

function speech(team, mocking, bot)
    local text = mocking[RandomInt(1, #mocking)]
    local spbot = GetBot()
    local heroname = C.GetNormName(bot['hero'])
    local killname = C.GetCnName(bot['killhero'])
    spbot:ActionImmediate_Chat(killname..' '..text, team)
    evenDeathStatistics = 0
    evenKillStatistics = 0
end

return L