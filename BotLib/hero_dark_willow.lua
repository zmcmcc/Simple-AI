local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local illuOrbLoc = nil

local tGroupedDataList = {
	
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,1,2,2,6,1,2,1,2,6,3,3,3,6},
	['Buy'] = {
		"item_tango",
		"item_flask",
		"item_double_branches",
		"item_enchanted_mango",
		"item_clarity",
		"item_magic_wand" ,
		"item_boots",
		"item_veil_of_discord",
		"item_blink",
		"item_cyclone",
		"item_ultimate_scepter",
		"item_sheepstick",
		"item_octarine_core",
	},
	['Sell'] = {
		"item_travel_boots_1",
		"item_boots",
	}
}

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
	local order = {'Q','W','E','R','D'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end

return X
-- dota2jmz@163.com QQ:2462331592
