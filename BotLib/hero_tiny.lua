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
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 3, 1, 2, 1, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6},
		--装备
		['Buy'] = {
			"item_flask",
			"item_gauntlets",
			"item_circlet",
			"item_bottle",
			"item_magic_stick",
			"item_bracer",
			"item_double_enchanted_mango",
			"item_phase_boots",
			"item_double_clarity",
			"item_echo_sabre", 
			"item_blink",
			"item_echo_sabre", 
			"item_greater_crit",
			"item_bfury",
			"item_travel_boots",
			"item_hyperstone",
			"item_ultimate_scepter_2",
			"item_moon_shard",
			"item_silver_edge",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_blink",
			"item_magic_stick",

			"item_echo_sabre",     
			"item_bracer",

			"item_bfury",     
			"item_bottle",
					
			"item_travel_boots",  
			"item_phase_boots",

			"item_silver_edge",
			"item_echo_sabre",
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 2, 3, 1, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6},
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_double_enchanted_mango",
			"item_gauntlets",
			"item_magic_stick",
			"item_crown",
			"item_phase_boots",
			"item_echo_sabre",
			"item_ancient_janggo", 
			"item_blink",
			"item_ultimate_scepter",
			"item_greater_crit",
			"item_black_king_bar",
			"item_assault",
			"item_ultimate_scepter_2",
			"item_satanic",
			"item_moon_shard",
			"item_heart",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_magic_stick",

			"item_black_king_bar",     
			"item_ancient_janggo",

			"item_assault",
			"item_echo_sabre",

			"item_travel_boots_2",
			"item_phase_boots",

			"item_heart",
			"item_blink",
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
	local order = {'Q','W','E','D','F'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X