local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return ByteNet.defineNamespace("Tutorial", function()
	return {
		request = ByteNet.definePacket({
			value = ByteNet.string,
		}),
	}
end)
