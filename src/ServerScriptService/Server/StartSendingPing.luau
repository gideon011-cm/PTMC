local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Extra = require(ReplicatedStorage.Shared.Modules.Game.Network.Extra)

--[[
    Starts sending ping to client
    client scripts like "FPS_LAG" needs this

    YEILDS
]]
local function startSendingPing()
	while task.wait(2) do
		for _, player in pairs(Players:GetPlayers()) do
            --[[
                sends the player ping with a mutilper of 2000
                server sends = 1000ms
                client gets = ~1000ms
                = ~2000
            ]]
			Extra.Ping.sendTo(player:GetNetworkPing() * 2000, player)
		end
	end
end

return startSendingPing
