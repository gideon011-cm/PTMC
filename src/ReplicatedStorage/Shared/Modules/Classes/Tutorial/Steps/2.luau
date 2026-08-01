local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local confti = require(ReplicatedStorage.Shared.Modules.Classes.Tutorial.confti)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local HUD = playerGui:WaitForChild("HUD")
local topButtons = HUD:WaitForChild("TopButtons")
local round = topButtons:WaitForChild("Round")
local main = round:WaitForChild("Main")

local locked = main:WaitForChild("Locked") :: Frame
local lock = locked:WaitForChild("Lock")

local newconfiti = confti.new()

local function unlock()
	newconfiti:Emit(100, UDim2.fromScale(0.5, 0.16))

	lock.Image = "rbxassetid://81104561689684"

	task.delay(0.5, function()
		local fallPosition = UDim2.fromScale(lock.Position.X.Scale - 0.8, 20)

		local throwTween =
			TweenService:Create(lock, TweenInfo.new(1.2, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
				Position = fallPosition,
				Rotation = 1440,
			})

        local visibleTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local visibleTween = TweenService:Create(locked, visibleTweenInfo, {BackgroundTransparency = 1})

		throwTween:Play()

        visibleTween.Completed:Once(function()
            locked:Destroy()
			
			round.Button.Visible = true
        end)

        visibleTween:Play()
	end)
end

local function step2(signal)
	unlock()
end

return step2
