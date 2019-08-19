local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件

local BotsInit = require( "game/botsinit" );

local sAbilityList = J.Skill.GetAbilityList(bot)--获取技能列表

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

local Consider = {}

if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
    Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
    castName['Q'] = abilityQ
else
    Consider['Q'] = nil
end
if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityW) then
    Consider['W'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityW )
    castName['W'] = abilityW
else
    Consider['W'] = nil
end
if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityE) then
    Consider['E'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityE )
    castName['E'] = abilityE
else
    Consider['E'] = nil
end
if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
    Consider['D'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityD )
    castName['D'] = abilityD
else
    Consider['D'] = nil
    castName['D'] = nil
end
if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityF) and abilityF ~= 'rubick_empty2' then
    Consider['F'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityF )
    castName['F'] = abilityF
else
    Consider['F'] = nil
    castName['F'] = nil
end
if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityR) then
    Consider['R'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityR )
    castName['R'] = abilityR
else
    Consider['R'] = nil
    castName['R'] = nil
end

if BotsInit["ABATiYanMa"] ~= nil then
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityQ) then
        Consider['Q'] = require( 'game/AI锦囊/技能模组/'..abilityQ )
    end
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityW) then
        Consider['W'] = require( 'game/AI锦囊/技能模组/'..abilityW )
    end
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityE) then
        Consider['E'] = require( 'game/AI锦囊/技能模组/'..abilityE )
    end
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityD) then
        Consider['D'] = require( 'game/AI锦囊/技能模组/'..abilityD )
    end
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityF) then
        Consider['F'] = require( 'game/AI锦囊/技能模组/'..abilityF )
    end
    if xpcall(function(loadAbility) require( 'game/AI锦囊/技能模组/'..loadAbility ) end, abilityR) then
        Consider['R'] = require( 'game/AI锦囊/技能模组/'..abilityR )
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
            if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityQ) then
                Consider['Q'] = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..abilityQ )
                castName['Q'] = abilityQ
            else
                Consider['Q'] = nil
                castName['Q'] = nil
            end
            if xpcall(function(loadAbility) require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/'..loadAbility ) end, function(err) if errc(err) then print(err) end end, abilityD) and abilityD ~= 'rubick_empty1' then
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
            if (bot:GetUnitName() == 'npc_dota_hero_rubick') then print(abilityorder..castDesire[abilityorder]) end
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
    if string.find(err, 'no field package.preload') ~= nil then return false; end
    return true;
end

return X