local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local Trove = require(ReplicatedStorage.Packages.Trove)
local RoundData = require(ReplicatedStorage.Shared.Modules.Core.RoundData)
local RandomPositionInPart = require(ReplicatedStorage.Shared.Modules.Math.RandomPositionInPart)

local Handler = {}
Handler.__index = Handler


type data = {
	Player: Player,
	CurrentRound: number?,
	StartRounds: any,
	EndRounds: any,
}

function Handler.new(data: data)
	local self = {
		roundMaster = data.Player,
		currentRound = data.CurrentRound or 1,
		connections = {},
		startRounds = data.StartRounds,
		endRounds = data.EndRounds,
		Entities = {},
	}

	setmetatable(self, Handler)

	self.connections[#self.connections + 1] = self.startRounds:Connect(function()
		self:_StartRounds()
	end)

	self.connections[#self.connections + 1] = self.endRounds:Connect(function()
		self:_StopRounds()
	end)

	return self
end

function Handler:_StartRounds()
	self:_DestoryRoundEntities()

	local entities = self:_SpawnCurrentRoundEntities()
	self.Entities = entities
end

function Handler:_StopRounds()
	self:_DestoryRoundEntities()
end

function Handler:_SpawnCurrentRoundEntities()
	local entityService = Knit.GetService("EntityService")
	local tycoonService = Knit.GetService("TycoonService")

	local tycoon = tycoonService:GetTycoon(self.roundMaster)
	local entitySpawns = tycoon.EntitySpawns

	local roundEntityData = RoundData[self.currentRound]

	local entities = {}

	for entityName, amount in pairs(roundEntityData.Entities) do
		for _ = 1, amount do
			local spawnParts = entitySpawns:GetChildren()
			local spawnPart = spawnParts[
				math.random(1, #spawnParts)
			]

			local randomPosition = RandomPositionInPart(spawnPart)

			table.insert(entities, {
				Name = entityName,
				CFrame = CFrame.new(randomPosition),
			})
		end
	end

	return entityService:SpawnGroupOfEntity(entities, tycoon)
end

function Handler:_DestoryRoundEntities()
	local entityService = Knit.GetService("EntityService")
	local entityIds = {}

	for _, entity in ipairs(self.Entities) do
		if entity.Id then
			table.insert(entityIds, entity.Id)
		end
	end

	entityService:DespawnGroupOfEntity(entityIds)
	table.clear(self.Entities)
end

function Handler:Destroy()
	self:_DestoryRoundEntities()

	for _, connection in pairs(self.connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(self.connections)
	self.connections = nil
	self.startRounds = nil
	self.endRounds = nil
	self.currentRound = nil
	self.Entities = nil
end

return Handler
