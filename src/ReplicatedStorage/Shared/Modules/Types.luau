local Types = {}

export type ColorTypes = "Exotic" | "Legendary" | "Epic"

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

return Types