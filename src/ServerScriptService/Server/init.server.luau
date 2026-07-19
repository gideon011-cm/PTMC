local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Services")

local Modules = Shared:WaitForChild("Modules")

local BootStrapper = require("@game/ReplicatedStorage/Packages/BootStrapper")
local Knit = require("@game/ReplicatedStorage/Packages/Knit")

Knit.AddServices(Services)

--Starts the services
Knit.Start():andThen(function()
    --[[
        Services would have to use :WaitForData function with the Data module
        Data loads after services
    ]]
    BootStrapper.loadDescendants(Modules, BootStrapper.byName("_$")) --[[
        Data
    ]]
end)
