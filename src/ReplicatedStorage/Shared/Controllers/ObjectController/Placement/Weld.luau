local function Weld(part0: BasePart, part1: BasePart): WeldConstraint
	local weldConstraint: WeldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part0
	weldConstraint.Part1 = part1
	weldConstraint.Parent = part0

	return weldConstraint
end

return Weld