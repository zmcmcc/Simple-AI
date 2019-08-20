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
		['info'] = '主W加点',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6},
		--装备
		['Buy'] = {
			"item_tango",
			"item_enchanted_mango",
			"item_double_branches",
			"item_clarity",
			"item_tranquil_boots",
			"item_force_staff",
			"item_glimmer_cape",
			"item_rod_of_atos",
			"item_ultimate_scepter",
			"item_pipe",
			"item_heavens_halberd",
		},
		--替换
		['Sell'] = {
			"item_crimson_guard",
			"item_quelling_blade",
		}
	},
	{
		['info'] = '主Q加点',
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		['Ability'] = {1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
		['Buy'] = {
			"item_tango",
			"item_enchanted_mango",
			"item_double_branches",
			"item_clarity",
			"item_tranquil_boots",
			"item_force_staff",
			"item_glimmer_cape",
			"item_rod_of_atos",
			"item_ultimate_scepter",
			"item_pipe",
			"item_heavens_halberd",
		},
		['Sell'] = {
			"item_crimson_guard",
			"item_quelling_blade",
		}
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
	['Ability'] = {1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
	['Buy'] = {
		"item_tango",
		"item_enchanted_mango",
		"item_double_branches",
		"item_clarity",
		"item_tranquil_boots",
		"item_force_staff",
		"item_glimmer_cape",
		"item_rod_of_atos",
		"item_ultimate_scepter",
		"item_pipe",
		"item_heavens_halberd",
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

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'E','D','R','W','Q'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X