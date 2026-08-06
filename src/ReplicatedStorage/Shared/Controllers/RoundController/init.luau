local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local TopButtons = HUD:WaitForChild("TopButtons")
local Round = TopButtons:WaitForChild("Round")
local Waves = HUD:WaitForChild("Waves")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RoundController = Knit.CreateController({
	Name = "RoundController",
})

function RoundController:KnitStart()
	local roundService = Knit.GetService("RoundService")
	local soundController = Knit.GetController("SoundController")

	roundService.IsActive:Observe(function(active: boolean)
		if active then
			Waves.Visible = true
			soundController:ChangeSoundGroupVolume("Songs", 0, 1)
			soundController:ChangeSoundGroupVolume("Round", 0.5, 1)
		else
			Waves.Visible = false
			soundController:ChangeSoundGroupVolume("Songs", 0.5, 1)
			soundController:ChangeSoundGroupVolume("Round", 0, 1)
		end
        
		Round.Main.Loading.Visible = false
		Round.Button.Visible = true
	end)
end

return RoundController
