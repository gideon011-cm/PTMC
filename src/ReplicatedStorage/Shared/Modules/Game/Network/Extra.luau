local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("Extra", function()
	return {
		Ping = ByteNet.definePacket({
			value = ByteNet.float32,
		}),
	}
end)
