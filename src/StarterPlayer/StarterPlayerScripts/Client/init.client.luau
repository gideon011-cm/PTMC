local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Controllers = Shared:WaitForChild("Controllers")

local BootStrapper = require("@game/ReplicatedStorage/Packages/BootStrapper")
local Knit = require("@game/ReplicatedStorage/Packages/Knit")

--Adds controllers to load
Knit.AddControllers(Controllers)

Knit.Start():andThen(function()
	--[[
        UI loads after controllers.
    ]]
	BootStrapper.run({ ReplicatedStorage.UI }, "Start")
end)