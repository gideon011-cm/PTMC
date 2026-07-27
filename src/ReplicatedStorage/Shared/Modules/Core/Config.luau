local Colors = require(script.Parent.Colors)

local Config = {}

Config.Objects = {
    Maxwell = {
        Max = 1,
        ImageId = "rbxassetid://79561629406259",
        Color = Colors.Gradients.Extoic
    },

    ["Wooden Wall"] = {
        Max = 99,
        ImageId = "rbxassetid://128067893234381",
        Color = Colors.Gradients.Gray
    }
}

Config.Placement = {
    CanOverlapWithOtherParts = false,
    
    CanPlaceColor = Color3.fromRGB(13, 105, 172),
    CannotPlaceColor = Color3.fromRGB(255, 165, 0),
    
    TweenDuration = 0.27,
    
    GridUnit = 1,
    RotationUnit = 15,
    
    Rotate = Enum.KeyCode.R,
    Cancel = Enum.KeyCode.X
}

return Config