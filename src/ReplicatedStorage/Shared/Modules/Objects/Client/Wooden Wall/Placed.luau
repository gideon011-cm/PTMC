local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Models = Assets:WaitForChild("Models")

local HealthGui = Models:WaitForChild("HealthbarUI")

return function(model: Model, sharedData: { [any]: any })
	local clone = HealthGui:Clone()
	clone.Parent = model

	sharedData.HealthGui = clone

	local bar = clone.Frame.Bar

	local function UpdateHealth()
		local health = model:GetAttribute("Health") or 0
		local maxHealth = model:GetAttribute("MaxHealth") or 100

		local healthPercent = math.clamp(health / maxHealth, 0, 1)

		bar.Size = UDim2.fromScale(healthPercent, 1)

		bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPercent)
	end

	sharedData.HealthConnection = model:GetAttributeChangedSignal("Health"):Connect(UpdateHealth)

	UpdateHealth()
end
