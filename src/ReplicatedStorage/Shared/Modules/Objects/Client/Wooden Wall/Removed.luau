return function(sharedData: { [any]: any })
	if sharedData.HealthBar then
		sharedData.HealthBar:Destroy()
	end
end
