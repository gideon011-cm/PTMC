local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BootStrapper = require(ReplicatedStorage.Packages.BootStrapper)

local UI = {}

function UI:Start()
	BootStrapper.run(script:GetChildren(), "Start")
end

return UI
