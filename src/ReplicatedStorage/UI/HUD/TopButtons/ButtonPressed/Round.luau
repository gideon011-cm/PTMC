local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Colors = require(ReplicatedStorage.Shared.Modules.Core.Colors)
local Notification = require(ReplicatedStorage.Shared.Modules.UI.Notification)

local roundService = Knit.GetService("RoundService")

local swordIcon = "rbxassetid://95315713736152"
local xIcon = "rbxassetid://133542966893748"

local function hideButtons()
	--Later
end

local function onRoundPressed(frame: Frame & {
	Main: Frame,
})
	local tycoonService = Knit.GetService("TycoonService")

	tycoonService:GetTycoon():andThen(function(tycoon: Model & { Objects: Folder })
		local objects = tycoon.Objects
		local maxwell = objects:FindFirstChild("Maxwell")

		if not maxwell then
			Notification("Place down maxwell on your tycoon to start the round!", 4)
			return
		end

		local redGradient = Colors.Red
		local greenGradient = Colors.Green

		local main = frame.Main

		local function changed(value)
			main.UIGradient.Color = not value and redGradient or greenGradient
			main.Title.Text = not value and "Stop" or "Fight!"
			main.Icon.Image = not value and xIcon or swordIcon
		end

		roundService:IsRoundActive():andThen(function(value: boolean)
			changed(value)

			if value then
				roundService:StopRounds()
			else
				roundService:StartRounds()
			end
		end)
	end)
end

return onRoundPressed
