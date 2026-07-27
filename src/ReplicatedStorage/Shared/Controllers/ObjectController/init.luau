local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)
local Placement = require(script.Placement)

local currentTycoon = nil
local gridTexture = nil
local previewHitbox = nil
local previewSelectionBox = nil
local lastPreview = nil

local previewHighlight = Instance.new("Highlight")
previewHighlight.FillTransparency = 0.75
previewHighlight.Parent = script

local ObjectController = Knit.CreateController({
	Name = "ObjectController",
})

local function updatePlacementVisuals(enabled: boolean, object: Instance?)
	if not currentTycoon then
		return
	end

	if previewHitbox then
		previewHitbox.Transparency = enabled and 0.875 or 1
	end

	if previewSelectionBox then
		previewSelectionBox.Visible = enabled
	end

	if gridTexture then
		gridTexture.Transparency = enabled and 0.4 or 1
	end

	previewHighlight.Adornee = enabled and object or nil
end

function ObjectController:KnitInit()
	local TycoonService = Knit.GetService("TycoonService")

	TycoonService:GetTycoon()
		:andThen(function(tycoonModel: Model)
			currentTycoon = tycoonModel

			local main = currentTycoon:WaitForChild("Main")
			gridTexture = main.GridTexture
		end)
		:catch(warn)
end

function ObjectController:KnitStart()
	Placement.PlacementStarted:Connect(function()
		local preview = Placement.GetPreview()
		assert(preview, "No preview")

		previewHitbox = preview.Hitbox
		previewSelectionBox = previewHitbox.SelectionBox

		updatePlacementVisuals(true, preview)
		lastPreview = preview
	end)

	Placement.Rendered:Connect(function(_, _, canPlace: boolean)
		local color = canPlace and Config.Placement.CanPlaceColor or Config.Placement.CannotPlaceColor

		previewHighlight.FillColor = color
		previewHighlight.OutlineColor = color
		previewSelectionBox.SurfaceColor3 = color
		previewSelectionBox.Color3 = color
	end)

	Placement.PlacementEnded:Connect(function()
		updatePlacementVisuals(false, lastPreview)
		previewHitbox = nil
		previewSelectionBox = nil
	end)

	local objectService = Knit.GetService("ObjectService")

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local preview = Placement.GetPreview()
			if preview and Placement.CanPlace then
				local cframe = Placement._CF
				preview:PivotTo(cframe)

				objectService:PlaceObject(lastPreview.Name, cframe):andThen(function(hasMore : boolean | string)
					if typeof(hasMore) == "boolean" and not hasMore then
						self:StopObjectPreview()
					elseif typeof(hasMore) == "string" and hasMore == "Error" then
						warn("ERORR with objectService")
						self:StopObjectPreview()
					end
				end)
			end
		elseif input.KeyCode == Config.Placement.Rotate then
			Placement:Rotate(Vector3.yAxis)
		elseif input.KeyCode == Config.Placement.Cancel then
			self:StopObjectPreview()
		end
	end)
end

function ObjectController:StartObjectPreview(object: Model)
	assert(currentTycoon, "No tycoon in for preview")

	Placement:SetPreview(object, currentTycoon)
end

function ObjectController:StopObjectPreview()
	Placement:Cancel()
end

return ObjectController
