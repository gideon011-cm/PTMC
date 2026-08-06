local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Shuffle = require(ReplicatedStorage.Shared.Modules.Math.Shuffle)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local Songs = Sounds:WaitForChild("Songs")
local Rounds = Sounds:WaitForChild("Round")
local UI = Sounds:WaitForChild("UI")

local SoundController = Knit.CreateController({
	Name = "SoundController",
})

SoundController.Folders = {
	UI = UI,
	Songs = Songs,
	Round = Rounds,
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

function SoundController:PlayPlaylist(folder: Folder)
	local playlist = {}

	for _, sound in ipairs(folder:GetChildren()) do
		if sound:IsA("Sound") then
			table.insert(playlist, sound)
		end
	end

	if #playlist == 0 then
		warn(`No sounds found in {folder:GetFullName()}`)
		return
	end

	while true do
		Shuffle(playlist)

		for _, song in ipairs(playlist) do
			song:Play()
			song.Ended:Wait()
		end
	end
end

function SoundController:ChangeSoundGroupVolume(soundGroup: string, volume: number, tweenSpeed: number)
	local group = self.Folders[soundGroup]

	TweenService:Create(
		group,
		TweenInfo.new(tweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Volume = volume }
	):Play()
end

function SoundController:KnitStart()
	task.spawn(function()
		self:PlayPlaylist(Songs)
	end)

	task.spawn(function()
		self:PlayPlaylist(Rounds)
	end)
end

return SoundController