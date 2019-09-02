--额外通用功能

local U = {}

local bot, nLV, nMP, nHP
--初始化
function U.init(LV, MP, HP, BOT)
    nLV = LV
    nMP = MP
    nHP = HP
    bot = BOT
end

--是否应当节省蓝量
function U.ShouldSaveMana(nAbility)

	if  nLV >= 6
		and ( bot:GetMana() - nAbility:GetManaCost() < nAbility:GetManaCost() * 2)
	then
		return true;
	end
	
	return false;
end
--检查英雄是否在列表中
function U.SearchHeroList(list,hero)
    if next(list) ~= nil then
        for _,value in pairs(list) do
            if value == hero:GetUnitName() then
                return true;
            end
		end
	end
	
    return false;
end
--确保大招
function U.ManaR(abilityR, avilityManaCost)
	local manaCost = abilityR:GetManaCost();

	if abilityR:IsFullyCastable() then --如果大招就绪，确保大招可以释放
		return bot:GetMana() > manaCost + avilityManaCost;
	elseif nHP > 0.25 then --省着点蓝，保证大招就绪时蓝量差不多
		return bot:GetMana() > manaCost * 0.8;
	else --血量过低就不要纠结是否留着大招了
		return true;
	end

	return false;
end
--获取单位面向
function GetForwardVector()
    local radians = bot:GetFacing() * math.pi / 180
    local forward_vector = Vector(math.cos(radians), math.sin(radians))
    return forward_vector
end

function U.GetXUnitsInFront( nUnits )
    return bot:GetLocation() + GetForwardVector() * nUnits
end

return U;