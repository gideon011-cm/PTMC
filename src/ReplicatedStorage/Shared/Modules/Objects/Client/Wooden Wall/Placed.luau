local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HealthBar = require(ReplicatedStorage.Shared.Modules.Classes.HealthBar)

return function(model: Model, sharedData: { [any]: any })
	sharedData.HealthBar = HealthBar.new(model)
end
