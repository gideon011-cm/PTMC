local UserInputS = game:GetService("UserInputService")

local camera: Camera = workspace.CurrentCamera

local Raycast = {}

function Raycast:GetMouseResult(raycastParams: RaycastParams?, raycastDistance : number): RaycastResult?
	local mousePos: Vector2 = UserInputS:GetMouseLocation()
	local ray: Ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params: RaycastParams = raycastParams or RaycastParams.new()
	local raycastResult: RaycastResult? = workspace:Raycast(
		ray.Origin,
		ray.Direction * raycastDistance,
		params
	)

	return raycastResult
end

return Raycast

