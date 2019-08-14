----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

local Site = {};

Site.nLaneList = {
					[1] = LANE_BOT,
					[2] = LANE_MID,
					[3] = LANE_TOP,
				 }


Site.nTowerList = {
					TOWER_TOP_1,
					TOWER_MID_1,
					TOWER_BOT_1,
					TOWER_TOP_2,
					TOWER_MID_2,
					TOWER_BOT_2,
					TOWER_TOP_3,
					TOWER_MID_3,
					TOWER_BOT_3,
				  }


Site.nRuneList = {
				RUNE_POWERUP_1, --上
				RUNE_POWERUP_2, --下
				RUNE_BOUNTY_1,	--天辉上
				RUNE_BOUNTY_2,	--夜魇下
				RUNE_BOUNTY_3,	--天辉下
				RUNE_BOUNTY_4,	--夜魇上
}

Site.nShopList = {
				SHOP_HOME, --家里商店
				SHOP_SIDE, --天辉下路商店
				SHOP_SIDE2,	--夜魇上路商店
				SHOP_SECRET,	--天辉上路神秘
				SHOP_SECRET2,	--夜魇下路神秘
}

Site["top_power_rune"] = Vector(-1767, 1233);
Site["bot_power_rune"] = Vector(2597, -2014);

Site["roshan"] = Vector(-2328, 1765);

Site["top_side_shop"] = Vector(-7236, 4444);
Site["bot_side_shop"] = Vector(7253, -4128);

Site["dire_ancient"] = Vector(5517, 4981);
Site["radiant_ancient"] = Vector(-5860, -5328);
Site["radiant_secret_shop"] = Vector(-4739, 1263);
Site["dire_secret_shop"] = Vector(4559, -1554);

Site["radiant_base"] = Vector(-7200, -6666);
Site["radiant_bot_tower_1"] = Vector(4896, -6140);
Site["radiant_bot_tower_2"] = Vector(-128, -6244);
Site["radiant_bot_tower_3"] = Vector(-3966, -6110);
Site["radiant_mid_tower_1"] = Vector(-1663, -1510);
Site["radiant_mid_tower_2"] = Vector(-3559, -2783);
Site["radiant_mid_tower_3"] = Vector(-4647, -4135);
Site["radiant_top_tower_1"] = Vector(-6202, 1831);
Site["radiant_top_tower_2"] = Vector(-6157, -860);
Site["radiant_top_tower_3"] = Vector(-6591, -3397);

Site["radiant_top_shrine"] = Vector(-4229, 1299);
Site["radiant_bot_shrine"] = Vector(622, -2555);
Site["radiant_bot_bounty_rune"] = Vector(1276, -4129);
Site["radiant_top_bounty_rune"] = Vector(-4351, 200);

Site["dire_base"] = Vector(7137, 6548);
Site["dire_bot_tower_1"] = Vector(6215, -1639);
Site["dire_bot_tower_2"] = Vector(6242, 400);
Site["dire_bot_tower_3"] = Vector(-6307, 3043);
Site["dire_mid_tower_1"] = Vector(1002, 330);
Site["dire_mid_tower_2"] = Vector(2477, 2114);
Site["dire_mid_tower_3"] = Vector(4197, 3756);
Site["dire_top_tower_1"] = Vector(-4714, 6016);
Site["dire_top_tower_2"] = Vector(0, 6020);
Site["dire_top_tower_3"] = Vector(3512, 5778);
Site["dire_top_shrine"] = Vector(-139, 2533);
Site["dire_bot_shrine"] = Vector(4173, -1613);
Site["dire_bot_bounty_rune"] = Vector(3471, 295);
Site["dire_top_bounty_rune"] = Vector(-2821, 4147);

Site["RandomIntRoute"] = nil;

Site["radiant_easy_and_medium"] = {
				Vector(3017, -4525),
				Vector(384, -4672),
				Vector(69 , -1851),
}

Site["radiant_hard"] = {
			Vector(-247, -3299),
			Vector(-1848, -4216),
			Vector(4800, -4288),
}

Site["dire_easy_and_medium"] = {
			Vector(-2464, 4816),
			Vector(-1864, 4431),
			Vector(-916 , 2236),
}

Site["dire_hard"] = {
			Vector(-132 , 3355),
			Vector(-4235, 3424),
			Vector(1346 , 3289),
}
	
local visionRad = 1600; --假眼视野范围
	
local RADIANT_T3TOPFALL = Vector(-6600.000000, -3072.000000, 0.000000); --高地防御眼
local RADIANT_T3MIDFALL = Vector(-4314.000000, -3887.000000, 0.000000);
local RADIANT_T3BOTFALL = Vector(-3586.000000, -6131.000000, 0.000000);

local RADIANT_T2TOPFALL = Vector(-4340.000000, -1015.000000, 0.000000);
local RADIANT_T2MIDFALL = Vector(-1023.000000, -4605.000000, 0.000000); --天辉下路野区高台
local RADIANT_T2BOTFALL = Vector(1010.000000, -5321.000000, 0.000000);

local RADIANT_T1TOPFALL = Vector(-5117.000000, 2068.000000, 0.00000);  --天辉上路野区高台
local RADIANT_T1MIDFALL = Vector(991.000000, -1574.000000, 0.000000);
local RADIANT_T1BOTFALL = Vector(5093.000000, -3722.000000, 0.000000);

local RADIANT_MANDATE1 = Vector(-1250.000000, -250.000000, 0.000000);   ---天辉中路河道眼        
local RADIANT_MANDATE2 = Vector(3860.000000, -2311.000000, 0.000000);   ---天辉三符眼

local RADIANT_AGGRESSIVETOP  = Vector(-1221.000000, 4833.000000, 0.000000);
local RADIANT_AGGRESSIVEMID1 = Vector(1015.000000, 4853.000000, 0.000000);
local RADIANT_AGGRESSIVEMID2 = Vector(5116.000000, -764.000000, 0.000000);
local RADIANT_AGGRESSIVEBOT  = Vector(5115.000000, -764.000000, 0.000000);

---DIRE WARDING SPOT
local DIRE_T3TOPFALL = Vector(3087.000000, 5690.000000, 0.000000);
local DIRE_T3MIDFALL = Vector(4024.000000, 3445.000000, 0.000000);
local DIRE_T3BOTFALL = Vector(6354.000000, 2606.000000, 0.000000);

local DIRE_T2TOPFALL = Vector(1022.000000, 4868.000000, 0.000000);    --夜魇上路野区高台
local DIRE_T2MIDFALL = Vector(1012.000000, 2247.000000, 0.000000);    --夜魇中路上野区入口
local DIRE_T2BOTFALL = Vector(5113.000000, 773.000000, 0.000000);

local DIRE_T1TOPFALL = Vector(-5697.000000, 3212.000000, 0.000000);
local DIRE_T1MIDFALL = Vector(1031.000000, -736.000000, 0.000000);
local DIRE_T1BOTFALL = Vector(5096.000000, -760.000000, 0.000000);

local DIRE_MANDATE1 =  Vector(3662.000000, -2064.000000, 0.000000);      --夜魇三符眼       
local DIRE_MANDATE2 =  Vector(-470.000000, 360.000000, 0.000000);        --夜魇中路河道眼       

local DIRE_AGGRESSIVETOP  = Vector(-4625.000000, 738.000000, 0.000000);
local DIRE_AGGRESSIVEMID1 = Vector(-4348.000000, -1014.000000, 0.000000);
local DIRE_AGGRESSIVEMID2 = Vector(-1030.000000, -4631.000000, 0.000000);
local DIRE_AGGRESSIVEBOT  = Vector(1826.000000, -4266.000000, 0.000000);


local WardSpotTowerFallRadiant = {
	RADIANT_T1TOPFALL,
	RADIANT_T1MIDFALL,
	RADIANT_T1BOTFALL,
	RADIANT_T2TOPFALL,
	RADIANT_T2MIDFALL,
	RADIANT_T2BOTFALL,
	RADIANT_T3TOPFALL,
	RADIANT_T3MIDFALL,
	RADIANT_T3BOTFALL
}	

local WardSpotTowerFallDire = {
	DIRE_T1TOPFALL,
	DIRE_T1MIDFALL,
	DIRE_T1BOTFALL,
	DIRE_T2TOPFALL,
	DIRE_T2MIDFALL,
	DIRE_T2BOTFALL,
	DIRE_T3TOPFALL,
	DIRE_T3MIDFALL,
	DIRE_T3BOTFALL
}

function Site.GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function Site.GetXUnitsTowardsLocation( hUnit, vLocation, nDistance)
    local direction = (vLocation - hUnit:GetLocation()):Normalized()
    return hUnit:GetLocation() + direction * nDistance
end

--固定强制眼位
function Site.GetMandatorySpot()
	local MandatorySpotRadiant = {
		RADIANT_MANDATE1,
		RADIANT_MANDATE2
	}

	local MandatorySpotDire = {
		DIRE_MANDATE1,
		DIRE_MANDATE2
	}
	if GetTeam() == TEAM_RADIANT then
		return MandatorySpotRadiant;
	else
		return MandatorySpotDire
	end	
end

--防御眼
function Site.GetWardSpotWhenTowerFall()
	local wardSpot = {};
	for i = 1, #Site.nTowerList
	do
		local t = GetTower(GetTeam(), Site.nTowerList[i]);
		if t == nil then
			if GetTeam() == TEAM_RADIANT then
				table.insert(wardSpot, WardSpotTowerFallRadiant[i]);
			else
				table.insert(wardSpot, WardSpotTowerFallDire[i]);
			end
		end
	end
	return wardSpot;
end

--进攻眼
function Site.GetAggressiveSpot()
	local AggressiveDire = {
		DIRE_AGGRESSIVETOP,
		DIRE_AGGRESSIVEMID1,
		DIRE_AGGRESSIVEMID2,
		DIRE_AGGRESSIVEBOT
	}

	local AggressiveRadiant = {
		RADIANT_AGGRESSIVETOP,
		RADIANT_AGGRESSIVEMID1,
		RADIANT_AGGRESSIVEMID2,
		RADIANT_AGGRESSIVEBOT
	}
	if GetTeam() == TEAM_RADIANT then
		return AggressiveRadiant;
	else
		return AggressiveDire
	end	
end


function Site.GetItemWard(bot)
	for i = 0,8 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == 'item_ward_observer' then
			return item;
		end
	end
	return nil;
end


function Site.GetAvailableSpot(bot)
	local temp = {};
	
	--先算必插眼位
	for _,s in pairs(Site.GetMandatorySpot()) do
		if not Site.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	
	--再算丢塔后的防御眼位
	for _,s in pairs(Site.GetWardSpotWhenTowerFall()) do
		if not Site.CloseToAvailableWard(s) then
			table.insert(temp, s);
		end
	end
	
	--8分钟后计算进攻眼位
	if DotaTime() > 8 *60 then
		for _,s in pairs(Site.GetAggressiveSpot()) do
			if GetUnitToLocationDistance(bot, s) <= 1200 and not Site.CloseToAvailableWard(s) then
				table.insert(temp, s);
			end
		end
	end
	
	return temp;
end


--位置是否已有眼
function Site.CloseToAvailableWard(wardLoc)
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
	for _,ward in pairs(WardList) do
		if Site.IsObserver(ward) and GetUnitToLocationDistance(ward, wardLoc) <= visionRad then
			return true;
		end
	end
	return false;
end


--获得可用眼位中最近的一个
function Site.GetClosestSpot(bot, spots)
	local cDist = 100000;
	local cTarget = nil;
	for _, spot in pairs(spots) do
		local dist = GetUnitToLocationDistance(bot, spot);
		if dist < cDist then
			cDist = dist;
			cTarget = spot;
		end
	end
	return cTarget, cDist;
end


function Site.IsObserver(wardUnit)
	return wardUnit:GetUnitName() == "npc_dota_observer_wards";
end

-----------*********************************----------------------------
-----------*********************************----------------------------
-----------*********************************----------------------------
-----------*********************************----------------------------
-----------*********************************----------------------------
-----------*********************************----------------------------
local CStackTime = {55,55,55,55,55,54,55,55,55,55,55,55,55,55,55,55,55,55}
local CStackLoc = {
	Vector(1854.000000, -4469.000000, 0.000000), 
	Vector(1249.000000, -2416.000000, 0.000000),
	Vector(3471.000000, -5841.000000, 0.000000),
	Vector(5153.000000, -3620.000000, 0.000000),
	Vector(-1846.000000, -2996.000000, 0.000000),
	Vector(-4961.000000, 559.000000, 0.000000),
	Vector(-3873.000000, -833.000000, 0.000000),
	Vector(-3146.000000, 702.000000, 0.000000),
	Vector(1141.000000, -3111.000000, 0.000000),
	Vector(660.000000, 2300.000000, 0.000000),
	Vector(3666.000000, 1836.000000, 0.000000),
	Vector(482.000000, 4723.000000, 0.000000),
	Vector(3173.000000, -861.000000, 0.000000),
	Vector(-3443.000000, 6098.000000, 0.000000),
	Vector(-4353.000000, 4842.000000, 0.000000),
	Vector(-1083.000000, 3385.000000, 0.000000),
	Vector(-922.000000, 4299.000000, 0.000000),
	Vector(4136.000000, -1753.000000, 0.000000)
}


function Site.IsVaildCreep(nUnit)

	return nUnit ~= nil
		   and not nUnit:IsNull()
		   and nUnit:IsAlive()
		   --and nUnit:CanBeSeen()
		   and nUnit:GetHealth() < 4000
		   and ( GetBot():GetLevel() > 9 or not nUnit:IsAncientCreep() )		   
		   
end


function Site.IsSpecialFarmer(bot)
	local botName = bot:GetUnitName();

	return     botName == "npc_dota_hero_nevermore"
			or botName == "npc_dota_hero_medusa"
			or botName == "npc_dota_hero_razor"
			or botName == "npc_dota_hero_luna"
			or botName == 'npc_dota_hero_sven'
			or botName == 'npc_dota_hero_antimage'
			or botName == 'npc_dota_hero_abaddon'
			or botName == 'npc_dota_hero_phantom_assassin'
			or botName == "npc_dota_hero_phantom_lancer"
			or botName == "npc_dota_hero_templar_assassin"
end


function Site.IsShouldFarmHero(bot)

	local botName = bot:GetUnitName();
	
	return botName == "npc_dota_hero_nevermore"
		or botName == "npc_dota_hero_drow_ranger"
		or botName == "npc_dota_hero_luna"
		or botName == 'npc_dota_hero_sven'
		or botName == 'npc_dota_hero_axe'
		or botName == 'npc_dota_hero_antimage'
		or botName == "npc_dota_hero_arc_warden"
		or botName == 'npc_dota_hero_omniknight'
		or botName == 'npc_dota_hero_vengefulspirit'
		or botName == "npc_dota_hero_bloodseeker"
		or botName == "npc_dota_hero_medusa"
		or botName == "npc_dota_hero_razor"
		or botName == 'npc_dota_hero_phantom_assassin'
		or botName == "npc_dota_hero_phantom_lancer"
		or botName == "npc_dota_hero_templar_assassin"
		
end


function Site.GetCampMoveToStack(id)
	return CStackLoc[id]
end


function Site.GetCampStackTime(camp)
	if camp.cattr.speed == "fast" then
		return 56;
	elseif camp.cattr.speed == "slow" then
		return 55;
	else
		return 56;
	end
end


function Site.IsEnemyCamp(camp)
	return camp.team ~= GetTeam();
end


function Site.IsAncientCamp(camp)
	return camp.type == "ancient";
end


function Site.IsSmallCamp(camp)
	return camp.type == "small";
end


function Site.IsMediumCamp(camp)
	return camp.type == "medium";
end


function Site.IsLargeCamp(camp)
	return camp.type == "large";
end


function Site.RefreshCamp(bot)
	local camps = GetNeutralSpawners();
	local AllCamps = {};
	local nSum = 0;
	local nCount = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) 
	do
		nSum = nSum + GetHeroLevel( id );
		nCount = nCount + 1;
	end 
	local nAverageLV = nSum/nCount; 
	
	
	for k,camp in pairs(camps) do
		if (nAverageLV < 6 or bot:GetAttackDamage() <= 66) then
			if not Site.IsEnemyCamp(camp) and not Site.IsLargeCamp(camp) and not Site.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		elseif nAverageLV < 9 then
			if not Site.IsEnemyCamp(camp) and not Site.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		elseif nAverageLV < 12 then
			if not Site.IsEnemyCamp(camp) 
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		else
			table.insert(AllCamps, {idx=k, cattr=camp});
		end
	end
	
	local nCamps = #AllCamps;
	return AllCamps, nCamps;
end


function Site.GetClosestNeutralSpwan(bot, AvailableCamp)
	local minDist = 15000;
	local pCamp = nil;
	for _,camp in pairs(AvailableCamp)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.cattr.location);
	   if Site.IsEnemyCamp(camp) then dist = dist * 1.66 end
	   
	   if Site.IsTheClosestOne(bot, dist, camp.cattr.location) 
	      and dist < minDist 
		  and ( bot:GetLevel() > 9 or not Site.IsAncientCamp(camp) )
	   then
			minDist = dist;
			pCamp = camp;
	   end
	end
	return pCamp
end


function Site.IsTheClosestOne(bot, bDis, loc)
	local dis = GetUnitToLocationDistance(bot, loc);
	local closest = bot;
	for k,v in pairs(GetTeamPlayers(GetTeam()))
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetActiveMode() == BOT_MODE_FARM then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist < dis then
				dis = dist;
				closest = member;
			end
		end
	end
	return closest == bot;
end

function Site.GetNearestCreep(hCreepList)
	
	if Site.IsVaildCreep(hCreepList[1])
	then
		return hCreepList[1];
	end
	
	return nil;
end

function Site.GetMaxHPCreep(hCreepList)
	
	local nHPMax  = 0;
	local hTarget = nil;
	for _,creep in pairs(hCreepList)
	do
		if not creep:IsNull()
		   and creep:HasModifier('modifier_item_medallion_of_courage_armor_reduction')
		then
			return creep;
		end
	
		if Site.IsVaildCreep(creep)
		   and creep:GetHealth() > nHPMax
		then
			nHPMax = creep:GetHealth();
			hTarget = creep;
		end
	end
	
	
	return hTarget;
end

function Site.GetMinHPCreep(hCreepList)
	
	local nHPMin = 4000;
	local hTarget = nil;
	for _,creep in pairs(hCreepList)
	do
		if not creep:IsNull()
		   and creep:HasModifier('modifier_item_medallion_of_courage_armor_reduction')
		then
			return creep;
		end
	
		if Site.IsVaildCreep(creep)
		   and creep:GetHealth() < nHPMin
		then
			nHPMin = creep:GetHealth();
			hTarget = creep;
		end
	end
	
	
	return hTarget;
end


function Site.FindFarmNeutralTarget(Creeps)
	local bot = GetBot();
	local botName = bot:GetUnitName();
	local hTarget = nil;
	
	if botName == "npc_dota_hero_templar_assassin"
	   or botName == "npc_dota_hero_sven"
	   or botName == "npc_dota_hero_drow_ranger"
	   or botName == "npc_dota_hero_phantom_lancer"
	   or ( botName == "npc_dota_hero_phantom_assassin" 
	        and Site.IsHaveItem(bot,"item_bfury") and bot:GetLevel() >= 15 )
	then
		hTarget = Site.GetNearestCreep(Creeps);
		if hTarget ~= nil then return hTarget end
	end
	
	if botName == "npc_dota_hero_viper"
	then
		local cAbility = bot:GetAbilityByName("viper_poison_attack");
		if cAbility ~= nil and cAbility:GetAutoCastState() == true
		then
			for _,creep in pairs(Creeps)
			do
				if  Site.IsVaildCreep(creep)
				    and not creep:HasModifier('modifier_viper_poison_attack_slow')
				then
					return creep;
				end
			end
		end	
	end
	
	if botName == 'npc_dota_hero_axe'
	   or botName == "npc_dota_hero_viper"
	   or botName == "npc_dota_hero_razor"
	   or botName == "npc_dota_hero_ogre_magi"
	   or ( botName == "npc_dota_hero_medusa"
			and bot:GetLevel() >= 8  )
	   or ( botName == "npc_dota_hero_luna"
			and bot:GetLevel() >= 8  )
	   or ( botName == "npc_dota_hero_nevermore" 
	        and bot:GetMana() > 120 and bot:GetLevel() >= 13 )
	   or ( botName == "npc_dota_hero_dragon_knight" 
	        and bot:GetAttackRange() > 330 )
	   or ( botName == "npc_dota_hero_sniper" 
	        and Site.IsHaveItem(bot,"item_maelstrom" ) )
	   or ( botName == "npc_dota_hero_phantom_assassin" 
	        and bot:GetLevel() >= 15  )
	   or ( botName == "npc_dota_hero_antimage" 
	        and Site.IsHaveItem(bot,"item_bfury" ) )
	then
		hTarget = Site.GetMaxHPCreep(Creeps);
		if hTarget ~= nil then return hTarget end		
	end

	hTarget = Site.GetMinHPCreep(Creeps);
	
	return hTarget;
end


function Site.GetFarmLaneTarget(Creeps,bStrongest)
	
	local bot = GetBot();
	local botName = bot:GetUnitName();
	local hTarget = nil;

	local nAllyCreeps = bot:GetNearbyLaneCreeps(1000,false);
	
	
	if botName ~= "npc_dota_hero_drow_ranger"
	   and botName ~= "npc_dota_hero_medusa"
	   and botName ~= "npc_dota_hero_razor"
	   and #nAllyCreeps > 0
	then
		
		hTarget = Site.GetNearestCreep(Creeps);
		if hTarget ~= nil
		   and botName ~= "npc_dota_hero_templar_assassin"
		   and botName ~= "npc_dota_hero_phantom_assassin" 
		then
			 return hTarget ;
		end
		
		for _,creep in pairs(Creeps)
		do
			if Site.IsVaildCreep(creep)
			   and ( creep:HasModifier("modifier_templar_assassin_meld_armor")
					 or creep:HasModifier("modifier_item_medallion_of_courage_armor_reduction")
					 or creep:HasModifier("modifier_item_solar_crest_armor_reduction") )
			then
				hTarget = creep;
				break;
			end
		end
		
		return hTarget;
	end
	
	
	if not bStrongest
	   and botName == "npc_dota_hero_drow_ranger"
	   and bot:GetLevel() >= 6
	then
		bStrongest = true;
	end	
	
	
	if bStrongest 
	   and botName ~= "npc_dota_hero_medusa"
	then
		hTarget = Site.GetMaxHPCreep(Creeps);
		if hTarget ~= nil then return hTarget end	
	end

	
	hTarget = Site.GetMinHPCreep(Creeps);
	
	return hTarget;
	
end


function Site.IsNotForbidFarmMode(mode)

	return	mode ~= BOT_MODE_RUNE
		and mode ~= BOT_MODE_ATTACK
		and mode ~= BOT_MODE_SECRET_SHOP
		and mode ~= BOT_MODE_SIDE_SHOP
		and mode ~= BOT_MODE_DEFEND_ALLY
		and mode ~= BOT_MODE_EVASIVE_MANEUVERS

end


local maskGetGold = 0;
local maskGet = false;
function Site.IsModeSuitableToFarm(bot)
	
	local mode     = bot:GetActiveMode();
	local botLevel = bot:GetLevel();
	local botName  = bot:GetUnitName();	
	
	if not maskGet
		and Site.IsHaveItem(bot,"item_mask_of_madness")
	then
		maskGet = true;
		maskGetGold = bot:GetNetWorth();
	end	
	
	if  botLevel < 9
	    and ( mode == BOT_MODE_PUSH_TOWER_TOP
		or mode == BOT_MODE_PUSH_TOWER_MID
		or mode == BOT_MODE_PUSH_TOWER_BOT 
		or mode == BOT_MODE_LANING)
	then
		local enemyAncient = GetAncient(GetOpposingTeam());
		if GetUnitToUnitDistance(bot,enemyAncient) > 6000  
		then
			return false;
		end
	end
	
	if Site.IsMaskFarmTime(bot,mode)
		and Site.IsNotForbidFarmMode(mode)
	then
		return true;
	end

	if Site.IsSpecialFarmer(bot)
		and botLevel > 5
		and botLevel < 20
		and Site.IsNotForbidFarmMode(mode)
		and mode ~= BOT_MODE_ROSHAN
		and mode ~= BOT_MODE_TEAM_ROAM
		and mode ~= BOT_MODE_LANING
		and mode ~= BOT_MODE_WARD
	then
		return true;
	end
	
	if botName == "npc_dota_hero_drow_ranger"
		and botLevel >= 10
		and botLevel <= 20
		and Site.IsNotForbidFarmMode(mode)
		and mode ~= BOT_MODE_TEAM_ROAM
		and mode ~= BOT_MODE_ROSHAN
		and mode ~= BOT_MODE_LANING
		and mode ~= BOT_MODE_WARD
	then
		return true;
	end
	
	if Site.IsNotForbidFarmMode(mode)
	   and mode ~= BOT_MODE_WARD
	   and mode ~= BOT_MODE_LANING
	   and mode ~= BOT_MODE_DEFEND_TOWER_TOP
	   and mode ~= BOT_MODE_DEFEND_TOWER_MID
	   and mode ~= BOT_MODE_DEFEND_TOWER_BOT
	   and mode ~= BOT_MODE_ASSEMBLE
	   and mode ~= BOT_MODE_TEAM_ROAM
	   and mode ~= BOT_MODE_ROSHAN
	   and botLevel >= 6
	then
		return true;
	end
		
	return false;
end


function Site.IsMaskFarmTime(bot,mode)
	
	if maskGet 
	   and bot:GetNetWorth() < maskGetGold + 1800 
	then
		return true;
	end	

	return false;
end


function Site.IsTimeToFarm(bot)

	if DotaTime() < 8 *60
	then
		return false;
	end
	
	local botName =  bot:GetUnitName();
		
	if botName == "npc_dota_hero_bloodseeker"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 20
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_abyssal_blade")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end	
	
	if botName == "npc_dota_hero_viper"
		and bot:GetLevel() >= 10
		and not Site.IsHaveItem(bot,"item_mjollnir")
	then
		local botKills = GetHeroKills(bot:GetPlayerID());
		local botDeaths = GetHeroDeaths(bot:GetPlayerID());
		local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if botKills - 4 <=  botDeaths
			and botDeaths > 2
			and #allies < 3
		then
			return true;
		end
		
		if bot:GetMana() > 650
			and bot:GetCurrentVisionRange() < 1000
			and #allies < 2
		then
			return true;
		end	
	end
	
	if botName == "npc_dota_hero_sniper"
		and bot:GetLevel() >= 10
		and not Site.IsHaveItem(bot,"item_monkey_king_bar")
	then
		local botKills = GetHeroKills(bot:GetPlayerID());
		local botDeaths = GetHeroDeaths(bot:GetPlayerID());
		local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if botKills - 3 <=  botDeaths
			and botDeaths > 2
			and #allies < 3
		then
			return true;
		end
		
	end
	
	if botName == "npc_dota_hero_dragon_knight"
	   and not Site.IsHaveItem(bot,"item_assault")
	then	
		local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if bot:GetAttackRange() > 300
			and #allies < 3
		then 
			return true;
		end
		
		if bot:GetMana() > 450
			and bot:GetCurrentVisionRange() < 1000
			and #allies < 2
		then
			return true;
		end
	end	
	
	if botName == "npc_dota_hero_skeleton_king"
	   or botName == "npc_dota_hero_kunkka"
	   or botName == "npc_dota_hero_chaos_knight"
	   or botName == "npc_dota_hero_bristleback"
	   or botName == "npc_dota_hero_ogre_magi"
	then
		local botKills = GetHeroKills(bot:GetPlayerID());
		local botDeaths = GetHeroDeaths(bot:GetPlayerID());
		local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if botKills - 3 >=  botDeaths
		   and botDeaths <= 3
		then
			return false;
		end
	
		if bot:GetLevel() > 12
			and #allies < 3
			and bot:GetNetWorth() < 12222
		then 
			return true;
		end
		
		if bot:GetLevel() > 20
		   and #allies < 2
		   and bot:GetNetWorth() < 21111
		then 
			return true;
		end
	end	
	
	if botName == "npc_dota_hero_antimage"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_satanic")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end
	
	if botName == "npc_dota_hero_luna"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_hurricane_pike")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end
	
	if botName == "npc_dota_hero_templar_assassin"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_hurricane_pike")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 3
			then
				return true;
			end
		end
		
		if not Site.IsHaveItem(bot,"item_satanic") 
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end	

	end
	
	if botName == 'npc_dota_hero_sven'
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
				
		if not Site.IsHaveItem(bot,"item_satanic")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 3
			then
				return true;
			end
		end
		
		if not Site.IsHaveItem(bot,"item_bloodthorn") 
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end			
	end
	
	if botName == "npc_dota_hero_phantom_lancer"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_skadi")
		then
			return true;
		end
				
		if not Site.IsHaveItem(bot,"item_sphere")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 3
			then
				return true;
			end
		end
		
		if not Site.IsHaveItem(bot,"item_heart") 
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end			
	end
	
	if botName == "npc_dota_hero_phantom_assassin"
	then
		if DotaTime() > 9 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_solar_crest")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 3
			then
				return true;
			end
		end
		
		if not Site.IsHaveItem(bot,"item_satanic") 
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end
	
	if botName == "npc_dota_hero_medusa"
	then
		if DotaTime() > 10 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_satanic")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end
	
	if botName == "npc_dota_hero_razor"
	then
		if DotaTime() > 7 *60
		   and bot:GetLevel() < 25
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_black_king_bar")
		then
			return true;
		end
		
		if not Site.IsHaveItem(bot,"item_satanic")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
	end
	
	if botName == "npc_dota_hero_nevermore"
	then
		if DotaTime() > 10 *60
			and bot:GetLevel() < 25
		then
			return true;
		end
	
		if not Site.IsHaveItem(bot,"item_skadi")
		then
			return true;
		end
		
		
		if not Site.IsHaveItem(bot,"item_sphere")
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end		
		
	end
	
	if botName == "npc_dota_hero_drow_ranger"
	then
		if bot:GetLevel() > 5
		   and bot:GetLevel() < 25
		then
			return true;
		end
		
		if Site.IsHaveItem(bot,"item_mask_of_madness")
			and bot:GetNetWorth() < 7000
		then
			return true;
		end
	
		if Site.IsHaveItem(bot,"item_blade_of_alacrity")
			and not Site.IsHaveItem(bot,"item_ultimate_scepter")
		then
			return true;
		end
		
		if  Site.IsHaveItem(bot,"item_shadow_amulet")
			and not Site.IsHaveItem(bot,"item_invis_sword")
			and bot:GetGold() > 400
		then
			return true;
		end
		
		if  Site.IsHaveItem(bot,"item_yasha")
			and not Site.IsHaveItem(bot,"item_manta")
			and bot:GetGold() > 1000
		then
			return true;
		end
		
		if Site.IsHaveItem(bot,"item_ultimate_scepter")
		   and bot:GetNetWorth() < 21111
		then
			local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
			if #allies < 2
			then
				return true;
			end
		end
		
	end

	if botName == "npc_dota_hero_arc_warden"
	then
		if  Site.IsHaveItem(bot,"item_gloves")
			and not Site.IsHaveItem(bot,"item_hand_of_midas")
			and bot:GetGold() > 1300
		then
			return true;
		end
		
		if  Site.IsHaveItem(bot,"item_yasha")
			and not Site.IsHaveItem(bot,"item_manta")
			and bot:GetGold() > 1000
		then
			return true;
		end
		
		local allies = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if  Site.IsHaveItem(bot,"item_maelstrom")
			and #allies < 2
		then 
			return true;
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
		or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
		or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	then
		local enemyAncient = GetAncient(GetOpposingTeam());
		local allies       = bot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
		local enemyAncientDistance = GetUnitToUnitDistance(bot,enemyAncient);
		if  enemyAncientDistance < 2800
		    and enemyAncientDistance > 1000
			and bot:GetActiveModeDesire() < BOT_MODE_DESIRE_HIGH
			and #allies < 2
		then
			return  true;
		end
		
		if Site.IsShouldFarmHero(bot)
		then
			if  bot:GetActiveModeDesire() < BOT_MODE_DESIRE_MODERATE 
				and enemyAncientDistance > 1000
				and enemyAncientDistance < 5800
				and #allies < 2
			then
				return  true;
			end
		end
	
	end
	
	
	return false;
end

--根据地点来刷新阵营
function Site.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp)
	if preferedCamp ~= nil then
		for i = 1, #AvailableCamp
		do
			if AvailableCamp[i].cattr.location == preferedCamp.cattr.location or GetUnitToLocationDistance(bot,  AvailableCamp[i].cattr.location) < 500 then
				table.remove(AvailableCamp, i);
				--print("Updating available camp : "..tostring(#AvailableCamp))
				--preferedCamp = nil;	
				return AvailableCamp, nil;
			end
		end
	end
	return AvailableCamp, nil;
end

--根据生物来刷新阵营
local lastCreep = nil;
function Site.UpdateCommonCamp(creep, AvailableCamp)
	if lastCreep ~= creep
	then
		lastCreep = creep;
		for i = 1, #AvailableCamp
		do
			if GetUnitToLocationDistance(creep,AvailableCamp[i].cattr.location) < 500 then
				table.remove(AvailableCamp, i);
				return AvailableCamp;
			end
		end
	end
	return AvailableCamp;
end


function Site.IsHaveItem(bot,item_name)

    local slot = bot:FindItemSlot(item_name);
	
	if slot < 0 then return false end
	
	if slot >= 0 and slot <= 8 then
		return true;
	end
	
    return false;
end

return Site;