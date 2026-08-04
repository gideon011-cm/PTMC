local function RandomPositionInPart(part: BasePart): Vector3
    local x = math.random(-part.Size.X / 2, part.Size.X / 2)
    local y = math.random(-part.Size.Y / 2, part.Size.Y / 2)
    local z = math.random(-part.Size.Z / 2, part.Size.Z / 2)

    return part.CFrame:PointToWorldSpace(Vector3.new(x, y, z))
end

return RandomPositionInPart