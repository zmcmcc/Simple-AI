--------------------
--from 望天的稻草
--------------------
local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

------------------------------------------------------------------------------------------------------------
--	英雄加点及出装数据
------------------------------------------------------------------------------------------------------------

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By 望天的稻草',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {2,3,1,3,1,6,3,1,1,3,6,2,2,2,6},
		--装备
		['Buy'] = {
			"item_stout_shield",
			'item_tango',
			'item_flask',
			'item_quelling_blade',
			'item_soul_ring',
			'item_phase_boots',
			"item_ancient_janggo",
			"item_blink",
			"item_echo_sabre",
			"item_sange_and_yasha",
			"item_black_king_bar",
			"item_assault",
		},
		--出售
		['Sell'] = {
			"item_crimson_guard",
			"item_abyssal_blade",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 3, 2, 3, 1, 3, 6, 3, 1, 1, 1, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_gauntlets", 
			"item_stout_shield",
			"item_enchanted_mango",
			"item_quelling_blade",
			"item_magic_stick",
			"item_flask",
			"item_bracer",
			"item_phase_boots",
			"item_ancient_janggo", 
			"item_blink",
			"item_echo_sabre",
			"item_black_king_bar",
			"item_desolator", 
			"item_assault",
			"item_moon_shard", 
			"item_silver_edge",
			"item_ultimate_scepter_2",
			"item_travel_boots",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_ancient_janggo", 
			"item_quelling_blade",

			"item_echo_sabre",     
			"item_stout_shield",
					
			"item_black_king_bar", 
			"item_magic_stick",	     

			"item_desolator",
			"item_bracer",

			"item_assault",
			"item_ancient_janggo",

			"item_silver_edge",
			"item_echo_sabre",

			"item_travel_boots",
			"item_phase_boots"
		},
	}
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {2,3,1,3,1,6,3,1,1,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		"item_stout_shield",
		'item_tango',
		'item_flask',
		'item_quelling_blade',
		'item_soul_ring',
		'item_phase_boots',
		"item_ancient_janggo",
		"item_blink",
		"item_echo_sabre",
		"item_sange_and_yasha",
		"item_black_king_bar",
		"item_assault",
	},
	--出售
	['Sell'] = {
		"item_crimson_guard",
		"item_abyssal_blade",
	},
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

--获取技能列表
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
	local order = {'Q','W','R'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X

--https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting#Ability_and_Item_usage
--http://discuss.alcedogroup.com/d/7-simple-ai