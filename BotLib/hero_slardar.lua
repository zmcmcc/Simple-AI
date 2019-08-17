--------------------
--from 望天的稻草
--------------------
local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local AbilityMode = require( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

------------------------------------------------------------------------------------------------------------
--	英雄加点及出装数据
------------------------------------------------------------------------------------------------------------

--英雄天赋树
local tTalentTreeList = {
						['t25'] = {0, 10}, --右
						['t20'] = {10, 0}, --左
						['t15'] = {10, 0}, --左
						['t10'] = {10, 0}, --左
}

--英雄技能树
--6代表大招
--可多组，游戏时随机一组使用
local tAllAbilityBuildList = {
						{2,3,1,3,1,6,3,1,1,3,6,2,2,2,6},
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

--出装方案
--基础出装在jmz_item.lua中编写，对应sOutfit项
X['sBuyList'] = {
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
}
--后期更换装备方案
X['sSellList'] = {
	"item_crimson_guard",
	"item_abyssal_blade",
}

--加载锦囊数据
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
	if AbilityMode.Skills(order) then return; end

end

return X

--https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting#Ability_and_Item_usage
--http://discuss.alcedogroup.com/d/7-simple-ai