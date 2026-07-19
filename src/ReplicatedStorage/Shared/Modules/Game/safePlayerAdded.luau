local Players = game:GetService("Players")

local function safePlayerAdded(callback: (Player) -> () )
    --[[
        Calls the callback from early joined players
    ]]
    for _, player : Player in pairs(Players:GetChildren()) do
        callback(player)
    end

    return Players.PlayerAdded:Connect(callback)
end

return safePlayerAdded