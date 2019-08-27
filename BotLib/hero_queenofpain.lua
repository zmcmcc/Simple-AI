local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 2, 1, 3, 1, 6, 3, 2, 3, 3, 6, 2, 2, 1, 6 },
		--装备
		['Buy'] = {
			"item_double_mantle",
			"item_circlet",
			"item_faerie_fire",
			"item_tango",
			"item_enchanted_mango",
			"item_bottle",
			"item_double_null_talisman",
			"item_double_enchanted_mango",
			"item_power_treads",
			"item_clarity",
			"item_orchid",
			"item_maelstrom",
			"item_black_king_bar", 
			"item_ultimate_scepter",
			"item_shivas_guard",
			"item_sphere",
			"item_bloodthorn",
			"item_ultimate_scepter_2",
			"item_mjollnir",
			"item_travel_boots",
			"item_sheepstick",
			"item_travel_boots_2",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",     
			"item_bottle",

			"item_ultimate_scepter",
			"item_null_talisman",     

			"item_travel_boots",
			"item_power_treads",

			"item_sheepstick",
			"item_black_king_bar"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 2, 1, 1, 6, 1, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_circlet",
			"item_enchanted_mango",
			"item_double_clarity",
			"item_double_branches",
			"item_tango",
			"item_boots",
			"item_bottle",
			"item_magic_wand",
			"item_null_talisman",
			"item_power_treads",
			"item_orchid",
			"item_ultimate_scepter",
			"item_shivas_guard",
			"item_black_king_bar",
			"item_sheepstick",
			"item_bloodthorn",
			"item_ultimate_scepter_2",
			"item_octarine_core",
			"item_travel_boots",
			"item_moon_shard",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_shivas_guard",
			"item_magic_wand",

			"item_black_king_bar",
			"item_null_talisman",
			
			"item_sheepstick",
			"item_bottle",
			
			"item_travel_boots",
			"item_power_treads",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 2, 1, 1, 6, 1, 2, 2, 6 },
	--装备
	['Buy'] = {
		"item_circlet",
		"item_enchanted_mango",
		"item_double_clarity",
		"item_double_branches",
		"item_tango",
		"item_boots",
		"item_bottle",
		"item_magic_wand",
		"item_null_talisman",
		"item_power_treads",
		"item_orchid",
		"item_ultimate_scepter",
		"item_shivas_guard",
		"item_black_king_bar",
		"item_sheepstick",
		"item_bloodthorn",
		"item_ultimate_scepter_2",
		"item_octarine_core",
		"item_travel_boots",
		"item_moon_shard",
		"item_travel_boots_2",
	},
	--出售
	['Sell'] = {
		"item_shivas_guard",
		"item_magic_wand",

		"item_black_king_bar",
		"item_null_talisman",
		
		"item_sheepstick",
		"item_bottle",
		
		"item_travel_boots",
		"item_power_treads",
	},
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
	local order = {'Q','W','E','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X