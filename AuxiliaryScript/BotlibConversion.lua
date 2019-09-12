--英雄技能及装备处理

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件

local BotsInit = require( "game/botsinit" );

local sAbilityList = J.Skill.GetAbilityList(bot)--获取技能列表
--可用技能列表，其实不用检查的
local abilityNameList = {
    'dazzle_poison_touch',
    'dazzle_shadow_wave',
    'dazzle_shallow_grave',
    'disruptor_glimpse',
    'disruptor_kinetic_field',
    'disruptor_static_storm',
    'disruptor_thunder_strike',
    'omniknight_guardian_angel',
    'omniknight_purification',
    'omniknight_repel',
    'shadow_demon_demonic_purge',
    'shadow_demon_disruption',
    'shadow_demon_shadow_poison_release',
    'shadow_demon_shadow_poison',
    'shadow_demon_soul_catcher',
    'slardar_amplify_damage',
    'slardar_slithereen_crush',
    'slardar_sprint',
    'queenofpain_blink',
    'queenofpain_scream_of_pain',
    'queenofpain_shadow_strike',
    'queenofpain_sonic_wave',
    'abaddon_aphotic_shield',
    'abaddon_death_coil',
    'axe_battle_hunger',
    'axe_berserkers_call',
    'axe_culling_blade',
    'batrider_sticky_napalm',
    'batrider_flamebreak',
    'batrider_flaming_lasso',
    'batrider_firefly',
    'faceless_void_chronosphere',
    'faceless_void_time_dilation',
    'faceless_void_time_walk',
    'rubick_fade_bolt',
    'rubick_spell_steal',
    'rubick_telekinesis_land',
    'rubick_telekinesis',
    'centaur_double_edge',
    'centaur_hoof_stomp',
    'centaur_return',
    'centaur_stampede',
    'tidehunter_anchor_smash',
    'tidehunter_gush',
    'tidehunter_ravage',
    'leshrac_pulse_nova',
    'leshrac_lightning_storm',
    'leshrac_diabolic_edict',
    'leshrac_split_earth',
    'grimstroke_dark_artistry',
    'grimstroke_ink_creature',
    'grimstroke_scepter',
    'grimstroke_spirit_walk',
    'grimstroke_soul_chain',
    'vengefulspirit_magic_missile',
    'vengefulspirit_nether_swap',
    'vengefulspirit_wave_of_terror',
    'obsidian_destroyer_arcane_orb',
    'obsidian_destroyer_astral_imprisonment',
    'obsidian_destroyer_equilibrium',
    'obsidian_destroyer_sanity_eclipse',
    'puck_dream_coil',
    'puck_ethereal_jaunt',
    'puck_illusory_orb',
    'puck_phase_shift',
    'puck_waning_rift',
    'jakiro_dual_breath',
    'jakiro_ice_path',
    'jakiro_liquid_fire',
    'jakiro_macropyre',
    'kunkka_x_marks_the_spot',
    'kunkka_torrent',
    'kunkka_tidebringer',
    'kunkka_return',
    'kunkka_ghostship',
    'crystal_maiden_frostbite',
    'crystal_maiden_crystal_nova',
    'crystal_maiden_freezing_field',
    'bloodseeker_rupture',
    'bloodseeker_blood_bath',
    'bloodseeker_bloodrage',
    'antimage_mana_void',
    'antimage_counterspell',
    'antimage_blink',
    'sven_gods_strength',
    'sven_storm_bolt',
    'sven_warcry',
    'arc_warden_flux',
    'arc_warden_magnetic_field',
    'arc_warden_scepter',
    'arc_warden_spark_wraith',
    'arc_warden_tempest_double',
    'dragon_knight_breathe_fire',
    'dragon_knight_dragon_tail',
    'dragon_knight_elder_dragon_form',
    'drow_ranger_frost_arrows',
    'drow_ranger_trueshot',
    'drow_ranger_wave_of_silence',
    'tiny_toss',
    'tiny_avalanche',
    'tiny_craggy_exterior',
    'tiny_toss_tree',
    'tiny_tree_channel',
    'earthshaker_enchant_totem',
    'earthshaker_echo_slam',
    'earthshaker_fissure',
    'razor_eye_of_the_storm',
    'razor_plasma_field',
    'razor_static_link',
    'silencer_curse_of_the_silent',
    'silencer_glaives_of_wisdom',
    'silencer_global_silence',
    'silencer_last_word',
    'undying_tombstone',
    'undying_soul_rip',
    'undying_flesh_golem',
    'undying_decay',
    'riki_tricks_of_the_trade',
    'riki_smoke_screen',
    'riki_blink_strike',
    'phantom_assassin_stifling_dagger',
    'phantom_assassin_phantom_strike',
    'phantom_assassin_blur',
    'dark_willow_terrorize',
    'dark_willow_shadow_realm',
    'dark_willow_cursed_crown',
    'dark_willow_bramble_maze',
    'dark_willow_bedlam',
    'lich_frost_nova',
    'lich_frost_shield',
    'lich_sinister_gaze',
    'lich_chain_frost',
}

--将英雄技能初始入变量
local abilityQ = sAbilityList[1]
local abilityW = sAbilityList[2]
local abilityE = sAbilityList[3]
local abilityD = sAbilityList[4]
local abilityF = sAbilityList[5]
local abilityR = sAbilityList[6]

--初始化技能欲望与点变量
local castDesire = {
    ['Q'] = 0,
    ['W'] = 0,
    ['E'] = 0,
    ['D'] = 0,
    ['F'] = 0,
    ['R'] = 0,
}

local castTarget = {
    ['Q'] = nil,
    ['W'] = nil,
    ['E'] = nil,
    ['D'] = nil,
    ['F'] = nil,
    ['R'] = nil,
}

local castName = {
    ['Q'] = nil,
    ['W'] = nil,
    ['E'] = nil,
    ['D'] = nil,
    ['F'] = nil,
    ['R'] = nil,
}

--尝试加载技能数据
function SearchAbilityList(list, hero)
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == hero then
                return true;
            end
		end
	end
	
    return false;
end

local Consider = {}

if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
    Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
    castName['Q'] = abilityQ
else
    Consider['Q'] = nil
end
if SearchAbilityList(abilityNameList,abilityW) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityW) then
    Consider['W'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityW )
    castName['W'] = abilityW
else
    Consider['W'] = nil
end
if SearchAbilityList(abilityNameList,abilityE) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityE) then
    Consider['E'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityE )
    castName['E'] = abilityE
else
    Consider['E'] = nil
end
if SearchAbilityList(abilityNameList,abilityR) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityR) then
    Consider['R'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityR )
    castName['R'] = abilityR
else
    Consider['R'] = nil
    castName['R'] = nil
end
if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
    Consider['D'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityD )
    castName['D'] = abilityD
else
    Consider['D'] = nil
    castName['D'] = nil
end
if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) and abilityF ~= 'rubick_empty2' then
    Consider['F'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityF )
    castName['F'] = abilityF
else
    Consider['F'] = nil
    castName['F'] = nil
end

if BotsInit["ABATiYanMa"] ~= nil then
    if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
        Consider['Q'] = require( 'game/AI锦囊/技能模组/'..abilityQ )
    end
    if SearchAbilityList(abilityNameList,abilityW) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityW) then
        Consider['W'] = require( 'game/AI锦囊/技能模组/'..abilityW )
    end
    if SearchAbilityList(abilityNameList,abilityE) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityE) then
        Consider['E'] = require( 'game/AI锦囊/技能模组/'..abilityE )
    end
    if SearchAbilityList(abilityNameList,abilityR) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityR) then
        Consider['R'] = require( 'game/AI锦囊/技能模组/'..abilityR )
    end
    if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) then
        Consider['D'] = require( 'game/AI锦囊/技能模组/'..abilityD )
    end
    if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) then
        Consider['F'] = require( 'game/AI锦囊/技能模组/'..abilityF )
    end
end

-- order技能检查顺序 {q,w,e,r}
function X.Skills(order)

    if (bot:GetUnitName() == 'npc_dota_hero_rubick')
    then
        sAbilityList = J.Skill.GetAbilityList(bot)
        abilityQ = sAbilityList[1]
        abilityD = sAbilityList[4]
        abilityF = sAbilityList[5]
        if abilityQ ~= castName['Q'] or abilityD ~= castName['D'] or abilityF ~= castName['F'] then
            if SearchAbilityList(abilityNameList,abilityQ) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
                Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
                castName['Q'] = abilityQ
            else
                Consider['Q'] = nil
                castName['Q'] = nil
            end
            if SearchAbilityList(abilityNameList,abilityD) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
                Consider['D'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityD )
                castName['D'] = abilityD
            else
                Consider['D'] = nil
                castName['D'] = nil
            end
            if SearchAbilityList(abilityNameList,abilityF) and xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) and abilityF ~= 'rubick_empty2' then
                Consider['F'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityF )
                castName['F'] = abilityF
            else
                Consider['F'] = nil
                castName['F'] = nil
            end
        end
    end

    for ability,desire in pairs(Consider) do
        if desire ~= nil
        then
            castDesire[ability], castTarget[ability] = desire.Consider()
        end
    end

    for _,abilityorder in pairs(order) do
        if castDesire[abilityorder] ~= nil
           and castDesire[abilityorder] > 0 
           and Consider[abilityorder] ~= nil
        then
            local cast = castTarget[abilityorder]
            Consider[abilityorder].Release(cast)
            return true;
        end
    end

    return false;
end

--技能组合           s技能组  n欲望信息 b联合行动
function SkillsCombo(skill, consider, joint)
    local ComboConsider = nil

    if joint then

        local nArreysTeam = GetTeamMember(GetTeam());  
        local nArreysAbility = {};--所有队友（包括自己）的技能数据
        local nskillList = {};--技能组合数据

        for i,Arrey in pairs(nArreysTeam)
        do
            local heroId = Arrey:GetPlayerID()
            local heroName = GetSelectedHeroName(heroId)
            local heroAbility = J.Skill.GetAbilityList(Arrey)

            nArreysAbility[i] = {
                ['hero'] = Arrey,
                ['player'] = heroId,
                ['name'] = heroName,
                ['abilitys'] = heroAbility,
                ['bot'] = IsPlayerBot(heroId),
            }
        end

        for _,ability in pairs(skill)
        do
            local multiple = string.find(ability, ':')
            local jointHero = string.sub(ability, 1, multiple - 1)
            local jointability = string.sub(ability, multiple + 1)
            local jointabilitys = nil
            local jointbot = nil

            for _,arreyAbility in pairs(nArreysAbility)
            do
                if arreyAbility['name'] == jointHero and arreyAbility['bot'] then
                    jointabilitys = arreyAbility['abilitys']
                    jointbot = arreyAbility['hero']
                end
            end

            if jointabilitys ~= nil then
                if jointability == 'Q' then
                    jointability = jointabilitys[1]
                elseif jointability == 'W' then
                    jointability = jointabilitys[2]
                elseif jointability == 'E' then
                    jointability = jointabilitys[3]
                elseif jointability == 'D' then
                    jointability = jointabilitys[4]
                elseif jointability == 'F' then
                    jointability = jointabilitys[5]
                elseif jointability == 'R' then
                    jointability = jointabilitys[6]
                end
            end
            --jointability此时为技能名
            if jointbot ~= nil then
                nskillList[ability] = {
                    ['ability'] = jointability,--释放的技能
                    ['bot'] = jointbot--由谁来释放
                }
            end

        end
        
        --此时nskillList中包含组合释放的技能、技能释放人和技能释放顺序，如果技能释放人为玩家控制，则跳过该技能
        
        if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, consider) then
            ComboConsider = require(GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..consider)
        else
            ComboConsider = nil
        end

        if ComboConsider ~= nil then
            --欲望和释放怎么写啊%￥&*……￥
        end


    end

end

--装备组处理
function X.Combination(tGroupedDataList, tDefaultGroupedData)
    --获取随机一组数据
    if #tGroupedDataList > 0 then
        tGroupedDataList = tGroupedDataList[RandomInt(1,#tGroupedDataList)]

        --检查数据是否缺失，如果缺失则使用默认数据
        for item,datalist in pairs(tGroupedDataList) do
            if datalist == nil or #datalist == 0 then
                tGroupedDataList[item] = tDefaultGroupedData[item]
            end
        end

    else
        tGroupedDataList = tDefaultGroupedData
    end
    --处理天赋树
    tGroupedDataList['Talent'] = J.Skill.GetTalentBuild(tGroupedDataList['Talent'])
    --返回数据
    return tGroupedDataList['Ability'], tGroupedDataList['Talent'], tGroupedDataList['Buy'], tGroupedDataList['Sell']
end

function errc(err)
    return true;
end

return X