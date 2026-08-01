local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).server
local TutorialNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Tutorial)

local TutorialService = Knit.CreateService({
	Name = "TutorialService",
})

function TutorialService:KnitStart()
	TutorialNetwork.request.listen(function(request: string, player: Player?)
		if request == "AddStep" then
			if player then
				local life = player:GetAttribute("Life")

				Data_[player][life].Tutorial.Step(function(n: number)
					return n + 1
				end)
			end
		end
	end)
end

return TutorialService
