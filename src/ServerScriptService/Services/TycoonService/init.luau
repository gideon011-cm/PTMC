local Knit = require("@game/ReplicatedStorage/Packages/Knit")
local SetupTycoon = require("@self/SetupTycoon")
local TycoonCleanup = require("@self/TycoonCleanup")
local Utiles = require("@self/Utiles")

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

function TycoonService:CleanupTycoon(tycoon: Model)
	TycoonCleanup(tycoon)
end

return TycoonService
