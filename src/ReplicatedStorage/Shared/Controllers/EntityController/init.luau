local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local EntityNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Entity)

local EntityController = Knit.CreateController({
    Name = "EntityController"
})

function EntityController:KnitStart()
    local entityServicxe = Knit.GetService("EntityService")

    entityServicxe.SpawnEntity:Connect(function(id: number, cframe: CFrame)
        print("Spawn entity", id, cframe)
    end)

    EntityNetwork.Snapshot.listen(function(data: {{ cf: CFrame, id: number }})
        print(data)
    end)
end

return EntityController