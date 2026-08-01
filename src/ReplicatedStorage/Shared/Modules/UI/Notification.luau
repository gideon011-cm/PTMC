local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local assets = ReplicatedStorage:WaitForChild("Assets")
local UI = assets:WaitForChild("UI")
local notificationTemplate = UI:WaitForChild("Notification")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Notifications = playerGui:WaitForChild("Notifications")
local container = Notifications:WaitForChild("Container")

local ObjectPool = require(ReplicatedStorage.Shared.Modules.Classes.ObjectPool)

local pool = ObjectPool.new(notificationTemplate)

local colorWhiteTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local normalPositionTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local leaveTweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function notification(title: string, duration: number)
	local template = pool:Get()
	local main = template.Main

	local ogPosition = main.Position

	main.Title.Text = title

	main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

	local upPosition = UDim2.fromScale(ogPosition.X.Scale, ogPosition.Y.Scale - 0.25)

    main.Position = upPosition

	local whiteTween = TweenService:Create(main, colorWhiteTweenInfo, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
	local normalPositionTween = TweenService:Create(main, normalPositionTweenInfo, { Position = ogPosition })

	template.Parent = container

	whiteTween:Play()
	normalPositionTween:Play()

	task.delay(duration, function()
		local leaveTween = TweenService:Create(main, leaveTweenInfo, { Transparency = 1 })
        local leaveTween2 = TweenService:Create(main.Title, leaveTweenInfo, { TextTransparency = 1 })

        leaveTween2:Play()
		leaveTween:Play()

		leaveTween.Completed:Once(function()
			pool:Return(template)

            main.Transparency = 0.3
            main.Title.TextTransparency = 0
		end)
	end)
end

return notification
