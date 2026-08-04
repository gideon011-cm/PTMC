local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local BuildFrame = HUD:WaitForChild("BuildFrame")
local Container = BuildFrame:WaitForChild("Contanier")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Placement = require(ReplicatedStorage.Shared.Controllers.ObjectController.Placement)
local Types = require(ReplicatedStorage.Shared.Modules.Types)
local RefreshFrames = require(script.RefreshFrames)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client

type FrameComponents = {
	Button: GuiButton,
	Main: GuiObject,
	Center: Frame,
}

local api = {
	OgSizes = {},
}

type Objects = Types.Objects
type StoredObject = Types.StoredObject

local activeMainFrame = nil
local activeClickedFrame = nil
local SoundController = Knit.GetController("SoundController")

local function ImpactTween(object: Frame, originalSize: UDim2)
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

local function deselectCurrent()
	if not activeMainFrame or not activeClickedFrame then
		return
	end

	activeClickedFrame.Visible = false
	SoundController:PlayUI("UI_BuildUnclick")
	ImpactTween(activeMainFrame, api.OgSizes[activeMainFrame])

	local objectController = Knit.GetController("ObjectController")
	objectController:StopObjectPreview()

	activeMainFrame = nil
	activeClickedFrame = nil
end

local function setupFrame(frame: Frame & FrameComponents)
	local frameTrove = Trove.new()

	local button = frame.Button
	local main = frame.Main
	local center = main.Center
	local clickedFrame = center.ClickedFrame
	local amountText = center.Amount

	local ogSize = main.Size
	api.OgSizes[main] = ogSize

	local hoverSize = UDim2.fromScale(ogSize.X.Scale * 0.91, ogSize.Y.Scale * 0.91)
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

	frameTrove:AttachToInstance(frame)

	frameTrove:Add(button.MouseEnter:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = hoverSize }):Play()
	end))

	frameTrove:Add(button.MouseLeave:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = ogSize }):Play()
	end))

	frameTrove:Add(button.MouseButton1Click:Connect(function()
		if activeMainFrame == main then
			deselectCurrent()
			return
		end

		deselectCurrent()

		local objectController = Knit.GetController("ObjectController")
		local success = objectController:StartObjectPreview(Models[frame.Name])

		if not success then
			return
		end

		clickedFrame.Visible = true
		activeMainFrame = main
		activeClickedFrame = clickedFrame

		SoundController:PlayUI("UI_BuildClick")
		ImpactTween(main, ogSize)
	end))

	local life = player:GetAttribute("Life")
	frameTrove:Add(Data_[life].Objects.Stored[frame.Name].Changed(function(objectData: StoredObject)
		--[[
            If objectData is nil it means the data removed ot placed somewhere else
        ]]
		if not objectData then
			if activeMainFrame == main then
				deselectCurrent()
			end

			frame:Destroy()
		else
			local amount = objectData.Amount
			amountText.Text = "X" .. amount
		end
	end))
end

function api:Init()
	local life = player:GetAttribute("Life")
	
	local ObjectStored = Data_[life].Objects.Stored()

	Container.ChildAdded:Connect(setupFrame)

	Placement.PlacementEnded:Connect(function()
		deselectCurrent()
	end)

	RefreshFrames(Container, ObjectStored)
end

return api
