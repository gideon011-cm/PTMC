local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Data_ = require(ReplicatedStorage.Shared.Modules.Core.Data_).client

local module = {}
--Later
--[[function module:Init()
    local life = player:GetAttribute("Life")
    local cashProxy = Data_[life].Currency.Cash()

    cashProxy.Changed:Connect(function()
        print("changed")
    end)
end]]

return module