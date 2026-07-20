local BootStrapper = require("../Packages/BootStrapper")

local HUD = {}

function HUD:Start()
	--[[
        Simply runs all the modules under HUD
        method name: Init
    ]]
	BootStrapper.run(script:GetChildren(), "Init")
end

return HUD
