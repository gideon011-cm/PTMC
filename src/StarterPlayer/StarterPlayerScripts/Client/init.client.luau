local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Controllers = Shared:WaitForChild("Controllers")

local BootStrapper = require(ReplicatedStorage.Packages.BootStrapper)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: ModuleScript
local Knit = require(ReplicatedStorage.Packages.Knit)
local Topbar = require(script.Topbar)

--Adds controllers to load
Knit.AddControllers(Controllers)

Knit.Start():andThen(function()
	--[[
        UI loads after controllers.
    ]]
	BootStrapper.run({ ReplicatedStorage.UI }, "Start")
	Topbar()
	
	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
end)
