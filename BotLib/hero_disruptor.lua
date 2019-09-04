local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 1, 2, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_circlet",
			"item_tango",
			"item_clarity",
			"item_enchanted_mango",
			"item_flask",
			"item_magic_wand",
			"item_double_clarity",
			"item_null_talisman",
			"item_enchanted_mango",
			"item_void_stone",
			"item_tranquil_boots",
			"item_aether_lens",
			"item_glimmer_cape",
			"item_force_staff",
			"item_ultimate_scepter",
			"item_sheepstick",
			"item_ghost",
			"item_ultimate_scepter_2",
			"item_ethereal_blade",
			"item_cyclone", 
			"item_travel_boots",
		},
		--出售
		['Sell'] = {
			"item_force_staff",
			"item_null_talisman",

			"item_ultimate_scepter",
			"item_magic_wand",

			"item_travel_boots",     
			"item_tranquil_boots", 

			"item_cyclone",
			"item_force_staff" 
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},
	['Buy'] = {
		"item_tango",
		"item_clarity",
		"item_clarity",
		"item_enchanted_mango",
		"item_enchanted_mango",
		"item_arcane_boots",
		"item_glimmer_cape",
		"item_cyclone",
		"item_aether_lens",
		"item_ultimate_scepter",
		"item_spirit_vessel",
		"item_sheepstick",
	},
	['Sell'] = {
		"item_crimson_guard",
		"item_quelling_blade",
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

local hEnemyOnceLocation = {}

for _,TeamPlayer in pairs( GetTeamPlayers(GetOpposingTeam()) )
do
    hEnemyOnceLocation[TeamPlayer] = nil;
end

local hEnemyRecordLocation = {}

function X.SkillsComplement()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--暂时取消位置记录
	--RecordTheLocation();

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'W','R','Q','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

function RecordTheLocation()
    local nEnemysTeam = GetTeamPlayers(GetOpposingTeam());
    local nEnemysHeroesCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local loctime = DotaTime();
    local players = {}

    for _,TeamPlayer in pairs( nEnemysTeam )
	do
        for _,Enemy in pairs( nEnemysHeroesCanSeen )
        do
            if Enemy:GetUnitName() == GetSelectedHeroName(TeamPlayer) then --取得英雄的玩家id
                table.insert(hEnemyRecordLocation,{
                    ['playerid'] = TeamPlayer,
                    ['time'] = loctime,
                    ['location'] = Enemy:GetLocation(),
                });
                players[TeamPlayer] = Enemy:GetLocation();
            end
        end
        if players[TeamPlayer] == nil then
            local info = GetHeroLastSeenInfo(TeamPlayer)
            if info ~= nil then
                local dInfo = info[1];
                if dInfo ~= nil then
                    table.insert(hEnemyRecordLocation,{
                        ['playerid'] = TeamPlayer,
                        ['time'] = dInfo.time_since_seen,
                        ['location'] = dInfo.location,
					});
                end
            end
        end
        --清除缓存,加入地址库
		if #hEnemyRecordLocation >= 10 then
			for i = 2, #hEnemyRecordLocation - 10
			do
				if hEnemyRecordLocation[i] ~= nil then
					if hEnemyRecordLocation[i]['time'] < loctime - 4 then
						table.remove(hEnemyRecordLocation,i)
					elseif hEnemyRecordLocation[i]['time'] >= loctime - 4 and hEnemyRecordLocation[i]['time'] <= loctime - 5 then
						hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']] = {
							['location'] = hEnemyRecordLocation[i]['location'],
							['time'] = hEnemyRecordLocation[i]['time'],
						};
						print('-2-');
						print(hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']]['time']);
					end
				end
            end
		end
		if hEnemyRecordLocation[1] ~= nil then
			if hEnemyRecordLocation[1]['time'] > loctime - 4 and hEnemyRecordLocation[1]['time'] <= loctime - 5 then
				hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']] = {
					['location'] = hEnemyRecordLocation[i]['location'],
					['time'] = hEnemyRecordLocation[i]['time'],
				};
				print('-1-');
				print(hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']]['time']);
			elseif hEnemyRecordLocation[1]['time'] > loctime - 10 then
				table.remove(hEnemyRecordLocation,1)
			end
		end
		for i = 1, #hEnemyOnceLocation
		do
			if hEnemyOnceLocation[i]['time'] < loctime - 10 then
				hEnemyOnceLocation[i] = nil
			end
		end
	end

	return;
end

return X