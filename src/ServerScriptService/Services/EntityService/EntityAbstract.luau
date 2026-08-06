local EntityAbstract = {}
EntityAbstract.__index = EntityAbstract

function EntityAbstract.new(
	entityName: string,
	id: number,
	cframe: CFrame,
	tycoon: Model & { Objects: { Maxwell: Model } }
)
	local self = {
		EntityName = entityName,
		Id = id,

		CFrame = cframe,
		Maxwell = tycoon.Objects.Maxwell,

		Speed = 5,

		PositionChanged = false,
	}

	setmetatable(self, EntityAbstract)
	
	return self
end

function EntityAbstract:UpdateAbstract(dt: number)
	local maxwellPrimaryPart = self.Maxwell.PrimaryPart

	if not maxwellPrimaryPart then
		return
	end

	local currentPosition = self.CFrame.Position
	local targetPosition = maxwellPrimaryPart.Position

	local offset = targetPosition - currentPosition
	local distance = offset.Magnitude

	if distance <= 0.05 then
		return
	end

	local direction = offset.Unit

	local movement = math.min(self.Speed * dt, distance)

	local newPosition = currentPosition + direction * movement

	self.CFrame = CFrame.lookAt(
		newPosition,
		newPosition + direction
	)
	
	self.PositionChanged = true
end

function EntityAbstract:DestoryAbstract()
	--Noting to really destory here
end

function EntityAbstract:CreateSnapshot()
	local _, y, _ = self.CFrame:ToEulerAnglesYXZ()

	return {
		id = self.Id,
		x = self.CFrame.X,
		z = self.CFrame.Z,
		rotation = y,
	}
end

return EntityAbstract