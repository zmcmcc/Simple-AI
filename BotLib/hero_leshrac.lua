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
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 2, 6, 2, 2, 3, 3, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_branches",
			"item_double_mantle",
			"item_circlet",
			"item_tango",
			"item_double_enchanted_mango",
			"item_magic_wand",
			"item_double_null_talisman",
			"item_boots",
			"item_cyclone",
			"item_travel_boots", 
			"item_bloodstone",
			"item_black_king_bar", 
			"item_kaya",
			"item_shivas_guard",
			"item_yasha_and_kaya",
			"item_ultimate_scepter_2", 
			"item_travel_boots_2",
			"item_octarine_core",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_bloodstone",
			"item_magic_wand",

			"item_kaya",
			"item_null_talisman",
					
			"item_octarine_core",   
			"item_yasha_and_kaya", 
		},
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	['Ability'] = {1,2,2,3,2,6,2,3,3,3,1,1,1,6,6},
	['Buy'] = {
		'item_tango',
		'item_flask',
		'item_faerie_fire',
		'item_magic_stick',
		'item_arcane_boots',
		'item_rod_of_atos',
		'item_vanguard',
		'item_glimmer_cape',
		'item_yasha_and_kaya',
		'item_ultimate_scepter',
		'item_sheepstick',
	},
	['Sell'] = {
		"item_manta",
		"item_urn_of_shadows",

		"item_black_king_bar",
		"item_dragon_lance",
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

	J.ConsiderForMkbDisassembleMask(bot);
	J.ConsiderTarget();
	
	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','W','E','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
-- dota2jmz@163.com QQ:2462331592
