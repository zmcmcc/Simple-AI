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
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 2, 2, 2, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_stout_shield",
			"item_tango",
			"item_gauntlets",
			"item_double_branches",
			"item_magic_stick",
			"item_flask",
			"item_bracer",
			"item_magic_wand",
			"item_phase_boots",
			"item_vanguard",
			"item_blink",
			"item_blade_mail",
			"item_black_king_bar",
			"item_lotus_orb",
			"item_pipe",
			"item_crimson_guard",
			"item_ultimate_scepter_2",
			"item_travel_boots_2",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_blade_mail",
			"item_magic_wand",

			"item_black_king_bar",
			"item_bracer",
			
			"item_pipe",
			"item_black_king_bar",

			"item_mjollnir",
			"item_magic_wand",
			
			"item_travel_boots_2",
			"item_phase_boots",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
	['Buy'] = {
		"item_tango",
		"item_flask",
		"item_quelling_blade",
		"item_magic_stick",
		"item_phase_boots",
		"item_vanguard",
		"item_blink",
		"item_blade_mail",
		"item_mjollnir", 
		"item_manta",
		"item_octarine_core",
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

X['bDeafaultAbility'] = false
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
	local order = {'R','Q','W'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X