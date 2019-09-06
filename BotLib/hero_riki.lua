local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
	--装备
	['Buy'] = {
		"item_faerie_fire",
		"item_double_slippers",
		"item_double_circlet",
		"item_tango",
		"item_bottle",
		"item_double_wraith_band",
		"item_power_treads",
		"item_desolator",
		"item_blink",
		"item_black_king_bar", 
		"item_nullifier",
		"item_monkey_king_bar",
		"item_ultimate_scepter",
		"item_greater_crit",
		"item_ultimate_scepter_2",
		"item_moon_shard",
		"item_travel_boots",
		"item_travel_boots_2"
	},
	--出售
	['Sell'] = {
		"item_black_king_bar",
		"item_wraith_band",
				
		"item_nullifier",
		"item_bottle",

		"item_ultimate_scepter",
		"item_blink",

		"item_travel_boots",
		"item_power_treads"
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
-- dota2jmz@163.com QQ:2462331592
