--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LemonSignal = require(script.LemonSignal)
local PlacingUtility = require(script.PlacingUtility)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)
local ParamsBuilder = require(ReplicatedStorage.Shared.Modules.Game.ParamsBuilder)
local Raycast = require(ReplicatedStorage.Shared.Modules.Math.Raycast)
local Validation = require(ReplicatedStorage.Shared.Modules.Platform.Validation)

local __THINGS = workspace:WaitForChild("__THINGS")

local currentTrove = Trove.new()

local placementStartedEvent = LemonSignal.new()
local placementEndedEvent = LemonSignal.new()
local renderedEvent = LemonSignal.new()

type Signal = LemonSignal.Signal
type Params = ParamsBuilder.Params

export type PreviewOptions = {
	ValidationPolicy: ((preview: Instance, objectsToCheck: { BasePart? }, context: {}) -> boolean)?,
	PreviewModifier: ((preview: Instance, context: {}) -> ())?,
	Context: {}?,
}

local PlacingService = {
	--[[
		The current object being previewed.

		This is cloned from the original object and modified
		to visually represent the object before it is placed.
	]]
	Preview = nil,

	--[[
		Objects that are used when checking whether the preview
		can be placed.

		These are usually the objects that the player is allowed
		to place on or interact with.
	]]
	CheckingObjects = {},

	--[[
		Whether the current preview is allowed to be placed.

		This value is updated every render frame by the validation system.
	]]
	CanPlace = false,

	--[[
		Controls whether the preview should visually update.
	]]
	CanRender = true,

	--[[
		Optional grid size override.

		If nil, the default grid size from Config.Placement is used.
	]]
	GridUnit = nil,

	--[[
		Raycast parameters used to determine where the preview
		should be positioned.
	]]
	RaycastParams = nil,

	--[[
		Stores the user's manual rotation of the preview.
	]]
	_RotationCF = CFrame.identity,

	--[[
		Signals fired when placement starts and ends.
	]]
	PlacementStarted = placementStartedEvent,
	PlacementEnded = placementEndedEvent,

	--[[
		Fired whenever the preview is rendered.

		Arguments:
			Preview
			TargetCFrame
		CanPlace
	]]
	Rendered = renderedEvent,

	--[[
		CFrameValue used to smoothly move the preview.

		Using a CFrameValue allows the preview movement to be
		handled through the Changed event.
	]]
	_PreviewCFValue = nil,

	--[[
		Custom data passed into validation and preview modifiers.

		This allows different object types to have their own
		validation rules without changing the main placement system.
	]]
	_OptionsContext = {},

	--[[
		Custom validation function for the current preview.

		If nil, the default Validation module is used.
	]]
	_ValidationPolicy = nil,

	--[[
		Optional function that modifies the preview.

		If nil, PlacingUtility.ModifyPreview is used.
	]]
	_PreviewModifier = nil,

	--[[
		The current target CFrame calculated from the mouse raycast.

		This is separated from _VisualCF so the actual target position
		can update immediately while the visual preview smoothly follows it.
	]]
	_CF = nil,

	--[[
		The CFrame currently displayed by the preview.

		This is smoothly interpolated toward _CF.
	]]
	_VisualCF = nil,
}

--[[
	Default validation policy.

	This is used when no custom validation function is provided
	through PreviewOptions.
]]
local function defaultValidationPolicy(preview: Instance, objectsToCheck: { BasePart? }, context: {}): boolean
	return Validation:HasValidPlacement(preview, objectsToCheck)
end

--[[
	Rotates the current preview around the given axis.

	The rotation amount is controlled by Config.Placement.RotationUnit.
]]
function PlacingService:Rotate(axis: Vector3)
	local rotationUnit: number = Config.Placement.RotationUnit

	PlacingService._RotationCF *= CFrame.fromAxisAngle(axis, math.rad(rotationUnit))
end

--[[
	Calculates the CFrame where the preview should be placed.

	The function:
		1. Raycasts from the player's mouse.
		2. Gets the surface normal.
		3. Creates an orientation based on the surface.
		4. Applies the player's manual rotation.
		5. Snaps the position to the placement grid.
		6. Offsets the preview so it sits on top of the surface.

	Returns nil if the mouse is not currently hitting anything.
]]
function PlacingService:GetTargetCF(): CFrame?
	local gridUnit: number = PlacingService.GridUnit or Config.Placement.GridUnit

	local raycastParams: RaycastParams = PlacingService.RaycastParams
	local raycastResult: RaycastResult? = Raycast:GetMouseResult(raycastParams, 2 ^ 11)

	if not (raycastResult and raycastResult.Instance) then
		return
	end

	local hitInstance = raycastResult.Instance
	local hitPosition: Vector3 = raycastResult.Position
	local normal: Vector3 = raycastResult.Normal

	local hitInstanceCF: CFrame = hitInstance:GetPivot()
	local hitInstancePosition: Vector3 = hitInstanceCF.Position

	--[[
		Create a coordinate system based on the surface normal.

		This allows the preview to align itself to walls,
		floors, slopes, and other surfaces.
	]]
	local upVector: Vector3 = normal
	local rightVector: Vector3 = hitInstanceCF.RightVector

	--[[
		If the surface normal is almost parallel to the object's
		RightVector, use LookVector instead to prevent an unstable
		cross product.
	]]
	if math.abs(upVector:Dot(rightVector)) > 0.999 then
		rightVector = hitInstanceCF.LookVector
	end

	--[[
		Project RightVector onto the surface plane.

		This ensures the resulting orientation is perpendicular
		to the surface normal.
	]]
	rightVector = (rightVector - upVector * rightVector:Dot(upVector)).Unit

	local lookVector: Vector3 = rightVector:Cross(upVector).Unit

	local preview = PlacingService.GetPreview()

	if not preview then
		return
	end

	--[[
		Get the size of the preview.

		Models use GetBoundingBox while BaseParts use their Size property.
	]]
	local previewSize: Vector3

	if preview:IsA("Model") then
		local _, size: Vector3 = preview:GetBoundingBox()
		previewSize = size
	else
		previewSize = preview.Size
	end

	--[[
		Create the surface orientation and apply
		the player's manual rotation.
	]]
	local surfaceCF: CFrame = CFrame.fromMatrix(Vector3.zero, rightVector, upVector, lookVector)

	local rotationCF: CFrame = PlacingService._RotationCF
	local finalRotation: CFrame = surfaceCF * rotationCF

	--[[
		Calculate the preview's rotated dimensions.

		Only the X and Z dimensions are used for grid snapping.
	]]
	local rotatedSize: Vector3 = rotationCF:VectorToWorldSpace(previewSize)

	local sizeX: number = math.abs(rotatedSize.X)
	local sizeZ: number = math.abs(rotatedSize.Z)

	--[[
		Convert the hit position into the surface's local coordinates.
	]]
	local relativePosition: Vector3 = hitPosition - hitInstancePosition

	local height: number = relativePosition:Dot(upVector)
	local tangentU: number = relativePosition:Dot(rightVector)
	local tangentV: number = relativePosition:Dot(lookVector)

	--[[
		Snap the preview's position to the placement grid.
	]]
	local snappedTangentU: number = PlacingUtility.SnapToGrid(tangentU, gridUnit, sizeX)

	local snappedTangentV: number = PlacingUtility.SnapToGrid(tangentV, gridUnit, sizeZ)

	local snappedPosition: Vector3 = hitInstancePosition
		+ upVector * height
		+ rightVector * snappedTangentU
		+ lookVector * snappedTangentV

	--[[
		Calculate how far the preview needs to be offset
		along the surface normal so that it sits on the surface
		instead of being centered inside it.
	]]
	local offsetDistance: number = (
		math.abs(finalRotation.RightVector:Dot(upVector)) * previewSize.X
		+ math.abs(finalRotation.UpVector:Dot(upVector)) * previewSize.Y
		+ math.abs(finalRotation.LookVector:Dot(upVector)) * previewSize.Z
	) / 2

	local finalPosition: Vector3 = snappedPosition + upVector * offsetDistance

	return CFrame.new(finalPosition) * finalRotation
end

--[[
	Updates the visual preview every frame.

	The preview smoothly interpolates toward the target CFrame
	using exponential smoothing.

	Validation is also performed here so CanPlace always reflects
	the current position of the preview.
]]
function PlacingService.Render(deltaTime: number)
	local canRender: boolean = PlacingService.CanRender
	local preview: Instance? = PlacingService.GetPreview()

	if not (canRender and preview) then
		return
	end

	local currentCF: CFrame? = PlacingService._CF
	local targetCF: CFrame? = PlacingService.GetTargetCF() or currentCF

	if not targetCF then
		return
	end

	PlacingService._CF = targetCF

	--[[
		Run the configured validation policy.

		This allows individual object types to override
		the default placement validation.
	]]
	local validationPolicy = PlacingService._ValidationPolicy
	local hasValidPlacement: boolean

	if validationPolicy then
		hasValidPlacement = validationPolicy(preview, PlacingService.CheckingObjects, PlacingService._OptionsContext)
	else
		hasValidPlacement =
			defaultValidationPolicy(preview, PlacingService.CheckingObjects, PlacingService._OptionsContext)
	end

	PlacingService.CanPlace = hasValidPlacement

	--[[
		Calculate exponential smoothing.

		This makes the preview movement consistent across
		different frame rates.
	]]
	local lerpSpeed: number = Config.Placement.LerpSpeed
	local alpha: number = 1 - math.exp(-lerpSpeed * deltaTime)

	--[[
		Create the CFrameValue once and reuse it.

		This avoids creating a new instance every render frame.
	]]
	local previewCFValue = PlacingService._PreviewCFValue

	if not previewCFValue then
		previewCFValue = Instance.new("CFrameValue")
		previewCFValue.Parent = __THINGS.Temp

		PlacingService._PreviewCFValue = previewCFValue

		previewCFValue.Changed:Connect(function(newCF: CFrame)
			local currentPreview = PlacingService.GetPreview()

			if currentPreview then
				currentPreview:PivotTo(newCF)
			end
		end)
	end

	--[[
		Smoothly move the visual preview toward the target position.
	]]
	local currentVisualCF: CFrame = PlacingService._VisualCF or targetCF

	local visualCF: CFrame = currentVisualCF:Lerp(targetCF, alpha)

	previewCFValue.Value = visualCF
	PlacingService._VisualCF = visualCF

	--[[
		Notify listeners that the preview has been rendered.

		Arguments:
			Preview
			Target CFrame
			Whether the object can be placed
	]]
	renderedEvent:Fire(preview, targetCF, hasValidPlacement)
end

--[[
	Creates a cloned preview from the provided instance.

	The preview is modified to visually indicate that it is
	a placement preview rather than the actual object.
]]
function PlacingService:PreparePreview(instance: Instance)
	local newPreview = instance:Clone()

	PlacingService.Preview = newPreview

	--[[
		Use a custom preview modifier if one was provided.

		Otherwise, use the default preview modification utility.
	]]
	local previewModifier = PlacingService._PreviewModifier

	if previewModifier then
		previewModifier(newPreview, PlacingService._OptionsContext)
	else
		PlacingUtility.ModifyPreview(newPreview)
	end

	newPreview.Parent = __THINGS.Temp

	--[[
		Position the preview immediately if a valid target exists.
	]]
	local targetCF: CFrame? = PlacingService.GetTargetCF()

	if targetCF then
		PlacingService._CF = targetCF
		PlacingService._VisualCF = targetCF
		newPreview:PivotTo(targetCF)
	end
end

--[[
	Returns the currently active placement preview.
]]
function PlacingService:GetPreview(): Instance?
	return PlacingService.Preview
end

--[[
	Starts placement mode for the given instance.

	Arguments:
		instance:
			The object that will be cloned as the preview.

		includeObjects:
			Objects that should be considered when validating placement.

		options:
			Optional per-object configuration that can override
			validation and preview behavior.
]]
function PlacingService:SetPreview(instance: Instance, includeObjects, options: PreviewOptions?)
	--[[
		Always cancel the previous placement before starting
		a new one. This prevents multiple render loops or previews
		from running at the same time.
	]]
	PlacingService.Cancel()

	--[[
		Store custom options for the current preview.
	]]
	PlacingService._OptionsContext = options and options.Context or {}

	PlacingService._ValidationPolicy = options and options.ValidationPolicy or defaultValidationPolicy

	PlacingService._PreviewModifier = options and options.PreviewModifier

	--[[
		Create raycast parameters for the current placement.

		The included objects are also stored so the validation
		system can use the same objects.
	]]
	local raycastParams: RaycastParams = RaycastParams.new()
	local params: Params = ParamsBuilder.new(raycastParams)

	params:Include(includeObjects)

	PlacingService.RaycastParams = raycastParams
	PlacingService.CheckingObjects = includeObjects

	--[[
		Create and prepare the preview.
	]]
	PlacingService:PreparePreview(instance)

	--[[
		Start updating the preview every render frame.
	]]
	currentTrove:Clean()

	currentTrove:BindToRenderStep("Render", Enum.RenderPriority.Camera.Value, PlacingService.Render)

	placementStartedEvent:Fire()
end

--[[
	Cancels the current placement operation.

	This removes the preview, stops the render loop,
	resets placement state, and fires PlacementEnded.
]]
function PlacingService:Cancel()
	local preview: Instance? = PlacingService.GetPreview()

	if not preview then
		return
	end

	--[[
		Stop all connections and render-step callbacks
		managed by the current Trove.
	]]
	currentTrove:Clean()

	--[[
		Reset placement state.
	]]
	PlacingService.CanPlace = false
	PlacingService.GridUnit = nil
	PlacingService.RaycastParams = nil
	PlacingService.CheckingObjects = {}

	--[[
		Reset rotation and cached CFrames.
	]]
	PlacingService._RotationCF = CFrame.identity
	PlacingService._VisualCF = nil
	PlacingService._CF = nil

	--[[
		Destroy the CFrameValue used to animate the preview.
	]]
	local previewCFValue = PlacingService._PreviewCFValue

	if previewCFValue then
		previewCFValue:Destroy()
	end

	PlacingService._PreviewCFValue = nil

	--[[
		Destroy the preview itself.
	]]
	preview:Destroy()
	PlacingService.Preview = nil

	--[[
		Notify listeners that placement has ended.
	]]
	placementEndedEvent:Fire()
end

return PlacingService
