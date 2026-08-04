local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EntitiesModules = script:WaitForChild("EntitiesModules")

local EntityNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Entity)
local Knit = require(ReplicatedStorage.Packages.Knit)

local EntityService = Knit.CreateService({
	Name = "EntityService",
	Client = {
		SpawnEntity = Knit.CreateSignal(),
	},
})

EntityService.Entities = {}

local nextEntityId = 0

function EntityService:KnitInit()
	local snapshotTimer = 0

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, entity in pairs(self.Entities) do
			if entity.Update then
				entity:Update(deltaTime)
			end
		end

		snapshotTimer += deltaTime

		if snapshotTimer < 0.1 then
			return
		end

		snapshotTimer -= 0.1

		local snapshots = {}

		for _, entity in pairs(self.Entities) do
			print("Entity:", entity)
			if entity.PositionChanged then
				print("SNAPSHOT:", entity:CreateSnapshot())
				table.insert(snapshots, entity:CreateSnapshot())

				entity.PositionChanged = false
			end
		end
		print(#snapshots)

		if #snapshots > 0 then
			print("Sending snapshots:", #snapshots)
			EntityNetwork.Snapshot.sendToAll(snapshots)
		end
	end)
end

function EntityService:SpawnEntity(entityName: string, id: number, cframe: CFrame, tycoon: Model)
	local entityModule = require(EntitiesModules:WaitForChild(entityName))

	self.Client.SpawnEntity:FireAll(id, cframe)

	local entity = entityModule.new({
		EntityName = entityName,
		id = id,
		cframe = cframe,
		tycoon = tycoon,
	})

	self.Entities[id] = entity

	return entity
end

function EntityService:GetNextEntityId()
	nextEntityId += 1

	return nextEntityId
end

function EntityService:SpawnGroupOfEntity(entityData: { { Name: string, CFrame: CFrame } }, tycoon: Model)
	local entityDatas = {}

	for _, data in pairs(entityData) do
		local entity = self:SpawnEntity(data.Name, self:GetNextEntityId(), data.CFrame, tycoon)

		table.insert(entityDatas, entity)
	end

	return entityDatas
end

return EntityService
