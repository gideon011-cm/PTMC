local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EntityHitbox = require(ReplicatedStorage.Shared.Modules.Classes.EntityHitbox)
local HealthBar = require(ReplicatedStorage.Shared.Modules.Classes.HealthBar)

local EntityVisuals = {}

function EntityVisuals.Create(entity: BasePart & { ClientModel: any }, entityId: number, targetCFrame: CFrame)
	EntityHitbox.EnsureFor(entity)

	local healthBar = HealthBar.new(entity, entity.ClientModel)

	local state = {
		entity = entity,
		Id = entityId,
		TargetCFrame = targetCFrame,
		LastPosition = targetCFrame.Position,
		Walking = false,
		WalkingTrack = nil,
		HealthBar = healthBar,
	}

	return state
end

function EntityVisuals.SetWalking(state, walking: boolean)
	if state.Walking == walking then
		return
	end

	state.Walking = walking
	local clone = state.entity
	local track = state.WalkingTrack

	if not track then
		track = clone.ClientModel.Humanoid.Animator:LoadAnimation(clone.Animations.Walking)
		state.WalkingTrack = track
	end

	if walking then
		track:Play(0.15)
	else
		track:Stop(0.15)
	end
end

function EntityVisuals.UpdatePosition(state, targetCFrame: CFrame, dt: number)
	local currentCFrame = state.entity:GetPivot()
	state.entity:PivotTo(currentCFrame:Lerp(targetCFrame, math.min(dt * 1.2, 1)))
	state.TargetCFrame = targetCFrame
end

function EntityVisuals.Destroy(state)
	if state.WalkingTrack then
		state.WalkingTrack:Stop()
	end

	if state.HealthBar then
		state.HealthBar:Destroy()
	end

	if state.entity then
		state.entity:Destroy()
	end
end

return EntityVisuals
