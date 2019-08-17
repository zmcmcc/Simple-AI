local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local AbilityMode = require( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

--感谢 铅笔会有猫的w 提供的出装及加点
--英雄天赋树
local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

--英雄技能树
local tAllAbilityBuildList = {
						{ 3, 1, 3, 2, 3, 6, 3, 2, 1, 1, 6, 1, 2, 2, 6 }
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--技能和天赋加点方案
X['sBuyList'] = {
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
}

X['sSellList'] = {
	"item_shivas_guard",
	"item_magic_wand",

	"item_black_king_bar",
	"item_null_talisman",
	
	"item_sheepstick",
	"item_bottle",
	
	"item_travel_boots",
	"item_power_treads",
}


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
	if AbilityMode.Skills(order) then return; end

end

return X