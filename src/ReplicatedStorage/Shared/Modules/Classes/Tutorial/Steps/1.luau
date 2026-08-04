local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")
local MaxwellTutorial = UI:WaitForChild("MaxwellTutorial")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local buttons = HUD:WaitForChild("Buttons")
local buildFrame = HUD:WaitForChild("BuildFrame")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TutorialHighlight = require(ReplicatedStorage.Shared.Modules.Classes.Tutorial.TutorialHighlight)

local function typewriteRichText(textLabel, htmlString, speed)
	speed = speed or 0.03

	textLabel.Text = htmlString
	textLabel.MaxVisibleGraphemes = 0

	local originalPosition = textLabel.Position

	textLabel.Position = originalPosition + UDim2.fromScale(0, 0.2)

	local popIn = TweenService:Create(textLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = originalPosition,
	})

	popIn:Play()

	local plainText = htmlString:gsub("<br%s*/>", "\n"):gsub("<[^<>]->", "")

	local graphemes = {}

	for start, finish in utf8.graphemes(plainText) do
		table.insert(graphemes, plainText:sub(start, finish))
	end

	for i = 1, #graphemes do
        if not textLabel then
            return
        end

		textLabel.MaxVisibleGraphemes = i
		task.wait(speed)
	end
end

local function step1(signal)
	local tycoonService = Knit.GetService("TycoonService")
	local connections = {}
	local buildActivatedConnection = nil
	local maxwellActivatedConnection = nil

	buildActivatedConnection = buttons.Build.Button.Activated:Once(function()
		maxwellActivatedConnection = buildFrame.Contanier.Maxwell.Button.Activated:Once(function()
			TutorialHighlight.Clear()

			tycoonService:GetTycoon():andThen(function(tycoon)
				local connection

				local textLabel = MaxwellTutorial:Clone()

				task.spawn(function()
					typewriteRichText(
						textLabel,
						"<font size='20'><b>Place <font color='#FFD54F'>Maxwell</font> Anywhere!</b></font><br/><font size='14'>You can place him anywhere on your <font color='#7DD3FC'>Tycoon</font>.</font>",
						0.015
					)
				end)

				textLabel.Parent = HUD

				connection = tycoon.Objects.ChildAdded:Connect(function(child: Model)
					if child.Name == "Maxwell" then
						signal:Fire()
						connection:Disconnect()
						connection = nil

                        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        local tween = TweenService:Create(textLabel, tweenInfo, {Size = UDim2.fromScale(0, 0)})
                        tween:Play()
                        
                        tween.Completed:Once(function()
                            textLabel:Destroy()
                        end)
					end
				end)
			end)
		end)

		TutorialHighlight.Focus(buildFrame.Contanier.Maxwell, 3.5, 0.5, 0.5)
	end)

	if buildActivatedConnection then
		connections[#connections + 1] = buildActivatedConnection
	end
	if maxwellActivatedConnection then
		connections[#connections + 1] = maxwellActivatedConnection
	end

	TutorialHighlight.Focus(buttons.Build, 3.5, 0.5, 0.5)
end

return step1
