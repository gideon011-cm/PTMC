local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)
local Placement = require(script.Placement)

local ObjectController = Knit.CreateController({
	Name = "ObjectController",
})

local tycoon = nil
local gridTexture = nil
local previewHitbox = nil
local previewSelectionBox = nil
local lastPreview = nil

local previewHighlight = Instance.new("Highlight")
previewHighlight.FillTransparency = 0.75
previewHighlight.Parent = script

--[[
	Updates the visual state of the placement preview.

	enabled = true:
	- Shows the hitbox
	- Shows the SelectionBox
	- Shows the placement grid

	enabled = false:
	- Hides the hitbox
	- Hides the SelectionBox
	- Hides the placement grid
]]
local function setPlacementVisuals(enabled: boolean, object : Instance)
	if not tycoon then
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
	local tycoonService = Knit.GetService("TycoonService")

	--[[
		GetTycoon returns a Promise, so wait until the
		player's tycoon has been successfully retrieved.
	]]
	tycoonService:GetTycoon():andThen(function(tycoonModel: Model)
		tycoon = tycoonModel

		local main = tycoon:WaitForChild("Main")
		gridTexture = main.GridTexture
	end)

	--[[task.delay(3, function()
		self:StartObjectPreview(ReplicatedStorage.Assets.Models.WoodWall)
	end)]]
end

function ObjectController:KnitStart()
	--[[
		Placement has started.

		Get the current preview and enable all
		placement-related visuals.
	]]
	Placement.PlacementStarted:Connect(function()
		local preview = Placement.GetPreview()

		if not preview then
			return
		end

		-- Cache these because the same preview is used
		-- throughout the current placement session.
		previewHitbox = preview.Hitbox
		previewSelectionBox = previewHitbox.SelectionBox
		
		setPlacementVisuals(true, preview)

		lastPreview = preview
	end)

	Placement.Rendered:Connect(function(_, _, canPlace : boolean)
		local color = canPlace and Config.Placement.CanPlaceColor or Config.Placement.CannotPlaceColor

		previewHighlight.FillColor = color
		previewHighlight.OutlineColor = color
		previewSelectionBox.SurfaceColor3 = color
		previewSelectionBox.Color3 = color
	end)

	--[[
		Placement has ended.

		Hide the preview visuals and placement grid.
	]]
	Placement.PlacementEnded:Connect(function()
		setPlacementVisuals(false, lastPreview)

		previewHitbox = nil
		previewSelectionBox = nil
	end)

	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Config.Placement.Rotate then
			Placement:Rotate(Vector3.yAxis)
		end
	end)
end

--[[
	Starts previewing an object for placement.

	@param object The model that should be previewed.
]]
function ObjectController:StartObjectPreview(object: Model)
	if not tycoon then
		warn("ERRORORRORORORROREORRORORORORORORO WITHTHHHHHHHHH STARTOBJECT PREWIWQ")
		return
	end

	Placement:SetPreview(object, tycoon)
end

function ObjectController:StopObjectPreview()
	Placement:Cancel()
end 

return ObjectController