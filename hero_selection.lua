---------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
---------------------------------------------------------------------------
------------------------------
--Hello,Friends:
--I'm the author of this file,but other file is based on BOT EXPERIMENT Credit:FURIOUSPUPPY.
--As you know,I'm come from china,and I'm studing English.
--My E-mail:dota2jmz@163.come,just have fun!  \o(∩_∩)o /
-------------------------------
local targetdata = require(GetScriptDirectory() .. "/AuxiliaryScript/RoleTargetsData")
local otherGameMod = require(GetScriptDirectory() .. "/AuxiliaryScript/OtherGameMod");

local X = {};
local bDebugMode = false
local sSelectHero = "npc_dota_hero_zuus";
local fLastSlectTime,fLastRand,nRand = 0,0,0 ;
local nDelayTime;
local nHumanCount = 0;
local sBanList = {}; 
local sSelectList = {};
local tSelectPoolList = {};
local tLaneAssignList = {};
local bInitLineUpDone = false;

local bUserMode = false;

local BotsInit = require( "game/botsinit" );

local Role = require( GetScriptDirectory()..'/FunLib/jmz_role')
local Chat = require( GetScriptDirectory()..'/FunLib/jmz_chat')
local HeroSet = nil

local tAllLineUpList = {	
				[1]={	"npc_dota_hero_viper",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_drow_ranger",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[2]={	"npc_dota_hero_viper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[3]={	"npc_dota_hero_viper",
						"npc_dota_hero_kunkka",
						"npc_dota_hero_arc_warden",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[4]={	"npc_dota_hero_viper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_sven",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[5]={	"npc_dota_hero_viper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_sven",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[6]={	"npc_dota_hero_viper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_skywrath_mage",
						"npc_dota_hero_necrolyte" },
				[7]={	"npc_dota_hero_viper",
						"npc_dota_hero_ogre_magi",
						"npc_dota_hero_antimage",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[8]={	"npc_dota_hero_viper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[9]={	"npc_dota_hero_viper",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_phantom_lancer",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
						
						
				[10]={	"npc_dota_hero_sniper",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_drow_ranger",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[11]={	"npc_dota_hero_sniper",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_sven",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[12]={	"npc_dota_hero_sniper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[13]={	"npc_dota_hero_sniper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_sven",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[14]={	"npc_dota_hero_sniper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[15]={	"npc_dota_hero_sniper",
						"npc_dota_hero_kunkka",
						"npc_dota_hero_arc_warden",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[16]={	"npc_dota_hero_sniper",
						"npc_dota_hero_kunkka",
						"npc_dota_hero_sven",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[17]={	"npc_dota_hero_sniper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_sven",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[18]={	"npc_dota_hero_sniper",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[19]={	"npc_dota_hero_sniper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_antimage",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[20]={	"npc_dota_hero_sniper",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_antimage",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
						
						
				[21]={	"npc_dota_hero_medusa",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_drow_ranger",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[22]={	"npc_dota_hero_medusa",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[23]={	"npc_dota_hero_medusa",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_sven",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },
				[24]={	"npc_dota_hero_medusa",
						"npc_dota_hero_kunkka",
						"npc_dota_hero_arc_warden",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[25]={	"npc_dota_hero_medusa",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_sven",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[26]={	"npc_dota_hero_medusa",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[27]={	"npc_dota_hero_medusa",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_antimage",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[28]={	"npc_dota_hero_medusa",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[29]={	"npc_dota_hero_medusa",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_drow_ranger",
						"npc_dota_hero_zuus",
						"npc_dota_hero_silencer" },
						
						
				[30]={	"npc_dota_hero_templar_assassin",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_drow_ranger",
						"npc_dota_hero_crystal_maiden",
						"npc_dota_hero_silencer" },
				[31]={	"npc_dota_hero_templar_assassin",
						"npc_dota_hero_kunkka",
						"npc_dota_hero_arc_warden",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[32]={	"npc_dota_hero_templar_assassin",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_warlock" },						
				[33]={	"npc_dota_hero_templar_assassin",
						"npc_dota_hero_skeleton_king",
						"npc_dota_hero_phantom_assassin",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				[34]={	"npc_dota_hero_templar_assassin",
						"npc_dota_hero_chaos_knight",
						"npc_dota_hero_antimage",
						"npc_dota_hero_jakiro",
						"npc_dota_hero_necrolyte" },
				
				[35]={	"npc_dota_hero_razor",
						"npc_dota_hero_bristleback",
						"npc_dota_hero_bloodseeker",
						"npc_dota_hero_zuus",
						"npc_dota_hero_silencer" },
				[36]={	"npc_dota_hero_razor",
						"npc_dota_hero_ogre_magi",
						"npc_dota_hero_phantom_lancer",
						"npc_dota_hero_lina",
						"npc_dota_hero_warlock" },
};

local sFirstList = {
	"npc_dota_hero_sniper",
	"npc_dota_hero_viper",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_medusa",	
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_razor",
}

local sSecondList = {
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_skeleton_king",	
	"npc_dota_hero_ogre_magi",
}

local sThirdList = {	
	"npc_dota_hero_sven",
	"npc_dota_hero_luna",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_huskar",
}

local sFourthList = {
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_zuus",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_lina",
	--'npc_dota_hero_pugna',
}

local sFifthList = {
	"npc_dota_hero_silencer",
	"npc_dota_hero_warlock",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_oracle",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_lich",
	--'npc_dota_hero_death_prophet',
}				


tSelectPoolList = {
	[1] = sFirstList,
	[2] = sSecondList,
	[3] = sThirdList,
	[4] = sFourthList,
	[5] = sFifthList,
}


sSelectList = {
	[1] = tSelectPoolList[1][RandomInt(1, #tSelectPoolList[1])],
	[2] = tSelectPoolList[2][RandomInt(1, #tSelectPoolList[2])],
	[3] = tSelectPoolList[3][RandomInt(1, #tSelectPoolList[3])],
	[4] = tSelectPoolList[4][RandomInt(1, #tSelectPoolList[4])],
	[5] = tSelectPoolList[5][RandomInt(1, #tSelectPoolList[5])],
}


if BotsInit["ABATiYanMa"] ~= nil
	and pcall(function(i) require( "game/赛季体验码" ) end,1)
then 
	bUserMode = true

	--设置全局语种环境
	Chat.SetRawLanguage(BotsInit["ABATiYanMa"]);
	
	--初始策略位置
	if GetTeam() ~= TEAM_DIRE then HeroSet = require( (Chat.GetLocalWord(1))..(Chat.GetLocalWord(5)) ) end
	if GetTeam() == TEAM_DIRE then HeroSet = require( (Chat.GetLocalWord(3))..(Chat.GetLocalWord(6)) ) end
	
	--修改策略位置
	if Chat.GetRawGameWord(HeroSet['QiYongKeChang']) == true 
	then
		Role["bHostSet"] = false;
		if GetTeam() ~= TEAM_DIRE then HeroSet = require( (Chat.GetLocalWord(2))..(Chat.GetLocalWord(5)) ) end
		if GetTeam() == TEAM_DIRE then HeroSet = require( (Chat.GetLocalWord(4))..(Chat.GetLocalWord(6)) ) end
	end
	
	--根据策略内容决定模式
	Role["nUserMode"] = Chat.GetRawGameWord(HeroSet['JiHuoCeLue']) == true and Role.GetUserLV(BotsInit["ABATiYanMa"]) or 0
	Role["sUserName"] = HeroSet['ZhanDuiJunShi'];
	
	if Chat.GetRawGameWord(HeroSet['ShuBuQi']) ~= false then Role["nUserMode"] = -1 end

	if Role["nUserMode"] <= 0 then bUserMode = false end
end

--For Random LineUp-------------
nRand = RandomInt(1,(#tAllLineUpList) *2.3 ); 
if nRand <= #tAllLineUpList and not bDebugMode
then 
	local sTempList = sSelectList;
	sSelectList = tAllLineUpList[nRand];
	print(tostring(GetTeam())..tostring(nRand/100));
	
	for i=1,5
	do
		if RandomInt(1,3) < 2
		then
			sSelectList[i] = sTempList[i];	
			print(tostring(GetTeam())..':'..sTempList[i]);
		end
	end
	
end



------------------------------------------------
---Finish Lineup---------------------------------
--初始阵容和英雄池
sSelectList = { sSelectList[5], sSelectList[4], sSelectList[3], sSelectList[2], sSelectList[1] };
tSelectPoolList = { tSelectPoolList[5], tSelectPoolList[4], tSelectPoolList[3], tSelectPoolList[2], tSelectPoolList[1] };
------------------------------------------------
------------------------------------------------

------For Random LaneAssig-------
function X.GetRandomChangeLane(tLane)

	if bDebugMode then return tLane end

	local temp;
	if RandomInt(1,9) < 4 then
		temp = tLane[1];
		tLane[1] = tLane[2];
		tLane[2] = temp;
	end 

	if RandomInt(1,9) < 4 then
		temp = tLane[3];
		tLane[3] = tLane[4];
		tLane[4] = temp;
	end 

	return tLane;
end

--初始分路
if GetTeam() == TEAM_RADIANT 
then
	local nRadiantLane = {
							[1] = LANE_BOT,
							[2] = LANE_TOP,
							[3] = LANE_TOP,
							[4] = LANE_BOT,
							[5] = LANE_MID,
						};

	tLaneAssignList = X.GetRandomChangeLane(nRadiantLane);
	
else
	local nDireLane = {
						[1] = LANE_TOP,
						[2] = LANE_BOT,
						[3] = LANE_BOT,
						[4] = LANE_TOP,
						[5] = LANE_MID,
					 }

	tLaneAssignList = X.GetRandomChangeLane(nDireLane);
end
				
--根据用户配置初始列表
--根据人类玩家数量初始化英雄池,英雄表,英雄分路
--tSelectPoolList, sSelectList, tLaneAssignList
function X.SetLaneUpInit()

	if bInitLineUpDone then return end
	
	if bUserMode 
	then 
		if Chat.GetRawGameWord(HeroSet['ZhenRongShengXiao']) == true
		then
			sSelectList = Chat.GetHeroSelectList(HeroSet['ZhenRong'])
		end
		
		if Chat.GetRawGameWord(HeroSet['FenLuShengXiao']) == true
		then
			tLaneAssignList = Chat.GetLaneAssignList(HeroSet['FenLu']) 
		end
	end

	local IDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(IDs) do
		if not IsPlayerBot(id) 
		then
			nHumanCount = nHumanCount + 1;
			tSelectPoolList = X.GetMoveTable(tSelectPoolList);
			sSelectList = X.GetMoveTable(sSelectList);
			tLaneAssignList = X.GetMoveTable(tLaneAssignList);
		end
	end

	
	bInitLineUpDone = true;
	
end


function X.GetMoveTable(nTable)

	local nLenth = #nTable;
	local temp = nTable[nLenth];
	
	table.remove(nTable, nLenth);
	table.insert(nTable, 1, temp);
	
	return nTable;
	
end


function X.IsHumanNotReady(team)
	
	if GameTime() > 40 then return false end

	local humanCount,readyCount = 0, 0;
	local IDs = GetTeamPlayers(team);
	for i,id in pairs(IDs)
	do
        if not IsPlayerBot(id)
		then
			humanCount = humanCount + 1;
			if GetSelectedHeroName(id) ~= ""
			then
				readyCount = readyCount + 1;
			end
		end
    end
	
	if( readyCount >= humanCount)
	then
		return false;
	end
	
	return true;
	
end


function X.GetNotRepeatHero(nTable)
	
	local sHero = nTable[1];
	local maxCount = #nTable ;
	local nRand = 0;
	local BeRepeated = false;
	
	for count = 1, maxCount
	do
		nRand = RandomInt(1, #nTable);
		sHero = nTable[nRand];
		BeRepeated = false;
		for id = 0, 20
		do
			if ( IsTeamPlayer(id) and GetSelectedHeroName(id) == sHero )
				or ( IsCMBannedHero(sHero) )
				or ( X.IsBanByChat(sHero) )
			then
				BeRepeated = true;
				table.remove(nTable,nRand);
				break;
			end
		end
		if not BeRepeated then break; end
	end		
	
	return sHero;		
end


function X.IsRepeatHero(sHero)

	for id = 0, 20
	do
		if ( IsTeamPlayer(id) and GetSelectedHeroName(id) == sHero )
			or ( IsCMBannedHero(sHero) )
			or ( X.IsBanByChat(sHero) )
		then
			return true;
		end
	end
	
	return false;

end


function X.SetChatHeroBan( sChatText )
	
	sBanList[#sBanList + 1] = string.lower(sChatText);
	
end


function X.IsBanByChat( sHero )

	for i = 1,#sBanList
	do
		if sBanList[i] ~= nil
		   and string.find(sHero, sBanList[i])
		then
			return true;
		end	
	end
	
	return false;
end


local sTianStarList =
{
"天罡星",
"天魁星",
"天机星",
"天闲星",
"天勇星",
"天雄星",
"天猛星",
"天英星",
"天贵星",
"天富星",
"天满星",
"天孤星",
"天伤星",
"天立星",
"天捷星",
"天暗星",
"天佑星",
"天空星",
"天速星",
"天异星",
"天杀星",
"天微星",
"天究星",
"天退星",
"天寿星",
"天剑星",
"天平星",
"天罪星",
"天损星",
"天牢星",
"天慧星",
"天暴星",
"天巧星",
--"天威星",
--"天哭星",
--"天败星",
}


local sDiStarsList = 
{
"地煞星",
"地魁星",
"地勇星",
"地杰星",
"地雄星",
"地英星",
"地奇星",
"地猛星",
"地文星",
"地正星",
"地阔星",
"地阖星",
"地强星",
"地暗星",
"地轴星",
"地会星",
"地佐星",
"地佑星",
"地灵星",
"地兽星",
"地微星",
"地慧星",
"地暴星",
"地然星",
"地猖星",
"地狂星",
"地飞星",
"地走星",
"地巧星",
"地明星",
"地进星",
"地退星",
"地满星",
"地遂星",
"地周星",
"地隐星",
"地异星",
"地理星",
"地俊星",
"地乐星",
"地捷星",
"地速星",
"地镇星",
"地嵇星",
"地魔星",
"地妖星",
"地幽星",
"地伏星",
"地僻星",
"地空星",
"地孤星",
"地全星",
"地短星",
"地角星",
"地平星",
"地察星",
"地数星",
"地阴星",
"地刑星",
"地壮星",
"地健星",
"地耗星",
--"地贼星",
--"地狗星",
--"地威星",
--"地劣星",
--"地劣星",
--"地损星",
--"地奴星",
--"地囚星",
--"地藏星",
}


function X.GetRandNameList(sStarList)
	
	local sNameList = {};
	
	for i=1,5
	do
	    local nRand = RandomInt(1, #sStarList);
		table.insert(sNameList,sStarList[nRand]);
		table.remove(sStarList,nRand);
	end
	
	return sNameList;
end

function X.SetTestSelection()

	sSelectList={ 
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_templar_assassin",
	}

	if GetTeam() == TEAM_DIRE then
	sSelectList={ 
	"npc_dota_hero_warlock",
	"npc_dota_hero_zuus",
	"npc_dota_hero_antimage",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_viper",
	}
	end
	
	local IDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(IDs) 
	do
		if IsPlayerBot(id) 
		then
			SelectHero(id,sSelectList[i]);
		end
	end

end


function Think()


----For Test-------------------
--	if bDebugMode then X.SetTestSelection() return end
-------------------------------

	if not bInitLineUpDone then X.SetLaneUpInit() return end

	if GetGameMode() == GAMEMODE_AP then
		if GetGameState() == GAME_STATE_HERO_SELECTION then
			InstallChatCallback(function ( tChat ) X.SetChatHeroBan( tChat.string ); end);
		end
		AllPickLogic();
	elseif GetGameMode() == GAMEMODE_CM or GetGameMode() == GAMEMODE_REVERSE_CM then
		otherGameMod.CaptainModeLogic();
		otherGameMod.AddToList();
		--elseif GetGameMode() == GAMEMODE_AR then
		--	otherGameMod.AllRandomLogic();
		--elseif GetGameMode() == GAMEMODE_MO then
		--	otherGameMod.MidOnlyLogic();
		--elseif GetGameMode() == GAMEMODE_1V1MID then
		--	otherGameMod.OneVsOneLogic();
		else
			if GetGameState() == GAME_STATE_HERO_SELECTION then
				InstallChatCallback(function ( tChat ) X.SetChatHeroBan( tChat.string ); end);
			end
			AllPickLogic();
	end
end

function AllPickLogic()	

	if GameTime() < 3.0
	   or fLastSlectTime > GameTime() - fLastRand
	   or X.IsHumanNotReady(GetTeam()) 
	   or X.IsHumanNotReady(GetOpposingTeam()) 
	then return end;
	
	if nDelayTime == nil then nDelayTime = GameTime(); fLastRand = RandomFloat(1.2,3.4); end
	if nDelayTime ~= nil and nDelayTime > GameTime() - fLastRand then return; end
	
	----------------------------------------------------------------------------------------
	------设置挑选延迟完毕------------------------------------------------------------------
	----------------------------------------------------------------------------------------
	
	--自定义挑选逻辑
	if bUserMode and Chat.GetRawGameWord(HeroSet['ZhenRongShengXiao']) == true
	then
		local IDs = GetTeamPlayers(GetTeam());
		for i,id in pairs(IDs) 
		do
			if IsPlayerBot(id) then
				SelectHero(id,sSelectList[i]);
			end
		end
		return;
	end
	
	--常规挑选逻辑
	local IDs = GetTeamPlayers(GetTeam());
	for i,id in pairs(IDs) 
	do
		if IsPlayerBot(id) 
		   and ( GetSelectedHeroName(id) == "" or GetSelectedHeroName(id) == nil )
		then
			--原版英雄选择策略
			--if not X.IsRepeatHero(sSelectList[i])
			--then
			--	sSelectHero = sSelectList[i];
			--else
			--	sSelectHero = X.GetNotRepeatHero(tSelectPoolList[i]);
			--end
			--新版英雄选择策略
			sSelectHero = targetdata.getApHero();

			fLastSlectTime = GameTime();
			fLastRand = RandomFloat(0.8,2.8);
			SelectHero(id,sSelectHero);
			break;
		end
	end
	
	
end


function GetBotNames()

	if bUserMode then return HeroSet['ZhanDuiMing'] end

	return targetdata.GetDota2Team();
	
end


local sBotVersion = Role.GetBotVersion()
if bUserMode or sBotVersion == 'Mid'
then

function UpdateLaneAssignments()

	if  GetGameMode() == GAMEMODE_AP or GetGameMode() == GAMEMODE_CM or GetGameMode() == GAMEMODE_TM or GetGameMode() == GAMEMODE_SD then
		return tLaneAssignList;
	elseif GetGameMode() == GAMEMODE_MO then
		return otherGameMod.MOLaneAssignment()
	elseif GetGameMode() == GAMEMODE_1V1MID then
		return otherGameMod.OneVsOneLaneAssignment()
	end
	
end

end

--dota2jmz@163.com QQ:2462331592.
