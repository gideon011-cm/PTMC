local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Hints = require("@self/Hints")

local player = Players.LocalPlayer

--[[
    Removes the default loadingScreen because we have our own
]]
ReplicatedFirst:RemoveDefaultLoadingScreen()

local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")

local loadingScreen = ReplicatedFirst:WaitForChild("Loading")

local Assets = ReplicatedStorage:WaitForChild("Assets")
loadingScreen.Parent = playerGui

local main = loadingScreen:WaitForChild("Main")
local cube_1 = main:WaitForChild("Cube_1")
local cube_2 = main:WaitForChild("Cube_2")
local loadingText = main:WaitForChild("Loading")
local progress = main:WaitForChild("Progress")
local green = progress:WaitForChild("Green")
local percentage = main:WaitForChild("Percentage")
local hintText = main:WaitForChild("Hint")

local loadingBlur = Lighting:WaitForChild("LoadingBlur")

loadingBlur.Enabled = true

--[[
    Sets up continuous rotation for loading cubes
]]
local function setupCube(cube: Frame): Tween
	local rotationTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut, -1)
	local rotationTween = TweenService:Create(cube, rotationTweenInfo, { Rotation = cube.Rotation + 180 })
	rotationTween:Play()

	return rotationTween
end

local tweens = {
	setupCube(cube_1),
	setupCube(cube_2),
}

local hintsEnabled = true

--[[
    Creates a wave animation for the text by splitting characters into separate animated labels
]]
local function setupBouncyText(textLabel: TextLabel, textString: string)
	textLabel.Text = ""
	textLabel.BackgroundTransparency = 1

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = textLabel

	local charWidth = 1 / #textString

	for i = 1, #textString do
		local char = string.sub(textString, i, i)

		local letterContainer = Instance.new("Frame")
		letterContainer.Name = "Container_" .. i
		letterContainer.BackgroundTransparency = 1
		--[[
            Fully scale based: divides the total width evenly among the letters
        ]]
		letterContainer.Size = UDim2.fromScale(charWidth, 1)
		letterContainer.LayoutOrder = i
		letterContainer.Parent = textLabel

		local letterLabel = Instance.new("TextLabel")
		letterLabel.Name = "Letter_" .. i
		letterLabel.Text = char
		letterLabel.BackgroundTransparency = 1
		letterLabel.Size = UDim2.fromScale(1, 1)

		letterLabel.Font = Enum.Font.GothamBold
		letterLabel.TextScaled = true
		letterLabel.TextColor3 = Color3.new(1, 1, 1)
		letterLabel.RichText = true
		letterLabel.Parent = letterContainer

		--[[
            Uses scale to move up 25% of the container's height
        ]]
		local upPosition = UDim2.fromScale(0, -0.25)

		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, (i * 0.1))

		local tween = TweenService:Create(letterLabel, tweenInfo, { Position = upPosition })
		tween:Play()
		table.insert(tweens, tween)
	end
end

--[[
    Yields
]]
local function playPixelTransition()
	local transitionGui = Instance.new("ScreenGui")
	transitionGui.IgnoreGuiInset = true
	transitionGui.DisplayOrder = 9999
	transitionGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = transitionGui

	local cols = 12
	local rows = 7
	local cubes = {}

	for x = 0, cols - 1 do
		for y = 0, rows - 1 do
			local cube = Instance.new("Frame")
			cube.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			cube.BorderSizePixel = 0
			cube.AnchorPoint = Vector2.new(0.5, 0.5)

			cube.Size = UDim2.fromScale(0, 0)

			cube.Position = UDim2.fromScale((x + 0.5) / cols, (y + 0.5) / rows)

			cube.Parent = container
			table.insert(cubes, cube)
		end
	end

	local growInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	for i, cube in ipairs(cubes) do
		task.delay(i * 0.01, function()
			TweenService:Create(cube, growInfo, {
				Size = UDim2.fromScale(1 / cols + 0.02, 1 / rows + 0.02),
			}):Play()
		end)
	end

	task.wait(0.8)

	loadingScreen:Destroy()
	loadingBlur:Destroy()
	HUD.Enabled = true

	local shrinkInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)

	for i, cube in ipairs(cubes) do
		task.delay(i * 0.01, function()
			TweenService:Create(cube, shrinkInfo, {
				Size = UDim2.fromScale(0, 0),
			}):Play()
		end)
	end

	task.wait(1.55)
	transitionGui:Destroy()
end

local function onFinished()
	--[[
        Tweens pause and instance instend loadingText will be destoryed,
        Then we add the finished animation.
    ]]
	for _, tween in pairs(tweens) do
		tween:Pause()
		tween:Destroy()
	end

	for _, instance in pairs(loadingText:GetChildren()) do
		instance:Destroy()
	end

	playPixelTransition()

	script:Destroy() -- Makes sure the script isn't using any more resoruces
end

local function updateHint()
	local randomHint = Hints[math.random(1, #Hints)]

	--[[
        Fade out, change text, then fade in
    ]]
	local fadeOut = TweenService:Create(hintText, TweenInfo.new(0.5), { TextTransparency = 1 })
	local fadeIn = TweenService:Create(hintText, TweenInfo.new(0.5), { TextTransparency = 0 })

	fadeOut:Play()
	fadeOut.Completed:Wait()

	hintText.Text = randomHint

	fadeIn:Play()
end

hintText.TextTransparency = 0
updateHint()

task.spawn(function()
	while hintsEnabled do
		task.wait(5)
		if hintsEnabled then
			updateHint()
		end
	end
end)
--------------------------------------------------------

setupBouncyText(loadingText, "Loading...")

local assetsToLoad = Assets:GetDescendants()
for _, child in ipairs(playerGui:GetDescendants()) do
	table.insert(assetsToLoad, child)
end

local totalAssets = #assetsToLoad
local loadedAssets = 0

if totalAssets == 0 then
	green.Size = UDim2.fromScale(1, 1)
	percentage.Text = "100.0%"

	onFinished()
else
	green.Size = UDim2.fromScale(0, 1)
	percentage.Text = "0.0%"

	local fillTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	ContentProvider:PreloadAsync(assetsToLoad, function()
		loadedAssets += 1

		--[[
            math.clamp guarantees the ratio never drops below 0 or goes above 1 (100%)
        ]]
		local progressRatio = math.clamp(loadedAssets / totalAssets, 0, 1)

		--[[
            Smoothly tweens the green bar to the new percentage using scale
        ]]
		TweenService:Create(green, fillTweenInfo, { Size = UDim2.fromScale(progressRatio, 1) }):Play()

		percentage.Text = string.format("%.1f%%", progressRatio * 100)

		--[[
            Finished loading Assets
        ]]
		if loadedAssets == totalAssets then
			onFinished()
		end
	end)
end
