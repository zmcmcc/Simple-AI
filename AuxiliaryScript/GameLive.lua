--游戏实时状态记录
--bug，暂时不启用该文件，请不要试图调用
--[[
    实现功能
    1、实时记录英雄死亡和击杀数量
    2、根据实时变化获取击杀者
    3、获取场上我方英雄等级、装备和价格总和，敌方最近看到的英雄等级、装备和价格总和
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
    for i,Arrey in pairs(nArreysTeam)
    do
        local hero = GetTeamMember(Arrey)
        local heroName = GetSelectedHeroName(Arrey)
        local heroAbility = J.Skill.GetAbilityList(hero)
        local heroItem = {}
        local heroItemCost = {}

        --物品
        for i = 0, 5 do
            local item = hero:GetItemInSlot(i)
            if item ~= nil then
                heroItem[i] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[i])
            end
        end

        nArreysData[Arrey] = {
            ['hero'] = hero,--指向英雄单位
            ['player'] = Arrey,--玩家id
            ['name'] = heroName,--英雄名称
            ['abilitys'] = heroAbility,--用于获取技能CD？如果需要的话
            ['bot'] = IsPlayerBot(Arrey),--是否是电脑
            ['kill'] = GetHeroKills(Arrey),--击杀数
            ['death'] = GetHeroDeaths(Arrey),--死亡数
            ['assist'] = GetHeroAssists(Arrey),--助攻数
            ['level'] = GetHeroLevel(Arrey),--英雄等级
            ['health'] = hero:GetHealth()/hero:GetMaxHealth(),--当前血量
            ['mana'] = hero:GetMana()/hero:GetMaxMana(),--当前魔法
            ['location'] = hero:GetLocation(),--当前位置
            ['item'] = heroItem,--当前装备
            ['itemCost'] = heroItemCost,--装备总值
            ['gold'] = hero:GetGold(),--当前金钱
            ['buyback'] = hero:HasBuyback(),--买活状态
        }
        
    end

    for i,Enemy in pairs(nEnemysTeam)
    do
        local hero = GetTeamMember(Enemy)
        local heroName = GetSelectedHeroName(Enemy)
        local heroAbility = J.Skill.GetAbilityList(hero)
        local heroItem = {}
        local heroItemCost = {}

        --物品
        for i = 0, 5 do
            local item = hero:GetItemInSlot(i)
            if item ~= nil then
                heroItem[i] = item:GetName()
                heroItemCost = heroItemCost + GetItemCost(heroItem[i])
            end
        end

        nEnemysData[Enemy] = {
            ['hero'] = hero,--指向英雄单位
            ['player'] = Enemy,--玩家id
            ['name'] = heroName,--英雄名称
            ['abilitys'] = heroAbility,--用于获取技能CD？如果需要的话
            ['bot'] = IsPlayerBot(Enemy),--是否是电脑
            ['kill'] = GetHeroKills(Enemy),--击杀数
            ['death'] = GetHeroDeaths(Enemy),--死亡数
            ['assist'] = GetHeroAssists(Enemy),--助攻数
            ['level'] = GetHeroLevel(Enemy),--英雄等级
            ['health'] = hero:GetHealth()/hero:GetMaxHealth(),--当前血量
            ['mana'] = hero:GetMana()/hero:GetMaxMana(),--当前魔法
            ['location'] = hero:GetLocation(),--当前位置
            ['item'] = heroItem,--当前装备
            ['itemCost'] = heroItemCost,--装备总值
            ['gold'] = hero:GetGold(),--当前金钱
            ['buyback'] = hero:HasBuyback(),--买活状态
        }
        
    end

    isInit = true
end

function L.NowKill()
    local nowKillHero = nil
    local nowDeathsHero = nil

    --if not isInit then return end

    for i,Enemy in pairs(nEnemysTeam)
    do
        --local hero = GetTeamMember(Enemy)
        local heroName = GetSelectedHeroName(Arrey)
        local deaths = GetHeroDeaths(Arrey)--死亡数

        --单位被击杀
        if deaths > nEnemysData[heroName]['deaths'] then
            --nowDeathsHero = hero
            nEnemysData[heroName]['deaths'] = deaths
        end
    end

    for i,Arrey in pairs(nArreysTeam)
    do
        --local hero = GetTeamMember(Arrey)
        local heroName = GetSelectedHeroName(Arrey)
        local kills = GetHeroKills(Arrey)--击杀数
        
        --击杀者
        if kills > nArreysData[heroName]['kills'] then
            --nowKillHero = hero
            nArreysData[heroName]['kills'] = kills
        end
        
    end

    --我方某个英雄是否击杀了敌方某个英雄
    if nowKillHero ~= nil 
       and nowDeathsHero ~= nil
    then
        local heroName = nowKillHero:GetUnitName()
        local bot = GetBot()

        nArreysData[heroName]['killEnemy'] = nowDeathsHero

        if nArreysData[heroName]['killTime'] ~= nil then
            if DotaTime() - 5 <= nArreysData[heroName]['killTime'] then --5秒连杀判断
                consecutivekills = consecutivekills + 1
            else
                consecutivekills = 1
                if consecutivekills >= 3 then
                    bot:ActionImmediate_Chat( '○( ＾皿＾)っHiahiahia…', true);
                    --K.killStreakSneer(nowKillHero)--连续击杀嘲讽
                else
                    bot:ActionImmediate_Chat( 'ヾ(￣▽￣)Bye~Bye~', true);
                    --K.killSneer(nowKillHero, nowDeathsHero)--击杀嘲讽
                end
            end
        end
        nArreysData[heroName]['killTime'] = DotaTime()
    end

end

return L