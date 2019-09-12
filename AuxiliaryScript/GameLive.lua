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

local isInit = false
--数据
local nArreysTeam = GetTeamPlayers(GetTeam())
local nEnemysTeam = GetTeamPlayers(GetOpposingTeam())
local nArreysData = {}
local nEnemysData = {}
local consecutivekills = 0

function L.init()

	for i = 1, #nArreysTeam
    do
        local botid = nArreysTeam[i]
		local member = GetTeamMember(botid);
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = {}

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
                ['abilitys'] = J.Skill.GetAbilityList(hero),--用于获取技能CD？如果需要的话
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
            }
        end
        
    end

    for i = 1, #nEnemysTeam
    do
        local botid = nArreysTeam[i]
        local member = GetTeamMember(i);
        
        if member ~= nil then
            local heroItem = {}
            local heroItemCost = {}
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

    isInit = true
end

function L.Updat()
    if not isInit then return end

    for i,data in nArreysData
    do
        local heroItem = {}
        local heroItemCost = {}
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
        if GetHeroKills(botid) > data['kill'] then
            for _,eData in nArreysData
                if Edata['death'] < GetHeroDeaths(eData['player']) then
                    nArreysData[i]['killhero'] = eData['name'] --击杀的敌人
                end
            end
        end

        --被哪个敌人击杀
        if GetHeroDeaths(botid) > data['death'] then
            for _,eData in nArreysData
                if Edata['kill'] < GetHeroKills(eData['player']) then
                    nArreysData[i]['herokill'] = eData['name'] --被敌人击杀
                end
            end
        end

        nArreysData[i]['kill'] = GetHeroKills(botid),--击杀数
        nArreysData[i]['death'] = GetHeroDeaths(botid),--死亡数
        nArreysData[i]['assist'] = GetHeroAssists(botid),--助攻数
        nArreysData[i]['level'] = GetHeroLevel(botid),--英雄等级
        nArreysData[i]['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
        nArreysData[i]['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
        nArreysData[i]['location'] = member:GetLocation(),--当前位置
        nArreysData[i]['item'] = heroItem,--当前装备
        nArreysData[i]['itemCost'] = heroItemCost,--装备总值
        nArreysData[i]['gold'] = member:GetGold(),--当前金钱
        nArreysData[i]['buyback'] = member:HasBuyback(),--买活状态

        nArreysData[i]['alive'] = member:IsAlive(),--是否存活
        
    end

    for i,data in nEnemysTeam
    do
        local heroItem = {}
        local heroItemCost = {}
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

        nEnemysTeam[i]['kill'] = GetHeroKills(botid),--击杀数
        nEnemysTeam[i]['death'] = GetHeroDeaths(botid),--死亡数
        nEnemysTeam[i]['assist'] = GetHeroAssists(botid),--助攻数
        nEnemysTeam[i]['level'] = GetHeroLevel(botid),--英雄等级
        nEnemysTeam[i]['health'] = member:GetHealth()/member:GetMaxHealth(),--当前血量
        nEnemysTeam[i]['mana'] = member:GetMana()/member:GetMaxMana(),--当前魔法
        nEnemysTeam[i]['location'] = botLocation,--位置
        nEnemysTeam[i]['seentime'] = botSeenTime,--丢失时间
        nEnemysTeam[i]['item'] = heroItem,--当前装备
        nEnemysTeam[i]['itemCost'] = heroItemCost,--装备总值

        nEnemysTeam[i]['alive'] = member:IsAlive(),--是否存活
        
    end
end

--场上局势判断
function L.Situation()
    
end

return L