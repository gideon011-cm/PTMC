local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EntitiesModules = script:WaitForChild("EntitiesModules")

local EntityNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Entity)
local Knit = require(ReplicatedStorage.Packages.Knit)

local EntityService = Knit.CreateService({
	Name = "EntityService",
	Client = {
		SpawnEntity = Knit.CreateSignal(),
		DespawnEntity = Knit.CreateSignal(),
		
		SpawnEntityBatch = Knit.CreateSignal(),
		DespawnEntityBatch = Knit.CreateSignal()
	},
})

EntityService.Entities = {}

local nextEntityId = 0

function EntityService:KnitInit()
	local snapshotTimer = 0
	local snapshotInterval = 0.2

	RunService.Heartbeat:Connect(function(deltaTime : number)
		local entities = self.Entities

		for _, entity in pairs(entities) do
			if entity.Update then
				entity:Update(deltaTime)
			end
		end

		snapshotTimer += deltaTime

		if snapshotTimer < snapshotInterval then
			return
		end

		snapshotTimer = 0

		local snapshots = {}

		for _, entity in pairs(entities) do
			--[[
				Only send snapshots for entities that have changed position since the last snapshot.
				This reduces the amount of data sent over the network and improves performance.
			]]
			if entity.PositionChanged then
				table.insert(snapshots, entity:CreateSnapshot())
				entity.PositionChanged = false
			end
		end

		if #snapshots > 0 then
			EntityNetwork.Snapshot.sendToAll(snapshots)
		end
	end)
end

function EntityService:SpawnEntity(entityName: string, id: number, cframe: CFrame, tycoon: Model, isBatch: boolean?)
	local entityModule = require(EntitiesModules:WaitForChild(entityName))

	--[[
		Sends 1 packet if it a batch
	]]
	if not isBatch then
		self.Client.SpawnEntity:FireAll(entityName, id, cframe)
	end

	local entity = entityModule.new({
		EntityName = entityName,
		id = id,
		cframe = cframe,
		tycoon = tycoon,
	})

	self.Entities[id] = entity

	return entity
end

function EntityService:DespawnEntity(id: number)
	local entity = self.Entities[id]

	if not entity then
		return
	end

	entity:Destory()

	self.Entities[id] = nil
	self.Client.DespawnEntity:FireAll(id)
end

function EntityService:DespawnGroupOfEntity(entityIds: { number })
	local despawnedEntityIds = {}

	for _, id in ipairs(entityIds) do
		local entity = self.Entities[id]

		if not entity then
			continue
		end

		entity:Destory()
		self.Entities[id] = nil
		table.insert(despawnedEntityIds, id)
	end

	if #despawnedEntityIds > 0 then
		self.Client.DespawnEntityBatch:FireAll(despawnedEntityIds)
	end
end

function EntityService:GetNextEntityId()
	--[[
		Increment the nextEntityId by 1 and return the new value.
		This ensures that each entity gets a unique ID.
	]]
	nextEntityId += 1
	return nextEntityId
end

function EntityService:SpawnGroupOfEntity(entityData: { { Name: string, CFrame: CFrame } }, tycoon: Model)
	local entityDatas = {}
	local batchPacket = {}

	for _, data in pairs(entityData) do
		local id = self:GetNextEntityId()

		local entity = self:SpawnEntity(data.Name, id, data.CFrame, tycoon, true)

		table.insert(entityDatas, entity)

		table.insert(batchPacket, {
			entityName = data.Name,
			id = id,
			cframe = data.CFrame,
		})
	end

	self.Client.SpawnEntityBatch:FireAll(batchPacket)

	return entityDatas
end

return EntityService
