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
		['info'] = '默认出装',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		['Ability'] = {1,3,3,2,1,6,1,3,1,3,6,2,2,2,6},
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_magic_stick",
			"item_double_branches",
			"item_power_treads_agi",
			"item_yasha",
			"item_mjollnir",
			"item_black_king_bar",
			"item_silver_edge",
			"item_manta", 
			"item_ultimate_scepter",
		},
		['Sell'] = {
			"item_monkey_king_bar",
			"item_yasha",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,3,2,1,6,1,3,1,3,6,2,2,2,6},
	['Buy'] = {
		"item_tango",
		"item_flask",
		"item_stout_shield",
		"item_quelling_blade",
		"item_magic_stick",
		"item_double_branches",
		"item_power_treads_agi",
		"item_yasha",
		"item_mjollnir",
		"item_black_king_bar",
		"item_silver_edge",
		"item_manta", 
		"item_ultimate_scepter",
	},
	['Sell'] = {
		"item_monkey_king_bar",
		"item_yasha",
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
		Minion.IllusionThink(hMinionUnit)
	end

end

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'Q','R','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X