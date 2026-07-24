local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")
local Sounds = Assets:WaitForChild("Sounds")
local UISounds = Sounds:WaitForChild("UI")

local UI_BuildClick = UISounds:WaitForChild("UI_BuildClick")
local UI_BuildUnclick = UISounds:WaitForChild("UI_BuildUnclick")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local BuildFrame = HUD:WaitForChild("BuildFrame")
local Contanier = BuildFrame:WaitForChild("Contanier")

local Knit = require(ReplicatedStorage.Packages.Knit)
local RefreshFrames = require(script.RefreshFrames)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client

local api = {}

type FrameComponents = {
	Button: GuiButton,
	Main: GuiObject,
	Center: Frame,
}

local function ImpactTween(object : Frame, originalSize : UDim2)
	local grow = UDim2.fromScale(originalSize.X.Scale * 1.08, originalSize.Y.Scale * 1.08)
	local shrink = UDim2.fromScale(originalSize.X.Scale * 0.94, originalSize.Y.Scale * 0.94)

	local t1 = TweenService:Create(
		object,
		TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = grow }
	)

	local t2 = TweenService:Create(
		object,
		TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Size = shrink }
	)

	local t3 = TweenService:Create(
		object,
		TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		{ Size = originalSize }
	)

	t1:Play()
	t1.Completed:Once(function()
		t2:Play()
		t2.Completed:Once(function()
			t3:Play()
		end)
	end)
end

local function setupFrame(frame: Frame & FrameComponents)
	local button = frame.Button
	local main = frame.Main
	local center = main.Center

	local ogSize = main.Size
	local clickedFrame = center.ClickedFrame

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local hoverSize = UDim2.fromScale(ogSize.X.Scale * 0.91, ogSize.Y.Scale * 0.91)

	button.MouseEnter:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = hoverSize }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = ogSize }):Play()
	end)

	local objectController = Knit.GetController("ObjectController")

	button.MouseButton1Click:Connect(function()
		clickedFrame.Visible = not clickedFrame.Visible
		ImpactTween(main, ogSize)

		if clickedFrame.Visible then
			UI_BuildClick:Play()
			objectController:StartObjectPreview(Models[frame.Name])
		else
			UI_BuildUnclick:Play()
			objectController:StopObjectPreview()
		end
	end)
end

function api:Init()
	--[[
        Gets the object that stored then refeshs the frames
    ]]
	local life = player:GetAttribute("Life")
	local ObjectStored = Data_[life].Objects.Stored()

	Contanier.ChildAdded:Connect(setupFrame)

	RefreshFrames(Contanier, ObjectStored)
end

return api
