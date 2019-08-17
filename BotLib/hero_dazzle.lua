local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local AbilityMode = require( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--local tTalentTreeList = {
--						['t25'] = {0, 10},
--						['t20'] = {10, 0},
--						['t15'] = {0, 10},
--						['t10'] = {10, 0},
--}
--
--local tAllAbilityBuildList = {
--						{1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},
--}
--
--local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--
--local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--
--X['sBuyList'] = {
--				'item_tango',
--				'item_enchanted_mango',
--				'item_double_branches',
--				'item_enchanted_mango',
--				'item_clarity',
--				'item_arcane_boots',
--				'item_rod_of_atos',
--				'item_sheepstick',
--				'item_ultimate_scepter',
--}
--
--X['sSellList'] = {
--	"item_crimson_guard",
--	"item_quelling_blade",
--}

-- 出装和加点来自于Misunderstand

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{ 1, 3, 1, 3, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 }
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
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
}

X['sSellList'] = {
	"item_aeon_disk",
	"item_magic_wand",

	"item_necronomicon_3",
	"item_force_staff",

	"item_silver_edge",
	"item_hand_of_midas",

	"item_silver_edge",
	"item_aeon_disk",
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

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	--技能检查顺序
	local order = {'W','Q','E'}
	--委托技能处理函数接管
	if AbilityMode.Skills(order) then return; end

end

return X
