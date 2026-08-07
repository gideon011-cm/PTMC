local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local BootStrapper = require(ReplicatedStorage.Packages.BootStrapper)

local UIController = Knit.CreateController({
	Name = "UIController",
})

function UIController:KnitStart()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local hud = playerGui:WaitForChild("HUD")

	if hud then
		BootStrapper.run({ ReplicatedStorage.UI }, "Start")
	end
end

return UIController
