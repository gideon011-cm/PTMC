local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)
local Placement = require(script.Placement)
local onPlaced = require(script.onPlaced)
local Notification = require(ReplicatedStorage.Shared.Modules.UI.Notification)

local currentTycoon = nil
local gridTexture = nil
local previewHitbox = nil
local previewSelectionBox = nil
local lastPreview = nil
local placementConnections = {}

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
	placementConnections[#placementConnections + 1] = Placement.PlacementStarted:Connect(function()
		local preview = Placement.GetPreview()
		assert(preview, "No preview")

		previewHitbox = preview.Hitbox
		previewSelectionBox = previewHitbox.SelectionBox

		updatePlacementVisuals(true, preview)
		lastPreview = preview
	end)

	placementConnections[#placementConnections + 1] = Placement.Rendered:Connect(function(_, _, canPlace: boolean)
		local color = canPlace and Config.Placement.CanPlaceColor or Config.Placement.CannotPlaceColor

		previewHighlight.FillColor = color
		previewHighlight.OutlineColor = color
		previewSelectionBox.SurfaceColor3 = color
		previewSelectionBox.Color3 = color
	end)

	placementConnections[#placementConnections + 1] = Placement.PlacementEnded:Connect(function()
		updatePlacementVisuals(false, lastPreview)
		previewHitbox = nil
		previewSelectionBox = nil
	end)

	local objectService = Knit.GetService("ObjectService")

	placementConnections[#placementConnections + 1] = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local preview = Placement.GetPreview()
			if preview and Placement.CanPlace then
				local cframe = Placement._CF
				preview:PivotTo(cframe)

				objectService:PlaceObject(lastPreview.Name, cframe):andThen(function(hasMore : boolean | string, model : Model)
					if typeof(hasMore) == "boolean" and not hasMore then
						self:StopObjectPreview()
					elseif typeof(hasMore) == "string" and hasMore == "Error" then
						warn("ERORR with objectService")
						self:StopObjectPreview()
					end

					onPlaced(model)
				end)
			end
		elseif input.KeyCode == Config.Placement.Rotate then
			Placement:Rotate(Vector3.yAxis)
		elseif input.KeyCode == Config.Placement.Cancel then
			self:StopObjectPreview()
		end
	end)
end

function ObjectController:StartObjectPreview(object: Model) : boolean
	if not currentTycoon then
		warn("No tycoon found")
		return false
	end	

	local distanceFromTycoon = (currentTycoon.PrimaryPart.Position - player.Character.PrimaryPart.Position).Magnitude
	if distanceFromTycoon > Config.Placement.MaxDistance then
		Notification("You are too far away from your tycoon to place this object.", 3)
		return false
	end

	Placement:SetPreview(object, currentTycoon)
	return true
end

function ObjectController:StopObjectPreview()
	Placement:Cancel()
end

function ObjectController:Destroy()
	for _, connection in ipairs(placementConnections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(placementConnections)
	placementConnections = {}
end

return ObjectController
