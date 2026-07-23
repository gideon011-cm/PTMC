local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local onCharacterAdded = require(script.onCharacterAdded)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local safePlayerAdded = require(ReplicatedStorage.Shared.Modules.Game.safePlayerAdded)

local PlayerService = Knit.CreateService({
	Name = "PlayerService",
})

function PlayerService:KnitInit()
	local tycoonService = Knit.GetService("TycoonService")

	local activeTycoons = {} :: {
		[number]: Model,
	}

	local playerTroves = {} :: { any }

	safePlayerAdded(function(player: Player)
		--[[
            When a player joins claim a tycoon for them
            Sets the player's tycoon to the activeTycoons so we can clean it up later
        ]]
		local tycoon = tycoonService:ClaimUnclaimedTycoon(player)

		local userId = player.UserId

		activeTycoons[userId] = tycoon

		--[[
			Creates a trove and binds it to the player
			when the player leaves the trove desotroys
		]]
		local newTrove = Trove.new()
		playerTroves[userId] = newTrove

		player:SetAttribute("Life", "Life_1") --!! TEST

		--[[
			First init on character added, then connects with trove
		]]
		local character = player.Character or player.CharacterAdded:Wait()

		onCharacterAdded(character)
		newTrove:Connect(player.CharacterAdded, onCharacterAdded)

		newTrove:AttachToInstance(player)
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
