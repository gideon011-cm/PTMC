local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TycoonCleanup = require(script.TycoonCleanup)
local SetupTycoon = require(script.SetupTycoon)
local Utiles = require(script.Utiles)
local Knit = require(ReplicatedStorage.Packages.Knit)

local TycoonService = Knit.CreateService({
	Name = "TycoonService",
})

function TycoonService:ClaimTycoon(player: Player, tycoon: Model)
	local isClaimed = Utiles:IsTycoonClaimed(tycoon)

	if not isClaimed then
		SetupTycoon(player, tycoon)
	end
end

function TycoonService:ClaimUnclaimedTycoon(player: Player): Model
	local tycoon = Utiles:GetUnclaimedTycoon()

	if tycoon then
		self:ClaimTycoon(player, tycoon)
	end

	return tycoon
end

function TycoonService:GetTycoon(player : Player) : Model
	return Utiles:GetTycoon(player)
end

function TycoonService.Client:GetTycoon(player : Player) : Model
	return Utiles:GetTycoon(player)
end

function TycoonService:CleanupTycoon(tycoon: Model)
	TycoonCleanup(tycoon)
end

return TycoonService
