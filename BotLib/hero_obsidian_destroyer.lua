local X = {}
local bDebugMode = false;
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		['info'] = 'By Misunderstand',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		['Ability'] = { 2, 3, 2, 1, 2, 6, 2, 3, 3, 1, 6, 1, 3, 1, 6 },
		['Buy'] = {
			"item_double_mantle",
			"item_circlet",
			"item_tango",
			"item_magic_stick",
			"item_double_null_talisman",
			"item_flask",
			"item_power_treads",
			"item_kaya",
			"item_blink",
			"item_yasha_and_kaya",
			"item_black_king_bar",
			"item_sheepstick",
			"item_refresher",
			"item_hurricane_pike",
			"item_ultimate_scepter_2",
			"item_moon_shard",
		},
		['Sell'] = {
			"item_black_king_bar",
			"item_magic_stick",
			
			"item_sheepstick",
			"item_null_talisman",
			
			"item_hurricane_pike",
			"item_blink",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,3,1,3,3,6,3,2,1,2,6,2,1,1,6},
	['Buy'] = {
		"item_double_mantle",
		"item_circlet",
		"item_tango",
		"item_magic_stick",
		"item_double_null_talisman",
		"item_flask",
		"item_power_treads",
		"item_hurricane_pike",
		"item_yasha_and_kaya",
		"item_black_king_bar",
		"item_shivas_guard",
		"item_ultimate_scepter_2",
		"item_sheepstick",
	},
	['Sell'] = {
		"item_monkey_king_bar",
		"item_arcane_boots",
		
		"item_cyclone",
		"item_magic_wand",
	}
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true


function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'R','Q','E','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end
	
end



return X
