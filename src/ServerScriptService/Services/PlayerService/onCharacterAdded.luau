local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--[[
	Helpful when the character is added
]]
local function onCharacterAdded(character: Model)
	for _, instance in pairs(character:GetChildren()) do
		if instance:IsA("BasePart") then
			instance.CollisionGroup = "Player"
		end
	end
	
	local tycoonService = Knit.GetService("TycoonService")

	local player = Players:GetPlayerFromCharacter(character)

	local playerTycoon = tycoonService:GetTycoon(player)

	local offset = Vector3.new(0, 5, 0)
	local primaryPart = character.PrimaryPart

	primaryPart.CFrame = playerTycoon.PrimaryPart.CFrame + offset
end

return onCharacterAdded
