local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local FPS_LAG = HUD:WaitForChild("FPS_LAG")

local api = {}

local ping = 100

local function getFPSColor(fps: number): Color3 end

local function getPingColor(): Color3 end

function api:Init()
	print("f")
	local TimeFunction = RunService:IsRunning() and time or os.clock

	local LastIteration, Start
	local FrameUpdateTable = {}

	local function HeartbeatUpdate()
		print("f")
		LastIteration = TimeFunction()
		for Index = #FrameUpdateTable, 1, -1 do
			FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index]
				or nil
		end

		FrameUpdateTable[1] = LastIteration
		FPS_LAG.Text = tostring(
			math.floor(
				TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)
			)
		) .. " FPS"
	end

	Start = TimeFunction()
	RunService.RenderStepped:Connect(HeartbeatUpdate)
end

return api
