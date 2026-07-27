local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local Types = require(ReplicatedStorage.Shared.Modules.Types)

type Template = Types.Template

local Data = {}

Data.Template = {
	Life_1 = {
		Objects = {
			Placed = {},
			Stored = {
				Maxwell = {
					Amount = 1,
				},

				["Wooden Wall"] = {
					Amount = 4,
				},
			},
		},
	},
} :: Template

return DataServiceTyped({
	template = Data.Template,
	profileStoreIndex = "Private",
	useMock = true
})