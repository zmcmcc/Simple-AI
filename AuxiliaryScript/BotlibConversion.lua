local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件

local sAbilityList = J.Skill.GetAbilityList(bot)--获取技能列表

--将英雄技能初始入变量
local abilityQ = 'ability_'..sAbilityList[1]
local abilityW = 'ability_'..sAbilityList[2]
local abilityE = 'ability_'..sAbilityList[3]
local abilityD = 'ability_'..sAbilityList[4]
local abilityF = 'ability_'..sAbilityList[5]
local abilityR = 'ability_'..sAbilityList[6]

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

local castLocation = {
    ['Q'] = nil,
    ['W'] = nil,
    ['E'] = nil,
    ['D'] = nil,
    ['F'] = nil,
    ['R'] = nil,
}

    --尝试加载技能数据
    local Consider = {}
    

-- order技能检查顺序 {q,w,e,r}
function X.Skills(order)

    if pcall(function(loadAbility) require( loadAbility ) end, abilityQ) then
        Consider['Q'] = require( abilityQ )
        print(abilityQ)
    else
        Consider['Q'] = nil
    end
    if pcall(function(loadAbility) require( loadAbility ) end, abilityW) then
        Consider['W'] = require( abilityW )
    else
        Consider['W'] = nil
    end
    if pcall(function(loadAbility) require( loadAbility ) end, abilityE) then
        Consider['E'] = require( abilityE )
    else
        Consider['E'] = nil
    end
    if pcall(function(loadAbility) require( loadAbility ) end, abilityD) then
        Consider['D'] = require( abilityD )
    else
        Consider['D'] = nil
    end
    if pcall(function(loadAbility) require( loadAbility ) end, abilityF) then
        Consider['F'] = require( abilityF )
    else
        Consider['F'] = nil
    end
    if pcall(function(loadAbility) require( loadAbility ) end, abilityR) then
        Consider['R'] = require( abilityR )
    else
        Consider['R'] = nil
    end

for ability,desire in pairs(Consider) do
    if desire ~= nil
    then
        castDesire[ability], castTarget[ability], castLocation[ability] = desire.Consider()
    end
end

    for _,abilityorder in pairs(order) do
        if castDesire[abilityorder] > 0 then
            local cast = castTarget[ability]
            if cast == nil then cast = castLocation[ability] end
            print('释放程序')
            Consider[abilityorder].Release(cast, true)
            return;
        end
    end
end

return X