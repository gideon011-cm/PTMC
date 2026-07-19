local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets:WaitForChild("Sounds")

local UI_Hover = Sounds:WaitForChild("UI_Hover")

local OnButtonPressed = script:WaitForChild("OnButtonPressed")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local HUD = playerGui:WaitForChild("HUD")
local Buttons = HUD:WaitForChild("Buttons")

local Settings = require("@self/Settings")

local api = {}

api.OgSizes = {} :: {
	[Frame]: UDim2,
}

api.ButtonsModules = {
    Build =  require(OnButtonPressed.Build),
    ["Co-Build"] = require(OnButtonPressed["Co-Build"]),
    Weapons = require(OnButtonPressed.Weapons)
}

--[[
    When the button is hovered we size up the button
]]
local function onHover(frame: Frame)
    local ogSize = api.OgSizes[frame]
    local sizeTween = UDim2.fromScale(ogSize.X.Scale * Settings.HOVER_SIZE, ogSize.Y.Scale * Settings.HOVER_SIZE)
    local tween = TweenService:Create(frame, Settings.BUTTON_HOVER_TWEENINFO, {Size = sizeTween})

    tween:Play()

    UI_Hover:Play()
end

--[[
    Resets the size with tween
]]
local function onLeaveHover(frame : Frame)
    local ogSize = api.OgSizes[frame]
    local tween = TweenService:Create(frame, Settings.BUTTON_HOVER_TWEENINFO, {Size = ogSize})

    tween:Play()
end

function api:Init()
	for _, frame: Frame in pairs(Buttons:GetChildren()) do
		local button = frame:FindFirstChild("Button") :: TextButton
		if not button then
			continue
		end
        
        self.OgSizes[frame] = frame.Size

		button.MouseEnter:Connect(function()
            onHover(frame)
        end)

        button.MouseLeave:Connect(function()
            onLeaveHover(frame)
        end)
        
        --[[
            When the button is clicked we will start the function
                 related to the button name
            
            --TODO: Add a visual stroke to signal it been selected
        ]]
        button.MouseButton1Click:Connect(function()
            local frameName = frame.Name
            local module = self.ButtonsModules[frameName]

            if module then
                --[[
                    Starts the module
                ]]
                module(HUD)
            end
        end)
	end
end

return api
