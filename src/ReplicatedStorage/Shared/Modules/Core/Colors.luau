local Colors = {}

Colors.Gradients = {
	Extoic = {
		Normal = ColorSequence.new(Color3.fromRGB(255, 112, 119), Color3.fromRGB(200, 62, 186)),
		Background = ColorSequence.new(Color3.fromRGB(85, 85, 85), Color3.fromRGB(173, 54, 161)),
	},

	Gray = {
		Normal = ColorSequence.new(Color3.fromRGB(99, 99, 99), Color3.fromRGB(125, 125, 125)),
		Background = ColorSequence.new(Color3.fromRGB(38, 37, 37), Color3.fromRGB(74, 74, 74)),
	}
}

Colors.Red = ColorSequence.new(Color3.fromRGB(255, 109, 80), Color3.fromRGB(255, 99, 85))
Colors.Green = ColorSequence.new(Color3.fromRGB(147, 255, 147), Color3.fromRGB(119, 255, 119))

return Colors
