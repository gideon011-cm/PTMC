local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HealthBar = require(ReplicatedStorage.Shared.Modules.Classes.HealthBar)

return function(model: Model)
	HealthBar.new(model)
end