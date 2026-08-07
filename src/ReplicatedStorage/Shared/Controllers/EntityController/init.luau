local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")
local Entities = Models:WaitForChild("Entities")

local __THINGS = workspace:WaitForChild("__THINGS")
local EntitiesFolder = __THINGS:WaitForChild("Entities")

local Knit = require(ReplicatedStorage.Packages.Knit)
local EntityNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Entity)
local EntityVisuals = require(script.EntityVisuals)

local EntityController = Knit.CreateController({
	Name = "EntityController",
})

local EntityStates = {}
local RenderConnection = nil

function EntityController:KnitStart()
	local entityService = Knit.GetService("EntityService")

	local function SpawnEntity(entityName, id, cframe)
		local model = Entities[entityName]
		if not model then
			return
		end

		local clone = model:Clone()
		clone.Name = tostring(id)
		clone:PivotTo(cframe)
		clone.Parent = EntitiesFolder

		EntityStates[id] = EntityVisuals.Create(clone, id, cframe)
	end

	local function DespawnEntity(id)
		local state = EntityStates[id]
		if not state then
			return
		end

		EntityVisuals.Destroy(state)
		EntityStates[id] = nil
	end

	entityService.SpawnEntity:Connect(SpawnEntity)
	entityService.DespawnEntity:Connect(DespawnEntity)

	entityService.SpawnEntityBatch:Connect(function(batchPacket)
		for _, data in ipairs(batchPacket) do
			SpawnEntity(data.entityName, data.id, data.cframe)
		end
	end)

	entityService.DespawnEntityBatch:Connect(function(entityIds)
		for _, id in ipairs(entityIds) do
			DespawnEntity(id)
		end
	end)

	EntityNetwork.Snapshot.listen(function(data)
		for _, snapshot in ipairs(data) do
			local id = snapshot.id
			local state = EntityStates[id]
			if not state then
				continue
			end

			local currentPosition = state.entity:GetPivot().Position
			local targetPosition = Vector3.new(snapshot.x, currentPosition.Y, snapshot.z)
			local lastPosition = state.LastPosition

			if lastPosition then
				local distance = (targetPosition - lastPosition).Magnitude
				EntityVisuals.SetWalking(state, distance >= 0.2)
			end

			state.LastPosition = targetPosition
			state.TargetCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, snapshot.rotation, 0)
		end
	end)

	if not RenderConnection then
		RenderConnection = RunService.RenderStepped:Connect(function(dt)
			for _, state in pairs(EntityStates) do
				if state.TargetCFrame then
					EntityVisuals.UpdatePosition(state, state.TargetCFrame, dt)
				end
			end
		end)
	end
end

return EntityController
