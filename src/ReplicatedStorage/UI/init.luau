local BootStrapper = require("./Packages/BootStrapper")

local UI = {}

function UI:Start()
	BootStrapper.run(script:GetChildren(), "Start")
end

return UI
