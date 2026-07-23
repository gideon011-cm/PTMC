local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Potato = require(script.Potato)
local Topbarplus = require(ReplicatedStorage.Packages.Topbarplus)

local function startTopBar()
	Topbarplus.new()
		:setName("Settings")
		:setImage(106254269390341)
		:setCaption("Settings")
		:setMenu({
			Topbarplus.new()
				:setImage(111344270567744)
				:setCaption("Potato Mode")
				:oneClick(false)
				:bindEvent("selected", Potato)
		})
end

--AFK
return startTopBar