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
        if abilityQ ~= castName['Q'] or abilityD ~= castName['D'] then
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

--装备组处理
function X.Combination(tGroupedDataList, tDefaultGroupedData)
    --获取随机一组数据
    tGroupedDataList = tGroupedDataList[RandomInt(1,#tGroupedDataList)]
    --检查数据是否缺失，如果缺失则使用默认数据
    for item,datalist in pairs(tGroupedDataList) do
        if datalist == nil or #datalist == 0 then
            tGroupedDataList[item] = tDefaultGroupedData[item]
        end
    end
    --处理天赋树
    tGroupedDataList['Talent'] = J.Skill.GetTalentBuild(tGroupedDataList['Talent'])
    --返回数据
    return tGroupedDataList['Ability'], tGroupedDataList['Talent'], tGroupedDataList['Buy'], tGroupedDataList['Sell']
end

function errc(err)
    --if string.find(err, 'rubick_empty1') ~= nil then return false; end
    --if string.find(err, 'rubick_empty2') ~= nil then return false; end
    --if string.find(err, 'generic_hidden') ~= nil then return false; end
    
    return true;
end

return X