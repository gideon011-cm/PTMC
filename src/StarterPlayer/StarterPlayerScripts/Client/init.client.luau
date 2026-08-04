local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Controllers = Shared:WaitForChild("Controllers")

local BootStrapper = require(ReplicatedStorage.Packages.BootStrapper)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: ModuleScript
local Knit = require(ReplicatedStorage.Packages.Knit)
local Tutorial = require(ReplicatedStorage.Shared.Modules.Classes.Tutorial)
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client
local Topbar = require(script.Topbar)

--Adds controllers to load
Knit.AddControllers(Controllers)

Knit.Start():andThen(function()
	--[[
        UI loads after controllers.
		Waits for the life attribute to be added to the player before running the UI.
    ]]

	repeat
		task.wait()
	until player:GetAttribute("Loaded") ~= nil

	BootStrapper.run({ ReplicatedStorage.UI }, "Start")
	Topbar()

	Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

	local life = player:GetAttribute("Life")
	local tutorialFinished = Data_[life].Tutorial.Finished()

	if not tutorialFinished then
		Tutorial.new(life)
	end
end)
