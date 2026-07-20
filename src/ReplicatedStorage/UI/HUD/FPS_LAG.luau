local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Extra = require(ReplicatedStorage.Shared.Modules.Game.Network.Extra)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local FPS_LAG = HUD:WaitForChild("FPS_LAG")

local api = {}

local ping = 100

local function getFPSColor(fps: number): string
	if fps >= 120 then
		return "#00FF00"
	elseif fps >= 60 then
		return "#7CFC00"
	elseif fps >= 30 then
		return "#FFD700"
	else
		return "#FF3B30"
	end
end

local function getPingColor(): string
	if ping <= 50 then
		return "#00FF00"
	elseif ping <= 100 then
		return "#FFD700"
	else
		return "#FF3B30"
	end
end

function api:Init()
	local TimeFunction = RunService:IsRunning() and time or os.clock

	local LastIteration, Start
	local FrameUpdateTable = {}

	--[[
		On every renderedStep finds the fps and ping
	]]
	local function HeartbeatUpdate()
		LastIteration = TimeFunction()
		for Index = #FrameUpdateTable, 1, -1 do
			FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index]
				or nil
		end

		FrameUpdateTable[1] = LastIteration

		local fps = math.floor(
			TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)
		)
		--[[
			This is mostly used for debug
			Rich text must be on
		]]
		FPS_LAG.Text = string.format(
			'FPS: <font color="%s">%d</font> | Latency: <font color="%s">%d ms</font>',
			getFPSColor(fps),
			fps,
			getPingColor(),
			ping
		)
	end

	Start = TimeFunction()
	RunService.RenderStepped:Connect(HeartbeatUpdate)

	--[[
		Listens to the ping packet then sets the ping to "myPing"
	]]
	Extra.Ping.listen(function(myPing: number)
		ping = myPing
	end)
end

return api
