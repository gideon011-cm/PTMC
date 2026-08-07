local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.Trove)
local HealthBar = require(ReplicatedStorage.Shared.Modules.Classes.HealthBar)
local MuchachoHitbox = require(ReplicatedStorage.Shared.Modules.Classes.MuchachoHitbox)

return function(model: Model, sharedData)
	HealthBar.new(model)

    local trove = Trove.new()

    trove:AttachToInstance(model)

    local hitbox = MuchachoHitbox.CreateHitbox()
    hitbox.Size = Vector3.new(5, 2, 5)
    hitbox.AutoDestroy = false

    hitbox.Touched:Connect(function()
        
    end)
end