--  英雄阵容搭配和克制库
--  电脑可选英雄在推荐列表中建议增加权重，针对阵容同理
local allowsHeroData = require(GetScriptDirectory() .. "/AuxiliaryScript/GetAllowHeroData")
local bnUtil = require(GetScriptDirectory() .. "/AuxiliaryScript/BotNameUtility");
local apHeroList = {}
local banList = {}
local interestingMode = nil
local interestingList = {}
local interestingSuccession = 1

local X = {}

X["allows_hero"] = allowsHeroData.hero--[[{
    ----冥界亚龙
	["npc_dota_hero_viper"] = {
        ['hero_name'] = '冥界亚龙',
		['proposal'] = { --推荐阵容
            { --复仇之魂
                ['hero'] = 'npc_dota_hero_vengefulspirit', --英雄
                ['weight'] = 3, --权重
            },
            { --暗影萨满
                ['hero'] = 'npc_dota_hero_shadow_shaman',
                ['weight'] = 3,
            },
            { --水晶室女
                ['hero'] = 'npc_dota_hero_crystal_maiden',
                ['weight'] = 4,
            },
            { --食人魔魔法师
                ['hero'] = 'npc_dota_hero_ogre_magi',
                ['weight'] = 3,
            },
            { --天穹守望者
                ['hero'] = 'npc_dota_hero_arc_warden',
                ['weight'] = 4,
            },
        },
		['counter'] = { --针对阵容
            { --剑圣
                ['hero'] = 'npc_dota_hero_juggernaut', --英雄
                ['weight'] = 3, --权重
            },
            { --哈斯卡
                ['hero'] = 'npc_dota_hero_huskar',
                ['weight'] = 3,
            },
            { --裂魂人
                ['hero'] = 'npc_dota_hero_spirit_breaker',
                ['weight'] = 3,
            },
            { --痛苦女王
                ['hero'] = 'npc_dota_hero_queenofpain',
                ['weight'] = 3,
            },
        },
        ['orientation'] = { --英雄定位
            ['core'] = true, --核心
            ['durable'] = true, --耐久
        },
        ['attribute'] = { --英雄属性
            ['type'] = 'Agile', --类型 力量：Power 敏捷：Agile 智力：Intelligence
        },
        ['bot'] = true, --电脑可选
    },
}]]

--当前英雄池
--'npc_dota_hero_vengefulspirit',
--'npc_dota_hero_shadow_demon',
--'npc_dota_hero_tidehunter',
--'npc_dota_hero_disruptor',
--'npc_dota_hero_axe',
--'npc_dota_hero_leshrac',
--'npc_dota_hero_batrider',
--'npc_dota_hero_dazzle',
--'npc_dota_hero_abaddon',
--'npc_dota_hero_grimstroke',
--'npc_dota_hero_puck',
--'npc_dota_hero_invoker',
--'npc_dota_hero_centaur',
--'npc_dota_hero_faceless_void',
--'npc_dota_hero_obsidian_destroyer',
--'npc_dota_hero_queenofpain',
--'npc_dota_hero_slardar',
--'npc_dota_hero_omniknight',
--'npc_dota_hero_rubick',
----原脚本
--'npc_dota_hero_antimage',
--'npc_dota_hero_arc_warden',
--'npc_dota_hero_bloodseeker',
--'npc_dota_hero_bristleback',
--'npc_dota_hero_chaos_knight',
--'npc_dota_hero_crystal_maiden',
--'npc_dota_hero_dragon_knight',
--'npc_dota_hero_drow_ranger',
--'npc_dota_hero_jakiro',
--'npc_dota_hero_kunkka',
--'npc_dota_hero_luna',
--'npc_dota_hero_medusa',
--'npc_dota_hero_necrolyte',
--'npc_dota_hero_nevermore',
--'npc_dota_hero_phantom_assassin',
--'npc_dota_hero_silencer',
--'npc_dota_hero_skeleton_king',
--'npc_dota_hero_sniper',
--'npc_dota_hero_sven',
--'npc_dota_hero_templar_assassin',
--'npc_dota_hero_viper',
--'npc_dota_hero_warlock',
--'npc_dota_hero_zuus',
--'npc_dota_hero_skywrath_mage',
--'npc_dota_hero_razor',
--'npc_dota_hero_phantom_lancer',
--'npc_dota_hero_ogre_magi',
--'npc_dota_hero_lina',

X["test_hero"] = {
}

X["onlyCM_hero"] = {
    --'npc_dota_hero_abaddon',
    'npc_dota_hero_vengefulspirit',
    'npc_dota_hero_disruptor',
    --'npc_dota_hero_shadow_demon',
    --'npc_dota_hero_grimstroke',
    'npc_dota_hero_tidehunter',
    'npc_dota_hero_axe',
    --'npc_dota_hero_dazzle',
    'npc_dota_hero_leshrac',
    'npc_dota_hero_batrider',
    'npc_dota_hero_puck',
    'npc_dota_hero_invoker',
}

function X.CounterWeightList(hero) --获取推荐阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroCounter = X["allows_hero"][hero]['restrained'];
    local counterList = {};
    if heroCounter == nil then return nil end;
    for _,value in pairs(heroCounter) do
        counterList[value['hero']] = value['weight'];
        --for w = value['weight'], 0, -1 do
        --    table.insert(counterList,value['hero']);
        --end
	end
	return counterList;
end

function X.RestraintWeightList(hero) --获取针对阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroCounter = X["allows_hero"][hero]['restraint'];
    local counterList = {};
    if heroCounter == nil then return nil end;
    for _,value in pairs(heroCounter) do
        counterList[value['hero']] = value['weight'];
	end
	return counterList;
end

function X.ProposalWeightList(hero) --获取被针对阵容列表
	if X["allows_hero"][hero] == nil then return nil end;
    local heroProposal = X["allows_hero"][hero]['proposal'];
    local proposalList = {};
    if heroProposal == nil then return nil end;
    for _,value in pairs(heroProposal) do
        proposalList[value['hero']] = value['weight'];
        --if weight then
        --    for w = value['weight'], 0, -1 do
        --        table.insert(proposalList,value['hero']);
        --    end
        --else
        --    table.insert(proposalList,value['hero']);
        --end
	end
	return proposalList;
end

function X.ScreeningHeroList(list,hero)--排除已选英雄 全部已选列表 待选英雄
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == hero then
                return false;
            end
        end
        return true;
    else
        return false;
    end
end

function X.OptionalHeroList()--可选英雄列表
    local heroList = {};
    for key,i in pairs(X['allows_hero']) do
        if i['bot'] then
            table.insert(heroList,key);
        end
    end
    return heroList;
end

function X.SelectHero(hero)--判断英雄是否可选
    local heroList = X.OptionalHeroList();
    for _,i in pairs(heroList) do
        if i == hero and IsCMBannedHero(hero) then
            return true
        end
    end
    return false;
end

function X.BreakUpList(list)--打散数组
	local _result = {}
    local _index = 1
    while #list ~= 0 do
        local ran = math.random(0,#list)
        if list[ran] ~= nil then
            _result[_index] = list[ran]
            table.remove(list,ran)
            _index = _index + 1
        end
    end
    return _result
end

function X.RemoveRepeat(a)--去重
    local b = {}
    for k,v in ipairs(a) do
        if(#b == 0) then
            b[1]=v;
        else
            local index = 0
            for i=1,#b do
                if(v == b[i]) then
                    break
                end
                index = index + 1
            end
            if(index == #b) then
                b[#b + 1] = v;
            end
        end
    end
    return b
end

--随机获取列表中的英雄
function RandomHero(herolist)
	local hero = herolist[RandomInt(1, #herolist)];
	while ( IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) ) 
	do
        hero = herolist[RandomInt(1, #herolist)];
    end
	return hero;
end

function X.AllLibraryHeroList()
    local HeroSelect = {}
    local HeroBan = {}
    local Herolist = {}

    for key,value in pairs(X['allows_hero']) do
        table.insert(Herolist,key);
        for _,v in pairs(X.CounterWeightList(key)) do
            table.insert(Herolist,v);
        end
        for _,v in pairs(X.ProposalWeightList(key)) do
            table.insert(Herolist,v);
        end
    end
    Herolist = X.RemoveRepeat(Herolist);
    --Herolist中现在拥有所有库中记载的英雄
    --for _,value in pairs(Herolist) do
    --    if IsCMBannedHero(value) then
    --        table.insert(HeroBan,value);
    --    end
    --    if IsCMPickedHero(GetTeam(), value) then
    --        table.insert(HeroSelect,value);
    --    end
    --end
    return {
        ['Herolist'] = Herolist,
        --['HeroSelect'] = HeroSelect,
        --['HeroBan'] = HeroBan,
    }
end

function IsBanBychat( sHero )

	for i = 1,#banList
	do
		if banList[i] ~= nil
		   and string.find(sHero, banList[i])
		then
			return true;
		end	
	end
	
	return false;
end

function GetNotRepeatHero(nTable)
    --仅限CM选择英雄
    --if next(X['onlyCM_hero']) ~= nil then
    --    local testheroList = {};
    --    for i, v in ipairs(nTable) do
    --        if X.ScreeningHeroList(X['onlyCM_hero'],v) then
    --            table.insert(testheroList,v);
    --        end
    --    end
    --    if next(testheroList) ~= nil then
    --        nTable = testheroList;
    --    end
    --end
	
	local sHero = nTable[1];
	local maxCount = #nTable ;
	local rand = 0;
    local BeRepeated = false;
    
	
	for count = 1, maxCount
	do
		rand = RandomInt(1, #nTable);
		sHero = nTable[rand];
		BeRepeated = false;
		for id = 0, 20
		do
			if ( IsTeamPlayer(id) and GetSelectedHeroName(id) == sHero )
				or ( IsCMBannedHero(sHero) )
				or ( IsBanBychat(sHero) )
			then
				BeRepeated = true;
				table.remove(nTable,rand);
				break;
			end
		end
		if not BeRepeated then break; end
	end
	return sHero;		
end

--以下为测试内容
function X.TypeWeight(ourHero,hero)--类型权重考量
    --local tIntelligence = 5 - #ourHero;
    local tIntelligence = 0;
    --print('-------- 数组总量 ------');
    --print(tIntelligence);
    --print('-------- 遍历列表 ------');
    --if next(ourHero) ~= nil and next(X['allows_hero'][hero]) ~= nil then
    --    for _key,value in pairs(ourHero) do
    --        --print(value);
    --        --print(value);
    --        if value ~= '' and X['allows_hero'][value]['type'] == X['allows_hero'][hero]['type'] then
    --            tIntelligence = tIntelligence - 1;
    --        end
    --    end
    --else
    --    tIntelligence = 0;
    --end
    --print('--------  结束  ------');
    --print(tIntelligence);
    return tIntelligence;
end

function X.TeamToObtain()--获取全阵营已选英雄
    local heroTeam = nil;
	local ourIds = GetTeamPlayers(GetTeam());
	local enemyIds = GetTeamPlayers(GetOpposingTeam());
	local botSelectHero = nil;
    local apHeroList = {};

    local ourHero = {};
    local enemyHero = {};
    local screeningList = {};

    local against = {};
    local targeted = {};

    local retext = '我们可以克制对方的 ';

    for i,id in pairs(ourIds) --找出我方已选英雄
	do
		if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
		then
			if GetTeam() == TEAM_RADIANT then
				apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
			else
				apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
			end
		end
	end

	for i,id in pairs(enemyIds) --找出对方已选英雄
	do
		if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
		then
			if GetTeam() == TEAM_RADIANT then
				apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
			else
				apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
			end
		end
    end

    for key,value in pairs(apHeroList) do
        if value == GetTeam() then
            table.insert(ourHero,key);
        else
            table.insert(enemyHero,key);
        end
    end

    for _key,value in pairs(enemyHero) do
        local priorityList = X.ProposalWeightList(value);
        if priorityList ~= nil then
            for _hero,i in pairs(priorityList) do
                for j,_ourHero in pairs(ourHero) do
                    if _ourHero == _hero and not X.ScreeningHeroList(against,_hero) then
                        table.insert(against, X["allows_hero"][value]['hero_name']);
                    end
                end
            end
        end
    end

    for _key,value in pairs(ourHero) do
        local enemyList = X.ProposalWeightList(value);
        if enemyList ~= nil then
            for _hero,i in pairs(enemyList) do
                for j,_ourHero in pairs(enemyHero) do
                    if _ourHero == _hero and not X.ScreeningHeroList(targeted,_ourHero) then
                        table.insert(targeted, X["allows_hero"][_ourHero]['hero_name']);
                    end
                end
            end
        end
    end

    
    retext = retext.. table.concat(against,", ");
    retext = retext.. ' 但是会被对方 ';
    retext = retext.. table.concat(targeted,", ");
    retext = retext.. ' 克制';
    
    return retext;
end

--其他文件索引
function X.GetDota2Team()
    return bnUtil.GetDota2Team();
end

--主函数
function X.IntelligentBannedHeroListAnalysis(apHeroList)
    local ourHero = {};
    local enemyHero = {};
    local tempHeroList = {};
    local tempBeAimedHeroList = {};
    local screeningList = {};

    if next(apHeroList) ~= nil then
        --列出已上阵列表
        for key,value in pairs(apHeroList) do
            if value == GetTeam() then
                table.insert(ourHero,key);
            else
                table.insert(enemyHero,key);
            end
            if key ~= '' then
                table.insert(screeningList,key);
            end
        end
        if next(screeningList) == nil then
            --没有成功获取到上阵列表，可能真的是空的
            local selectHero = X.AllLibraryHeroList()['Herolist'];
            return RandomHero(selectHero);
        end
    else
        --没有任何上阵英雄，发出全列表
        local selectHero = X.AllLibraryHeroList()['Herolist'];
        return RandomHero(selectHero);
    end

    if next(ourHero) ~= nil then
        for _key,value in pairs(ourHero) do
            local priorityList = X.ProposalWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        table.insert(tempHeroList,_hero);
                    end
                end
            end
        end
    end

    if next(enemyHero) ~= nil then
        for _key,value in pairs(enemyHero) do
            local priorityList = X.CounterWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        table.insert(tempHeroList,_hero);
                    end
                end
            end
        end
    end

    if next(tempHeroList) ~= nil then
        for k,i in pairs(tempHeroList) do
            if IsCMPickedHero(GetTeam(), i) or IsCMPickedHero(GetOpposingTeam(), i) or IsCMBannedHero(i) then
                table.remove(tempHeroList,k);
            end
        end
    end

    local banhero = ''

    if next(tempHeroList) ~= nil then
        banhero = RandomHero(tempHeroList);
    else
        banhero = RandomHero(X.AllLibraryHeroList()['Herolist']);
    end

    return banhero

end

function X.getApHero()
    local heroTeam = nil;
	local ourIds = GetTeamPlayers(GetTeam());
	local enemyIds = GetTeamPlayers(GetOpposingTeam());
    local botSelectHero = nil
    --趣味模式
    if interestingMode == nil then
        local randomMode = math.random(0,1000)
        if randomMode == 234 then
            interestingMode = '拉比克大魔王'
            interestingList = {
                'npc_dota_hero_rubick',
                'npc_dota_hero_rubick',
                'npc_dota_hero_rubick',
                'npc_dota_hero_rubick',
                'npc_dota_hero_rubick',
            }
        elseif randomMode == 587 then
            interestingMode = '刺球'
            interestingList = {
                'npc_dota_hero_bristleback',
                'npc_dota_hero_bristleback',
                'npc_dota_hero_bristleback',
                'npc_dota_hero_bristleback',
                'npc_dota_hero_bristleback',
            }
        elseif randomMode == 724 then
            interestingMode = '刺客联盟'
            interestingList = {
                'npc_dota_hero_phantom_assassin',
                'npc_dota_hero_templar_assassin',
                'npc_dota_hero_phantom_assassin',
                'npc_dota_hero_templar_assassin',
                'npc_dota_hero_phantom_assassin',
            }
        elseif randomMode == 984 then
            interestingMode = '闪电'
            interestingList = {
                'npc_dota_hero_arc_warden',
                'npc_dota_hero_zuus',
                'npc_dota_hero_razor',
                'npc_dota_hero_disruptor',
                'npc_dota_hero_lina',
            }
        else
            interestingMode = 'Normal'
        end
    end

	if GetTeam() == TEAM_RADIANT 
	then
		heroTeam = TEAM_RADIANT;
	elseif GetTeam() == TEAM_DIRE
	then
		heroTeam = TEAM_DIRE;
    end
    
    if interestingMode == 'Normal' then
        for i,id in pairs(ourIds) --找出我方已选英雄
        do
            if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
            then
                if GetTeam() == TEAM_RADIANT then
                    apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
                else
                    apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
                end
            end
        end

        for i,id in pairs(enemyIds) --找出对方已选英雄
        do
            if GetSelectedHeroName(id) ~= "" or GetSelectedHeroName(id) ~= nil
            then
                if GetTeam() == TEAM_RADIANT then
                    apHeroList[GetSelectedHeroName(id)] = TEAM_DIRE;
                else
                    apHeroList[GetSelectedHeroName(id)] = TEAM_RADIANT;
                end
            end
        end

        botSelectHero = X.IntelligentHeroListAnalysis(apHeroList); --智能库去筛选合适的英雄队列

        local botHero;
        if next(botSelectHero) ~= nil then
            --print('采用匹配库生成目标英雄串');
            botHero = GetNotRepeatHero(botSelectHero);
            apHeroList[botHero] = heroTeam;
        else
            --print('采用英雄库生成目标英雄串');
            botHero = GetNotRepeatHero(X.OptionalHeroList()); --智能筛选都筛不出能选的，只好在全英雄可选中随便挑一个能用的了
            apHeroList[botHero] = heroTeam;
        end
    else
        botHero = interestingList[interestingSuccession]
        interestingSuccession = interestingSuccession + 1
    end

    return botHero
end

function X.IntelligentHeroListAnalysis(apHeroList)
    --英雄列表分析
    --我方列表ourHero
    --敌方列表enemyHero
    
    local ourHero = {};
    local enemyHero = {};
    local tempHeroList = {};
    local tempBeAimedHeroList = {};
    local screeningList = {};
    if next(apHeroList) ~= nil then
        --列出已上阵列表
        for key,value in pairs(apHeroList) do
            if value == GetTeam() then
                table.insert(ourHero,key);
            else
                table.insert(enemyHero,key);
            end
            --print(key);
            if key ~= '' then
                table.insert(screeningList,key);
            end
        end
        if next(screeningList) == nil then
            --没有成功获取到上阵列表，可能真的是空的
            local selectHero = X.OptionalHeroList();
            return selectHero;
        end
    else
        --没有任何上阵英雄，发出全列表
        local selectHero = X.OptionalHeroList();
        return selectHero;
    end

    --优先选择需要测试的英雄
    if next(X['test_hero']) ~= nil then
        local testheroList = {};
        for i, v in ipairs(X['test_hero']) do
            if X.ScreeningHeroList(screeningList,v) then
                table.insert(testheroList,v);
            end
        end
        if next(testheroList) ~= nil then
            return testheroList;
        end
    end

    if next(ourHero) ~= nil then
        --将我方推荐阵容筛选为待选临时列表
        for _key,value in pairs(ourHero) do
            local priorityList = X.CounterWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        --print(_hero);
                        local typeWeight = X.TypeWeight(ourHero,_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] + _weight + typeWeight;
                        else
                            tempHeroList[_hero] = _weight + typeWeight;
                        end
                        --考虑cm模式Ban人取消绝对值
                        --if tempHeroList[_hero] < 0 then
                        --    --if tempHeroList[_hero] < -2; then
                        --    --    tempHeroList[_hero] = nil;
                        --    --else
                        --        tempHeroList[_hero] = 0;
                        --    --end
                        --end
                    end
                end
            end
        end
        if next(enemyHero) ~= nil then --如果敌方还未选英雄，则不进一步操作
        --将我方克制敌方英雄加入临时列表 （取消逻辑）
        --for _key,value in pairs(ourHero) do
        --    local priorityList = X.RestraintWeightList(value);
        --    if priorityList ~= nil then
        --        for _hero,_weight in pairs(priorityList) do
        --            for _,_ehero in pairs(enemyHero) do --遍历敌方列表
        --                if _ehero == _hero then --如果在我方克制列表中发现可以克制地方的英雄
        --                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
        --                        if tempHeroList[_hero] ~= nil then
        --                            tempHeroList[_hero] = tempHeroList[_hero] + _weight;
        --                        else
        --                            tempHeroList[_hero] = _weight;
        --                        end
        --                    end
        --                end
        --            end
        --        end
        --    end
        --end
        --将敌方的克制英雄加入待选临时列表
        for _key,value in pairs(enemyHero) do
            local priorityList = X.ProposalWeightList(value);
            if priorityList ~= nil then
                for _hero,_weight in pairs(priorityList) do
                    if X.ScreeningHeroList(screeningList,_hero) and X.SelectHero(_hero) then
                        --print(_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] + _weight;
                        else
                            tempHeroList[_hero] = _weight;
                        end
                    end
                end
            end
        end
        --将敌方已选克制临时列表中的英雄删除
        for _key,value in pairs(tempHeroList) do
            local enemyList = X.ProposalWeightList(value);
            if enemyList ~= nil then
                for _hero,_weight in pairs(enemyList) do
                    if _hero == value then
                        --print(_hero);
                        if tempHeroList[_hero] ~= nil then
                            tempHeroList[_hero] = tempHeroList[_hero] - _weight;
                            --考虑cm模式Ban人取消绝对值
                            --if tempHeroList[_hero] < 0 then
                            --    tempHeroList[_hero] = 0;
                            --end
                        end
                    end
                end
            end
        end
        end
        --此时tempHeroList中的英雄为我方已选英雄的最佳拍档或敌方的克制英雄并且不被对方针对(包含权重)
        --转换权重为列表
        if next(tempHeroList) ~= nil then
            local conclusionHeroList = {};
            for _hero,_weight in pairs(tempHeroList) do
                for i = 1, _weight do
                    table.insert(conclusionHeroList,_hero);
                end
            end
            conclusionHeroList = X.BreakUpList(conclusionHeroList);--乱序
            return conclusionHeroList;
        else
            --过分了，发出全列表
            local selectHero = X.OptionalHeroList();
            for k,i in pairs(selectHero) do
                if not X.ScreeningHeroList(screeningList,i) then
                    table.remove(selectHero,k);
                end
            end
            return selectHero;
        end
    else --
        if next(enemyHero) ~= nil then
            --将敌方的克制英雄加入待选临时列表
            for _key,value in pairs(enemyHero) do
                local priorityList = X.ProposalWeightList(value);
                if priorityList ~= nil then
                    for _,i in pairs(priorityList) do
                        if X.ScreeningHeroList(screeningList,i) and X.SelectHero(i) then
                            --print(i);
                            table.insert(tempHeroList,i);
                        end
                    end
                end
            end
            --将敌方已选克制临时列表中的英雄删除
            for _key,value in pairs(tempHeroList) do
                local enemyList = X.ProposalWeightList(value);
                if enemyList ~= nil then
                    for _,i in pairs(enemyList) do
                        if value == i then
                            --print(i);
                            table.remove(tempHeroList,_key);
                            table.insert(tempBeAimedHeroList,i);--将移除的英雄加入次要选择库，当无英雄可选时，优先选择对我方有利的英雄，忽视是否被敌方克制
                        end
                    end
                end
            end
            --此时tempHeroList中的英雄为敌方的克制英雄并且不被对方针对(包含权重)
            if next(tempHeroList) ~= nil then
                local conclusionHeroList = {};
                for _hero,_weight in pairs(tempHeroList) do
                    for i = 1, _weight do
                        table.insert(conclusionHeroList,_hero);
                    end
                end
                conclusionHeroList = X.BreakUpList(conclusionHeroList); --乱序
                return conclusionHeroList;
            else
                --过分了，发出全列表
                local selectHero = X.OptionalHeroList();
                for k,i in pairs(selectHero) do
                    if not X.ScreeningHeroList(screeningList,i) then
                        table.remove(selectHero,k);
                    end
                end
                return selectHero;
            end
        else --双方均未选择英雄，则发出全列表
            local selectHero = X.OptionalHeroList();
            return selectHero;
        end
    end
end

return X
-- alcedo@alcedo.site 