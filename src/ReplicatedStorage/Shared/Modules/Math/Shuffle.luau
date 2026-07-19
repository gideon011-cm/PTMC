--[[
    Helpful to make sure everything only gets used once.
]]
local function shuffle(t : {any})
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

return shuffle