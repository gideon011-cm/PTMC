local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Handler = require(script.Handler)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local RoundService = Knit.CreateService({
	Name = "RoundService",
	Client = {
		IsActive = Knit.CreateProperty(false),
	},
})

local roundPlayerData = {}

--[[
    Creates a table for the player when they join or leave
    Removes them from the table after they leave to not have a memory leak
]]
function RoundService:KnitStart()
	Players.PlayerAdded:Connect(function(player: Player)
		roundPlayerData[player] = {
			Handler = Handler.new({ Player = player, StartRounds = Signal.new(), EndRounds = Signal.new() }),
			Active = false,
		}
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local playerData = roundPlayerData[player]
		if not playerData then
			return
		end

		local handler = playerData.Handler
		if handler then
			handler:Destroy()
		end

		roundPlayerData[player] = nil
	end)
end

function RoundService.Client:StartRounds(player: Player)
	RoundService.Client.IsActive:SetFor(player, true)
    
    local handler = roundPlayerData[player].Handler

    handler.startRounds:Fire()

	roundPlayerData[player].Active = true
end

function RoundService.Client:StopRounds(player: Player)
	RoundService.Client.IsActive:SetFor(player, false)

    local handler = roundPlayerData[player].Handler

    handler.endRounds:Fire()

	roundPlayerData[player].Active = false
end

function RoundService.Client:IsRoundActive(player: Player)
	return roundPlayerData[player].Active
end

return RoundService
