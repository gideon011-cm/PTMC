local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIAssets = Assets:WaitForChild("UI")
local Build_Template = UIAssets:WaitForChild("Build_Template")

local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)

local function createTemplate(data: {
	Amount: number,
	Name: string,
}): Frame

    --[[
        Gets the objectData and clones the template
    ]]
	local objectData = Config.Objects[data.Name]
	local template = Build_Template:Clone()

    template.Name = data.Name

	local main = template.Main
	local center = main.Center

    --[[
        Sets up the center frame
    ]]
	local center_Gradient = center.UIGradient

	center.Icon.Image = objectData.ImageId
	center.Amount.Text = "x" .. data.Amount
	center_Gradient.Color = objectData.Color.Normal

    --[[
        Sets up the background frame
    ]]
	local background = main.BG
	local background_Gradient = background.UIGradient

	background_Gradient.Color = objectData.Color.Background

    --[[
        Sets up clicked frame then returns the template
    ]]
    center.ClickedFrame.UIGradient.Color = objectData.Color.Normal
	return template
end

return createTemplate
