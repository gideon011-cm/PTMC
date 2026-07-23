local Lighting = game:GetService("Lighting")

local enabled = false

local function potatoMode()
	enabled = not enabled
    
	if enabled then
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = true
	end
end

return potatoMode