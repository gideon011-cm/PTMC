local Colors = require(script.Parent.Colors)

local Config = {}

Config.Objects = {
    Maxwell = {
        Max = 1,
        ImageId = "rbxassetid://76379192098522",
        Color = Colors.Gradients.Extoic
    }
}

Config.Placement = {
    CanOverlapWithOtherParts = false,
	
	CanPlaceColor = Color3.fromRGB(13, 105, 172),
	CannotPlaceColor = Color3.fromRGB(255, 165, 0),
	
	LerpSpeed = 25,
	
	GridUnit = 0.2,
	RotationUnit = 15,
	
	RotateY = Enum.KeyCode.R,
	Cancel = Enum.KeyCode.X
}

return Config