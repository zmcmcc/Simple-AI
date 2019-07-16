-- CAPTAIN'S MODE
local targetdata = require(GetScriptDirectory() .. "/AuxiliaryScript/RoleTargetsData")

local U = {};

local cmHeroList = {};
local UnImplementedHeroes = {};

local ListPickedHeroes = {};
local AllHeroesSelected = false;
local BanCycle = 1;
local NeededTime = 28;
local Min = 20; --最小思考时间
local Max = 27; --最大思考时间
local CMdebugMode = false;
local UnavailableHeroes = {
	"npc_dota_hero_techies"
}
local allBotHeroes = targetdata.OptionalHeroList()
local humanPick = {};

--队长模式的英雄选择逻辑
function U.CaptainModeLogic()
	--如果游戏状态不是英雄选择，跳出该函数
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
        return
    end
	--模拟思考时间，调试模式固定25
	-- NeededTime -> 思考时间
	if not CMdebugMode then
		NeededTime = RandomInt( Min, Max );
	elseif CMdebugMode then
		NeededTime = 25;
	end
	--如果英雄选择状态为选择队长，则执行选择队长函数，下列不做详细说明
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
		PickCaptain();
	--ban英雄阶段，同时满足思考时间和阶段列表内
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 18 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero();
		--重置思考时间
		NeededTime = 0 
	--选英雄阶段，同时满足思考时间和在最后一个选英雄阶段前（包含）
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero();	
		NeededTime = 0
	--分配英雄阶段
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectsHero();	
	end	
end
--选择队长函数
function PickCaptain()
	--如果没有人类玩家存在或者当前游戏时间大于-1
	if not IsHumanPlayerExist() or DotaTime() > -1 then
		--如果队长id不存在
		if GetCMCaptain() == -1 then
			--让第一个机器人当队长
			-- GetFirstBot选择队长函数
			local CaptBot = GetFirstBot();
			--如果队长不是空
			if CaptBot ~= nil then
				--设置团队队长为预选队长（CaptBot中保存的队长）
				print("CAPTAIN PID : "..CaptBot)
				SetCMCaptain(CaptBot)
			end
		end
	end
end
--检查团队中是否存在人类玩家
function IsHumanPlayerExist()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if not IsPlayerBot(id) then
			return true;
        end
    end
	return false;
end
--选择队长函数，固定为第一个机器人
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id;
			return BotId;
        end
    end
	return BotId;
end
--Ban英雄函数
function BansHero()
	--如果队长是人类玩家或者队长没有选择权限，跳出该函数
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end
	--要ban的英雄选择
	-- RandomHero随机英雄
	local BannedHero = targetdata.IntelligentBannedHeroListAnalysis(cmHeroList);
	--ban掉英雄
	CMBanHero(BannedHero);
	--已经ban掉的英雄数+1
	BanCycle = BanCycle + 1;
end
--选英雄函数
function PicksHero()
	--如果队长是人类玩家或者队长没有选择权限，跳出该函数
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end	
	--要选的英雄选择
	local PickedHero = GetNotRepeatHero(targetdata.IntelligentHeroListAnalysis(cmHeroList));
	cmHeroList[PickedHero] = GetTeam();
	CMPickHero(PickedHero);
end

function IsRandHero(Hero)
	for _,uh in pairs(rankBotList)
	do
		if Hero == uh then
			return true;
		end	
	end
	return false;
end

--添加到人类选择的英雄列表中
function U.AddToList()
	--如果队长是人类玩家
	if not IsPlayerBot(GetCMCaptain()) then
		for _,h in pairs(allBotHeroes)
		do
			if IsCMPickedHero(GetTeam(), h) and not alreadyInTable(h) then
				table.insert(humanPick, h)
			end
		end
	end
end
--检查被选中的英雄是否已经被人类选中
function alreadyInTable(hero_name)
	for _,h in pairs(humanPick)
	do
		if hero_name == h then
			return true
		end
	end
	return false
end
--检查随机英雄是否不适用于队长模式的函数
function IsUnavailableHero(name)
	for _,uh in pairs(UnavailableHeroes)
	do
		if name == uh then
			return true;
		end	
	end
	return false;
end
--随机获取列表中的英雄
function RandomHero(herolist)
	local hero = herolist[RandomInt(1, #herolist)];
	while ( IsUnavailableHero(hero) or IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) ) 
	do
        hero = herolist[RandomInt(1, #herolist)];
    end
	return hero;
end
--检查英雄是否不适应于CM
function IsUnImplementedHeroes()
	for _,unh in pairs(UnImplementedHeroes)
	do
		if name == unh then
			return true;
		end	
	end
	return false;
end	
--检查人类是否已经在队长模式中选择了英雄
function WasHumansDonePicking()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) 
	do
        if not IsPlayerBot(id) then
			if GetSelectedHeroName(id) == nil or GetSelectedHeroName(id) == "" then
				return false;
			end	
        end
    end
	return true;
end
--选择英雄
function SelectsHero()
	if not AllHeroesSelected and ( WasHumansDonePicking() or GetCMPhaseTimeRemaining() < 1 ) then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();
		
		for _,id in pairs(Players) 
		do
			local hero_name =  GetSelectedHeroName(id);
			if hero_name ~= nil and hero_name ~= "" then
				UpdateSelectedHeroes(hero_name)
				print(hero_name.." Removed")
			else
				table.insert(RestBotPlayers, id)
			end	
		end
		
		for i = 1, #RestBotPlayers
		do
			SelectHero(RestBotPlayers[i], ListPickedHeroes[i])
		end
		
		AllHeroesSelected = true;
	end
end
--让团队选出英雄
function GetTeamSelectedHeroes()
	for _,sName in pairs(allBotHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
	for _,sName in pairs(UnImplementedHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end	
	end
end
--更新团队选择英雄后，人类玩家选择他们想要的英雄
function UpdateSelectedHeroes(selected)
	for i=1, #ListPickedHeroes
	do
		if ListPickedHeroes[i] == selected then
			table.remove(ListPickedHeroes, i);
		end
	end
end

return U
