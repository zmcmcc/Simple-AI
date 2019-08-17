-----------------
--英雄：戴泽
--技能：剧毒之触
--键位：Q
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('dazzle_poison_touch')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget,compensation)
    if castTarget ~= nil then
        if compensation then X.Compensation() end
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability ~= nil
       and not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0; --没欲望
	end
	
	local nCastRange = ability:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nDamage = (ability:GetLevel() * 12 + 4) * (ability:GetLevel() + 3);
	
	local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, bot);
	local npcTarget = J.GetProperTarget(bot)
	local nCastRTarget = nil
	
	
	if J.IsValid(nEnemysHerosInCastRange[1])
	then
		--最弱目标和当前目标
		if(nWeakestEnemyHeroInCastRange ~= nil)
		then
			if nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			then
				nCastRTarget = nWeakestEnemyHeroInCastRange;
				return BOT_ACTION_DESIRE_HIGH, nCastRTarget;
			end
			
			if J.IsValidHero(npcTarget)
			then
				if J.IsInRange(npcTarget, bot, nCastRange + 80)
					and J.CanCastOnMagicImmune(npcTarget)
				then
					nCastRTarget = npcTarget;
					return BOT_ACTION_DESIRE_HIGH,nCastRTarget;
				else
					nCastRTarget = nWeakestEnemyHeroInCastRange;
					return BOT_ACTION_DESIRE_HIGH, nCastRTarget;
				end
			end	
		end
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		then
			nCastRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH, nCastRTarget;
		end
	end
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
	then
	    local nAttackTarget = bot:GetAttackTarget();
        if nAttackTarget ~= nil 
           and nAttackTarget:IsAlive()
		then
			return BOT_ACTION_DESIRE_HIGH, nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;