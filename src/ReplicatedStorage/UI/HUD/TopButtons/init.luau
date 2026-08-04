local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local TopButtons = HUD:WaitForChild("TopButtons")

local module = {}

function module:Init()
	for _, frame: Frame & {
		Main: Frame,
		Button: TextButton,
	} in pairs(TopButtons:GetChildren()) do
		if frame:IsA("Frame") then
			local main = frame.Main
			local ogSize = main.Size
			local button = frame.Button

			local sizeTween = UDim2.fromScale(ogSize.X.Scale * 1.08, ogSize.Y.Scale * 1.08)
			local unSizeTween = UDim2.fromScale(ogSize.X.Scale * 0.92, ogSize.Y.Scale * 0.92)

			button.MouseButton1Down:Connect(function()
				local visible = button.Visible
				if not visible then
					return
				end

				local tween = TweenService:Create(
					main,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = unSizeTween }
				)

				tween:Play()
			end)

			button.MouseButton1Up:Connect(function()
				local visible = button.Visible
				if not visible then
					return
				end

				local tween = TweenService:Create(
					main,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = sizeTween }
				)

				local buttonModule = require(script.ButtonPressed:FindFirstChild(frame.Name))
				if buttonModule then
					buttonModule(frame)
				end

				tween:Play()
			end)

			button.MouseEnter:Connect(function()
				local visible = button.Visible
				if not visible then
					return
				end

				local tween = TweenService:Create(
					main,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = sizeTween }
				)

				tween:Play()
			end)

			button.MouseLeave:Connect(function()
				local visible = button.Visible
				if not visible then
					return
				end

				local tween = TweenService:Create(
					main,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = ogSize }
				)

				tween:Play()
			end)
		end
	end
end

return module
