local ServerScriptService = game:GetService("ServerScriptService")

local EntityAbstract = require(ServerScriptService.Services.EntityService.EntityAbstract)

local Zombie = setmetatable({}, {
	__index = EntityAbstract,
})

Zombie.__index = Zombie

function Zombie.new(data)
	local self = EntityAbstract.new(data.EntityName, data.id, data.cframe, data.tycoon)

	setmetatable(self, Zombie)

	return self
end

function Zombie:Update(dt)
	self:UpdateAbstract(dt)
end

return Zombie
