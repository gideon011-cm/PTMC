local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Modules.Core.Config)
local ParamsBuilder = require(ReplicatedStorage.Shared.Modules.Game.ParamsBuilder)

local Validation = {}

-- Determines whether a preview instance can be placed.
--
-- toCheck:
--   - Model/BasePart/table (supported types)
-- objectsToCheck:
--   BaseParts included in OverlapParams / workspace:GetPartsInPart filtering.
--
-- NOTE:
--   This module currently returns *false* if any colliding part is found
--   (excluding parts that are descendants of `parent` and parts tagged
--   "Object_IgnoreCollision").
function Validation:HasValidPlacement(toCheck: any, objectsToCheck: {}): boolean
	if not toCheck then
		return false
	end

	local overlapParams: OverlapParams = OverlapParams.new()
	local params = ParamsBuilder.new(overlapParams)

	local function HasValidPlacement(basePart: BasePart, parent: Instance?): boolean
		if not basePart.CanQuery then
			return true
		end
		if Config.Placement.CanOverlapWithOtherParts then
			return true
		end

		local intersectingParts: { BasePart } = workspace:GetPartsInPart(basePart, overlapParams)
		for _, intersectingPart: BasePart in intersectingParts do
			if parent and intersectingPart:IsDescendantOf(parent) then
				continue
			end

			local ignoreCollision: boolean = intersectingPart:HasTag("Object_IgnoreCollision")
			if ignoreCollision then
				continue
			end

			return false
		end

		return true
	end

	params.CollisionGroup = ""
	params:Include(objectsToCheck)

	if typeof(toCheck) == "table" then
		for _, instance: Instance in toCheck do
			if not instance:IsA("BasePart") then
				continue
			end

			local hasValidPlacement: boolean = HasValidPlacement(instance)
			if hasValidPlacement then
				continue
			end

			return false
		end
	elseif toCheck:IsA("BasePart") then
		local hasValidPlacement: boolean = HasValidPlacement(toCheck)
		return hasValidPlacement
	elseif toCheck:IsA("Model") then
		for _, descendant: BasePart in toCheck:GetDescendants() do
			if not descendant:IsA("BasePart") then
				continue
			end

			local hasValidPlacement: boolean = HasValidPlacement(descendant, toCheck)
			if hasValidPlacement then
				continue
			end

			return false
		end
	end

	return true
end

return Validation
