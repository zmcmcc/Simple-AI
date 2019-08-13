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

return U;