
if GetTeam() == TEAM_DIRE then return end

local npcBot = GetBot();
local sBotName = npcBot:GetUnitName();

if sBotName ~= "npc_dota_hero_viper"
then
	return;
end

local fileName = 'bot_generic'
local nDebugFlag = 999
