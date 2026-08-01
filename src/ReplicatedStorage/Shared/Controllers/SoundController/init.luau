local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shuffle = require(ReplicatedStorage.Shared.Modules.Math.Shuffle)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")
local Songs = Sounds:WaitForChild("Songs")
local UI = Sounds:WaitForChild("UI")

local SoundController = Knit.CreateController({
	Name = "SoundController",
})

SoundController.Folders = {
	UI = UI,
	Songs = Songs,
}

function SoundController:GetSound(folderName: string, soundName: string): Sound?
	local folder = self.Folders[folderName]
	if not folder then
		warn(`Sound folder '{folderName}' does not exist`)
		return nil
	end

	local sound = folder:FindFirstChild(soundName)
	if not sound then
		warn(`Sound '{soundName}' does not exist in Sounds.{folderName}`)
		return nil
	end

	if not sound:IsA("Sound") then
		warn(`Sounds.{folderName}.{soundName} is not a Sound`)
		return nil
	end

	return sound
end

function SoundController:PlaySound(folderName: string, soundName: string): Sound?
	local sound = self:GetSound(folderName, soundName)
	if not sound then
		return nil
	end

	sound:Play()
	return sound
end

function SoundController:PlayUI(soundName: string): Sound?
	return self:PlaySound("UI", soundName)
end

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
