local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("Entity", function()
	return {
		Snapshot = ByteNet.definePacket({
			value = ByteNet.array(ByteNet.struct({
				id = ByteNet.uint16,

				-- Position
				--[[x = ByteNet.float32,
				z = ByteNet.float32,

				-- Rotation around Y
				rotation = ByteNet.float32,--]]
			})),
		}),
	}
end)