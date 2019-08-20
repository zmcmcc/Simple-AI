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
		['info'] = 'By Misunderstand',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		['Ability'] = { 1, 3, 1, 3, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 },
		['Buy'] = {
			"item_blight_stone",
			"item_double_tango",
			"item_clarity",
			"item_enchanted_mango",
			"item_magic_stick",
			"item_double_enchanted_mango",
			"item_magic_wand",
			"item_wind_lace",
			"item_medallion_of_courage",
			"item_arcane_boots",
			"item_hand_of_midas",
			"item_force_staff",
			"item_guardian_greaves",
			"item_pipe",
			"item_solar_crest",
			"item_necronomicon_3",
			"item_sheepstick",
			"item_ultimate_scepter_2",
			"item_silver_edge",
			"item_moon_shard",
		},
		['Sell'] = {
			"item_aeon_disk",
			"item_magic_wand",
	
			"item_necronomicon_3",
			"item_force_staff",
	
			"item_silver_edge",
			"item_hand_of_midas",
	
			"item_silver_edge",
			"item_aeon_disk",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	['Ability'] = { 1, 3, 1, 3, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 },
	['Buy'] = {
		"item_blight_stone",
		"item_double_tango",
		"item_clarity",
		"item_enchanted_mango",
		"item_magic_stick",
		"item_double_enchanted_mango",
		"item_magic_wand",
		"item_wind_lace",
		"item_medallion_of_courage",
		"item_arcane_boots",
		"item_hand_of_midas",
		"item_force_staff",
		"item_guardian_greaves",
		"item_pipe",
		"item_solar_crest",
		"item_necronomicon_3",
		"item_sheepstick",
		"item_ultimate_scepter_2",
		"item_silver_edge",
		"item_moon_shard",
	},
	['Sell'] = {
		"item_aeon_disk",
		"item_magic_wand",

		"item_necronomicon_3",
		"item_force_staff",

		"item_silver_edge",
		"item_hand_of_midas",

		"item_silver_edge",
		"item_aeon_disk",
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
	local order = {'W','Q','E'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
