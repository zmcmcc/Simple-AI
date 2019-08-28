----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local ItemModule = {}


ItemModule['tRemoveItems'] = {
	'item_iron_talon',
	'item_diffusal_blade_2',
	'item_poor_mans_shield',
	'item_ring_of_aquila',
}

ItemModule['tBasicItems'] = {
	'item_aegis',
	'item_boots_of_elves',
	'item_belt_of_strength',
	'item_blade_of_alacrity',
	'item_blades_of_attack',
	'item_blight_stone',
	'item_blink',
	'item_boots',
	'item_bottle',
	'item_branches',
	'item_broadsword',
	'item_chainmail',
	'item_cheese',
	'item_circlet',
	'item_clarity',
	'item_claymore',
	'item_cloak',
	'item_courier',
	'item_crown',
	'item_demon_edge',
	'item_dust',
	'item_eagle',
	'item_enchanted_mango',
	'item_energy_booster',
	'item_faerie_fire',
	'item_flying_courier',
	'item_flask',
	'item_gauntlets',
	'item_gem',
	'item_ghost',
	'item_gloves',
	'item_helm_of_iron_will',
	'item_hyperstone',
	'item_infused_raindrop',
	'item_javelin',
	'item_lifesteal',
	'item_magic_stick',
	'item_mantle',
	'item_mithril_hammer',	
	'item_mystic_staff',	
	'item_ogre_axe',
	'item_orb_of_venom',
	'item_platemail',
	'item_point_booster',
	'item_quarterstaff',
	'item_quelling_blade',
	'item_reaver',
	'item_refresher_shard',
	'item_ring_of_health',
	'item_ring_of_protection',
	'item_ring_of_regen',
	'item_ring_of_tarrasque',
	'item_robe',
	'item_relic',
	'item_sobi_mask',	
	'item_shadow_amulet',
	'item_slippers',
	'item_smoke_of_deceit',
	'item_staff_of_wizardry',
	'item_stout_shield',
	'item_talisman_of_evasion',
	'item_tango',
	'item_tango_single',
	'item_tome_of_knowledge',
	'item_tpscroll',
	'item_ultimate_orb',
	'item_vitality_booster',
	'item_void_stone',
	'item_wind_lace',
	'item_ward_observer',
	'item_ward_sentry',	
}

ItemModule['tSeniorItems'] = {
	
	'item_arcane_boots',
	'item_buckler',
	'item_basher',
	'item_dagon',
	'item_dagon_2',
	'item_dagon_3',
	'item_dagon_4',	
	'item_dragon_lance',	
	'item_force_staff',	
	'item_headdress',	
	'item_hood_of_defiance',	
	'item_invis_sword',
	'item_kaya',	
	'item_lesser_crit',
	'item_maelstrom',	
	'item_medallion_of_courage',
	'item_mekansm',	
	'item_necronomicon',
	'item_necronomicon_2',
	'item_ring_of_basilius',
	'item_sange',	
	'item_soul_booster',
	'item_travel_boots',	
	'item_urn_of_shadows',	
	'item_vanguard',	
	'item_yasha',
	
}

ItemModule['tTopItems'] = {
	'item_abyssal_blade',
	'item_aether_lens',
	'item_armlet',
	'item_assault',
	'item_ancient_janggo',
	'item_aeon_disk',
	'item_bfury',
	'item_black_king_bar',
	'item_blade_mail',
	'item_bloodstone',
	'item_bloodthorn',
	'item_bracer',
	'item_butterfly',
	'item_crimson_guard',
	'item_cyclone',
	'item_dagon_5',
	'item_desolator',
	'item_diffusal_blade',
	'item_echo_sabre',
	'item_ethereal_blade',
	'item_glimmer_cape',
	'item_guardian_greaves',
	'item_greater_crit',
	'item_hand_of_midas',
	'item_heart',
	'item_heavens_halberd',
	'item_helm_of_the_dominator',
	'item_hurricane_pike',
	'item_holy_locket',
	'item_kaya_and_sange',
	'item_lotus_orb',
	'item_magic_wand',
	'item_manta',
	'item_mask_of_madness',
	'item_mjollnir',
	'item_monkey_king_bar',
	'item_moon_shard',
	'item_meteor_hammer',
	'item_necronomicon_3',
	'item_null_talisman',
	'item_nullifier',
	'item_orchid',
	'item_pers',
	'item_phase_boots',
	'item_pipe',
	'item_power_treads',
	'item_radiance',
	'item_rapier',
	'item_refresher',
	'item_rod_of_atos',
	'item_sange_and_yasha',
	'item_satanic',
	'item_sheepstick',
	'item_sphere',
	'item_shivas_guard',
	'item_silver_edge',
	'item_solar_crest',
	'item_soul_ring',
	'item_skadi',
	'item_spirit_vessel',
	'item_tranquil_boots',
	'item_travel_boots_2',
	'item_ultimate_scepter',
	'item_veil_of_discord',
	'item_vladmir',
	'item_wraith_band',
	'item_yasha_and_kaya',
}

ItemModule['tEarlyItem'] = {
	 'item_clarity',
	 'item_faerie_fire',
	 'item_tango',  
	 'item_flask', 
	 'item_infused_raindrop',
	 'item_branches',
	 'item_magic_stick',
	 'item_orb_of_venom',
	 'item_bracer',
	 'item_wraith_band',
	 'item_null_talisman',
	 'item_bottle',  
	 'item_soul_ring',  
	 'item_magic_wand',
	 'item_ancient_janggo',
	 'item_refresher_shard',
	 'item_cheese',
--   'item_quelling_blade',
--	 'item_stout_shield',
--	 'item_dust',
--	 'item_ward_observer',
--	 'item_ring_of_basilius',
--	 'item_urn_of_shadows',
--	 'item_armlet',
--	 'item_power_treads',
--	 'item_hand_of_midas' 
}

ItemModule['tEarlyBoots'] = {  
	'item_phase_boots', 
	'item_power_treads', 
	'item_tranquil_boots', 
	'item_arcane_boots'  
}

ItemModule['tCanNotSwitchItems'] = {
		'item_aegis',
		'item_refresher_shard',
		'item_bloodstone',
		'item_gem',
}

ItemModule['tPowerBoots'] = {  
	 
	'item_power_treads_agi',
	'item_power_treads_int',
	'item_power_treads_str',	
	  
}

ItemModule['tMidOutfit'] = {  
	'item_viper_outfit', 
	'item_medusa_outfit',
	'item_razor_outfit',
	'item_templar_assassin_outfit',
	'item_nevermore_outfit',
	'item_sniper_outfit',
}

ItemModule['tCarryOutfit'] = {  
	'item_drow_ranger_outfit',
	'item_sven_outfit',
	'item_arc_warden_outfit',
	'item_phantom_assassin_outfit',
	'item_phantom_lancer_outfit',
	'item_antimage_outfit',
	'item_luna_outfit',
	'item_bloodseeker_outfit',
}

ItemModule['tCoreOutfit'] = {  
	'item_chaos_knight_outfit',
	'item_kunkka_outfit',
	'item_dragon_knight_outfit',
	'item_skeleton_king_outfit',
	'item_bristleback_outfit',
	'item_ogre_magi_outfit',
}

ItemModule['tSupportOutfit'] = {  
	'item_crystal_maiden_outfit',
	'item_jakiro_outfit',
	'item_zuus_outfit',
	'item_necrolyte_outfit',
	'item_silencer_outfit',
	'item_warlock_outfit',
	'item_skywrath_mage_outfit',
	'item_lina_outfit',
}

ItemModule['tConsumableList'] = {
	'item_clarity',
	'item_tango',
	'item_flask',
	'item_faerie_fire',
}


if true then

ItemModule['item_abyssal_blade']		 = { 'item_basher', 'item_vanguard', 'item_recipe_abyssal_blade' }

ItemModule['item_aether_lens']			 = { 'item_void_stone', 'item_energy_booster', 'item_recipe_aether_lens' }

ItemModule['item_arcane_boots']			 = { 'item_boots', 'item_energy_booster' }

ItemModule['item_armlet']				 = { 'item_helm_of_iron_will', 'item_gloves', 'item_blades_of_attack', 'item_recipe_armlet' }

ItemModule['item_assault']				 = { 'item_chainmail',  'item_platemail', 'item_hyperstone', 'item_recipe_assault' }

ItemModule['item_ancient_janggo']		 = { 'item_crown', 'item_wind_lace', 'item_sobi_mask', 'item_recipe_ancient_janggo' }

ItemModule['item_aeon_disk']			 = { 'item_vitality_booster', 'item_energy_booster', 'item_recipe_aeon_disk' }

ItemModule['item_bfury']				 = { 'item_quelling_blade',  'item_ring_of_health', 'item_demon_edge', 'item_void_stone', 'item_recipe_bfury' }

ItemModule['item_black_king_bar']		 = { 'item_mithril_hammer', 'item_ogre_axe', 'item_recipe_black_king_bar' }

ItemModule['item_blade_mail']			 = {  'item_chainmail', 'item_robe', 'item_broadsword' }

ItemModule['item_bloodstone']			 = { 'item_point_booster', 'item_vitality_booster', 'item_energy_booster', 'item_pers' }

ItemModule['item_bloodthorn']			 = { 'item_orchid',  'item_lesser_crit',  'item_recipe_bloodthorn' }

ItemModule['item_bracer']				 = {  'item_circlet', 'item_gauntlets', 'item_recipe_bracer' }

ItemModule['item_buckler']				 = { 'item_branches', 'item_chainmail', 'item_recipe_buckler' }

ItemModule['item_butterfly']			 = { 'item_quarterstaff', 'item_eagle', 'item_talisman_of_evasion' }

ItemModule['item_basher']				 = { 'item_mithril_hammer', 'item_belt_of_strength', 'item_recipe_basher' }

ItemModule['item_crimson_guard']		 = { 'item_vanguard', 'item_buckler', 'item_recipe_crimson_guard' }

ItemModule['item_cyclone']				 = { 'item_wind_lace', 'item_void_stone', 'item_staff_of_wizardry', 'item_recipe_cyclone' }

ItemModule['item_dagon']				 = { 'item_crown', 'item_staff_of_wizardry', 'item_recipe_dagon' }

ItemModule['item_dagon_2']				 = { 'item_dagon', 'item_recipe_dagon' }

ItemModule['item_dagon_3']				 = { 'item_dagon_2', 'item_recipe_dagon' }

ItemModule['item_dagon_4']				 = { 'item_dagon_3', 'item_recipe_dagon' }

ItemModule['item_dagon_5']				 = { 'item_dagon_4', 'item_recipe_dagon' }

ItemModule['item_desolator']			 = { 'item_mithril_hammer', 'item_mithril_hammer', 'item_blight_stone' }

ItemModule['item_diffusal_blade']		 = { 'item_blade_of_alacrity', 'item_blade_of_alacrity', 'item_robe', 'item_recipe_diffusal_blade' }

ItemModule['item_diffusal_blade_2']		 = { 'item_diffusal_blade', 'item_recipe_diffusal_blade' }

ItemModule['item_dragon_lance']			 = { 'item_boots_of_elves', 'item_boots_of_elves', 'item_ogre_axe' }

ItemModule['item_echo_sabre']			 = { 'item_ogre_axe', 'item_oblivion_staff' }

ItemModule['item_ethereal_blade']		 = { 'item_ghost', 'item_eagle' }

ItemModule['item_force_staff']			 = { 'item_staff_of_wizardry', 'item_ring_of_regen', 'item_recipe_force_staff' }

ItemModule['item_glimmer_cape']			 = { 'item_shadow_amulet', 'item_cloak' }

ItemModule['item_guardian_greaves']		 = { 'item_arcane_boots', 'item_mekansm', 'item_recipe_guardian_greaves' }

ItemModule['item_greater_crit']			 = { 'item_lesser_crit', 'item_recipe_greater_crit', 'item_demon_edge' }

ItemModule['item_hand_of_midas']		 = { 'item_gloves', 'item_recipe_hand_of_midas' }

ItemModule['item_headdress']			 = { 'item_branches', 'item_ring_of_regen', 'item_recipe_headdress' }

ItemModule['item_heart']				 = { 'item_reaver' , 'item_ring_of_tarrasque', 'item_vitality_booster', 'item_recipe_heart' }

ItemModule['item_heavens_halberd']		 = { 'item_sange', 'item_talisman_of_evasion' }

ItemModule['item_helm_of_the_dominator'] = { 'item_headdress', 'item_gloves', 'item_ring_of_health', 'item_recipe_helm_of_the_dominator ' }

ItemModule['item_hood_of_defiance'] 	 = { 'item_ring_of_health', 'item_cloak', 'item_ring_of_regen' }

ItemModule['item_hurricane_pike'] 		 = { 'item_dragon_lance', 'item_force_staff', 'item_recipe_hurricane_pike' }

ItemModule['item_holy_locket'] 			 = { 'item_ring_of_tarrasque', 'item_cloak', 'item_energy_booster', 'item_recipe_holy_locket' }

ItemModule['item_iron_talon'] 			 = { 'item_quelling_blade', 'item_ring_of_protection', 'item_recipe_iron_talon' }

ItemModule['item_invis_sword']			 = { 'item_shadow_amulet', 'item_claymore' }

ItemModule['item_kaya']					 = { 'item_robe', 'item_staff_of_wizardry', 'item_recipe_kaya' }

ItemModule['item_kaya_and_sange']		 = { 'item_sange', 'item_kaya' }

ItemModule['item_lotus_orb']			 = { 'item_pers', 'item_platemail', 'item_energy_booster' }

ItemModule['item_lesser_crit']			 = { 'item_broadsword', 'item_blades_of_attack', 'item_recipe_lesser_crit' }

ItemModule['item_maelstrom']			 = { 'item_javelin', 'item_mithril_hammer' }

ItemModule['item_magic_wand']			 = { 'item_branches', 'item_branches', 'item_magic_stick', 'item_recipe_magic_wand' }

ItemModule['item_manta']				 = { 'item_yasha', 'item_ultimate_orb', 'item_recipe_manta' }

ItemModule['item_mask_of_madness']		 = { 'item_quarterstaff', 'item_lifesteal' }

ItemModule['item_medallion_of_courage']	 = { 'item_blight_stone', 'item_sobi_mask', 'item_chainmail' }

ItemModule['item_mekansm']				 = { 'item_buckler', 'item_headdress', 'item_recipe_mekansm' }

ItemModule['item_mjollnir']				 = { 'item_maelstrom', 'item_recipe_mjollnir', 'item_hyperstone' }

ItemModule['item_monkey_king_bar']		 = { 'item_quarterstaff', 'item_javelin', 'item_demon_edge' }

ItemModule['item_moon_shard']			 = { 'item_hyperstone', 'item_hyperstone' }

ItemModule['item_meteor_hammer']		 = { 'item_ring_of_regen', 'item_sobi_mask', 'item_ogre_axe', 'item_staff_of_wizardry' }

ItemModule['item_necronomicon']			 = { 'item_sobi_mask', 'item_sobi_mask', 'item_belt_of_strength', 'item_recipe_necronomicon' }

ItemModule['item_necronomicon_2']		 = { 'item_necronomicon', 'item_recipe_necronomicon' }

ItemModule['item_necronomicon_3']		 = { 'item_necronomicon_2', 'item_recipe_necronomicon' }
	    
ItemModule['item_null_talisman']		 = {  'item_circlet', 'item_mantle', 'item_recipe_null_talisman' }

ItemModule['item_nullifier']			 = { 'item_helm_of_iron_will', 'item_relic' }

ItemModule['item_oblivion_staff']		 = { 'item_quarterstaff', 'item_robe', 'item_sobi_mask' }

ItemModule['item_octarine_core']		 = { 'item_soul_booster', 'item_mystic_staff' }

ItemModule['item_orchid']				 = { 'item_oblivion_staff', 'item_oblivion_staff', 'item_recipe_orchid' }

ItemModule['item_pers']					 = { 'item_ring_of_health', 'item_void_stone' }

ItemModule['item_phase_boots']			 = { 'item_boots', 'item_blades_of_attack', 'item_chainmail' }

ItemModule['item_pipe']					 = { 'item_hood_of_defiance', 'item_headdress', 'item_recipe_pipe' }

ItemModule['item_poor_mans_shield']		 = { 'item_stout_shield', 'item_slippers', 'item_slippers' }

ItemModule['item_power_treads_agi']		 = { 'item_boots', 'item_boots_of_elves', 'item_gloves' }

ItemModule['item_power_treads_int']		 = { 'item_boots', 'item_robe', 'item_gloves' }

ItemModule['item_power_treads_str']		 = { 'item_boots', 'item_belt_of_strength' , 'item_gloves' }

ItemModule['item_power_treads']			 = { 'item_boots', 'item_belt_of_strength', 'item_gloves' }

ItemModule['item_radiance']				 = { 'item_relic', 'item_recipe_radiance' }

ItemModule['item_rapier']				 = { 'item_relic', 'item_demon_edge' }

ItemModule['item_refresher']			 = { 'item_pers', 'item_pers', 'item_recipe_refresher' }
				
ItemModule['item_ring_of_aquila']		 = { 'item_ring_of_basilius', 'item_crown' }
			    
ItemModule['item_ring_of_basilius']		 = {  'item_ring_of_protection', 'item_sobi_mask' }
				
ItemModule['item_rod_of_atos']			 = { 'item_crown', 'item_crown', 'item_staff_of_wizardry', 'item_recipe_rod_of_atos' }

ItemModule['item_sange']				 = { 'item_belt_of_strength', 'item_ogre_axe', 'item_recipe_sange' }
			    
ItemModule['item_sange_and_yasha']		 = { 'item_yasha', 'item_sange' }

ItemModule['item_satanic']				 = { 'item_lifesteal', 'item_claymore', 'item_reaver' }

ItemModule['item_sheepstick']			 = { 'item_ultimate_orb', 'item_void_stone', 'item_mystic_staff' }

ItemModule['item_sphere']				 = { 'item_pers', 'item_ultimate_orb', 'item_recipe_sphere' }

ItemModule['item_shivas_guard']			 = { 'item_mystic_staff', 'item_platemail', 'item_recipe_shivas_guard' }

ItemModule['item_silver_edge']			 = { 'item_invis_sword', 'item_recipe_silver_edge', 'item_ultimate_orb' }

ItemModule['item_solar_crest']			 = { 'item_medallion_of_courage', 'item_wind_lace', 'item_ultimate_orb', 'item_recipe_solar_crest' }

ItemModule['item_soul_booster']			 = { 'item_point_booster', 'item_vitality_booster', 'item_energy_booster' }

ItemModule['item_soul_ring']			 = { 'item_ring_of_regen', 'item_gauntlets', 'item_gauntlets', 'item_recipe_soul_ring' }

ItemModule['item_skadi']				 = { 'item_ultimate_orb', 'item_point_booster', 'item_ultimate_orb' }

ItemModule['item_spirit_vessel']		 = { 'item_urn_of_shadows', 'item_wind_lace', 'item_vitality_booster', 'item_recipe_spirit_vessel' }

ItemModule['item_tranquil_boots']		 = { 'item_wind_lace', 'item_boots', 'item_ring_of_regen' }

ItemModule['item_travel_boots']			 = { 'item_boots', 'item_recipe_travel_boots' }

ItemModule['item_travel_boots_2']		 = { 'item_travel_boots', 'item_recipe_travel_boots' }

ItemModule['item_urn_of_shadows']		 = { 'item_circlet', 'item_ring_of_protection', 'item_infused_raindrop', 'item_recipe_urn_of_shadows' }

ItemModule['item_ultimate_scepter']		 = { 'item_point_booster', 'item_ogre_axe', 'item_blade_of_alacrity', 'item_staff_of_wizardry'  }

ItemModule['item_ultimate_scepter_2']    = { 'item_ultimate_scepter', 'item_recipe_ultimate_scepter_2' }

ItemModule['item_vanguard']				 = { 'item_stout_shield' , 'item_vitality_booster', 'item_ring_of_health' }

ItemModule['item_veil_of_discord']		 = { 'item_crown', 'item_helm_of_iron_will', 'item_recipe_veil_of_discord' }

ItemModule['item_vladmir']				 = {  'item_ring_of_basilius' , 'item_lifesteal' , 'item_recipe_vladmir' }

ItemModule['item_wraith_band']			 = { 'item_slippers', 'item_circlet', 'item_recipe_wraith_band' }

ItemModule['item_yasha']				 = { 'item_boots_of_elves', 'item_blade_of_alacrity', 'item_recipe_yasha' }

ItemModule['item_yasha_and_kaya']		 = { 'item_yasha', 'item_kaya' }

end


------------------------------------------------------------------------------------------------------
--Self-Defining ItemModule
------------------------------------------------------------------------------------------------------

if true then

ItemModule['item_double_branches']      	= { 'item_branches', 'item_branches' }

ItemModule['item_double_tango'] 			= { 'item_tango', 'item_tango',}
	
ItemModule['item_double_clarity']			= { 'item_clarity', 'item_clarity',}
	
ItemModule['item_double_flask']				= { 'item_flask', 'item_flask',}

ItemModule['item_double_enchanted_mango'] 	= { 'item_enchanted_mango', 'item_enchanted_mango',}

ItemModule['item_double_circlet'] 			= { 'item_circlet', 'item_circlet',}

ItemModule['item_double_slippers'] 			= { 'item_slippers', 'item_slippers',}

ItemModule['item_double_mantle'] 			= { 'item_mantle', 'item_mantle',}

ItemModule['item_double_gauntlets'] 		= { 'item_gauntlets', 'item_gauntlets',}

ItemModule['item_double_wraith_band'] 		= { 'item_wraith_band', 'item_wraith_band',}

ItemModule['item_double_null_talisman'] 	= { 'item_null_talisman', 'item_null_talisman',}

ItemModule['item_double_bracer'] 			= { 'item_bracer', 'item_bracer',}
	
ItemModule['item_double_crown'] 			= { 'item_crown', 'item_crown',}	

ItemModule['item_broken_urn']           	= { 'item_infused_raindrop', 'item_ring_of_protection', 'item_recipe_urn_of_shadows' }

ItemModule['item_broken_vladmir']       	= { 'item_lifesteal', 'item_recipe_vladmir' }

ItemModule['item_broken_crimson_guard'] 	= { 'item_branches', 'item_chainmail', 'item_recipe_buckler', 'item_vitality_booster', 'item_ring_of_health', 'item_recipe_crimson_guard' }

ItemModule['item_broken_octarine_core'] 	= { 'item_point_booster', 'item_vitality_booster', 'item_mystic_staff' }

ItemModule['item_broken_satanic']       	= { 'item_reaver', 'item_claymore' }

ItemModule['item_broken_mkb']           	= { 'item_javelin', 'item_demon_edge' }

ItemModule['item_six_refresher']        	= { 'item_refresher', 'item_refresher', 'item_refresher', 'item_refresher', 'item_refresher', 'item_refresher' }

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

ItemModule['item_viper_outfit']            = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn', 'item_magic_stick', 'item_recipe_magic_wand', }

ItemModule['item_sniper_outfit']           = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn', 'item_magic_stick', 'item_recipe_magic_wand', }

ItemModule['item_razor_outfit']            = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn', 'item_magic_stick', 'item_recipe_magic_wand', }

ItemModule['item_medusa_outfit']           = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn', 'item_magic_stick', 'item_recipe_magic_wand', 'item_infused_raindrop', }

ItemModule['item_nevermore_outfit']        = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn',  'item_magic_stick', 'item_recipe_magic_wand', 'item_infused_raindrop',}

ItemModule['item_templar_assassin_outfit'] = { 'item_tango', 'item_faerie_fire', 'item_double_branches', 'item_circlet', 'item_wraith_band', 'item_flask', 'item_power_treads_agi', 'item_broken_urn', 'item_magic_stick', 'item_recipe_magic_wand', 'item_blight_stone',}

ItemModule['item_luna_outfit']             = { 'item_tango', 'item_flask', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi', 'item_infused_raindrop' } 

ItemModule['item_antimage_outfit']         = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi' }

ItemModule['item_drow_ranger_outfit']      = { 'item_tango', 'item_flask', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi', 'item_infused_raindrop',}

ItemModule['item_phantom_assassin_outfit'] = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_blight_stone', 'item_recipe_magic_wand', 'item_power_treads_agi' } 

ItemModule['item_phantom_lancer_outfit']   = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi' }

ItemModule['item_bloodseeker_outfit']  	   = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi' }

ItemModule['item_arc_warden_outfit']       = { 'item_tango', 'item_flask', 'item_magic_stick', 'item_double_branches', 'item_wraith_band', 'item_recipe_magic_wand', 'item_power_treads_agi', 'item_infused_raindrop' }

ItemModule['item_sven_outfit']             = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_magic_stick', 'item_double_branches', 'item_bracer', 'item_recipe_magic_wand', 'item_phase_boots' }

ItemModule['item_chaos_knight_outfit']     = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_bracer', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_str', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_dragon_knight_outfit']    = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_str', 'item_soul_ring', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_ogre_magi_outfit']		   = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_int', 'item_hand_of_midas', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_bristleback_outfit']      = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_bracer', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_str', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_kunkka_outfit']           = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_bracer', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_str', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_skeleton_king_outfit']    = { 'item_tango', 'item_flask', 'item_stout_shield', 'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_bracer', 'item_recipe_magic_wand', 'item_ring_of_basilius', 'item_power_treads_str', 'item_broken_vladmir', 'item_broken_crimson_guard' }

ItemModule['item_silencer_outfit']         = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_circlet', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_necrolyte_outfit']        = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_circlet', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_warlock_outfit']          = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_circlet', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_jakiro_outfit']           = { 'item_tango', 'item_flask', 'item_double_branches', 'item_branches', 'item_magic_stick', 'item_crown', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_crystal_maiden_outfit']   = { 'item_tango', 'item_flask', 'item_double_branches', 'item_branches', 'item_magic_stick', 'item_crown', 'item_power_treads_int', 'item_recipe_magic_wand' }

ItemModule['item_zuus_outfit']             = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_null_talisman', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_skywrath_mage_outfit']    = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_null_talisman', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_lina_outfit']             = { 'item_tango', 'item_flask', 'item_double_branches', 'item_magic_stick', 'item_null_talisman', 'item_arcane_boots', 'item_recipe_magic_wand' }

ItemModule['item_brewmaster_outfit']       = { 'item_tango', 'item_tango', 'item_quelling_blade', 'item_gauntlets', 'item_stick_bracer', 'item_ring_of_basilius', 'item_phase_boots', 'item_broken_vladmir', 'item_mjollnir' , 'item_abyssal_blade' , 'item_black_king_bar' , 'item_lotus_orb' }

ItemModule['item_invoker_outfit']          = { 'item_tango', 'item_flask', 'item_enchanted_mango', 'item_clarity', 'item_magic_wand' , 'item_phase_boots' , 'item_urn_of_shadows', 'item_ultimate_scepter', 'item_cyclone', 'item_force_staff', 'item_sheepstick', 'item_hurricane_pike', 'item_octarine_core', 'item_shivas_guard'}

end
------------------------------------------------------------------------------------------------------

function ItemModule.IsExistInTable(u, tUnits)
	
	for _,t in pairs(tUnits) 
	do
		if u == t then return true end
	end
	
	return false
	
end 


function ItemModule.HasItem(bot, item_name)
	return bot:FindItemSlot(item_name) >= 0
end


function ItemModule.IsItemInHero(sItemName)
	
	local bot = GetBot()
	
	if ItemModule.IsExistInTable(sItemName, ItemModule['tPowerBoots']) 
	then return ItemModule.IsItemInHero('item_power_treads') end
	
	if ItemModule.IsExistInTable(sItemName, ItemModule['tConsumableList']) 
	then return bot:FindItemSlot(sItemName) >= 0 end
	
	if string.find(sItemName, 'item_double') ~= nil 
	then
		if sItemName == 'item_double_tango' 
		   or sItemName == 'item_double_flask'
		   or sItemName == 'item_double_clarity'
		   or sItemName == 'item_double_enchanted_mango'
		then return ItemModule.IsItemInHero(string.gsub(sItemName,"_double","")) end
	
		return ItemModule.GetItemCountInSolt(GetBot(),string.gsub(sItemName,"_double",""), 0, 8) >= 2
	end
	
	if string.find(sItemName, '_outfit') ~= nil 
	then
		if ItemModule.IsExistInTable(sItemName, ItemModule['tMidOutfit']) 
		then return ItemModule.IsItemInHero('item_magic_wand') end
		
		if ItemModule.IsExistInTable(sItemName, ItemModule['tCarryOutfit']) 
		then 
			return ItemModule.IsItemInHero('item_power_treads') 
			       or ItemModule.IsItemInHero('item_phase_boots') 
		end
	
		if ItemModule.IsExistInTable(sItemName, ItemModule['tCoreOutfit']) 
		then return ItemModule.IsItemInHero('item_crimson_guard') end
		
		if ItemModule.IsExistInTable(sItemName, ItemModule['tSupportOutfit']) 
		then return ItemModule.IsItemInHero('item_magic_wand') end
		
		return ItemModule.IsItemInHero('item_magic_wand') 
	end	
	
	if sItemName == 'item_broken_satanic' then return ItemModule.IsItemInHero('item_satanic') end
	
	if sItemName == 'item_ultimate_scepter_2' then return bot:HasModifier('modifier_item_ultimate_scepter_consumed') end
	
	local nItemSolt = bot:FindItemSlot(sItemName)
	
	return (nItemSolt >= 0 and nItemSolt <= 8) or nItemSolt == 15 

end


function ItemModule.GetBasicItems(sItemList)

	local bot = GetBot()
    local tBasicItem = {}  
	
    for i,v in pairs(sItemList) 
	do 
		local bRepeatedItem = ItemModule.IsItemInHero(v)		
		if bRepeatedItem == false 
		   or v == bot.sLastRepeatItem
		then		
			if ItemModule[v] ~= nil      
			then                                        
				for _,w in pairs(ItemModule.GetBasicItems(ItemModule[v])) 
				do  
					tBasicItem[#tBasicItem +1] = w
				end
			elseif ItemModule[v] == nil 
			    then
					tBasicItem[#tBasicItem +1] = v
			end
		else
			--能修复单重重复的问题
			--能修复"两个"系列重复的问题
			if ItemModule.GetItemCount(GetBot(),v) <= 1
			then
				bot.sLastRepeatItem = v
			end
		end
    end
    return tBasicItem
	
end


function ItemModule.GetMainInvLessValItemSlot(bot)
	local minPrice = 10000;
	local minSlot = -1;
	for i=0,5 do
		local item = bot:GetItemInSlot(i);
		if  item ~= nil 
			and not ItemModule.IsExistInTable(item:GetName(), ItemModule['tCanNotSwitchItems'])
		then
			local cost = GetItemCost(item:GetName()); 
			if  cost < minPrice then
				minPrice = cost;
				minSlot = i;
			end
		end
	end
	return minSlot;
end


function ItemModule.GetItemCharges(bot, item_name)
	
	local charges = 0;
	for i = 0, 15 do
		local item = bot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == item_name then
			charges = charges + item:GetCurrentCharges();
		end
	end
	return charges;
	
end


function ItemModule.GetEmptyInventoryAmount(bot)
	
	local amount = 0;
	for i=0,8 
	do	
		local item = bot:GetItemInSlot(i);
		if item == nil 
		then
			amount = amount +1;
		end
	end
	return amount;
	
end


function ItemModule.GetItemCount(unit, item_name)
	
	local count = 0;
	for i = 0, 15 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
	
end


function ItemModule.GetItemCountInSolt(unit, item_name, nSlotMin, nSlotMax)
	local count = 0;
	for i = nSlotMin, nSlotMax 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end


function ItemModule.HasBasicItem(bot)
	
	local basicItemSlot = -1 ;
	
	for i=1,#ItemModule['tBasicItems'] do
		basicItemSlot = bot:FindItemSlot(ItemModule['tBasicItems'][i]);
		if basicItemSlot >= 0 and basicItemSlot <= 5 then
			return true;
		end
	end
	
	return false;
end


function ItemModule.UpdateBuyBootStatus(bot)
	local bootsSlot = bot:FindItemSlot('item_boots');
	if bootsSlot == - 1 then
		for i=1,#ItemModule['tEarlyBoots'] do
		    bootsSlot = bot:FindItemSlot(ItemModule['tEarlyBoots'][i]);
			if bootsSlot >= 0 then
				break;
			end
		end
	end
	return bootsSlot >= 0;
end


function ItemModule.GetTheItemSolt(bot, nSlotMin, nSlotMax, bMaxCost)

	if bMaxCost 
	then
		local nMaxCost = 0;
		local idx = -1;
		for i = nSlotMin, nSlotMax 
		do
			if  bot:GetItemInSlot(i) ~= nil  
			then
				local sItem = bot:GetItemInSlot(i):GetName()
				if GetItemCost(sItem) > nMaxCost  
				then
					nMaxCost = GetItemCost(sItem)
					idx = i
				end
			end
		end
		
		return idx
	end
	
	local nMinCost = 99999;
	local idx = -1;
	for i = nSlotMin, nSlotMax 
	do
		if  bot:GetItemInSlot(i) ~= nil  
		then
			local sItem = bot:GetItemInSlot(i):GetName()
			if GetItemCost(sItem) < nMinCost  
			then
				nMinCost = GetItemCost(sItem)
				idx = i
			end
		end
	end
	
	return idx

end


return ItemModule;
-- dota2jmz@163.com QQ:2462331592