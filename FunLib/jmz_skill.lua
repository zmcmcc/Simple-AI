----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local X = {}


function X.GetTalentList(bot)
	local sTalentList = {};
	for i = 0, 23 
	do
		local hAbility = bot:GetAbilityInSlot(i);
		if hAbility ~= nil and hAbility:IsTalent() then
			table.insert(sTalentList, hAbility:GetName());
		end
	end
	return sTalentList;
end

function X.GetAbilityList(bot)
	local sAbilityList = {};
	for slot = 0,5
	do
		table.insert(sAbilityList, bot:GetAbilityInSlot(slot):GetName());
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

			--通用写法
	--local sSkillList = {}

	--for _,Ability in pairs(nAbilityBuildList)
	--do
	--	table.insert(sSkillList, sAbilityList[Ability])
	--end


	--if #sSkillList >= 10 then
	--	local tempskill = {}
	--	for i = 10 , #sSkillList
	--	do
	--		table.insert(tempskill, sSkillList[i])
	--	end
	--	sSkillList[10] = sTalentList[nTalentBuildList[1]]
	--	for i = 1 , #tempskill
	--	do
	--		sSkillList[10 + i] = tempskill[i]
	--	end
	--else
	--	table.insert(sSkillList, sTalentList[nTalentBuildList[1]])
	--end

	--if #sSkillList >= 15 then
	--	local tempskill = {}
	--	for i = 15 , #sSkillList
	--	do
	--		table.insert(tempskill, sSkillList[i])
	--	end
	--	sSkillList[15] = sTalentList[nTalentBuildList[2]]
	--	for i = 1 , #tempskill
	--	do
	--		sSkillList[15 + i] = tempskill[i]
	--	end
	--else
	--	table.insert(sSkillList, sTalentList[nTalentBuildList[2]])
	--end

	--if #sSkillList >= 20 then
	--	local tempskill = {}
	--	for i = 20 , #sSkillList
	--	do
	--		table.insert(tempskill, sSkillList[i])
	--	end
	--	sSkillList[20] = sTalentList[nTalentBuildList[3]]
	--	for i = 1 , #tempskill
	--	do
	--		sSkillList[20 + i] = tempskill[i]
	--	end
	--else
	--	table.insert(sSkillList, sTalentList[nTalentBuildList[3]])
	--end

	--table.insert(sSkillList, sTalentList[nTalentBuildList[4]])

	--限定写法（高性能）
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
					
	if GetBot():GetUnitName() == 'npc_dota_hero_invoker'
	then
		sSkillList = {
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
						[18] = sAbilityList[nAbilityBuildList[16]],
						[19] = sAbilityList[nAbilityBuildList[17]],
						[20] = sTalentList[nTalentBuildList[3]],
						[21] = sAbilityList[nAbilityBuildList[18]],
						[22] = sAbilityList[nAbilityBuildList[19]],
						[23] = sAbilityList[nAbilityBuildList[20]],
						[24] = sAbilityList[nAbilityBuildList[21]],
						[25] = sTalentList[nTalentBuildList[4]],
					}
	end
					 
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

function X.GetOutfitName(bot)

	return 'item_'..string.gsub(bot:GetUnitName(),"npc_dota_hero_","")..'_outfit'

end


return X
-- dota2jmz@163.com QQ:2462331592.
