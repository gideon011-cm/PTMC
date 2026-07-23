local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)

export type StoredObject = {
	Amount: number,
}

export type Objects = {
	Placed: {},
	Stored: {
		[string]: StoredObject,
	},
}

export type Life = {
	Objects: Objects,
}

export type Template = {
	Life_1: Life,
}

local Data = {}

Data.Template = {
	Life_1 = {
		Objects = {
			Placed = {},
			Stored = {
				Maxwell = {
					Amount = 1,
				},
			},
		},
	},
} :: Template

return DataServiceTyped({
	template = Data.Template,
	dontSave = true,
})
