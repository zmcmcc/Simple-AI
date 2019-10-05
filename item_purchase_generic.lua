----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local Item = require( GetScriptDirectory()..'/FunLib/jmz_item')
local Role = require( GetScriptDirectory()..'/FunLib/jmz_role')

local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion()
then
	return;
end

local BotBuild = require(GetScriptDirectory() .. "/BotLib/" .. string.gsub(GetBot():GetUnitName(), "npc_dota_", ""));

if BotBuild == nil then return; end

--clone item build to bot.itemTobBuy in reverse order 
bot.itemToBuy = {};   
bot.currentItemToBuy = nil;  
bot.currentComponentToBuy = nil;   
bot.currListItemToBuy = {};         
bot.SecretShop = false;             
bot.SideShop = false;                

local sPurchaseList = BotBuild['sBuyList'];
local sItemSellList = BotBuild['sSellList'];

--Reverse item order
for i=1,#sPurchaseList
do
	bot.itemToBuy[i] = sPurchaseList[#sPurchaseList - i +1];
end


local courier = nil;
local sell_time = -90;
local check_time = -90;


local lastItemToBuy = nil;
local CanPurchaseFromSecret = false;
local CanPurchaseFromSide = false;
local itemCost = 0;
local courier = nil;
local t3AlreadyDamaged = false;
local t3Check = -90;

--General item BotBuild logis
local function GeneralPurchase()

	--Cache all needed item properties when the last item to buy not equal to current item component to buy
	if lastItemToBuy ~= bot.currentComponentToBuy then
		lastItemToBuy = bot.currentComponentToBuy;
		bot:SetNextItemPurchaseValue( GetItemCost( bot.currentComponentToBuy ) );
		CanPurchaseFromSecret = IsItemPurchasedFromSecretShop(bot.currentComponentToBuy);
		CanPurchaseFromSide   = IsItemPurchasedFromSideShop(bot.currentComponentToBuy);
		itemCost = GetItemCost( bot.currentComponentToBuy );
		if bot.currentComponentToBuy == "item_ring_of_health" 
		   or  bot.currentComponentToBuy == "item_void_stone" 
		then CanPurchaseFromSecret = false end

	end
	
	if  bot.currentComponentToBuy == "item_infused_raindrop" 
		or bot.currentComponentToBuy == "item_courier"
		or bot.currentComponentToBuy == "item_tome_of_knowledge"
		or bot.currentComponentToBuy == "item_ward_observer"
		or bot.currentComponentToBuy == "item_ward_sentry"
	then 
		if GetItemStockCount( bot.currentComponentToBuy ) < 1
		then
			return; 
		end
	end
	
	local cost = itemCost;
	
	--Save the gold for buyback whenever a tier 3 tower damaged or destroyed
	if bot:GetLevel() >= 18 and t3AlreadyDamaged == false and DotaTime() > t3Check + 1.0 then
		for i=2, 8, 3 do
			local tower = GetTower(GetTeam(), i);
			if tower == nil or tower:GetHealth()/tower:GetMaxHealth() < 0.05 then
				t3AlreadyDamaged = true;
				break;
			end
		end
		
		for i=1, 7, 3 do
			local tower = GetTower(GetTeam(), i);
			if tower ~= nil and tower:IsAlive() then  
				t3AlreadyDamaged = false;
				break;
			end
		end
		
		for i=9, 10, 1 do
			local tower = GetTower(GetTeam(), i);
			if tower == nil or tower:GetHealth()/tower:GetMaxHealth() < 0.9 then
				t3AlreadyDamaged = true;
				break;
			end
		end
		
		if DotaTime() >= 54 * 60 then t3AlreadyDamaged = true; end
		
		t3Check = DotaTime();
		
	elseif t3AlreadyDamaged == true and bot:GetBuybackCooldown() <= 10 then
		cost = itemCost + bot:GetBuybackCost() + ( 0 + bot:GetNetWorth()/40 ) -300;
	end
	
	--If only one Component
	if t3AlreadyDamaged == true and #bot.currListItemToBuy == 1
	then
		cost = itemCost;
	end
	
	--buy the item if we have the gold
	if ( bot:GetGold() >= cost and bot:GetItemInSlot(13) == nil ) 
	then
		
		if courier == nil then
			courier = GetCourier(0);
		end
		
		--BotBuild done by courier for secret shop item
		if bot.SecretShop 
		   and courier ~= nil 
		   and GetCourierState(courier) == COURIER_STATE_IDLE 
		   and courier:DistanceFromSecretShop() == 0 
		then
			if courier:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS then
				bot.currentComponentToBuy = nil;
				bot.currListItemToBuy[#bot.currListItemToBuy] = nil; 
				courier.latestUser = bot;
				bot.SecretShop = false;
			    bot.SideShop = false;
				return
			end
		end
		
		--Get bot distance from side shop and secret shop
		local dSecretShop = bot:DistanceFromSecretShop();
		local dSideShop   = bot:DistanceFromSideShop();
		
		--Logic to decide in which shop bot have to BotBuild the item
		if CanPurchaseFromSecret             
		   and CanPurchaseFromSide == false  
		   and bot:DistanceFromSecretShop() > 0   
		then
			bot.SecretShop = true;              
			
		elseif CanPurchaseFromSecret            		
			   and CanPurchaseFromSide           
			   and dSideShop < dSecretShop         
			   and dSideShop > 0                   
			   and dSideShop <= 2800 
	    then
			bot.SideShop = true;                       
			
		elseif CanPurchaseFromSecret                   
		       and CanPurchaseFromSide                 
			   and dSideShop > dSecretShop              
			   and dSecretShop > 0                      
	    then
			bot.SecretShop = true;                      
			
		elseif CanPurchaseFromSecret 
			   and CanPurchaseFromSide                  
			   and dSideShop > 2800                     
			   and dSecretShop > 0                      
	    then
			bot.SecretShop = true;                       
			
		elseif CanPurchaseFromSide 
		       and CanPurchaseFromSecret == false            
			   and bot:DistanceFromSideShop() > 0             
			   and bot:DistanceFromSideShop() <= 2800 
	    then
			bot.SideShop = true;                             
			
		else                                                 
			if bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS then
				bot.currentComponentToBuy = nil;                  
				bot.currListItemToBuy[#bot.currListItemToBuy] = nil;  
				bot.SecretShop = false;                               
				bot.SideShop = false;	                              
				return
			else
				print("[item_purchase_generic] "..bot:GetUnitName().." failed to BotBuild "..bot.currentComponentToBuy.." : "..tostring(bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy )))	
			end
		end	
	else
		bot.SecretShop = false;              
		bot.SideShop = false;
	end
end


--Turbo Mode General item BotBuild logis
local function TurboModeGeneralPurchase()
	--Cache all needed item properties when the last item to buy not equal to current item component to buy
	if lastItemToBuy ~= bot.currentComponentToBuy then
		lastItemToBuy = bot.currentComponentToBuy;
		bot:SetNextItemPurchaseValue( GetItemCost( bot.currentComponentToBuy ) );
		itemCost = GetItemCost( bot.currentComponentToBuy );
		lastItemToBuy = bot.currentComponentToBuy ;
	end
	
	if  bot.currentComponentToBuy == "item_infused_raindrop" 
		or bot.currentComponentToBuy == "item_courier"
		or bot.currentComponentToBuy == "item_tome_of_knowledge"
		or bot.currentComponentToBuy == "item_ward_observer"
		or bot.currentComponentToBuy == "item_ward_sentry"
	then 
		if GetItemStockCount( bot.currentComponentToBuy ) < 1
		then
			return; 
		end
	end
	
	local cost = itemCost;
		
	--buy the item if we have the gold
	if ( bot:GetGold() >= cost ) then
		if bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS then
			bot.currentComponentToBuy = nil;
			bot.currListItemToBuy[#bot.currListItemToBuy] = nil; 
			bot.SecretShop = false;
			bot.SideShop = false;	
			return
		else
			print("[item_purchase_generic] "..bot:GetUnitName().." failed to BotBuild "..bot.currentComponentToBuy.." : "..tostring(bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy )))	
		end
	end
end


local lastInvCheck = -90;
local fullInvCheck = -90;
local lastBootsCheck = -90;
local buyBootsStatus = false;
local buyRD = false;
local buyTP = false;
local buyBottle = false;

local buyAnotherRD = false
local lastRDCheck  = 0;
local buyAnotherTango = false
local switchTime = 0
local buyWardTime = -999

local hasSelltEarlyBoots = false
local checkBKBTime = 40 *60
local checkMoonShareTime = 30 *60
local addTB2toBuy     = false
local addTravelBoots  = false

local buyTPtime = 0;


function ItemPurchaseThink()  
	
	if ( GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS )
	then
		return;
	end
	
	if bot:HasModifier('modifier_arc_warden_tempest_double') then
		bot.itemToBuy = {};
		return;
	end	
	
	--------*******----------------*******----------------*******--------
	local nowTime  = DotaTime();
	local botName  = bot:GetUnitName();
	local botLevel = bot:GetLevel();
	local botGold  = bot:GetGold();
	local botWorth = bot:GetNetWorth();
	local botMode  = bot:GetActiveMode();
	local botHP    = bot:GetHealth()/bot:GetMaxHealth();
	--------*******----------------*******----------------*******--------
	
	
	--buy another tango for midlaner
	if nowTime > 60 and nowTime < 4 *60 
	   and bot.theRole == "midlaner" 
	   and buyAnotherTango == false
	   and not Item.HasItem(bot,"item_tango_single")
	   and not Item.HasItem(bot,"item_tango")
	   and botGold > GetItemCost( "item_tango" ) 
	   and Item.GetEmptyInventoryAmount(bot) >= 5
	   and bot:GetCourierValue() == 0
	then
		bot:ActionImmediate_PurchaseItem("item_tango"); 
		buyAnotherTango = true;
		return;
	end
		
	--Update support availability status
	if Role['supportExist'] == nil then Role.UpdateSupportStatus(bot); end
	
	--Update invisible hero or item availability status
	if Role['invisEnemyExist'] == false then Role.UpdateInvisEnemyStatus(bot); end
	
	--Update boots availability status to make the bot start buy support item and rain drop
	if buyBootsStatus == false and nowTime > lastBootsCheck + 2.0 then buyBootsStatus = Item.UpdateBuyBootStatus(bot); lastBootsCheck = nowTime end
	
	--buy flying courier and support item
	if bot.theRole == 'support' then
		if nowTime < 0 and GetItemStockCount( "item_courier" ) > 0
		then
			bot:ActionImmediate_PurchaseItem( 'item_courier' );      
		elseif nowTime < 0 and botGold >= GetItemCost( "item_clarity" ) and Item.HasItem(bot, "item_clarity") == false 
		then
			bot:ActionImmediate_PurchaseItem("item_clarity");	
		elseif botLevel >= 5 and Role['invisEnemyExist'] == true and buyBootsStatus == true and botGold >= GetItemCost( "item_dust" ) 
			and Item.GetEmptyInventoryAmount(bot) >= 2 and Item.GetItemCharges(bot, "item_dust") < 1 and bot:GetCourierValue() == 0   
		then
			bot:ActionImmediate_PurchaseItem("item_dust"); 
		elseif GetItemStockCount( "item_ward_observer" ) >= 1 
			  and ( nowTime < 0 or ( nowTime > 0 and buyBootsStatus == true ) ) 
			  and botGold >= GetItemCost( "item_ward_observer" ) 
			  and Item.GetEmptyInventoryAmount(bot) >= 2 
			  and Item.GetItemCharges(bot, "item_ward_observer") < 1  
			  and bot:GetCourierValue() == 0
			  and buyWardTime < nowTime - 3 *60
		then 
			buyWardTime = nowTime;
			bot:ActionImmediate_PurchaseItem("item_ward_observer"); 
		end
	end
	
	--buy courier when no support in team
	if nowTime > -65 and nowTime < 600 and botGold >= 50 
	   and GetItemStockCount( "item_courier" ) > 0 
	   and bot:DistanceFromFountain() < 200
	   and ( Role['supportExist'] == false or Role['supportExist'] == nil )
	then 
		bot:ActionImmediate_PurchaseItem( 'item_courier' );
		return;
	end
	
	--buy raindrop
	if buyRD == false
	   and nowTime > 3 *60
	   and nowTime < 20 *60
	   and buyBootsStatus == true
	   and GetItemStockCount( "item_infused_raindrop" ) > 0 
	   and Item.GetItemCharges(bot, 'item_infused_raindrop') < 1
	   and botGold >= GetItemCost( "item_infused_raindrop" ) 
	   and Item.HasItem(bot, 'item_boots')
	then
		bot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
		buyRD = true;
		return;
	end
	
	
	if buyRD == false and nowTime < 0
		and bot.theRole ~= 'support'
	then
		buyRD = true
	end
	
	
	--buy raindrop when it broken
	if nowTime > 5 *60 and lastRDCheck < nowTime - 5.0 and buyAnotherRD == false
	then
		lastRDCheck = nowTime;
		local recipe_urn_of_shadows = bot:FindItemSlot("item_recipe_urn_of_shadows");
		local raindrop = bot:FindItemSlot("item_infused_raindrop");
		if  recipe_urn_of_shadows >= 0 and recipe_urn_of_shadows <= 8 
		    and raindrop == -1 and bot:GetCourierValue() == 0
			and botGold >= GetItemCost( "item_infused_raindrop" ) 
			and GetItemStockCount( "item_infused_raindrop" ) > 0 
		then
			bot:ActionImmediate_PurchaseItem("item_infused_raindrop"); 
			buyAnotherRD = true;
			return;
		end
	end
	
	--buy tp when die
	if botGold >= 50 
	   and bot:IsAlive()
	   and botGold < ( 50 + botWorth/40 )
	   and botHP < 0.08	   
	   and GetGameMode() ~= 23
	   and bot:GetHealth() >= 1
	   and bot:WasRecentlyDamagedByAnyHero(3.1)
	   and not Item.HasItem(bot, 'item_travel_boots')
	   and not Item.HasItem(bot, 'item_travel_boots_2')
	   and Item.GetItemCharges(bot, 'item_tpscroll') <= 3	   
	then
		bot:ActionImmediate_PurchaseItem("item_tpscroll"); 
		return;
	end	 

	--buy ward when die
	if botGold >= 50 
	   and bot:IsAlive()
	   and bot.theRole == 'support'
	   and botGold < ( 50 + botWorth/40 )
	   and botHP < 0.06	   
	   and GetGameMode() ~= 23
	   and bot:GetHealth() >= 1
	   and bot:WasRecentlyDamagedByAnyHero(3.1)
	   and GetItemStockCount( "item_ward_observer" ) >= 2
	then
		bot:ActionImmediate_PurchaseItem("item_ward_observer"); 
		return;
	end
	
	--buy dust when die
	if botGold >= 180 
	   and bot:IsAlive()
	   and bot.theRole == 'support'
	   and botGold < ( 100 + botWorth/40 )
	   and botHP < 0.06	   
	   and GetGameMode() ~= 23
	   and bot:GetHealth() >= 1
	   and bot:WasRecentlyDamagedByAnyHero(3.1)
	   and Item.GetItemCharges(bot, 'item_dust') <= 1	  
	then
		bot:ActionImmediate_PurchaseItem("item_dust"); 
		return;
	end
	
	--buy tom of knowledge when die
	if nowTime > 10 *60
	   and bot:IsAlive()
	   and botGold >= 150 
	   and botGold < ( 150 + botWorth/40 )
	   and botHP < 0.08	   
	   and botLevel < 24
	   and GetGameMode() ~= 23
	   and bot:WasRecentlyDamagedByAnyHero(3.1)
	   and GetItemStockCount( "item_tome_of_knowledge" ) >= 1
	   and Item.GetItemCharges(bot, 'item_tome_of_knowledge') < 1
	then
		bot:ActionImmediate_PurchaseItem("item_tome_of_knowledge"); 
		return;
	end
	
	--swap item_stout_shield when item_quelling_blade in backpack
	if nowTime > 30 and nowTime < 3000
		and switchTime < nowTime - 7
		and bot:GetAttackRange() < 310
	then
		local blade  = bot:FindItemSlot("item_quelling_blade");
		local shield = bot:FindItemSlot("item_stout_shield");
		local stick  = bot:FindItemSlot("item_magic_stick");
				
		local nEnemyHeroes = bot:GetNearbyHeroes(1400,true,BOT_MODE_NONE)
		
		--No enemy nearby then swap shield , blade or stick
		if (nEnemyHeroes[1] == nil)
		   and (blade >= 6 and blade <= 8)
		then
			if (shield >=0 and shield <= 5)
			then
				switchTime = nowTime;
				bot:ActionImmediate_SwapItems( blade, shield );
				return;
			end
			if (stick >=0 and stick <= 5)
			then
				switchTime = nowTime;
				bot:ActionImmediate_SwapItems( blade, stick );
				return;
			end
		end
		 
		--there be enemy then swap shield and blade
		if (nEnemyHeroes[1] ~= nil)
		   and (blade >= 0 and blade <= 5)
		then
			if (shield >= 6 and shield <= 8)
			then
				switchTime = nowTime;
				bot:ActionImmediate_SwapItems( blade, shield );
				return;
			end
		end
	end
	
	--swap raindrop when it will be broken
	if nowTime > 180 and nowTime < 1800
	   and switchTime < nowTime - 5.6
	then
		local raindrop = bot:FindItemSlot("item_infused_raindrop");
		local raindropCharge = Item.GetItemCharges(bot, "item_infused_raindrop");
		local nEnemyHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
		if (raindrop >= 0 and raindrop <= 5)
		   and ( nEnemyHeroes[1] ~= nil 
				 or botMode == BOT_MODE_ROSHAN
		         or bot:WasRecentlyDamagedByAnyHero(3.1))
		   and ( raindropCharge == 1 or raindropCharge >= 6 )
		then
		    switchTime = nowTime;
			bot:ActionImmediate_SwapItems( raindrop, 6 );
			return;
		end
	end
	
	--swap ward,flask,tango_singe 
	if nowTime > 60 and botLevel < 25
		and botMode ~= BOT_MODE_WARD
		and check_time < nowTime - 10
	then
		check_time = nowTime;
		local wardSlot = bot:FindItemSlot('item_ward_observer');
		if wardSlot >=0 and wardSlot <= 5 
		   and bot.lastSwapWardTime <  nowTime - 10 then
			local mostCostItem = Item.GetTheItemSolt(bot, 6, 8, true)
			if mostCostItem ~= -1 then
				bot:ActionImmediate_SwapItems( wardSlot, mostCostItem );
				return;
			end
		end
		
		local tango_single = bot:FindItemSlot('item_tango_single');
		if tango_single >= 0 and tango_single <= 5 
		   and Item.GetItemCountInSolt(bot, "item_tango_single", 0, 5) >= 2 
		then
			local mostCostItem = Item.GetTheItemSolt(bot, 6, 8, true)
			if mostCostItem ~= -1 then
				bot:ActionImmediate_SwapItems( tango_single, mostCostItem );
				return;
			end
		end
		
	end
	
	--sell early game item   
	if  ( GetGameMode() ~= 23 and botLevel > 5 and nowTime > fullInvCheck + 1.0 
	      and ( bot:DistanceFromFountain() <= 150 or bot:DistanceFromSecretShop() <= 150 or bot:DistanceFromSideShop() <= 150) ) 
		or ( GetGameMode() == 23 and botLevel > 8 and nowTime > fullInvCheck + 1.0  )
	then
		local emptySlot = Item.GetEmptyInventoryAmount(bot);
		local slotToSell = nil;
		
		local preEmpty = 2;
		if botLevel < 18 then preEmpty = 1; end
		if emptySlot < preEmpty then
			for i=1,#Item['tEarlyItem'] 
			do
				local item = Item['tEarlyItem'][i];
				local itemSlot = bot:FindItemSlot(item);
				if itemSlot >= 0 and itemSlot <= 8 then
					if item == "item_magic_wand" or item == "item_magic_stick" 
					then
						if 	( emptySlot == 0 or botWorth > 18000) 
						    and botWorth > 15000
						then
							slotToSell = itemSlot;
							break;
						end
					elseif  item == "item_branches" and botWorth > 7000
						then
							if  ( bot.theRole ~= 'support' and bot:GetPrimaryAttribute() ~= ATTRIBUTE_STRENGTH )
								or botWorth > 15000
							then
								slotToSell = itemSlot;
								break;
							end
					else
						slotToSell = itemSlot;
						break;
					end
				end
			end
		end	
		
		--for charge wand
		if botWorth > 9999 and ( botName ~= 'npc_dota_hero_luna' or botWorth > 13333 )
		then
			local wand = bot:FindItemSlot("item_magic_wand");
			local assitItem =  bot:FindItemSlot("item_infused_raindrop");
			if assitItem < 0 then assitItem =  bot:FindItemSlot("item_bracer"); end
			if assitItem < 0 then assitItem =  bot:FindItemSlot("item_null_talisman"); end
			if assitItem < 0 then assitItem =  bot:FindItemSlot("item_wraith_band"); end		
			if assitItem >= 0 and wand >= 6 and wand <= 8
			then
				slotToSell = assitItem;
			end	
		end
		
		if slotToSell ~= nil then
			bot:ActionImmediate_SellItem(bot:GetItemInSlot(slotToSell));
		end
		
		fullInvCheck = nowTime;
	end
	
	--sale late item 
	if nowTime > sell_time + 1.0 
	   and ( bot:GetItemInSlot(6) ~= nil or bot:GetItemInSlot(7) ~= nil )                 
	   and ( bot:DistanceFromFountain() <= 150 or bot:DistanceFromSecretShop() <= 150 or bot:DistanceFromSideShop() <= 150) 
	then
		sell_time = nowTime;
		
		for i = 2 ,#sItemSellList, 2
		do
			local nNewSlot = bot:FindItemSlot(sItemSellList[i -1]);
			local nOldSlot = bot:FindItemSlot(sItemSellList[i]);
			if nNewSlot >= 0 and nOldSlot >= 0
			then
				--print(sItemSellList[i -1]..sItemSellList[i]);
				bot:ActionImmediate_SellItem(bot:GetItemInSlot(nOldSlot));
				return;
			end
		end
		
	end
	
	--Sell non BoT boots when have BoT
	if nowTime > 30 *60 and not hasSelltEarlyBoots 
	   and  ( bot:GetItemInSlot(6) ~= nil or bot:GetItemInSlot(7) ~= nil )
	   and  ( bot:DistanceFromFountain() <= 150 or bot:DistanceFromSecretShop() <= 150 or bot:DistanceFromSideShop() <= 150 )
	   and  ( Item.HasItem( bot, "item_travel_boots") or Item.HasItem( bot, "item_travel_boots_2")) 
	then	
		for i=1,#Item['tEarlyBoots']
		do
			local bootsSlot = bot:FindItemSlot(Item['tEarlyBoots'][i]);
			if bootsSlot >= 0 then
				bot:ActionImmediate_SellItem(bot:GetItemInSlot(bootsSlot));
				hasSelltEarlyBoots = true;
				return;
			end
		end
	end
	
	--Insert tp scroll to list item to buy and then change the buyTP flag so the bots don't reapeatedly add the tp scroll to list item to buy 
	if nowTime > 4 *60 
	    and buyTP == false 
		and bot:GetCourierValue() == 0 
		and (bot:FindItemSlot('item_tpscroll') == -1 
		      or (botLevel >= 12 and Item.GetItemCharges(bot, 'item_tpscroll') <= 1)) 
		and botGold >= 50
	then
		local tCharges = Item.GetItemCharges(bot, 'item_tpscroll');
		
		if botLevel < 12 or (botLevel >= 12 and tCharges == 1)
		then
			buyTP = true;
			buyTPtime = nowTime;
			bot.currentComponentToBuy = nil;	
			bot.currListItemToBuy[#bot.currListItemToBuy+1] = 'item_tpscroll';
			return;
		end
		
		if botLevel >= 12 and tCharges == 0 and botGold >= 100
		then
			buyTP = true;
			buyTPtime = nowTime;
			bot.currentComponentToBuy = nil;	
			bot.currListItemToBuy[#bot.currListItemToBuy+1] = 'item_tpscroll';
			bot.currListItemToBuy[#bot.currListItemToBuy+1] = 'item_tpscroll';
			return;
		end
	end
	
	--Change the flag to buy tp scroll to false when it already has it in inventory so the bot can insert tp scroll to list item to buy whenever they don't have any tp scroll
	if buyTP == true and buyTPtime < nowTime - 70
	then
		buyTP = false;
	end
	
	--Add travelboots,moonshare,bkb to buy when in very late
	if #bot.itemToBuy == 0 and not Role.IsUserMode() --there be bug
	then

		if addTravelBoots == false
		   and Item.HasItem(bot, 'item_travel_boots') 
		then
			addTravelBoots = true;
			return;
		end
	
		if addTravelBoots == false 
		   and not Item.HasItem(bot, 'item_guardian_greaves')
		then
			bot.itemToBuy = {'item_travel_boots'};
			addTravelBoots = true;
			return;
		end
	
		if Role.ShouldBuyMoonShare()
		   and botGold > 4000 + bot:GetBuybackCost() + ( 0 + botWorth/40 ) - 333
		then
			
			bot.itemToBuy = {'item_moon_shard' };
			Role['moonshareCount'] = Role['moonshareCount'] - 1;
			return;
			
		end
		
		if addTB2toBuy == false
		   and Item.HasItem(bot, 'item_travel_boots_2')
		then
			addTB2toBuy = true;
			return;
		end
	
		if  addTB2toBuy == false
		    and addTravelBoots == true
		    and not Item.HasItem(bot, 'item_guardian_greaves')
			and not Role.ShouldBuyMoonShare()
			and not Item.HasItem(bot, 'item_moon_shard')
			and botGold > 2000 + bot:GetBuybackCost() + botWorth/40 - 222
		then
			addTB2toBuy = true;
			bot.itemToBuy = {'item_travel_boots_2'};
			return;
		end
	end
	
	--Sell cheapie when have travel_boots
	if  nowTime > 50 *60 --and #bot.itemToBuy == 0 
		and ( bot:GetItemInSlot(7) ~= nil or bot:GetItemInSlot(8) ~= nil )
		and ( Item.HasItem(bot, 'item_travel_boots') or Item.HasItem(bot, 'item_travel_boots_2'))
		and ( bot:DistanceFromFountain() == 0 or bot:DistanceFromSecretShop() == 0 or bot:DistanceFromSideShop() == 0)
		and ( not Item.HasItem(bot, 'item_refresher_shard') and not Item.HasItem(bot, 'item_cheese') and not Item.HasItem(bot, "item_aegis") )
		and ( not Item.HasItem(bot, 'item_dust') and not Item.HasItem(bot, "item_ward_observer") )
		and ( not Item.HasItem(bot, 'item_moon_shard') and not Item.HasItem(bot, "item_hyperstone") )
	then
		local itemToSell = nil;
		local itemToSellValue = 99999;
		for i = 0, 8
		do
			local tempItem = bot:GetItemInSlot(i);
			if tempItem ~= nil 			   
			then
				local tempItemName = tempItem:GetName();
				if tempItemName ~= 'item_black_king_bar'
				   and tempItemName ~= 'item_satanic'
				   and tempItemName ~= 'item_skadi'
				   and tempItemName ~= 'item_travel_boots'
				   and tempItemName ~= 'item_travel_boots_2'
				   and tempItemName ~= 'item_rapier'
				   and tempItemName ~= 'item_gem'
				   and GetItemCost(tempItemName) < itemToSellValue
				then
					itemToSell = tempItem;
					itemToSellValue = GetItemCost(tempItemName);
				end
			end
		end		
		if itemToSell ~= nil
		then
			bot:ActionImmediate_SellItem(itemToSell);
			return;
		end
	end
		
	--No need to BotBuild item when no item to BotBuild in the list
	if #bot.itemToBuy == 0 then bot:SetNextItemPurchaseValue( 0 ); return; end
	
	--Get the next item to buy and break it to item components then add it to currListItemToBuy. 
	--It'll only done if the bot already has the item that formed from its component in their hero's inventory (not stash) to prevent unintended item combining
	if  bot.currentItemToBuy == nil and #bot.currListItemToBuy == 0 then    
		bot.currentItemToBuy = bot.itemToBuy[#bot.itemToBuy];               
		local tempTable = Item.GetBasicItems({bot.currentItemToBuy})   
		for i=1,math.ceil(#tempTable/2)                                                     
		do	
			bot.currListItemToBuy[i] = tempTable[#tempTable-i+1];
			bot.currListItemToBuy[#tempTable-i+1] = tempTable[i];
		end
		
	end
	
	--Check if the bot already has the item formed from its components in their inventory (not stash)
	if  #bot.currListItemToBuy == 0 and nowTime > lastInvCheck + 3.0 then  
	    if Item.IsItemInHero(bot.currentItemToBuy) 
		then   
			bot.currentItemToBuy = nil;                         
			bot.itemToBuy[#bot.itemToBuy] = nil;           
		else
			lastInvCheck = nowTime;
		end
	--Added item component to current item component to buy and do the BotBuild	
	elseif #bot.currListItemToBuy > 0 then           
		if bot.currentComponentToBuy == nil then      
			bot.currentComponentToBuy = bot.currListItemToBuy[#bot.currListItemToBuy];  
		else                                          
			if GetGameMode() == 23 then
				TurboModeGeneralPurchase();
			else
				GeneralPurchase();
			end	
		end
	end

end
-- dota2jmz@163.com QQ:2462331592.
