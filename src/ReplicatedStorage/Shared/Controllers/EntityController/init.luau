local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")
local Entities = Models:WaitForChild("Entities")

local __THINGS = workspace:WaitForChild("__THINGS")
local EntitiesFolder = __THINGS:WaitForChild("Entities")

local Knit = require(ReplicatedStorage.Packages.Knit)
local HealthBar = require(ReplicatedStorage.Shared.Modules.Classes.HealthBar)
local EntityNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Entity)

local EntityController = Knit.CreateController({
	Name = "EntityController",
})

local EntityModels = {}
local EntityTargets = {}
local EntityLastPositions = {}
local EntityHealthBars = {}

local EntityWalking = {}
local EntityWalkingTracks = {}

local function SetWalking(id, clone, walking)
	if EntityWalking[id] == walking then
		return
	end

	EntityWalking[id] = walking

	local track = EntityWalkingTracks[id]

	if not track then
		track = clone.ClientModel.Humanoid.Animator:LoadAnimation(clone.Animations.Walking)
		EntityWalkingTracks[id] = track
	end

	if walking then
		track:Play(0.15)
	else
		track:Stop(0.15)
	end
end

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

		EntityModels[id] = clone
		EntityTargets[id] = cframe
		EntityLastPositions[id] = cframe.Position
		EntityWalking[id] = false
		EntityHealthBars[id] = HealthBar.new(clone, clone.ClientModel)
	end

	local function DespawnEntity(id)
		local clone = EntityModels[id]

		if not clone then
			return
		end

		clone:Destroy()

		local walkingTrack = EntityWalkingTracks[id]
		if walkingTrack then
			walkingTrack:Stop()
			EntityWalkingTracks[id] = nil
		end

		EntityModels[id] = nil
		EntityTargets[id] = nil
		EntityLastPositions[id] = nil
		EntityWalking[id] = nil
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
			local clone = EntityModels[id]

			if not clone then
				continue
			end

			local currentPosition = clone:GetPivot().Position

			local targetPosition = Vector3.new(snapshot.x, currentPosition.Y, snapshot.z)

			local lastPosition = EntityLastPositions[id]

			if lastPosition then
				local distance = (targetPosition - lastPosition).Magnitude

				SetWalking(id, clone, distance >= 0.2)
			end

			EntityLastPositions[id] = targetPosition

			EntityTargets[id] = CFrame.new(targetPosition) * CFrame.Angles(0, snapshot.rotation, 0)
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		for id : number, clone : BasePart in pairs(EntityModels) do
			local targetCFrame = EntityTargets[id]

			if targetCFrame then
				--[[
					Lerps the clone to the targetCFrame
					Changing (math.min (dt * here, 1)) can make it snapper or smoother
				]]
				local currentCFrame = clone:GetPivot()
				clone:PivotTo(currentCFrame:Lerp(targetCFrame, math.min(dt * 1.2, 1)))
			end
		end
	end)
end

return EntityController
