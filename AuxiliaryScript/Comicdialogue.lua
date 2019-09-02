--趣味消息

local N = {}

local nEnemysTeam = GetTeamPlayers(GetOpposingTeam());
local nArreysTeam = GetTeamPlayers(GetTeam());

local nEnemysName = {}
local nArreysName = {};

for i,Enemy in pairs( nEnemysTeam )
do
    nEnemysName[i] = GetSelectedHeroName(Enemy);
end

for i,Arrey in pairs( nArreysTeam )
do
    nArreysName[i] = GetSelectedHeroName(Arrey);
end

function IsHaveHero(Name, Enemy)
    local herolist = {}
    if Enemy then
        herolist = nEnemysName
    else
        herolist = nArreysName
    end
    for _,hero in pairs( herolist )
    do
        if hero == Name then
            return true;
        end
    end

    return false;
end

function N.ComicDialogue()
    local bot = GetBot()
    local heroName = bot:GetUnitName()
    --骷髅王
    if heroName == 'npc_dota_hero_skeleton_king' then
        --骨弓
        if IsHaveHero('npc_dota_hero_clinkz', true) then
            bot:ActionImmediate_Chat( '克林克兹，这么多年了，你还是在玩那把破弓！！', true);
            return true
        end
        --屠夫
        if IsHaveHero('npc_dota_hero_pudge', false) then
            bot:ActionImmediate_Chat( '你好啊 大肉球', true);
            return true
        end
        if IsHaveHero('npc_dota_hero_pudge', true) then
            bot:ActionImmediate_Chat( '你好啊 大肉球', true);
            return true
        end
        
    end

    --电棍
    if heroName == 'npc_dota_hero_razor' then
        --宙斯
        if IsHaveHero('npc_dota_hero_zuus', true) then
            bot:ActionImmediate_Chat( '宙斯，你掌握闪电的水平就像一只菜鸡', true);
            return true
        end
    end

    --钢背
    if heroName == 'npc_dota_hero_bristleback' then
        --骷髅王
        if IsHaveHero('npc_dota_hero_skeleton_king', true) then
            bot:ActionImmediate_Chat( '大兄弟，你等等，咱俩唠嗑唠嗑，你应该选我啊，我的活可硬了，真的，杠杠的，不信你试试，哎，大兄弟，你别跑啊', true);
            return true
        end
    end

    --宙斯
    if heroName == 'npc_dota_hero_zuus' then
        --赏金
        if IsHaveHero('npc_dota_hero_bounty_hunter', true) then
            bot:ActionImmediate_Chat( '赏金猎人，装逼遭雷劈', true);
            return true
        end
    end
    
    --猴子
    if heroName == 'npc_dota_hero_phantom_lancer' then
        --混沌
        if IsHaveHero('npc_dota_hero_chaos_knight', true) then
            bot:ActionImmediate_Chat( '混沌骑士，我们来让他们见识一下什么叫大军压境。', true);
            return true
        end
    end
    
    --火女
    if heroName == 'npc_dota_hero_lina' then
        --火女
        if IsHaveHero('npc_dota_hero_crystal_maiden', false) then
            bot:ActionImmediate_Chat( '瑞莱～～～～～', true);
            return true
        end
        if IsHaveHero('npc_dota_hero_crystal_maiden', true) then
            bot:ActionImmediate_Chat( '瑞莱～～～～～', true);
            return true
        end
    end
    
    --冰女
    if heroName == 'npc_dota_hero_crystal_maiden' then
        --火女
        if IsHaveHero('npc_dota_hero_lina', false) then
            bot:ActionImmediate_Chat( '丽娜～～～～', true);
            return true
        end
        if IsHaveHero('npc_dota_hero_lina', true) then
            bot:ActionImmediate_Chat( '丽娜～～～～', true);
            return true
        end
    end
    
    --蝙蝠
    if heroName == 'npc_dota_hero_batrider' then
        --火女
        if IsHaveHero('npc_dota_hero_crystal_maiden', true) then
            bot:ActionImmediate_Chat( '丽娜，做我的压寨夫人怎么样。', true);
            return true
        end
    end

    return nil

end

return N;