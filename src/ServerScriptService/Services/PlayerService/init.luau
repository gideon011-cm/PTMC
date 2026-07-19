local Players = game:GetService("Players")
local Knit = require("@game/ReplicatedStorage/Packages/Knit")
local safePlayerAdded = require("@game/ReplicatedStorage/Shared/Modules/Game/safePlayerAdded")

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
})

function PlayerService:KnitInit()
	local tycoonService = Knit.GetService("TycoonService")

	local activeTycoons = {} :: {
		[number]: Model,
	}

	safePlayerAdded(function(player: Player)
		--[[
            When a player joins claim a tycoon for them
            Sets the player's tycoon to the activeTycoons so we can clean it up later
        ]]
		local tycoon = tycoonService:ClaimUnclaimedTycoon(player)

		activeTycoons[player.UserId] = tycoon
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		--[[
            Cleaning up everything like they nerver even joined
        ]]

		local userId = player.UserId

		local playerTycoon = activeTycoons[userId]
		tycoonService:CleanupTycoon(playerTycoon)

		activeTycoons[userId] = nil -- After we are done remove the player's tycoon from activeTycoons
	end)
end

return PlayerService
