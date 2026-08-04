local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local RoundController = Knit.CreateController({
    Name = "RoundController"
})

--later use
--[[function RoundController:KnitStart()
    local roundService = Knit.GetService("RoundService")

    roundService.IsActive:Observe(function(active : boolean)
        if active then
            
        end
    end)
end]]

return RoundController