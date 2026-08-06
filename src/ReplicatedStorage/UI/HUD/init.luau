local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUDGui = playerGui:WaitForChild("HUD")
local topButtons = HUDGui:WaitForChild("TopButtons")
local Round = topButtons:WaitForChild("Round")
local Main = Round:WaitForChild("Main")
local Loading = Main:WaitForChild("Loading")
local icon = Loading:WaitForChild("Icon")

local BootStrapper = require("../Packages/BootStrapper")

local HUD = {}

function HUD:Start()
	--[[
        Simply runs all the modules under HUD
        method name: Init
    ]]
	BootStrapper.run(script:GetChildren(), "Init")

    local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false)
    local tween = TweenService:Create(icon, tweenInfo, {Rotation = 360})
    tween:Play()
end

return HUD
