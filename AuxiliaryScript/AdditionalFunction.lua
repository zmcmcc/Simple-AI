--额外功能函数

--初始化
local bot = GetBot();

local A = {}

--载入库
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')


--尝试转移塔仇恨
function A.Movetowerhate()

	if bot:WasRecentlyDamagedByTower(1) then

		local nNearHero = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE);
		local nNearCreep = bot:GetNearbyCreeps(800, false);

		if nNearCreep ~= nil then
			for _,allyTarget in pairs(nNearCreep)
			do
				if bot:IsFacingLocation(allyTarget:GetLocation(),30) then
					bot:Action_AttackUnit(allyTarget, true);
					bot:Action_ClearActions(false);
				end
			end
		end

		if nNearHero ~= nil then
			for _,allyTarget in pairs(nNearHero)
			do
				if bot:IsFacingLocation(allyTarget:GetLocation(),30) then
					bot:Action_AttackUnit(allyTarget, true);
					bot:Action_ClearActions(false);
				end
			end
		end

    end

end
--人类发出的信号
function A.IsPingedByHumanPlayer(bot)
	local TeamPlayers = GetTeamPlayers(GetTeam());
	for i,id in pairs(TeamPlayers)
	do
		if not IsPlayerBot(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and GetUnitToUnitDistance(bot, member) <= 1000 then
				local ping = member:GetMostRecentPing();
				local Wslot = member:FindItemSlot('item_ward_observer');
				if GetUnitToLocationDistance(bot, ping.location) <= 600 and 
				   GameTime() - ping.time < 5 and 
				   Wslot == -1
				then
					return true, member;
				end	
			end
		end
	end
	return false, nil;
end

return A
