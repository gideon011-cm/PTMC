local EntityAbstract = {}
EntityAbstract.__index = EntityAbstract

function EntityAbstract.new(entityName: string, id: number, cframe: CFrame, tycoon: Model)
	local self = {
		EntityName = entityName,
		Id = id,
		CFrame = cframe,
		Tycoon = tycoon,

		PositionChanged = false,
	}

	setmetatable(self, EntityAbstract)

	return self
end

function EntityAbstract:UpdateAbstract(dt: number)
    self.PositionChanged = true
	--print("Abstract update:", self.EntityName)
end

function EntityAbstract:CreateSnapshot()
	return {
		id = self.Id,
	}
end

return EntityAbstract
