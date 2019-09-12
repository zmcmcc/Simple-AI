--聊天轮盘（伪）
--由于没有api，只能让电脑发话代替轮盘，没有声音，没有语言匹配╮(╯▽╰)╭

local C = {}
local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

local countTime = 0;

local killInTime = 0;
local killCount = 0;
local dieInTime = 0;
local dieCount = 0;
local speechRestrictions = false;

local allyKills = 0;
local enemyKills = 0;

--嘲讽列表
local killMocking = {
    '你气不气？',
    '头部撞击',
    '猢狲把戏',
    '好走，不送',
    '不好意思'
}
local teamMocking = {
    '你气不气？',
    '头部撞击',
    '猢狲把戏',
    'what are you cooking？boom！'

}
local wipeMocking = {
    '人群叹息',
    '头部撞击',
    '猢狲把戏',
    '这波不亏666'
}
local horseAndHorseMocking = {
    '玩不了啦！',
    '这游戏好难玩'
}
local perishTogetherMocking = {
    '啊，队友呢?队友呢?队友呢?队友呢?',
    '头部撞击',
    'what are you cooking？boom！'
}
local warMocking = {
    '你气不气？',
    '相当精彩的比赛',
    '头部撞击',
    'what are you cooking？boom！'
}

function C.GameLive(countCD)

    if DotaTime() > countTime + countCD
    then
        --更新当前时间数据
        countTime = DotaTime();
        local nowAllyKills = J.GetNumOfTeamTotalKills(false);
        local nowEnemyKills = J.GetNumOfTeamTotalKills(true);

        --判断和发动轮盘
        if allyKills ~= nowAllyKills then

            dieInTime = DotaTime()
            dieCount = dieCount + 1
            speechRestrictions = false

        end
        if enemyKills ~= nowEnemyKills then
            
            killInTime = DotaTime()
            killCount = killCount + 1

        end

        --[[
            说明：
                以下均为死亡数小于击杀数的情况
                3秒内没有再次击杀或死亡且总计击杀数量等于1【击杀嘲讽】
                3秒内没有再次击杀或死亡且总计击杀数量大于等于3则判断为当前团战结束【团战嘲讽】
                4秒内没有再次击杀或死亡且击杀数大于等于5【团灭嘲讽】
                以下为死亡数等于击杀数的情况
                5秒没没有再次击杀或死亡且击杀数等于1【同归于尽嘲讽】
                5秒内没有再次击杀或死亡且击杀数大于等于5【大战嘲讽】
                击杀情况
                5秒内没有再次击杀或死亡且总计击杀数量大于等于3则判断为当前团战结束，死亡数大于等于3【旗鼓相当嘲讽】
        ]]

        if not speechRestrictions then
            if killCount > dieCount then
                if killCount >= 5 
                   and DotaTime() - killInTime <= 4
                then
                    speech(true, wipeMocking)
                elseif killCount >= 3 
                   and DotaTime() - killInTime <= 3
                then
                    speech(true, teamMocking)
                elseif killCount == 1 
                   and DotaTime() - killInTime <= 4
                then
                    speech(true, killMocking)
                end
                
            elseif killCount == dieCount then
                if killCount >= 5
                   and DotaTime() - killInTime <= 5
                then
                    speech(true, warMocking)
                elseif killCount == 1
                   and DotaTime() - killInTime <= 5
                then
                    speech(true, perishTogetherMocking)
                end
                
            else
                if killCount >= 3 
                   and DotaTime() - killInTime <= 5
                   and killCount <= dieCount
                   and dieCount < killCount + 1
                then
                    speech(true, horseAndHorseMocking)
                end
            end
        end

        --超过15秒清空连杀数据
        if DotaTime() - dieInTime >= 15 then
            dieCount = 0
            dieInTime = DotaTime()
        end
        if DotaTime() - killInTime >= 15 then
            killCount = 0
            killInTime = DotaTime()
        end

        --更新记录时间数据
        allyKills  = nowAllyKills;
        enemyKills = nowEnemyKills;

    end

end

function speech(team, mocking)
    local bot = GetBot()
    local text = mocking[RandomInt(1, #mocking)]
    bot:ActionImmediate_Chat(text, team)
    speechRestrictions = true

end

return C;