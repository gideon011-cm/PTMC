--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

local Placement = {
    Preview = nil,
    CheckingObjects = {},
    CanPlace = false,
    CanRender = true,
    GridUnit = nil,
    RaycastParams = nil,
    _RotationCF = CFrame.identity,
    PlacementStarted = placementStartedEvent,
    PlacementEnded = placementEndedEvent,
    Rendered = renderedEvent,
    _PreviewCFValue = nil,
    _OptionsContext = {},
    _ValidationPolicy = nil,
    _PreviewModifier = nil,
    _CF = nil,
}

local function defaultValidationPolicy(preview: Instance, objectsToCheck: { BasePart? }, context: {}): boolean
    return Validation:HasValidPlacement(preview, objectsToCheck)
end

function Placement:Rotate(axis: Vector3)
    local rotationUnit: number = Config.Placement.RotationUnit
    Placement._RotationCF *= CFrame.fromAxisAngle(axis, math.rad(rotationUnit))
end

function Placement:GetTargetCF(): CFrame?
    local gridUnit: number = Placement.GridUnit or Config.Placement.GridUnit
    local raycastParams: RaycastParams = Placement.RaycastParams
    local raycastResult: RaycastResult? = Raycast:GetMouseResult(raycastParams, 2 ^ 11)

    if not (raycastResult and raycastResult.Instance) then return end

    local hitInstance = raycastResult.Instance
    local hitPosition: Vector3 = raycastResult.Position
    local normal: Vector3 = raycastResult.Normal

    local hitInstanceCF: CFrame = hitInstance:GetPivot()
    local hitInstancePosition: Vector3 = hitInstanceCF.Position

    local upVector: Vector3 = normal
    local rightVector: Vector3 = hitInstanceCF.RightVector

    if math.abs(upVector:Dot(rightVector)) > 0.999 then
        rightVector = hitInstanceCF.LookVector
    end

    rightVector = (rightVector - upVector * rightVector:Dot(upVector)).Unit
    local lookVector: Vector3 = rightVector:Cross(upVector).Unit

    local preview = Placement:GetPreview()
    if not preview then return end

    local previewSize: Vector3
    if preview:FindFirstChild("Hitbox") then
        previewSize = preview.Hitbox.Size
    elseif preview:IsA("Model") then
        local _, size: Vector3 = preview:GetBoundingBox()
        previewSize = size
    else
        previewSize = preview.Size
    end

    local surfaceCF: CFrame = CFrame.fromMatrix(Vector3.zero, rightVector, upVector, lookVector)
    local rotationCF: CFrame = Placement._RotationCF
    local finalRotation: CFrame = surfaceCF * rotationCF

    local rotatedSize: Vector3 = rotationCF:VectorToWorldSpace(previewSize)
    local sizeX: number = math.abs(rotatedSize.X)
    local sizeZ: number = math.abs(rotatedSize.Z)

    local relativePosition: Vector3 = hitPosition - hitInstancePosition
    local height: number = relativePosition:Dot(upVector)
    local tangentU: number = relativePosition:Dot(rightVector)
    local tangentV: number = relativePosition:Dot(lookVector)

    local snappedTangentU: number = PlacingUtility.SnapToGrid(tangentU, gridUnit, sizeX)
    local snappedTangentV: number = PlacingUtility.SnapToGrid(tangentV, gridUnit, sizeZ)

    local snappedPosition: Vector3 = hitInstancePosition
        + upVector * height
        + rightVector * snappedTangentU
        + lookVector * snappedTangentV

    local offsetDistance: number = (
        math.abs(finalRotation.RightVector:Dot(upVector)) * previewSize.X
        + math.abs(finalRotation.UpVector:Dot(upVector)) * previewSize.Y
        + math.abs(finalRotation.LookVector:Dot(upVector)) * previewSize.Z
    ) / 2

    local finalPosition: Vector3 = snappedPosition + upVector * offsetDistance
    return CFrame.new(finalPosition) * finalRotation
end

local tweenInfo = TweenInfo.new(Config.Placement.TweenDuration or 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
function Placement.Render()
    local canRender: boolean = Placement.CanRender
    local preview: Instance? = Placement:GetPreview()

    if not (canRender and preview) then return end

    local currentCF: CFrame? = Placement._CF
    local targetCF: CFrame? = Placement:GetTargetCF() or currentCF

    if not targetCF then return end

    local validationPolicy = Placement._ValidationPolicy
    local hasValidPlacement: boolean

    if validationPolicy then
        hasValidPlacement = validationPolicy(preview, Placement.CheckingObjects, Placement._OptionsContext)
    else
        hasValidPlacement = defaultValidationPolicy(preview, Placement.CheckingObjects, Placement._OptionsContext)
    end

    Placement.CanPlace = hasValidPlacement

    local previewCFValue = Placement._PreviewCFValue

    if not previewCFValue then
        previewCFValue = Instance.new("CFrameValue")
        previewCFValue.Parent = __THINGS.Temp

        Placement._PreviewCFValue = previewCFValue

        previewCFValue.Changed:Connect(function(newCF: CFrame)
            local currentPreview = Placement:GetPreview()
            if currentPreview then
                currentPreview:PivotTo(newCF)
            end
        end)
    end

    if Placement._CF ~= targetCF then
        Placement._CF = targetCF

        TweenService:Create(previewCFValue, tweenInfo, {Value = targetCF}):Play()
    end

    renderedEvent:Fire(preview, targetCF, hasValidPlacement)
end

function Placement:PreparePreview(instance: Instance)
    local newPreview = instance:Clone()
    Placement.Preview = newPreview

    local previewModifier = Placement._PreviewModifier
    if previewModifier then
        previewModifier(newPreview, Placement._OptionsContext)
    else
        PlacingUtility.ModifyPreview(newPreview)
    end

    newPreview.Parent = __THINGS.Temp
    local targetCF: CFrame? = Placement:GetTargetCF()

    if targetCF then
        Placement._CF = targetCF
        newPreview:PivotTo(targetCF)
        
        if Placement._PreviewCFValue then
            Placement._PreviewCFValue.Value = targetCF
        end
    end
end

function Placement:GetPreview(): Instance?
    return Placement.Preview
end

function Placement:SetPreview(instance: Instance, includeObjects, options: PreviewOptions?)
    Placement:Cancel()

    Placement._OptionsContext = options and options.Context or {}
    Placement._ValidationPolicy = options and options.ValidationPolicy or defaultValidationPolicy
    Placement._PreviewModifier = options and options.PreviewModifier

    local raycastParams: RaycastParams = RaycastParams.new()
    local params: Params = ParamsBuilder.new(raycastParams)
    params:Include(includeObjects)

    Placement.RaycastParams = raycastParams
    Placement.CheckingObjects = includeObjects

    Placement:PreparePreview(instance)

    currentTrove:Clean()
    currentTrove:BindToRenderStep("Render", Enum.RenderPriority.Camera.Value, Placement.Render)

    placementStartedEvent:Fire()
end

function Placement:Cancel()
    local preview: Instance? = Placement:GetPreview()
    if not preview then return end

    currentTrove:Clean()

    Placement.CanPlace = false
    Placement.GridUnit = nil
    Placement.RaycastParams = nil
    Placement.CheckingObjects = {}

    Placement._RotationCF = CFrame.identity
    Placement._CF = nil

    local previewCFValue = Placement._PreviewCFValue
    if previewCFValue then
        previewCFValue:Destroy()
    end

    Placement._PreviewCFValue = nil

    preview:Destroy()
    Placement.Preview = nil
    placementEndedEvent:Fire()
end

return Placement