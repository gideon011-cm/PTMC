local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")
local ObjectModules = Modules:WaitForChild("Objects").Server

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).server

local ObjectService = Knit.CreateService({
	Name = "ObjectService",
})

function ObjectService.Client:PlaceObject(player: Player, objectName: string, placedCFrame: CFrame) : (boolean | string, Model?)
	assert(typeof(objectName) == "string", "argument 'objectName' must be a string")
	assert(typeof(placedCFrame) == "CFrame", "argument 'placedCFrame' must be a CFrame")

	local playerData = Data_[player]
	if not playerData then
		return "Erorr"
	end

	local life = player:GetAttribute("Life")
	if not life then
		return "Erorr"
	end

	local storedProxy = playerData[life].Objects.Stored
	local storedTable = storedProxy()

	local objectData = storedTable and storedTable[objectName]
	if not objectData then
		return "Erorr"
	end

	local currentAmount = objectData.Amount
	if not currentAmount or currentAmount <= 0 then
		return "Erorr"
	end

	local model = Models:FindFirstChild(objectName)
	if not model then
		warn(`Model '{objectName}' does not exist in Assets.Models`)
		return "Erorr"
	end

	local tycoonService = Knit.GetService("TycoonService")
	
	local clone = model:Clone()
	clone:PivotTo(placedCFrame)
	clone.Parent = tycoonService:GetTycoon(player).Objects

	local newAmount = currentAmount - 1

	local placedModule = ObjectModules[objectName]:FindFirstChild("Placed")

	if placedModule then
		local module = require(placedModule)
		module(clone, {})
	end

	if newAmount <= 0 then
		-- Setting the key to nil via the proxy removes it and triggers replication
		storedProxy[objectName](nil)
		
        return false, clone
	else
		-- Update the amount field
		storedProxy[objectName].Amount(newAmount)

        return true, clone
	end
end

return ObjectService
