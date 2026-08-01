local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client
local Signal = require(ReplicatedStorage.Packages.Signal)
local TutorialNetwork = require(ReplicatedStorage.Shared.Modules.Game.Network.Tutorial)

local Steps = script.Steps

local Tutorial = {}
Tutorial.__index = Tutorial

function Tutorial.new(life : string)
    local self = {
        life = life,
        stepFinished = Signal.new(),
        connections = {}
    }

    setmetatable(self, Tutorial)

    self:StartCurrent()

    self.connections["StepFinished"] = self.stepFinished:Connect(function()
        TutorialNetwork.request.send("AddStep")
    end)

    self.connections["StepChanged"] = Data_[self.life].Tutorial.Step.Changed(function()
        self:StartCurrent()
    end)

    return self
end

function Tutorial:StartCurrent()
    local step = Data_[self.life].Tutorial.Step()

    local module = require(Steps[step])
    module(self.stepFinished)
end

function Tutorial:Destroy()
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
            connection = nil
        end
    end
end

return Tutorial