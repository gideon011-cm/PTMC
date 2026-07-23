local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Placement = require(script.Placement)
local Knit = require(ReplicatedStorage.Packages.Knit)

local ObjectController = Knit.CreateController({
	Name = "ObjectController",
})

function ObjectController:KnitStart()
	local tycoonService = Knit.GetService("TycoonService")
	self:StartObjectPreview(ReplicatedStorage.Assets.Models.Maxwell)

	local tycoon = nil
	tycoonService:GetTycoon():andThen(function(arugment: any)
		tycoon = arugment
	end)

	Placement.PlacementStarted:Connect(function()
		local preview = Placement.GetPreview()
		preview.Hitbox.Transparency = 0.875
		preview.Hitbox.SelectionBox.Visible = true

		tycoon.Main.GridTexture.Transparency = 0.4
	end)

	Placement.PlacementEnded:Connect(function()
		local preview = Placement.GetPreview()
		preview.Hitbox.Transparency = 1
		preview.Hitbox.SelectionBox.Visible = false

		tycoon.Main.GridTexture.Transparency = 1
	end)
end

function ObjectController:StartObjectPreview(object: Model)
	local tycoonService = Knit.GetService("TycoonService")

	tycoonService:GetTycoon():andThen(function(tycoon: Model)
		Placement:SetPreview(object, tycoon)
	end)
end

return ObjectController
