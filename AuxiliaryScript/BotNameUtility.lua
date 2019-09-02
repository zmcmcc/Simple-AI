--电脑名称处理

local U = {}

local allowsHeroData = require(GetScriptDirectory() .. "/AuxiliaryScript/GetAllowHeroData")
local dota2team = allowsHeroData.team

function U.GetDota2Team()
	local bot_names = {};
	local rand = RandomInt(1, #dota2team); 
	if GetTeam() == TEAM_RADIANT then
		while rand%2 ~= 0 do
			rand = RandomInt(1, #dota2team); 
		end
	else
		while rand%2 ~= 1 do
			rand = RandomInt(1, #dota2team); 
		end
	end
	local team = dota2team[rand];
	for _,player in pairs(team.players) do
		if #bot_names < 5 then
			table.insert(bot_names, player);
		end
	end
	return bot_names;
end

return U