local TutorialHighlight = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TutorialHighlightGui"
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = false
ScreenGui.Parent = PlayerGui

local Overlay = Instance.new("Frame")
Overlay.Name = "Overlay"
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.Size = UDim2.fromScale(1, 1)
Overlay.Position = UDim2.fromScale(0, 0)
Overlay.Parent = ScreenGui

local function CreateFrame(Name: string): Frame
	local Frame = Instance.new("Frame")
	Frame.Name = Name
	Frame.BackgroundColor3 = Color3.new(0, 0, 0)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Parent = Overlay

	return Frame
end

local TopFrame = CreateFrame("Top")
local BottomFrame = CreateFrame("Bottom")
local LeftFrame = CreateFrame("Left")
local RightFrame = CreateFrame("Right")

local Frames = {
	TopFrame,
	BottomFrame,
	LeftFrame,
	RightFrame,
}

-- Rounded highlight around the target
local Highlight = Instance.new("Frame")
Highlight.Name = "Highlight"
Highlight.BackgroundColor3 = Color3.new(0, 0, 0)
Highlight.BackgroundTransparency = 1
Highlight.BorderSizePixel = 0
Highlight.Visible = false
Highlight.Parent = Overlay

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.05, 0)
Corner.Parent = Highlight

local Stroke = Instance.new("UIStroke")
Stroke.Name = "Stroke"
Stroke.Color = Color3.fromRGB(255, 255, 255)
Stroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
Stroke.Thickness = 0.025
Stroke.Transparency = 0
Stroke.Parent = Highlight

local CurrentTarget: GuiObject?
local UpdateConnection: RBXScriptConnection?

local CurrentPadding = 8
local CurrentTransparency = 0.5

local PositionTween: Tween?
local SizeTween: Tween?

local function GetTargetBounds(Target: GuiObject)
	local TargetPosition = Target.AbsolutePosition
	local TargetSize = Target.AbsoluteSize

	local OverlayPosition = Overlay.AbsolutePosition
	local OverlaySize = Overlay.AbsoluteSize

	-- Convert target position into Overlay coordinates
	local X = TargetPosition.X - OverlayPosition.X
	local Y = TargetPosition.Y - OverlayPosition.Y

	local XMin = math.floor(X - CurrentPadding)
	local YMin = math.floor(Y - CurrentPadding)

	local XMax = math.ceil(X + TargetSize.X + CurrentPadding)
	local YMax = math.ceil(Y + TargetSize.Y + CurrentPadding)

	return {
		XMin = math.max(0, XMin),
		YMin = math.max(0, YMin),
		XMax = math.min(OverlaySize.X, XMax),
		YMax = math.min(OverlaySize.Y, YMax),
		ScreenWidth = OverlaySize.X,
		ScreenHeight = OverlaySize.Y,
	}
end

local function UpdatePosition(
	Target: GuiObject,
	Instant: boolean?
)
	if not Target.Parent or not Target.Visible then
		return
	end

	local Bounds = GetTargetBounds(Target)

	local XMin = Bounds.XMin
	local YMin = Bounds.YMin
	local XMax = Bounds.XMax
	local YMax = Bounds.YMax

	local ScreenWidth = Bounds.ScreenWidth
	local ScreenHeight = Bounds.ScreenHeight

	local TargetPosition = UDim2.fromOffset(
		XMin,
		YMin
	)

	local TargetSize = UDim2.fromOffset(
		XMax - XMin,
		YMax - YMin
	)

	-- Update the rounded highlight
	if Instant then
		Highlight.Position = TargetPosition
		Highlight.Size = TargetSize
	else
		if PositionTween then
			PositionTween:Cancel()
		end

		if SizeTween then
			SizeTween:Cancel()
		end

		PositionTween = TweenService:Create(
			Highlight,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),
			{
				Position = TargetPosition,
			}
		)

		SizeTween = TweenService:Create(
			Highlight,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			),
			{
				Size = TargetSize,
			}
		)

		PositionTween:Play()
		SizeTween:Play()
	end

	-- TOP
	TopFrame.Position = UDim2.fromOffset(0, 0)

	TopFrame.Size = UDim2.fromOffset(
		ScreenWidth,
		YMin
	)

	-- BOTTOM
	BottomFrame.Position = UDim2.fromOffset(
		0,
		YMax
	)

	BottomFrame.Size = UDim2.fromOffset(
		ScreenWidth,
		math.max(0, ScreenHeight - YMax)
	)

	-- LEFT
	LeftFrame.Position = UDim2.fromOffset(
		0,
		YMin
	)

	LeftFrame.Size = UDim2.fromOffset(
		XMin,
		math.max(0, YMax - YMin)
	)

	-- RIGHT
	RightFrame.Position = UDim2.fromOffset(
		XMax,
		YMin
	)

	RightFrame.Size = UDim2.fromOffset(
		math.max(0, ScreenWidth - XMax),
		math.max(0, YMax - YMin)
	)
end

function TutorialHighlight.Focus(
	Target: GuiObject,
	Padding: number?,
	Transparency: number?,
	FadeTime: number?
)
	if not Target:IsA("GuiObject") then
		warn("[TutorialHighlight] Target must be a GuiObject.")
		return
	end

	if UpdateConnection then
		UpdateConnection:Disconnect()
		UpdateConnection = nil
	end

	CurrentTarget = Target
	CurrentPadding = Padding or 8
	CurrentTransparency = Transparency or 0.5

	ScreenGui.Enabled = true
	Highlight.Visible = true

	-- Instantly position the first time
	task.defer(function()
		if CurrentTarget == Target then
			UpdatePosition(Target, true)
		end
	end)

	local FadeTweenInfo = TweenInfo.new(
		FadeTime or 0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	-- Fade in darkness
	for _, Frame in Frames do
		TweenService:Create(
			Frame,
			FadeTweenInfo,
			{
				BackgroundTransparency = CurrentTransparency,
			}
		):Play()
	end

	-- Fade in highlight
	Stroke.Transparency = 1

	TweenService:Create(
		Stroke,
		FadeTweenInfo,
		{
			Transparency = 0,
		}
	):Play()

	-- Follow target
	UpdateConnection = RunService.RenderStepped:Connect(function()
		if not CurrentTarget then
			return
		end

		if not CurrentTarget.Parent or not CurrentTarget.Visible then
			TutorialHighlight.Clear()
			return
		end

		-- Don't tween every RenderStepped.
		-- The spotlight follows the UI while the target changes.
		UpdatePosition(CurrentTarget)
	end)
end

function TutorialHighlight.Clear(FadeTime: number?)
	if UpdateConnection then
		UpdateConnection:Disconnect()
		UpdateConnection = nil
	end

	if PositionTween then
		PositionTween:Cancel()
	end

	if SizeTween then
		SizeTween:Cancel()
	end

	CurrentTarget = nil

	local TweenInfo_ = TweenInfo.new(
		FadeTime or 0.25,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	for _, Frame in Frames do
		TweenService:Create(
			Frame,
			TweenInfo_,
			{
				BackgroundTransparency = 1,
			}
		):Play()
	end

	TweenService:Create(
		Stroke,
		TweenInfo_,
		{
			Transparency = 1,
		}
	):Play()

	task.delay(FadeTime or 0.25, function()
		if not CurrentTarget then
			ScreenGui.Enabled = false
			Highlight.Visible = false
		end
	end)
end

return TutorialHighlight