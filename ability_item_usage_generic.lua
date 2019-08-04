----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


--计划添加撤退时的物品使用逻辑
local X = {};
local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() or not bot:IsHero()
then
	return;
end

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local BotBuild = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(GetBot():GetUnitName(), "npc_dota_", ""));

if BotBuild == nil then 
	print("*&((*^(*^(*^(^(*^(*^(*");
	return ;
end

if GetTeam() ~= TEAM_DIRE
then
	print(J.Chat.GetNormName(bot)..': Hello, Dota2 World!')
end

local bDeafaultAbilityHero = BotBuild['bDeafaultAbility'];
local bDeafaultItemHero = BotBuild['bDeafaultItem'];
local sAbilityLevelUpList = BotBuild['sSkillList'];



local function AbilityLevelUpComplement()  

	if GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS 
	then
		return;
	end

	if not bot:IsAlive() and bot:NumQueuedActions() > 0 then
		 bot:Action_ClearActions( false ) 
		 return
	end	
		
	if DotaTime() < 15 then
		bot.theRole = J.Role.GetCurrentSuitableRole(bot, bot:GetUnitName());	
	end	
		
	local botLoc = bot:GetLocation();
	if bot:IsAlive() and DotaTime() > 20
	   and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO 
	   and not IsLocationPassable(botLoc) 
	then
		if bot.stuckLoc == nil then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime();
		elseif bot.stuckLoc ~= botLoc then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime();
		end
	else	
		bot.stuckTime = nil;
		bot.stuckLoc = nil;
	end	
	
	if bot:GetAbilityPoints() > 0 then
		local ability = bot:GetAbilityByName(sAbilityLevelUpList[1]);
		if ability ~= nil 
		   and ability:CanAbilityBeUpgraded() 
		   and ability:GetLevel() < ability:GetMaxLevel() 
		then			
			bot:ActionImmediate_LevelAbility(sAbilityLevelUpList[1]);
			table.remove(sAbilityLevelUpList,1);
			return;
		end
	end
	
	
end

function X.GetNumEnemyNearby(building)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(building, dInfo.location) <= 2750 and dInfo.time_since_seen < 1.0 then
					nearbynum = nearbynum + 1;
				end
			end
		end
	end
	return nearbynum;
end

function X.GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function X.GetRemainingRespawnTime()
	
	if fDeathTime == nil then
		return 0;
	else
		return bot:GetRespawnTime() - ( DotaTime() - fDeathTime ) ;
	end
end

local fDeathTime = nil;
local bArcWardenClone = false;
local function BuybackUsageComplement() 
	
	if bot:GetLevel() <=  15
	   or bArcWardenClone == true
	   or J.Role.ShouldBuyBack() == false 
	then
		return;
	end
	
	if bot:HasModifier('modifier_arc_warden_tempest_double') then
		bArcWardenClone = true return;
	end
	
	if bot:IsAlive() and fDeathTime ~= nil then
		fDeathTime = nil;
	end
	
	if not bot:IsAlive() then	
		if fDeathTime == nil then fDeathTime = DotaTime() end
	end

	if not bot:HasBuyback() then return end

	if bot:GetRespawnTime() < 60 then
		return;
	end
	
	local nRespawnTime = X.GetRemainingRespawnTime();
	
	if bot:GetLevel() > 24
	   and nRespawnTime > 80
	then
		local nTeamFightLocation = J.GetTeamFightLocation(bot);
		if nTeamFightLocation ~= nil 
		then
			bot:ActionImmediate_Buyback();
			J.Role['lastbbtime'] = DotaTime();
			return;
		end
	end

	
	if nRespawnTime < 50 then
		return;
	end
	
	
	local ancient = GetAncient(GetTeam());
	
	if ancient ~= nil 
	then
		local nEnemies = X.GetNumEnemyNearby(ancient);
		local nAllies = X.GetNumOfAliveHeroes(GetTeam())
		if  nEnemies > 0 and nEnemies >= nAllies and nEnemies - nAllies <= 3 then
			J.Role['lastbbtime'] = DotaTime();
			bot:ActionImmediate_Buyback();
			return;
		end	
	end

end


local pTime = 0;
function X.PrintCourierState(state)
		
	if pTime < DotaTime() - 10
	then
		pTime = DotaTime();

		if state == 0 then
			print(tostring(GetTeam())..":COURIER_STATE_IDLE.."..tostring(IsCourierAvailable()));
		elseif state == 1 then
			print(tostring(GetTeam())..":COURIER_STATE_AT_BASE.."..tostring(IsCourierAvailable()));
		elseif state == 2 then
			print(tostring(GetTeam())..":COURIER_STATE_MOVING.."..tostring(IsCourierAvailable()));
		elseif state == 3 then
			print(tostring(GetTeam())..":COURIER_STATE_DELIVERING_ITEMS.."..tostring(IsCourierAvailable()));
		elseif state == 4 then
			print(tostring(GetTeam())..":COURIER_STATE_RETURNING_TO_BASE.."..tostring(IsCourierAvailable()));
		elseif state == 5 then
			print(tostring(GetTeam())..":COURIER_STATE_DEAD.."..tostring(IsCourierAvailable()));
		else
			print(tostring(GetTeam())..":UNKNOWN.."..tostring(IsCourierAvailable()));
		end
	end
		
end


local courierTime = -90;
local cState = -1;
bot.SShopUser = false;
if nReturnTime == nil then nReturnTime = -90; end

local bHumanInTeam = not IsPlayerBot(GetTeamPlayers(GetTeam())[1]);
local nCourierStart = RandomInt(1,20);

local function CourierUsageComplement()

	if bot == GetTeamMember(1)
	   and bot:FindItemSlot("item_orb_of_venom") >= 0
	   and pTime < DotaTime() - 3.0
	then
		pTime = DotaTime();
		local npcCourier = GetCourier(0);	
		local available = tostring(IsCourierAvailable());
		local cState    = tostring(GetCourierState( npcCourier ));
		local courierPHP = tostring(npcCourier:GetHealth() / npcCourier:GetMaxHealth()); 
		local suCourier = tostring(J.Role.ShouldUseCourier());
		local numCouriers = GetNumCouriers();
		local nLastUser = 'Null';
	    if npcCourier.latestUser ~= nil then nLastUser = "temp" end;
		
		print(tostring(GetTeam()).."++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print("available:"..available.."cState:"..cState.."courierPHP:"..courierPHP);
		print("suCourier:"..suCourier.."numCouriers"..numCouriers.."nLastUser"..nLastUser);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
		
	end

	if DotaTime() < 40 + nCourierStart then return end
	
	if DotaTime() < 90 and bot:GetAssignedLane() ~= LANE_MID 
	then
		return
	end
	
	if GetGameMode() == 23 
	   or bot:HasModifier("modifier_arc_warden_tempest_double") 
	   or GetNumCouriers() == 0 
	   or J.Role.ShouldUseCourier() == false
	then
		return;
	end
	
	local npcCourier = GetCourier(0);	
	local cState = GetCourierState( npcCourier );
	local courierPHP = npcCourier:GetHealth() / npcCourier:GetMaxHealth(); 
	
	--------*******----------------*******----------------*******--------
	local nowTime   = DotaTime();
	local botIsAlive = bot:IsAlive();
	local bHumanUseCourier = X.IsHumanHaveItemInCourier();
	local useCourierCD = 2.0;
	local protectCourierCD = 5.0;
	--------*******----------------*******----------------*******--------
	
	
	if cState == COURIER_STATE_DEAD then
		npcCourier.latestUser = nil;
		return
	end	
	
	
	if bot == GetTeamMember(5) and not bHumanUseCourier
	then
		if X.IsTargetedByUnit(npcCourier) 
		then
			if nowTime > nReturnTime + protectCourierCD then
				nReturnTime = nowTime;
				J.Role['courierReturnTime'] = nowTime;
				bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
				return;
			end
		end
	end
	
		
	if ( IsCourierAvailable() and cState ~= COURIER_STATE_IDLE )
	    or ( cState == COURIER_STATE_IDLE and not bHumanInTeam and npcCourier.latestUser == nil )
	then
		npcCourier.latestUser = "temp";
	end
	
	--FREE UP THE COURIER FOR HUMAN PLAYER
	if cState == COURIER_STATE_MOVING or bHumanUseCourier then
		npcCourier.latestUser = nil;
	end
	
	if bot.SShopUser and ( not botIsAlive or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP or not bot.SecretShop  ) then
		--bot:ActionImmediate_Chat( "Releasing the courier to anticipate secret shop stuck", true );
		npcCourier.latestUser = "temp";
		bot.SShopUser = false;
		bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
		return
	end
	
	if npcCourier.latestUser ~= nil 
	   and ( IsCourierAvailable() or cState == COURIER_STATE_RETURNING_TO_BASE or cState == COURIER_STATE_IDLE ) 
	   and nowTime > nReturnTime + protectCourierCD  
	then 
		
		if cState == COURIER_STATE_AT_BASE and courierPHP < 1.0 then
			return;
		end
		
		--RETURN COURIER TO BASE WHEN IDLE 
		if cState == COURIER_STATE_IDLE then
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
			return
		end
		
		--TAKE ITEM FROM STASH
		if  botIsAlive and cState == COURIER_STATE_AT_BASE and not X.IsHumanHaveItemInStash() then
			local nCSlot = X.GetCourierEmptySlot(npcCourier);
			local nMSlot = X.GetNumStashItem(bot);
			if nMSlot > 0 and nMSlot <= nCSlot and X.IsValueToUseCourier(bot)
			then
				bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_STASH_ITEMS );
				courierTime = nowTime;
			end
		end
		
		--MAKE COURIER GOES TO SECRET SHOP
		if  botIsAlive and bot.SecretShop and npcCourier:DistanceFromFountain() < 7000 
			and X.GetCourierEmptySlot(npcCourier) >= 2 and courierPHP > 0.95
		    and nowTime > courierTime + useCourierCD 
		then
			--bot:ActionImmediate_Chat( "Using Courier for secret shop.", true );
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_SECRET_SHOP )
			npcCourier.latestUser = bot;
			bot.SShopUser = true;
			X.UpdateSShopUserStatus(bot);
			courierTime = nowTime;
			return
		end
		
		--TRANSFER ITEM IN COURIER
		if botIsAlive and bot:GetCourierValue() > 0 and courierPHP > 0.95
		   and X.IsTheClosestToCourier(bot, npcCourier)
		   and ( npcCourier:DistanceFromFountain() < 6000 or GetUnitToUnitDistance(bot, npcCourier) < 1600 ) 
		   and nowTime > courierTime + useCourierCD
		then
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
			npcCourier.latestUser = bot;
			courierTime = nowTime;
			return
		end
		
		--RETURN STASH ITEM WHEN DEATH
		if  not botIsAlive and cState == COURIER_STATE_AT_BASE  
			and bot:GetCourierValue() > 0 
			and X.GetNumStashItem(bot) < 3
			and X.GetCourierEmptySlot(npcCourier) >= 4
			and nowTime > courierTime + useCourierCD
		then
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS );
			npcCourier.latestUser = bot;
			courierTime = nowTime;
			return
		end
		
	end
	
end


function X.IsValueToUseCourier(bot)
	
	if DotaTime() < 89
		and bot:GetStashValue() > 0
	then
		return true;
	end	
	
	if bot:GetStashValue() > 299
	then
		return true;
	end
	
	if bot:GetStashValue() > 89
	   and X.GetCourierEmptySlot(GetCourier(0)) < 9
	then
		return true;
	end
	
	return false;
end


function X.IsHumanHaveItemInCourier()

	if not bHumanInTeam then return false; end

	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		if not IsPlayerBot(numPlayer[i]) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and member:GetCourierValue() > 0 
			then
				return true;
			end
		end
	end
	
	return false;
end


function X.IsHumanHaveItemInStash()

	if not bHumanInTeam then return false; end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		if not IsPlayerBot(numPlayer[i]) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and member:GetStashValue() > 0 
			then
				return true;
			end
		end
	end
	
	return false;
end


function X.IsTheClosestToCourier(bot, npcCourier)
	local numPlayer =  GetTeamPlayers(GetTeam());
	local closest = nil;
	local closestD = 100000;
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive() 
		   and IsPlayerBot(numPlayer[i]) 
		   and member:GetCourierValue() > 0 
		   and J.GetDistanceFromEnemyFountain(member) > 4600
		then
			local invFull = X.IsInvFull(member);
			local nStash = X.GetNumStashItem(member);
			if invFull == false 
				or ( invFull == true and nStash == 0 and bot.currListItemToBuy ~= nil and #bot.currListItemToBuy == 0 ) 
			then
				local dist = GetUnitToUnitDistance(member, npcCourier);
				
				if member:GetAssignedLane() == LANE_MID and member:GetLevel() < 8 and dist > 1600 then dist = dist * 1.38; end
				
				if dist < closestD then
					closest = member;
					closestD = dist;
				end
			end	
		end
	end
	return closest ~= nil and closest == bot
end


function X.GetCourierEmptySlot(courier)
	local amount = 0;
	for i=0, 8 do
		if courier:GetItemInSlot(i) == nil then
			amount = amount + 1;
		end
	end
	return amount;
end


function X.GetNumStashItem(unit)
	local amount = 0;
	for i=9, 14 do
		if unit:GetItemInSlot(i) ~= nil then
			amount = amount + 1;
		end
	end
	return amount;
end


function X.UpdateSShopUserStatus(bot)
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and IsPlayerBot(numPlayer[i]) and  member:GetUnitName() ~= bot:GetUnitName() 
		then
			member.SShopUser = false;
		end
	end
end


function X.IsTargetedByUnit(courier)

	local botLV = bot:GetLevel();
	
	if J.GetHPR(courier) < 0.9 
	then 
		return true;
	end;
	
	if courier:DistanceFromFountain() < 2000 then return false end
	
	for i = 0, 10 do
	local tower = GetTower(GetOpposingTeam(), i)
		if tower ~= nil and tower:GetAttackTarget() == courier then
			return true;
		end
	end
	
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil 
				   and GetUnitToLocationDistance(courier, dInfo.location) <= 800 
				   and dInfo.time_since_seen < 1.5
			    then
					return true;
				end
			end
		end
	end
	
	local nEnemysHeroesCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _,enemy in pairs(nEnemysHeroesCanSeen)
	do 
		if GetUnitToUnitDistance(enemy,courier) <= 700 + botLV * 15
		then
			return true;
		end
		
		if enemy:GetUnitName() == 'npc_dota_hero_sniper' 
		   and GetUnitToUnitDistance(enemy,courier) <= 1100 + botLV * 30
		then
			return true;
		end
	end
	
	local nEnemysHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	for _,enemy in pairs(nEnemysHeroes)
	do 
		if GetUnitToUnitDistance(enemy,courier) <= 700 + botLV * 15
		then
			return true ;
		end
	end
	
	local nAllEnemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
	for _,creep in pairs(nAllEnemyCreeps)
	do
		if  GetUnitToUnitDistance(courier,creep) <= 800
			and ( creep:GetAttackTarget() == courier or botLV > 10 )
		then
			return true;
		end
	end
	
	
	return false;
end

function X.IsInvFull(bot)
	for i = 0, 8 do
		if bot:GetItemInSlot(i) == nil 
		then
			return false;
		end
	end
	return true;
end

function X.CanCastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function X.IsDisabled(npcTarget)
	
	if npcTarget:IsStunned() and J.GetRemainStunTime(npcTarget) > 0.8
	then --待检测
		return true;
	end

	return npcTarget:IsRooted() or npcTarget:IsHexed() or npcTarget:IsSilenced() or npcTarget:IsNightmared()
end


function X.GiveToMidLaner()
	local teamPlayers = GetTeamPlayers(GetTeam())
	local target = nil;
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);  
		if member ~= nil 
			and not member:IsIllusion() 
			and member:IsAlive() 
			and member:GetAssignedLane() == LANE_MID 
		then
			local num_sts = X.GetItemCount(member, "item_tango_single"); 
			local num_ff = X.GetItemCount(member, "item_faerie_fire");   
			local num_stg = X.GetItemCharges(member, "item_tango");      
			if  num_sts + num_stg <= 1 then  
				return member;               
			end
		end
	end
	return nil;
end

function X.GetItemCount(unit, item_name)
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end

function X.GetItemCharges(unit, item_name) 
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + item:GetCurrentCharges();
		end
	end
	return count;
end


function X.CanSwitchPTStat(pt)
	if bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and pt:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY  and pt:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and pt:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY then
		return true;
	end 
	return false;
end

local myTeam = GetTeam()
local opTeam = GetOpposingTeam()

local teamT1Top = nil; 
if GetTower(myTeam,TOWER_TOP_1) ~= nil then teamT1Top = GetTower(myTeam,TOWER_TOP_1):GetLocation(); end

local teamT1Mid = nil;
if GetTower(myTeam,TOWER_MID_1) ~= nil then teamT1Mid = GetTower(myTeam,TOWER_MID_1):GetLocation(); end

local teamT1Bot = nil;
if GetTower(myTeam,TOWER_BOT_1) ~= nil then teamT1Bot = GetTower(myTeam,TOWER_BOT_1):GetLocation(); end

local enemyT1Top = nil;
if GetTower(opTeam,TOWER_TOP_1) ~= nil then enemyT1Top = GetTower(opTeam,TOWER_TOP_1):GetLocation(); end

local enemyT1Mid = nil;
if GetTower(opTeam,TOWER_MID_1) ~= nil then enemyT1Mid = GetTower(opTeam,TOWER_MID_1):GetLocation(); end

local enemyT1Bot = nil; 
if GetTower(opTeam,TOWER_BOT_1) ~= nil then enemyT1Bot = GetTower(opTeam,TOWER_BOT_1):GetLocation(); end

function X.GetLaningTPLocation(nLane)
	if nLane == LANE_TOP then
		return teamT1Top
	elseif nLane == LANE_MID then
		return teamT1Mid
	elseif nLane == LANE_BOT then
		return teamT1Bot			
	end	
	return teamT1Mid
end	

function X.GetDefendTPLocation(nLane)
	return GetLaneFrontLocation(myTeam,nLane,-600)
end

function X.GetPushTPLocation(nLane)
	
	local laneFront = GetLaneFrontLocation(myTeam,nLane,0);
	local bestTpLoc = J.GetNearbyLocationToTp(laneFront);
	if J.GetLocationToLocationDistance(laneFront,bestTpLoc) < 2000
	then
		return bestTpLoc;
	end
	
	return nil;
end


function X.CanJuke()
	
	local allyTowers = bot:GetNearbyTowers(300,false); 
	if allyTowers[1] ~= nil	and allyTowers[1]:DistanceFromFountain() > bot:DistanceFromFountain() + 100		     
	then
		return true;
	end
	
	local enemyPids = GetTeamPlayers(GetOpposingTeam())
	
	local heroHG = GetHeightLevel(bot:GetLocation())
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  
				and GetUnitToLocationDistance(bot,dInfo.location) < 1300 
				and GetHeightLevel(dInfo.location) < heroHG  
			then
				return false;
			end
		end	
	end
	
	local tDamage = 0;
	local nEnemies = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
	for _,enemy in pairs(nEnemies)
	do
		local enemyDamage = enemy:GetEstimatedDamageToTarget( false, bot, 3.6, DAMAGE_TYPE_PHYSICAL );
		tDamage = tDamage + enemyDamage;
		if bot:GetHealth() <= bot:GetActualIncomingDamage(tDamage,DAMAGE_TYPE_PHYSICAL)
		then
			return false;
		end		
	end
	
	return true;
end	

function X.GetNumHeroWithinRange(nRange)
	
	local enemyPids = GetTeamPlayers(GetOpposingTeam())
	
	local cHeroes = 0;
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  
				and GetUnitToLocationDistance(bot,dInfo.location) < nRange 
			then
				cHeroes = cHeroes + 1;
			end
		end	
	end
	
	return cHeroes;
end	

function X.GetAlliesNumWithinRange(nRange)
	local nAllies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE)
	return #nAllies;
end

function X.IsFarmingAlways(bot)
	local nTarget = bot:GetAttackTarget();	
	if J.IsValid(nTarget)
	   and nTarget:GetTeam() == TEAM_NEUTRAL
	   and not J.IsRoshan(nTarget)
	   and not J.IsKeyWordUnit("warlock",nTarget)
	   and X.GetNumEnemyNearby(GetAncient(GetTeam())) >= 2
	then
		return true;
	end
	
	local nAllies = bot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
	if J.IsValid(nTarget)
		and nTarget:IsAncientCreep()
		and not J.IsRoshan(nTarget)
		and not J.IsKeyWordUnit("warlock",nTarget)
		and bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
		and #nAllies < 2
	then
		return true;
	end
	
	if X.GetNumEnemyNearby(GetAncient(GetTeam())) >= 4
		and bot:DistanceFromFountain() >= 4800
		and #nAllies < 2
	then
		return true;
	end
	
	return false;
end


function X.ShouldTP()
	local tpLoc = nil;
	local tpThreshold = 4000;
	local mode = bot:GetActiveMode();
	local modDesire = bot:GetActiveModeDesire();
	local botLoc = bot:GetLocation();
	local enemies = X.GetNumHeroWithinRange(1600);
	local allies = X.GetAlliesNumWithinRange(1600);
	local ifl = X.IsItemAvailable("item_flask");
	
	if     ( bot:HasModifier("modifier_kunkka_x_marks_the_spot") )
		or ( bot:HasModifier("modifier_sniper_assassinate") )
		or ( bot:HasModifier("modifier_viper_nethertoxin") )
		or ( bot:HasModifier("modifier_oracle_false_promise_timer")
			 and J.GetModifierTime(bot,"modifier_oracle_false_promise_timer") <= 3.2 )
		or ( bot:HasModifier("modifier_jakiro_macropyre_burn")
			 and J.GetModifierTime(bot,"modifier_jakiro_macropyre_burn") >= 1.4 )
		or ( bot:HasModifier("modifier_arc_warden_tempest_double")
			 and bot:GetRemainingLifespan() < 3.2 )
	then
		return false,nil;
	end	
	
	if bot:GetHealth() < 300
	then
		local nProDamage = J.GetAttackProjectileDamageByRange(bot, 1600);
		if bot:GetHealth() < bot:GetActualIncomingDamage(nProDamage,DAMAGE_TYPE_PHYSICAL)
		then return false,nil; end
	end
	
	if bot:GetLevel() > 12 and bot:DistanceFromFountain() < 600 then tpThreshold = tpThreshold + 800 end
	
	if mode == BOT_MODE_LANING and enemies == 0 then
		local assignedLane = bot:GetAssignedLane();
		if assignedLane == LANE_TOP  then
			local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
			if botAmount.distance > tpThreshold - 200 or botAmount.amount < laneFront / 5 then 
				tpLoc = X.GetLaningTPLocation(LANE_TOP)
			end	
		elseif assignedLane == LANE_MID then
			local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
			if botAmount.distance > tpThreshold  - 200 or botAmount.amount < laneFront / 5 then 
				tpLoc = X.GetLaningTPLocation(LANE_MID)
			end	
		elseif assignedLane == LANE_BOT then
			local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
			if botAmount.distance > tpThreshold  - 200 or botAmount.amount < laneFront / 5 then 
				tpLoc = X.GetLaningTPLocation(LANE_BOT)
			end	
		end
	elseif mode == BOT_MODE_DEFEND_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetDefendTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetDefendTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then	
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetDefendTPLocation(LANE_BOT)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetPushTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetPushTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = X.GetPushTPLocation(LANE_BOT)
		end	
	elseif mode == BOT_MODE_DEFEND_ALLY and modDesire >= BOT_MODE_DESIRE_MODERATE and J.Role.CanBeSupport(bot:GetUnitName()) and enemies == 0 then
		local target = bot:GetTarget()
		if target ~= nil and target:IsHero() and GetUnitToUnitDistance(bot,target) > tpThreshold 
		then
			local bestTpLoc = J.GetNearbyLocationToTp(target:GetLocation());
			if bestTpLoc ~= nil 
			   and GetUnitToLocationDistance(bot,bestTpLoc) > tpThreshold 
			then
				tpLoc = bestTpLoc;
			end
		end
	elseif mode == BOT_MODE_RETREAT and modDesire >= BOT_MODE_DESIRE_MODERATE 
	then  --here has some bugs
		if bot:GetHealth() < 0.18*bot:GetMaxHealth() 
		   and bot:WasRecentlyDamagedByAnyHero(5.0) 
		   and enemies == 0 
		   and ifl == nil
		   and not bot:HasModifier("modifier_flask_healing")
		   and bot:DistanceFromFountain() > tpThreshold - 200
		then
			J.Print("感觉快要死了:",bot:GetUnitName());
			tpLoc = J.GetTeamFountain();
		elseif bot:GetHealth() < 0.35*bot:GetMaxHealth() 
		       and bot:WasRecentlyDamagedByAnyHero(8.0) 
			   and X.CanJuke() == true 
			   and ifl == nil
			   and not bot:HasModifier("modifier_flask_healing")
			   and bot:DistanceFromFountain() > tpThreshold - 200
			then
			   J.Print("尝试逃跑:",bot:GetUnitName());
			   tpLoc = J.GetTeamFountain();
		elseif  (bot:GetHealth()/bot:GetMaxHealth() < 0.25 or bot:GetHealth()/bot:GetMaxHealth() + bot:GetMana() /bot:GetMaxMana() < 0.3)
				and X.CanJuke() == true 
				and bot:DistanceFromFountain() > tpThreshold - 200
				and enemies <= 1 and allies <= 2
				and ifl == nil
				and bot:GetAttackTarget() == nil
				and not  bot:HasModifier("modifier_flask_healing")
				and not  bot:HasModifier("modifier_clarity_potion")
				and not  bot:HasModifier("modifier_item_urn_heal")
				and not  bot:HasModifier("modifier_filler_heal")
				and not  bot:HasModifier("modifier_item_spirit_vessel_heal")
				and not  bot:HasModifier("modifier_bottle_regeneration")
				and not  bot:HasModifier("modifier_tango_heal")
			then
				J.Print("撤退了回家补血补蓝:",bot:GetUnitName());
				tpLoc = J.GetTeamFountain();
		    end	
	elseif mode == BOT_MODE_FARM 
	       and bot:DistanceFromFountain() < 800 
		   and bot:GetHealth()/bot:GetMaxHealth() > 0.9
		   and bot:GetMana() /bot:GetMaxMana() > 0.8
	then
		local mostFarmDesireLane,mostFarmDesire = J.GetMostFarmLaneDesire();

		if mostFarmDesire > BOT_MODE_DESIRE_HIGH			
		then
			farmTpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
			local bestTpLoc = J.GetNearbyLocationToTp(farmTpLoc);
			if bestTpLoc ~= nil and farmTpLoc ~= nil
			   and J.IsLocHaveTower(2000,false,farmTpLoc)
			   and GetUnitToLocationDistance(bot,bestTpLoc) > tpThreshold 
			then
				tpLoc = farmTpLoc;
			end
		end	
		
		if tpLoc == nil 
		then
			local shrines = {
				 SHRINE_JUNGLE_1,
				 SHRINE_JUNGLE_2 
			}
			for _,s in pairs(shrines) do
				local shrine = GetShrine(GetTeam(), s);
				if  shrine ~= nil and shrine:IsAlive() then
					tpLoc = shrine:GetLocation();
					break; 
				end	
			end	
		end		
	elseif bot:HasModifier('modifier_bloodseeker_rupture') and enemies <= 1 then
		local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
		if #allies <= 1 and X.CanJuke() == true then		
			tpLoc = J.GetTeamFountain();
		end
	elseif  (bot:GetHealth()/bot:GetMaxHealth() + bot:GetMana()/bot:GetMaxMana() < 0.35 or bot:GetHealth()/bot:GetMaxHealth() < 0.25)
			and X.CanJuke() == true 
			and bot:DistanceFromFountain() > tpThreshold + 800
			and enemies <= 1 and allies <= 1
			and J.GetProperTarget(bot) == nil
			and ifl == nil
			and bot:GetAttackTarget() == nil
			and not bot:HasModifier("modifier_flask_healing")
			and not bot:HasModifier("modifier_clarity_potion")
			and not bot:HasModifier("modifier_filler_heal")
			and not bot:HasModifier("modifier_item_urn_heal")
			and not bot:HasModifier("modifier_item_spirit_vessel_heal")
			and not bot:HasModifier("modifier_bottle_regeneration")
			and not bot:HasModifier("modifier_tango_heal")
		then
			J.Print("状态不好回家补血补蓝:",bot:GetUnitName());
			tpLoc = J.GetTeamFountain();
	elseif X.IsFarmingAlways(bot) then
			J.Print("不打野了马上回家:",bot:GetUnitName());
			tpLoc = GetAncient(GetTeam()):GetLocation()
	elseif J.IsStuck(bot) and enemies == 0 then
		bot:ActionImmediate_Chat("I'm using tp while stuck.", true);
		tpLoc = GetAncient(GetTeam()):GetLocation();
	end	
	
	if tpLoc ~= nil and GetUnitToLocationDistance(bot, tpLoc) > tpThreshold - 300
	then
		return true, tpLoc;
	end
	
	return false, nil;
end

local giveTime = -90;
local lasItemCheckTime = -100;
local firstUseTime = 0;
local aetherRange = 0;
local amuletTime = 0;
local wandTime = 0;
local thereBeMonkey = false;

local function UnImplementedItemUsage()
	
	if not bot:IsAlive() 
	   or bot:NumQueuedActions() > 0 
	   or bot:IsMuted() 
	   or bot:IsStunned()
	   or bot:IsHexed()
	   or bot:HasModifier("modifier_doom_bringer_doom")
    then 
	    return ;
	end
	
	local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	local hNearbyEnemyTowerList = bot:GetNearbyTowers(888,true); 
	local npcTarget = J.GetProperTarget(bot);
	local mode = bot:GetActiveMode();
	
	local aether = X.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
	

	local se = X.IsItemAvailable("item_silver_edge");
	if se == nil then se = X.IsItemAvailable("item_invis_sword") end
    if se ~= nil and se:IsFullyCastable() 
	   and not bot:IsUsingAbility() and not bot:IsCastingAbility()
	then
		if bot:GetActiveMode() == BOT_MODE_RETREAT 
			and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
			and #hNearbyEnemyHeroList > 0
		then
			bot:Action_UseAbility(se);
			return;
	    end
		
		if bot:GetHealth()/bot:GetMaxHealth() < 0.2
		   and (#hNearbyEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero(5.0))
		then
			bot:Action_UseAbility(se);
			return;
	    end		
		
		if J.IsGoingOnSomeone(bot)
		   and J.IsValidHero(npcTarget)
		   and J.CanCastOnMagicImmune(npcTarget)
		then
			if not J.IsInRange(bot, npcTarget, 1800)
			then
				local hEnemyCreepList = bot:GetNearbyLaneCreeps(800,false);
				if #hEnemyCreepList == 0 and #hNearbyEnemyHeroList == 0
				then
					bot:Action_UseAbility(se);
					return;
				end
			end		
		end
		
		
	end
	
	local shivas = X.IsItemAvailable("item_shivas_guard")
	if shivas ~= nil and shivas:IsFullyCastable()
	then
		local tableNearbyCreeps = bot:GetNearbyCreeps(800,true);
		if #tableNearbyCreeps >= 6 
		   or #hNearbyEnemyHeroList >= 1
		then
			bot:Action_UseAbility(shivas);
			return;
		end
	end
	
------------------*************************************----------------------------------	


	if  bot:IsChanneling() 
		or bot:IsUsingAbility()
		or bot:IsCastingAbility( )
		or ( bot:IsInvisible()
		     and not bot:HasModifier("modifier_phantom_assassin_blur_active") )
	then
		return;
	end
	
		
	local pt = X.IsItemAvailable("item_power_treads");
	if pt ~= nil and pt:IsFullyCastable()
	then
		if (   bot:HasModifier("modifier_flask_healing")
		   or  bot:HasModifier("modifier_clarity_potion")
		   or  bot:HasModifier("modifier_item_urn_heal")
		   or  bot:HasModifier("modifier_filler_heal")
		   or  bot:HasModifier("modifier_item_spirit_vessel_heal")
		   or  bot:HasModifier("modifier_bottle_regeneration") )
		   and mode ~= BOT_MODE_ATTACK 
		   and mode ~= BOT_MODE_RETREAT 
		then
			if pt:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT
			then
				bot:Action_UseAbility(pt);
				return	
			end
		elseif  ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE ) 
				or mode == BOT_MODE_EVASIVE_MANEUVERS
				or (J.IsNotAttackProjectileIncoming(bot, 1600))
				or (bot:HasModifier("modifier_sniper_assassinate"))
				or (bot:GetHealth()/bot:GetMaxHealth() < 0.2)
				or (pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH and bot:GetHealth()/bot:GetMaxHealth() < 0.25)
				or (mode ~= BOT_MODE_LANING and bot:GetLevel() < 12 and J.IsEnemyFacingUnit(800,bot,30))
			then
				if pt:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
				then
					bot:Action_UseAbility(pt);
					return
				end
		elseif  mode == BOT_MODE_ATTACK 
				or mode == BOT_MODE_TEAM_ROAM
			then
				if  X.CanSwitchPTStat(pt) 
				then
					bot:Action_UseAbility(pt);
					return
				end
		else
			local enemies = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			local creeps = bot:GetNearbyCreeps(1200,true);
			if  #creeps == 0
				and  #enemies == 0 
				and  (npcTarget == nil or GetUnitToUnitDistance(bot,npcTarget) > 1600)
				and  bot:DistanceFromFountain() > 400
				and  mode ~= BOT_MODE_ROSHAN
			then
				if pt:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT
				then
					bot:Action_UseAbility(pt);
					return
				end
			elseif X.CanSwitchPTStat(pt)
				then
					bot:Action_UseAbility(pt);
					return			 
			end
		end
	end
	
	--------------*********************------------------------------
	if DotaTime() < lasItemCheckTime + 0.06 then return end;
	--------------*********************------------------------------
	
	local tps = X.IsItemAvailable("item_travel_boots_2");
	if tps == nil or not tps:IsFullyCastable()
	then tps = X.IsItemAvailable("item_travel_boots");end;
	if tps == nil or not tps:IsFullyCastable()
	then tps = bot:GetItemInSlot(15); end;	
	if tps ~= nil and tps:IsFullyCastable()
	   and #hNearbyEnemyTowerList == 0
	   and not J.IsShopping(bot)
	   and (not bot:WasRecentlyDamagedByAnyHero(2.0) 
			or bot:HasModifier("modifier_bloodseeker_rupture") 
			or #hNearbyEnemyHeroList == 0)
	then
		local nAncient = GetAncient(GetTeam());
		local tpLoc = nil
		local shouldTP = false
		shouldTP, tpLoc = X.ShouldTP()
		if shouldTP then 
		
			if tps:GetName() ~= "item_tpscroll" 
			   and J.GetLocationToLocationDistance(tpLoc , J.GetTeamFountain() ) > 3000 
			then
				tpLoc = J.GetNearestLaneFrontLocation(tpLoc,false,-600);
				if GetUnitToLocationDistance(bot,tpLoc) > 3200
				then
					J.Print("飞鞋常规用法:",GetUnitToLocationDistance(bot,tpLoc));
					bot:Action_UseAbilityOnLocation(tps, tpLoc);
					return;
				end
			end	
		
		
			if J.GetLocationToLocationDistance(tpLoc , J.GetTeamFountain() ) > 2500 
			then				
				local nAncientDistance = GetUnitToLocationDistance(GetAncient(GetTeam()),tpLoc);
				if nAncientDistance > 1800 and nAncientDistance < 2800
				then
					local newLoc = J.GetLocationTowardDistanceLocation(nAncient,tpLoc,nAncientDistance - 800);
					if GetUnitToLocationDistance(bot,newLoc) > 3200 then tpLoc = newLoc end;
				end
			end					


			bot:Action_UseAbilityOnLocation(tps, tpLoc);
			return;
		end	
		
		--使用tp来farm
		if bot:GetLevel() >= 10 
		   and mode ~= BOT_MODE_ROSHAN
		   and J.GetAllyCount(bot,1600) <= 2
		   and J.Role.ShouldTpToFarm() 
		   and not J.Role.IsAllyHaveAegis()
		   and not J.Role.CanBeSupport(bot:GetUnitName())
		   and not J.IsEnemyHeroAroundLocation(GetAncient(GetTeam()):GetLocation(), 3300)
		then
			local nAttackAllys = bot:GetNearbyHeroes(1600,false,BOT_MODE_ATTACK);
		    local nEnemy = bot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
			local nCreeps= bot:GetNearbyCreeps(1600,true);
			local mostFarmDesireLane,mostFarmDesire = J.GetMostFarmLaneDesire();

			if mostFarmDesire > BOT_MODE_DESIRE_VERYHIGH *0.95
				and #nEnemy == 0
				and #nCreeps == 0
				and #nAttackAllys == 0
				and not X.IsAllyChanneling()				
			then
				
				if tps:GetName() ~= "item_tpscroll"
				then
					tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,-600);
					local nAllies = J.GetAlliesNearLoc(tpLoc, 1600);
					if GetUnitToLocationDistance(bot,tpLoc) > 3800 and #nAllies == 0
					then					
						J.Print("飞鞋发育用法:",GetUnitToLocationDistance(bot,tpLoc));
						J.Role['lastFarmTpTime'] = DotaTime();
						bot:Action_UseAbilityOnLocation(tps, tpLoc);
						return;
					end
				end
						
				tpLoc = GetLaneFrontLocation(GetTeam(),mostFarmDesireLane,0);
				local bestTpLoc = J.GetNearbyLocationToTp(tpLoc);
				local nAllies = J.GetAlliesNearLoc(tpLoc, 1600);
				if bestTpLoc ~= nil 
				   and J.IsLocHaveTower(1850,false,tpLoc)
				   and GetUnitToLocationDistance(bot,bestTpLoc) > 3800 
				   and #nAllies == 0
				then
					J.Print("TP发育用法:",GetUnitToLocationDistance(bot,bestTpLoc));
					J.Role['lastFarmTpTime'] = DotaTime();
					bot:Action_UseAbilityOnLocation(tps, bestTpLoc);
					return;
				end
			end	
		end
		
		--使用tp来支援团战
		if bot:GetLevel() > 10
			and mode ~= BOT_MODE_RUNE
			and mode ~= BOT_MODE_SECRET_SHOP
			and mode ~= BOT_MODE_ROSHAN
			and mode ~= BOT_MODE_ATTACK
			and ( npcTarget == nil or not npcTarget:IsHero() )
			and J.GetAllyCount(bot,1600) < 3 --守护遗迹bug
		then
			local nEnemys = bot:GetNearbyHeroes(1400,true,BOT_MODE_NONE);
			local nTeamFightLocation = J.GetTeamFightLocation(bot);
			if #nEnemys == 0 and nTeamFightLocation ~= nil
			   and GetUnitToLocationDistance(bot,nTeamFightLocation) > 3200
			then
			
				if tps:GetName() ~= "item_tpscroll"
				then
					J.Print("飞鞋团战用法:",GetUnitToLocationDistance(bot,nTeamFightLocation));
					bot:Action_UseAbilityOnLocation(tps, nTeamFightLocation);
					return;
				end
			
				local bestTpLoc = J.GetNearbyLocationToTp(nTeamFightLocation);
				if bestTpLoc ~= nil
			       and J.GetLocationToLocationDistance(bestTpLoc,nTeamFightLocation) < 1800
				   and GetUnitToLocationDistance(bot,bestTpLoc) > 2400
				then
					J.Print("TP团战用法:",GetUnitToLocationDistance(bot,nTeamFightLocation));
					bot:Action_UseAbilityOnLocation(tps, bestTpLoc);
					return;
				end
			end
			
			--使用tp来支守护遗迹
			if bot:GetLevel() >= 22	and #nEnemys == 0 
			   and J.Role.ShouldTpToFarm() 
			   and bot:DistanceFromFountain() > 2000
			   and GetUnitToUnitDistance(bot,nAncient) > 3800
			   and J.GetAroundTargetAllyHeroCount(nAncient, 1600, bot) == 0
			then
				local nEnemyLaneFront = J.GetNearestLaneFrontLocation(nAncient:GetLocation(),true,400);
				if nEnemyLaneFront ~= nil
				   and GetUnitToLocationDistance(nAncient,nEnemyLaneFront) <= 1400
				then
				
					if tps:GetName() ~= "item_tpscroll"
					then
						J.Print("飞鞋守家用法:",GetUnitToLocationDistance(nAncient,nEnemyLaneFront));
						J.Role['lastFarmTpTime'] = DotaTime();
						bot:Action_UseAbilityOnLocation(tps, nAncient:GetLocation());
						return;
					end				
				
					J.Print("TP守家用法:",GetUnitToLocationDistance(nAncient,nEnemyLaneFront));
					J.Role['lastFarmTpTime'] = DotaTime();
					bot:Action_UseAbilityOnLocation(tps, nAncient:GetLocation());
					return;
					
				end
			end
			
		end
		
		
	end	
	
	
	local bas = X.IsItemAvailable("item_ring_of_basilius");
	if bas ~= nil and bas:IsFullyCastable() and DotaTime() % 3 < 1 
	then
		if #hNearbyEnemyTowerList == 0 
		   and mode == BOT_MODE_LANING
		then
		    if not bas:GetToggleState() 
			then
				bot:Action_UseAbility(bas);
			    return
			end
		else
		    if bas:GetToggleState() then
			   bot:Action_UseAbility(bas);
			   return
			end
		end
	end
	

	local itg = X.IsItemAvailable("item_tango");
	if itg ~= nil and itg:IsFullyCastable() then
		local tCharge = itg:GetCurrentCharges()
		if DotaTime() > -86 and DotaTime() < 0 and bot:DistanceFromFountain() < 400 and J.Role.CanBeSupport(bot:GetUnitName())
		   and bot:GetAssignedLane() ~= LANE_MID and tCharge > 2 and DotaTime() > giveTime + 2.0 then
			local target = X.GiveToMidLaner()
			if target ~= nil then
				bot:Action_UseAbilityOnEntity(itg, target);
				giveTime = DotaTime();
				return;
			end
		elseif bot:GetLevel() < 12
			  and (#hNearbyEnemyHeroList == 0 or mode == BOT_MODE_LANING)
			  and tCharge >= 1 
			  and DotaTime() > 0
			  and DotaTime() > giveTime + 2.0 
			then
			local allies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
			for _,ally in pairs(allies)
			do
				if J.IsValid(ally) and ally:GetUnitName() ~= bot:GetUnitName()
				then
					local tangoSlot = ally:FindItemSlot('item_tango');
					if tangoSlot == -1 
					   and not ally:IsIllusion() 
					   and not ally:HasModifier("modifier_arc_warden_tempest_double")
					   and ally:GetUnitName() ~= "npc_dota_hero_meepo"
					   and X.GetItemCount(ally, "item_tango_single") == 0 
					   and ally:GetItemInSlot(5) == nil
					then
						bot:Action_UseAbilityOnEntity(itg, ally);
						giveTime = DotaTime();
						return
					end
				end
			end
		end
	end
	
	
	local its = X.IsItemAvailable("item_tango_single");
	local tango = its;
	local item_tango_rate = 160; 
	if(its == nil or not its:IsFullyCastable())
	then
		tango = itg;
		item_tango_rate = 200;
	end
	if tango ~= nil and DotaTime() > 0 
	   and tango:IsFullyCastable() 
	   and bot:DistanceFromFountain() > 4000 
	then
		if not bot:HasModifier("modifier_tango_heal")
		   and not bot:HasModifier("modifier_filler_heal")
		   and not bot:HasModifier("modifier_flask_healing")
		then
			local trees = bot:GetNearbyTrees(800);
			local nEnemies = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
			local nTowers = bot:GetNearbyTowers(1500,true)
			if trees[1] ~= nil  			   
			   and  IsLocationVisible(GetTreeLocation(trees[1])) 
			   and  IsLocationPassable(GetTreeLocation(trees[1])) 
			   and  #nEnemies == 0 
			   and  #nTowers == 0
			   and bot:GetMaxHealth() - bot:GetHealth() > item_tango_rate
			then
				bot:Action_UseAbilityOnTree(tango, trees[1]);
				return;
			end
			
			local nearbyTrees = bot:GetNearbyTrees(200);
			if nearbyTrees[1] ~= nil
				and  IsLocationVisible(GetTreeLocation(nearbyTrees[1])) 
				and  IsLocationPassable(GetTreeLocation(nearbyTrees[1])) 
			then
				if  bot:GetMaxHealth() - bot:GetHealth() > item_tango_rate
				then
					bot:Action_UseAbilityOnTree(tango, nearbyTrees[1]);
					return;
				end
				
				if bot:GetMaxHealth() - bot:GetHealth() > item_tango_rate *0.38
				   and bot:WasRecentlyDamagedByAnyHero(1.0)
				   and ( bot:GetActiveMode() == BOT_MODE_ATTACK 
				         or ( bot:GetActiveMode() == BOT_MODE_RETREAT 
						      and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH ) )
				then
					bot:Action_UseAbilityOnTree(tango, nearbyTrees[1]);
					return;
				end
			end
		end
	end	
	
	
	local blink = X.IsItemAvailable("item_blink");	
	if blink ~= nil and blink:IsFullyCastable() then
		if J.IsStuck(bot)
		then
			bot:ActionImmediate_Chat("I'm using blink while stuck.", true);
			bot:Action_UseAbilityOnLocation(blink, J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), 1100 ));
			return;
		end
		
		--Retreat
		if ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE )
		then
			local bLocation = J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), 1199 );
			local nAttackAllys = bot:GetNearbyHeroes(600,false,BOT_MODE_ATTACK);
			if bot:DistanceFromFountain() > 800 
			   and IsLocationPassable(bLocation) 
			   and #nAttackAllys == 0
			   and #hNearbyEnemyHeroList >= 1
			then
				J.SetReport("闪烁逃跑",#hNearbyEnemyHeroList)
				bot:Action_UseAbilityOnLocation(blink, bLocation);
				return;
			end
		end 
		
		--Farm
		local nEnemyHeroInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nAttackAllys    = bot:GetNearbyHeroes(1600,false,BOT_MODE_ATTACK);
		if #nEnemyHeroInView == 0 and not bot:WasRecentlyDamagedByAnyHero(3.0)
		   and #nAttackAllys == 0 and ( npcTarget == nil or not npcTarget:IsHero())
		then
			local nAOELocation = bot:FindAoELocation(true,false,bot:GetLocation(),1600,400,0,0);
			local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true);
			if nAOELocation.count >= 4 
			   and #nLaneCreeps >= 4
			then
				local bCenter = J.GetCenterOfUnits(nLaneCreeps);
				local bDist = GetUnitToLocationDistance(bot,bCenter);
				local vLocation = J.GetLocationTowardDistanceLocation(bot,bCenter, bDist + 550);
				local bLocation = J.GetLocationTowardDistanceLocation(bot,bCenter, bDist - 300);
				if bDist >= 1500 then bLocation = J.GetLocationTowardDistanceLocation(bot,bCenter, 1199); end
				
				if IsLocationPassable(bLocation) 
				   and GetUnitToLocationDistance(bot,bLocation) > 600
				   and IsLocationVisible(vLocation)
				then
					J.SetReport("闪烁打钱",#nLaneCreeps)
					bot:Action_UseAbilityOnLocation(blink, bLocation);
					return;
				end
			end				
		end
		
		--躲技能
		if J.IsProjectileIncoming(bot, 1800)
			and (npcTarget == nil 
			     or not npcTarget:IsHero() 
				 or not J.IsInRange(bot,npcTarget,bot:GetAttackRange() + 100) )
		then
			J.SetReport("闪烁躲技能",#hNearbyEnemyHeroList)
			local bLocation = J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), 1199 );
			bot:Action_UseAbilityOnLocation(blink, bLocation);
			return;
		end
		--shopping
		
		--Attack
		
	end
	
	
	local its = X.IsItemAvailable("item_tango_single");
	if its ~= nil and its:IsFullyCastable() and bot:DistanceFromFountain() > 1000 and DotaTime() > 0 and npcTarget == nil then
	    local tCount = X.GetItemCount(bot, "item_tango_single")
		if DotaTime() > 4*60 +30
		   and mode ~= BOT_MODE_RUNE
		   and tCount >= 2
		then
			local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			local trees = bot:GetNearbyTrees(1000);
			if trees[1] ~= nil  and ( IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])) )
			   and #hNearbyEnemyHeroList == 0 
			then
				bot:Action_UseAbilityOnTree(its, trees[1]);
				return;
			end
		end
	
		if DotaTime() > 7*60 +30 
			and mode ~= BOT_MODE_RUNE
		then
			local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			local trees = bot:GetNearbyTrees(1000);
			if trees[1] ~= nil  and ( IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])) )
			   and #hNearbyEnemyHeroList == 0 
			then
				bot:Action_UseAbilityOnTree(its, trees[1]);
				return;
			end
		end
	end
	
	
	
	local icl = X.IsItemAvailable("item_clarity");
	if icl ~= nil and icl:IsFullyCastable() and bot:DistanceFromFountain() > 4000 then
		if DotaTime() > 0 
		then
			local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			if  (bot:GetMana() / bot:GetMaxMana())  < 0.35 
				and not bot:HasModifier("modifier_clarity_potion")
				and #hNearbyEnemyHeroList == 0 
				and not bot:WasRecentlyDamagedByAnyHero(5.0)
			then
				bot:Action_UseAbilityOnEntity(icl, bot);
				return;
			end
			
			local hAllyList=bot:GetNearbyHeroes(300,false,BOT_MODE_NONE);
			local NeedManaAlly = nil
			local NeedManaAllyMana = 99999
			for _,ally in pairs(hAllyList) do
				if J.IsValid(ally)
				   and ally ~= bot
				   and not ally:HasModifier("modifier_clarity_potion")  
				   and not ally:WasRecentlyDamagedByAnyHero(5.0)
				   and X.CanCastOnTarget(ally) 
				   and not ally:IsIllusion()
				   and not ally:IsChanneling() 
				   and ally:GetMaxMana() - ally:GetMana() > 350 
				   and #hNearbyEnemyHeroList == 0 				   				   			
				then
					if(ally:GetMana() < NeedManaAllyMana )
					then
						NeedManaAlly = ally
						NeedManaAllyMana = ally:GetMana()
					end
				end
			end		
			if(NeedManaAlly ~= nil)
			then
				bot:Action_UseAbilityOnEntity(icl,NeedManaAlly );
				return;
			end
		end
	end
	
	
	local ifl = X.IsItemAvailable("item_flask");
	if ifl ~= nil and ifl:IsFullyCastable() 
		and bot:DistanceFromFountain() > 4000 
	then
		if DotaTime() > 60 
		then
			local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			if  (bot:GetMaxHealth() - bot:GetHealth() )  > 600
				and #hNearbyEnemyHeroList == 0 
				and not bot:WasRecentlyDamagedByAnyHero(3.1)
				and not bot:HasModifier("modifier_filler_heal") 
			then
				bot:Action_UseAbilityOnEntity(ifl, bot);
				return;
			end
			
			local hAllyList=bot:GetNearbyHeroes(600,false,BOT_MODE_NONE);
			local hNeedHealAlly = nil
			local nNeedHealAllyHealth = 99999
			for _,ally in pairs(hAllyList) do
				if J.IsValid(ally)
				   and not ally:HasModifier("modifier_filler_heal")  
				   and not ally:WasRecentlyDamagedByAnyHero(5.0)
				   and X.CanCastOnTarget(ally) 
				   and not ally:IsIllusion()
				   and not ally:IsChanneling()
				   and ally:GetMaxHealth() - ally:GetHealth() > 550 
				   and #hNearbyEnemyHeroList == 0 				   				   			
				then
					if(ally:GetHealth() < nNeedHealAllyHealth )
					then
						hNeedHealAlly = ally
						nNeedHealAllyHealth = ally:GetHealth()
					end
				end
			end		
			if(hNeedHealAlly ~= nil)
			then
				bot:Action_UseAbilityOnEntity(ifl,hNeedHealAlly );
				return;
			end
			
		end
	end
	
	
	
	local mg = X.IsItemAvailable("item_enchanted_mango");
	if mg ~= nil and mg:IsFullyCastable() 
	then
		if J.IsGoingOnSomeone(bot) 
		   and bot:GetMana() < 100
		   and J.IsValidHero(npcTarget)
		   and J.IsInRange(bot,npcTarget,1200)
        then
			bot:Action_UseAbility(mg);
			return;
		end
	end
	
	
	local tok = X.IsItemAvailable("item_tome_of_knowledge");
	if tok ~= nil and tok:IsFullyCastable() then
		if firstUseTime == 0 
		then
			firstUseTime = DotaTime();
		end
		
		if firstUseTime < DotaTime() - 6.1
		then
			firstUseTime = 0;
			bot:Action_UseAbility(tok);
			return;
		end
	end
	
	
	local ff = X.IsItemAvailable("item_faerie_fire");
	if ff ~= nil and ff:IsFullyCastable() then
		if ( mode == BOT_MODE_RETREAT 
		     and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH 
			 and bot:DistanceFromFountain() > 300 
			 and ( bot:GetHealth() / bot:GetMaxHealth() ) < 0.15 ) 
		   or DotaTime() > 10 *60
		then
			bot:Action_UseAbility(ff);
			return;
		end
	end
	
	local blade = X.IsItemAvailable("item_quelling_blade");
	if blade == nil then blade = X.IsItemAvailable("item_bfury"); end
	if blade ~= nil and blade:IsFullyCastable()
	then
		
		if DotaTime() < 60 and not thereBeMonkey
		then
			for i, id in pairs(GetTeamPlayers(GetOpposingTeam())) 
			do
				if  GetSelectedHeroName(id) == 'npc_dota_hero_monkey_king' 
				then
					thereBeMonkey = true;
				end
			end
		end
		
		if thereBeMonkey
		then
			local theMonkeyKing = nil;
			for _,enemy in pairs(hNearbyEnemyHeroList)
			do
				if enemy:IsAlive()
					and enemy:GetUnitName() == "npc_dota_hero_monkey_king"
				then
					theMonkeyKing = enemy;
					break;
				end		
			end
			
			if theMonkeyKing ~= nil
			   and J.IsInRange(bot,theMonkeyKing,450)
			then
				local nTrees = bot:GetNearbyTrees(450);
				for _,tree in pairs(nTrees)
				do
					local treeLoc = GetTreeLocation(tree);
					if GetUnitToLocationDistance(theMonkeyKing,treeLoc) < 30
					then
						bot:Action_UseAbilityOnTree(blade, tree);
						return;
					end			
				end
			end
		end
	
		--开视野
		
	end
	
	
	local pb = X.IsItemAvailable("item_phase_boots");
	if pb ~= nil and pb:IsFullyCastable() 
	then
		if J.IsRunning(bot)
		then
			bot:Action_UseAbility(pb);
			return;
		end	
	end
	
	local bst = X.IsItemAvailable("item_bloodstone");
	if bst ~= nil and bst:IsFullyCastable() 
	then
		if  mode == BOT_MODE_RETREAT 
		    and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH 
			and ( bot:GetHealth() / bot:GetMaxHealth() ) < 0.10 - ( bot:GetLevel() / 500 ) 
			and	( bot:GetMana() / bot:GetMaxMana() > 0.6 )
		then
			bot:Action_UseAbility(bst);
			return;
		end
	end
	
	local eb = X.IsItemAvailable("item_ethereal_blade");
	if eb ~= nil and eb:IsFullyCastable() and bot:GetUnitName() ~= "npc_dota_hero_morphling"
	then
		local nCastRange = 1050;
		if J.IsGoingOnSomeone(bot)
		then
			if J.IsValidHero(npcTarget)
				and J.CanCastOnNonMagicImmune(npcTarget)
				and GetUnitToUnitDistance(npcTarget, bot) < nCastRange 
			then
			    bot:Action_UseAbilityOnEntity(eb,npcTarget);
				return
			end
		end
	end
	
	
	local rs = X.IsItemAvailable("item_refresher_shard");
	if rs ~= nil and rs:IsFullyCastable() 
	then
		if J.IsGoingOnSomeone(bot) 
		   and J.CanUseRefresherShard(bot)  
		then
			bot:Action_UseAbility(rs);
			return
		end
	end
	
	
	local ro = X.IsItemAvailable("item_refresher");
	if ro ~= nil and ro:IsFullyCastable() 
	then
		if J.IsGoingOnSomeone(bot) 
		   and J.CanUseRefresherOrb(bot)  
		then
			bot:Action_UseAbility(ro);
			return
		end
	end
	
	
	local sc = X.IsItemAvailable("item_solar_crest");
	if sc == nil then sc = X.IsItemAvailable("item_medallion_of_courage"); end
	if sc ~= nil and sc:IsFullyCastable() 
	then
		if J.IsGoingOnSomeone(bot)
		then
			if J.IsValidHero(npcTarget) 
			   and not npcTarget:HasModifier('modifier_item_solar_crest_armor_reduction') 
			   and not npcTarget:HasModifier('modifier_item_medallion_of_courage_armor_reduction') 
			   and J.CanCastOnNonMagicImmune(npcTarget)
			   and (GetUnitToUnitDistance(npcTarget, bot) < bot:GetAttackRange() + 150
					or (GetUnitToUnitDistance(npcTarget, bot) < 1000
					    and J.GetAroundTargetOtherAllyHeroCount(npcTarget, 600, bot) >= 1) )
			then
			    bot:Action_UseAbilityOnEntity(sc, npcTarget);
				return
			end
		end
		
		if #hNearbyEnemyHeroList == 0
		then
			if J.IsValid(npcTarget) 
			   and not npcTarget:HasModifier('modifier_item_solar_crest_armor_reduction') 
			   and not npcTarget:HasModifier('modifier_item_medallion_of_courage_armor_reduction') 
			   and not npcTarget:HasModifier("modifier_fountain_glyph")
			   and not J.CanKillTarget(npcTarget, bot:GetAttackDamage() *2.38, DAMAGE_TYPE_PHYSICAL)
			   and GetUnitToUnitDistance(npcTarget, bot) < bot:GetAttackRange() + 150
			then
			    bot:Action_UseAbilityOnEntity(sc, npcTarget);
				return;
			end
		end
	end
	
	if sc ~= nil and sc:IsFullyCastable() then
		local hAllyList = bot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,ally in pairs(hAllyList) do
			if ally ~= bot
			   and J.IsValidHero(ally)
			   and not ally:IsIllusion()
			   and X.CanCastOnTarget(ally)
			   and not ally:HasModifier('modifier_item_solar_crest_armor_addition') 
			   and not ally:HasModifier('modifier_item_medallion_of_courage_armor_addition') 
			   and not ally:HasModifier("modifier_arc_warden_tempest_double")
			   and (  ( X.IsDisabled(ally) )
			       or ( J.GetHPR(ally) < 0.35 and #hNearbyEnemyHeroList > 0 and ally:WasRecentlyDamagedByAnyHero(2.0) ) 
				   or ( J.IsValidHero(ally:GetAttackTarget()) and GetUnitToUnitDistance(ally,ally:GetAttackTarget()) <= ally:GetAttackRange() and #hNearbyEnemyHeroList == 0 ) )
			then
				bot:Action_UseAbilityOnEntity(sc,ally);
				return;
			end
		end
	end
	
	
	local hood = X.IsItemAvailable("item_hood_of_defiance");
    if hood ~= nil and hood:IsFullyCastable() 
	   and bot:GetHealth()/bot:GetMaxHealth()< 0.8 and not bot:HasModifier('modifier_item_pipe_barrier')
	then
		if hNearbyEnemyHeroList ~= nil and #hNearbyEnemyHeroList > 0 
		then
			bot:Action_UseAbility(hood);
			return;
		end
	end
	
	
	local hod = X.IsItemAvailable("item_helm_of_the_dominator");
	if hod ~= nil and hod:IsFullyCastable() 
	then
		local maxHP = 0;
		local hCreep = nil;
		local tableNearbyCreeps = bot:GetNearbyCreeps( 1000, true );
		if #tableNearbyCreeps >= 2 then
			for _,creep in pairs(tableNearbyCreeps)
			do
				if J.IsValid(creep)
				then
					local nCreepHP = creep:GetHealth();
					if nCreepHP > maxHP 
					   and ( creep:GetHealth() / creep:GetMaxHealth() ) > 0.75 
					   and not creep:IsAncientCreep()
					   and not J.IsKeyWordUnit("siege",creep)
					then
						hCreep = creep;
						maxHP = nCreepHP;
					end
				end
			end
		end
		if hCreep ~= nil then
			bot:Action_UseAbilityOnEntity(hod, hCreep);
			return
		end	
	end
	
	
	local necrono = X.IsItemAvailable("item_necronomicon");
	if necrono == nil then necrono = X.IsItemAvailable("item_necronomicon_2"); end
	if necrono == nil then necrono = X.IsItemAvailable("item_necronomicon_3"); end
	if necrono ~= nil and necrono:IsFullyCastable() 
	then
		if npcTarget ~= nil and npcTarget:IsAlive()
		   and J.IsInRange(bot, npcTarget, 700)
		then
			bot:Action_UseAbility(necrono);
			return;
		end	
	end
	
	
	local stick = X.IsItemAvailable("item_magic_stick");
	if stick ~= nil and stick:IsFullyCastable() and bot:DistanceFromFountain() > 300
	then
		local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		local nEnemyCount = #hNearbyEnemyHeroList;
		local nHPrate = bot:GetHealth()/bot:GetMaxHealth();
		local nMPrate = bot:GetMana()/bot:GetMaxMana();
		local nCharges = X.GetItemCharges(bot,"item_magic_stick");
		
		if ( ((nHPrate < 0.5 or nMPrate < 0.3) and nEnemyCount >= 1 and nCharges >= 1 )
			or( nHPrate + nMPrate < 1.1 and nCharges >= 7  and  nEnemyCount >= 1 )
			or( nCharges >= 9 and bot:GetCourierValue() > 200 and (nHPrate <= 0.7 or nMPrate <= 0.6)) )  
		then
			bot:Action_UseAbility(stick);
			return;
		end
	end	
	
	
	local wand = X.IsItemAvailable("item_magic_wand");
	if wand ~= nil and wand:IsFullyCastable() 
	   and bot:DistanceFromFountain() > 300
	   and wandTime < DotaTime() - 1.0
	then
		local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local nEnemyCount = #hNearbyEnemyHeroList;
		local nHPrate = bot:GetHealth()/bot:GetMaxHealth();
		local nMPrate = bot:GetMana()/bot:GetMaxMana();
		local nLostHP = bot:GetMaxHealth() - bot:GetHealth();
		local nLostMP = bot:GetMaxMana() - bot:GetMana();
		local nCharges = X.GetItemCharges(bot,"item_magic_wand");
		
		if ( ((nHPrate < 0.4 or nMPrate < 0.3) and  nEnemyCount >= 1 and nCharges >= 1 )
			or( nHPrate < 0.7  and nMPrate < 0.7 and nCharges >= 12  and  nEnemyCount >= 1 ) 
			or( nCharges >= 19 and bot:GetCourierValue() > 500 and (nHPrate <= 0.7 or nMPrate <= 0.6)) 
			or( nCharges == 20 and nEnemyCount >= 1 and nLostHP > 350 and nLostMP > 350 ) ) 				
		then
			wandTime = DotaTime();
			bot:Action_UseAbility(wand);
			return;
		end
	end
	
	
	local cyclone = X.IsItemAvailable("item_cyclone");
	if cyclone ~= nil and cyclone:IsFullyCastable() then
		local nCastRange = 650 +aetherRange;
		if J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and GetUnitToUnitDistance(bot, npcTarget) < nCastRange +200
		   and ( npcTarget:HasModifier('modifier_teleporting') 
		         or npcTarget:HasModifier('modifier_abaddon_borrowed_time') 
				 or npcTarget:HasModifier("modifier_ursa_enrage")
				 or npcTarget:HasModifier("modifier_item_satanic_unholy")
				 or npcTarget:IsChanneling()
				 or ( J.GetHPR(npcTarget) > 0.49 and J.IsCastingUltimateAbility(npcTarget) )
				 or ( J.IsRunning(npcTarget) and npcTarget:GetCurrentMovementSpeed() > 440)) 
		then
			bot:Action_UseAbilityOnEntity(cyclone, npcTarget);
			return;
		end
		
		if X.CanCastOnTarget(bot)
		   and hNearbyEnemyHeroList[1] ~= nil 
		   and ( bot:GetHealth() < 188
				  or ( bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT 
					   and bot:IsSilenced() )
				  or bot:IsRooted()  
				  or J.IsNotAttackProjectileIncoming(bot, 1600) )
		then
			bot:Action_UseAbilityOnEntity(cyclone, bot);
			return;
		end
	end		
	
	
	local metham = X.IsItemAvailable("item_meteor_hammer");  
	if metham ~= nil and metham:IsFullyCastable() then
		if J.IsPushing(bot) then
			local towers = bot:GetNearbyTowers(800, true);
			if #towers > 0 and towers[1] ~= nil and  towers[1]:IsInvulnerable() == false then 
				bot:Action_UseAbilityOnLocation(metham, towers[1]:GetLocation());
				return;
			end
		elseif J.IsInTeamFight(bot, 1200) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 600, 300, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				bot:Action_UseAbilityOnLocation(metham, locationAoE.targetloc);
				return;
			end
		elseif J.IsGoingOnSomeone(bot) then
			if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, 800) 
			   and J.IsDisabled(true, npcTarget) == true	
			then
				bot:Action_UseAbilityOnLocation(metham, npcTarget:GetLocation());
				return;
			end
		end
	end
	
	
	local bldemail = X.IsItemAvailable("item_blade_mail");
	if bldemail ~= nil and bldemail:IsFullyCastable() 
	then
		
		if J.IsNotAttackProjectileIncoming(bot, 366)
		then
			bot:Action_UseAbility(bldemail);
			return;
		end
		
		for _,npcEnemy in pairs(hNearbyEnemyHeroList)
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnMagicImmune(npcEnemy)
			   and npcEnemy:GetAttackTarget() == bot
			   and bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			then
				bot:Action_UseAbility(bldemail);
				return;
			end
		end
		
		
		--反弹大招伤害
	
	end
	
	
	local ghost = X.IsItemAvailable("item_ghost");
	if ghost ~= nil and ghost:IsFullyCastable() 
	then
		
		if bot:GetAttackTarget() == nil 
		   or bot:GetHealth() < 400 
		then
			for _,npcEnemy in pairs(hNearbyEnemyHeroList)
			do
				if J.IsValidHero(npcEnemy)
				   and J.CanCastOnMagicImmune(npcEnemy)
				   and J.IsInRange(bot,npcEnemy, npcEnemy:GetAttackRange() +100)
				   and npcEnemy:GetAttackTarget() == bot
				   and bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
				   and npcEnemy:GetAttackDamage() > bot:GetAttackDamage()
				then
					bot:Action_UseAbility(ghost);
					return;
				end
			end
		end
	
	end
	
	
	local lotus = X.IsItemAvailable("item_lotus_orb");
	if lotus ~= nil and lotus:IsFullyCastable() 
	then
		local nAllies = bot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,ally in pairs(nAllies)
		do
			if J.IsValid(ally)
				and not ally:IsIllusion()
				and not ally:IsMagicImmune()
				and not ally:IsInvulnerable()
				and not ally:HasModifier('modifier_item_lotus_orb_active') 
				and not ally:HasModifier('modifier_antimage_spell_shield') 
			then
				if J.IsUnitTargetProjectileIncoming(ally, 800) 
				   or J.IsWillBeCastUnitTargetSpell(ally,1200)
				   or ally:IsRooted()
				   or ally:IsSilenced()
				   or ally:IsDisarmed()
				then
					bot:Action_UseAbilityOnEntity(lotus,ally);
					return;
				end			
			end
		end
	end
		
		
	local sphere = X.IsItemAvailable("item_sphere");
	if sphere ~= nil and sphere:IsFullyCastable()
	then
		local nCastRange = 800;
		local nAllies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE)
		
		--Use at ally who BeTargeted
		for _,ally in pairs(nAllies)
		do 
			if  J.IsValidHero(ally)
				and ally ~= bot
				and not ally:IsMagicImmune()
				and not ally:IsInvulnerable()
				and not ally:IsIllusion()
				and not ally:HasModifier("modifier_item_sphere_target")
				and not ally:HasModifier('modifier_antimage_spell_shield') 
				and ( J.IsUnitTargetProjectileIncoming(ally, 800)
				      or J.IsWillBeCastUnitTargetSpell(ally,1200)
				      or bot:GetHealth() < 150 )
			then
				bot:Action_UseAbilityOnEntity(sphere,ally);
				return;
			end
		end
	
	
		if J.IsValidHero(npcTarget) 
		then			
			if J.IsValidHero(nAllies[2])
			then
				local targetAlly = nil
				local targetDis = 9999
				for _,ally in pairs(nAllies)
				do 
					if  ally ~= bot
						and not ally:IsIllusion()
						and GetUnitToUnitDistance(npcTarget,ally) < targetDis
						and not ally:HasModifier("modifier_item_sphere_target")
						and not ally:HasModifier('modifier_antimage_spell_shield') 
					then
						targetAlly = ally;
						targetDis = GetUnitToUnitDistance(npcTarget,ally);
					end
				end
				if targetAlly ~= nil
				then
					bot:Action_UseAbilityOnEntity(sphere,ally);
					return;
				end
			end
		end
	end
	
	
	local mjo = X.IsItemAvailable("item_mjollnir");
	if mjo ~= nil and mjo:IsFullyCastable()
	then
		local nCastRange = 800;
		local nNearbyAllies = bot:GetNearbyHeroes(nCastRange + 100,false,BOT_MODE_NONE);
		
		local nAttackAllys = bot:GetNearbyHeroes(1200,false,BOT_MODE_ATTACK);
		if #nAttackAllys >= 2
		then
			local targetAlly = nil;
			local maxTargetCount = 0;
			for _,ally in pairs(nNearbyAllies)
			do
				if  J.IsValid(ally)
					and not ally:IsIllusion()
					and not ally:HasModifier("modifier_item_mjollnir_static")
				then
				
					local nAllyCount = 0 ;
					local nEnemyHeroes = ally:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
					local nEnemyCreeps = ally:GetNearbyCreeps(1000,true);
					for _,unit in pairs(nEnemyHeroes)
					do 
						if unit ~= nil and unit:IsAlive()
						   and unit:GetAttackTarget() == ally
						then
							nAllyCount = nAllyCount + 1;
						end
					end
					for _,unit in pairs(nEnemyCreeps)
					do 
						if unit ~= nil and unit:IsAlive()
						   and unit:GetAttackTarget() == ally
						then
							nAllyCount = nAllyCount + 1;
						end
					end
					if nAllyCount > maxTargetCount
					then
						maxTargetCount = nAllyCount;
						targetAlly = ally;
					end
				end					
			end
			
			if targetAlly ~= nil
			then
				bot:Action_UseAbilityOnEntity(mjo, targetAlly);
				return;
			end		
		end
	
		if J.IsValidHero(npcTarget) 
		then
			local nAllies = J.GetAlliesNearLoc(npcTarget:GetLocation(),1400);
			if J.IsValid(nAllies[1])
			then
				local targetAlly = nil
				local targetDis = 9999
				for _,ally in pairs(nAllies)
				do 
					if  J.IsValid(ally)
					    and not ally:IsIllusion()
						and GetUnitToUnitDistance(bot,ally) <= nCastRange + 200
						and GetUnitToUnitDistance(npcTarget,ally) < targetDis
						and not ally:HasModifier("modifier_item_mjollnir_static")
					then
						targetAlly = ally;
						targetDis = GetUnitToUnitDistance(npcTarget,ally);
					end
				end
				if targetAlly ~= nil
				then
					bot:Action_UseAbilityOnEntity(mjo, targetAlly);
					return;
				end
			end
		end
			
		if hNearbyEnemyHeroList[1] == nil
		then
			local nAllyCreeps = bot:GetNearbyLaneCreeps(1000,false);
			local nEnemyCreeps = bot:GetNearbyLaneCreeps(1000,true);
			if #nAllyCreeps >= 1 and #nEnemyCreeps == 0
			then
				local targetCreep = nil
				local targetDis = 0
				for _,creep in pairs(nAllyCreeps)
				do 
					if J.IsValid(creep)
						and J.GetHPR(creep) > 0.6
						and creep:DistanceFromFountain() > targetDis
					then
						targetCreep = creep;
						targetDis  = creep:DistanceFromFountain();
					end
				end
				if targetCreep ~= nil
				then
					bot:Action_UseAbilityOnEntity(mjo,targetCreep);
					return;
				end
			end
		end
		
		if hNearbyEnemyHeroList[1] ~= nil
		then
			if not bot:HasModifier("modifier_item_mjollnir_static")
			then
				bot:Action_UseAbilityOnEntity(mjo,bot);
				return;
			end
		end
	end
	
	
	local amulet = X.IsItemAvailable("item_shadow_amulet");
	if amulet ~= nil 
	   and amulet:IsFullyCastable() 
	   and not bot:HasModifier('modifier_item_dustofappearance')
	   and not bot:HasModifier("modifier_item_shadow_amulet_fade")
	then
		local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		for _,enemy in pairs(nEnemies)
		do
			if enemy:IsAlive()
				and ( enemy:GetAttackTarget() == bot or enemy:IsFacingLocation(bot:GetLocation(),10) )
			then
				local nNearbyAllyEnemyTowers = bot:GetNearbyTowers(888,true);
				if #nNearbyAllyEnemyTowers == 0 and amuletTime < DotaTime() + 1.28
				then
					amuletTime = DotaTime();
					bot:Action_UseAbilityOnEntity(amulet,bot);
					return;
				end
			end
		end
		
		if not bot:HasModifier('modifier_item_glimmer_cape') 
		   and not bot:HasModifier('modifier_item_shadow_amulet_fade')
		   and not bot:HasModifier('modifier_item_dustofappearance')
		   and ( bot:IsStunned() or bot:IsRooted() or bot:IsNightmared() )
		then
			local nNearbyAllyEnemyTowers = bot:GetNearbyTowers(888,true);
			if #nNearbyAllyEnemyTowers == 0 and amuletTime < DotaTime() + 1.28
			then
				amuletTime = DotaTime();
				bot:Action_UseAbilityOnEntity(amulet,bot);
				return;
			end
		end
		
		local nAllies = bot:GetNearbyHeroes(849,false,BOT_MODE_NONE);
		for _,ally in pairs(nAllies) do
			if J.IsValid(ally)
			   and ally ~= bot
			   and not ally:IsIllusion()
			   and not ally:IsMagicImmune()
			   and not ally:IsInvisible()
			   and not ally:HasModifier('modifier_item_glimmer_cape') 
			   and not ally:HasModifier('modifier_item_shadow_amulet_fade')
			   and not ally:HasModifier('modifier_item_dustofappearance')
			   and ( ally:IsStunned() or ally:IsRooted() or ally:IsNightmared() )
			then
				local nNearbyAllyEnemyTowers = ally:GetNearbyTowers(888,true);
				if #nNearbyAllyEnemyTowers == 0
				then					
					bot:Action_UseAbilityOnEntity(amulet,bot);
					bot:ActionQueue_UseAbilityOnEntity(amulet,ally);
					return;
				end
			end
		end
	end
	
	
	local glimer = X.IsItemAvailable("item_glimmer_cape");
	if glimer ~= nil and glimer:IsFullyCastable() and #hNearbyEnemyTowerList == 0 then
		if  not bot:IsMagicImmune()
			and not bot:IsInvulnerable()
			and bot:DistanceFromFountain() > 300
			and not bot:HasModifier('modifier_item_dustofappearance')
			and not bot:HasModifier('modifier_item_glimmer_cape') 
			and ( bot:IsSilenced() 
				  or bot:IsRooted()
				  or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
			      or ( npcTarget == nil and #hNearbyEnemyHeroList > 0 and bot:GetHealth()/bot:GetMaxHealth() < 0.35 + (0.05*#hNearbyEnemyHeroList) ) )
	    then
			bot:Action_UseAbilityOnEntity(glimer,bot);
			return;
		end
	end
	
	if glimer ~= nil and glimer:IsFullyCastable() then
		local hAllyList = bot:GetNearbyHeroes(1049,false,BOT_MODE_NONE);
		for _,ally in pairs(hAllyList) do
			if J.IsValid(ally)
			   and not ally:IsIllusion()
			   and not ally:IsMagicImmune()
			   and not ally:IsInvisible()
			   and not ally:HasModifier('modifier_item_glimmer_cape') 
			   and not ally:HasModifier('modifier_item_dustofappearance')
			   and ally:WasRecentlyDamagedByAnyHero(5.0)
			   and (( ally:GetHealth()/ally:GetMaxHealth() < 0.35 and J.IsRetreating(ally) ) or X.IsDisabled(ally))
			then
				local nNearbyAllyEnemyTowers = ally:GetNearbyTowers(888,true);
				if #nNearbyAllyEnemyTowers == 0
				then
					bot:Action_UseAbilityOnEntity(glimer,ally);
					return;
				end
			end
		end
	end
	
	
	local dagon = X.IsItemAvailable("item_dagon");
	if dagon == nil then dagon = X.IsItemAvailable("item_dagon_2"); end
	if dagon == nil then dagon = X.IsItemAvailable("item_dagon_3"); end
	if dagon == nil then dagon = X.IsItemAvailable("item_dagon_4"); end
	if dagon == nil then dagon = X.IsItemAvailable("item_dagon_5"); end
	if dagon ~= nil and dagon:IsFullyCastable() 
	then
		local nCastRange = 800 +aetherRange
	
		if J.IsGoingOnSomeone(bot)
		then			
			if  J.IsValidHero(npcTarget) 
                and J.CanCastOnNonMagicImmune(npcTarget)				
				and J.IsInRange(bot, npcTarget, nCastRange)
			then
			    bot:Action_UseAbilityOnEntity(dagon, npcTarget);
				return;
			end
		end
	end
	
	
	local atos = X.IsItemAvailable("item_rod_of_atos");
	if atos ~= nil and atos:IsFullyCastable()
	then
		local nCastRange = 1200 +aetherRange;
		local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE)
		for _,npcEnemy in pairs( nEnemysHerosInCastRange )
		do
			if J.IsValid(npcEnemy)
			   and npcEnemy:IsChanneling()
			   and npcEnemy:HasModifier("modifier_teleporting")
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				bot:Action_UseAbilityOnEntity(atos,npcEnemy);
				return
			end
		end
		
		if mode == BOT_MODE_RETREAT 
		   and  bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		   and	J.IsValid(nEnemysHerosInCastRange[1])
		   and  J.CanCastOnNonMagicImmune(nEnemysHerosInCastRange[1])
		   and  not X.IsDisabled(nEnemysHerosInCastRange[1])
		then
			bot:Action_UseAbilityOnEntity(atos,nEnemysHerosInCastRange[1]);
			return;
	    end	
	
		if J.IsGoingOnSomeone(bot)
		then			
			if  J.IsValidHero(npcTarget) 
				and not X.IsDisabled(npcTarget)
                and J.CanCastOnNonMagicImmune(npcTarget)				
				and GetUnitToUnitDistance(npcTarget, bot) <= nCastRange
				and J.IsMoving(npcTarget)
			then
			    bot:Action_UseAbilityOnEntity(atos,npcTarget);
				return
			end
		end
	
	end
	
	
	local sheep = X.IsItemAvailable("item_sheepstick");
	if sheep ~= nil and sheep:IsFullyCastable()
	then
		local nCastRange = 850 +aetherRange;
		local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE)
		for _,npcEnemy in pairs( nEnemysHerosInCastRange )
		do
			if J.IsValid(npcEnemy)
			   and (npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility())
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				bot:Action_UseAbilityOnEntity(sheep,npcEnemy);
				return
			end
		end
		
		if mode == BOT_MODE_RETREAT 
		   and  bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		   and	J.IsValid(nEnemysHerosInCastRange[1])
		   and  J.CanCastOnNonMagicImmune(nEnemysHerosInCastRange[1])
		   and  not X.IsDisabled(nEnemysHerosInCastRange[1])
		then
			bot:Action_UseAbilityOnEntity(sheep,nEnemysHerosInCastRange[1]);
			return;
	    end	
	
		if J.IsGoingOnSomeone(bot)
		then		
			if  J.IsValidHero(npcTarget)
				and not X.IsDisabled(npcTarget)
                and J.CanCastOnNonMagicImmune(npcTarget)				
				and GetUnitToUnitDistance(npcTarget, bot) < nCastRange
			then
			    bot:Action_UseAbilityOnEntity(sheep,npcTarget);
				return;
			end
		end
	
	end
	
	
	local abyssal = X.IsItemAvailable("item_abyssal_blade");
	if abyssal ~= nil and abyssal:IsFullyCastable()
	then
		local nCastRange = 300 +aetherRange;
		local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE)
		for _,npcEnemy in pairs( nEnemysHerosInCastRange )
		do
			if J.IsValid(npcEnemy)
			   and (npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility())
			   and J.CanCastOnMagicImmune(npcEnemy)
			then
				bot:Action_UseAbilityOnEntity(abyssal,npcEnemy);
				return
			end
		end
		
		if mode == BOT_MODE_RETREAT 
		   and  bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		   and	J.IsValid(nEnemysHerosInCastRange[1])
		   and  J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		   and  not X.IsDisabled(nEnemysHerosInCastRange[1])
		then
			bot:Action_UseAbilityOnEntity(abyssal,nEnemysHerosInCastRange[1]);
			return;
	    end	
	
		if J.IsGoingOnSomeone(bot)
		then		
			if  J.IsValidHero(npcTarget)
				and J.CanCastOnMagicImmune(npcTarget) 
				and not X.IsDisabled(npcTarget)			
				and GetUnitToUnitDistance(npcTarget, bot) < nCastRange
			then
			    bot:Action_UseAbilityOnEntity(abyssal,npcTarget);
				return;
			end
		end
	
	end
	
	
	local bt = X.IsItemAvailable("item_bloodthorn");
	if bt == nil then bt = X.IsItemAvailable("item_orchid") end 
	if bt ~= nil and bt:IsFullyCastable()
	then
		local nCastRange = 950 +aetherRange;
		
		local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE)
		for _,npcEnemy in pairs( nEnemysHerosInCastRange )
		do
			if J.IsValid(npcEnemy)
			   and (npcEnemy:IsChanneling() or npcEnemy:IsCastingAbility())
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				bot:Action_UseAbilityOnEntity(bt,npcEnemy);
				return
			end
		end
		
		if mode == BOT_MODE_RETREAT 
		   and  bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		   and	J.IsValid(nEnemysHerosInCastRange[1])
		   and  J.CanCastOnNonMagicImmune(nEnemysHerosInCastRange[1])
		   and  not X.IsDisabled(nEnemysHerosInCastRange[1])
		then
			bot:Action_UseAbilityOnEntity(bt,nEnemysHerosInCastRange[1]);
			return;
	    end	
	
		if J.IsGoingOnSomeone(bot)
		then		
			if  J.IsValidHero(npcTarget)
				and not X.IsDisabled(npcTarget)
                and J.CanCastOnNonMagicImmune(npcTarget)		
				and GetUnitToUnitDistance(npcTarget, bot) < nCastRange
			then
			    bot:Action_UseAbilityOnEntity(bt,npcTarget);
				return;
			end
		end
	
	end
	
	
	local heavens = X.IsItemAvailable("item_heavens_halberd");
	if heavens ~= nil and heavens:IsFullyCastable() 
	then	
		local hNearbyEnemyHeroList = bot:GetNearbyHeroes( 700, true ,BOT_MODE_NONE);
		local targetHero = nil;
		local targetHeroDamage = 0		
		for _,nEnemy in pairs(hNearbyEnemyHeroList)
		do
		   if J.IsValid(nEnemy)
			  and not nEnemy:IsDisarmed()
			  and not J.IsDisabled(true, nEnemy)
			  and J.CanCastOnNonMagicImmune(nEnemy)
			  and (nEnemy:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT or nEnemy:GetAttackDamage() > 200)
		   then
			   local nEnemyDamage = nEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL);
			   if ( nEnemyDamage > targetHeroDamage )
			   then
					targetHeroDamage = nEnemyDamage;
					targetHero = nEnemy;
			   end
		   end
		end		
		if targetHero ~= nil
		then
			bot:Action_UseAbilityOnEntity(heavens, targetHero);
			return;
		end		
		
		if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
		then
			local npcTarget = bot:GetAttackTarget();
			if  J.IsRoshan(npcTarget) 
				and not J.IsDisabled(true, npcTarget)
				and not npcTarget:IsDisarmed()
			then
				bot:Action_UseAbilityOnEntity(heavens, npcTarget);
				return;
			end
		end
	end
	
	
	local hom = X.IsItemAvailable("item_hand_of_midas");
	if hom ~= nil and hom:IsFullyCastable() then
		local nCastRange = 700 ;     
		if #hNearbyEnemyHeroList >= 0 then nCastRange = 628 end
		local tableNearbyCreeps = bot:GetNearbyCreeps( nCastRange, true );
		local targetCreeps = nil;
		local targetCreepsLV = 0
		
		for _,creeps in pairs(tableNearbyCreeps)
		do
		   if J.IsValid(creeps)
			  and not creeps:IsMagicImmune()
			  and not creeps:IsAncientCreep()
		   then
			   if creeps:GetLevel() > targetCreepsLV
			   then
				   targetCreepsLV = creeps:GetLevel();
				   targetCreeps = creeps;
			   end
		   end

		end
		
		if targetCreeps ~= nil
		then
			bot:Action_UseAbilityOnEntity(hom, targetCreeps);
			return;
		end
		
	end
	
	
	local fst = X.IsItemAvailable("item_force_staff");
	if fst ~= nil and fst:IsFullyCastable() 
	then
		if J.IsStuck(bot)
		then
			bot:ActionImmediate_Chat("I'm using force staff while stuck.", true);
			bot:Action_UseAbilityOnEntity(fst, bot);
			return;
		end
		
		local hAllyList = bot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
		
		for _,ally in pairs(hAllyList) 
		do
			if ally ~= nil and ally:IsAlive()
				and not ally:IsIllusion()
				and X.CanCastOnTarget(ally)
			then
				if  not ally:IsInvisible()
					and ally:HasModifier("modifier_arc_warden_tempest_double")
					and ally:GetActiveMode() == BOT_MODE_RETREAT
					and ally:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),20)
					and ally:DistanceFromFountain() > 0 
				then		
					bot:Action_UseAbilityOnEntity(fst,ally);
					return
				end
				
				if J.IsGoingOnSomeone(ally)
				then
					local allyTarget = J.GetProperTarget(ally);
					if J.IsValidHero(allyTarget)
						and J.CanCastOnNonMagicImmune(allyTarget)
						and GetUnitToUnitDistance(allyTarget,ally) > ally:GetAttackRange() + 100
						and GetUnitToUnitDistance(allyTarget,ally) < ally:GetAttackRange() + 700
						and ally:IsFacingLocation(allyTarget:GetLocation(),20)
						and not allyTarget:IsFacingLocation(ally:GetLocation(),90)
						and J.GetEnemyCount(ally,1600) < 3
					then
						bot:Action_UseAbilityOnEntity(fst,ally);
						return;
					end
				end
			end		
			
		end
		
		for _,npcEnemy in pairs(hNearbyEnemyHeroList) 
		do
			if npcEnemy ~= nil and npcEnemy:IsAlive()
				and J.CanCastOnMagicImmune(npcEnemy)
				and npcEnemy:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),40)
				and GetUnitToLocationDistance(npcEnemy,GetAncient(GetTeam()):GetLocation()) < 1000 
			then
				bot:Action_UseAbilityOnEntity(fst,npcEnemy);
				return
			end		
		end
		
		for _,ally in pairs(hAllyList) 
		do
			if ally ~= nil and ally:IsAlive()
			   and X.CanCastOnTarget(ally)
			   and ally:GetUnitName() == "npc_dota_hero_crystal_maiden"
			   and (ally:IsInvisible() or ally:GetHealth()/ally:GetMaxHealth() > 0.8)
			   and (ally:IsChanneling() and not ally:HasModifier("modifier_teleporting") )
			then
				local enemyHeroesNearbyCM = ally:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
				for _,npcEnemy in pairs( enemyHeroesNearbyCM )
				do
				   if npcEnemy ~= nil and npcEnemy:IsAlive()
						and J.CanCastOnNonMagicImmune(npcEnemy)
						and GetUnitToUnitDistance(npcEnemy,ally) > 835
						and ally:IsFacingLocation(npcEnemy:GetLocation(),30)
				   then
						bot:Action_UseAbilityOnEntity(hurricanpike,ally);
						return;
				   end
				end
				   
			end		
		end
		
	end
	
			
	local hurricanpike = X.IsItemAvailable("item_hurricane_pike");
	if hurricanpike ~= nil and hurricanpike:IsFullyCastable()
	then
	
		local nCastRange = 800;
		local nNearRange = 400;
		
		if ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH )
		then
			for _,npcEnemy in pairs( hNearbyEnemyHeroList )
			do
				if ( GetUnitToUnitDistance( npcEnemy, bot ) < nNearRange and X.CanCastOnTarget(npcEnemy) )
				then
					bot:Action_UseAbilityOnEntity(hurricanpike,npcEnemy);
					return
				end
			end
			
			if bot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),20) and bot:DistanceFromFountain() > 0 
			then
				bot:Action_UseAbilityOnEntity(hurricanpike,bot);
				return;
			end
		end 
		
		if J.IsGoingOnSomeone(bot)
		then
			if J.IsValidHero(npcTarget)
				and J.CanCastOnNonMagicImmune(npcTarget)
				and GetUnitToUnitDistance(npcTarget,bot) > bot:GetAttackRange() + 100
				and GetUnitToUnitDistance(npcTarget,bot) < bot:GetAttackRange() + 700
				and bot:IsFacingLocation(npcTarget:GetLocation(),20)
				and not npcTarget:IsFacingLocation(bot:GetLocation(),90)
				and J.GetEnemyCount(bot,1600) < 3
			then
				bot:Action_UseAbilityOnEntity(hurricanpike,bot);
				return;
			end
		end
		
		if bot:GetUnitName() == "npc_dota_hero_drow_ranger"
			or bot:GetUnitName() == "npc_dota_hero_sniper"
		then
			for _,npcEnemy in pairs( hNearbyEnemyHeroList )
			do
				if npcEnemy ~= nil
				   and J.CanCastOnNonMagicImmune(npcEnemy)
				   and GetUnitToUnitDistance( npcEnemy, bot ) <= nNearRange
				   and X.CanCastOnTarget(npcEnemy)
				then
					bot:SetTarget(npcEnemy);
					bot:ActionQueue_UseAbilityOnEntity(hurricanpike,npcEnemy);
					return;
				end
		    end
		end
		
		local hAllyList = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
		for _,ally in pairs(hAllyList) 
		do
			if ally ~= nil and ally:IsAlive()
			   and X.CanCastOnTarget(ally)
			   and ally:GetUnitName() == "npc_dota_hero_crystal_maiden"
			   and (ally:IsInvisible() or ally:GetHealth()/ally:GetMaxHealth() > 0.8)
			   and (ally:IsChanneling() and not ally:HasModifier("modifier_teleporting") )
			then
				local enemyHeroesNearbyCM = ally:GetNearbyHeroes(1200,true,BOT_MODE_NONE)
				for _,npcEnemy in pairs( enemyHeroesNearbyCM )
				do
				   if npcEnemy ~= nil and npcEnemy:IsAlive()
						and J.CanCastOnNonMagicImmune(npcEnemy)
						and GetUnitToUnitDistance(npcEnemy,ally) > 835
						and ally:IsFacingLocation(npcEnemy:GetLocation(),30)
				   then
						bot:Action_UseAbilityOnEntity(hurricanpike,ally);
						return;
				   end
				end
				   
			end		
		end
	end	
		
	
	local arcane = X.IsItemAvailable("item_arcane_boots");
    if arcane ~= nil and arcane:IsFullyCastable()  
	then
		local tableNearbyAllys = bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
		if #tableNearbyAllys >= 2
			and bot:GetHealth() <= 100
		then
			bot:Action_UseAbility(arcane);
			return;
		end
		local needMPCount = 0;
		for _,ally in pairs(tableNearbyAllys)
		do
			if ally ~= nil and ally:IsAlive() and not ally:IsIllusion()
			   and ally:GetMaxMana()- ally:GetMana() > 180
			then
			    needMPCount = needMPCount + 1;
			end
			
			if needMPCount >= 2 
			then
				bot:Action_UseAbility(arcane);
				return;
			end
		end
	
		if bot:GetMana()/bot:GetMaxMana() < 0.55 
		then  
			bot:Action_UseAbility(arcane);
			return ;
		end
	end
	
	
	local mekansm = X.IsItemAvailable("item_mekansm");
    if mekansm ~= nil and mekansm:IsFullyCastable()
	then
		local tableNearbyAllys = J.GetAllyList(bot,1200);
		
		for _,ally in pairs(tableNearbyAllys) do
			if  ally ~= nil and ally:IsAlive()
				and ally:GetHealth()/ally:GetMaxHealth() < 0.35 
			    and hNearbyEnemyHeroList ~= nil 
				and #hNearbyEnemyHeroList > 0 
			then
				bot:Action_UseAbility(mekansm);
				return;
			end
		end
		
		local needHPCount = 0;
		for _,ally in pairs(tableNearbyAllys)
		do
			if ally ~= nil
			   and ally:GetMaxHealth()- ally:GetHealth() > 300
			then
			    needHPCount = needHPCount + 1;
	
				if needHPCount >= 2 and  ally:GetHealth()/ally:GetMaxHealth() < 0.38 
				then  --if firstAlly HP < 0.38,will bug
					bot:Action_UseAbility(mekansm);
					return;
				end
				
				if needHPCount >= 3 
				then
					bot:Action_UseAbility(mekansm);
					return;
				end
				
			end
		end
	
		if bot:GetHealth()/bot:GetMaxHealth() < 0.4 
		then  
			bot:Action_UseAbility(mekansm);
			return ;
		end
		
		local LaneCreeps = bot:GetNearbyLaneCreeps(1200,false);		
		if #LaneCreeps >= 8 then
			local nAOELocation = bot:FindAoELocation(false, false, bot:GetLocation(), 100, 1100 , 0, 200);
			if nAOELocation.count >= 8
			   and GetUnitToLocationDistance(bot,nAOELocation.targetloc) <= 200
			then
			    bot:Action_UseAbility(mekansm);
				return;
			end
		end	
		
	end
	
	
	local guardian = X.IsItemAvailable("item_guardian_greaves");
	if guardian ~= nil and guardian:IsFullyCastable() 
	then
		local hAllyList = J.GetAllyList(bot,1200);
		for _,ally in pairs(hAllyList) do
			if  ally ~= nil and ally:IsAlive()
				and ally:GetHealth()/ally:GetMaxHealth() < 0.45 
			    and hNearbyEnemyHeroList ~= nil 
				and #hNearbyEnemyHeroList > 0 
			then
				bot:Action_UseAbility(guardian);
				return;
			end
		end
		
		local needHPCount = 0;
		for _,ally in pairs(hAllyList)
		do
			if ally ~= nil
			   and ally:GetMaxHealth()- ally:GetHealth() > 400
			then
			    needHPCount = needHPCount + 1;
	
				if needHPCount >= 2 and  ally:GetHealth()/ally:GetMaxHealth() < 0.55 
				then
					bot:Action_UseAbility(guardian);
					return;
				end
				
				if needHPCount >= 3 
				then
					bot:Action_UseAbility(guardian);
					return;
				end
				
			end
		end
	
		if bot:GetHealth()/bot:GetMaxHealth() < 0.5
			or bot:IsSilenced()
			or bot:IsRooted()
			or bot:HasModifier("modifier_item_urn_damage") 
		    or bot:HasModifier("modifier_item_spirit_vessel_damage")
		then  
			bot:Action_UseAbility(guardian);
			return ;
		end
		
		local needMPCount = 0;
		for _,ally in pairs(hAllyList)
		do
			if ally ~= nil
			   and ally:GetMaxMana()- ally:GetMana() > 400
			then
			    needMPCount = needMPCount + 1;
			end
			
			if needMPCount >= 2 and bot:GetMana()/bot:GetMaxMana() < 0.2 
			then
				bot:Action_UseAbility(guardian);
				return;
			end
			
			if needMPCount >= 3 
			then
				bot:Action_UseAbility(guardian);
				return;
			end
			
		end
		
		local LaneCreeps = bot:GetNearbyLaneCreeps(1200,false);		
		if #LaneCreeps >= 9 then
			local nAOELocation = bot:FindAoELocation(false, false, bot:GetLocation(), 100, 1100 , 0, 200);
			if nAOELocation.count >= 9
			   and GetUnitToLocationDistance(bot,nAOELocation.targetloc) <= 200
			then
			    bot:Action_UseAbility(guardian);
				return;
			end
		end
	end
	
	
	local crimson = X.IsItemAvailable("item_crimson_guard");
    if crimson ~= nil and crimson:IsFullyCastable() 
		and not bot:HasModifier("modifier_item_crimson_guard_nostack")
	then
		local tableNearbyAllys = J.GetAllyList(bot,1200);
		
		for _,ally in pairs(tableNearbyAllys) do
			if  J.IsValid(ally) 
				and ally:GetHealth()/ally:GetMaxHealth() < 0.5
				and ally:WasRecentlyDamagedByAnyHero(2.0)
				and #hNearbyEnemyHeroList > 0 
			then
				bot:Action_UseAbility(crimson);
				return;
			end
		end
		
		local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local nNearbyEnemyTowers = bot:GetNearbyTowers(800,true); 
		if (#tableNearbyAllys >= 2 and #nNearbyEnemyHeroes >= 2)
			or (#tableNearbyAllys >= 2 and #nNearbyEnemyHeroes + #nNearbyEnemyTowers >= 2 and #nNearbyEnemyHeroes >=1)
		then
			for _,ally in pairs(tableNearbyAllys) 
			do
				if ally:WasRecentlyDamagedByAnyHero(2.0)
				then
					bot:Action_UseAbility(crimson);
					return;
				end
			end
		end	
	end
	
	
	local pipe = X.IsItemAvailable("item_pipe");
    if pipe ~= nil and pipe:IsFullyCastable()
	then
		local tableNearbyAllys = bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
		
		for _,ally in pairs(tableNearbyAllys) do
			if  J.IsValid(ally)
				and not ally:IsIllusion()
				and ally:GetHealth()/ally:GetMaxHealth() < 0.4
			    and hNearbyEnemyHeroList ~= nil 
				and #hNearbyEnemyHeroList > 0 
			then
				bot:Action_UseAbility(pipe);
				return;
			end
		end
		
		local nNearbyAlliedHeroes = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
		local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
		local nNearbyAlliedTowers = bot:GetNearbyTowers(1200,true); 
		if (#nNearbyAlliedHeroes >= 2 and #nNearbyEnemyHeroes >= 2)
			or (#nNearbyEnemyHeroes >= 2 and #nNearbyAlliedHeroes + #nNearbyAlliedTowers >= 2 and #nNearbyAlliedHeroes >=1)
		then
			bot:Action_UseAbility(pipe);
			return;
		end	
	end
	
	
	local msh = X.IsItemAvailable("item_moon_shard");
	if msh ~= nil and msh:IsFullyCastable() 
	   and ( bot:GetItemInSlot(6) ~= nil or bot:GetItemInSlot(7) ~= nil) 
	   and bot:GetNetworth() > 16666
	then
		if firstUseTime == 0 
		then
			firstUseTime = DotaTime();
		end
		
		if firstUseTime < DotaTime() - 6.1
		then
		
			if bot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY 
				and not bot:HasModifier("modifier_item_moon_shard_consumed")
			then
				firstUseTime = 0;	
				bot:Action_UseAbilityOnEntity(msh, bot);
				return;
			end
	
			local numPlayer = GetTeamPlayers(GetTeam());
			local targetMember = nil;
			local targetDamage = 0;
			for i = 1, #numPlayer
			do
			   local member = GetTeamMember(i);
			   if member ~= nil and member:IsAlive()		   
				  and member:GetAttackDamage() > targetDamage
				  and not member:HasModifier("modifier_item_moon_shard_consumed")
			   then
				   targetMember = member;
				   targetDamage = member:GetAttackDamage();
			   end
			end
			if targetMember ~= nil
			then
				firstUseTime = 0;	
				bot:Action_UseAbilityOnEntity(msh, targetMember);
				return;
			end
		end
	end
	
	
	local veil = X.IsItemAvailable("item_veil_of_discord");
    if veil ~= nil and veil:IsFullyCastable()
	then
		local nCastRange = 1000 +aetherRange;
		local hEnemyList= bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);		
		if hEnemyList ~= nil and #hEnemyList > 0 then
			local nAOELocation = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, 600 , 0, 0);
			if nAOELocation.count >= 2
			   and GetUnitToLocationDistance(bot,nAOELocation.targetloc) <= nCastRange
			then
			    bot:Action_UseAbilityOnLocation(veil,nAOELocation.targetloc);
				return ;
			end
		end
		
		hEnemyList = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);		
		if hEnemyList ~= nil and #hEnemyList > 0 
		then
			local nAOELocation = bot:FindAoELocation(true, true, bot:GetLocation(), 800, 600 , 0, 0);
			if nAOELocation.count >= 1  
			   and GetUnitToLocationDistance(bot,nAOELocation.targetloc) <= 1000
			then
			    bot:Action_UseAbilityOnLocation(veil,nAOELocation.targetloc);
				return ;
			end
		end
		
		local LaneCreeps=bot:GetNearbyLaneCreeps(1500,true);		
		if LaneCreeps ~= nil and #LaneCreeps >= 6 then
			local nAOELocation = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, 600 , 0, 0);
			if nAOELocation.count >= 8
			   and GetUnitToLocationDistance(bot,nAOELocation.targetloc) <= nCastRange
			then
			    bot:Action_UseAbilityOnLocation(veil,nAOELocation.targetloc);
				return ;
			end
		end
	end
	
	
	local manta = X.IsItemAvailable("item_manta");
	if manta ~= nil and manta:IsFullyCastable() 
	then
	    local nNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		local nNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local nNearbyEnemyTowers = bot:GetNearbyTowers(800,true);
		local nNearbyEnemyBarracks = bot:GetNearbyBarracks(600,true);
		local nNearbyAlliedCreeps = bot:GetNearbyLaneCreeps(1000,false);
		local nNearbyEnemyCreeps = bot:GetNearbyLaneCreeps(800,true);
		
		if J.IsPushing(bot)
		then
			if (#nNearbyEnemyTowers >= 1 or #nNearbyEnemyBarracks >= 1)
				and #nNearbyAlliedCreeps >= 1
			then
				J.PrintAndReport("幻影斧推进:",#nNearbyAlliedCreeps);
				bot:Action_UseAbility(manta);
				return;
			end
		end
		
		--幻影进攻
		
		
		if  bot:IsRooted()
			or ( bot:IsSilenced() and not bot:HasModifier("modifier_item_mask_of_madness_berserk") )
			or bot:HasModifier('modifier_item_solar_crest_armor_reduction') 
			or bot:HasModifier('modifier_item_medallion_of_courage_armor_reduction') 
			or bot:HasModifier('modifier_item_spirit_vessel_damage')
			or bot:HasModifier('modifier_dragonknight_breathefire_reduction')
		then
			J.PrintAndReport("幻影斧解状态:",bot:IsSilenced());
			bot:Action_UseAbility(manta);
			return;
		end
		
		if J.IsNotAttackProjectileIncoming(bot, 66) 
		   and not bot:IsMagicImmune()
		   and not bot:HasModifier("modifier_antimage_spell_shield")
		   and not bot:HasModifier("modifier_item_sphere_target")
		   and not bot:HasModifier("modifier_item_lotus_orb_active")
		then
			local tAbility = nil;
			if bot:GetUnitName() == "npc_dota_hero_antimage"
			then tAbility = bot:GetAbilityByName("antimage_counterspell") end				
			if tAbility == nil or not tAbility:IsFullyCastable()
			then
				J.PrintAndReport("幻影斧躲技能:",#nNearbyEnemyHeroes);
				bot:Action_UseAbility(manta);
				return;
			end
		end
		
		if J.IsRetreating(bot)
		   and nNearbyEnemyHeroes[1] ~= nil
		   and bot:DistanceFromFountain() > 600
		then
			J.PrintAndReport("幻影斧撤退:",#nNearbyEnemyHeroes);
			bot:Action_UseAbility(manta);
			return;
		end
		
		if #nNearbyEnemyCreeps >= 8
		then
			J.PrintAndReport("幻影斧发育:",#nNearbyEnemyCreeps);
			bot:Action_UseAbility(manta);
			return;
		end
	
		if bot:WasRecentlyDamagedByAnyHero(5.0)
		   and bot:GetHealth()/bot:GetMaxHealth() < 0.18
		   and bot:DistanceFromFountain() > 200
		then
			J.PrintAndReport("死前开幻影斧:",#nNearbyEnemyCreeps);
			bot:Action_UseAbility(manta);
			return;
		end
	
	end
	
	
	local bkb = X.IsItemAvailable("item_black_king_bar");
	if bkb ~= nil and bkb:IsFullyCastable()
	then
		local tableEnemyHeroesInView = bot:GetNearbyHeroes(1500,true,BOT_MODE_NONE);
		if  #tableEnemyHeroesInView > 0
			and not bot:IsMagicImmune()
			and not bot:IsInvulnerable()
			and not bot:HasModifier('modifier_item_lotus_orb_active') 
			and not bot:HasModifier('modifier_antimage_spell_shield') 
		then
			if bot:IsRooted()
			   or ( bot:IsSilenced() and bot:GetMana() > 80 and not bot:HasModifier("modifier_item_mask_of_madness_berserk") )
			   or J.IsNotAttackProjectileIncoming(bot, 400) 
			   or J.IsWillBeCastUnitTargetSpell(bot,1300) --可以额外加入秀一下的考虑
			   or J.IsWillBeCastPointSpell(bot,1500)
			then
				J.PrintAndReport("主动开BKB:",#tableEnemyHeroesInView);
				bot:Action_UseAbility(bkb);
				return;
			end			
		end	
	end
	
	
	local satanic = X.IsItemAvailable("item_satanic");
	if satanic ~= nil and satanic:IsFullyCastable() 
	then
		local nCastRange = bot:GetAttackRange() + 150;
		if  bot:GetHealth()/bot:GetMaxHealth() < 0.62 
			and #hNearbyEnemyHeroList > 0 
			and ( J.IsValidHero(npcTarget) and J.IsInRange(bot,npcTarget,nCastRange)
				  or ( J.IsValidHero(hNearbyEnemyHeroList[1]) and J.IsInRange(bot,hNearbyEnemyHeroList[1],nCastRange) ) )  
		then
			bot:SetTarget(npcTarget);
			bot:Action_UseAbility(satanic);
			return;
		end
	end	
	
	
	local mask = X.IsItemAvailable("item_mask_of_madness");
	if mask ~= nil and mask:IsFullyCastable() 
		and bot:GetUnitName() ~= "npc_dota_hero_drow_ranger"
	then
		local nAttackTarget = bot:GetAttackTarget();
		local nCastRange = bot:GetAttackRange() + 150;
		if  ( J.IsValid(nAttackTarget) or J.IsValidBuilding(nAttackTarget) )
			and J.CanBeAttacked(nAttackTarget)
			and J.IsInRange(bot,nAttackTarget,nCastRange)
			and ( not J.CanKillTarget(nAttackTarget,bot:GetAttackDamage() *2,DAMAGE_TYPE_PHYSICAL)
				  or J.GetAroundTargetEnemyUnitCount(bot, nCastRange ) >= 2 )		    
		then
			local nEnemyHeroInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
			if nAttackTarget:IsHero()
				or ( #nEnemyHeroInView == 0 and not bot:WasRecentlyDamagedByAnyHero(2.0))
			then
				if  ( #nEnemyHeroInView == 0 )
				     or ( bot:GetUnitName() ~= "npc_dota_hero_sniper" 
					      and bot:GetUnitName() ~= "npc_dota_hero_medusa" )
				then
					bot:SetTarget(nAttackTarget);
					bot:Action_UseAbility(mask);
					return;
				end
			end
		end
		
	end	
	
	
	local buckler = X.IsItemAvailable("item_buckler"); 
	if buckler ~= nil and buckler:IsFullyCastable() 
	then
	    if hNearbyEnemyHeroList[1] ~= nil
		then
			bot:Action_UseAbility(buckler);
		    return;	
		end
	end
	
	
	local db = X.IsItemAvailable("item_diffusal_blade");
	if db ~= nil and db:IsFullyCastable() 
	then
	
		local nCastRange = 650;
		if( mode == BOT_MODE_RETREAT )
		then
			for _,npcEnemy in pairs( hNearbyEnemyHeroList )
			do
				if  J.IsValid(npcEnemy)
					and J.IsMoving(npcEnemy)
					and J.IsInRange(npcEnemy, bot, nCastRange) 
					and bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
					and npcEnemy:GetCurrentMovementSpeed() > 200
					and J.CanCastOnNonMagicImmune(npcEnemy) 
					and not J.IsDisabled(true, npcEnemy) 					
				then
					bot:Action_UseAbilityOnEntity(db,npcEnemy);
					return;
				end
			end
		end	
	
		if J.IsGoingOnSomeone(bot)
		then
			if  J.IsValidHero(npcTarget)  
			    and J.IsMoving(npcTarget)
				and npcTarget:GetCurrentMovementSpeed() > 200
				and J.IsInRange(npcTarget, bot, nCastRange) 
				and J.CanCastOnNonMagicImmune(npcTarget) 
				and not J.IsDisabled(true, npcTarget) 				
			then
			    bot:Action_UseAbilityOnEntity(db,npcTarget);
				return
			end
		end
		
		if  J.IsValid(hNearbyEnemyHeroList[1])
			and GetUnitToUnitDistance(hNearbyEnemyHeroList[1], bot) <= nCastRange
			and J.CanCastOnNonMagicImmune(hNearbyEnemyHeroList[1]) 
			and not X.IsDisabled(hNearbyEnemyHeroList[1]) 
			and J.IsMoving(hNearbyEnemyHeroList[1])
			and hNearbyEnemyHeroList[1]:GetCurrentMovementSpeed() > 300
		then
			bot:Action_UseAbilityOnEntity(db,hNearbyEnemyHeroList[1]);
			return;
		end
		
	end	
	
	
	local uos = X.IsItemAvailable("item_urn_of_shadows"); 
	if uos ~= nil and uos:IsFullyCastable() and uos:GetCurrentCharges() > 0
	then
		local nCastRange = 980 +aetherRange;
	
		if J.IsGoingOnSomeone(bot)
		then	
			if J.IsValidHero(npcTarget) 
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			   and GetUnitToUnitDistance(bot, npcTarget) <= nCastRange
			   and not npcTarget:HasModifier("modifier_item_urn_damage") 
			   and not npcTarget:HasModifier("modifier_item_spirit_vessel_damage")
			   and (npcTarget:GetHealth()/npcTarget:GetMaxHealth() < 0.95 or GetUnitToUnitDistance(bot, npcTarget) <= 700)
			then
			    bot:Action_UseAbilityOnEntity(uos, npcTarget);
				return;
			end
		end
		
		if uos:GetCurrentCharges() >= 2 
			and	bot:GetActiveMode() ~= BOT_MODE_ROSHAN
		then
			local hAllyList = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
			local hNeedHealAlly = nil
			local nNeedHealAllyHealth = 99999
			for _,ally in pairs(hAllyList) do
				if J.IsValid(ally) 
				   and X.CanCastOnTarget(ally) 
				   and not ally:IsIllusion()
				   and ally:DistanceFromFountain() > 800
				   and not ally:HasModifier("modifier_item_spirit_vessel_heal")  
				   and not ally:HasModifier("modifier_item_urn_heal")
				   and not ally:HasModifier("modifier_fountain_aura")
				   and not ally:WasRecentlyDamagedByAnyHero(3.1)
				   and not ally:HasModifier("modifier_illusion") 
				   and ally:GetMaxHealth() - ally:GetHealth() > 400 
				   and #hNearbyEnemyHeroList == 0 				   				   			
				then
					if(ally:GetHealth() < nNeedHealAllyHealth )
					then
						hNeedHealAlly = ally
						nNeedHealAllyHealth = ally:GetHealth()
					end
				end
			end
		
			if(hNeedHealAlly ~= nil)
			then
				bot:Action_UseAbilityOnEntity(uos,hNeedHealAlly );
				return;
			end
		end
	end
	
	
	local sv = X.IsItemAvailable("item_spirit_vessel"); 
	if sv ~= nil and sv:IsFullyCastable() and sv:GetCurrentCharges() > 0
	then
		local nCastRange = 980 +aetherRange;
			
		if J.IsGoingOnSomeone(bot)
		then	
			if J.IsValidHero(npcTarget)
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			   and GetUnitToUnitDistance(bot, npcTarget) <= nCastRange
			   and not npcTarget:HasModifier("modifier_item_spirit_vessel_damage")
			   and not npcTarget:HasModifier("modifier_item_urn_damage")
			then
			    bot:Action_UseAbilityOnEntity(sv, npcTarget);
				return;
			end
		end
		
		if sv:GetCurrentCharges() >= 2
			and bot:GetActiveMode() ~= BOT_MODE_ROSHAN
		then
			local hAllyList = bot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
			local hNeedHealAlly=nil
			local nNeedHealAllyHealth = 99999
			for _,ally in pairs(hAllyList) do
				if J.IsValid(ally) 
				   and not ally:IsIllusion() 
				   and X.CanCastOnTarget(ally) 
				   and ally:DistanceFromFountain() > 800
				   and not ally:HasModifier("modifier_item_spirit_vessel_heal")
				   and not ally:HasModifier("modifier_item_urn_heal") 
				   and not ally:HasModifier("modifier_fountain_aura")
				   and ally:GetMaxHealth() - ally:GetHealth() > 500 
				   and #hNearbyEnemyHeroList == 0 
				   and not ally:WasRecentlyDamagedByAnyHero(3.1)		   				   
				then
					if(ally:GetHealth() < nNeedHealAllyHealth )
					then
						hNeedHealAlly = ally
						nNeedHealAllyHealth = ally:GetHealth()
					end
				end
			end
			
			if(hNeedHealAlly ~= nil)
			then
				bot:Action_UseAbilityOnEntity(sv,hNeedHealAlly );
				return;
			end
		end
	end
	
	
	local null = X.IsItemAvailable("item_nullifier");
	if null ~= nil and null:IsFullyCastable() 
	then
		if J.IsGoingOnSomeone(bot)
		then	
			if J.IsValidHero(npcTarget) 
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			   and J.IsInRange(npcTarget, bot, 800) 
			   and npcTarget:HasModifier("modifier_item_nullifier_mute") == false 
			then
			    bot:Action_UseAbilityOnEntity(null, npcTarget);
				return;
			end
		end
	end
	
	
	lasItemCheckTime = DotaTime();
	return;
	
end

function X.IsItemAvailable(item_name)
    
	local slot = bot:FindItemSlot(item_name)
	
	if slot >= 0 and slot <= 5 then
		return bot:GetItemInSlot(slot);
	end
	
    return nil;
end

function X.IsTargetedByEnemy(building)
	local heroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _,hero in pairs(heroes)
	do
		if ( GetUnitToUnitDistance(building, hero) <= hero:GetAttackRange() + 200 and hero:GetAttackTarget() == building ) then
			return true;
		end
	end
	return false;
end

local function UseGlyph()

	if GetGlyphCooldown( ) > 0  or  DotaTime() < 60 then
		return
	end	
	
	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3, 
		TOWER_BOT_3, 
		TOWER_BASE_1, 
		TOWER_BASE_2
	}
	
	for _,t in pairs(T1)
	do
		local tower = GetTower(GetTeam(), t);
		if  tower ~= nil and tower:GetHealth() > 0 and tower:GetHealth()/tower:GetMaxHealth() < 0.45 and tower:GetAttackTarget() ~=  nil
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end
	

	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}
	
	for _,b in pairs(MeleeBarrack)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil and barrack:GetHealth() > 0 and barrack:GetHealth()/barrack:GetMaxHealth() < 0.5 and X.IsTargetedByEnemy(barrack)
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end
	
	local Ancient = GetAncient(GetTeam())
	if Ancient ~= nil and Ancient:GetHealth() > 0 and Ancient:GetHealth()/Ancient:GetMaxHealth() < 0.5 and X.IsTargetedByEnemy(Ancient)
	then
		bot:ActionImmediate_Glyph( )
		return
	end

end

function X.IsAllyChanneling(bot)

	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil 
		   and member ~= bot 
		   and member:IsAlive()
		   and member:IsChanneling()
		then
			return true;
		end
	end

	return false;
end

if not bDeafaultItemHero
then

function ItemUsageThink()

end

end

if not bDeafaultAbilityHero
then

function AbilityUsageThink()

end

end


function BuybackUsageThink()
	
	UnImplementedItemUsage();
	
	BotBuild.SkillsComplement();

	BuybackUsageComplement();
	
	UseGlyph();

end

function CourierUsageThink()
	
	CourierUsageComplement();

end

function AbilityLevelUpThink()

	AbilityLevelUpComplement();

end
-- dota2jmz@163.com QQ:2462331592