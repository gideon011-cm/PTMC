local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local BuildFrame = HUD:WaitForChild("BuildFrame")
local Contanier = BuildFrame:WaitForChild("Contanier")

local RefreshFrames = require(script.RefreshFrames)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client

local api = {}

type FrameComponents = {
	Button: GuiButton,
	Main: GuiObject,
}

local function setupFrame(frame : Frame & FrameComponents)
	local button = frame.Button
    local main = frame.Main

	local ogSize = main.Size

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local hoverSize = UDim2.fromScale(ogSize.X.Scale * 0.91, ogSize.Y.Scale * 0.91)

	button.MouseEnter:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = hoverSize }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(main, tweenInfo, { Size = ogSize }):Play()
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
