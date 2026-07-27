local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = Shared:WaitForChild("Modules")
local ObjectModules = Modules:WaitForChild("Objects").Client

return function(model : Model)
    local placedModule = ObjectModules:FindFirstChild(model.Name):FindFirstChild("Placed")
    print(placedModule)
    if placedModule then
        print("g")
        local module = require(placedModule)

        module(model, {})
    end
end
