local DataServiceTyped = require("../../../Packages/DataServiceTyped")

local Data = {}

Data.Template = {
	Life_1 = {
		Objects = {
			Placed = {},
			Stored = {},
		},
	},
}

return DataServiceTyped({
	template = Data.Template,
	dontSave = true,
})
