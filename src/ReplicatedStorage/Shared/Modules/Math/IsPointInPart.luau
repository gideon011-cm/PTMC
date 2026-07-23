local function IsPointInPart(part: BasePart, point: Vector3): boolean
	local relativePoint: Vector3 = part.CFrame:PointToObjectSpace(point)

	return math.abs(relativePoint.X) < part.Size.X / 2
		and math.abs(relativePoint.Y) < part.Size.Y / 2
		and math.abs(relativePoint.Z) < part.Size.Z / 2
end

return IsPointInPart