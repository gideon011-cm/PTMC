local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require("../../Packages/Knit")
local Shuffle = require("../Modules/Math/Shuffle")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Songs = Sounds:WaitForChild("Songs")

local SoundController = Knit.CreateController({
	Name = "SoundController",
})

function SoundController:KnitStart()
	local playlist = Songs:GetChildren()

	Shuffle(playlist)
    
    --[[
        Plays random songs, uses shuffle to make sure it not playing the same song over and over again
    ]]
	while true do
		for _, song in ipairs(playlist) do
			song:Play()
			song.Ended:Wait()
		end

		Shuffle(playlist)
	end
end

return SoundController
