----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local X = {}


function X.GetTalentList(npcBot)
	local sTalentList = {};
	for i = 0, 23 
	do
		local hAbility = npcBot:GetAbilityInSlot(i);
		if hAbility ~= nil and hAbility:IsTalent() then
			table.insert(sTalentList, hAbility:GetName());
		end
	end
	return sTalentList;
end

function X.GetAbilityList(npcBot)
	local sAbilityList = {};
	for slot = 0,5
	do
		table.insert(sAbilityList, npcBot:GetAbilityInSlot(slot):GetName());
	end
	return sAbilityList;
end


function X.GetRandomBuild(tBuildList)
	return tBuildList[RandomInt(1,#tBuildList)]
end	


function X.GetTalentBuild(tTalentTreeList)

	local nTalentBuildList = { 
							[1] = (tTalentTreeList['t10'][1] == 0 and 1 or 2),
							[2] = (tTalentTreeList['t15'][1] == 0 and 3 or 4),
							[3] = (tTalentTreeList['t20'][1] == 0 and 5 or 6),
							[4] = (tTalentTreeList['t25'][1] == 0 and 7 or 8),
						  }
	
	return nTalentBuildList
end


function X.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

	local sSkillList = {
						[1] = sAbilityList[nAbilityBuildList[1]],
						[2] = sAbilityList[nAbilityBuildList[2]],
						[3] = sAbilityList[nAbilityBuildList[3]],
						[4] = sAbilityList[nAbilityBuildList[4]],
						[5] = sAbilityList[nAbilityBuildList[5]],
						[6] = sAbilityList[nAbilityBuildList[6]],
						[7] = sAbilityList[nAbilityBuildList[7]],
						[8] = sAbilityList[nAbilityBuildList[8]],
						[9] = sAbilityList[nAbilityBuildList[9]],
						[10] = sTalentList[nTalentBuildList[1]],
						[11] = sAbilityList[nAbilityBuildList[10]],
						[12] = sAbilityList[nAbilityBuildList[11]],
						[13] = sAbilityList[nAbilityBuildList[12]],
						[14] = sAbilityList[nAbilityBuildList[13]],
						[15] = sTalentList[nTalentBuildList[2]],
						[16] = sAbilityList[nAbilityBuildList[14]],
						[17] = sAbilityList[nAbilityBuildList[15]],
						[18] = sTalentList[nTalentBuildList[3]],
						[19] = sTalentList[nTalentBuildList[4]],
					}
					 
	return sSkillList

end


function X.IsHeroInEnemyTeam(sHero)

	for _,id in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do
		if GetSelectedHeroName(id) == sHero
		then
			return true;
		end
	end

	return false;
	
end

function X.GetOutfitName(npcBot)

	return 'item_'..string.gsub(npcBot:GetUnitName(),"npc_dota_hero_","")..'_outfit'

end


return X
-- dota2jmz@163.com QQ:2462331592
