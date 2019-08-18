-----------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI 
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
-----------------------------------------------------------------------------
local Chat = {}
local sRawLanguage = 'sCnName'

Chat['sExpandedList'] = {
	'npc_dota_hero_antimage',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_drow_ranger',
	'npc_dota_hero_jakiro',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_luna',
	'npc_dota_hero_medusa',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_silencer',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_sniper',
	'npc_dota_hero_sven',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_viper',
	'npc_dota_hero_warlock',
	'npc_dota_hero_zuus',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_phantom_lancer',
	'npc_dota_hero_razor',
	'npc_dota_hero_lina',
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_axe',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_batrider',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_puck',
	'npc_dota_hero_centaur',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_slardar',
	'npc_dota_hero_omniknight',
}


Chat['tLanguageNameList'] = {

	[1] = {
		['sRawName'] = 'sCnName',
		['sLocalName'] = '中文',
	},
	
	[2] = {
		['sRawName'] = 'sEnName',
		['sLocalName'] = 'English',
	},
	
	[3] = {
		['sRawName'] = 'sFrName',
		['sLocalName'] = 'Français',
	},
	
	[4] = {
		['sRawName'] = 'sDeName',
		['sLocalName'] = 'Deutsch',
	},
	
	[5] = {
		['sRawName'] = 'sRuName',
		['sLocalName'] = 'русский',
	},
	
	[6] = {
		['sRawName'] = 'sJpName',
		['sLocalName'] = 'ほうぶん',
	},
	
	[7] = {
		['sRawName'] = 'sEsName',
		['sLocalName'] = 'Испанский',
	},



}


Chat['tGameWordList'] = {

	[1] = {
		['sRawName'] = true,
		['sShortName'] = 'y',
		['sCnName'] = '是',
		['sEnName'] = 'yes',
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[2] = {
		['sRawName'] = false,
		['sShortName'] = 'n',
		['sCnName'] = '否',
		['sEnName'] = 'no',
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},


	[3] = {
		['sRawName'] = 10,
		['sShortName'] = 'l',
		['sCnName'] = '左',
		['sEnName'] = 'left',
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[4] = {
		['sRawName'] = 0,
		['sShortName'] = 'r',
		['sCnName'] = '右',
		['sEnName'] = 'right',
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[5] = {
		['sRawName'] = LANE_TOP,
		['sShortName'] = 'top',
		['sCnName'] = '上路',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[6] = {
		['sRawName'] = LANE_MID,
		['sShortName'] = 'mid',
		['sCnName'] = '中路',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[7] = {
		['sRawName'] = LANE_BOT,
		['sShortName'] = 'bot',
		['sCnName'] = '下路',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
}

	
Chat['tSpWordList'] = {

	[1] = {
		['sSp1Name'] = 1,
		['sSp2Name'] = '1',
		['sCnName'] = 'game/AI锦囊/天辉锦囊/',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[2] = {
		['sSp1Name'] = 2,
		['sSp2Name'] = '2',
		['sCnName'] = 'game/AI锦囊/客场锦囊/天辉锦囊/',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},


	[3] = {
		['sSp1Name'] = 3,
		['sSp2Name'] = '3',
		['sCnName'] = 'game/AI锦囊/夜魇锦囊/',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[4] = {
		['sSp1Name'] = 4,
		['sSp2Name'] = '4',
		['sCnName'] = 'game/AI锦囊/客场锦囊/夜魇锦囊/',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[5] = {
		['sSp1Name'] = 5,
		['sSp2Name'] = '5',
		['sCnName'] = 'AI天辉阵容',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[6] = {
		['sSp1Name'] = 6,
		['sSp2Name'] = '6',
		['sCnName'] = 'AI夜魇阵容',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[7] = {
		['sSp1Name'] = 7,
		['sSp2Name'] = '',
		['sCnName'] = '运筹帷幄模式  军师:',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[8] = {
		['sSp1Name'] = 8,
		['sSp2Name'] = '',
		['sCnName'] = '运筹帷幄模式  中级军师:',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[9] = {
		['sSp1Name'] = 9,
		['sSp2Name'] = '',
		['sCnName'] = '运筹帷幄模式  高级军师:',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[10] = {
		['sSp1Name'] = 10,
		['sSp2Name'] = '',
		['sCnName'] = '运筹帷幄模式  客场军师:',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	
	[11] = {
		['sSp1Name'] = 0,
		['sSp2Name'] = '',
		['sCnName'] = '新词汇',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

}

	
Chat['tItemNameList'] = {


	[1] = {
		['sRawName'] = 'item_cyclone',
		['sShortName'] = 'itemNull',
		['sCnName'] = 'Eul的神圣法杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[2] = {
		['sRawName'] = 'item_ultimate_scepter',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿哈利姆神杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[3] = {
		['sRawName'] = 'item_ultimate_scepter_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿哈利姆神杖2',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[4] = {
		['sRawName'] = 'item_rod_of_atos',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阿托斯之棍',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[5] = {
		['sRawName'] = 'item_shadow_amulet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '暗影护符',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[6] = {
		['sRawName'] = 'item_desolator',
		['sShortName'] = 'itemNull',
		['sCnName'] = '黯灭',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[7] = {
		['sRawName'] = 'item_arcane_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '奥术鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[8] = {
		['sRawName'] = 'item_silver_edge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '白银之锋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[9] = {
		['sRawName'] = 'item_platemail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '板甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[10] = {
		['sRawName'] = 'item_javelin',
		['sShortName'] = 'itemNull',
		['sCnName'] = '标枪',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[11] = {
		['sRawName'] = 'item_crimson_guard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '赤红甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[12] = {
		['sRawName'] = 'item_orb_of_venom',
		['sShortName'] = 'itemNull',
		['sCnName'] = '淬毒之珠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[13] = {
		['sRawName'] = 'item_dagon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[14] = {
		['sRawName'] = 'item_dagon_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力2',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[15] = {
		['sRawName'] = 'item_dagon_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力3',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[16] = {
		['sRawName'] = 'item_dagon_4',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力4',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[17] = {
		['sRawName'] = 'item_dagon_5',
		['sShortName'] = 'itemNull',
		['sCnName'] = '达贡之神力5',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[18] = {
		['sRawName'] = 'item_claymore',
		['sShortName'] = 'itemNull',
		['sCnName'] = '大剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[19] = {
		['sRawName'] = 'item_greater_crit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '代达罗斯之殇',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[20] = {
		['sRawName'] = 'item_power_treads',
		['sShortName'] = 'itemNull',
		['sCnName'] = '动力鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[21] = {
		['sRawName'] = 'item_courier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '动物信使',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[22] = {
		['sRawName'] = 'item_pipe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '洞察烟斗',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[23] = {
		['sRawName'] = 'item_quarterstaff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '短棍',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[24] = {
		['sRawName'] = 'item_demon_edge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恶魔刀锋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[25] = {
		['sRawName'] = 'item_robe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '法师长袍',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[26] = {
		['sRawName'] = 'item_veil_of_discord',
		['sShortName'] = 'itemNull',
		['sCnName'] = '纷争面纱',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[27] = {
		['sRawName'] = 'item_mask_of_madness',
		['sShortName'] = 'itemNull',
		['sCnName'] = '疯狂面具',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[28] = {
		['sRawName'] = 'item_nullifier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '否决坠饰',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[29] = {
		['sRawName'] = 'item_vladmir',
		['sShortName'] = 'itemNull',
		['sCnName'] = '弗拉迪米尔的祭品',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[30] = {
		['sRawName'] = 'item_ward_sentry',
		['sShortName'] = 'itemNull',
		['sCnName'] = '岗哨守卫',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[31] = {
		['sRawName'] = 'item_blades_of_attack',
		['sShortName'] = 'itemNull',
		['sCnName'] = '攻击之爪',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[32] = {
		['sRawName'] = 'item_smoke_of_deceit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '诡计之雾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[33] = {
		['sRawName'] = 'item_black_king_bar',
		['sShortName'] = 'itemNull',
		['sCnName'] = '黑皇杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[34] = {
		['sRawName'] = 'item_butterfly',
		['sShortName'] = 'itemNull',
		['sCnName'] = '蝴蝶',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[35] = {
		['sRawName'] = 'item_bracer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '护腕',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[36] = {
		['sRawName'] = 'item_blade_of_alacrity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '欢欣之刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[37] = {
		['sRawName'] = 'item_manta',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幻影斧',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[38] = {
		['sRawName'] = 'item_headdress',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恢复头巾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[39] = {
		['sRawName'] = 'item_radiance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '辉耀',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[40] = {
		['sRawName'] = 'item_tpscroll',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回城卷轴',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[41] = {
		['sRawName'] = 'item_ring_of_health',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回复戒指',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[42] = {
		['sRawName'] = 'item_echo_sabre',
		['sShortName'] = 'itemNull',
		['sCnName'] = '回音战刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[43] = {
		['sRawName'] = 'item_kaya',
		['sShortName'] = 'itemNull',
		['sCnName'] = '慧光',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[44] = {
		['sRawName'] = 'item_yasha_and_kaya',
		['sShortName'] = 'itemNull',
		['sCnName'] = '慧夜对剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[45] = {
		['sRawName'] = 'item_vitality_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '活力之球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[46] = {
		['sRawName'] = 'item_ultimate_orb',
		['sShortName'] = 'itemNull',
		['sCnName'] = '极限法球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[47] = {
		['sRawName'] = 'item_gloves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '加速手套',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[48] = {
		['sRawName'] = 'item_pers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '坚韧球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[49] = {
		['sRawName'] = 'item_monkey_king_bar',
		['sShortName'] = 'itemNull',
		['sCnName'] = '金箍棒',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[50] = {
		['sRawName'] = 'item_boots_of_elves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精灵布带',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[51] = {
		['sRawName'] = 'item_point_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '精气之球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[52] = {
		['sRawName'] = 'item_clarity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '净化药水',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[53] = {
		['sRawName'] = 'item_diffusal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '净魂之刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[54] = {
		['sRawName'] = 'item_tranquil_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '静谧之鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[55] = {
		['sRawName'] = 'item_cloak',
		['sShortName'] = 'itemNull',
		['sCnName'] = '抗魔斗篷',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[56] = {
		['sRawName'] = 'item_null_talisman',
		['sShortName'] = 'itemNull',
		['sCnName'] = '空灵挂件',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[57] = {
		['sRawName'] = 'item_oblivion_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '空明杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[58] = {
		['sRawName'] = 'item_ring_of_tarrasque',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恐鳌之戒',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[59] = {
		['sRawName'] = 'item_heart',
		['sShortName'] = 'itemNull',
		['sCnName'] = '恐鳌之心',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[60] = {
		['sRawName'] = 'item_bfury',
		['sShortName'] = 'itemNull',
		['sCnName'] = '狂战斧',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[61] = {
		['sRawName'] = 'item_broadsword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '阔剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[62] = {
		['sRawName'] = 'item_mjollnir',
		['sShortName'] = 'itemNull',
		['sCnName'] = '雷神之锤',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[63] = {
		['sRawName'] = 'item_gauntlets',
		['sShortName'] = 'itemNull',
		['sCnName'] = '力量手套',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[64] = {
		['sRawName'] = 'item_belt_of_strength',
		['sShortName'] = 'itemNull',
		['sCnName'] = '力量腰带',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[65] = {
		['sRawName'] = 'item_sphere',
		['sShortName'] = 'itemNull',
		['sCnName'] = '林肯法球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[66] = {
		['sRawName'] = 'item_soul_ring',
		['sShortName'] = 'itemNull',
		['sCnName'] = '灵魂之戒',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[67] = {
		['sRawName'] = 'item_octarine_core',
		['sShortName'] = 'itemNull',
		['sCnName'] = '玲珑心',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[68] = {
		['sRawName'] = 'item_reaver',
		['sShortName'] = 'itemNull',
		['sCnName'] = '掠夺者之斧',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[69] = {
		['sRawName'] = 'item_hand_of_midas',
		['sShortName'] = 'itemNull',
		['sCnName'] = '迈达斯之手',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[70] = {
		['sRawName'] = 'item_mekansm',
		['sShortName'] = 'itemNull',
		['sCnName'] = '梅肯斯姆',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[71] = {
		['sRawName'] = 'item_mithril_hammer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '秘银锤',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[72] = {
		['sRawName'] = 'item_slippers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '敏捷便鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[73] = {
		['sRawName'] = 'item_magic_stick',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔棒',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[74] = {
		['sRawName'] = 'item_enchanted_mango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔法芒果',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[75] = {
		['sRawName'] = 'item_staff_of_wizardry',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔力法杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[76] = {
		['sRawName'] = 'item_dragon_lance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔龙枪',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[77] = {
		['sRawName'] = 'item_bottle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔瓶',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[78] = {
		['sRawName'] = 'item_magic_wand',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魔杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[79] = {
		['sRawName'] = 'item_armlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '莫尔迪基安的臂章',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[80] = {
		['sRawName'] = 'item_energy_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '能量之球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[81] = {
		['sRawName'] = 'item_assault',
		['sShortName'] = 'itemNull',
		['sCnName'] = '强袭胸甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[82] = {
		['sRawName'] = 'item_lotus_orb',
		['sShortName'] = 'itemNull',
		['sCnName'] = '清莲宝珠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[83] = {
		['sRawName'] = 'item_blade_mail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '刃甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[84] = {
		['sRawName'] = 'item_ancient_janggo',
		['sShortName'] = 'itemNull',
		['sCnName'] = '韧鼓',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[85] = {
		['sRawName'] = 'item_satanic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '撒旦之邪力',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[86] = {
		['sRawName'] = 'item_sange',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散华',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[87] = {
		['sRawName'] = 'item_kaya_and_sange',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散慧对剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[88] = {
		['sRawName'] = 'item_sange_and_yasha',
		['sShortName'] = 'itemNull',
		['sCnName'] = '散夜对剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[89] = {
		['sRawName'] = 'item_talisman_of_evasion',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪避护符',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[90] = {
		['sRawName'] = 'item_blink',
		['sShortName'] = 'itemNull',
		['sCnName'] = '闪烁匕首',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[91] = {
		['sRawName'] = 'item_abyssal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '深渊之刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[92] = {
		['sRawName'] = 'item_mystic_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '神秘法杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[93] = {
		['sRawName'] = 'item_rapier',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[94] = {
		['sRawName'] = 'item_holy_locket',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣洁吊坠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[95] = {
		['sRawName'] = 'item_relic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圣者遗物',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[96] = {
		['sRawName'] = 'item_ogre_axe',
		['sShortName'] = 'itemNull',
		['sCnName'] = '食人魔之斧',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[97] = {
		['sRawName'] = 'item_ring_of_protection',
		['sShortName'] = 'itemNull',
		['sCnName'] = '守护指环',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[98] = {
		['sRawName'] = 'item_tango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '树之祭祀',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[99] = {
		['sRawName'] = 'item_refresher',
		['sShortName'] = 'itemNull',
		['sCnName'] = '刷新球',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[100] = {
		['sRawName'] = 'item_lesser_crit',
		['sShortName'] = 'itemNull',
		['sCnName'] = '水晶剑',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[101] = {
		['sRawName'] = 'item_skadi',
		['sShortName'] = 'itemNull',
		['sCnName'] = '斯嘉蒂之眼',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[102] = {
		['sRawName'] = 'item_necronomicon',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[103] = {
		['sRawName'] = 'item_necronomicon_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书2',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[104] = {
		['sRawName'] = 'item_necronomicon_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '死灵书3',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[105] = {
		['sRawName'] = 'item_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '速度之靴',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[106] = {
		['sRawName'] = 'item_basher',
		['sShortName'] = 'itemNull',
		['sCnName'] = '碎颅锤',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[107] = {
		['sRawName'] = 'item_chainmail',
		['sShortName'] = 'itemNull',
		['sCnName'] = '锁子甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[108] = {
		['sRawName'] = 'item_heavens_halberd',
		['sShortName'] = 'itemNull',
		['sCnName'] = '天堂之戟',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[109] = {
		['sRawName'] = 'item_hood_of_defiance',
		['sShortName'] = 'itemNull',
		['sCnName'] = '挑战头巾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[110] = {
		['sRawName'] = 'item_branches',
		['sShortName'] = 'itemNull',
		['sCnName'] = '铁树枝干',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[111] = {
		['sRawName'] = 'item_helm_of_iron_will',
		['sShortName'] = 'itemNull',
		['sCnName'] = '铁意头盔',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[112] = {
		['sRawName'] = 'item_crown',
		['sShortName'] = 'itemNull',
		['sCnName'] = '王冠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[113] = {
		['sRawName'] = 'item_ring_of_basilius',
		['sShortName'] = 'itemNull',
		['sCnName'] = '王者之戒',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[114] = {
		['sRawName'] = 'item_glimmer_cape',
		['sShortName'] = 'itemNull',
		['sCnName'] = '微光披风',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[115] = {
		['sRawName'] = 'item_guardian_greaves',
		['sShortName'] = 'itemNull',
		['sCnName'] = '卫士胫甲',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[116] = {
		['sRawName'] = 'item_lifesteal',
		['sShortName'] = 'itemNull',
		['sCnName'] = '吸血面具',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[117] = {
		['sRawName'] = 'item_shivas_guard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '希瓦的守护',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[118] = {
		['sRawName'] = 'item_faerie_fire',
		['sShortName'] = 'itemNull',
		['sCnName'] = '仙灵之火',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[119] = {
		['sRawName'] = 'item_vanguard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '先锋盾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[120] = {
		['sRawName'] = 'item_sobi_mask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '贤者面罩',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[121] = {
		['sRawName'] = 'item_dust',
		['sShortName'] = 'itemNull',
		['sCnName'] = '显影之尘',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[122] = {
		['sRawName'] = 'item_phase_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '相位鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[123] = {
		['sRawName'] = 'item_sheepstick',
		['sShortName'] = 'itemNull',
		['sCnName'] = '邪恶镰刀',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[124] = {
		['sRawName'] = 'item_ethereal_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '虚灵之刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[125] = {
		['sRawName'] = 'item_void_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '虚无宝石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[126] = {
		['sRawName'] = 'item_buckler',
		['sShortName'] = 'itemNull',
		['sCnName'] = '玄冥盾牌',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[127] = {
		['sRawName'] = 'item_maelstrom',
		['sShortName'] = 'itemNull',
		['sCnName'] = '漩涡',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[128] = {
		['sRawName'] = 'item_bloodthorn',
		['sShortName'] = 'itemNull',
		['sCnName'] = '血棘',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[129] = {
		['sRawName'] = 'item_bloodstone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '血精石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[130] = {
		['sRawName'] = 'item_quelling_blade',
		['sShortName'] = 'itemNull',
		['sCnName'] = '压制之刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[131] = {
		['sRawName'] = 'item_solar_crest',
		['sShortName'] = 'itemNull',
		['sCnName'] = '炎阳纹章',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[132] = {
		['sRawName'] = 'item_yasha',
		['sShortName'] = 'itemNull',
		['sCnName'] = '夜叉',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[133] = {
		['sRawName'] = 'item_aether_lens',
		['sShortName'] = 'itemNull',
		['sCnName'] = '以太透镜',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[134] = {
		['sRawName'] = 'item_moon_shard',
		['sShortName'] = 'itemNull',
		['sCnName'] = '银月之晶',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[135] = {
		['sRawName'] = 'item_eagle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '鹰歌弓',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[136] = {
		['sRawName'] = 'item_invis_sword',
		['sShortName'] = 'itemNull',
		['sCnName'] = '影刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[137] = {
		['sRawName'] = 'item_urn_of_shadows',
		['sShortName'] = 'itemNull',
		['sCnName'] = '影之灵龛',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[138] = {
		['sRawName'] = 'item_aeon_disk',
		['sShortName'] = 'itemNull',
		['sCnName'] = '永恒之盘',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[139] = {
		['sRawName'] = 'item_medallion_of_courage',
		['sShortName'] = 'itemNull',
		['sCnName'] = '勇气勋章',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[140] = {
		['sRawName'] = 'item_ghost',
		['sShortName'] = 'itemNull',
		['sCnName'] = '幽魂权杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[141] = {
		['sRawName'] = 'item_force_staff',
		['sShortName'] = 'itemNull',
		['sCnName'] = '原力法杖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[142] = {
		['sRawName'] = 'item_stout_shield',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圆盾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[143] = {
		['sRawName'] = 'item_circlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '圆环',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[144] = {
		['sRawName'] = 'item_travel_boots',
		['sShortName'] = 'itemNull',
		['sCnName'] = '远行鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[145] = {
		['sRawName'] = 'item_travel_boots_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '远行鞋2',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[146] = {
		['sRawName'] = 'item_wraith_band',
		['sShortName'] = 'itemNull',
		['sCnName'] = '怨灵系带',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[147] = {
		['sRawName'] = 'item_meteor_hammer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '陨星锤',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[148] = {
		['sRawName'] = 'item_ward_observer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '侦查守卫',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[149] = {
		['sRawName'] = 'item_gem',
		['sShortName'] = 'itemNull',
		['sCnName'] = '真视宝石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[150] = {
		['sRawName'] = 'item_hyperstone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '振奋宝石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[151] = {
		['sRawName'] = 'item_soul_booster',
		['sShortName'] = 'itemNull',
		['sCnName'] = '镇魂石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[152] = {
		['sRawName'] = 'item_helm_of_the_dominator',
		['sShortName'] = 'itemNull',
		['sCnName'] = '支配头盔',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[153] = {
		['sRawName'] = 'item_flask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '治疗药膏',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[154] = {
		['sRawName'] = 'item_ring_of_health',
		['sShortName'] = 'itemNull',
		['sCnName'] = '治疗指环',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[155] = {
		['sRawName'] = 'item_mantle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '智力斗篷',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[156] = {
		['sRawName'] = 'item_orchid',
		['sShortName'] = 'itemNull',
		['sCnName'] = '紫怨',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[157] = {
		['sRawName'] = 'item_spirit_vessel',
		['sShortName'] = 'itemNull',
		['sCnName'] = '魂之灵瓮',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[158] = {
		['sRawName'] = 'item_blight_stone',
		['sShortName'] = 'itemNull',
		['sCnName'] = '枯萎之石',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[159] = {
		['sRawName'] = 'item_hurricane_pike',
		['sShortName'] = 'itemNull',
		['sCnName'] = '飓风长戟',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[160] = {
		['sRawName'] = 'item_recipe_bfury',
		['sShortName'] = 'itemNull',
		['sCnName'] = '狂战斧卷轴',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[161] = {
		['sRawName'] = 'item_broken_santic',
		['sShortName'] = 'itemNull',
		['sCnName'] = '拆疯脸转撒旦',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[162] = {
		['sRawName'] = 'item_tome_of_knowledge',
		['sShortName'] = 'itemNull',
		['sCnName'] = '知识之书',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[163] = {
		['sRawName'] = 'item_infused_raindrop',
		['sShortName'] = 'itemNull',
		['sCnName'] = '凝魂之露',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[164] = {
		['sRawName'] = 'item_wind_lace',
		['sShortName'] = 'itemNull',
		['sCnName'] = '风灵之纹',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[165] = {
		['sRawName'] = 'item_new_5',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品5',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[166] = {
		['sRawName'] = 'item_new_6',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品6',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[167] = {
		['sRawName'] = 'item_new_7',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品7',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[168] = {
		['sRawName'] = 'item_new_8',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品8',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[169] = {
		['sRawName'] = 'item_new_9',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品9',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[170] = {
		['sRawName'] = 'item_double_tango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个树之祭祀',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[171] = {
		['sRawName'] = 'item_double_clarity',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个净化药水',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[172] = {
		['sRawName'] = 'item_double_flask',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个治疗药膏',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[173] = {
		['sRawName'] = 'item_double_enchanted_mango',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个魔法芒果',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[174] = {
		['sRawName'] = 'item_double_branches',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个铁树枝干',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[175] = {
		['sRawName'] = 'item_double_circlet',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个圆环',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[176] = {
		['sRawName'] = 'item_double_stout_shield',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个圆盾',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[177] = {
		['sRawName'] = 'item_double_slippers',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个敏捷便鞋',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[178] = {
		['sRawName'] = 'item_double_mantle',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个智力斗篷',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[179] = {
		['sRawName'] = 'item_double_gauntlets',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个力量手套',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[180] = {
		['sRawName'] = 'item_double_wraith_band',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个怨灵系带',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[181] = {
		['sRawName'] = 'item_double_null_talisman',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个空灵挂件',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[182] = {
		['sRawName'] = 'item_double_bracer',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个护腕',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[183] = {
		['sRawName'] = 'item_double_crown',
		['sShortName'] = 'itemNull',
		['sCnName'] = '两个王冠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[184] = {
		['sRawName'] = 'item_new_2',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品2',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	[185] = {
		['sRawName'] = 'item_new_3',
		['sShortName'] = 'itemNull',
		['sCnName'] = '新物品3',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
}


Chat['tHeroNameList'] = {

	--001
	['npc_dota_hero_abaddon'] = {
		['sNormName'] = '死骑',
		['sShortName'] = 'loa',
		['sCnName'] = '亚巴顿',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--002
	['npc_dota_hero_alchemist'] = {
		['sNormName'] = '炼金',
		['sShortName'] = 'ga',
		['sCnName'] = '炼金术士',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},
	
	--003
	['npc_dota_hero_axe'] = {
		['sNormName'] = '斧王',
		['sShortName'] = 'axe',
		['sCnName'] = '斧王',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 2,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--004
	['npc_dota_hero_beastmaster'] = {
		['sNormName'] = '兽王',
		['sShortName'] = 'bm',
		['sCnName'] = '兽王',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--005
	['npc_dota_hero_brewmaster'] = {
		['sNormName'] = '熊猫',
		['sShortName'] = 'panda',
		['sCnName'] = '酒仙',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--006
	['npc_dota_hero_bristleback'] = {
		['sNormName'] = '钢背',
		['sShortName'] = 'bb',
		['sCnName'] = '钢背兽',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--007
	['npc_dota_hero_centaur'] = {
		['sNormName'] = '人马',
		['sShortName'] = 'cent',
		['sCnName'] = '半人马战行者',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--008
	['npc_dota_hero_chaos_knight'] = {
		['sNormName'] = '混沌',
		['sShortName'] = 'ck',
		['sCnName'] = '混沌骑士',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 2
	},
	
	--009
	['npc_dota_hero_rattletrap'] = {
		['sNormName'] = '发条',
		['sShortName'] = 'cg',
		['sCnName'] = '发条技师',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--010
	['npc_dota_hero_doom_bringer'] = {
		['sNormName'] = '末日',
		['sShortName'] = 'doom',
		['sCnName'] = '末日使者',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--011
	['npc_dota_hero_dragon_knight'] = {
		['sNormName'] = '龙骑',
		['sShortName'] = 'dk',
		['sCnName'] = '龙骑士',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--012
	['npc_dota_hero_earth_spirit'] = {
		['sNormName'] = '土猫',
		['sShortName'] = 'earthspirit',
		['sCnName'] = '大地之灵',
		['sEnName'] = 2,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--013
	['npc_dota_hero_earthshaker'] = {
		['sNormName'] = '小牛',
		['sShortName'] = 'es',
		['sCnName'] = '撼地者',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--014
	['npc_dota_hero_elder_titan'] = {
		['sNormName'] = '大牛',
		['sShortName'] = 'et',
		['sCnName'] = '上古巨神',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--015
	['npc_dota_hero_grimstroke'] = {
		['sNormName'] = '笔仙',
		['sShortName'] = 'grimstroke',
		['sCnName'] = '天涯墨客',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 3,
		['sEsName'] = 0
	},
	
	--016
	['npc_dota_hero_huskar'] = {
		['sNormName'] = '神灵',
		['sShortName'] = 'hus',
		['sCnName'] = '哈斯卡',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--017
	['npc_dota_hero_wisp'] = {
		['sNormName'] = '小精灵',
		['sShortName'] = 'wisp',
		['sCnName'] = '艾欧',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--018
	['npc_dota_hero_kunkka'] = {
		['sNormName'] = '船长',
		['sShortName'] = 'coco',
		['sCnName'] = '昆卡',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--019
	['npc_dota_hero_legion_commander'] = {
		['sNormName'] = '军团',
		['sShortName'] = 'legion',
		['sCnName'] = '军团指挥官',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--020
	['npc_dota_hero_life_stealer'] = {
		['sNormName'] = '小狗',
		['sShortName'] = 'naix',
		['sCnName'] = '噬魂鬼',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--021
	['npc_dota_hero_lycan'] = {
		['sNormName'] = '狼人',
		['sShortName'] = 'lyc',
		['sCnName'] = '狼人',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--022
	['npc_dota_hero_magnataur'] = {
		['sNormName'] = '猛犸',
		['sShortName'] = 'mag',
		['sCnName'] = '马格纳斯',
		['sEnName'] = 1,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--023
	['npc_dota_hero_night_stalker'] = {
		['sNormName'] = '夜魔',
		['sShortName'] = 'ns',
		['sCnName'] = '暗夜魔王',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--024
	['npc_dota_hero_omniknight'] = {
		['sNormName'] = '全能',
		['sShortName'] = 'ok',
		['sCnName'] = '全能骑士',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--025
	['npc_dota_hero_phoenix'] = {
		['sNormName'] = '凤凰',
		['sShortName'] = 'pho',
		['sCnName'] = '凤凰',
		['sEnName'] = 2,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--026
	['npc_dota_hero_pudge'] = {
		['sNormName'] = '屠夫',
		['sShortName'] = 'pudge',
		['sCnName'] = '帕吉',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--027
	['npc_dota_hero_sand_king'] = {
		['sNormName'] = '沙王',
		['sShortName'] = 'sk',
		['sCnName'] = '沙王',
		['sEnName'] = 2,
		['sFrName'] = 3,
		['sDeName'] = 1,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--028
	['npc_dota_hero_slardar'] = {
		['sNormName'] = '大鱼',
		['sShortName'] = 'sg',
		['sCnName'] = '斯拉达',
		['sEnName'] = 1,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--029
	['npc_dota_hero_spirit_breaker'] = {
		['sNormName'] = '白牛',
		['sShortName'] = 'sb',
		['sCnName'] = '裂魂人',
		['sEnName'] = 1,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--030
	['npc_dota_hero_sven'] = {
		['sNormName'] = '流浪',
		['sShortName'] = 'sv',
		['sCnName'] = '斯温',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--031
	['npc_dota_hero_tidehunter'] = {
		['sNormName'] = '潮汐',
		['sShortName'] = 'th',
		['sCnName'] = '潮汐猎人',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--032
	['npc_dota_hero_shredder'] = {
		['sNormName'] = '伐木机',
		['sShortName'] = 'gs',
		['sCnName'] = '伐木机',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--033
	['npc_dota_hero_tiny'] = {
		['sNormName'] = '山岭',
		['sShortName'] = 'tiny',
		['sCnName'] = '小小',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--034
	['npc_dota_hero_treant'] = {
		['sNormName'] = '大树',
		['sShortName'] = 'tp',
		['sCnName'] = '树精卫士',
		['sEnName'] = 1,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--035
	['npc_dota_hero_tusk'] = {
		['sNormName'] = '海民',
		['sShortName'] = 'tusk',
		['sCnName'] = '巨牙海民',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--036
	['npc_dota_hero_abyssal_underlord'] = {
		['sNormName'] = '大屁股',
		['sShortName'] = 'au',
		['sCnName'] = '孽主',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--037
	['npc_dota_hero_undying'] = {
		['sNormName'] = '尸王',
		['sShortName'] = 'ud',
		['sCnName'] = '不朽尸王',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--038
	['npc_dota_hero_skeleton_king'] = {
		['sNormName'] = '骷髅王',
		['sShortName'] = 'snk',
		['sCnName'] = '冥魂大帝',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--039
	['npc_dota_hero_antimage'] = {
		['sNormName'] = '敌法',
		['sShortName'] = 'am',
		['sCnName'] = '敌法师',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--040
	['npc_dota_hero_arc_warden'] = {
		['sNormName'] = '弧光',
		['sShortName'] = 'arc',
		['sCnName'] = '天穹守望者',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--041
	['npc_dota_hero_bloodseeker'] = {
		['sNormName'] = '血魔',
		['sShortName'] = 'bs',
		['sCnName'] = '血魔',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 1,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--042
	['npc_dota_hero_bounty_hunter'] = {
		['sNormName'] = '赏金',
		['sShortName'] = 'bh',
		['sCnName'] = '赏金猎人',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--043
	['npc_dota_hero_broodmother'] = {
		['sNormName'] = '蜘蛛',
		['sShortName'] = 'br',
		['sCnName'] = '育母蜘蛛',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--044
	['npc_dota_hero_clinkz'] = {
		['sNormName'] = '小骷髅',
		['sShortName'] = 'bone',
		['sCnName'] = '克林克兹',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--045
	['npc_dota_dark_willow'] = {
		['sNormName'] = '小仙女',
		['sShortName'] = 'dw',
		['sCnName'] = '邪影芳灵',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--046
	['npc_dota_hero_drow_ranger'] = {
		['sNormName'] = '小黑',
		['sShortName'] = 'dr',
		['sCnName'] = '卓尔游侠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--047
	['npc_dota_hero_ember_spirit'] = {
		['sNormName'] = '火猫',
		['sShortName'] = 'ember',
		['sCnName'] = '灰烬之灵',
		['sEnName'] = 3,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--048
	['npc_dota_hero_faceless_void'] = {
		['sNormName'] = '虚空',
		['sShortName'] = 'fv',
		['sCnName'] = '虚空假面',
		['sEnName'] = 1,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--049
	['npc_dota_hero_gyrocopter'] = {
		['sNormName'] = '飞机',
		['sShortName'] = 'av',
		['sCnName'] = '矮人直升机',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--050
	['npc_dota_hero_juggernaut'] = {
		['sNormName'] = '剑圣',
		['sShortName'] = 'jugg',
		['sCnName'] = '主宰',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--051
	['npc_dota_hero_lone_druid'] = {
		['sNormName'] = '熊德',
		['sShortName'] = 'ld',
		['sCnName'] = '德鲁伊',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--052
	['npc_dota_hero_luna'] = {
		['sNormName'] = '月骑',
		['sShortName'] = 'luna',
		['sCnName'] = '露娜',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--053
	['npc_dota_hero_medusa'] = {
		['sNormName'] = '一姐',
		['sShortName'] = 'med',
		['sCnName'] = '美杜莎',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--054
	['npc_dota_hero_meepo'] = {
		['sNormName'] = '狗头',
		['sShortName'] = 'meepo',
		['sCnName'] = '米波',
		['sEnName'] = 2,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--055
	['npc_dota_hero_mirana'] = {
		['sNormName'] = '白虎',
		['sShortName'] = 'pom',
		['sCnName'] = '米拉娜',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--056
	['npc_dota_hero_monkey_king'] = {
		['sNormName'] = '大圣',
		['sShortName'] = 'monkey',
		['sCnName'] = '齐天大圣',
		['sEnName'] = 2,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--057
	['npc_dota_hero_morphling'] = {
		['sNormName'] = '水人',
		['sShortName'] = 'mor',
		['sCnName'] = '变体精灵',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--058
	['npc_dota_hero_naga_siren'] = {
		['sNormName'] = '小娜迦',
		['sShortName'] = 'naga',
		['sCnName'] = '娜迦海妖',
		['sEnName'] = 1,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 1,
		['sEsName'] = 2
	},

	--059
	['npc_dota_hero_nyx_assassin'] = {
		['sNormName'] = '小强',
		['sShortName'] = 'na',
		['sCnName'] = '司夜刺客',
		['sEnName'] = 1,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--060
	['npc_dota_hero_phantom_assassin'] = {
		['sNormName'] = '幻刺',
		['sShortName'] = 'pa',
		['sCnName'] = '幻影刺客',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--061
	['npc_dota_hero_phantom_lancer'] = {
		['sNormName'] = '猴子',
		['sShortName'] = 'pl',
		['sCnName'] = '幻影长矛手',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--062
	['npc_dota_hero_razor'] = {
		['sNormName'] = '电棍',
		['sShortName'] = 'razor',
		['sCnName'] = '剃刀',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--063
	['npc_dota_hero_riki'] = {
		['sNormName'] = '隐刺',
		['sShortName'] = 'sa',
		['sCnName'] = '力丸',
		['sEnName'] = 2,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--064
	['npc_dota_hero_nevermore'] = {
		['sNormName'] = '影魔',
		['sShortName'] = 'sf',
		['sCnName'] = '影魔',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--065
	['npc_dota_hero_slark'] = {
		['sNormName'] = '小鱼',
		['sShortName'] = 'nc',
		['sCnName'] = '斯拉克',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--066
	['npc_dota_hero_sniper'] = {
		['sNormName'] = '火枪',
		['sShortName'] = 'sniper',
		['sCnName'] = '狙击手',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--067
	['npc_dota_hero_spectre'] = {
		['sNormName'] = '幽鬼',
		['sShortName'] = 'spe',
		['sCnName'] = '幽鬼',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--068
	['npc_dota_hero_templar_assassin'] = {
		['sNormName'] = '圣堂',
		['sShortName'] = 'ta',
		['sCnName'] = '圣堂刺客',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--069
	['npc_dota_hero_terrorblade'] = {
		['sNormName'] = '魂守',
		['sShortName'] = 'tb',
		['sCnName'] = '恐怖利刃',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--070
	['npc_dota_hero_troll_warlord'] = {
		['sNormName'] = '巨魔',
		['sShortName'] = 'tw',
		['sCnName'] = '巨魔战将',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--071
	['npc_dota_hero_ursa'] = {
		['sNormName'] = '拍拍',
		['sShortName'] = 'ursa',
		['sCnName'] = '熊战士',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--072
	['npc_dota_hero_vengefulspirit'] = {
		['sNormName'] = '复仇',
		['sShortName'] = 'vs',
		['sCnName'] = '复仇之魂',
		['sEnName'] = 1,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--073
	['npc_dota_hero_venomancer'] = {
		['sNormName'] = '剧毒',
		['sShortName'] = 'veno',
		['sCnName'] = '剧毒术士',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--074
	['npc_dota_hero_viper'] = {
		['sNormName'] = '毒龙',
		['sShortName'] = 'vip',
		['sCnName'] = '冥界亚龙',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--075
	['npc_dota_hero_weaver'] = {
		['sNormName'] = '蚂蚁',
		['sShortName'] = 'nw',
		['sCnName'] = '编织者',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--076
	['npc_dota_hero_ancient_apparition'] = {
		['sNormName'] = '冰魂',
		['sShortName'] = 'aa',
		['sCnName'] = '远古冰魄',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--077
	['npc_dota_hero_bane'] = {
		['sNormName'] = '祸乱',
		['sShortName'] = 'bane',
		['sCnName'] = '祸乱之源',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--078
	['npc_dota_hero_batrider'] = {
		['sNormName'] = '蝙蝠',
		['sShortName'] = 'bat',
		['sCnName'] = '蝙蝠骑士',
		['sEnName'] = 1,
		['sFrName'] = 3,
		['sDeName'] = 2,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--079
	['npc_dota_hero_chen'] = {
		['sNormName'] = '陈',
		['sShortName'] = 'chen',
		['sCnName'] = '陈',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 3,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--080
	['npc_dota_hero_crystal_maiden'] = {
		['sNormName'] = '冰女',
		['sShortName'] = 'cm',
		['sCnName'] = '水晶室女',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 2,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--081
	['npc_dota_hero_dark_seer'] = {
		['sNormName'] = '兔子',
		['sShortName'] = 'ds',
		['sCnName'] = '黑暗贤者',
		['sEnName'] = 1,
		['sFrName'] = 1,
		['sDeName'] = 1,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--082
	['npc_dota_hero_dazzle'] = {
		['sNormName'] = '暗牧',
		['sShortName'] = 'sp',
		['sCnName'] = '戴泽',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--083
	['npc_dota_hero_death_prophet'] = {
		['sNormName'] = 'DP',
		['sShortName'] = 'DP',
		['sCnName'] = '死亡先知',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--084
	['npc_dota_hero_disruptor'] = {
		['sNormName'] = '萨尔',
		['sShortName'] = 'thrall',
		['sCnName'] = '干扰者',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--085
	['npc_dota_hero_enchantress'] = {
		['sNormName'] = '小鹿',
		['sShortName'] = 'eh',
		['sCnName'] = '魅惑魔女',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 3,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--086
	['npc_dota_hero_enigma'] = {
		['sNormName'] = '谜团',
		['sShortName'] = 'em',
		['sCnName'] = '谜团',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 3,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--087
	['npc_dota_hero_invoker'] = {
		['sNormName'] = '卡尔',
		['sShortName'] = 'invoker',
		['sCnName'] = '祈求者',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 1
	},

	--088
	['npc_dota_hero_jakiro'] = {
		['sNormName'] = '双头龙',
		['sShortName'] = 'thd',
		['sCnName'] = '杰奇洛',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 1,
		['sEsName'] = 2
	},

	--089
	['npc_dota_hero_keeper_of_the_light'] = {
		['sNormName'] = '光法',
		['sShortName'] = 'kotl',
		['sCnName'] = '光之守卫',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 1,
		['sRuName'] = 2,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--090
	['npc_dota_hero_leshrac'] = {
		['sNormName'] = '老鹿',
		['sShortName'] = 'TS',
		['sCnName'] = '拉席克',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 1,
		['sEsName'] = 3
	},

	--091
	['npc_dota_hero_lich'] = {
		['sNormName'] = '巫妖',
		['sShortName'] = 'lich',
		['sCnName'] = '巫妖',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--092
	['npc_dota_hero_lina'] = {
		['sNormName'] = '火女',
		['sShortName'] = 'lina',
		['sCnName'] = '莉娜',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--093
	['npc_dota_hero_lion'] = {
		['sNormName'] = '莱恩',
		['sShortName'] = 'lion',
		['sCnName'] = '莱恩',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--094
	['npc_dota_hero_furion'] = {
		['sNormName'] = '先知',
		['sShortName'] = 'fur',
		['sCnName'] = '先知',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 3,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--095
	['npc_dota_hero_necrolyte'] = {
		['sNormName'] = '死灵法',
		['sShortName'] = 'nec',
		['sCnName'] = '瘟疫法师',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--096
	['npc_dota_hero_ogre_magi'] = {
		['sNormName'] = '蓝胖',
		['sShortName'] = 'om',
		['sCnName'] = '食人魔魔法师',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--097
	['npc_dota_hero_oracle'] = {
		['sNormName'] = '神谕',
		['sShortName'] = 'oracle',
		['sCnName'] = '神谕者',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--098
	['npc_dota_hero_obsidian_destroyer'] = {
		['sNormName'] = '黑鸟',
		['sShortName'] = 'od',
		['sCnName'] = '殁境神蚀者',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--099
	['npc_dota_hero_pangolier'] = {
		['sNormName'] = '滚滚',
		['sShortName'] = 'pangolier',
		['sCnName'] = '石鳞剑士',
		['sEnName'] = 1,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 0,
		['sEsName'] = 0
	},
	
	--100
	['npc_dota_hero_puck'] = {
		['sNormName'] = '精灵龙',
		['sShortName'] = 'puck',
		['sCnName'] = '帕克',
		['sEnName'] = 3,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--101
	['npc_dota_hero_pugna'] = {
		['sNormName'] = '骨法',
		['sShortName'] = 'pugna',
		['sCnName'] = '帕格纳',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--102
	['npc_dota_hero_queenofpain'] = {
		['sNormName'] = '女王',
		['sShortName'] = 'qop',
		['sCnName'] = '痛苦女王',
		['sEnName'] = 3,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--103
	['npc_dota_hero_rubick'] = {
		['sNormName'] = '拉比克',
		['sShortName'] = 'rubick',
		['sCnName'] = '拉比克',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--104
	['npc_dota_hero_shadow_demon'] = {
		['sNormName'] = '毒狗',
		['sShortName'] = 'sd',
		['sCnName'] = '暗影恶魔',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--105
	['npc_dota_hero_shadow_shaman'] = {
		['sNormName'] = '小Y',
		['sShortName'] = 'ss',
		['sCnName'] = '暗影萨满',
		['sEnName'] = 0,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 3
	},

	--106
	['npc_dota_hero_silencer'] = {
		['sNormName'] = '沉默',
		['sShortName'] = 'sil',
		['sCnName'] = '沉默术士',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--107
	['npc_dota_hero_skywrath_mage'] = {
		['sNormName'] = '天怒',
		['sShortName'] = 'sm',
		['sCnName'] = '天怒法师',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--108
	['npc_dota_hero_storm_spirit'] = {
		['sNormName'] = '蓝猫',
		['sShortName'] = 'st',
		['sCnName'] = '风暴之灵',
		['sEnName'] = 3,
		['sFrName'] = 1,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--109
	['npc_dota_hero_techies'] = {
		['sNormName'] = '炸弹人',
		['sShortName'] = 'techies',
		['sCnName'] = '工程师',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--110
	['npc_dota_hero_tinker'] = {
		['sNormName'] = 'tk',
		['sShortName'] = 'tk',
		['sCnName'] = '修补匠',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 2
	},

	--111
	['npc_dota_hero_visage'] = {
		['sNormName'] = '死灵龙',
		['sShortName'] = 'vis',
		['sCnName'] = '维萨吉',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 1,
		['sEsName'] = 1
	},

	--112
	['npc_dota_hero_warlock'] = {
		['sNormName'] = '术士',
		['sShortName'] = 'wlk',
		['sCnName'] = '术士',
		['sEnName'] = 0,
		['sFrName'] = 2,
		['sDeName'] = 0,
		['sRuName'] = 0,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--113
	['npc_dota_hero_windrunner'] = {
		['sNormName'] = '风行',
		['sShortName'] = 'wr',
		['sCnName'] = '风行者',
		['sEnName'] = 1,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 1,
		['sEsName'] = 0
	},

	--114
	['npc_dota_hero_winter_wyvern'] = {
		['sNormName'] = '冰龙',
		['sShortName'] = 'ww',
		['sCnName'] = '寒冬飞龙',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 3,
		['sEsName'] = 0
	},

	--115
	['npc_dota_hero_witch_doctor'] = {
		['sNormName'] = '巫医',
		['sShortName'] = 'wd',
		['sCnName'] = '巫医',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 2,
		['sJpName'] = 3,
		['sEsName'] = 0
	},
	
	--116
	['npc_dota_hero_mars'] = {
		['sNormName'] = '马尔斯',
		['sShortName'] = 'mars',
		['sCnName'] = '马尔斯',
		['sEnName'] = 0,
		['sFrName'] = 3,
		['sDeName'] = 0,
		['sRuName'] = 1,
		['sJpName'] = 0,
		['sEsName'] = 0
	},

	--117
	['npc_dota_hero_zuus'] = {
		['sNormName'] = '宙斯',
		['sShortName'] = 'zeus',
		['sCnName'] = '宙斯',
		['sEnName'] = 0,
		['sFrName'] = 0,
		['sDeName'] = 0,
		['sRuName'] = 3,
		['sJpName'] = 0,
		['sEsName'] = 0
	}
}


function Chat.GetRawLanguge(sName)

	for _,t in pairs(Chat['tLanguageNameList'])
	do
		if t['sLocalName'] == sName
		then
			return t['sRawName']
		end	
	end
	
	return 'sCnName'

end

function Chat.SetRawLanguage(sName)

	--sRawLanguage = Chat.GetRawLanguge(sName)

end

function Chat.GetEnName(npcBot)

	local sHeroName = string.gsub(string.sub(npcBot:GetUnitName(), 15),'_','')

	return sHeroName
	
end

--本地英雄名
function Chat.GetLocalName(npcBot)
	
	local tBotName = Chat['tHeroNameList'][npcBot:GetUnitName()]
	
	if tBotName ~= nil
	then
		return tBotName[sRawLanguage]
	end
	
end

--简化中文名
function Chat.GetNormName(npcBot)

	
	local tBotName = Chat['tHeroNameList'][npcBot:GetUnitName()]
	
	return tBotName ~= nil and tBotName['sNormName'] or '大神' 
	
end

--由本地名获得英雄代码名
function Chat.GetRawHeroName(sName)
	
	for _,s in pairs(Chat['sExpandedList'])
	do
		local sTempCnName = Chat['tHeroNameList'][s][sRawLanguage]
		if sTempCnName == sName
		then
			return s
		end	
	end
	
	return 'npc_dota_hero_crystal_maiden'  --如果是重复或未拓展的英雄,则返回冰女
	
end


--由本地名获得装备代码名
function Chat.GetRawItemName(sName)
	
	for _,t in pairs(Chat['tItemNameList'])
	do
		if t[sRawLanguage] == sName
		then
			return t['sRawName']
		end	
	end
	
	return 'item_flask'  --如果是错误物品,则改为治疗药膏
	
end


--由本地名获得游戏词汇代码名
function Chat.GetRawGameWord(sName)
	
	for _,t in pairs(Chat['tGameWordList'])
	do
		if t[sRawLanguage] == sName
		then
			return t['sRawName']
		end	
	end
	
	return nil  --如果是错误词汇
	
end


--选人列表
function Chat.GetHeroSelectList(nLocalList)

	local sTargetList = {}
	
	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawHeroName(nLocalList[i])
		sTargetList[#sTargetList + 1] = tempName
	end
	
	return sTargetList

end


--分路列表
function Chat.GetLaneAssignList(nLocalList)

	
	local sTargetList = {}
	
	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawGameWord(nLocalList[i])
		sTargetList[#sTargetList +1] = tempName
	end
	
	return sTargetList

end


--天赋列表
function Chat.GetTalentBuildList(nLocalList)

	local sTargetList = {}
	
	for i = 1, #nLocalList
    do
		local rawTalent = Chat.GetRawGameWord(nLocalList[i])
		if rawTalent == 10 
		then
			sTargetList[#sTargetList +1] = i *2
		else
			sTargetList[#sTargetList +1] = i *2 -1
		end
	end
	
	return sTargetList

end


--物品构成表
function Chat.GetItemBuildList(nLocalList)

	local sTargetList = {}
	
	for i = 1, #nLocalList
    do
		local tempName = Chat.GetRawItemName(nLocalList[i])
		sTargetList[#sTargetList + 1] = tempName
	end
	
	return sTargetList

end


--本地英雄策略路径名
function Chat.GetHeroDirName(npcBot, nType)
	
	local sString = Chat['tSpWordList'][nType][sRawLanguage]
	
	return sString..Chat.GetLocalName(npcBot,sLanguage)	

end


--本地游戏词语名
function Chat.GetLocalWord(nType)
	
	local sString = Chat['tSpWordList'][nType][sRawLanguage]
	
	return sString	

end


return Chat

--[[
Eul的神圣法杖  item_cyclone  item_recipe_cyclone  
阿哈利姆神杖1  item_ultimate_scepter  item_recipe_ultimate_scepter  
阿哈利姆神杖2  item_ultimate_scepter_2
阿托斯之棍  item_rod_of_atos  item_recipe_rod_of_atos  
暗影护符  item_shadow_amulet  
黯灭  item_desolator  item_recipe_desolator  
奥术鞋  item_arcane_boots  item_recipe_arcane_boots  
白银之锋  item_silver_edge  item_recipe_silver_edge  
板甲  item_platemail  
标枪  item_javelin  
赤红甲  item_crimson_guard  item_recipe_crimson_guard  
淬毒之珠  item_orb_of_venom  
达贡之神力  item_dagon  item_recipe_dagon  
达贡之神力2
达贡之神力3
达贡之神力4
达贡之神力5
大剑  item_claymore  
代达罗斯之殇  item_greater_crit  item_recipe_greater_crit  
动力鞋  item_power_treads  item_recipe_power_treads  
动物信使  item_courier  
洞察烟斗  item_pipe  item_recipe_pipe  
短棍  item_quarterstaff  
恶魔刀锋  item_demon_edge  
法师长袍  item_robe  
纷争面纱  item_veil_of_discord  item_recipe_veil_of_discord  
疯狂面具  item_mask_of_madness  item_recipe_mask_of_madness  
否决坠饰  item_nullifier
弗拉迪米尔的祭品  item_vladmir  item_recipe_vladmir  
岗哨守卫  item_ward_sentry  
攻击之爪  item_blades_of_attack  
诡计之雾  item_smoke_of_deceit  
黑皇杖  item_black_king_bar  item_recipe_black_king_bar  
蝴蝶  item_butterfly  item_recipe_butterfly  
护腕  item_bracer  item_recipe_bracer  
欢欣之刃  item_blade_of_alacrity  
幻影斧  item_manta  item_recipe_manta  
恢复头巾  item_headdress  item_recipe_headdress  
辉耀  item_radiance  item_recipe_radiance  
回城卷轴  item_tpscroll  
回复戒指  item_ring_of_regen  
回音战刃  item_echo_sabre
慧光  item_kaya
慧夜对剑 item_yasha_and_kaya
活力之球  item_vitality_booster  
极限法球  item_ultimate_orb  
加速手套  item_gloves  
坚韧球  item_pers  item_recipe_pers  
金箍棒  item_monkey_king_bar  item_recipe_monkey_king_bar  
精灵布带  item_boots_of_elves  
精气之球  item_point_booster  
净化药水  item_clarity  
净魂之刃  item_diffusal_blade  item_recipe_diffusal_blade  
静谧之鞋  item_tranquil_boots  item_recipe_tranquil_boots  
抗魔斗篷  item_cloak  
空灵挂件  item_null_talisman  item_recipe_null_talisman  
空明杖  item_oblivion_staff  item_recipe_oblivion_staff  
恐鳌之戒 item_ring_of_tarrasque
恐鳌之心  item_heart  item_recipe_heart  
狂战斧  item_bfury  item_recipe_bfury  
阔剑  item_broadsword  
雷神之锤  item_mjollnir  item_recipe_mjollnir  
力量手套  item_gauntlets  
力量腰带  item_belt_of_strength  
林肯法球  item_sphere  item_recipe_sphere  
灵魂之戒  item_soul_ring  item_recipe_soul_ring  
玲珑心  item_octarine_core  item_recipe_octarine_core  
掠夺者之斧  item_reaver  
迈达斯之手  item_hand_of_midas  item_recipe_hand_of_midas  
梅肯斯姆  item_mekansm  item_recipe_mekansm  
秘银锤  item_mithril_hammer  
敏捷便鞋  item_slippers  
魔棒  item_magic_stick  
魔法芒果  item_enchanted_mango  
魔力法杖  item_staff_of_wizardry  
魔龙枪  item_dragon_lance  item_recipe_dragon_lance  
魔瓶  item_bottle  
魔杖  item_magic_wand  item_recipe_magic_wand  
莫尔迪基安的臂章  item_armlet  item_recipe_armlet  
能量之球  item_energy_booster  
强袭胸甲  item_assault  item_recipe_assault  
清莲宝珠  item_lotus_orb  item_recipe_lotus_orb  
刃甲  item_blade_mail  item_recipe_blade_mail  
韧鼓  item_ancient_janggo  item_recipe_ancient_janggo  
撒旦之邪力  item_satanic  item_recipe_satanic  
散华  item_sange  item_recipe_sange  
散慧对剑  item_kaya_and_sange
散夜对剑  item_sange_and_yasha  item_recipe_sange_and_yasha  
闪避护符  item_talisman_of_evasion  
闪烁匕首  item_blink  
深渊之刃  item_abyssal_blade  item_recipe_abyssal_blade  
神秘法杖  item_mystic_staff  
圣剑  item_rapier  item_recipe_rapier  
圣洁吊坠  item_holy_locket
圣者遗物  item_relic  
食人魔之斧  item_ogre_axe  
守护指环  item_ring_of_protection  
树之祭祀  item_tango  
刷新球  item_refresher  item_recipe_refresher  
水晶剑  item_lesser_crit  item_recipe_lesser_crit  
斯嘉蒂之眼  item_skadi  item_recipe_skadi  
死灵书  item_necronomicon  item_recipe_necronomicon  
死灵书2 item_necronomicon_2
死灵书3 item_necronomicon_3
速度之靴  item_boots  
碎颅锤  item_basher  item_recipe_basher  
锁子甲  item_chainmail  
天堂之戟  item_heavens_halberd  item_recipe_heavens_halberd  
挑战头巾  item_hood_of_defiance  item_recipe_hood_of_defiance  
铁树枝干  item_branches  
铁意头盔  item_helm_of_iron_will  
王冠  item_crown
王者之戒  item_ring_of_basilius  item_recipe_ring_of_basilius  
微光披风  item_glimmer_cape  item_recipe_glimmer_cape  
卫士胫甲  item_guardian_greaves  item_recipe_guardian_greaves  
吸血面具  item_lifesteal  
希瓦的守护  item_shivas_guard  item_recipe_shivas_guard  
仙灵之火  item_faerie_fire  
先锋盾  item_vanguard  item_recipe_vanguard  
贤者面罩  item_sobi_mask  
显影之尘  item_dust  
相位鞋  item_phase_boots  item_recipe_phase_boots  
邪恶镰刀  item_sheepstick  item_recipe_sheepstick  
虚灵之刃  item_ethereal_blade  item_recipe_ethereal_blade  
虚无宝石  item_void_stone   
玄冥盾牌  item_buckler  item_recipe_buckler  
漩涡  item_maelstrom  item_recipe_maelstrom  
血棘  item_bloodthorn
血精石  item_bloodstone  item_recipe_bloodstone  
压制之刃  item_quelling_blade  
炎阳纹章  item_solar_crest  item_recipe_solar_crest  
夜叉  item_yasha  item_recipe_yasha  
以太透镜  item_aether_lens  item_recipe_aether_lens  
银月之晶  item_moon_shard  item_recipe_moon_shard  
鹰歌弓  item_eagle  
影刃  item_invis_sword  item_recipe_invis_sword  
影之灵龛  item_urn_of_shadows  item_recipe_urn_of_shadows  
永恒之盘  item_aeon_disk
勇气勋章  item_medallion_of_courage  item_recipe_medallion_of_courage  
幽魂权杖  item_ghost  
原力法杖  item_force_staff  item_recipe_force_staff  
圆盾  item_stout_shield  
圆环  item_circlet  
远行鞋  item_travel_boots
远行鞋2  item_travel_boots_2  item_recipe_travel_boots  
怨灵系带  item_wraith_band  item_recipe_wraith_band  
陨星锤  item_meteor_hammer
侦查守卫  item_ward_observer  
真视宝石  item_gem  
振奋宝石  item_hyperstone  
镇魂石  item_soul_booster  item_recipe_soul_booster  
支配头盔  item_helm_of_the_dominator  item_recipe_helm_of_the_dominator  
治疗药膏  item_flask  
治疗指环  item_ring_of_health  
智力斗篷  item_mantle  
紫怨  item_orchid  item_recipe_orchid  
知识之书 item_tome_of_knowledge
魂之灵瓮 item_spirit_vessel 
凝魂之露 item_infused_raindrop
风灵之纹 item_wind_lace

--]]