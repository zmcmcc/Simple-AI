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
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 1, 3, 1, 6, 1, 3, 2, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_gauntlets",
			"item_double_enchanted_mango",
			"item_double_enchanted_mango",
			"item_double_branches",
			"item_magic_stick",
			"item_wind_lace",
			"item_bracer",
			"item_flask",
			"item_magic_wand",
			"item_travel_boots",
			"item_ring_of_health",
			"item_clarity",
			"item_blink",
			"item_force_staff",
			"item_black_king_bar",
			"item_meteor_hammer", 
			"item_sphere",
			"item_ultimate_scepter_2",
			"item_hurricane_pike",
			"item_travel_boots_2",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_force_staff",     
			"item_wind_lace",

			"item_black_king_bar",
			"item_bracer",     

			"item_meteor_hammer",
			"item_magic_wand"
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		['Ability'] = { 1, 3, 3, 1, 3, 6, 2, 3, 1, 1, 6, 2, 2, 2, 6},
		['Buy'] = {
			"item_double_tango",
			"item_flask",
			"item_double_enchanted_mango",
			"item_crown",
			"item_magic_stick",
			"item_boots",
			"item_ancient_janggo",
			"item_blink",
			"item_force_staff",
			"item_aether_lens", 
			"item_travel_boots",
			"item_black_king_bar",
			"item_ultimate_scepter_2",
			"item_shivas_guard",
			"item_travel_boots_2",
			"item_moon_shard"
		},
		['Sell'] = {
			"item_black_king_bar",
			"item_magic_stick",

			"item_shivas_guard",
			"item_ancient_janggo",
		}
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		"item_tango",
		"item_flask",
		"item_magic_wand",
		"item_tranquil_boots",
		"item_blink",
		"item_force_staff",
		"item_black_king_bar",
		"item_cyclone",
		"item_ultimate_scepter",
		"item_hurricane_pike",
		"item_octarine_core",
	},
	--出售
	['Sell'] = {
		"item_cyclone",
		"item_magic_wand",
	},
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
	local order = {'R','E','W','Q'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
