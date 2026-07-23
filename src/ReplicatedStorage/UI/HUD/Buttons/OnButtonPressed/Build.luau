local TweenService = game:GetService("TweenService")

local ogPosition = nil

local function onBuildPressed(HUD : ScreenGui)
    --[[
        Gets the needed variables
    ]]
    local BuildFrame = HUD:WaitForChild("BuildFrame")
    local visible = BuildFrame.Visible

    if not ogPosition then
        ogPosition = BuildFrame.Position
    end

    local offscreenPosition = ogPosition - UDim2.fromScale(0.5, 0)

    if visible then
        --[[
            If the buildFrame is shown, tween it to the offscreenPosition
        ]]
		local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local tween = TweenService:Create(BuildFrame, tweenInfo, { Position = offscreenPosition })

		tween.Completed:Once(function()
            --[[
                When tween is done, set visible to false so next time we know it not on screen
            ]]
			BuildFrame.Visible = false
		end)

		tween:Play()
	else
        --[[
            When the buildFrame isn't visible tween it to the originalPosition
        ]]
		BuildFrame.Visible = true
		BuildFrame.Position = offscreenPosition

		local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(BuildFrame, tweenInfo, { Position = ogPosition })

		tween:Play()
	end
end

return onBuildPressed